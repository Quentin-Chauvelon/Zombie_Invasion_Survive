local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local zombiePet : Model = ServerStorage:WaitForChild("ZombiePet")
local RandomRoleBindableEvent = ServerStorage:WaitForChild("RandomRole")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CountdownRemoteEvent = ReplicatedStorage:WaitForChild("Countdown")
local RoundInformationRemoteEvent = ReplicatedStorage:WaitForChild("RoundInformation")
local AddWeaponToBackpackRemoteEvent = ReplicatedStorage:WaitForChild("AddWeaponToBackpack")
local CancelCooldownRemoteEvent = ReplicatedStorage:WaitForChild("CancelCooldown")
local RoleConfirmationRemoteEvent = ReplicatedStorage:WaitForChild("RoleConfirmation")
local EnableMouseRemoteEvent = ReplicatedStorage:WaitForChild("EnableMouse")
local StartPackRemoteEvent = ReplicatedStorage:WaitForChild("StarterPack")

local Utilities = require(ServerScriptService:WaitForChild("Utilities"))
local Weapons = require(ServerScriptService:WaitForChild("Weapons"))
local Zombies = require(ServerScriptService:WaitForChild("Zombies"))
local Rounds = require(ServerScriptService:WaitForChild("Rounds"))
local PlayersModuleScript = require(ServerScriptService:WaitForChild("Players"))

local countdown : boolean = false
local timeLeft : number = 60

local doors : Folder = workspace.Doors
local lockedZones : Folder = workspace.LockedZones
local antiCheatLockedZones : Folder = workspace.AntiCheatLockedZones
local pistolStats : Model = workspace.WeaponGivers.Pistol
local teamMachinePlayers : Folder = workspace:WaitForChild("Machines"):WaitForChild("TeamMachine"):WaitForChild("TeamMachine"):WaitForChild("Players")
local possibleSpawners : Folder = workspace:WaitForChild("PossibleSpawners")
local unlockedSpawners : Folder = workspace:WaitForChild("UnlockedSpawners")

local oneAndAHalfCoinsMultiplierPassId : number = 86193283
local doubleCoinsMultiplierPassId : number = 86193694
local tripleCoinsMultiplierPassId : number = 86194025
local titlePassId : number = 86188278
--local weaponsSkinsPassId: number = 0
--local sparklesSkinsPassId: number = 0
--local hitHighlightColorSkinsPassId: number = 0
--local ZombieSkinsPassId: number = 0
local zombiePetPassId: number = 86190437
local basicStarterPackPassId : number = 86191125
local proStarterPackPassId : number = 86191507
local undeadStarterPackPassId : number = 86191967
local ultimateStarterPackPassId : number = 86192698

local data

local PlayerRequired = 1
 --TODO: delete
--PlayerRequired = 1
--ReplicatedStorage:WaitForChild("NumberOfPlayers").Value = PlayerRequired

-- define the type tab as table of strings
type tab = {string}


-- deletes a door when a zone is unlocked + delete the anti-cheat touch detection part
local function DeleteDoor(v : Part, zone : string)
	v:Destroy()

	if antiCheatLockedZones:FindFirstChild(zone) then
		antiCheatLockedZones[zone]:Destroy()
	end
end


local function AddPetToPlayer(plr : Player)
	local character : Model = workspace:WaitForChild(plr.Name)

	local pet = zombiePet:Clone()
	pet:PivotTo(character:WaitForChild("HumanoidRootPart").CFrame)

	local modelSize : Vector3 = pet.PetSize.Size

	local characterAttachment : Attachment = Instance.new("Attachment")
	characterAttachment.Position = Vector3.new(2,1,0) * modelSize
	characterAttachment.Parent = character.HumanoidRootPart

	local petAttachment : Attachment = Instance.new("Attachment")
	petAttachment.Parent = pet.PrimaryPart

	local alignPosition : AlignPosition = Instance.new("AlignPosition")
	alignPosition.Attachment0 = petAttachment
	alignPosition.Attachment1 = characterAttachment
	alignPosition.MaxForce = 25000
	alignPosition.Responsiveness = 25
	alignPosition.Parent = pet.PrimaryPart

	local alignOrientation : AlignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = petAttachment
	alignOrientation.Attachment1 = characterAttachment
	alignOrientation.MaxTorque = 50000
	alignOrientation.Responsiveness = 15
	alignOrientation.Parent = pet.PrimaryPart

	pet.Parent = character
end


local function EnableGamepasses(plr : Player)
	
	-- check if the player owns the game pass
	local success, tripleCoinsMultiplierPass : boolean = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(plr.UserId, tripleCoinsMultiplierPassId)
	end)

	if success and tripleCoinsMultiplierPass then
		plr:WaitForChild("Stats"):WaitForChild("CoinsMultiplier").Value = 3
		
		
	else
		-- check if the player owns the game pass
		local success, doubleCoinsMultiplierPass : boolean = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(plr.UserId, doubleCoinsMultiplierPassId)
		end)

		if success and doubleCoinsMultiplierPass then
			plr:WaitForChild("Stats"):WaitForChild("CoinsMultiplier").Value = 2
			
			
		else
			-- check if the player owns the game pass
			local success, oneAndAHalfCoinsMultiplierPass : boolean = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(plr.UserId, oneAndAHalfCoinsMultiplierPassId)
			end)

			if success and oneAndAHalfCoinsMultiplierPass then
				plr:WaitForChild("Stats"):WaitForChild("CoinsMultiplier").Value = 1.5
			end
		end
	end
	
	
	-- check if the player owns the game pass
	local success, zombiePetPass : boolean = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(plr.UserId, zombiePetPassId)
	end)

	if success and zombiePetPass then
		AddPetToPlayer(plr)
	end
	
	
	-- check if the player owns the game pass
	local success, ultimateStarterPackPass : boolean = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(plr.UserId, ultimateStarterPackPassId)
	end)

	if success and ultimateStarterPackPass then
		plr:WaitForChild("Stats"):WaitForChild("Defense"):WaitForChild("Helmet").Value = 0.12
		plr.Stats.Defense:WaitForChild("Chestplate").Value = 0.16
		plr.Stats.Defense:WaitForChild("Pants").Value = 0.08
		plr.Stats.Defense:WaitForChild("Boots").Value = 0.04
		plr.Stats.TotalDefense.Value = 0.4
		
		StartPackRemoteEvent:FireClient(plr, "ultimate")
		

	else
		-- check if the player owns the game pass
		local success, undeadStarterPackPass : boolean = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(plr.UserId, undeadStarterPackPassId)
		end)
		
		if success and undeadStarterPackPass then
			plr:WaitForChild("Stats"):WaitForChild("Defense"):WaitForChild("Helmet").Value = 0.09
			plr.Stats.Defense:WaitForChild("Chestplate").Value = 0.12
			plr.Stats.Defense:WaitForChild("Pants").Value = 0.06
			plr.Stats.Defense:WaitForChild("Boots").Value = 0.03
			plr.Stats.TotalDefense.Value = 0.3

			StartPackRemoteEvent:FireClient(plr, "undead")


		else
			-- check if the player owns the game pass
			local success, proStarterPackPass : boolean = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(plr.UserId, proStarterPackPassId)
			end)

			if success and proStarterPackPass then
				plr:WaitForChild("Stats"):WaitForChild("Defense"):WaitForChild("Helmet").Value = 0.06
				plr.Stats.Defense:WaitForChild("Chestplate").Value = 0.08
				plr.Stats.Defense:WaitForChild("Pants").Value = 0.04
				plr.Stats.Defense:WaitForChild("Boots").Value = 0.02
				plr.Stats.TotalDefense.Value = 0.2

				StartPackRemoteEvent:FireClient(plr, "pro")

			else
				-- check if the player owns the game pass
				local success, basicStarterPackPass : boolean = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(plr.UserId, basicStarterPackPassId)
				end)

				if success and basicStarterPackPass then
					plr:WaitForChild("Stats"):WaitForChild("Defense"):WaitForChild("Helmet").Value = 0.03
					plr.Stats.Defense:WaitForChild("Chestplate").Value = 0.04
					plr.Stats.Defense:WaitForChild("Pants").Value = 0.02
					plr.Stats.Defense:WaitForChild("Boots").Value = 0.01
					plr.Stats.TotalDefense.Value = 0.1

					StartPackRemoteEvent:FireClient(plr, "basic")
				end
			end
		end
	end
end


-- unlocked a zone when the player triggers a proximity prompt
local function UnlockZone(plr : Player, door : Part, zone : string)

	-- if the player isn't down
	if not PlayersModuleScript:IsDown(plr) then

		-- if the zone is not already unlocked
		if not Utilities:IsZoneUnlocked(zone) then

			-- if the player is close to the door
			if plr:DistanceFromCharacter(door[zone].Position) < 10 then

				if door[zone]:FindFirstChild("Price") then
					-- if the player has enough coins to unlock the zone
					if Utilities:PlayerHasEnoughCoins(plr, door[zone].Price.Value) then

						-- remove the coins from the player
						if Utilities:RemoveCoins(plr, door[zone].Price.Value) then

							-- iterate through all the doors to delete all the doors of the zone
							for _,v : Part in ipairs(doors:GetChildren()) do

								if v:FindFirstChild("Zone1") then
									-- if the door is only connected to one zone then, if the zone is the same
									-- as the one the player wants to unlock, destroy the door
									if not v:FindFirstChild("Zone2") then
										if v.Zone1.Value == zone then
											DeleteDoor(v, zone)
										end

										-- else if the door is connected to multiple zones, then if one of them is the
										-- zone the player wants to unlock and the other is already unlocked, destroy the door
									else
										-- if a zone is unlocked, delete the proximty prompt but keep the door
										if v:FindFirstChild(zone) then
											v[zone]:Destroy()
										end

										if v.Zone1.Value == zone then
											if Utilities:IsZoneUnlocked(v.Zone2.Value) then
												DeleteDoor(v, zone)
											end

										elseif v.Zone2.Value == zone then
											if Utilities:IsZoneUnlocked(v.Zone1.Value) then
												DeleteDoor(v, zone)
											end
										end
									end
								end
							end

							-- unlock the zone in the locked zones folder
							if lockedZones:FindFirstChild(zone) then
								lockedZones[zone].Value = false
							end
							
							for _,v in ipairs(possibleSpawners:GetChildren()) do
								if v.Name == zone then
									v.Parent = unlockedSpawners
								end
							end

							-- destroy the door
							door:Destroy()
						end
					end
				end
			end
		end
	end
end


local function GiveStarterPackToolToPlayer(plr : Player, weapon : string)
	local toolCloned = Utilities:GiveToolToPlayer(plr, weapon)

	-- If the tool has successfully been cloned and given to the player
	if toolCloned then

		-- add the tool to the player's backpack gui
		AddWeaponToBackpackRemoteEvent:FireClient(plr, weapon)

		-- increase the number of slots already taken by 1
		plr.BackpackSlots.SlotsFull.Value += 1

		local weaponNumber : number = plr.BackpackSlots.SlotsFull.Value
		if plr.BackpackSlots:FindFirstChild("Slot"..weaponNumber) then
			plr.BackpackSlots["Slot"..tostring(weaponNumber)].Value = weapon
		end
	end
end


local function StartGame()
	timeLeft = 10
	
	-- unlock the street zone
	lockedZones.Street.Value = false

	-- show the game gui for all players
	for _, player : Player in ipairs(Players:GetPlayers()) do
		player.PlayerGui:WaitForChild("GameGui").Enabled = true
		
		-- give a pistol to all the players
		local toolCloned = Utilities:GiveToolToPlayer(player, "Pistol")

		-- If the tool has successfully been cloned and given to the player
		if toolCloned then
			--local tool = Weapons.new(pistolStats.Stats.Damage.Value, pistolStats.Stats.Cooldown.Value, pistolStats.Stats.MaxAmmos.Value, pistolStats.Stats.InfiniteAmmos.Value, pistolStats.Stats.Zone.Value)

			--if workspace.WeaponGivers:FindFirstChild(toolCloned.Name) and workspace.WeaponGivers[toolCloned.Name].Stats:FindFirstChild("Melee") then

			--	-- load the animation into the humanoid animator
			--	local Animation = tool:LoadAnimation(player, toolCloned)

			--	if Animation then
			--		-- attack on activated
			--		toolCloned.Activated:Connect(function()
			--			tool:Attack(player, Animation)
			--		end)

			--		-- damage zombie on touched
			--		toolCloned.Body.Touched:Connect(function(hit)
			--			if hit.Name == "Zombie" and hit.Parent.Parent.Name == "Zombies" then
			--				-- if the tool is in cooldown, it means it has been fired recently
			--				tool:DamageHumanoid(player, hit.Parent)
			--			end
			--		end)

			--		-- restart the cooldown on equipped
			--		toolCloned.Equipped:Connect(function()
			--			tool:StartCooldown(player)
			--		end)

			--		-- cancel the cooldown on unequipped
			--		toolCloned.Unequipped:Connect(function()
			--			CancelCooldownRemoteEvent:FireClient(player)
			--		end)
			--	end
			--end
			
			-- add the baseball bat to the player's backpack gui
			AddWeaponToBackpackRemoteEvent:FireAllClients("Pistol")
		end

		-- if the player has a starter pack, give him his weapon
		if player.Stats.TotalDefense.Value == 0.1 then
			GiveStarterPackToolToPlayer(player, "SubMachineGun")

		elseif player.Stats.TotalDefense.Value == 0.2 then
			GiveStarterPackToolToPlayer(player, "Shotgun")

		elseif player.Stats.TotalDefense.Value == 0.3 then
			GiveStarterPackToolToPlayer(player, "Rifle")

		elseif player.Stats.TotalDefense.Value == 0.4 then
			GiveStarterPackToolToPlayer(player, "LaserGun")
		end
	end

	-- change the round and timer texts at the top for all players + start countdown
	RoundInformationRemoteEvent:FireAllClients("Both", "Round 1 starting in : 10", "Kill all the zombies!")
	CountdownRemoteEvent:FireAllClients("Round", "Round 1 starting in : ", timeLeft)

	wait(timeLeft + 2)

	-- change the round and timer texts at the top for all players
	RoundInformationRemoteEvent:FireAllClients("Both", "Round 1", "00 : 00")
	
	Utilities:StartTimer()
	Rounds:StartRound()

	for _,v : Part in ipairs(doors:GetChildren()) do

		if v:FindFirstChild("Zone1") and v:FindFirstChild(v.Zone1.Value) and v[v.Zone1.Value]:FindFirstChild("ProximityPrompt") then
			v[v.Zone1.Value].ProximityPrompt.Triggered:Connect(function(plr)
				UnlockZone(plr, v, v.Zone1.Value)
				-- anticheat for players in locked zones (tp to spawnpoint) (kill player after 3 times doing it)
			end)

		end

		if v:FindFirstChild("Zone2") and v:FindFirstChild(v.Zone2.Value) and v[v.Zone2.Value]:FindFirstChild("ProximityPrompt") then
			v[v.Zone2.Value].ProximityPrompt.Triggered:Connect(function(plr)
				UnlockZone(plr, v, v.Zone2.Value)

				--if not Utilities:IsZoneUnlocked(v.Zone1.Value) then

				--	if plr:DistanceFromCharacter(v.Price.Position) < 10 then

				--		if v.Price:FindFirstChild("Price") then
				--			if Utilities:PlayerHasEnoughCoins(plr, v.Price.Price.Value) then

				--				if Utilities:RemoveCoins(plr, v.Price.Price.Value) then

				--					for _,b in ipairs(doors:GetChildren()) do
				--						if b:FindFirstChild("Zone1") and v:FindFirstChild("Zone1") and b.Zone1.Value == v.Zone1.Value then
				--							b:Destroy()
				--						end

				--						if b:FindFirstChild("Zone2") and v:FindFirstChild("Zone2") and b.Zone2.Value == v.Zone1.Value then
				--							b:Destroy()
				--						end
				--					end

				--					v:Destroy()
				--				end
				--			end
				--		end
				--	end
				--end
			end)
		end
	end
end


local function RoleSelection()
	ServerScriptService.Roles.Disabled = false
	
	
	for _,player : Player in ipairs(Players:GetPlayers()) do
		player.PlayerGui:WaitForChild("Roles"):WaitForChild("Roles").Disabled = false
		EnableMouseRemoteEvent:FireClient(player, true)
	end
	
	local validatedRoleCounter : number = 0
	countdown = true
	
	coroutine.wrap(function()
		for i = 0,30 do
			wait(1)
			timeLeft = i

			if not countdown then
				break
			end
		end
		
		if countdown then
			local rolesTable : tab = {"Healer", "Tank", "Sniper", "Barbarian", "Enchanter"}
			
			for _,v : StringValue in ipairs(ServerStorage.Roles:GetChildren()) do
				
				-- validate the player's role if he has not clicked the start button
				if v.Value ~= "" and Players:FindFirstChild(v.Name) then
					local playerRole : stringv? = Players[v.Name]:FindFirstChild("Role")
						
					if playerRole.Value == "" then
						playerRole.Value = v.Value
					end
				end
				
				-- select a random role for the player if he hasn't chosen any
				if v.Value == "" then
					-- select a random role for the player
					local randomRole : string = rolesTable[math.random(1,5)]
					v.Value = randomRole
					
					if Players:FindFirstChild(v.Name) and Players[v.Name]:FindFirstChild("Role") then
						Players[v.Name].Role.Value = randomRole
					end
					
					RandomRoleBindableEvent:Fire(v.Name, randomRole)
					wait(2)
				end
			end
		end
		
		-- enable the roles use script so that the roles can be used
		ServerScriptService.RolesUse.Disabled = false
		
		-- delete everything that is related to the role selection (except the roles folder in server storage which is destroyed by the RolesUse script)
		RoleConfirmationRemoteEvent:Destroy()
		RandomRoleBindableEvent:Destroy()
		
		if ReplicatedStorage:FindFirstChild("Roles") then
			ReplicatedStorage.Roles:Destroy()
		end
		
		ServerScriptService.Roles:Destroy()

		for _,player : Player in ipairs(Players:GetPlayers()) do
			player.PlayerGui.Roles:Destroy()
			EnableMouseRemoteEvent:FireClient(player, false)
		end

		StartGame()
	end)()
	
	-- player clicks the start button to validate the role he selected
	RoleConfirmationRemoteEvent.OnServerEvent:Connect(function(plr : Player)
		-- if the player hasn't validated his role yet
		if plr:FindFirstChild("Role") and plr.Role.Value == "" then
			
			-- if the role argument is a valid role
			if ServerStorage.Roles:FindFirstChild(plr.Name) and ServerStorage.Roles[plr.Name].Value ~= "" then
				plr.Role.Value = ServerStorage.Roles[plr.Name].Value
				
				-- count the number of players that have validated their roles
				validatedRoleCounter += 1
				
				-- if all the players validated theirs roles, stop the countdown and start the game
				if validatedRoleCounter == #Players:GetPlayers() then
					countdown = false
				end
			end
		end
	end)
end



-- When a player connects, we check to see if all the players are connected, if so we launch the game, otherwise we wait
Players.PlayerAdded:Connect(function(plr)
	
	local joinData = plr:GetJoinData()
	local teleportData
	
	if joinData then
		teleportData = joinData.TeleportData
	end
	
	-- get the number of players and the mode
	if teleportData then
		if not data then
			data = teleportData
			
			PlayerRequired = data.numberOfPlayers
			
			if data.mode == 1 then
				EnableGamepasses(plr)
			
			elseif data.mode == 3 then
				EnableGamepasses(plr)
				ServerStorage:WaitForChild("CanRevive").Value = false
				
			elseif data.mode == 4 then
				ServerStorage:WaitForChild("CanRevive").Value = false
				
			elseif data.mode == 5 then
				
				-- unlock all the zones
				for _,v : BoolValue in ipairs(workspace.LockedZones:GetChildren()) do
					v.Value = false
				end
				
				workspace.Doors:ClearAllChildren()
				
				workspace.AntiCheatLockedZones:ClearAllChildren()
				
				local unlockedSpawners : Folder = workspace.UnlockedSpawners
				for _,v in ipairs(workspace.PossibleSpawners:GetChildren()) do
					v.Parent = unlockedSpawners
				end
			end
			
			if ServerStorage:FindFirstChild("Mode") then
				ServerStorage.Mode.Value = data.mode
			end
			
			if ReplicatedStorage:FindFirstChild("NumberOfPlayers") then
				ReplicatedStorage.NumberOfPlayers.Value = data.numberOfPlayers
			end
		end
	end
	
	plr.CameraMaxZoomDistance = 16
	
	-- change the round and timer texts at the top for all players + start countdown
	RoundInformationRemoteEvent:FireClient(plr, "Both", "Game will start in : "..tostring(timeLeft), "Waiting for all players to join the game : "..tostring(#Players:GetChildren()).. "/"..tostring(PlayerRequired))
	CountdownRemoteEvent:FireClient(plr, "Round", "Game will start in : ", timeLeft)

	-- wait for 60 seconds or that all players join the game
	if not countdown then
		countdown = true

		coroutine.wrap(function()
			for i = 0,60 do
				wait(1)
				timeLeft = i

				if not countdown then
					break
				end
			end
			
			if not plr.Character then
				RoundInformationRemoteEvent:FireAllClients("Round", "Game starting...")
				plr.CharacterAdded:Wait()
			end
			
			RoleSelection()
			
			for _,player : Player in ipairs(Players:GetPlayers()) do
				player.PlayerGui.GameGui.Game.Disabled = false
			end
		end)()
	end

	-- Once all the players are here, stop the timer (which will start the game)
	if #Players:GetChildren() == PlayerRequired then
		countdown = false
	end
	
	for i=1,4 do
		if teamMachinePlayers:FindFirstChild("Player"..tostring(i)) then
			teamMachinePlayers["Player"..tostring(i)].Name = plr.Name
			
			teamMachinePlayers[plr.Name].Light.Color = Color3.new(0,1,0)
			break
		end
	end
end)