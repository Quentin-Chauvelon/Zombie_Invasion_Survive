local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EquipWeaponRemoteEvent = ReplicatedStorage:WaitForChild("EquipWeapon")
local EditWeaponOrderRemoteEvent = ReplicatedStorage:WaitForChild("EditWeaponOrder")


EquipWeaponRemoteEvent.OnServerEvent:Connect(function(plr : Player, weapon : string)
	if plr and plr.Character then
		local equippedWeapon : Tool? = plr.Character:FindFirstChildOfClass("Tool")
		
		-- if the player already has a tool equipped, put it in their backpack
		if equippedWeapon then
			equippedWeapon.Parent = plr.Backpack
		end
		
		-- equip the weapon if it's not the same one as the one the player unequipped
		if not equippedWeapon or equippedWeapon.Name ~= weapon then
			if plr.Backpack:FindFirstChild(weapon) then
				plr.Backpack[weapon].Parent = plr.Character
			end
		end
	end
end)


-- player edited the order of his weapons
EditWeaponOrderRemoteEvent.OnServerEvent:Connect(function(plr : Player, order)
	
	for i : string,v : string in pairs(order) do
		if plr.BackpackSlots:FindFirstChild(i) then
			plr.BackpackSlots[i].Value = v
		end
	end
end)