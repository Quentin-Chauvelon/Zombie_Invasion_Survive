local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateAmmoCount = ReplicatedStorage:WaitForChild("UpdateAmmoCount")
local ResetAmmos = ReplicatedStorage:WaitForChild("ResetAmmos")
local UpdateCooldown = ReplicatedStorage:WaitForChild("UpdateCooldown")

local Zombies = require(ServerScriptService:WaitForChild("Zombies"))

local Weapon = {}
Weapon.__index = Weapon

function Weapon.new(damage : number, cooldown : number, maxAmmos : number, infiniteAmmos : boolean, zone : string)
	local newWeapon = {
		Damage = damage or 10,
		Cooldown = cooldown or 1,
		LastAttack = 0,
		MaxAmmos = maxAmmos or 0,
		Ammos = maxAmmos or 0,
		InfiniteAmmos = infiniteAmmos or false,
		Zone = zone or "Street"
	}
	
	return setmetatable(newWeapon, Weapon)
end


function Weapon:ReloadWeapon(plr : Player, weapon : Tool)
	if weapon:FindFirstChild("CurrentAmmo") and weapon:FindFirstChild("Configuration") and weapon.Configuration:FindFirstChild("AmmoCapacity") then
		local ammos : number = weapon.Configuration.AmmoCapacity.Value

		weapon.CurrentAmmo.Value = ammos

		-- play animation
		--local reloadTrackKey = self:getConfigValue("ReloadAnimation", "RifleReload")
		--if reloadTrackKey then
		--	self.reloadTrack = self:getAnimTrack(reloadTrackKey)
		--	if self.reloadTrack then
		--		self.reloadTrack:Play()
		--	end
		--end

		-- play sound
		--if weapon:FindFirstChild(weapon.Name) and weapon[weapon.Name]:FindFirstChild(weapon.Name) and weapon[weapon.Name][weapon.Name]:FindFirstChild("Reload") and weapon[weapon.Name][weapon.Name].Reload:IsA("Sound") then
		--	weapon[weapon.Name][weapon.Name].Reload:Play()
		--end
		
		-- if the player has the weapon equipped, update the amount of ammos text gui
		if weapon.Parent.Name ~= "Backpack" then
			ResetAmmos:FireClient(plr, ammos)
			UpdateAmmoCount:FireClient(plr, ammos)
		end
	end
end


--[[
Attack a zombie

Params :
plr : the player that attacks the zombie
humanoid : the humanoid that should get damaged
]]--
function Weapon:DamageHumanoid(plr : Player, zombie : Model)
	
	-- if the tool is in cooldown, it means it has been fired recently
	--print(tick() - self.LastAttack + self.Cooldown)
	if self:IsInCooldown() then
		Zombies:TakeDamage(zombie, self.Damage * plr.Weapons.DamageMultiplier.Value * plr.Roles.Barbarian.Value, plr)
	end	
end


--[[
Check if the tool is in cooldown

Return :
boolean (true if the weapon is in cooldown, false otherwise)
]]--
function Weapon:IsInCooldown() : boolean
	return (self.LastAttack + self.Cooldown) >= tick()
end


--[[
Starts the cooldown gui on the client
]]--
function Weapon:StartCooldown(plr : Player)
	local cooldownLeft = (self.LastAttack + self.Cooldown) - tick()
	if cooldownLeft > 0 then
		UpdateCooldown:FireClient(plr, cooldownLeft, cooldownLeft / self.Cooldown)
	end
end


--[[
Attacks

Params :
plr : the player that activated the weapon
animation : the weapon's animation to play
]]--
function Weapon:Attack(plr : Player, animation)
	if not self:IsInCooldown() then
		animation:Play()
		self.LastAttack = tick()
		
		UpdateCooldown:FireClient(plr,  self.Cooldown, 1)
	end
end


--[[
Loads an animation into the player's humanoid

Params :
plr : the player that activated the weapon
tool : the tool
]]--
function Weapon:LoadAnimation(plr : Player, tool : Tool)
	if plr.Character and plr.Character:FindFirstChild("Humanoid") then
		if tool:FindFirstChild("Animation") then
			return plr.Character.Humanoid:LoadAnimation(tool.Animation) -- load animation to the player
		end
	end
	
	return nil
end


return Weapon