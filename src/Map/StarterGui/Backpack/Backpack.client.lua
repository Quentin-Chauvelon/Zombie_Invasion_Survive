local StarterGui = game:GetService('StarterGui')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AddWeaponToBackpackRemoteEvent = ReplicatedStorage:WaitForChild("AddWeaponToBackpack")
local EquipWeaponRemoteEvent = ReplicatedStorage:WaitForChild("EquipWeapon")
local EditWeaponOrderRemoteEvent = ReplicatedStorage:WaitForChild("EditWeaponOrder")

local backpackSlots : Folder = game.Players.LocalPlayer:WaitForChild("BackpackSlots")

local backpackGui : Frame = script.Parent:WaitForChild("Frame")
local toolsTemplate : Folder = script.Parent:WaitForChild("Weapons")

local editButton : TextButton = script.Parent:WaitForChild("Edit")
local editBackpack : Frame = script.Parent:WaitForChild("EditBackpack")
local editor : Frame = editBackpack:WaitForChild("Frame")
local editFirstSelect : StringValue = editBackpack:WaitForChild("FirstSelect")


-- disable the default backpack gui
for _ = 1,5 do
	local success,_ = pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)
	
	if success then
		break
	end
	
	RunService.Stepped:Wait()
end


-- inputs to equip and unequip weapons
UserInputService.InputBegan:Connect(function(input : InputObject)
	if input.KeyCode == Enum.KeyCode.One then
		EquipWeaponRemoteEvent:FireServer(backpackSlots.Slot1.Value)
	elseif input.KeyCode == Enum.KeyCode.Two then
		EquipWeaponRemoteEvent:FireServer(backpackSlots.Slot2.Value)
	elseif input.KeyCode == Enum.KeyCode.Three then
		EquipWeaponRemoteEvent:FireServer(backpackSlots.Slot3.Value)
	elseif input.KeyCode == Enum.KeyCode.Four then
		EquipWeaponRemoteEvent:FireServer(backpackSlots.Slot4.Value)
	elseif input.KeyCode == Enum.KeyCode.Five then
		EquipWeaponRemoteEvent:FireServer(backpackSlots.Slot5.Value)
	elseif input.KeyCode == Enum.KeyCode.Six then
		EquipWeaponRemoteEvent:FireServer(backpackSlots.Slot6.Value)
	elseif input.KeyCode == Enum.KeyCode.Seven then
		EquipWeaponRemoteEvent:FireServer(backpackSlots.Slot7.Value)
	elseif input.KeyCode == Enum.KeyCode.Eight then
		EquipWeaponRemoteEvent:FireServer(backpackSlots.Slot8.Value)
	elseif input.KeyCode == Enum.KeyCode.Nine then
		EquipWeaponRemoteEvent:FireServer(backpackSlots.Slot9.Value)
	end
end)



AddWeaponToBackpackRemoteEvent.OnClientEvent:Connect(function(weaponName : string)
	if weaponName and toolsTemplate:FindFirstChild(weaponName) then
		
		local weapon : ImageButton = toolsTemplate[weaponName]:Clone()
		
		local weaponNumber : number = #backpackGui:GetChildren()
		
		if weaponName == "Sword" and backpackGui:FindFirstChild("BaseballBat") then
			weapon.LayoutOrder = backpackGui.BaseballBat.LayoutOrder
			weapon.TextLabel.Text = backpackGui.BaseballBat.LayoutOrder
			backpackGui.BaseballBat:Destroy()
			
		elseif weaponName == "Revolver" and backpackGui:FindFirstChild("Pistol") then
			weapon.LayoutOrder = backpackGui.Pistol.LayoutOrder
			weapon.TextLabel.Text = backpackGui.Pistol.LayoutOrder
			backpackGui.Pistol:Destroy()
			
		elseif weaponName == "Rifle" and backpackGui:FindFirstChild("SubMachineGun") then
			weapon.LayoutOrder = backpackGui.SubMachineGun.LayoutOrder
			weapon.TextLabel.Text = backpackGui.SubMachineGun.LayoutOrder
			backpackGui.SubMachineGun:Destroy()
			
		else
			weapon.LayoutOrder = weaponNumber
			weapon.TextLabel.Text = weaponNumber
		end
		
		-- on weapon clicked
		weapon.MouseButton1Down:Connect(function()
			if backpackSlots:FindFirstChild("Slot"..tostring(weapon.LayoutOrder)) then
				EquipWeaponRemoteEvent:FireServer(backpackSlots["Slot"..tostring(weapon.LayoutOrder)].Value)
			end
		end)
		
		weapon.Visible = true
		weapon.Parent = backpackGui
	end
end)


editButton.MouseButton1Down:Connect(function()
	if not editBackpack.Visible then
		editBackpack.Visible = true
		
		for _,v : ImageButton | UIListLayout in ipairs(backpackGui:GetChildren()) do
			if v:IsA("ImageButton") then
				
				local weaponClone : ImageButton = v:Clone()
				weaponClone.Size = UDim2.new(0.08,0,1,0)
				
				-- when a weapon is clicked, swap it with another one
				weaponClone.MouseButton1Down:Connect(function()
					
					-- if the player hasn't clicked any weapon yet, store the first one clicked and make it bigger to highlight it
					if editFirstSelect.Value == "" then
						editFirstSelect.Value = weaponClone.Name
						weaponClone.Size = UDim2.new(0.1,0,1,0)
						
					-- else if the player already clicked a weapon, swap them
					else
						-- if the player clicked the same weapon twice, unselect it
						if editFirstSelect.Value == weaponClone.Name then
							editFirstSelect.Value = ""
							weaponClone.Size = UDim2.new(0.08,0,1,0)
							
						-- else if the player clicked another weapon, swap them
						else
							local weaponToSwap : ImageButton? = editor:FindFirstChild(editFirstSelect.Value)
							
							if weaponToSwap then
								weaponToSwap.LayoutOrder, weaponClone.LayoutOrder = weaponClone.LayoutOrder, weaponToSwap.LayoutOrder
								weaponToSwap.TextLabel.Text, weaponClone.TextLabel.Text = weaponClone.TextLabel.Text, weaponToSwap.TextLabel.Text
								
								weaponToSwap.Size = UDim2.new(0.08,0,1,0)
								editFirstSelect.Value = ""
							end
						end
					end
				end)
				
				weaponClone.Parent = editor
			end
		end
	end 
end)


-- close the weapon order editor
local function CloseOrderEditor()
	editBackpack.Visible = false
	editFirstSelect.Value = ""
	
	for _,v : ImageButton | UIListLayout in ipairs(editor:GetChildren()) do
		if v:IsA("ImageButton") then
			v:Destroy()
		end
	end
end



-- player closes the order editor without validating
editBackpack:WaitForChild("Close").MouseButton1Down:Connect(function()
	CloseOrderEditor()
end)


-- player validates the new order
editBackpack:WaitForChild("Validate").MouseButton1Down:Connect(function()
	for _,v : ImageButton | UIListLayout in ipairs(backpackGui:GetChildren()) do
		if v:IsA("ImageButton") then
			
			local weaponNewOrder : ImageButton? = editor:FindFirstChild(v.Name)
			
			if weaponNewOrder then
				v.LayoutOrder = weaponNewOrder.LayoutOrder
				v.TextLabel.Text = weaponNewOrder.TextLabel.Text
			end
		end
	end
	
	-- copy the weapon order to a table to fire the server, otherwise the server can't access the children because they are created on the client
	local weaponOrder = {}
	for _,v : ImageButton | UIListLayout in ipairs(backpackGui:GetChildren()) do
		if v:IsA("ImageButton") then
			weaponOrder["Slot"..tostring(v.LayoutOrder)] = v.Name
		end
	end
	
	EditWeaponOrderRemoteEvent:FireServer(weaponOrder)
	
	CloseOrderEditor()
end)