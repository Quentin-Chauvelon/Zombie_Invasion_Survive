local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ZombieJump = ReplicatedStorage:WaitForChild("ZombieJump")
local ZombieEffectRemoteEvent = ReplicatedStorage:WaitForChild("ZombieEffect")
local UpdateZombieHealthBarRemoteEvent = ReplicatedStorage:WaitForChild("UpdateZombieHealthBar")

local zombiesFolder = ReplicatedStorage:WaitForChild("Zombies")
local zombiesClient = workspace:WaitForChild("ZombiesClient")

local walkAnimation : Animation = ReplicatedStorage:WaitForChild("WalkAnimation")
local jumpAnimation : Animation = ReplicatedStorage:WaitForChild("JumpAnimation")


workspace:WaitForChild("Zombies").ChildAdded:Connect(function(zombie : Model)
	
	if zombiesFolder:FindFirstChild(zombie.Name) then
		
		local zombieClone : Model = zombiesFolder[zombie.Name]:Clone()
		
		zombie:WaitForChild("Zombie")
		
		local weldConstraint : WeldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = zombie.PrimaryPart
		weldConstraint.Part1 = zombieClone.PrimaryPart
		weldConstraint.Parent = zombieClone
		
		--zombieClone:MoveTo(zombie.PrimaryPart.Position)
		zombieClone:PivotTo(zombie.PrimaryPart.CFrame)
		zombieClone.Name = "Zombie"..tostring(zombie.Index.Value)
		zombieClone.Parent = zombiesClient
		
		local animation : AnimationTrack = zombieClone.AnimationController.Animator:LoadAnimation(walkAnimation)
		animation.Looped = true
		animation:Play()
	end
end)


workspace.Zombies.ChildRemoved:Connect(function(zombie : Model)
	if zombie:FindFirstChild("Index") then
		
		if zombiesClient:FindFirstChild("Zombie"..tostring(zombie.Index.Value)) then
			zombiesClient["Zombie"..tostring(zombie.Index.Value)]:Destroy()
		end
	end
end)


ZombieJump.OnClientEvent:Connect(function(index : number)
	local zombie = zombiesClient:FindFirstChild("Zombie"..tostring(index))
	
	if zombie then
		local animation : AnimationTrack = zombie.AnimationController.Animator:LoadAnimation(jumpAnimation)
		animation:Play()
	end
end)


ZombieEffectRemoteEvent.OnClientEvent:Connect(function(index : number, effect : number)
	
	if index and effect then
		
		local zombie = zombiesClient:FindFirstChild("Zombie"..tostring(index))
		if zombie then

			if effect == 1 then

				-- add a fire on the zombie's head
				if zombie:FindFirstChild("Head") then
					local fire : Fire = Instance.new("Fire")
					fire.Heat = 1
					fire.Size = 4

					Debris:AddItem(fire, 3)

					fire.Parent = zombie.Head
				end
				
				
			elseif effect == 2 then
				
				-- add a particleEmitter on the zombie's head
				if zombie:FindFirstChild("Head") then
					local particleEmitter : ParticleEmitter = Instance.new("ParticleEmitter")
					particleEmitter.Color = ColorSequence.new(Color3.fromRGB(209,41,255))
					particleEmitter.Size = NumberSequence.new(0.6)
					particleEmitter.Lifetime = NumberRange.new(0.5, 0.6)
					particleEmitter.Rate = 20
					particleEmitter.Speed = NumberRange.new(3,3)
					particleEmitter.SpreadAngle = Vector2.new(0, 180)

					Debris:AddItem(particleEmitter, 3)

					particleEmitter.Parent = zombie.Head
				end
				
			elseif effect == 3 then
				local head : MeshPart = zombie:FindFirstChild("Head")
				
				if head then
					local headColor : BrickColor = head.BrickColor

					-- turn the zombie's head to ice
					if zombie:FindFirstChild("Head") then
						head.BrickColor = BrickColor.new("Pastel Blue")
						head.Material = Enum.Material.Ice
					end
					
					coroutine.wrap(function()
						task.wait(3)

						head.BrickColor = headColor
						head.Material = Enum.Material.Plastic
					end)()
				end
			end
		end
	end
end)


UpdateZombieHealthBarRemoteEvent.OnClientEvent:Connect(function(index : number, health : number, maxHealth : number)
	
	local zombie : Model? = zombiesClient:FindFirstChild("Zombie"..tostring(index))
	if zombie then
		
		local billboardGui : BillboardGui = zombie.Head.BillboardGui
		if billboardGui then
			
			if not billboardGui.Enabled then
				billboardGui.Enabled = true
			end
			
			local healthPercentage : number = health / maxHealth
			
			billboardGui.Frame.HealthBar.Size = UDim2.new(healthPercentage, 0,1,0)
			
			-- get the color from 50% to 100% health, increase the red value, from 50% to 0% health, decrease the green value
			local R,G : number
			if healthPercentage > 0.5 then
				R = (1 - healthPercentage) * 2
				G = 1
			else
				R = 1
				G = healthPercentage * 2
			end
			
			billboardGui.Frame.HealthBar.BackgroundColor3 = Color3.new(R,G,0)
		end
	end
end)