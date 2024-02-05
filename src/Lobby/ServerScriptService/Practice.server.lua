local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local DamageZombieBindableEvent = ServerStorage:WaitForChild("DamageZombie")
local tools : Folder = ServerStorage:WaitForChild("Tools")
local zombieToClone : Model = ServerStorage:WaitForChild(" ")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EnableCameraRemoteEvent = ReplicatedStorage:WaitForChild("EnableCamera")

local practiceArea : Model = workspace:WaitForChild("PracticeArea")
local zombies : Folder = workspace.PracticeArea.Zombies

local positionsToRespawn : {Vector3} = {}


-- if the player is entering pratice, force the third person camera
for _,v : Part in ipairs(practiceArea:WaitForChild("InnerBorders"):GetChildren()) do
	v.Touched:Connect(function(hit)
		if hit.Name == "HumanoidRootPart" then
			
			local player : Player? = Players:GetPlayerFromCharacter(hit.Parent)
			if player then				
				
				if not player.IsInPractice.Value then
					player.IsInPractice.Value = true
					EnableCameraRemoteEvent:FireClient(player, true)
				end
			end
		end
	end)
end


-- if the player is already in practice, remove all weapons he has and disable the third person camera
for _,v : Part in ipairs(practiceArea:WaitForChild("OuterBorders"):GetChildren()) do
	v.Touched:Connect(function(hit)
		if hit.Name == "HumanoidRootPart" then
			
			local player : Player? = Players:GetPlayerFromCharacter(hit.Parent)
			if player then

				if player.IsInPractice.Value then
					player.IsInPractice.Value = false
					EnableCameraRemoteEvent:FireClient(player, false)

					if player.Character and player.Character:FindFirstChildOfClass("Tool") then
						player.Character:FindFirstChildOfClass("Tool").Parent = player.Backpack
					end

					player.Backpack:ClearAllChildren()
				end
			end
		end
	end)
end


for _,v : Model in ipairs(workspace.PracticeArea.WeaponGivers:GetChildren()) do
	v.Price.ProximityPrompt.Triggered:Connect(function(plr : Player)
		if plr.Character then
			
			if not plr.Character:FindFirstChild(v.Name) and not plr.Backpack:FindFirstChild(v.Name) then
				if plr.Character:FindFirstChildOfClass("Tool") then
					plr.Character:FindFirstChildOfClass("Tool").Parent = plr.Backpack
				end
				
				
				local tool : Tool = tools[v.Name]:Clone()
				
				if v:FindFirstChild("Stats") then
					
					tool.Body.Touched:Connect(function(hit : Part)
						if hit.Name == "HumanoidRootPart" and hit.Parent:FindFirstChild("Humanoid") and hit:IsDescendantOf(practiceArea.Zombies) then
							
							if hit.Parent.Humanoid.Health > v.Stats.Damage.Value then
								hit.Parent.Humanoid.Health -= v.Stats.Damage.Value
							else
								table.insert(positionsToRespawn, hit.Position)
								hit.Parent:Destroy()
							end
						end
					end)
					
					local animationTrack : AnimationTrack = plr.Character.Humanoid:LoadAnimation(tool.Animation)
					
					tool.Activated:Connect(function()
						if tool.LastActivated.Value + v.Stats.Cooldown.Value < tick() then
							tool.LastActivated.Value = tick()
							animationTrack:Play()
						end
					end)
				end
				
				tool.Parent = plr.Character
			end
		end
	end)
end


DamageZombieBindableEvent.Event:Connect(function(humanoid : Humanoid, damage : number)
	
	-- damage the zombie if their health is superior to the damage
	if humanoid.Health > damage then
		humanoid.Health -= damage
		
	-- kill them otherwise
	else
		table.insert(positionsToRespawn, humanoid.Parent.HumanoidRootPart.Position)
		humanoid.Parent:Destroy()
	end
end)


-- respawn the zombies
coroutine.wrap(function()
	while true do
		
		-- if there is at least one zombie to respawn
		if #positionsToRespawn > 0 then
			
			-- clone the zombie and move it the position of the previous zombie
			local zombie : Model = zombieToClone:Clone()
			zombie:PivotTo(CFrame.new(positionsToRespawn[1]))
			zombie.Parent = zombies
			
			table.remove(positionsToRespawn, 1)
		end
		
		task.wait(5)
	end
end)()