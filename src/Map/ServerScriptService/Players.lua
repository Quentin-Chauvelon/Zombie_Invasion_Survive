local Debris = game:GetService("Debris")
local PlayersList = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SaveDataBindableEvent = ServerStorage:WaitForChild("SaveData")
local LeaderboardBindableEvent = ServerStorage:WaitForChild("Leaderboard")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateHealthRemoteEvent = ReplicatedStorage:WaitForChild("UpdateHealth")
local TeammatesHealthStatusRemoteEvent = ReplicatedStorage:WaitForChild("TeammatesHealthStatus")
local SpectateRemoteEvent = ReplicatedStorage:WaitForChild("Spectate")
local EnableCameraRemoteEvent = ReplicatedStorage:WaitForChild("EnableCamera")
local PlayAgainRemoteEvent = ReplicatedStorage:WaitForChild("PlayAgain")

local canRevive : BoolValue = game:GetService("ServerStorage"):WaitForChild("CanRevive")
local executeOnlyOnce : boolean = false

local corpses : Folder = workspace:WaitForChild("Corpses")
local teamMachinePlayers : Folder = workspace:WaitForChild("Machines"):WaitForChild("TeamMachine"):WaitForChild("TeamMachine"):WaitForChild("Players")

local Utilities = require(ServerScriptService:WaitForChild("Utilities"))

local Players = {}


function Players:RevivePlayer(plr : Player, playerWhoRevived : Player?, character : Model)
	if canRevive.Value and character then
		
		if playerWhoRevived ~= plr then
			if playerWhoRevived and playerWhoRevived:FindFirstChild("Stats") and playerWhoRevived.Stats:FindFirstChild("Revived") then
				playerWhoRevived.GameStats.Revived.Value += 1
			end

			plr.IsDown.Value = false

			-- set the camera back to the player
			SpectateRemoteEvent:FireClient(plr, false)
			EnableCameraRemoteEvent:FireClient(plr, true)

			plr.Character:SetPrimaryPartCFrame(CFrame.new(character.HumanoidRootPart.Position + Vector3.new(0,2,0)))
			--plr.Character.PrimaryPart.Position = character.HumanoidRootPart.Position + Vector3.new(0,2,0)

			character:Destroy()

			if plr:FindFirstChild("Stats") and plr.Stats:FindFirstChild("Health") and plr.Stats:FindFirstChild("MaxHealth") then
				plr.Stats.Health.Value = math.round(plr.Stats.MaxHealth.Value * 0.75)
			end
			
			if teamMachinePlayers:FindFirstChild(plr.Name) then
				teamMachinePlayers[plr.Name].Light.Color = Color3.new(0,1,0)
			end

			TeammatesHealthStatusRemoteEvent:FireAllClients(plr, 0)
		end
	end
end



--[[
Kill the specified player

Params : 
plr : the player that is supposed to die
]]--
function Players:Die(plr : Player)	
	if plr:FindFirstChild("IsAlive") then
		plr.IsAlive.Value = false
	end

	if plr:FindFirstChild("IsDown") then
		plr.IsDown.Value = true
	end

	if corpses:FindFirstChild(plr.Name) then
		corpses[plr.Name]:Destroy()
	end

	-- clear the player's backpack slots, so that he cannot equip weapons anymore
	plr.BackpackSlots:ClearAllChildren()
	
	-- if the save game value is false (the player exploited), don't save the game's stats
	if plr.GameStats.SaveGame.Value then
		SaveDataBindableEvent:Fire(plr)

		-- add the player on the leaderboard eventually
		LeaderboardBindableEvent:Fire(plr)
	end
	
	plr.PlayerGui.Death.Enabled = true
	
	if ReplicatedStorage.NumberOfPlayers.Value == 1 then
		plr.PlayerGui.Death.PlayAgain.Visible = true
	end
	
	if teamMachinePlayers:FindFirstChild(plr.Name) then
		teamMachinePlayers[plr.Name].Light.Color = Color3.new(1,0,0)
	end
	
	TeammatesHealthStatusRemoteEvent:FireAllClients(plr, 2)
end


local function CloneCharacter(character : Model) : Model?
	if character then

		-- allows the player to be cloned
		character.Archivable = true
		local characterClone : Model = character:Clone()
		character.Archivable = false

		characterClone.Parent = corpses
		return characterClone
	end
end


local function RagdollCharacter(character : Model)
	character.Humanoid.BreakJointsOnDeath = false

	if character:FindFirstChildOfClass("Tool") then
		character:FindFirstChildOfClass("Tool"):Destroy()
	end

	character.HumanoidRootPart:SetNetworkOwner(nil)
	character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)

	local d = character:GetDescendants()
	for i=1,#d do
		local desc = d[i]
		if desc:IsA("Motor6D") then
			local socket = Instance.new("BallSocketConstraint")
			local part0 = desc.Part0
			local joint_name = desc.Name
			local attachment0 = desc.Parent:FindFirstChild(joint_name.."Attachment") or desc.Parent:FindFirstChild(joint_name.."RigAttachment")
			local attachment1 = part0:FindFirstChild(joint_name.."Attachment") or part0:FindFirstChild(joint_name.."RigAttachment")
			if attachment0 and attachment1 then
				socket.Attachment0, socket.Attachment1 = attachment0, attachment1
				socket.Parent = desc.Parent
				desc:Destroy()
			end	
		end
	end
end


--[[
The specified player is down

Params : 
plr : the player that is supposed to be down
]]--
function Players:Down(plr : Player)

	-- clone the character
	local character : Model? = CloneCharacter(plr.Character)

	if character then
		-- unequip weapon if the player has one equipped
		if character:FindFirstChildOfClass("Tool") then
			character:FindFirstChildOfClass("Tool").Parent = plr.Backpack
		end

		-- disable the player's camera to spectate on someone else
		EnableCameraRemoteEvent:FireClient(plr, false)

		RagdollCharacter(character)

		-- create the proximity prompt to revive the player
		local reviveProximityPrompt : ProximityPrompt = Instance.new("ProximityPrompt")
		reviveProximityPrompt.ActionText = "Revive player"
		reviveProximityPrompt.HoldDuration = 5
		reviveProximityPrompt.RequiresLineOfSight = false

		reviveProximityPrompt.Triggered:Connect(function(playerWhoRevived : Player)
			self:RevivePlayer(plr, playerWhoRevived, character)
		end)

		-- create the billboard gui
		local billboardGui : BillboardGui = Instance.new("BillboardGui")
		billboardGui.AlwaysOnTop = true
		billboardGui.Size = UDim2.new(0,150,0,35)
		billboardGui.StudsOffset = Vector3.new(0,5,0)

		-- player's name gui
		local playerName : TextLabel = Instance.new("TextLabel")
		playerName.Name = "PlayerName"
		playerName.BackgroundTransparency = 1
		playerName.Size = UDim2.new(1,0,0.5,0)
		playerName.Font = Enum.Font.FredokaOne
		playerName.Text = plr.Name
		playerName.TextColor3 = Color3.fromRGB(58,58,58)
		playerName.TextScaled = true

		-- countdown gui
		local countdown : TextLabel = Instance.new("TextLabel")
		countdown.Name = "Countdown"
		countdown.BackgroundTransparency = 1
		countdown.Position = UDim2.new(0,0,0.5,0)
		countdown.Size = UDim2.new(1,0,0.5,0)
		countdown.Font = Enum.Font.FredokaOne
		countdown.Text = "30"
		countdown.TextColor3 = Color3.new(1,1,1)
		countdown.TextScaled = true

		-- destroy the corpse after 30 seconds
		Debris:AddItem(character, 30)
		
		plr.Character:SetPrimaryPartCFrame(workspace.DownBox.DownPosition.CFrame)

		SpectateRemoteEvent:FireClient(plr, true)

		-- wait 30 seconds before killing the player if he hasn't been revived in the mean time
		coroutine.wrap(function()
			for i=29,0,-1 do

				-- if the player is down, update the countdown
				if self:IsDown(plr) then
					wait(1)
					countdown.Text = i

				else
					return
				end
			end

			if self:IsDown(plr) then
				Players:Die(plr)
			end
		end)()

		reviveProximityPrompt.Parent = character.HumanoidRootPart
		playerName.Parent = billboardGui
		countdown.Parent = billboardGui
		billboardGui.Parent = character.HumanoidRootPart
		
		if teamMachinePlayers:FindFirstChild(plr.Name) then
			teamMachinePlayers[plr.Name].Light.Color = Color3.fromRGB(255,176,0)
		end
		
		TeammatesHealthStatusRemoteEvent:FireAllClients(plr, 1)
	end
end


--[[
Damages the specified player by the specified value

Params : 
plr : the player that is supposed to take damage
value : the amount of damage the player should take
]]--
function Players:TakeDamage(plr : Player, value : number)

	if plr and plr.Character and value then

		local statsFolder : Folder = plr:FindFirstChild("Stats")

		if statsFolder then
			local health : NumberValue = plr.Stats:FindFirstChild("Health")

			if health then

				-- reduce the damage if the player is wearing armor
				value = math.round(value * (1 - plr.Stats.TotalDefense.Value))

				-- if the player has less health than the amount of damage he is suppose to take, then he is down
				if health.Value <= value then
					
					if canRevive.Value then
						if not corpses:FindFirstChild(plr.Name) then

							-- if there is still at least one player that isn't down and is alive, then the player is down
							for _,player : Player in ipairs(PlayersList:GetPlayers()) do
								if player ~= plr and not self:IsDown(player) and self:IsAlive(player) then
									
									if plr:FindFirstChild("Stats") and plr.Stats:FindFirstChild("Deaths") then
										plr.GameStats.Deaths.Value += 1
									end
									
									plr.IsDown.Value = true
									self:Down(plr)
									return
								end
							end
							
							-- end of game
							if not executeOnlyOnce then
								executeOnlyOnce = true
								
								-- stop the timer
								Utilities:PauseTimer()

								for _,player : Player in ipairs(PlayersList:GetPlayers()) do
									self:Down(player)
									self:Die(player)

									local round : number = require(ServerScriptService.Rounds):GetRound()
									local totalTime : number = Utilities:GetTime()

									PlayAgainRemoteEvent:FireClient(player, round, totalTime)							
								end
							end
						end

					else
						self:Die(plr)
					end

				-- otherwise, damage him
				else
					health.Value -= value
					
					-- update the health gui on the client
					UpdateHealthRemoteEvent:FireAllClients(plr)
				end
			end
		end
	end
end


--[[
The player is on fire (a fire zombie hit him)

Params : 
plr : the player that is supposed to be on fire
]]--
function Players:OnFire(plr : Player)

	if plr and plr.Character then
		local humanoid : Humanoid? = plr.Character:FindFirstChild("Humanoid")

		if humanoid then
			local duration : number = 3
			local timeBetweenDamage : number = 0.4
			local reduction : number = plr.Roles.Enchanter.Value
			local damage : number = 2 * reduction

			-- make the player slower by 15%
			local walkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed *= (0.85 * reduction)

			-- add a fire on the player's head
			if plr.Character:FindFirstChild("Head") then
				local fire : Fire = Instance.new("Fire")
				fire.Heat = 1
				fire.Size = 4

				Debris:AddItem(fire, duration)

				fire.Parent = plr.Character.Head
			end

			-- player takes 2 damage every 0.4 seconds for 3 seconds
			coroutine.wrap(function()
				for _ = 1, (duration / timeBetweenDamage) do

					Players:TakeDamage(plr, damage)
					wait(timeBetweenDamage)
				end

				humanoid.WalkSpeed = walkSpeed
			end)()
		end
	end
end


--[[
Check if the specified player is on fire

Params : 
plr : the player that might be on fire

Return :
Boolean? (true if the player has a fire Instance in his head, false or nil otherwise)
]]--
function Players:IsOnFire(plr : Player) : boolean?
	if plr and plr.Character and plr.Character:FindFirstChild("Head") then
		return plr.Character.Head:FindFirstChild("Fire")
	end

	return false
end


--[[
The player is poisonned (a poison zombie hit him)

Params : 
plr : the player that is supposed to be poisonned
]]--
function Players:Poison(plr : Player)

	if plr and plr.Character then
		local humanoid : Humanoid? = plr.Character:FindFirstChild("Humanoid")

		if humanoid then
			local duration :number = 3
			local timeBetweenDamage : number = 0.4
			local reduction : number = plr.Roles.Enchanter.Value
			local damage : number = 4 * reduction

			-- add a particleEmitter on the player's head
			if plr.Character:FindFirstChild("Head") then
				local particleEmitter : ParticleEmitter = Instance.new("ParticleEmitter")
				particleEmitter.Color = ColorSequence.new(Color3.fromRGB(209,41,255))
				particleEmitter.Size = NumberSequence.new(0.6)
				particleEmitter.Lifetime = NumberRange.new(0.5, 0.6)
				particleEmitter.Rate = 20
				particleEmitter.Speed = NumberRange.new(3,3)
				particleEmitter.SpreadAngle = Vector2.new(0, 180)

				Debris:AddItem(particleEmitter, duration)

				particleEmitter.Parent = plr.Character.Head
			end

			-- player takes 4 damage every 0.4 seconds for 3 seconds
			coroutine.wrap(function()
				for _ = 1, (duration / timeBetweenDamage) do

					Players:TakeDamage(plr, damage)
					wait(timeBetweenDamage)
				end
			end)()
		end
	end
end


--[[
Check if the specified player is already poisonned

Params : 
plr : the player that might be on poisonned

Return :
Boolean? (true if the player has a particleEmitter Instance in his head, false or nil otherwise)
]]--
function Players:IsPoisonned(plr : Player) : boolean?
	if plr and plr.Character and plr.Character:FindFirstChild("Head") then
		return plr.Character.Head:FindFirstChild("ParticleEmitter")
	end

	return false
end


--[[
The player is frozen (an ice zombie hit him)

Params : 
plr : the player that is supposed to be frozen
]]--
function Players:Freeze(plr : Player)

	if plr and plr.Character then
		local humanoid : Humanoid? = plr.Character:FindFirstChild("Humanoid")
		local head : Part? = plr.Character:FindFirstChild("Head")

		if humanoid and head then

			-- make the player slower by 30%
			local walkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed *= (0.7 * plr.Roles.Enchanter.Value)

			local headColor : BrickColor = head.BrickColor

			-- turn the player's head to ice
			if plr.Character:FindFirstChild("Head") then
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
Check if the specified player is already frozen

Params : 
plr : the player that might be on frozen

Return :
Boolean (true if the player has an ice head, false otherwise)
]]--
function Players:IsFrozen(plr : Player) : boolean
	if plr and plr.Character and plr.Character:FindFirstChild("Head") then
		return plr.Character.Head.Material == Enum.Material.Ice
	end

	return false
end


--[[
Check if the specified player is down

Params : 
plr : the player that might be down

Return :
Boolean (true if the player is down, false otherwise)
]]--
function Players:IsDown(plr : Player) : boolean
	if plr and plr:FindFirstChild("IsDown") then
		return plr.IsDown.Value
	end

	return false
end


--[[
Check if the specified player is dead

Params : 
plr : the player that might be dead

Return :
Boolean (true if the player is dead, false otherwise)
]]--
function Players:IsAlive(plr : Player) : boolean
	if plr and plr:FindFirstChild("IsAlive") then
		return plr.IsAlive.Value
	end

	return false
end


return Players