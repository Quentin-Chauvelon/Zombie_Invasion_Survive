local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Spectate = ReplicatedStorage:WaitForChild("Spectate")
local EnableCameraRemoteEvent = ReplicatedStorage:WaitForChild("EnableCamera")

local lplr : Player = Players.LocalPlayer

local currentCamera : Camera = workspace.CurrentCamera
local index : number = 1

local spectateGui : ScreenGui = lplr.PlayerGui:WaitForChild("Spectate")
local leftArrow : ImageButton = spectateGui:WaitForChild("LeftArrow")
local rightArrow : ImageButton = spectateGui:WaitForChild("RightArrow")

local leftArrowClicked : RBXScriptConnection, rightArrowClicked : RBXScriptConnection


local function SpectatePlayer(players)
	local player : Player? = players[index]

	if player then
		-- if the player is not down and is alive, spectate him, otherwise spectate next player
		if not player.IsDown.Value and player.IsAlive.Value and player.Character and player.Character:FindFirstChild("Humanoid") then

			currentCamera.CameraSubject = player.Character.Humanoid
			return true
		end
	end

	return false
end


local function SpectatePreviousPlayer(players)

	-- if the player can't be spectated, spectate the previous one
	if not SpectatePlayer(players) then

		index -= 1

		if index < 1 then
			index = #players
		end

		SpectatePreviousPlayer(players)
	end
end


local function SpectateNextPlayer(players)

	-- if the player can't be spectated, spectate the next one
	if not SpectatePlayer(players) then
		index += 1

		if index > #players then
			index = 1
		end

		SpectateNextPlayer(players)
	end
end


Spectate.OnClientEvent:Connect(function(enable : boolean)
	if enable then
		lplr.PlayerGui.GameGui.Enabled = false
		lplr.PlayerGui.Backpack.Enabled = false
		lplr.PlayerGui.Spectate.Enabled = true

		EnableCameraRemoteEvent:FireServer(false)

		local players : {Instance} = Players:GetPlayers()

		local position : number? = table.find(players, lplr)
		if position then
			table.remove(players, position)
		end

		local IsThereStillAPlayerAlive : boolean = false

		for _,player : Player in ipairs(Players:GetPlayers()) do
			if player ~= lplr then
				if not player.IsDown.Value then
					IsThereStillAPlayerAlive = true
				end
			end
		end

		if IsThereStillAPlayerAlive then
			-- spectate player
			SpectateNextPlayer(players)

			-- spectate the previous player on left arrow button click
			leftArrowClicked = leftArrow.MouseButton1Down:Connect(function()
				index -= 1
				SpectatePreviousPlayer(players)
			end)

			-- spectate the next player on right arrow button click
			rightArrowClicked = rightArrow.MouseButton1Down:Connect(function()
				index +=1
				SpectateNextPlayer(players)
			end)
		end


	else
		lplr.PlayerGui.Spectate.Enabled = false
		lplr.PlayerGui.GameGui.Enabled = true
		lplr.PlayerGui.Backpack.Enabled = true

		-- set the camera subject back to the local player
		if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
			currentCamera.CameraSubject = lplr.Character.Humanoid
		end

		-- disconnect the arrows click events
		if leftArrowClicked and rightArrowClicked then
			leftArrowClicked:Disconnect()
			rightArrowClicked:Disconnect()
		end
	end
end)