local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")
local InviteFromServerRemoteEvent = ReplicatedStorage:WaitForChild("InviteFromServer")
local InviteFriendsRemoteEvent = ReplicatedStorage:WaitForChild("InviteFriends")
local PlayerAddedToPartyRemoteEvent = ReplicatedStorage:WaitForChild("PlayerAddedToParty")
local InvitationResponseRemoteEvent = ReplicatedStorage:WaitForChild("InvitationResponse")
local CreateTeamGameGuiRemoteEvent = ReplicatedStorage:WaitForChild("CreateTeamGameGui")
local ReplicateTeamGameGuiRemoteEvent = ReplicatedStorage:WaitForChild("ReplicateTeamGameGui")
local ReplicateTeamGameGuiHostOnAnotherServerRemoteEvent = ReplicatedStorage:WaitForChild("ReplicateTeamGameGuiHostOnAnotherServer")
local PlayerJoinedPartyRemoteEvent = ReplicatedStorage:WaitForChild("PlayerJoinedParty")
local PlayerDeclinedPartyRemoteEvent = ReplicatedStorage:WaitForChild("PlayerDeclinedParty")
local RemovePlayerFromPartyRemoteEvent = ReplicatedStorage:WaitForChild("RemovePlayerFromParty")
local DeletepartyRemoteEvent = ReplicatedStorage:WaitForChild("DeleteParty")
local SelectModeRemoteEvent = ReplicatedStorage:WaitForChild("SelectMode")
local StartRemoteFunction = ReplicatedStorage:WaitForChild("Start")

local MemoryStoreService = game:GetService("MemoryStoreService")
local normalQueue= MemoryStoreService:GetQueue("MatchmakingNormal")
local hardQueue = MemoryStoreService:GetQueue("MatchmakingHard")

local SafeTeleport = require(ServerScriptService.SafeTeleport)

local selectModeCooldown : NumberValue = ReplicatedStorage:WaitForChild("SelectModeCooldown")

-- List of the map places id
local mapIds = {9574932625, 9574932625, 9574932625}

local parties : {{string}} = {}
local hostParty : {string : string} = {}
local numberOfPlayersInParty : {string : number} = {}


local function AddPlayerToParty(player : Player)
	local hostName : string = player.PartyHost.Value
	
	for _,v : {string} in pairs(parties) do
		if table.find(v, hostName) then
			table.insert(v, player.Name)
		end
	end
	
end


-- get the party that contains the specified player
local function GetPartyWithPlayer(playerName : string)
	for _,v : {string} in pairs(parties) do
		if table.find(v, playerName) then
			return v
		end
	end
	
	return {}
end


local function RemovePlayerFromParty(playerName : string)
	for _,v : {string} in pairs(parties) do
		
		local position : number? = table.find(v, playerName)
		if position then
			
			if numberOfPlayersInParty[playerName] then
				numberOfPlayersInParty[playerName] -= 1

				for _,b : string in pairs(GetPartyWithPlayer(playerName)) do

					if Players:FindFirstChild(b) then
						RemovePlayerFromPartyRemoteEvent:FireClient(Players:FindFirstChild(b), playerName)
					else
						--MessagingService:PublishAsync("RemovePlayerFromParty", {5, b, playerName})
						MessagingService:PublishAsync("Other", {5, b, playerName})
					end
				end

				-- remove the player from the party table
				table.remove(v, position)

				break
			end
		end
	end
end


local function IsPartyFull(playerName : string)
	local party : {string}? = GetPartyWithPlayer(playerName)
	
	if party then
		if #party <= 4 then
			return false
		end
	end
	
	return true
end


-- copy the player's folders into the player
Players.PlayerAdded:Connect(function(plr : Player)
	for _,v in ipairs(ServerStorage.PlayerFolders:GetChildren()) do
		v:Clone().Parent = plr
	end
end)


local function AddPlayerToQueue()
	
end


local function TeleportToServer(plr, mapId, mode)
	local reservedServerCode = TeleportService:ReserveServer(mapId)
	
	local playersToTeleport = {plr}
	
	local teleportData = {
		numberOfPlayers = 1,
		mode = mode
	}
	
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = reservedServerCode
	teleportOptions:SetTeleportData(teleportData)
	
	return SafeTeleport(mapId, playersToTeleport, teleportOptions)
end


-- Player clicked the play button.
-- If he plays solo mode, teleport him to a reserved server of the map he chose
-- If he plays team mode, add him to the queue
StartRemoteFunction.OnServerInvoke = function(plr : Player, teamSize : number, map : number, mode : number)
	
	if teamSize and mode and map and typeof(teamSize) == "number" and typeof(mode) == "number" and typeof(map) == "number" then

		if teamSize == 1 then
			if mode >= 1 and mode <= 5 then
				if mapIds[map] then
					if not plr.IsInParty.Value then
						return TeleportToServer(plr, mapIds[map], mode)
					end
				end
			end

		elseif teamSize <= 4 then
			
		end
	end
	
	return false
end


-- player invited another player to join their party
InviteFromServerRemoteEvent.OnServerEvent:Connect(function(plr : Player, player : Player)
	if player and typeof(player) == "Instance" then

		if plr ~= player then
			if not IsPartyFull(plr.Name) then
				
				-- get the number of players invited or in the party
				if numberOfPlayersInParty[plr.Name] then
					numberOfPlayersInParty[plr.Name] += 1
				else
					numberOfPlayersInParty[plr.Name] = 1
				end
				
				if numberOfPlayersInParty[plr.Name] and numberOfPlayersInParty[plr.Name] < 4 then
					
					-- create the party if the player is not already in a party
					if not plr.IsInParty.Value then
						plr.IsInParty.Value = true

						-- create the party
						table.insert(parties, {plr.Name})
					end

					-- if the player is not in a party yet, invite him to the party
					player.PartyHost.Value = plr.Name
					InviteFromServerRemoteEvent:FireClient(player)

					-- tell all the players in the party that someone was invited
					for _,v : string in pairs(GetPartyWithPlayer(plr.Name)) do
						local playerInParty : Player? = Players:FindFirstChild(v)

						-- if the player is in the same server, tell him
						if playerInParty then
							PlayerAddedToPartyRemoteEvent:FireClient(playerInParty, player.Name)
						else
							--MessagingService:PublishAsync("PlayerAddedToParty", {1, playerInParty.Name, player.Name})
							MessagingService:PublishAsync("Other", {1, playerInParty.Name, player.Name})
						end
					end
				end
			end
		end
	end
end)


InviteFriendsRemoteEvent.OnServerEvent:Connect(function(plr : Player, playerName : string)

	if plr.Name ~= playerName then
		if not IsPartyFull(plr.Name) then

			-- get the number of players invited or in the party
			if numberOfPlayersInParty[plr.Name] then
				numberOfPlayersInParty[plr.Name] += 1
			else
				numberOfPlayersInParty[plr.Name] = 1
			end

			if numberOfPlayersInParty[plr.Name] and numberOfPlayersInParty[plr.Name] < 4 then

				-- create the party if the player is not already in a party
				if not plr.IsInParty.Value then
					plr.IsInParty.Value = true

					-- create the party
					table.insert(parties, {plr.Name})
				end

				-- uncomment this on suscribe async
				-- if the player is not in a party yet, invite him to the party
				--player.PartyHost.Value = plr.Name
				--InviteFromServerRemoteEvent:FireClient(player)

				MessagingService:PublishAsync("InviteFriend", {GetPartyWithPlayer(plr.Name), playerName})

				for _,v : string in pairs(GetPartyWithPlayer(plr.Name)) do
					local playerInParty : Player? = Players:FindFirstChild(v)

					-- if the player is in the same server, tell him
					if playerInParty then
						PlayerAddedToPartyRemoteEvent:FireClient(playerInParty, playerName)
					else
						--MessagingService:PublishAsync("PlayerAddedToParty", {1, playerInParty.Name, playerName})
						MessagingService:PublishAsync("Other", {1, playerInParty.Name, playerName})
					end
				end
			end
		end
	end
end)


-- event fired from the host to create the game gui for the player that joined the party
-- party table is a table containing the user ids of all the players in the party and a number indicating their status
ReplicateTeamGameGuiRemoteEvent.OnServerEvent:Connect(function(plr : Player, player : Player, partyTable : {[number | string] : number})
	
	-- if the player is not in a party and the host is plr
	if plr and player and typeof(player) == "Instance" and player:FindFirstChild("PartyHost") and player.PartyHost.Value == plr.Name then
		
		numberOfPlayersInParty[plr.Name] -= 1

		if numberOfPlayersInParty[plr.Name] >= 0 then
			player.IsInParty.Value = true

			-- remove the player from the party if they are already in one
			RemovePlayerFromParty(player.Name)

			-- add player to the party
			AddPlayerToParty(player)

			-- create the game gui for the player based on the party table fired by plr
			CreateTeamGameGuiRemoteEvent:FireClient(player, partyTable)

			-- change the status of the player that joined for all the players in the party
			for _,v : string in pairs(GetPartyWithPlayer(player.Name)) do

				-- if the player is in the server
				if Players:FindFirstChild(v) then
					PlayerJoinedPartyRemoteEvent:FireClient(Players:FindFirstChild(v), player.Name)
				else
					--MessagingService:PublishAsync("PlayerJoinedParty", {2, v, player.Name})
					MessagingService:PublishAsync("Other", {2, v, player.Name})
				end
			end
		end
	end
end)


-- replicate the host's team game gui for a friend on another server
ReplicateTeamGameGuiHostOnAnotherServerRemoteEvent.OnServerEvent:Connect(function(plr : Player, playerName : string, partyTable : {[number | string] : number})

	-- if the player is not in a party and the host is plr
	if hostParty[plr.Name] and hostParty[plr.Name] == playerName and numberOfPlayersInParty[plr.Name] then

		numberOfPlayersInParty[plr.Name] -= 1

		if numberOfPlayersInParty[plr.Name] >= 0 then

			-- remove the player from the party if they are already in one
			RemovePlayerFromParty(playerName)

			-- add player to the party
			for i,v in pairs(parties) do
				if table.find(v, plr.Name) then
					table.insert(v, playerName)
				end
			end

			--MessagingService:PublishAsync("CreateTeamGameGui", {3, playerName, partyTable})
			MessagingService:PublishAsync("Other", {3, playerName, partyTable})

			-- change the status of the player that joined for all the players in the party
			for _,v : string in pairs(GetPartyWithPlayer(playerName)) do

				-- if the player is in the server
				if Players:FindFirstChild(v) then
					PlayerJoinedPartyRemoteEvent:FireClient(Players:FindFirstChild(v), playerName)
				else
					--MessagingService:PublishAsync("PlayerJoinedParty", {2, v, playerName})
					MessagingService:PublishAsync("Other", {2, v, playerName})
				end
			end
		end
	end
end)



-- player responded to the invitation to a party
InvitationResponseRemoteEvent.OnServerEvent:Connect(function(plr : Player, response : string)
	if response and typeof(response) == "string" then

		-- if the player joins the party
		if response == "Join" then
			
			-- check if the player is not already in a party or not in a party with the host (to avoid remote event spamming and messaging service hitting the limit)
			local partyWithPlayer = GetPartyWithPlayer(plr.Name)
			if not partyWithPlayer or not table.find(partyWithPlayer, plr.PartyHost.Value) then

				-- if the host is in the server, fire the event to get the status of all the players inside the party
				if Players:FindFirstChild(plr.PartyHost.Value) then
					ReplicateTeamGameGuiRemoteEvent:FireClient(Players[plr.PartyHost.Value], plr)
				else
					AddPlayerToParty(plr)

					MessagingService:PublishAsync("ReplicateTeamGameGui", {plr.PartyHost.Value, plr.Name})
				end
			end
			
		-- if the player declined the invitation
		elseif response == "Decline" then
			
			-- if the player has been invited to a party (to avoid remote event spamming and messaging service hitting the limit)
			if plr.PartyHost.Value ~= "" then
				
				-- fire the event for all the players in the party to remove the player that declined the invitation from the gui
				for _,v : string in pairs(GetPartyWithPlayer(plr.PartyHost.Value)) do

					if Players:FindFirstChild(v) then
						PlayerDeclinedPartyRemoteEvent:FireClient(Players:FindFirstChild(v), plr.Name)
					else

						-- remove the party with the host
						for i,v in pairs(parties) do
							if table.find(v, plr.PartyHost.Value) then
								table.remove(parties, i)
							end
						end

						--MessagingService:PublishAsync("DeclineInvitation", {4, v, plr.Name})
						MessagingService:PublishAsync("Other", {4, v, plr.Name})
					end
				end

				plr.PartyHost.Value = ""
			end
		end
	end
end)


SelectModeRemoteEvent.OnServerEvent:Connect(function(plr : Player, layoutOrder : number)
	
	-- cooldown of 1 seconds for all players when someone selects a mode
	if tick() > selectModeCooldown.Value + 1 then
		
		selectModeCooldown.Value = tick()
		
		for _,v : string in pairs(GetPartyWithPlayer(plr.Name)) do

			if Players:FindFirstChild(v) then
				SelectModeRemoteEvent:FireClient(Players:FindFirstChild(v), layoutOrder)
			else
				MessagingService:PublishAsync("SelectMode", {v, layoutOrder})
			end
		end
	end
end)


-- remove the player from the party when he quits the party
RemovePlayerFromPartyRemoteEvent.OnServerEvent:Connect(function(plr : Player)
	plr.IsInParty.Value = false
	plr.PartyHost.Value = ""
	
	for _,v : {string} in pairs(parties) do
		
		-- if the player leaving the party is the host, delete the party and delete the team game gui for all other players in the party
		if v[1] == plr.Name then
			
			for _,b : string in pairs(v) do
				
				if Players:FindFirstChild(b) then
					DeletepartyRemoteEvent:FireClient(Players:FindFirstChild(b))
				else
					MessagingService:PublishAsync("DeleteParty", b)
				end
			end
			
			local position : number? = table.find(parties, v)
			
			if position then
				table.remove(parties, position)
			end
		end
	end
	
	RemovePlayerFromParty(plr.Name)
end)


-- remove the player from the party when he leaves
Players.PlayerRemoving:Connect(function(plr : Player)
	plr.IsInParty.Value = false
	plr.PartyHost.Value = ""
	
	RemovePlayerFromParty(plr.Name)
end)


-- add a player to the party
MessagingService:SubscribeAsync("InviteFriend", function(data)
	if typeof(data.Data) == "table" and #data.Data == 2 then
		
		local player : Player? = Players:FindFirstChild(data.Data[2])
		
		if player then
			if player:FindFirstChild("PartyHost") then

				if typeof(data.Data[1]) == "table" then
					player.PartyHost.Value = data.Data[1][1]
					
					
					-- create the party
					local addParty : {string} = {}
					
					for _,v in pairs(data.Data[1]) do
						table.insert(addParty, v)
					end
					
					table.insert(parties, addParty)
				end

				InviteFromServerRemoteEvent:FireClient(player)
			end
		end
	end

	--Players:FindFirstChildOfClass("Player").PlayerGui.Play.Start.TextLabel.Text = data[1]..data[2]
end)


-- player declined the invitation to a party
--MessagingService:SubscribeAsync("DeclineInvitation", function(data)
	
--	if typeof(data.Data) == "table" and #data.Data == 2 then
--		if Players:FindFirstChild(data.Data[1]) then
--			PlayerDeclinedPartyRemoteEvent:FireClient(Players:FindFirstChild(data.Data[1]), data.Data[2])
--		end
--	end
--end)


-- replicate the team game gui from the host
MessagingService:SubscribeAsync("ReplicateTeamGameGui", function(data)
	
	if typeof(data.Data) == "table" and #data.Data == 2 then
		local host : string = data.Data[1]
		
		if Players:FindFirstChild(host) then
			
			-- store the host of the player
			hostParty[host] = data.Data[2]
			
			ReplicateTeamGameGuiHostOnAnotherServerRemoteEvent:FireClient(Players:FindFirstChild(host), data.Data[2])
		end
	end
end)


--MessagingService:SubscribeAsync("CreateTeamGameGui", function(data)
	
--	if typeof(data.Data) == "table" and #data.Data == 2 then

--		if Players:FindFirstChild(data.Data[1]) then
--			CreateTeamGameGuiRemoteEvent:FireClient(Players:FindFirstChild(data.Data[1]), data.Data[2])
--		end
--	end
--end)


--MessagingService:SubscribeAsync("PlayerJoinedParty", function(data)
	
--	if typeof(data.Data) == "table" and #data.Data == 2 then

--		if Players:FindFirstChild(data.Data[1]) then
--			PlayerJoinedPartyRemoteEvent:FireClient(Players:FindFirstChild(data.Data[1]), data.Data[2])
--		end
--	end
--end)


MessagingService:SubscribeAsync("SelectMode", function(data)
	
	if typeof(data.Data) == "table" and #data.Data == 2 then

		if Players:FindFirstChild(data.Data[1]) then
			SelectModeRemoteEvent:FireClient(Players:FindFirstChild(data.Data[1]), data.Data[2])
		end
	end
end)


--MessagingService:SubscribeAsync("RemovePlayerFromParty", function(data)
	
--	if typeof(data.Data) == "table" and #data.Data == 2 then

--		if Players:FindFirstChild(data.Data[1]) then
--			RemovePlayerFromPartyRemoteEvent:FireClient(Players:FindFirstChild(data.Data[1]), data.Data[2])
--		end
--	end
--end)


MessagingService:SubscribeAsync("DeleteParty", function(data)
	
	if typeof(data.Data) == "string" then

		if Players:FindFirstChild(data.Data) then
			DeletepartyRemoteEvent:FireClient(Players:FindFirstChild(data.Data))
		end
	end
end)


MessagingService:SubscribeAsync("Other", function(data)
	
	if typeof(data.Data) == "table" and #data.Data == 3 then
		
		if Players:FindFirstChild(data.Data[2]) then
			
			local topic : number = data.Data[1]
			
			-- game hits the limit of active subscriptions (that's why I add to group them in an "Other" topic and differentiate them using the first data)
			if topic == 1 then -- player added to party
				PlayerAddedToPartyRemoteEvent:FireClient(Players:FindFirstChild(data.Data[2]), data.Data[3])
				
			elseif topic == 2 then -- player joined party
				PlayerJoinedPartyRemoteEvent:FireClient(Players:FindFirstChild(data.Data[2]), data.Data[3])
				
			elseif topic == 3 then -- create team game gui
				CreateTeamGameGuiRemoteEvent:FireClient(Players:FindFirstChild(data.Data[2]), data.Data[3])
				
			elseif topic == 4 then -- decline invitation
				PlayerDeclinedPartyRemoteEvent:FireClient(Players:FindFirstChild(data.Data[2]), data.Data[3])
				
			elseif topic == 5 then -- remove player from party
				RemovePlayerFromPartyRemoteEvent:FireClient(Players:FindFirstChild(data.Data[2]), data.Data[3])
			end 
		end
	end
end)

-- other uis on start click
-- momery store queue (matchmaking)