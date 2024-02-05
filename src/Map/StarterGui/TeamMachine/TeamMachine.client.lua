local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MachineRemoteFunction = ReplicatedStorage:WaitForChild("Machines")
local EnableMouseRemoteEvent = ReplicatedStorage:WaitForChild("EnableMouse")

local teamMachineGui : Frame = script.Parent:WaitForChild("Frame")
local levels : Frame = teamMachineGui:WaitForChild("Levels")

local lplr : Player = game.Players.LocalPlayer

local hasMouse : boolean = game:GetService("UserInputService").MouseEnabled
local firstTrigger : boolean = false

local close


-- player clicked a level
local function CloseGui(walkSpeed)
	if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
		lplr.Character.Humanoid.WalkSpeed = walkSpeed
	end

	if hasMouse then
		EnableMouseRemoteEvent:FireServer(false)
	end

	teamMachineGui:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)
	wait(0.5)
	teamMachineGui.Visible = false
end


-- player fires the proximity prompt on the perks machine
workspace.Machines.TeamMachine.ProximityPrompt.ProximityPrompt.Triggered:Connect(function(plr)
	teamMachineGui.Visible = true
	teamMachineGui:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)

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
					MachineRemoteFunction:InvokeServer("Team", v.Name)
					CloseGui(walkSpeed)
				end)
			end
		end

		close = teamMachineGui.Close.MouseButton1Down:Connect(function()
			CloseGui(walkSpeed)
		end)
	end
end)