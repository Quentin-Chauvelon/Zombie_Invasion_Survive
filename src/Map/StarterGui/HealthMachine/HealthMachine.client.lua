local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MachineRemoteFunction = ReplicatedStorage:WaitForChild("Machines")
local EnableMouseRemoteEvent = ReplicatedStorage:WaitForChild("EnableMouse")

local healthMachineGui : Frame = script.Parent:WaitForChild("Frame")
local levels : Frame = healthMachineGui:WaitForChild("Levels")

local healthMachineFillBar : Frame = workspace:WaitForChild("Machines"):WaitForChild("HealthMachine"):WaitForChild("HealthMachine"):WaitForChild("FillBar"):WaitForChild("SurfaceGui"):WaitForChild("BarToFill"):WaitForChild("FillingBar")

local lplr : Player = game.Players.LocalPlayer
local healthLevel : IntValue = lplr:WaitForChild("Machines"):WaitForChild("HealthMachine")

local hasMouse : boolean = game:GetService("UserInputService").MouseEnabled
local firstTrigger : boolean = false

local level1, level2, level3, level4, level5, level6, level7, level8, level9, level10, close


-- player clicked a level
local function LevelClicked(level : number)
	
	-- if the player hasn't already bought an higher level of health
	if healthLevel.Value < level then
		--if HealthMachineRemoteFunction:InvokeServer(level) then
		if MachineRemoteFunction:InvokeServer("Health", level) then
			
			for i : number = level,1,-1 do
				local lowerLevel : ImageButton? = levels:FindFirstChild("Level"..tostring(i))
				
				if lowerLevel then
					lowerLevel.AutoButtonColor = false
					lowerLevel.ImageColor3 = Color3.fromRGB(128,128,128)
					lowerLevel.Price.Text = "OWNED"
					lowerLevel.Price.TextColor3 = Color3.fromRGB(71,190,58)
				end
			end
			
			-- disconnect events
			if level10 and level >= 10 then
				level10:Disconnect()
				level10 = nil
			end

			if level9 and level >= 9 then
				level9:Disconnect()
				level9 = nil
			end

			if level8 and level >= 8 then
				level8:Disconnect()
				level8 = nil
			end

			if level7 and level >= 7 then
				level7:Disconnect()
				level7 = nil
			end

			if level6 and level >= 6 then
				level6:Disconnect()
				level6 = nil
			end

			if level5 and level >= 5 then
				level5:Disconnect()
				level5 = nil
			end

			if level4 and level >= 4 then
				level4:Disconnect()
				level4 = nil
			end

			if level3 and level >= 3 then
				level3:Disconnect()
				level3 = nil
			end

			if level2 and level >= 2 then
				level2:Disconnect()
				level2 = nil
			end

			if level1 and level >= 1 then
				level1:Disconnect()
				level1 = nil
			end
			
			-- fill the health bar on the machine
			healthMachineFillBar:TweenSize(UDim2.new(1,0, level / 10, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 3)
		end
	end
end


-- player fires the proximity prompt on the health machine
workspace.Machines.HealthMachine.ProximityPrompt.ProximityPrompt.Triggered:Connect(function(plr)
	healthMachineGui.Visible = true
	healthMachineGui:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)
	
	if hasMouse then
		EnableMouseRemoteEvent:FireServer(true)
	end
	
	local walkSpeed
	if plr.Character and plr.Character:FindFirstChild("Humanoid") then
		walkSpeed = plr.Character.Humanoid.WalkSpeed
		plr.Character.Humanoid.WalkSpeed = 0
	end
	walkSpeed = walkSpeed or 20
	
	if not firstTrigger then
		firstTrigger = true

		level1 = levels.Level1.MouseButton1Down:Connect(function()
			LevelClicked(1)
		end)

		level2 = levels.Level2.MouseButton1Down:Connect(function()
			LevelClicked(2)
		end)

		level3 = levels.Level3.MouseButton1Down:Connect(function()
			LevelClicked(3)
		end)

		level4 = levels.Level4.MouseButton1Down:Connect(function()
			LevelClicked(4)
		end)

		level5 = levels.Level5.MouseButton1Down:Connect(function()
			LevelClicked(5)
		end)

		level6 = levels.Level6.MouseButton1Down:Connect(function()
			LevelClicked(6)
		end)

		level7 = levels.Level7.MouseButton1Down:Connect(function()
			LevelClicked(7)
		end)

		level8 = levels.Level8.MouseButton1Down:Connect(function()
			LevelClicked(8)
		end)

		level9 = levels.Level9.MouseButton1Down:Connect(function()
			LevelClicked(9)
		end)

		level10 = levels.Level10.MouseButton1Down:Connect(function()
			LevelClicked(10)
		end)
		
		close = healthMachineGui.Close.MouseButton1Down:Connect(function()
			if plr.Character and plr.Character:FindFirstChild("Humanoid") then
				plr.Character.Humanoid.WalkSpeed = walkSpeed
			end

			if hasMouse then
				EnableMouseRemoteEvent:FireServer(false)
			end
			
			healthMachineGui:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)
			wait(0.5)
			healthMachineGui.Visible = false
		end)
	end
end)