local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Utilities = require(ServerScriptService:WaitForChild("Utilities"))
local PlayersModuleScript = require(ServerScriptService:WaitForChild("Players"))

local sewer : Folder = script.Parent
local price : number = sewer:WaitForChild("Price").Value


for _,v in ipairs(sewer:WaitForChild("ManholeCovers"):GetChildren()) do

	-- if the player triggers the proximity prompt, he can get in the sewer and get back on the other side of the street
	v:WaitForChild("Price"):WaitForChild("ProximityPrompt").Triggered:Connect(function(plr)

		if not PlayersModuleScript:IsDown(plr) then

			if plr:DistanceFromCharacter(v.Price.Position) < 10 then

				if Utilities:PlayerHasEnoughCoins(plr, price) then

					if Utilities:RemoveCoins(plr, price) then

						if sewer.Sensors:FindFirstChild(v.Name) and sewer.Sensors[v.Name]:FindFirstChild("Start") and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
							local humanoid : Humanoid = plr.Character.Humanoid
							
							-- store the walkspeed and jump height of the player
							plr.WalkSpeed.Value = humanoid.WalkSpeed
							plr.JumpHeight.Value = humanoid.JumpHeight
							
							humanoid.WalkSpeed = 0
							humanoid.JumpHeight = 0
							plr.Character.HumanoidRootPart.CFrame = sewer.Sensors[v.Name].Start.CFrame
						end
					end
				end
			end
		end
	end)
end


-- teleport the player back to the street once he hits the end of the sewer
for _,v in ipairs(sewer:WaitForChild("Sensors"):GetChildren()) do
	v:WaitForChild("End").Touched:Connect(function(hit)

		if hit.Name == "HumanoidRootPart" and hit.Parent:FindFirstChild("Humanoid") then
			
			local plr : Player = Players:GetPlayerFromCharacter(hit.Parent)
			if plr then
				
				local humanoid : Humanoid = hit.Parent.Humanoid
				humanoid.WalkSpeed = plr.WalkSpeed.Value
				humanoid.JumpHeight = plr.JumpHeight.Value

				if v.Name == "Sewer1" then
					hit.CFrame = sewer.Sewer2Position.CFrame
				else
					hit.CFrame = sewer.Sewer1Position.CFrame
				end
			end
		end
	end)
end