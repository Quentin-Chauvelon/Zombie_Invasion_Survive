local Debris = game:GetService("Debris")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local HuntBindableEvent : BindableEvent = ServerStorage:WaitForChild("Hunt")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ZombieJump = ReplicatedStorage:WaitForChild("ZombieJump")

local PlayersModuleScript = require(ServerScriptService:WaitForChild("Players"))
local Zombies = require(ServerScriptService:WaitForChild("Zombies"))

local zombies : Folder = workspace:WaitForChild("Zombies")

local path : Path = PathfindingService:CreatePath()

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Blacklist
params.FilterDescendantsInstances = {zombies}

local waypoints
local nextWaypointIndex = 2
local reachedConnection
local blockedConnection


--local function WaitEvent(ev,t)
--	local obj = Instance.new("BoolValue")
--	local returns
--	local c;c = ev:Connect(function(...)
--		c:Disconnect()
--		c = nil
--		returns = {...}
--		obj.Value = true
--	end)
--	do
--		coroutine.wrap(function()
--			local ti = tick()
--			local waitTime = t
--			while (tick()-ti < waitTime) do
--				if (returns) then return end
--				waitTime = t + RunService.Heartbeat:Wait()
--			end
--			if (returns) then return end
--			c:Disconnect()
--			obj.Value = true
--		end)()
--	end
--	obj:GetPropertyChangedSignal("Value"):Wait()
--	obj:Destroy()
--	return (returns) and unpack(returns) or nil
--end


-- get the closest player to the zombie position
--local function closestPlayerPosition(zombie : Model, zombiePosition : Vector3) : Vector3
--	local closestPosition : Vector3 = Vector3.zero
--	local closestDistance : number = 10000
--	local closestPlayer : Player

--	-- loop through all players to find the closest one
--	for _,player : Player in ipairs(Players:GetPlayers()) do
--		if player:DistanceFromCharacter(zombiePosition) < closestDistance then
--			closestDistance = player:DistanceFromCharacter(zombiePosition)
--			closestPlayer = player

--			-- if the player is closer than 2.5 studs, damage him
--			if closestDistance <= 2.5 then

--				-- if the zombie is not a boom zombie, attack player, otherwise explode
--				if zombie.Name ~= "BoomZombie" then

--					-- if the zombie is not in cooldown
--					if tick() > (zombie.LastHit.Value + zombie:GetAttribute("AttackSpeed")) then
--						zombie.LastHit.Value = tick()
--						PlayersModuleScript:TakeDamage(player, zombie:GetAttribute("Damage"))

--						-- player catches on fire if hit by a fire zombie
--						if zombie.Name == "FireZombie" then

--							-- if the player is not already on fire
--							if not PlayersModuleScript:IsOnFire(player) then
--								-- put him on fire
--								PlayersModuleScript:OnFire(player)
--							end

--						elseif zombie.Name == "PoisonZombie" then

--							-- if the player is not already poisonned
--							if not PlayersModuleScript:IsPoisonned(player) then
--								-- poison him
--								PlayersModuleScript:Poison(player)
--							end

--						elseif zombie.Name == "IceZombie" then

--							-- if the player is not already frozen
--							if not PlayersModuleScript:IsFrozen(player) then
--								-- freeze him
--								PlayersModuleScript:Freeze(player)
--							end
--						end
--					end

--				else
--					-- create the explosion
--					local explosion : Explosion = Instance.new("Explosion")
--					explosion.BlastRadius = 10
--					explosion.BlastPressure = 0
--					explosion.ExplosionType = Enum.ExplosionType.NoCraters
--					explosion.DestroyJointRadiusPercent = 0
--					explosion.Position = zombie.Head.Position

--					-- kill the zombie
--					Zombies:TakeDamage(zombie.Humanoid, math.huge)

--					-- if the explosion hits a player, damage him
--					explosion.Hit:Connect(function(part, distance)
--						if part.Name == "Head" and part.Parent and Players:FindFirstChild(part.Parent.Name) then
--							PlayersModuleScript:TakeDamage(Players[part.Parent.Name], 25)
--						end
--					end)

--					Debris:AddItem(explosion, 4)
--					explosion.Parent = workspace
--				end
--			end
--		end
--	end

--	return closestPlayer.Character.LeftFoot
--end


local function CheckSight(zombiePrimaryPartPosition, closestPlayerPosition)
	-- check if the zombie can get to the player without using pathfind (if the player is in sight and at the same y level)
	local dif = closestPlayerPosition - zombiePrimaryPartPosition
	local mag = dif.Magnitude

	local p = workspace:Raycast(zombiePrimaryPartPosition, dif.Unit * mag, params)

	if p and p.Instance.Parent:FindFirstChild("Humanoid") and math.abs(closestPlayerPosition.Y - zombiePrimaryPartPosition.Y) < 3 then
		return true
	end

	return false
end


HuntBindableEvent.Event:Connect(function()
	coroutine.wrap(function()

		wait(1)

		local index : number = 0

		-- while there are zombies left
		while zombies:FindFirstChildOfClass("Model") do
			local zombiesLeft : number = #zombies:GetChildren()


			-- for all zombies, find the closest player
			for _,zombie : Model in ipairs(zombies:GetChildren()) do
				--local closestPlayer : Part = closestPlayerPosition(zombie, zombie.PrimaryPart.Position)

				--if closestPlayer then

				--	--if CheckSight(zombie.PrimaryPart.Position, closestPlayer.Position) then
				--	if true then
				--		TweenService:Create(zombie.PrimaryPart, TweenInfo.new((closestPlayer.Position - zombie.PrimaryPart.Position).Magnitude / 16, Enum.EasingStyle.Linear), {CFrame = closestPlayer.CFrame}):Play()

				--	else
				--		-- compute path
				--		local success, errorMessage = pcall(function()
				--			path:ComputeAsync(zombie.PrimaryPart.Position, closestPlayer.Position)
				--		end)

				--		-- get all waypoints
				--		if success and path.Status == Enum.PathStatus.Success then
				--			waypoints = path:GetWaypoints()
				--		end

				--local closestPlayer : Part = closestPlayerPosition(zombie, zombie.PrimaryPart.Position)

				index += 1

				if index > math.ceil(zombiesLeft / 10) then
					index = 0
					RunService.Heartbeat:Wait()
				end

				if zombie.Parent then
					local closestPlayerPosition : Vector3 = zombie.ClosestPlayer.Value.Position
					local zombiePosition : Vector3 = zombie.PrimaryPart.Position

					-- move the zombie back to the map if he fell in the void
					if math.abs((zombiePosition - closestPlayerPosition).Magnitude) > 10000 then
						zombie.PrimaryPart:PivotTo(CFrame.new(workspace.SpawnLocation.Position + Vector3.new(0,4,0)))
						continue
					end

					--if closestPlayer then

					if CheckSight(zombiePosition, closestPlayerPosition) then
						TweenService:Create(
							zombie.PrimaryPart,

							TweenInfo.new((
								closestPlayerPosition - zombiePosition).Magnitude / zombie.WalkSpeed.Value,
								Enum.EasingStyle.Linear
							),

							{CFrame =
								CFrame.lookAt(
									closestPlayerPosition + Vector3.new(0, (zombie.PrimaryPart.Size.Y - 5.3) / 2, 0),
									closestPlayerPosition + (closestPlayerPosition - zombiePosition).Unit + Vector3.new(0, (zombie.PrimaryPart.Size.Y - 5.3) / 2, 0))
							}
						):Play()

					else
						-- compute path
						local success, errorMessage = pcall(function()
							path:ComputeAsync(zombiePosition, closestPlayerPosition)
						end)

						-- get all waypoints
						if success and path.Status == Enum.PathStatus.Success then
							waypoints = path:GetWaypoints()

						else
							TweenService:Create(
								zombie.PrimaryPart,

								TweenInfo.new((
									closestPlayerPosition - zombiePosition).Magnitude / zombie.WalkSpeed.Value,
									Enum.EasingStyle.Linear
								),

								{CFrame =
									CFrame.lookAt(
										closestPlayerPosition + Vector3.new(0, (zombie.PrimaryPart.Size.Y - 5.3) / 2, 0),
										closestPlayerPosition + (closestPlayerPosition - zombiePosition).Unit + Vector3.new(0, (zombie.PrimaryPart.Size.Y - 5.3) / 2, 0))
								}
							):Play()
						end

						--workspace.Waypoints:ClearAllChildren()

						--for _,v : PathWaypoint in pairs(waypoints) do
						--	local part : Part = Instance.new("Part")
						--	part.Size = Vector3.new(1,1,1)
						--	part.Anchored = true
						--	part.CanCollide = false
						--	part.BrickColor = BrickColor.new("Really red")
						--	part.Position = v.Position
						--	part.Parent = workspace.Waypoints
						--end

						if waypoints and waypoints[nextWaypointIndex - 1] and waypoints[nextWaypointIndex] then
							if nextWaypointIndex < #waypoints - 1 then
								if waypoints[nextWaypointIndex - 1].Position == waypoints[nextWaypointIndex].Position then
									nextWaypointIndex += 1
								end

								if nextWaypointIndex < #waypoints - 2 then
									if waypoints[nextWaypointIndex].Action == Enum.PathWaypointAction.Jump then
										nextWaypointIndex += 2

										if zombie.Parent and zombie.ClosestPlayer.Value.Parent and Players:FindFirstChild(zombie.ClosestPlayer.Value.Parent.Name) then
											ZombieJump:FireClient(Players[zombie.ClosestPlayer.Value.Parent.Name], zombie.Index.Value)
										end
									end
								end
							end

							--while waypoints[nextWaypointIndex].Action == Enum.PathWaypointAction.Jump do
							--	nextWaypointIndex += 1
							--end

							if waypoints and waypoints[nextWaypointIndex - 1] and waypoints[nextWaypointIndex] then
								local previousWaypointPosition : Vector3 = waypoints[nextWaypointIndex - 1].Position
								local currentWaypointPosition : Vector3 = waypoints[nextWaypointIndex].Position

								if zombie.Parent then
									local zombieHitBoxSize : number = zombie.PrimaryPart.Size.Y / 2

									local tween : Tween = TweenService:Create(
										zombie.PrimaryPart,

										TweenInfo.new(
											(currentWaypointPosition - previousWaypointPosition).Magnitude / 16,
											Enum.EasingStyle.Linear
										),

										{CFrame =
											CFrame.lookAt(
												currentWaypointPosition + Vector3.new(0, zombieHitBoxSize, 0),
												currentWaypointPosition + (currentWaypointPosition - previousWaypointPosition).Unit + Vector3.new(0, zombieHitBoxSize, 0))									}
									)
									tween:Play()

									-- fired when next waypoint is reached
									--if not reachedConnection then
									--	reachedConnection = tween.Completed:Connect(function(reached)
									--		if reached and nextWaypointIndex < #waypoints then

									--			--if waypoints[nextWaypointIndex].Action == Enum.PathWaypointAction.Jump then
									--			--	zombie.Humanoid.Jump = true
									--			--end

									--			nextWaypointIndex += 1

									--			-- part gets stuck on jump because the points have the same position, thus the tween completed event nevers fires since the part is already there
									--			while nextWaypointIndex < #waypoints and waypoints[nextWaypointIndex - 1].Position == waypoints[nextWaypointIndex].Position do
									--				nextWaypointIndex += 1
									--			end

									--			tween = TweenService:Create(zombie.PrimaryPart, TweenInfo.new((waypoints[nextWaypointIndex].Position - waypoints[nextWaypointIndex - 1].Position).Magnitude / 16, Enum.EasingStyle.Linear), {Position = waypoints[nextWaypointIndex].Position})
									--			tween:Play()
									--		else
									--			reachedConnection:Disconnect()
									--		end
									--	end)
									--end

									nextWaypointIndex = 2

									--coroutine.wrap(function()
									--	for i = 3,#waypoints do
									--		local v = waypoints[i]
									--		--if (v and v.Action == Enum.PathWaypointAction.Jump) then
									--		--	zombie.Humanoid.Jump = true
									--		--end

									--		local tween : Tween = TweenService:Create(zombie.PrimaryPart, TweenInfo.new((closestPlayer.Position - zombie.PrimaryPart.Position).Magnitude / 16, Enum.EasingStyle.Linear), {Position = v.Position})
									--		tween:Play()

									--		local reached = WaitEvent(tween.Completed,1)
									--		--if (not reached) then
									--		--	zombie.Humanoid.Jump = true
									--		--	break
									--		--end

									--		if (CheckSight(zombie.PrimaryPart.Position, closestPlayer.Position)) then
									--			TweenService:Create(zombie.PrimaryPart, TweenInfo.new((closestPlayer.Position - zombie.PrimaryPart.Position).Magnitude / 16, Enum.EasingStyle.Linear), {CFrame = closestPlayer.CFrame}):Play()
									--			break
									--		end

									--		if ((closestPlayer.Position - waypoints[#waypoints].Position).Magnitude >= 40) then

									--			if ((closestPlayer.Position - zombie.PrimaryPart.Position).Magnitude <= 20) then
									--				TweenService:Create(zombie.PrimaryPart, TweenInfo.new((closestPlayer.Position - zombie.PrimaryPart.Position).Magnitude / 16, Enum.EasingStyle.Linear), {CFrame = closestPlayer.CFrame}):Play()

									--			elseif (waypoints[i+1]) then
									--				TweenService:Create(zombie.PrimaryPart, TweenInfo.new((closestPlayer.Position - zombie.PrimaryPart.Position).Magnitude / 16, Enum.EasingStyle.Linear), {Position = waypoints[i+1].Position}):Play()
									--			end

									--			break
									--		end
									--	end
									--end)()
								end
							end
						end
					end

					-- damage the player if they are close enough
					if math.abs((closestPlayerPosition - zombiePosition).Magnitude) <= 2.5 then

						-- if the zombie is not a boom zombie, attack player, otherwise explode
						if zombie.Name ~= "BoomZombie" then

							-- if the zombie is not in cooldown
							if zombie:FindFirstChild("LastHit") then
								if tick() > (zombie.LastHit.Value + zombie:GetAttribute("AttackSpeed")) then
									zombie.LastHit.Value = tick()
									PlayersModuleScript:TakeDamage(Players:GetPlayerFromCharacter(zombie.ClosestPlayer.Value.Parent), zombie:GetAttribute("Damage"))

									-- player catches on fire if hit by a fire zombie
									if zombie.Name == "FireZombie" then

										-- if the player is not already on fire
										if not PlayersModuleScript:IsOnFire(Players:GetPlayerFromCharacter(zombie.ClosestPlayer.Value.Parent)) then
											-- put him on fire
											PlayersModuleScript:OnFire(Players:GetPlayerFromCharacter(zombie.ClosestPlayer.Value.Parent))
										end

									elseif zombie.Name == "PoisonZombie" then

										-- if the player is not already poisonned
										if not PlayersModuleScript:IsPoisonned(Players:GetPlayerFromCharacter(zombie.ClosestPlayer.Value.Parent)) then
											-- poison him
											PlayersModuleScript:Poison(Players:GetPlayerFromCharacter(zombie.ClosestPlayer.Value.Parent))
										end

									elseif zombie.Name == "IceZombie" then

										-- if the player is not already frozen
										if not PlayersModuleScript:IsFrozen(Players:GetPlayerFromCharacter(zombie.ClosestPlayer.Value.Parent)) then
											-- freeze him
											PlayersModuleScript:Freeze(Players:GetPlayerFromCharacter(zombie.ClosestPlayer.Value.Parent))
										end
									end
								end
							end

						else
							-- create the explosion
							local explosion : Explosion = Instance.new("Explosion")
							explosion.BlastRadius = 10
							explosion.BlastPressure = 0
							explosion.ExplosionType = Enum.ExplosionType.NoCraters
							explosion.DestroyJointRadiusPercent = 0
							explosion.Position = zombie.PrimaryPart.Position

							-- kill the zombie
							Zombies:TakeDamage(zombie, math.huge)

							-- if the explosion hits a player, damage him
							explosion.Hit:Connect(function(part, distance)
								if part.Name == "Head" and part.Parent:IsA("Model") and Players:GetPlayerFromCharacter(part.Parent) then
									PlayersModuleScript:TakeDamage(Players:GetPlayerFromCharacter(part.Parent), 25)
								end
							end)

							Debris:AddItem(explosion, 4)
							explosion.Parent = workspace
						end
					end
				end
			end

			RunService.Heartbeat:Wait()
		end
	end)()
end)