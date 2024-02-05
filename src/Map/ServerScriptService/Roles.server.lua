local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RandomRoleBindableEvent = ServerStorage:WaitForChild("RandomRole")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RolesRemoteEvent = ReplicatedStorage:WaitForChild("Roles")

local roles : Folder = ServerStorage:WaitForChild("Roles")

-- define the type tab as a table of number
type tab = {number}

local thumbnailIds = {}


-- save the player thumbnail image id in the thumbnailIds table
for _,player : Player in ipairs(Players:GetPlayers()) do
	local content, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	thumbnailIds[player.Name] = content

	-- create a string value that will store the player's role when he selects a role
	local playerRole : StringValue = Instance.new("StringValue")
	playerRole.Name = player.Name
	playerRole.Parent = roles
end


local function GetPlayersWithRole(role : string) : tab
	local playersWithRole = {}

	if role ~= "" then
		for _,v : StringValue in ipairs(roles:GetChildren()) do
			if v.Value == role then

				if thumbnailIds[v.Name] then
					table.insert(playersWithRole, thumbnailIds[v.Name])
				end
			end
		end
	end

	return playersWithRole
end

-- player selected a role
RolesRemoteEvent.OnServerEvent:Connect(function(plr : Player, role)

	if role and typeof(role) == "string" and (role == "Healer" or role == "Tank" or role == "Sniper" or role == "Barbarian" or role == "Enchanter") then
		
		-- store the previous role the player had
		local previousRole : string = roles[plr.Name].Value

		if roles:FindFirstChild(plr.Name) then
			roles[plr.Name].Value = ""

			-- get all the players with the role
			local playersWithRole = GetPlayersWithRole(role)

			-- change the player's role to role
			roles[plr.Name].Value = role

			if thumbnailIds[plr.Name] then
				-- if there is at least one player that already has the role, add the player to the table
				if #playersWithRole ~= 0 then
					table.insert(playersWithRole, thumbnailIds[plr.Name])
					RolesRemoteEvent:FireAllClients(playersWithRole, role, previousRole, GetPlayersWithRole(previousRole))

					-- otherwise, return the table with the player only
				else
					RolesRemoteEvent:FireAllClients({thumbnailIds[plr.Name]}, role, previousRole, GetPlayersWithRole(previousRole))
				end
			end
		end
	end
end)


-- event fired at the end of the countdown for the players that have not chosen any role
RandomRoleBindableEvent.Event:Connect(function(playerName : string, playerRandomRole : string)
	RolesRemoteEvent:FireAllClients(GetPlayersWithRole(playerRandomRole), playerRandomRole, "", {})
end)