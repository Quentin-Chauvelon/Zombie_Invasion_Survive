local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateHealth = ReplicatedStorage:WaitForChild("UpdateHealth")
local TeammatesHealthStatusRemoteEvent = ReplicatedStorage:WaitForChild("TeammatesHealthStatus")
local UpdateCooldown = ReplicatedStorage:WaitForChild("UpdateCooldown")
local UpdateAmmoCount = ReplicatedStorage:WaitForChild("UpdateAmmoCount")
local ResetAmmos = ReplicatedStorage:WaitForChild("ResetAmmos")
local CancelCooldown = ReplicatedStorage:WaitForChild("CancelCooldown")
local RoleActivatedRemoteEvent = ReplicatedStorage:WaitForChild("RoleActivated")
local StartRoundRemoteEvent = ReplicatedStorage:WaitForChild("StartRound")
local MysteryBoxRemoteEvent = ReplicatedStorage:WaitForChild("MysteryBox")

local lplr : Player = game.Players.LocalPlayer

local health : NumberValue = lplr:WaitForChild("Stats"):WaitForChild("Health")
local maxHealth : NumberValue = lplr:WaitForChild("Stats"):WaitForChild("MaxHealth")

local healthGui : Frame = script.Parent:WaitForChild("Health")
local healthValue : TextLabel = healthGui:WaitForChild("HealthValue")
local healthBar : Frame = healthGui:WaitForChild("HealthBar")

local cooldownGui : Frame = script.Parent:WaitForChild("Cooldown")
local cooldownBar : Frame = cooldownGui:WaitForChild("CooldownBar")

local ammosLeft : TextLabel = script.Parent:WaitForChild("AmmosLeft")
local outOfAmmos : TextLabel = script.Parent:WaitForChild("OutOfAmmos")

local teammatesHealth : Frame = script.Parent:WaitForChild("TeammatesHealth")

local rolesGui : Frame = script.Parent:WaitForChild("Roles")
local roleActivated : TextLabel = script.Parent:WaitForChild("RoleActivated")

local mysteryBox : TextLabel = script.Parent:WaitForChild("MysteryBox")

local mysteryBoxMessageChanged : boolean = false
local tween

-- lower the title if the player has one
if lplr.Character and lplr.Character:WaitForChild("Head") and lplr.Character.Head:FindFirstChild("Title") then
	lplr.Character.Head.Title.Size = UDim2.new(0,100,0,25)
	lplr.Character.Head.Title.StudsOffset = Vector3.new(0,2,0)
end


-- create all the players health bars
local numberOfPlayers : number = #Players:GetPlayers()

-- if there is at least 2 players, show the other player's health
if numberOfPlayers > 1 then
	local numberOfTeammatesFrameSizes = {0.9, 0.46, 0.315}
	
	-- changes the sizes of the frames based on the number of players
	teammatesHealth.Size = UDim2.new(0.15,0, 0.075 * (numberOfPlayers - 1), 0)
	teammatesHealth.Player.Size = UDim2.new(0.9,0, numberOfTeammatesFrameSizes[numberOfPlayers - 1], 0)
	
	-- clone the health frame to match the number of players
	for i=3,numberOfPlayers do
		teammatesHealth.Player:Clone().Parent = teammatesHealth
	end
	
	-- change the names of the player in the frames
	for i,player : Player in ipairs(Players:GetPlayers()) do
		if player ~= lplr then
			if teammatesHealth:FindFirstChild("Player") then
				teammatesHealth.Player.PlayerName.Text = player.Name
				teammatesHealth.Player.Name = player.Name
			end
		end
	end

	teammatesHealth.Visible = true
end


-- Update the health of the client
UpdateHealth.OnClientEvent:Connect(function(player : Player)
	if player == lplr then
		healthValue.Text = tostring(health.Value).." / "..tostring(maxHealth.Value)
		healthBar:TweenSize(UDim2.new(health.Value / maxHealth.Value, 0, 1, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quart, 0.3)

	else
		if teammatesHealth:FindFirstChild(player.Name) then
			teammatesHealth[player.Name].Health.HealthBar.Size = UDim2.new(player.Stats.Health.Value / player.Stats.MaxHealth.Value, 0,1,0)
		end
	end
end)


TeammatesHealthStatusRemoteEvent.OnClientEvent:Connect(function(player : Player, status : number)
	if player ~= lplr then
		local teammateHealth : Frame = teammatesHealth:FindFirstChild(player.Name)
		
		if teammateHealth then
			
			-- player is alive, show the health, hide the down and dead text labels
			if status == 0 then
				teammateHealth.Down.Visible = false
				teammateHealth.Dead.Visible = false
				teammateHealth.Health.Visible = true
				
			-- player is down, hide the health, show the down text label
			elseif status == 1 then
				teammateHealth.Dead.Visible = false
				teammateHealth.Health.Visible = false
				teammateHealth.Down.Visible = true
				
			-- player is dead, hide the down text label, show the dead text label
			elseif status == 2 then
				teammateHealth.Down.Visible = false
				teammateHealth.Health.Visible = false
				teammateHealth.Dead.Visible = true
			end
		end
	end
end)


-- Show the cooldown bar when a weapon is activated
UpdateCooldown.OnClientEvent:Connect(function(cooldown : number, startingSize : number)	
	cooldownBar.Size = UDim2.new(startingSize,0,1,0)
	--cooldownBar:TweenSize(UDim2.new(0,0,1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, cooldown)
	tween = TweenService:Create(cooldownBar, TweenInfo.new(cooldown, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Size = UDim2.new(0,0,1,0)})
	tween:Play()
end)


-- Stop the cooldown when player switches or unequips a weapon
CancelCooldown.OnClientEvent:Connect(function()
	if tween and tween:IsA("TweenBase") then
		tween:Cancel()
		cooldownBar.Size = UDim2.new(0,0,1,0)
	end
end)


 -- Update the amount of ammos left for the weapon
UpdateAmmoCount.OnClientEvent:Connect(function(ammos : number? | string?)
	
	if ammos then
		ammosLeft.Text = ammos

		-- if there are less than 10 ammos left, turn the text red
		if typeof(ammos) == "number" then
			if ammos < 10 then
				ammosLeft.TextColor3 = Color3.new(1,0,0)
			end

			-- if the player is out of ammos, show a big text at the top
			if ammos == 0 then
				outOfAmmos.Visible = true
			end
		end
		
	else
		ammosLeft.TextColor3 = Color3.new(1,1,1)
		outOfAmmos.Visible = false
	end
end)


-- Reset the ammos left text color and remove the out of ammos message (when reloading or switching weapons)
ResetAmmos.OnClientEvent:Connect(function(ammos : number?)
	
	if ammos then
		if ammos >= 10 then
			ammosLeft.TextColor3 = Color3.new(1,1,1)
		end
		
		if ammos ~= 0 then
			outOfAmmos.Visible = false
		end
		
	else
		ammosLeft.TextColor3 = Color3.new(1,1,1)
		outOfAmmos.Visible = false
	end
end)


script.Parent.Parent:WaitForChild("Roles").Destroying:Connect(function()

	for i=1,2 do
		-- clone the roles buttons into the frame to use them
		if ReplicatedStorage.RolesButtons:FindFirstChild(lplr.Role.Value..tostring(i)) then
			local buttonClone : ImageButton = ReplicatedStorage.RolesButtons[lplr.Role.Value..tostring(i)]:Clone()
			buttonClone.Parent = rolesGui
			
			-- fire the server to activate te ability
			buttonClone.MouseButton1Down:Connect(function()
				
				if lplr:FindFirstChild("Ability"..tostring(i).."Used") and not lplr["Ability"..tostring(i).."Used"].Value then
					RoleActivatedRemoteEvent:FireServer(i)
					buttonClone.AutoButtonColor = false
					buttonClone.ImageColor3 = Color3.fromRGB(128,128,128)
				end
			end)
		end
	end
	
	-- change the UIListLayout padding based on the size of the text label
	if rolesGui:FindFirstChildOfClass("ImageButton") and rolesGui:FindFirstChildOfClass("ImageButton"):FindFirstChild("TextLabel") then
		rolesGui.UIListLayout.Padding = UDim.new(0, rolesGui:FindFirstChildOfClass("ImageButton").TextLabel.AbsoluteSize.Y + 10)
	end
end)


-- fires when a player activates an ability that affects all players
RoleActivatedRemoteEvent.OnClientEvent:Connect(function(player : Player, role : string, amount : number)
	
	if player and role and amount then
		roleActivated.Visible = true
		
		-- change the text based on the role of the player that activated the ability
		if role == "Healer" then
			roleActivated.Text = player.Name..' healed everyone by '..tostring(amount)..'<font color="#FF0000">♥</font>'
		elseif role == "Tank" then
			roleActivated.Text = player.Name..' reduced damages for everyone by <font color="#00FF00">'..tostring(amount)..'%</font>'
		elseif role == "Sniper" then
			roleActivated.Text = player.Name..' increased ranged weapons damage for everyone by <font color="#00FF00">'..tostring(amount)..'%</font>'
		elseif role == "Barbarian" then
			roleActivated.Text = player.Name..' increased melee weapons damage for everyone by <font color="#00FF00">'..tostring(amount)..'%</font>'
		elseif role == "Enchanter" then
			roleActivated.Text = player.Name..' reduced zombies abilities damage for everyone by <font color="#00FF00">'..tostring(amount)..'%</font>'
		end

		wait(10)
		roleActivated.Visible = false
	end
end)


-- fires when a new round starts
StartRoundRemoteEvent.OnClientEvent:Connect(function()
	for _,v : ImageButton | UIListLayout in ipairs(rolesGui:GetChildren()) do
		if v:IsA("ImageButton") then
			v.AutoButtonColor = true
			v.ImageColor3 = Color3.new(1,1,1)
		end
	end
end)


local function ShowMisteryBoxMessage(message : string)
	
	if mysteryBox.Visible then
		mysteryBoxMessageChanged = true
	else
		mysteryBox.Visible = true
	end
	
	mysteryBox.Text = message
	wait(8)
	
	-- only hide it the same message is still being displayed
	if mysteryBoxMessageChanged then
		mysteryBoxMessageChanged = false
	else
		mysteryBox.Visible = false
	end
end


-- fires when a player kills a zombie and spawns a mystery box
MysteryBoxRemoteEvent.OnClientEvent:Connect(function(player : Player, reward : number?, amount : number?)
	if player then
		
		-- if there is no arguments reward, it means, that the mystery box spawned, otherwise a player opened it
		if not reward then
			ShowMisteryBoxMessage(player.Name..' spawned a <font color="#FF00FF">mystery box</font>!')

		else
			if reward == 1 and amount then
				ShowMisteryBoxMessage(player.Name..' opened a <font color="#FF00FF">mystery box</font> and got <font color="#FFC020">'..tostring(amount)..'</font> coins!')
			elseif reward == 2 then
				ShowMisteryBoxMessage(player.Name..' opened a <font color="#FF00FF">mystery box</font> and <font color="#FF0000">healed</font> all players!')
			elseif reward == 3 then
				ShowMisteryBoxMessage(player.Name..' opened a <font color="#FF00FF">mystery box</font> and <font color="#808080">refilled ammos</font> of all weaopns for all players!')				
			elseif reward == 4 and amount then
				ShowMisteryBoxMessage(player.Name..' opened a <font color="#FF00FF">mystery box</font> and activated <font color="#AC0000">instant kill</font> for '..tostring(amount)..' seconds for all players!')				
			elseif reward == 5 then
				ShowMisteryBoxMessage(player.Name..' opened a <font color="#FF00FF">mystery box</font> and activated <font color="#FF9D47">explosion</font> for all players!')				
			elseif reward == 6 and amount then
				ShowMisteryBoxMessage(player.Name..' opened a <font color="#FF00FF">mystery box</font> and activated <font color="#2DB7F1">invincibility</font> for '..tostring(amount)..' seconds for all players!')				
			elseif reward == 7 and amount then
				ShowMisteryBoxMessage(player.Name..' opened a <font color="#FF00FF">mystery box</font> and activated <font color="#FF0000">double coins</font> for all players for '..tostring(amount)..' seconds!')				
			end
		end
	end
end)