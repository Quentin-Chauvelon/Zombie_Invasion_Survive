local StarterGui = game:GetService('StarterGui')
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuyWeaponRemoteFunction = ReplicatedStorage:WaitForChild("BuyWeapon")
local BuyArmorRemoteFunction = ReplicatedStorage:WaitForChild("BuyArmor")
local StarterPackRemoteEvent = ReplicatedStorage:WaitForChild("StarterPack")

local bulletToClone : MeshPart = ReplicatedStorage:WaitForChild("Bullet")


-- disable the reset button
for _ = 1,5 do
	local success,_ = pcall(function()
		StarterGui:SetCore("ResetButtonCallback", false)
	end)

	if success then
		break
	end
	
	RunService.Stepped:Wait()
end

local lplr : Player = game.Players.LocalPlayer


local function WeaponSuccesfullyBought(weapon : Model)
	weapon.NeonPart.Color = Color3.new(0,1,0)

	if not weapon.Stats.Melee.Value then

		if weapon:FindFirstChild(weapon.Name) then
			weapon[weapon.Name]:Destroy()

			local bullet : MeshPart = bulletToClone:Clone()
			bullet.Position = weapon.NeonPart.Position + Vector3.new(0,2,0)

			-- move the tip of the bullet above the bullet's body (by adding half the bullet's body size + half the bullet's tip size)
			bullet.Part.Position = bullet.Position + Vector3.new(0, bullet.Size.Z / 2 + bullet.Part.Size.Z / 2, 0)
			bullet.Parent = weapon
		end

		weapon.Price.BillboardGui.WeaponName.Text = weapon.Name.."'s ammos ("..tostring(weapon.Stats.MaxAmmos.Value)..")"
		weapon.Price.BillboardGui.Price.Text = math.floor(weapon.Stats.Price.Value / 10)
		weapon.Price.ProximityPrompt.ObjectText = tostring(math.floor(weapon.Stats.Price.Value / 10))
	end

	-- make the pistol and submachine gun green if the player already has the revolver and rifle
	if weapon.Name == "Revolver" and not lplr.PlayerGui.Backpack.Frame:FindFirstChild("Pistol") then
		workspace.WeaponGivers.Pistol.NeonPart.Color = Color3.new(0,1,0)
		workspace.WeaponGivers.Pistol.Price.BillboardGui.Price.Text = "0"

	elseif weapon.Name == "Rifle" and not lplr.PlayerGui.Backpack.Frame:FindFirstChild("SubMachineGun") then
		workspace.WeaponGivers.SubMachineGun.NeonPart.Color = Color3.new(0,1,0)
		workspace.WeaponGivers.Pistol.Price.BillboardGui.Price.Text = "0"
	end
end


-- Get all the weapons proximity prompt trigerred events to buy weapons
for _,v : Model in ipairs(workspace.WeaponGivers:GetChildren()) do
	
	v.Price.ProximityPrompt.Triggered:Connect(function()
		if BuyWeaponRemoteFunction:InvokeServer(v) then
			WeaponSuccesfullyBought(v)
		end
	end)
end


local function ArmourSuccesfullyBought(armour : Model)
	armour.NeonPart.Color = Color3.new(0,1,0)

	for _,b in ipairs(workspace.ArmorGivers:GetChildren()) do
		if armour.Stats.Piece.Value == b.Stats.Piece.Value then
			if armour.Stats.Defense.Value > b.Stats.Defense.Value then
				b.NeonPart.Color = Color3.new(0,1,0)
			end
		end
	end
end


-- Get all the armors proximity prompt trigerred events to buy a piece of armor
for _,v : Model in ipairs(workspace.ArmorGivers:GetChildren()) do
	
	v.Price.ProximityPrompt.Triggered:Connect(function()
		if BuyArmorRemoteFunction:InvokeServer(v) then
			ArmourSuccesfullyBought(v)
		end
	end)
end


StarterPackRemoteEvent.OnClientEvent:Connect(function(pack : string)
	
	if pack and typeof(pack) == "string" then
		lplr.PlayerGui:WaitForChild("Backpack"):WaitForChild("Frame")
		
		if pack == "basic" then
			WeaponSuccesfullyBought(workspace.WeaponGivers.SubMachineGun)
			ArmourSuccesfullyBought(workspace.ArmorGivers.LeatherHelmet)
			ArmourSuccesfullyBought(workspace.ArmorGivers.LeatherChestplate)
			ArmourSuccesfullyBought(workspace.ArmorGivers.LeatherPants)
			ArmourSuccesfullyBought(workspace.ArmorGivers.LeatherBoots)
			
		elseif pack == "pro" then
			WeaponSuccesfullyBought(workspace.WeaponGivers.Shotgun)
			ArmourSuccesfullyBought(workspace.ArmorGivers.ChainHelmet)
			ArmourSuccesfullyBought(workspace.ArmorGivers.ChainChestplate)
			ArmourSuccesfullyBought(workspace.ArmorGivers.ChainPants)
			ArmourSuccesfullyBought(workspace.ArmorGivers.ChainBoots)
		
		elseif pack == "undead" then
			WeaponSuccesfullyBought(workspace.WeaponGivers.Rifle)
			ArmourSuccesfullyBought(workspace.ArmorGivers.IronHelmet)
			ArmourSuccesfullyBought(workspace.ArmorGivers.IronChestplate)
			ArmourSuccesfullyBought(workspace.ArmorGivers.IronPants)
			ArmourSuccesfullyBought(workspace.ArmorGivers.IronBoots)
		
		elseif pack == "ultimate" then
			WeaponSuccesfullyBought(workspace.WeaponGivers.LaserGun)
			ArmourSuccesfullyBought(workspace.ArmorGivers.DiamondHelmet)
			ArmourSuccesfullyBought(workspace.ArmorGivers.DiamondChestplate)
			ArmourSuccesfullyBought(workspace.ArmorGivers.DiamondPants)
			ArmourSuccesfullyBought(workspace.ArmorGivers.DiamondBoots)
		end
	end
end)