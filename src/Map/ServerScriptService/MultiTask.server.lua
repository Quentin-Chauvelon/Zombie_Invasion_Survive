local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateHealth = ReplicatedStorage:WaitForChild("UpdateHealth")
local EnableCameraRemoteEvent = ReplicatedStorage:WaitForChild("EnableCamera")
local EnableMouseRemoteEvent = ReplicatedStorage:WaitForChild("EnableMouse")
local PlayAgainRemoteEvent = ReplicatedStorage:WaitForChild("PlayAgain")
local BackToLobbyRemoteEvent = ReplicatedStorage:WaitForChild("BackToLobby")
local PlayAgainStatusRemoteEvent = ReplicatedStorage:WaitForChild("PlayAgainStatus")

local PlayersModuleScript = require(ServerScriptService:WaitForChild("Players"))
local Utilities = require(ServerScriptService:WaitForChild("Utilities"))

local unlockElevator : Part = workspace:WaitForChild("Lift"):WaitForChild("Unlock")
local elevatorTeleport : Part = workspace.Lift:WaitForChild("ElevatorTeleport")

local playersWhoWantToPlayAgain : {string} = {}


-- enable / disable mouse
EnableMouseRemoteEvent.OnServerEvent:Connect(function(plr : Player, state : boolean)
	EnableMouseRemoteEvent:FireClient(plr, state)
end)


-- enable / disable camera
EnableCameraRemoteEvent.OnServerEvent:Connect(function(plr : Player, state : boolean)
	EnableCameraRemoteEvent:FireClient(plr, state)
end)


local SafeTeleport = require(ServerScriptService:WaitForChild("SafeTeleport"))


local function TeleportToServer(playersToTeleport : {Player})

	local teleportData = {
		numberOfPlayers = ReplicatedStorage.NumberOfPlayers.Value or 1,
		mode = ServerStorage.Mode.Value
	}

	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = TeleportService:ReserveServer(game.PlaceId)
	teleportOptions:SetTeleportData(teleportData)

	return SafeTeleport(game.PlaceId, playersToTeleport, teleportOptions)
end


-- play again after death
PlayAgainRemoteEvent.OnServerEvent:Connect(function(plr : Player)
	
	-- if the player was playing solo mode
	if ReplicatedStorage.NumberOfPlayers.Value == 1 and #Players:GetPlayers() == 1 then
		if not plr.IsAlive.Value then
			if not TeleportToServer({plr}) then
				plr.PlayerGui.Death.Error.Visible = true
			end
		end

	else
		-- check if there is enough players to start the game
		if ReplicatedStorage.NumberOfPlayers.Value == #Players:GetPlayers() then
			
			for _,player in ipairs(Players:GetPlayers()) do
				PlayAgainStatusRemoteEvent:FireClient(player, plr.Name, 1)
			end
			
			if not table.find(playersWhoWantToPlayAgain, plr.Name) then
				table.insert(playersWhoWantToPlayAgain, plr.Name)
			end
			
			for _,player in ipairs(Players:GetPlayers()) do
				if player.IsAlive.Value or not table.find(playersWhoWantToPlayAgain, plr.Name) then
					return
				end
			end
			
			if not TeleportToServer(Players:GetPlayers()) then
				plr.PlayerGui.Death.Error.Visible = true
			end
			
		else
			plr.PlayerGui.Death.Error.Text = "Not enough players to start the game"
			plr.PlayerGui.Death.Error.Visible = true
		end
	end
end)


BackToLobbyRemoteEvent.OnServerEvent:Connect(function(plr : Player)
	for _,player in ipairs(Players:GetPlayers()) do
		PlayAgainStatusRemoteEvent:FireClient(player, plr.Name, 2)
	end
	
	SafeTeleport(9574923822, {plr})
end)


-- elevator
unlockElevator.ProximityPrompt.Triggered:Connect(function(plr)
	-- if the player isn't down
	if not PlayersModuleScript:IsDown(plr) then

		-- If the zone has been unlocked
		if Utilities:IsZoneUnlocked("Skyscraper") then

			if plr:DistanceFromCharacter(unlockElevator.Position) < 12 then


				if Utilities:PlayerHasEnoughCoins(plr, unlockElevator.Price.Value) then

					if Utilities:RemoveCoins(plr, unlockElevator.Price.Value) then
						
						workspace.Lift.TakeTheElevator.ProximityPrompt.Enabled = true
						workspace.Lift.TakeTheElevator.ProximityPrompt.Triggered:Connect(function(plr)
							
							if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
								plr.Character.HumanoidRootPart.CFrame = elevatorTeleport.CFrame
							end
						end)
						
						unlockElevator:Destroy()
					end
				end
			end
		end
	end
end)


workspace:WaitForChild("Water"):WaitForChild("Middle"):WaitForChild("Water").Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" then
		hit.Position = workspace.SpawnLocation.Position + Vector3.new(0,5,0)
	end
end)


-- regeneration
Players.PlayerAdded:Connect(function(plr)
	coroutine.wrap(function()
		local health : NumberValue = plr:WaitForChild("Stats"):WaitForChild("Health") 
		local maxHealth : NumberValue = plr.Stats:WaitForChild("MaxHealth")
		local regenerationTime : NumberValue = plr.Stats:WaitForChild("RegenerationTime")
		
		while plr do
			-- increase the player health by one
			if health.Value < maxHealth.Value then
				health.Value += 1
				UpdateHealth:FireAllClients(plr)
			end
			
			wait(regenerationTime.Value)
		end
	end)()
end)