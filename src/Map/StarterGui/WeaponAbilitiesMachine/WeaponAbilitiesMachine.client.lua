local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MachineRemoteFunction = ReplicatedStorage:WaitForChild("Machines")
local EnableMouseRemoteEvent = ReplicatedStorage:WaitForChild("EnableMouse")

local weaponAbilitiesMachineGui : Frame = script.Parent:WaitForChild("Frame")
local levels : Frame = weaponAbilitiesMachineGui:WaitForChild("Levels")

local weaponAbilitiesMachineEffects : Folder = workspace:WaitForChild("Machines"):WaitForChild("WeaponAbilitiesMachine"):WaitForChild("WeaponAbilitiesMachine"):WaitForChild("Effects")

local lplr : Player = game.Players.LocalPlayer

local hasMouse : boolean = game:GetService("UserInputService").MouseEnabled
local firstTrigger : boolean = false

local close


-- player clicked a level
local function LevelClicked(ability : string)

	-- if the player hasn't already bought an higher level of perks
	if lplr:FindFirstChild("Weapons") and lplr.Weapons:FindFirstChild(ability.."Ability") and not lplr.Weapons[ability.."Ability"].Value then
		if MachineRemoteFunction:InvokeServer("WeaponAbilities", ability) then

			local level = levels:FindFirstChild(ability)
			if level then
				
				-- disable the others ability if they were already selected
				for _,v : ImageButton | UIListLayout in ipairs(levels:GetChildren()) do
					if v:IsA("ImageButton") and v.Name ~= ability then
						v.AutoButtonColor = true
						v.ImageColor3 = Color3.new(1,1,1)
						v.Price.Text = workspace.Machines.WeaponAbilitiesMachine.Prices[v.Name].Value
						v.Price.TextColor3 = Color3.fromRGB(255,192,32)
					end
				end
				
				level.AutoButtonColor = false
				level.ImageColor3 = Color3.fromRGB(128,128,128)
				level.Price.Text = "OWNED"
				level.Price.TextColor3 = Color3.fromRGB(71,190,58)
				
				-- turn off all the lights on the machine
				for _,v : Model in ipairs(weaponAbilitiesMachineEffects:GetChildren()) do
					v.Light.Color = Color3.fromRGB(83, 83, 83)
				end
				
				if weaponAbilitiesMachineEffects:FindFirstChild(ability) then
					weaponAbilitiesMachineEffects[ability].Light.Color = Color3.new(0,1,0)
				end
			end
		end
	end
end


-- player fires the proximity prompt on the perks machine
workspace.Machines.WeaponAbilitiesMachine.ProximityPrompt.ProximityPrompt.Triggered:Connect(function(plr)
	weaponAbilitiesMachineGui.Visible = true
	weaponAbilitiesMachineGui:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)

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
		
		for _,v : ImageButton | UIListLayout in ipairs(levels:GetChildren()) do
			if v:IsA("ImageButton") then
				v.MouseButton1Down:Connect(function()
					LevelClicked(v.Name)
				end)
			end
		end

		close = weaponAbilitiesMachineGui.Close.MouseButton1Down:Connect(function()
			if plr.Character and plr.Character:FindFirstChild("Humanoid") then
				plr.Character.Humanoid.WalkSpeed = walkSpeed
			end

			if hasMouse then
				EnableMouseRemoteEvent:FireServer(false)
			end

			weaponAbilitiesMachineGui:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)
			wait(0.5)
			weaponAbilitiesMachineGui.Visible = false
		end)
	end
end)