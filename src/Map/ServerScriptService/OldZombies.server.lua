local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local DamageZombie = ServerStorage:WaitForChild("DamageZombie")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateZombieCount = ReplicatedStorage:WaitForChild("UpdateZombieCount")
local MysteryBoxRemoteEvent = ReplicatedStorage:WaitForChild("MysteryBox")
local UpdateAmmoCountRemoteEvent = ReplicatedStorage:WaitForChild("UpdateAmmoCount")
local ResetAmmosRemoteEvent = ReplicatedStorage:WaitForChild("ResetAmmos")
local UpdateHealthRemoteEvent = ReplicatedStorage:WaitForChild("UpdateHealth")

local newZombiesFolder = workspace:WaitForChild("Zombies")
local zombiesFolder = ServerStorage:WaitForChild("Zombies")

local zombieCollisionGroup : string = "Zombies"

local Zombie = {}
Zombie.__index = Zombie

local mysteryBoxTemplate : Model = ServerStorage:WaitForChild("MysteryBox")

local Zombies = {}
local index : number = 0
local zombiesLeft : number = 0


-- move the mystery box up until we find a spot
local function SetPartYPosition(part : Part)
	while part.Position.Y < 50 do
		local raycastResult : RaycastResult = workspace:Raycast(part.Position, Vector3.new(0,10,0))

		if raycastResult then
			part.Position = Vector3.new(part.Position.X, raycastResult.Position.Y + raycastResult.Instance.Size.Y + 1, part.Position.Z)
		else
			return true
		end
	end

	return false
end


-- reload a weapon
local function ReloadWeapon(plr : Player, weapon : Tool)

	-- if it's a ranged weapon (gun), reload it, otherwise no need it because there are no ammos
	if weapon:FindFirstChild("Configuration") then
		local ammos : number = weapon.Configuration.AmmoCapacity.Value
		weapon.CurrentAmmo.Value = ammos

		-- update the number of ammos text gui
		ResetAmmosRemoteEvent:FireClient(plr, ammos)
		UpdateAmmoCountRemoteEvent:FireClient(plr, ammos)
	end
end



--[[
Creates a new zombie with the given parameters

Params :
name : the name (type) of zombies
health : the amount of health the zombie has
damage : the damage the zombie deals
attackSpeed : the speed at which the zombie can attack (cooldown between two attacks)
speed : the speed at which the zombie can move
coins : the amount of coins the player that kills the zombie gets
position : the position to spawn the zombie at

Return :
Metatable (a metatable with all the zombies?)
]]--
function Zombie.new(name : string, health : number, damage : number, attackSpeed : number, speed : number, coins : number, position : Vector3)

	if zombiesFolder:FindFirstChild(name) then
		--local newZombie = {
		--	Health = health or 100,
		--	Damage = damage or 10,
		--	AttackSpeed = attackSpeed or 1,
		--	Speed = speed or 18,
		--	Coins = coins or 10,
		--	LastAttack = 0
		--}

		local zombieClone = zombiesFolder[name]:Clone()
		--zombieClone.Name = "Zombie"..tostring(index)
		zombieClone.HumanoidRootPart.Position = position
		zombieClone.Index.Value = index
		zombieClone.Parent = newZombiesFolder

		-- add all the parts of the zombie to the collision group to disable them
		for _,v in ipairs(zombieClone:GetDescendants()) do
			if v:IsA("BasePart") then
				--v:SetNetworkOwner(nil)
				PhysicsService:SetPartCollisionGroup(v, zombieCollisionGroup)
			end
		end

		local humanoid : Humanoid = zombieClone.Humanoid
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		--humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
		--humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
		--humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		--humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
		--humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
		--humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)

		--Zombies[index] = {newZombie, zombieClone}
		index += 1
		zombiesLeft += 1

		--return setmetatable(newZombie, Zombie)
	end
end



function Zombie:TakeDamage(humanoid : Humanoid, damage: number, plr : Player)
	if humanoid and damage and humanoid:IsA("Humanoid") and humanoid.Parent and humanoid:IsDescendantOf(workspace.Zombies) and typeof(damage) == "number" then

		-- if the zombie has less health than the damage he is supposed to take, kill him
		if humanoid.Health <= damage then
			if humanoid.Parent then

				-- give coins to the player for killing a zombie
				if humanoid.Parent:FindFirstChild("Coins") then
					plr.leaderstats.Coins.Value += math.round(humanoid.Parent.Coins.Value * plr.Stats.CoinsMultiplier.Value)
				end

				-- update the player's stats
				plr.GameStats.CoinsEarnt.Value += math.round(humanoid.Parent.Coins.Value * plr.Stats.CoinsMultiplier.Value)
				plr.GameStats.ZombiesKilled.Value += 1

				humanoid.Parent:Destroy()
				zombiesLeft -= 1

				-- update the zombie count in the bottom right hand corner
				UpdateZombieCount:FireAllClients(zombiesLeft)

				-- if there are less than 10 zombies, count the number of zombies left in the folder (in case, zombiesLeft would be off)
				if zombiesLeft < 10 then
					if #newZombiesFolder:GetChildren() == 0 then
						require(ServerScriptService.Rounds):EndOfRound()
					end
				end

				-- 1 in 500 chance of spawning a mystery box
				if math.random() < 0.002 then
					local mysteryBox : Model = mysteryBoxTemplate:Clone()

					-- move the mystery box until we find a spot
					local foundPosition : boolean = false
					repeat
						-- random position on the map (between the two corner parts)
						mysteryBox.PrimaryPart.Position = Vector3.new(math.random(workspace.MapCorners.Part2.Position.X, workspace.MapCorners.Part1.Position.X), 2, math.random(workspace.MapCorners.Part1.Position.Z, workspace.MapCorners.Part2.Position.Z))

						-- check if there is ground below the part (if not it probably is out of the map)
						if workspace:Raycast(mysteryBox.PrimaryPart.Position, Vector3.new(0,-5,0)) then

							-- move the part up until there is a spot or the part is above Y=50
							foundPosition = SetPartYPosition(mysteryBox.PrimaryPart)
						end

						RunService.Heartbeat:Wait()
					until foundPosition

					-- delete the mystery box after 30 seconds if he hasn't been opened
					Debris:AddItem(mysteryBox, 30)

					-- show all the players that a mystery box spawned
					MysteryBoxRemoteEvent:FireAllClients(plr)

					-- players have 30 seconds to open the mystery box
					coroutine.wrap(function()
						local countdown : TextLabel = mysteryBox.HitBox.BillboardGui.Countdown

						for i=29,0,-1 do

							-- if the mystery box hasn't not been opened yet (and thus destroyed), update the countdown
							if countdown.Parent then
								countdown.Text = i
								wait(1)
							else
								return
							end
						end
					end)()

					-- player opens the mystery box
					mysteryBox.HitBox.ProximityPrompt.Triggered:Connect(function(plr)

						-- if the player is close enough to the mystery box
						if plr:DistanceFromCharacter(mysteryBox.HitBox.Position) < 12 then
							mysteryBox:Destroy()

							local randomReward : number = math.random(1,7)

							-- give a random amount of coins to the player that triggered the proximity prompt
							if randomReward == 1 then
								local randomAmount = math.random(100,1000)
								plr.leaderstats.Coins.Value += math.round(randomAmount * plr.Stats.CoinsMultiplier.Value)

								if plr:FindFirstChild("Stats") and plr.Stats:FindFirstChild("Coins") then
									plr.GameStats.CoinsEarnt.Value += math.round(randomAmount * plr.Stats.CoinsMultiplier.Value)
								end

								MysteryBoxRemoteEvent:FireAllClients(plr, 1, randomAmount)

								-- heal all players
							elseif randomReward == 2 then
								for _,player : Player in ipairs(Players:GetPlayers()) do
									player.Stats.Health.Value = player.Stats.MaxHealth.Value
									UpdateHealthRemoteEvent:FireAllClients(player)
								end								

								MysteryBoxRemoteEvent:FireAllClients(plr, 2)

								-- refill ammos of all weapons for all players
							elseif randomReward == 3 then
								for _,player : Player in ipairs(Players:GetPlayers()) do

									-- reload unequipped weapons
									for _,weapon : Tool in ipairs(player.Backpack:GetChildren()) do
										ReloadWeapon(player, weapon)
									end

									-- reload equipped weapon if the player has one
									if player.Character then
										local weapon : Tool? = player.Character:FindFirstChildOfClass("Tool")

										if weapon then
											ReloadWeapon(player, weapon)
										end
									end
								end

								MysteryBoxRemoteEvent:FireAllClients(plr, 3)

								-- instant kill for a random amount of time for all players
							elseif randomReward == 4 then
								local lastingTime : number = math.random(3,15)

								-- set the damage multiplier value to a lot so that the player can instantly kill any zombie
								for _,player : Player in ipairs(Players:GetPlayers()) do
									player.Weapons.DamageMultiplier.Value = 100
								end

								coroutine.wrap(function()
									wait(lastingTime)

									-- reset the damage multiplier value
									for _,player : Player in ipairs(Players:GetPlayers()) do
										player.Weapons.DamageMultiplier.Value = 1 + player.Machines.DamageMultiplierMachine.Value * 0.1
									end
								end)()

								MysteryBoxRemoteEvent:FireAllClients(plr, 4, lastingTime)

								-- explosion around all players that kill all the zombies in a random radius
							elseif randomReward == 5 then
								local radius : number = math.random(5,15)

								for _,player : Player in ipairs(Players:GetPlayers()) do

									-- create the explosion
									local explosion : Explosion = Instance.new("Explosion")
									explosion.BlastRadius = radius
									explosion.BlastPressure = 0
									explosion.ExplosionType = Enum.ExplosionType.NoCraters
									explosion.DestroyJointRadiusPercent = 0

									if player.Character then
										explosion.Position = player.Character.Head.Position
									end

									-- if the explosion hits a zombie, kill him
									explosion.Hit:Connect(function(part, distance)
										if part.Name == "Head" and part.Parent and part:IsDescendantOf(workspace.Zombies) and part.Parent:FindFirstChild("Humanoid") then
											self:TakeDamage(part.Parent.Humanoid, math.huge, player)
										end
									end)

									Debris:AddItem(explosion, 4)
									explosion.Parent = workspace
								end

								MysteryBoxRemoteEvent:FireAllClients(plr, 5)

								-- invincibility for a random amount of time for all players
							elseif randomReward == 6 then								
								local lastingTime : number = math.random(3,15)

								-- make the player invincible
								for _,player : Player in ipairs(Players:GetPlayers()) do
									player.Stats.TotalDefense.Value = 1
								end

								coroutine.wrap(function()
									wait(lastingTime)

									-- reset the player's defense
									for _,player : Player in ipairs(Players:GetPlayers()) do
										local defenseSum : number = 0

										for _,v in ipairs(player.Stats.Defense:GetChildren()) do
											defenseSum += v.Value
										end

										player.Stats.TotalDefense.Value = defenseSum
									end
								end)()

								MysteryBoxRemoteEvent:FireAllClients(plr, 6, lastingTime)

								-- double coins for a random amount of time for all players
							elseif randomReward == 7 then								
								local lastingTime : number = math.random(3,15)

								-- make the player invincible
								for _,player : Player in ipairs(Players:GetPlayers()) do
									player.Stats.CoinsMultiplier.Value = 2
								end

								coroutine.wrap(function()
									wait(lastingTime)

									-- reset the player's defense
									for _,player : Player in ipairs(Players:GetPlayers()) do
										player.Stats.CoinsMultiplier.Value = 1
									end
								end)()

								MysteryBoxRemoteEvent:FireAllClients(plr, 7, lastingTime)
							end
						end
					end)

					mysteryBox.Parent = workspace
				end
			end

		else
			humanoid.Health -= damage

			-- abilities
			if plr then

				-- if the player has the fire ability enabled, put the zombie on fire
				if plr.Weapons.FireAbility.Value then
					if not self:IsOnFire(humanoid.Parent) then
						self:OnFire(humanoid.Parent)
					end
				end

				-- if the player has the poison ability enabled, poison the zombie
				if plr.Weapons.PoisonAbility.Value then
					if not self:IsPoisonned(humanoid.Parent) then
						self:Poison(humanoid.Parent)
					end
				end

				-- if the player has the ice ability enabled, freeze the zombie
				if plr.Weapons.IceAbility.Value then
					if not self:IsFrozen(humanoid.Parent) then
						self:Freeze(humanoid.Parent)
					end
				end
			end

			-- red hightlight on hit
			coroutine.wrap(function()
				if humanoid.Parent and humanoid.Parent:FindFirstChild("Highlight") then
					humanoid.Parent.Highlight.Enabled = true

					-- wait 6 frames (wait less than the minimum weapon cooldown (0.1s))
					-- otherwise coroutine are created faster than they die which may result in lag
					for _=1,6 do
						RunService.Stepped:Wait()
					end

					if humanoid.Parent then
						humanoid.Parent.Highlight.Enabled = false
					end
				end
			end)()
		end
	end
end


-- bindable event called when a a bullet touches a zombie
DamageZombie.Event:Connect(function(humanoid : Humanoid, damage : number, plr : Player)
	Zombie:TakeDamage(humanoid, damage * plr.Weapons.DamageMultiplier.Value * plr.Roles.Sniper.Value, plr)
end)


--[[
The zombie is on fire

Params : 
zombie : the zombie that is supposed to be on fire
]]--
function Zombie:OnFire(zombie : Model)
	if zombie then
		local humanoid : Humanoid? = zombie:FindFirstChild("Humanoid")

		if humanoid then
			local duration : number = 3
			local timeBetweenDamage : number = 0.4

			-- make the zombie slower by 15%
			local walkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed *= 0.85

			-- add a fire on the zombie's head
			if zombie:FindFirstChild("Head") then
				local fire : Fire = Instance.new("Fire")
				fire.Heat = 1
				fire.Size = 4

				Debris:AddItem(fire, duration)

				fire.Parent = zombie.Head
			end

			-- zombie takes 2 damage every 0.4 seconds for 3 seconds
			coroutine.wrap(function()
				for _ = 1, (duration / timeBetweenDamage) do

					self:TakeDamage(humanoid, 2)
					wait(timeBetweenDamage)
				end

				humanoid.WalkSpeed = walkSpeed
			end)()
		end
	end
end


--[[
Check if the specified zombie is on fire

Params : 
zombie : the zombie that might be on fire

Return :
Boolean? (true if the zombie has a fire Instance in his head, false or nil otherwise)
]]--
function Zombie:IsOnFire(zombie : Model) : boolean?
	if zombie and zombie:FindFirstChild("Head") then
		return zombie.Head:FindFirstChild("Fire")
	end

	return false
end


--[[
The zombie is poisonned

Params : 
zombie : the zombie that is supposed to be poisonned
]]--
function Zombie:Poison(zombie : Model)

	if zombie then
		local humanoid : Humanoid? = zombie:FindFirstChild("Humanoid")

		if humanoid then
			local duration :number = 3
			local timeBetweenDamage : number = 0.4

			-- add a particleEmitter on the zombie's head
			if zombie:FindFirstChild("Head") then
				local particleEmitter : ParticleEmitter = Instance.new("ParticleEmitter")
				particleEmitter.Color = ColorSequence.new(Color3.fromRGB(209,41,255))
				particleEmitter.Size = NumberSequence.new(0.6)
				particleEmitter.Lifetime = NumberRange.new(0.5, 0.6)
				particleEmitter.Rate = 20
				particleEmitter.Speed = NumberRange.new(3,3)
				particleEmitter.SpreadAngle = Vector2.new(0, 180)

				Debris:AddItem(particleEmitter, duration)

				particleEmitter.Parent = zombie.Head
			end

			-- zombie takes 4 damage every 0.4 seconds for 3 seconds
			coroutine.wrap(function()
				for _ = 1, (duration / timeBetweenDamage) do

					self:TakeDamage(humanoid, 4)
					wait(timeBetweenDamage)
				end
			end)()
		end
	end
end


--[[
Check if the specified zombie is already poisonned

Params : 
zombie : the zombie that might be on poisonned

Return :
Boolean? (true if the zombie has a particleEmitter Instance in his head, false or nil otherwise)
]]--
function Zombie:IsPoisonned(zombie : Model) : boolean?
	if zombie and zombie:FindFirstChild("Head") then
		return zombie.Head:FindFirstChild("ParticleEmitter")
	end

	return false
end


--[[
The zombie is frozen

Params : 
zombie : the zombie that is supposed to be frozen
]]--
function Zombie:Freeze(zombie : Model)

	if zombie then
		local humanoid : Humanoid? = zombie:FindFirstChild("Humanoid")
		local head : Part? = zombie:FindFirstChild("Head")

		if humanoid and head then

			-- make the zombie slower by 30%
			local walkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed *= 0.7

			local headColor : BrickColor = head.BrickColor

			-- turn the zombie's head to ice
			if zombie:FindFirstChild("Head") then
				head.BrickColor = BrickColor.new("Pastel Blue")
				head.Material = Enum.Material.Ice
			end

			coroutine.wrap(function()
				wait(3)

				head.BrickColor = headColor
				head.Material = Enum.Material.Plastic

				humanoid.WalkSpeed = walkSpeed
			end)()
		end
	end
end


--[[
Check if the specified zombie is already frozen

Params : 
zombie : the zombie that might be on frozen

Return :
Boolean (true if the zombie has an ice head, false otherwise)
]]--
function Zombie:IsFrozen(zombie : Model) : boolean
	if zombie and zombie:FindFirstChild("Head") then
		return zombie.Head.Material == Enum.Material.Ice
	end

	return false
end


return Zombie