local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StartRemoteFunction = ReplicatedStorage:WaitForChild("Start")
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
local DeletePartyRemoteEvent = ReplicatedStorage:WaitForChild("DeleteParty")
local SelectModeRemoteEvent = ReplicatedStorage:WaitForChild("SelectMode")
local StartGameRemoteEvent = ReplicatedStorage:WaitForChild("StartGame")
local PlayGuiTemplates : Folder = ReplicatedStorage:WaitForChild("PlayGuiTemplates")

local selectModeCooldown : NumberValue = ReplicatedStorage:WaitForChild("SelectModeCooldown")

local playGui : ScreenGui = script.Parent
local startButton : TextButton = playGui:WaitForChild("Start")
local playerOnServer : ImageButton = PlayGuiTemplates:WaitForChild("PlayerOnServer")
local friends : ImageButton = PlayGuiTemplates:WaitForChild("Friend")

local lplr : Player = Players.LocalPlayer
local playerThumbnail, isReady = Players:GetUserThumbnailAsync(lplr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

local waitingForConfirmation : {string} = {}
local party : {string} = {}

local Utilities : ModuleScript = require(ReplicatedStorage:WaitForChild("Utilities"))

local debounce : boolean = false


-- move the play button to the middle of the screen if the player has a touch screen (because of the jump button in the bottom right)
if UserInputService.TouchEnabled then
	startButton.AnchorPoint = Vector2.new(1,0.5)
	startButton.Position = UDim2.new(1,-10,0.5,0)
end

local teamSize : number = 1 -- default : solo
local chosenMap : number = 2 -- default : city
local chosenMode : number = 1 -- default : normal mode

local soloClicked, teamClicked


local function TweenGuiUp(gui : Frame)
	gui.Visible = true
	gui:TweenPosition(UDim2.new(0.5,0,0.55,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)
end


local function TweenGuiDown(gui : Frame)
	gui:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)
	task.wait(0.5)
	gui.Visible = false
	debounce = false
end


local function CloneGui(gui : Frame)
	if gui and not playGui:FindFirstChild(gui.Name) then
		local Clone = gui:Clone()
		Clone.Parent = playGui
	end
end


-- add the player to the team game party gui (invited but didn't join or deny yet)
local function AddPlayerToParty(playerName : string)
	
	local playerInParty : ImageButton?

	for i=2,4 do
		playerInParty = playGui.TeamGame.Players:FindFirstChild("Player"..tostring(i))

		if playerInParty and playerInParty.Status.Text == "" then
			-- add the player to the table waiting for them to accept or decline the invite
			table.insert(waitingForConfirmation, playerName)
			
			playerInParty.PlayerName.Text = playerName
			playerInParty.PlayerThumbnail.Image = Utilities:GetThumbnailForPlayer(playerName)

			-- change status text and color
			playerInParty.Status.Text = "Waiting for confirmation..."
			playerInParty.Status.TextColor3 = Color3.fromRGB(255, 187, 49)
			
			-- break to only get the first free spot
			break
		end
	end
end


local function GetPlayerFrameInTeamGame(playerName : string) : ImageButton?
	local teamGame : Frame = playGui:FindFirstChild("TeamGame") 

	if teamGame then

		-- find the frame that corresponds to the player
		for _,v : ImageButton | UIListLayout in ipairs(teamGame.Players:GetChildren()) do
			if v:FindFirstChild("PlayerName") and string.lower(v.PlayerName.Text) == string.lower(playerName) then
				return v
			end
		end
	end
	
	return nil
end


local function UnselectAllModes(gameGui : Frame)
	for _,b : TextButton | UIListLayout in ipairs(gameGui.Modes:GetChildren()) do
		if b:IsA("TextButton") then
			b.Size = UDim2.new(0.17,0,1,0)
			b.UIGradient.Color = ColorSequence.new(Color3.fromRGB(162,162,162), Color3.fromRGB(190,190,190))
		end
	end
end


local function SelectMode(gameGui : Frame, button : TextButton?)
	if button then

		-- show the mode explanation text based on the mode the player selected
		if button.LayoutOrder == 1 then
			gameGui.ModeExplanation.Text = ""
		elseif button.LayoutOrder == 2 then
			gameGui.ModeExplanation.Text = "In this mode, some gamepasses are disabled (coins multiplier and starter packs)."
		elseif button.LayoutOrder == 3 then
			gameGui.ModeExplanation.Text = "In this mode, you can't revive other players, which means that once you are down, the game is over."
		elseif button.LayoutOrder == 4 then
			gameGui.ModeExplanation.Text = "In this mode, you can't revive other players, which means that once you are down, the game is over and some gamepasses are disabled (coins multiplier and starter packs)."
		elseif button.LayoutOrder == 5 then
			gameGui.ModeExplanation.Text = workspace.Event.CurrentEvent.BillboardGui.Event.Text
		end

		-- store the chosen mode
		chosenMode = button.LayoutOrder

		-- change the size and the gradient color used
		button.Size = UDim2.new(0.19,0,1.2,0)
		button.UIGradient.Color = ColorSequence.new(Color3.fromRGB(244,183,0), Color3.fromRGB(246,187,0))
	end
end


local function GetModeButtonWithLayoutOrder(layoutOrder : number) : TextButton?
	if playGui:FindFirstChild("TeamGame") then
		
		for _,v : TextButton | UIListLayout in ipairs(playGui.TeamGame.Modes:GetChildren()) do
			if v:IsA("TextButton") then
				if v.LayoutOrder == layoutOrder then
					return v
				end
			end
		end
	end
	
	return nil
end


local function RemovePlayerFrame(playerFrame : ImageButton)
	playerFrame.Status.Text = ""
	playerFrame.Status.TextColor3 = Color3.fromRGB(255, 187, 49)
	playerFrame.PlayerThumbnail.Image = ""
	playerFrame.PlayerName.Text = "Random"

	local teamGame : Frame = playGui:FindFirstChild("TeamGame")

	if teamGame then

		-- switch the player3 and player2 frames to bring the next players to the left
		if teamGame.Players.Player3.Status.Text ~= "" then
			teamGame.Players.Player2.Name, teamGame.Players.Player3.Name = teamGame.Players.Player3.Name, teamGame.Players.Player2.Name
			teamGame.Players.Player3.LayoutOrder, teamGame.Players.Player2.LayoutOrder = teamGame.Players.Player2.LayoutOrder, teamGame.Players.Player3.LayoutOrder
		end

		-- switch the player3 and player4 frames to bring the next players to the left
		if teamGame.Players.Player4.Status.Text ~= "" then
			teamGame.Players.Player4.Name, teamGame.Players.Player3.Name = teamGame.Players.Player3.Name, teamGame.Players.Player4.Name
			teamGame.Players.Player3.LayoutOrder, teamGame.Players.Player4.LayoutOrder = teamGame.Players.Player4.LayoutOrder, teamGame.Players.Player3.LayoutOrder
		end
	end
end


local function InviteFromServer()
	CloneGui(PlayGuiTemplates.InviteFromServer)
	
	local inviteFromServerGui : Frame = playGui:FindFirstChild("InviteFromServer")
	if inviteFromServerGui then
		
		local playerScrollingFrame : ScrollingFrame = inviteFromServerGui:FindFirstChild("Players")
		
		if playerScrollingFrame then
			for _,player : Player in ipairs(Players:GetPlayers()) do
				local playerClone : ImageButton = playerOnServer:Clone()
				playerClone.Image = Utilities:GetThumbnailForPlayer(player.Name)
				playerClone.TextLabel.Text = player.Name
				playerClone.Parent = playerScrollingFrame

				playerClone.MouseButton1Down:Connect(function()
					
					-- if the player is different from the local player and the player has not already been invited
					if player ~= lplr and not table.find(waitingForConfirmation, player.Name) and not table.find(party, player.Name) then
						inviteFromServerGui:Destroy()

						-- tell the player they were invited to a party and ask them if they want to join
						InviteFromServerRemoteEvent:FireServer(player)
					end
				end)
			end
			
			-- change the UIGridLayout cell padding and the scrolling frame CanvasSize based on the absolute size of the scrolling frame and its children
			local playerOnServerButton : ImageButton = playerScrollingFrame:FindFirstChildOfClass("ImageButton")
			if playerOnServerButton then

				playerScrollingFrame.UIGridLayout.CellPadding = UDim2.new(
					0,
					(playerScrollingFrame.AbsoluteSize.X - (playerOnServerButton.AbsoluteSize.X * 5)) / 6,
					0,
					playerOnServerButton.TextLabel.AbsoluteSize.Y + 40
				)
				
				playerScrollingFrame.CanvasSize = UDim2.new(
					0,
					0,
					0,
					(math.ceil(#Players:GetPlayers() / 5) * playerOnServerButton.AbsoluteSize.X) + (#Players:GetPlayers() * playerScrollingFrame.UIGridLayout.CellPadding.Y.Offset)
				)
			end
		end

		inviteFromServerGui.Close.MouseButton1Down:Connect(function()
			inviteFromServerGui:Destroy()
		end)
	end
end


 --iterate through the player's friends pages
local function iterPageItems(pages)
	return coroutine.wrap(function()
		local pagenum = 1
		while true do
			for _, item in ipairs(pages:GetCurrentPage()) do
				coroutine.yield(item, pagenum)
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
			pagenum = pagenum + 1
		end
	end)
end


local function InviteFriends()
	CloneGui(PlayGuiTemplates.InviteFriends)

	local inviteFriendsGui : Frame = playGui:FindFirstChild("InviteFriends")
	if inviteFriendsGui then

		local playerScrollingFrame : ScrollingFrame = inviteFriendsGui:FindFirstChild("Players")

		if playerScrollingFrame then
			
			local friendsList = {}
			for item, pageNo in iterPageItems(Players:GetFriendsAsync(lplr.UserId)) do
				table.insert(friendsList, item)
			end
			
			local friendsGame = lplr:GetFriendsOnline()

			for _,friend in pairs(friendsList) do
				local playerClone : ImageButton = friends:Clone()

				-- set the player's thumbnail
				local playerThumbnail, isReady = Players:GetUserThumbnailAsync(friend.Id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
				if playerThumbnail then
					playerClone.Image = playerThumbnail
				end

				playerClone.TextLabel.Text = friend.DisplayName
				
				-- if the friend is online, set their status to "online" if he is in the game and "not in game" if their are not
				if friend.IsOnline then
					-- iterate through all the online friends to check if the player is playing this game or another one
					for _,v in pairs(friendsGame) do
						if friend.Id == v.VisitorId then
							
							if v.PlaceId == game.PlaceId then
								playerClone.Status.Text = "Online"
								playerClone.Status.TextColor3 = Color3.new(0,1,0)
								
								playerClone.MouseButton1Down:Connect(function()

									-- if the player is different from the local player and the player has not already been invited-
									if friend.Username ~= lplr.Name and not table.find(waitingForConfirmation, friend.Username) and not table.find(party, friend.Username) then
										inviteFriendsGui:Destroy()

										-- tell the player they were invited to a party and ask them if they want to join
										InviteFriendsRemoteEvent:FireServer(friend.Username)
										-- messaging service tell player he has been invited
									end
								end)
							else
								playerClone.Status.Text = "Not in game"
							end
						end
					end
				end
				
				playerClone.Parent = playerScrollingFrame
				
				-- move the status position under the player's name (do it after parenting, otherwise the size is 0)
				playerClone.Status.Position = UDim2.new(0,0,1, playerClone.TextLabel.AbsoluteSize.Y + 5)
			end

			 --change the UIGridLayout cell padding and the scrolling frame CanvasSize based on the absolute size of the scrolling frame and its children
			local friendButton : ImageButton = playerScrollingFrame:FindFirstChildOfClass("ImageButton")
			if friendButton then

				playerScrollingFrame.UIGridLayout.CellPadding = UDim2.new(
					0,
					(playerScrollingFrame.AbsoluteSize.X - (friendButton.AbsoluteSize.X * 5)) / 6,
					0,
					friendButton.TextLabel.AbsoluteSize.Y + friendButton.Status.AbsoluteSize.Y + 40
				)

				playerScrollingFrame.CanvasSize = UDim2.new(
					0,
					0,
					0,
					(math.ceil(#Players:GetPlayers() / 5) * friendButton.AbsoluteSize.X) + (#Players:GetPlayers() * playerScrollingFrame.UIGridLayout.CellPadding.Y.Offset)
				)
			end
		end

		inviteFriendsGui.Close.MouseButton1Down:Connect(function()
			inviteFriendsGui:Destroy()
		end)
	end
end


local function ChooseMode()
	-- clone the gui from the templates
	
	-- clone the solo game gui
	if teamSize == 1 then
		CloneGui(PlayGuiTemplates.SoloGame)
		local soloGame : Frame = playGui:FindFirstChild("SoloGame") 
		
		if soloGame then
			TweenGuiUp(soloGame)
			
			-- mode selection
			for _,v : TextButton | UIListLayout in ipairs(soloGame.Modes:GetChildren()) do
				if v:IsA("TextButton") then

					-- zoom on hover
					v.MouseEnter:Connect(function()
						v:TweenSize(UDim2.new(0.19,0,1.2,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.1)
					end)

					-- unzoom on unhover
					v.MouseLeave:Connect(function()
						-- only unzoom if it's not selected hence doesn't have the gold gradient
						if v.UIGradient.Color ~= ColorSequence.new(Color3.fromRGB(244,183,0), Color3.fromRGB(246,187,0)) then
							v:TweenSize(UDim2.new(0.17,0,1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.1)
						end
					end)

					v.MouseButton1Down:Connect(function()
						
						-- 1 second cooldown when selecting a new mode
						if tick() > selectModeCooldown.Value + 1 then

							-- unselect the other modes
							UnselectAllModes(soloGame)

							SelectMode(soloGame, v)

							SelectModeRemoteEvent:FireServer(v.LayoutOrder)
						end
					end)
				end
			end

			soloGame.Solo.PlayerThumbnail.Image = playerThumbnail
			soloGame.Solo.PlayerThumbnail.TextLabel.Text = lplr.Name

			soloGame.Play.MouseButton1Down:Connect(function()
				soloGame.Play.Visible = false
				soloGame.StartingGame.Visible = true
				
				--soloGame.Server.Visible = true
				local success, result = StartRemoteFunction:InvokeServer(teamSize, chosenMap, chosenMode)

				-- if the player can succesfully be teleported, delete the gui, otherwise, tell the player there was an error
				if success then
					soloGame.StartingGame.TextLabel.Text = "Teleporting you to the server..."
				else
					soloGame.Play.Visible = false
					soloGame.Server.Visible = false
					soloGame.Error.Visible = true
				end
			end)
		end
		
	-- clone the team game gui
	else
		CloneGui(PlayGuiTemplates.TeamGame)
		local teamGame : Frame = playGui:FindFirstChild("TeamGame") 
		
		if teamGame then
			TweenGuiUp(teamGame)
			
			-- mode selection
			for _,v : TextButton | UIListLayout in ipairs(teamGame.Modes:GetChildren()) do
				if v:IsA("TextButton") then

					-- zoom on hover
					v.MouseEnter:Connect(function()
						v:TweenSize(UDim2.new(0.19,0,1.2,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.1)
					end)

					-- unzoom on unhover
					v.MouseLeave:Connect(function()
						-- only unzoom if it's not selected hence doesn't have the gold gradient
						if v.UIGradient.Color ~= ColorSequence.new(Color3.fromRGB(244,183,0), Color3.fromRGB(246,187,0)) then
							v:TweenSize(UDim2.new(0.17,0,1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.1)
						end
					end)

					v.MouseButton1Down:Connect(function()
						
						-- 1 second cooldown when selecting a new mode
						if tick() > selectModeCooldown.Value + 1 then

							-- unselect the other modes
							UnselectAllModes(teamGame)

							SelectMode(teamGame, v)

							SelectModeRemoteEvent:FireServer(v.LayoutOrder)
						end
					end)
				end
			end
			
			-- player wants to invite a friend
			teamGame.InviteFriends.MouseButton1Down:Connect(function()
				InviteFriends()
			end)			
			
			-- player wants to invite someone from the server
			teamGame.InviteFromServer.MouseButton1Down:Connect(function()
				InviteFromServer()
			end)			
			
			teamGame.Players.Host.PlayerThumbnail.Image = playerThumbnail
			teamGame.Players.Host.PlayerThumbnail.TextLabel.Text = lplr.Name
			
			-- change the UIListLayout padding based on the absolute size of its children
			teamGame.Players.UIListLayout.Padding = UDim.new(0, (teamGame.Players.AbsoluteSize.X - (teamGame.Players.Host.AbsoluteSize.X * 4)) / 5)

			teamGame.Play.MouseButton1Down:Connect(function()
				teamGame.Play.Visible = false
				teamGame.StartingGame.Visible = true
				--teamGame.Server.Visible = true
				
				local success, result = StartRemoteFunction:InvokeServer(teamSize, chosenMap, chosenMode)

				-- if the player can succesfully be teleported, delete the gui, otherwise, tell the player there was an error
				if success then
					if #party == teamSize then
						teamGame.StartingGame.TextLabel.Text = "Teleporting you to the server..."
					else
						teamGame.StartingGame.TextLabel.Text = "Waiting for other players..."
					end
				else
					teamGame.Play.Visible = false
					teamGame.InviteFriends.Visible = false
					teamGame.InviteFromServer.Visible = false
					teamGame.Server.Visible = false
					teamGame.Error.Visible = true
				end
			end)
		end
	end
end


-- map selection gui
local function ChooseMap()
	-- clone the gui from the templates
	CloneGui(PlayGuiTemplates.Map)
	local mapSelection : Frame = playGui:FindFirstChild("Map")
	
	if mapSelection then
		TweenGuiUp(mapSelection)
		
		for _,v in ipairs(mapSelection.Frame:GetChildren()) do
			if v:IsA("ImageButton") and v.Name ~= "Locked" then

				-- zoom on hover
				v.MouseEnter:Connect(function()
					v:TweenSize(UDim2.new(0.45,0,1.05,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.1)
				end)

				-- unzoom on unhover
				v.MouseLeave:Connect(function()
					v:TweenSize(UDim2.new(0.4,0,1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.1)
				end)

				v.MouseButton1Down:Connect(function()
					if not debounce then
						debounce = true
						
						-- store the chosen map
						chosenMap = v.LayoutOrder

						TweenGuiDown(mapSelection)
						mapSelection:Destroy()

						ChooseMode()
					end
				end)
			end
		end
	end
end

-- team size selection gui
local function ChooseTeamSize()
	-- clone the gui from the templates
	CloneGui(PlayGuiTemplates.Team)
	local teamSizeSelection : Frame = playGui:FindFirstChild("Team")
	
	if teamSizeSelection then
		
		for _,v in ipairs(teamSizeSelection:GetChildren()) do
			if v:IsA("ImageButton") then
				
				-- change the player thumbnail
				v.PlayerThumbnail.Image = playerThumbnail
				
				-- zoom on hover
				v.MouseEnter:Connect(function()
					v:TweenSize(UDim2.new(0.55,0,0.55,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.1)
				end)
				
				-- unzoom on unhover
				v.MouseLeave:Connect(function()
					v:TweenSize(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.1)
				end)
				
				-- on team selected
				v.MouseButton1Down:Connect(function()
					if not debounce then
						debounce = true
						
						-- the team size of the button is stored in the layout order
						teamSize = v.LayoutOrder

						TweenGuiDown(teamSizeSelection)
						teamSizeSelection:Destroy()

						ChooseMap()
					end
				end)
			end
		end
	end
end


-- player clicks the start button to create a party
startButton.MouseButton1Down:Connect(function()
	startButton.Visible = false
	
	-- team size selection
	ChooseTeamSize()
	TweenGuiUp(playGui.Team)
end)


-- player clicks the close button to leave the party
playGui.Close.MouseButton1Down:Connect(function()

	startButton.Visible = true
	
	waitingForConfirmation = {}
	party = {}

	for i,v in ipairs(playGui:GetChildren()) do
		if v:IsA("Frame") and v.Name ~= "Invitation" then
			RemovePlayerFromPartyRemoteEvent:FireServer()

			v:Destroy()
		end
	end
end)


-- a player has been added to the party (but has not joined or denied yet)
PlayerAddedToPartyRemoteEvent.OnClientEvent:Connect(function(playerName : string)
	AddPlayerToParty(playerName)
end)


-- player is invited to a party or a player joined their party
InviteFromServerRemoteEvent.OnClientEvent:Connect(function()
		
	-- the player is invited to a party
	CloneGui(PlayGuiTemplates.Invitation)

	local invitationGui : Frame = playGui:FindFirstChild("Invitation")
	if invitationGui then
		invitationGui.Title.Text = lplr.PartyHost.Value.." is inviting you to join their party"

		-- tween the gui down
		invitationGui:TweenPosition(UDim2.new(0.5,0,0,10), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 1.2)
		
		for _,v in ipairs(invitationGui:GetChildren()) do
			if v:IsA("TextButton") then
				
				-- player clicks one of the buttons to join or deny the party
				v.MouseButton1Down:Connect(function()
					InvitationResponseRemoteEvent:FireServer(v.Name)
					
					-- if the player joins the party, delete the team game gui (in case they would already be in a party, we don't want 2 guis)
					if v.Name == "Join" and playGui:FindFirstChild("TeamGame") then
						playGui.TeamGame:Destroy()
					end
					
					startButton.Visible = false

					invitationGui:TweenPosition(UDim2.new(0.5,0,-0.2,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 1.2)
					task.wait(1.2)
					invitationGui:Destroy()
				end)
			end
		end
	end
end)


CreateTeamGameGuiRemoteEvent.OnClientEvent:Connect(function(partyTable : {[number | string] : number})
	
	CloneGui(PlayGuiTemplates.TeamGame)

	local teamGame : Frame = playGui:FindFirstChild("TeamGame")
	
	if teamGame then
		TweenGuiUp(teamGame)

		-- change the UIListLayout padding based on the absolute size of its children
		teamGame.Players.UIListLayout.Padding = UDim.new(0, (teamGame.Players.AbsoluteSize.X - (teamGame.Players.Host.AbsoluteSize.X * 4)) / 5)
		
		local counter : number = 2
		
		for i : number,v : number in pairs(partyTable) do
			
			-- select the mode the host selected
			if i == "Mode" then
				local teamGameGui = playGui:FindFirstChild("TeamGame")

				if teamGameGui then
					UnselectAllModes(teamGameGui)

					SelectMode(teamGameGui, GetModeButtonWithLayoutOrder(v))
				end
				
			-- host
			elseif v == 5 then
				local username : string
				
				-- get the player username based on his user id
				pcall(function()
					username = Players:GetNameFromUserIdAsync(i)
				end)
				
				if username then	
					-- change the player thumbnail and username
					teamGame.Players.Host.PlayerThumbnail.Image = Utilities:GetThumbnailForPlayer(username) 
					teamGame.Players.Host.PlayerThumbnail.TextLabel.Text = username
				end
				
			-- players that joined the party
			else
				if teamGame.Players:FindFirstChild("Player"..tostring(counter)) then
					local username : string
					
					-- get the player username based on his user id
					pcall(function()
						username = Players:GetNameFromUserIdAsync(i)
					end)

					if username then
						-- change the player thumbnail and username
						teamGame.Players["Player"..tostring(counter)].PlayerThumbnail.Image = Utilities:GetThumbnailForPlayer(username)
						teamGame.Players["Player"..tostring(counter)].PlayerName.Text = username
						
						-- change the status for the player
						if v == 0 then
							teamGame.Players["Player"..tostring(counter)].Status.Text = "Ready"
							teamGame.Players["Player"..tostring(counter)].Status.TextColor3 = Color3.new(0,1,0)
						else
							teamGame.Players["Player"..tostring(counter)].Status.Text = "Waiting for confirmation..."
						end
					end

					counter += 1
				end
			end
		end
	end
end)


-- give the user ids and status to the player who joined the party to create the team game gui
ReplicateTeamGameGuiRemoteEvent.OnClientEvent:Connect(function(player : Player)
	
	local position : number = table.find(waitingForConfirmation, player.Name)
	
	if position then
		table.remove(waitingForConfirmation, position)
		table.insert(party, player.Name)

		-- create the table that will be used to create the team game gui for the player that joined
		local partyTable : {[number] : number} = {}

		for _,playerName in pairs(party) do
			local userId : number
			
			pcall(function()
				userId = Players:GetUserIdFromNameAsync(playerName)
			end)
				
			if userId then
				partyTable[userId] = 0
			end
		end

		for _,playerName in pairs(waitingForConfirmation) do
			local userId : number

			pcall(function()
				userId = Players:GetUserIdFromNameAsync(playerName)
			end)
			
			if userId then
				partyTable[userId] = 1
			end
		end
		
		-- add the host to the table
		partyTable[lplr.UserId] = 5 -- 5 is the number used to say that the player is the host
		partyTable["Mode"] = chosenMode
		
		ReplicateTeamGameGuiRemoteEvent:FireServer(player, partyTable)
	end
end)


ReplicateTeamGameGuiHostOnAnotherServerRemoteEvent.OnClientEvent:Connect(function(playerName : string)
	local position : number = table.find(waitingForConfirmation, playerName)

	if position then
		table.remove(waitingForConfirmation, position)
		table.insert(party, playerName)

		-- create the table that will be used to create the team game gui for the player that joined
		local partyTable : {[number] : number} = {}

		for _,playerName in pairs(party) do
			local userId : number

			pcall(function()
				userId = Players:GetUserIdFromNameAsync(playerName)
			end)

			if userId then
				partyTable[userId] = 0
			end
		end

		for _,playerName in pairs(waitingForConfirmation) do
			local userId : number

			pcall(function()
				userId = Players:GetUserIdFromNameAsync(playerName)
			end)

			if userId then
				partyTable[userId] = 1
			end
		end

		-- add the host to the table
		partyTable[lplr.UserId] = 5 -- 5 is the number used to say that the player is the host
		partyTable["Mode"] = chosenMode

		ReplicateTeamGameGuiHostOnAnotherServerRemoteEvent:FireServer(playerName, partyTable)
	end
end)


-- fired when a player clicked joined the party to change the status
PlayerJoinedPartyRemoteEvent.OnClientEvent:Connect(function(playerName : string)
	local playerFrame : ImageButton? = GetPlayerFrameInTeamGame(playerName)

	if playerFrame then
		playerFrame.Status.Text = "Ready"
		playerFrame.Status.TextColor3 = Color3.new(0,1,0)
	end
end)


-- remove the player that declined the invitation from the party
PlayerDeclinedPartyRemoteEvent.OnClientEvent:Connect(function(playerName : string)
	local position : number = table.find(waitingForConfirmation, playerName)
	
	if position then
		table.remove(waitingForConfirmation, position)
	end
	
	local playerFrame : ImageButton? = GetPlayerFrameInTeamGame(playerName)
	
	if playerFrame then
		
		-- show the player as declined
		playerFrame.Status.Text = "Declined"
		playerFrame.Status.TextColor3 = Color3.new(1,0,0)
		
		-- wait 3 seconds before removing the player from the party gui
		coroutine.wrap(function()
			task.wait(3)

			RemovePlayerFrame(playerFrame)
		end)()
	end
end)


-- select a mode when the host selects another mode
SelectModeRemoteEvent.OnClientEvent:Connect(function(layoutOrder : number)
	local teamGameGui = playGui:FindFirstChild("TeamGame")

	if teamGameGui then
		UnselectAllModes(teamGameGui)

		SelectMode(teamGameGui, GetModeButtonWithLayoutOrder(layoutOrder))
	end
end)


-- remove a player from the party
RemovePlayerFromPartyRemoteEvent.OnClientEvent:Connect(function(playerName : string)
	
	-- remove the player from the waiting for confirmation table
	local position : number? = table.find(waitingForConfirmation, playerName)
	if position then
		table.remove(waitingForConfirmation, position)
	end
	
	-- remove the player from the party table
	position = table.find(party, playerName)
	if position then
		table.remove(party, position)
	end
	
	local playerFrame : ImageButton? = GetPlayerFrameInTeamGame(playerName)

	if playerFrame then
		RemovePlayerFrame(playerFrame)
	end
end)


-- if the host leaves the party, delete the gui
DeletePartyRemoteEvent.OnClientEvent:Connect(function()
	waitingForConfirmation = {}
	party = {}
	
	if playGui:FindFirstChild("TeamGame") then
		playGui.TeamGame:Destroy()
	end
	
	startButton.Visible = true
end)


-- fires when the host start the game to show the start the game gui
StartGameRemoteEvent.OnClientEvent:Connect(function()
	local gameGui : Frame? = playGui:FindFirstChild("SoloGame") or playGui:FindFirstChild("TeamGame")

	if gameGui then
		gameGui.StartingGame.Visible = true
	end
end)