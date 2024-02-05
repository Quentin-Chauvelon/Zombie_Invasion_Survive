local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MachineRemoteFunction = ReplicatedStorage:WaitForChild("Machines")
local EnableMouseRemoteEvent = ReplicatedStorage:WaitForChild("EnableMouse")

local perksMachineGui : Frame = script.Parent:WaitForChild("Frame")

local lplr : Player = game.Players.LocalPlayer

local hasMouse : boolean = game:GetService("UserInputService").MouseEnabled
local firstTrigger : boolean = false

local PerksMachinePerks : Folder = workspace:WaitForChild("Machines"):WaitForChild("PerksMachine"):WaitForChild("PerksMachine"):WaitForChild("Perks")

local regenerationLevel1, regenerationLevel2, regenerationLevel3, regenerationLevel4
local speedLevel1, speedLevel2, speedLevel3
local jumpLevel1, jumpLevel2, jumpLevel3
local close


-- player clicked a level
local function LevelClicked(machine : string, level : number)

	-- if the player hasn't already bought an higher level of perks
	if lplr.Machines:FindFirstChild(machine.."Machine") and lplr.Machines[machine.."Machine"].Value < level then
		if MachineRemoteFunction:InvokeServer(machine, level) then

			local levels : Frame = perksMachineGui.Levels:FindFirstChild(machine)

			if levels then
				for i : number = level,1,-1 do
					local lowerLevel : ImageButton? = levels:FindFirstChild("Level"..tostring(i))

					if lowerLevel then
						lowerLevel.AutoButtonColor = false
						lowerLevel.ImageColor3 = Color3.fromRGB(128,128,128)
						lowerLevel.Price.Text = "OWNED"
						lowerLevel.Price.TextColor3 = Color3.fromRGB(71,190,58)
					end
				end
			end

			-- disconnect regeneration events
			if machine == "Regeneration" then
				if regenerationLevel1 and level >= 1 then
					regenerationLevel1:Disconnect()
					regenerationLevel1 = nil
				end
			
				if regenerationLevel2 and level >= 2 then
					regenerationLevel2:Disconnect()
					regenerationLevel2 = nil
				end
			
				if regenerationLevel3 and level >= 3 then
					regenerationLevel3:Disconnect()
					regenerationLevel3 = nil
				end
				
				if regenerationLevel4 and level >= 4 then
					regenerationLevel4:Disconnect()
					regenerationLevel4 = nil
				end
			end
		
			-- disconnect speed events
			if machine == "Speed" then
				if speedLevel1 and level >= 1 then
					speedLevel1:Disconnect()
					speedLevel1 = nil
				end
			
				if speedLevel2 and level >= 2 then
					speedLevel2:Disconnect()
					speedLevel2 = nil
				end
			
				if speedLevel3 and level >= 3 then
					speedLevel3:Disconnect()
					speedLevel3 = nil
				end
			end
		
			-- disconnect jump events
			if machine == "Jump" then
				if jumpLevel1 and level >= 1 then
					jumpLevel1:Disconnect()
					jumpLevel1 = nil
				end
			
				if jumpLevel2 and level >= 2 then
					jumpLevel2:Disconnect()
					jumpLevel2 = nil
				end
			
				if jumpLevel3 and level >= 3 then
					jumpLevel3:Disconnect()
					jumpLevel3 = nil
				end
			end
			
			for i=level,1,-1 do
				if PerksMachinePerks:FindFirstChild(machine) and PerksMachinePerks[machine]:FindFirstChild("Light"..tostring(i)) then
					PerksMachinePerks[machine]["Light"..tostring(i)].Color = Color3.new(0,1,0)
				end
			end
		end
	end
end


-- player fires the proximity prompt on the perks machine
workspace.Machines.PerksMachine.ProximityPrompt.ProximityPrompt.Triggered:Connect(function(plr)
	perksMachineGui.Visible = true
	perksMachineGui:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)

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
		
		local regenerationlevels : Frame = perksMachineGui.Levels.Regeneration
		local speedlevels : Frame = perksMachineGui.Levels.Speed
		local jumplevels : Frame = perksMachineGui.Levels.Jump
		
		-- regeneration
		regenerationLevel1 = regenerationlevels.Level1.MouseButton1Down:Connect(function()
			LevelClicked("Regeneration", 1)
		end)

		regenerationLevel2 = regenerationlevels.Level2.MouseButton1Down:Connect(function()
			LevelClicked("Regeneration", 2)
		end)

		regenerationLevel3 = regenerationlevels.Level3.MouseButton1Down:Connect(function()
			LevelClicked("Regeneration", 3)
		end)

		regenerationLevel4 = regenerationlevels.Level4.MouseButton1Down:Connect(function()
			LevelClicked("Regeneration", 4)
		end)
		
		-- speed
		speedLevel1 = speedlevels.Level1.MouseButton1Down:Connect(function()
			LevelClicked("Speed", 1)
		end)

		speedLevel2 = speedlevels.Level2.MouseButton1Down:Connect(function()
			LevelClicked("Speed", 2)
		end)

		speedLevel3 = speedlevels.Level3.MouseButton1Down:Connect(function()
			LevelClicked("Speed", 3)
		end)

		-- jump
		jumpLevel1 = jumplevels.Level1.MouseButton1Down:Connect(function()
			LevelClicked("Jump", 1)
		end)

		jumpLevel2 = jumplevels.Level2.MouseButton1Down:Connect(function()
			LevelClicked("Jump", 2)
		end)

		jumpLevel3 = jumplevels.Level3.MouseButton1Down:Connect(function()
			LevelClicked("Jump", 3)
		end)

		close = perksMachineGui.Close.MouseButton1Down:Connect(function()
			if plr.Character and plr.Character:FindFirstChild("Humanoid") then
				
				-- only change the player's walkspeed if it's lower than the current one (when player buys speed, it resets his walkspeed and 2)
				-- and so if it's set back to walkspeed, the player loses the speed he bought
				if plr.Character.Humanoid.WalkSpeed < walkSpeed then
					plr.Character.Humanoid.WalkSpeed = walkSpeed
				end
			end

			if hasMouse then
				EnableMouseRemoteEvent:FireServer(false)
			end

			perksMachineGui:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)
			wait(0.5)
			perksMachineGui.Visible = false
		end)
	end
end)