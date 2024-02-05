local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuyWeaponRemoteFunction = ReplicatedStorage:WaitForChild("BuyWeapon")
local BuyArmorRemoteFunction = ReplicatedStorage:WaitForChild("BuyArmor")
local UpdateAmmoCount = ReplicatedStorage:WaitForChild("UpdateAmmoCount")
local ResetAmmos = ReplicatedStorage:WaitForChild("ResetAmmos")
local CancelCooldown = ReplicatedStorage:WaitForChild("CancelCooldown")
local AddWeaponToBackpackRemoteEvent = ReplicatedStorage:WaitForChild("AddWeaponToBackpack")

local Utilities = require(ServerScriptService:WaitForChild("Utilities"))
local Weapons = require(ServerScriptService:WaitForChild("Weapons"))
local Zombies = require(ServerScriptService:WaitForChild("Zombies"))
local PlayersModuleScript = require(ServerScriptService:WaitForChild("Players"))


--local function ReloadWeapon(plr : Player, weapon : Tool)
--	if weapon:FindFirstChild("CurrentAmmo") and weapon:FindFirstChild("Configuration") and weapon.Configuration:FindFirstChild("AmmoCapacity") then
--		local ammos : number = weapon.Configuration.AmmoCapacity.Value

--		weapon.CurrentAmmo.Value = ammos

--		-- play animation
--		--local reloadTrackKey = self:getConfigValue("ReloadAnimation", "RifleReload")
--		--if reloadTrackKey then
--		--	self.reloadTrack = self:getAnimTrack(reloadTrackKey)
--		--	if self.reloadTrack then
--		--		self.reloadTrack:Play()
--		--	end
--		--end

--		-- play sound
--		--if weapon:FindFirstChild(weapon.Name) and weapon[weapon.Name]:FindFirstChild(weapon.Name) and weapon[weapon.Name][weapon.Name]:FindFirstChild("Reload") and weapon[weapon.Name][weapon.Name].Reload:IsA("Sound") then
--		--	weapon[weapon.Name][weapon.Name].Reload:Play()
--		--end

--		-- update the number of ammos text gui
--		ResetAmmos:FireClient(plr, ammos)
--		UpdateAmmoCount:FireClient(plr, ammos)
--	end
--end


-- Player triggered the proximity prompt to buy a weapon
BuyWeaponRemoteFunction.OnServerInvoke = function(plr, weapon) : boolean

	-- if the player isn't down
	if not PlayersModuleScript:IsDown(plr) then

		-- If the zone has been unlocked
		if Utilities:IsZoneUnlocked(weapon.Stats.Zone.Value) then

			if plr:DistanceFromCharacter(weapon.Price.Position) < 10 then

				if not Utilities:PlayerAlreadyHasTool(plr, weapon.Name) then

					if Utilities:PlayerHasEnoughCoins(plr, weapon.Stats.Price.Value) then
	
						if Utilities:RemoveCoins(plr, weapon.Stats.Price.Value) then

							local toolCloned = Utilities:GiveToolToPlayer(plr, weapon.Name)

							-- If the tool has successfully been cloned and given to the player
							if toolCloned then
								
								
								-- add the tool to the player's backpack gui
								AddWeaponToBackpackRemoteEvent:FireClient(plr, weapon.Name)
								
								local newWeapon : boolean = false
								
								-- player's backpack slot
								if weapon.Name == "Sword" then
									for _,v : StringValue | IntValue in ipairs(plr.BackpackSlots:GetChildren()) do
										if v.Value == "BaseballBat" then
											v.Value = "Sword"
											newWeapon = true
										end
									end
									
									-- if the player bought the sword and doesn't have the baseball bat, give it to them
									if not Utilities:PlayerAlreadyHasTool(plr, "BaseballBat") then
										ServerStorage.Tools.BaseballBat:Clone().Parent = plr.Backpack
									end
									
								elseif weapon.Name == "Revolver" then
									for _,v : StringValue | IntValue in ipairs(plr.BackpackSlots:GetChildren()) do
										if v.Value == "Pistol" then
											v.Value = "Revolver"
											newWeapon = true
										end
									end
									
									-- if the player bought the revolver and doesn't have the pistol, give it to them
									if not Utilities:PlayerAlreadyHasTool(plr, "Pistol") then
										ServerStorage.Tools.Pistol:Clone().Parent = plr.Backpack
									end
									
								elseif weapon.Name == "Rifle" then
									for _,v : StringValue | IntValue in ipairs(plr.BackpackSlots:GetChildren()) do
										if v.Value == "SubMachineGun" then
											v.Value = "Rifle"
											newWeapon = true
										end
									end
									
									-- if the player bought the rifle and doesn't have the submachine gun, give it to them
									if not Utilities:PlayerAlreadyHasTool(plr, "SubMachineGun") then
										ServerStorage.Tools.SubMachineGun:Clone().Parent = plr.Backpack
									end
								end

								if not newWeapon then
									-- increase the number of slots already taken by 1
									plr.BackpackSlots.SlotsFull.Value += 1

									local weaponNumber : number = plr.BackpackSlots.SlotsFull.Value
									if plr.BackpackSlots:FindFirstChild("Slot"..weaponNumber) then
										plr.BackpackSlots["Slot"..tostring(weaponNumber)].Value = weapon.Name
									end
								end
								
								
								if workspace.WeaponGivers[toolCloned.Name].Stats.Melee.Value then
									local tool = Weapons.new(weapon.Stats.Damage.Value, weapon.Stats.Cooldown.Value, weapon.Stats.MaxAmmos.Value, weapon.Stats.InfiniteAmmos.Value, weapon.Stats.Zone.Value)

									if workspace.WeaponGivers:FindFirstChild(toolCloned.Name) and workspace.WeaponGivers[toolCloned.Name].Stats:FindFirstChild("Melee") then

										-- load the animation into the humanoid animator
										local Animation = tool:LoadAnimation(plr, toolCloned)

										if Animation then
											-- attack on activated
											toolCloned.Activated:Connect(function()
												tool:Attack(plr, Animation)
											end)

											-- damage zombie on touched
											toolCloned.Body.Touched:Connect(function(hit)
												if hit.Name == "Zombie" and hit.Parent.Parent.Name == "Zombies" then											
													-- if the tool is in cooldown, it means it has been fired recently
													tool:DamageHumanoid(plr, hit.Parent)
												end
											end)

											-- restart the cooldown on equipped
											toolCloned.Equipped:Connect(function()
												tool:StartCooldown(plr)
											end)

											-- cancel the cooldown on unequipped
											toolCloned.Unequipped:Connect(function()
												CancelCooldown:FireClient(plr)
											end)

											return true
										end
									end

								else
									return true
								end
							end
						end
					end

				else
					if Utilities:PlayerHasEnoughCoins(plr, math.floor(weapon.Stats.Price.Value / 10)) then

						if Utilities:RemoveCoins(plr, math.floor(weapon.Stats.Price.Value / 10)) then

							-- reload weapon
							if plr.Character and plr.Character:FindFirstChild(weapon.Name) then
								Weapons:ReloadWeapon(plr, plr.Character[weapon.Name])
							end
						end
					end
				end
			end
		end
	end

	return false
end


-- Player triggered the proximity prompt to buy a piece of armor
BuyArmorRemoteFunction.OnServerInvoke = function(plr, armor) : boolean

	-- if the player isn't down
	if not PlayersModuleScript:IsDown(plr) then

		-- If the zone has been unlocked
		if Utilities:IsZoneUnlocked(armor.Stats.Zone.Value) then

			if plr:DistanceFromCharacter(armor.Price.Position) < 10 then

				if not Utilities:PlayerAlreadyHasArmor(plr, armor.Stats.Piece.Value, armor.Stats.Defense.Value) then

					if Utilities:PlayerHasEnoughCoins(plr, armor.Stats.Price.Value) then

						if Utilities:RemoveCoins(plr, armor.Stats.Price.Value) then

							Utilities:GiveArmorToPlayer(plr, armor.Stats.Piece.Value, armor.Stats.Defense.Value)
							return true
						end
					end
				end
			end
		end
	end

	return false
end


-- TODO: gamepasses id + images
-- TODO: roles abilities uis

-- TODO: anticheat

-- can't reload weapon (no ammo left) : BulletWeapon:119, BulletWeapon:903, BaseWeapon:99 and BaseWeapon:336 (search :reload()
-- fix camera : ShoulderCamera:252 (currentRootPart instead of currentHumanoid)
-- damage uncollidable zombies : Parabola:117 and Roblox:364

-- fonts for the numbers on the hearths of the health machine (I, II, III...) :
-- cartoon
-- merriweather

-- to add a new weapon, execute the following line in the command bar (change the location of the weapon to point to the tool game.ServerStorage.Tools.TheTool):
 --game:GetService("CollectionService"):AddTag(game.ServerStorage.Tools.LaserGun, "WeaponsSystemWeapon")
-- set the model's primary part to the part that has all the attachments, effects...