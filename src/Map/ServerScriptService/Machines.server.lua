local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MachineRemoteFunction = ReplicatedStorage:WaitForChild("Machines")
local UpdateHealth = ReplicatedStorage:WaitForChild("UpdateHealth")

local Utilities = require(ServerScriptService:WaitForChild("Utilities"))
local PlayersModuleScript = require(ServerScriptService:WaitForChild("Players"))
local Weapons = require(ServerScriptService:WaitForChild("Weapons"))
local Rounds = require(ServerScriptService:WaitForChild("Rounds"))

local machines : Folder = workspace:WaitForChild("Machines")

local healthMachinePrice : number = 150
local perksMachinePrice : number = 200
local weaponModifiersMachinePrice : number = 300
local weaponEffectsMachinePrice : number = 2500


MachineRemoteFunction.OnServerInvoke = function(plr : Player, machine : string, param1 : number | string) : boolean
	if plr and machine and typeof(machine) == "string" then

		-- if the player isn't down
		if not PlayersModuleScript:IsDown(plr) then

			if machine == "Health" then
				local level = param1
				if level and typeof(level) == "number" then

					-- If the zone has been unlocked
					if Utilities:IsZoneUnlocked("House") then

						-- if the player is less than 12 studs away from the health machine
						if plr:DistanceFromCharacter(machines.HealthMachine.ProximityPrompt.Position) < 12 then
							
							-- you can't buy health after round 30, since it decreases from that point on
							if Rounds:GetRound() <= 30 then

								-- if the player is not trying to buy a lower health level than he already has
								if plr:FindFirstChild("Machines") and plr.Machines:FindFirstChild("HealthMachine") then
									local healthLevel : IntValue = plr.Machines.HealthMachine

									if level > healthLevel.Value then

										--local price : IntValue = machines.HealthMachine.Prices:FindFirstChild("Level"..tostring(level))
										--if price then

										-- if the player has enough coins							
										if Utilities:PlayerHasEnoughCoins(plr, healthMachinePrice) then

											-- remove the coins from the player
											if Utilities:RemoveCoins(plr, healthMachinePrice) then

												-- increase the player max health
												if plr:FindFirstChild("Stats") and plr.Stats:FindFirstChild("MaxHealth") then
													plr.Stats.MaxHealth.Value += (level - healthLevel.Value) * 10

													healthLevel.Value = level

													UpdateHealth:FireAllClients(plr)

													return true
												end
											end
										end
										--end
									end
								end
							end
						end
					end
				end

			elseif machine == "Regeneration" then
				local level = param1
				if level and typeof(level) == "number" then

					-- If the zone has been unlocked
					if Utilities:IsZoneUnlocked("Shop") then

						-- if the player is less than 12 studs away from the perks machine
						if plr:DistanceFromCharacter(machines.PerksMachine.ProximityPrompt.Position) < 12 then

							-- if the player is not trying to buy a lower regeneration level than he already has
							if plr:FindFirstChild("Machines") and plr.Machines:FindFirstChild("RegenerationMachine") then
								local regenerationLevel : IntValue = plr.Machines.RegenerationMachine

								if level > regenerationLevel.Value then

									--local price : IntValue = machines.PerksMachine.RegenerationPrices:FindFirstChild("Level"..tostring(level))
									--if price then

									-- if the player has enough coins							
									if Utilities:PlayerHasEnoughCoins(plr, perksMachinePrice) then

										-- remove the coins from the player
										if Utilities:RemoveCoins(plr, perksMachinePrice) then

											-- decrease the player regeneration time
											if plr:FindFirstChild("Stats") and plr.Stats:FindFirstChild("RegenerationTime") then
												plr.Stats.RegenerationTime.Value -= (level - regenerationLevel.Value) * 0.2

												regenerationLevel.Value = level

												return true
											end
										end
									end
									--end
								end
							end
						end
					end
				end

			elseif machine == "Speed" then
				local level : number = param1
				if level and typeof(level) == "number" then

					-- If the zone has been unlocked
					if Utilities:IsZoneUnlocked("Shop") then

						-- if the player is less than 12 studs away from the perks machine
						if plr:DistanceFromCharacter(machines.PerksMachine.ProximityPrompt.Position) < 12 then

							-- if the player is not trying to buy a lower speed level than he already has
							if plr:FindFirstChild("Machines") and plr.Machines:FindFirstChild("SpeedMachine") then
								local speedLevel : IntValue = plr.Machines.SpeedMachine

								if level > speedLevel.Value then

									--local price : IntValue = machines.PerksMachine.SpeedPrices:FindFirstChild("Level"..tostring(level))
									--if price then

									-- if the player has enough coins							
									if Utilities:PlayerHasEnoughCoins(plr, perksMachinePrice) then

										-- remove the coins from the player
										if Utilities:RemoveCoins(plr, perksMachinePrice) then

											-- increase the player speed
											if plr.Character and plr.Character:FindFirstChild("Humanoid") then
												plr.Character.Humanoid.WalkSpeed += (level - speedLevel.Value) * 2

												speedLevel.Value = level

												return true
											end
										end
									end
									--end
								end
							end
						end
					end
				end

			elseif machine == "Jump" then
				local level : number = param1
				if level and typeof(level) == "number" then

					-- If the zone has been unlocked
					if Utilities:IsZoneUnlocked("Shop") then

						-- if the player is less than 12 studs away from the perks machine
						if plr:DistanceFromCharacter(machines.PerksMachine.ProximityPrompt.Position) < 12 then

							-- if the player is not trying to buy a lower jump level than he already has
							if plr:FindFirstChild("Machines") and plr.Machines:FindFirstChild("JumpMachine") then
								local jumpLevel : IntValue = plr.Machines.JumpMachine

								if level > jumpLevel.Value then

									--local price : IntValue = machines.PerksMachine.JumpPrices:FindFirstChild("Level"..tostring(level))
									--if price then

									-- if the player has enough coins							
									if Utilities:PlayerHasEnoughCoins(plr, perksMachinePrice) then

										-- remove the coins from the player
										if Utilities:RemoveCoins(plr, perksMachinePrice) then

											-- increase the player's jump height
											if plr.Character and plr.Character:FindFirstChild("Humanoid") then
												plr.Character.Humanoid.JumpHeight += (level - jumpLevel.Value) * 2.5

												jumpLevel.Value = level

												return true
											end
										end
									end
									--end
								end
							end
						end
					end
				end

			elseif machine == "DamageMultiplier" then
				local level : number = param1
				if level and typeof(level) == "number" then

					-- If the zone has been unlocked
					if Utilities:IsZoneUnlocked("Subway") then

						-- if the player is less than 12 studs away from the weapon modifiers machine
						if plr:DistanceFromCharacter(machines.WeaponModifiersMachine.ProximityPrompt.Position) < 12 then

							-- if the player is not trying to buy a lower damage multiplier level than he already has
							if plr:FindFirstChild("Machines") and plr.Machines:FindFirstChild("DamageMultiplierMachine") then
								local damageMultiplierLevel : IntValue = plr.Machines.DamageMultiplierMachine

								if level > damageMultiplierLevel.Value then

									--local price : IntValue = machines.WeaponModifiersMachine.Prices:FindFirstChild("Level"..tostring(level))
									--if price then

									-- if the player has enough coins							
									if Utilities:PlayerHasEnoughCoins(plr, weaponModifiersMachinePrice) then

										-- remove the coins from the player
										if Utilities:RemoveCoins(plr, weaponModifiersMachinePrice) then

											-- increase the player's damage
											if plr:FindFirstChild("Weapons") and plr.Weapons:FindFirstChild("DamageMultiplier") then
												plr.Weapons.DamageMultiplier.Value += (level - damageMultiplierLevel.Value) * 0.1

												damageMultiplierLevel.Value = level

												return true
											end
										end
									end
									--end
								end
							end
						end
					end
				end

			elseif machine == "WeaponAbilities" then
				local ability : string = param1
				if ability and typeof(ability) == "string" then

					-- If the zone has been unlocked
					if Utilities:IsZoneUnlocked("TrainStation") then

						-- if the player is less than 12 studs away from the weapon abilities machine
						if plr:DistanceFromCharacter(machines.WeaponAbilitiesMachine.ProximityPrompt.Position) < 12 then

							-- if the player is not trying to buy an ability he already has
							if plr:FindFirstChild("Weapons") and plr.Weapons:FindFirstChild(ability.."Ability") and not plr.Weapons[ability.."Ability"].Value then

								--local price : IntValue = machines.WeaponAbilitiesMachine.Prices:FindFirstChild(ability)
								--if price then

								-- if the player has enough coins							
								if Utilities:PlayerHasEnoughCoins(plr, weaponEffectsMachinePrice) then

									-- remove the coins from the player
									if Utilities:RemoveCoins(plr, weaponEffectsMachinePrice) then

										-- enable the ability for the player
										for _,v : BoolValue | NumberValue in ipairs(plr.Weapons:GetChildren()) do
											if v.Name == "FireAbility" or v.Name == "PoisonAbility" or v.Name == "IceAbility" then
												v.Value = false
											end
										end											

										plr.Weapons[ability.."Ability"].Value = true

										return true
									end
								end
								--end
							end
						end
					end
				end
				
			elseif machine == "Team" then
				if param1 and typeof(param1) == "string" then
					
					-- If the zone has been unlocked
					if Utilities:IsZoneUnlocked("Garden") then

						-- if the player is less than 12 studs away from the weapon abilities machine
						if plr:DistanceFromCharacter(machines.TeamMachine.ProximityPrompt.Position) < 12 then

							local price : IntValue = machines.TeamMachine.Prices:FindFirstChild(param1)
							if price then

								-- if the player has enough coins							
								if Utilities:PlayerHasEnoughCoins(plr, price.Value) then

									-- remove the coins from the player
									if Utilities:RemoveCoins(plr, price.Value) then
										
										-- revive all players that are down
										if param1 == "Revive" then
											for _,player : Player in ipairs(Players:GetPlayers()) do
												
												if PlayersModuleScript:IsDown(player) then
													PlayersModuleScript:RevivePlayer(player, nil, workspace.Corpses:FindFirstChild(player.Name))
												end
											end
											
										-- refill all ammos for all players
										elseif param1 == "Ammos" then
											for _,player : Player in ipairs(Players:GetPlayers()) do
												
												-- reload the player's equipped weapon if he has one
												if player.Character and player.Character:FindFirstChildOfClass("Tool") then
													Weapons:ReloadWeapon(player, player.Character:FindFirstChildOfClass("Tool"))
												end
												
												for _,weapon in ipairs(player.Backpack:GetChildren()) do
													Weapons:ReloadWeapon(player, weapon)
												end
											end
											
											
										-- heal all players
										elseif param1 == "Heal" then
											for _,player : Player in ipairs(Players:GetPlayers()) do
												player.Stats.Health.Value = player.Stats.MaxHealth.Value

												UpdateHealth:FireAllClients(player)
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	return false
end