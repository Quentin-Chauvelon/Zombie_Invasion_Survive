local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoleActivatedRemoteEvent = ReplicatedStorage:WaitForChild("RoleActivated")
local UpdateHealthRemoteEvent = ReplicatedStorage:WaitForChild("UpdateHealth")

local rolesAbilities : Folder = ServerStorage:WaitForChild("RolesAbilities")

-- define the type tab as a table of string
type tab = {string}

local abilities : tab = {"Fire", "Poison", "Ice"}


-- get the number of players with the given role
local function GetNumberOfPlayersWithRole(role : string) : number
	local counter : number = 0 

	for _,v : StringValue in ipairs(ServerStorage.Roles:GetChildren()) do
		if v.Value == role then
			counter += 1
		end
	end

	return counter
end


-- enable the temporary abilities
for _,v : IntValue | NumberValue in ipairs(ServerStorage.RolesAbilities:GetChildren()) do

	-- tank ability is only activated on click
	local numberOfPlayersWithRole : number = GetNumberOfPlayersWithRole(v.Name)

	if numberOfPlayersWithRole > 0 then

		if v.Name == "Healer" then
			v.Value = 100 / numberOfPlayersWithRole
		elseif v.Name == "Tank" then
			v.Value = (110 - 20 * numberOfPlayersWithRole) / 100
		elseif v.Name == "Sniper" then
			v.Value = (5 - 1 * numberOfPlayersWithRole) / 100
		elseif v.Name == "Barbarian" then
			v.Value = (12 - 2 * numberOfPlayersWithRole) / 100
		elseif v.Name == "Enchanter" then
			v.Value = 1 - (60 - 10 * numberOfPlayersWithRole) / 100
		end
	end
end

-- destroy the roles folder in server storage as it's not needed anymore
ServerStorage.Roles:Destroy()


-- enable the permanenent abilities for the player
for _,player : Player in ipairs(Players:GetPlayers()) do
	if player:FindFirstChild("Role") then

		if player.Role.Value == "Tank" then
			player.Stats.MaxHealth.Value = 200
			player.Stats.Health.Value = 200
			UpdateHealthRemoteEvent:FireAllClients(player)
			
		elseif player.Role.Value == "Sniper" then
			player.Roles.Sniper.Value = 1.15
		elseif player.Role.Value == "Barbarian" then
			player.Roles.Barbarian.Value = 1.3
		end
	end
end


-- player clicked a role to activate it
RoleActivatedRemoteEvent.OnServerEvent:Connect(function(plr : Player, ability : number)
	if ability and typeof(ability) == "number" then

		if ability == 1 and not plr.Ability1Used.Value then
			plr.Ability1Used.Value = true
			
			-- heal all players
			if plr.Role.Value == "Healer" then
				for _,player : Player in ipairs(Players:GetPlayers()) do
					
					-- if the player has less health missing than the amount of health he should get from the ability, set it health to max
					if player.Stats.MaxHealth.Value - player.Stats.Health.Value < rolesAbilities.Healer.Value then
						player.Stats.Health.Value = player.Stats.MaxHealth.Value
					else
						player.Stats.Health.Value += rolesAbilities.Healer.Value
						
					end
					
					UpdateHealthRemoteEvent:FireAllClients(player)
				end
				
				RoleActivatedRemoteEvent:FireAllClients(plr, "Healer", rolesAbilities.Healer.Value)
				
				
			-- add a random ability to the player's weapon
			elseif plr.Role.Value == "Enchanter" then
				local randomAbility : string = abilities[math.random(1,3)]

				if randomAbility and plr.Weapons:FindFirstChild(randomAbility.."Ability") and not plr.Weapons[randomAbility.."Ability"].Value then
					plr.Weapons[randomAbility.."Ability"].Value = true
					
					-- set the ability value back to its original value
					coroutine.wrap(function()
						wait(10)
						plr.Weapons[randomAbility.."Ability"].Value = false
					end)()
				end
			end

		elseif ability == 2 and not plr.Ability2Used.Value then
			plr.Ability2Used.Value = true

			-- regeneration
			if plr.Role.Value == "Healer" then

				coroutine.wrap(function()
					local health : NumberValue = plr.Stats.Health
					local maxHealth : NumberValue = plr.Stats.MaxHealth
					
					for i=1,10 do
						
						-- regenerate the player
						if health.Value < maxHealth.Value - 10 then
							health.Value += 10
						else
							health.Value = maxHealth.Value
						end
						
						UpdateHealthRemoteEvent:FireAllClients(plr)

						wait(1)
					end
				end)()
				
				
			-- add defense to the player's total defense value (used for armors)
			elseif plr.Role.Value == "Tank" then
				for _,player : Player in ipairs(Players:GetPlayers()) do
					player.Stats.TotalDefense.Value += rolesAbilities.Tank.Value
				end
				
				-- wait 10 seconds before setting the value back to its original value
				coroutine.wrap(function()
					wait(10)
					for _,player : Player in ipairs(Players:GetPlayers()) do
						player.Stats.TotalDefense.Value -= rolesAbilities.Tank.Value
					end
				end)()
				
				RoleActivatedRemoteEvent:FireAllClients(plr, "Tank", rolesAbilities.Tank.Value * 100)
				
				
			-- increase the ranged weapon damage
			elseif plr.Role.Value == "Sniper" then
				for _,player : Player in ipairs(Players:GetPlayers()) do
					player.Roles.Sniper.Value += rolesAbilities.Sniper.Value
				end

				-- set the sniper value back to its original value
				coroutine.wrap(function()
					wait(10)
					for _,player : Player in ipairs(Players:GetPlayers()) do
						player.Roles.Sniper.Value -= rolesAbilities.Sniper.Value
					end
				end)()
				
				RoleActivatedRemoteEvent:FireAllClients(plr, "Sniper", rolesAbilities.Sniper.Value * 100)
				
				
			-- increase the melee weapon damage
			elseif plr.Role.Value == "Barbarian" then
				for _,player : Player in ipairs(Players:GetPlayers()) do
					player.Roles.Barbarian.Value += rolesAbilities.Barbarian.Value
				end

				-- set the sniper value back to its original value
				coroutine.wrap(function()
					wait(10)
					for _,player : Player in ipairs(Players:GetPlayers()) do
						player.Roles.Barbarian.Value -= rolesAbilities.Barbarian.Value
					end
				end)()
				
				RoleActivatedRemoteEvent:FireAllClients(plr, "Barbarian", rolesAbilities.Barbarian.Value * 100)
			
				
			-- decrease the zombies abilities damage
			elseif plr.Role.Value == "Enchanter" then
				for _,player : Player in ipairs(Players:GetPlayers()) do
					player.Roles.Enchanter.Value = rolesAbilities.Enchanter.Value
				end

				-- set the enchanter value back to its original value
				coroutine.wrap(function()
					wait(10)
					for _,player : Player in ipairs(Players:GetPlayers()) do
						player.Roles.Enchanter.Value = 1
					end
				end)()
				
				RoleActivatedRemoteEvent:FireAllClients(plr, "Enchanter", rolesAbilities.Enchanter.Value * 100)
			end
		end
	end
end)