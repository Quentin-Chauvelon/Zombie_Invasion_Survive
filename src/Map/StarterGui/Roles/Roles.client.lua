--local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RolesRemoteEvent = ReplicatedStorage:WaitForChild("Roles")
local RoleConfirmation = ReplicatedStorage:WaitForChild("RoleConfirmation")

-- define the type tab as a table of number
type tab = {number}

local rolesGui = script.Parent:WaitForChild("Frame")
local rolesFrame = rolesGui:WaitForChild("Frame")

local roleSelected : boolean = false

rolesGui.Visible = true

rolesFrame:WaitForChild("Healer")
rolesFrame:WaitForChild("Tank")
rolesFrame:WaitForChild("Sniper")
rolesFrame:WaitForChild("Barbarian")
rolesFrame:WaitForChild("Enchanter")

for _,v : ImageButton | UIListLayout in ipairs(rolesFrame:GetChildren()) do
	if v:IsA("ImageButton") then

		-- wait for the guis element to load
		local title : TextLabel = v:WaitForChild("Title")
		local thumbnails : TextLabel = v:WaitForChild("Thumbnails")
		local description : TextLabel = v:WaitForChild("Description")

		-- position the elements based on the size of the thumbnails frame
		title.Position = UDim2.new(0.5,0,0, thumbnails.AbsoluteSize.Y)
		description.Position = UDim2.new(0.5,0,0, (title.Position.Y.Offset + title.AbsoluteSize.Y))
		description.Size = UDim2.new(0.95,0,0, v.AbsoluteSize.Y - description.Position.Y.Offset)

		-- make the frame bigger on mouse enter
		v.MouseEnter:Connect(function()
			v.Size = UDim2.new(0.17,0,1.05,0)
		end)

		-- make the frame smaller on mouse leave
		v.MouseLeave:Connect(function()
			v.Size = UDim2.new(0.17,0,1,0)
		end)

		-- fire the server on click event to let everyone know who clicked what
		v.MouseButton1Down:Connect(function()
			if not roleSelected then
				roleSelected = true
			end
			
			RolesRemoteEvent:FireServer(v.Name)
		end)
	end
end


-- player clicks start to validate the role he selected
rolesGui:WaitForChild("Start").MouseButton1Down:Connect(function()
	if roleSelected then
		rolesGui.Start.Visible = false
		rolesGui.TextLabel.Text = "Waiting for other players to select a role..."
		RoleConfirmation:FireServer()
	end
end)


-- fired when a player selected a role
RolesRemoteEvent.OnClientEvent:Connect(function(playersWithRole : tab, role : string, previousRole : string, playersWithPreviousRole : tab)
	local roleImage : ImageButton? = rolesFrame:FindFirstChild(role)

	if roleImage then
		local numberOfPlayersWithRole : number = #playersWithRole

		-- update the role text
		if role == "Healer" then
			roleImage.Description.Text = '-Heal all players by '..tostring(100 / numberOfPlayersWithRole)..'<font color="#FF0000">♥</font><br /><br />-Regeneration (+10<font color="#FF0000">♥</font>per second) for 10 seconds'
		elseif role == "Tank" then
			roleImage.Description.Text = '-200<font color="#FF0000">♥</font> instead of 100<font color="#FF0000">♥</font><br /><br />-Resistance (damage reduced by <font color="#00FF00">'..tostring(110 - 20 * numberOfPlayersWithRole)..'%</font>) for 10 seconds for all players'
		elseif role == "Sniper" then
			roleImage.Description.Text = '-Damage of all ranged weapons increased by <font color="#00FF00">15%</font><br /><br />-Damage of all ranged weapons increased by <font color="#00FF00">'..tostring(5 - 1 * numberOfPlayersWithRole)..'%</font> for all players'
		elseif role == "Barbarian" then
			roleImage.Description.Text = '-Damage of all melee weapons increased by <font color="#00FF00">30%</font><br /><br />-Damage of all melee weapons increased by <font color="#00FF00">'..tostring(12 - 2 * numberOfPlayersWithRole)..'%</font> for all players'
		elseif role == "Enchanter" then
			roleImage.Description.Text = '-Add an ability to your weapons for 10 seconds once per round<br /><br />-Reduce abilities from zombies by <font color="#00FF00">'..tostring(60 - 10 * numberOfPlayersWithRole)..'%</font> for 15 seconds for all players'
		end

		local thumbnailsFrame : Frame = roleImage:FindFirstChild("Thumbnails")
		if thumbnailsFrame then

			-- hide the thumbnails images with the previous number of players (-1)
			if thumbnailsFrame:FindFirstChild(tostring(numberOfPlayersWithRole - 1).."Players") then
				thumbnailsFrame[tostring(numberOfPlayersWithRole - 1).."Players"].Visible = false
			end

			local thumbnailsImages : ImageLabel | Frame = thumbnailsFrame:FindFirstChild(tostring(numberOfPlayersWithRole).."Players")
			if thumbnailsImages then

				-- show the thumbnails images with the current number of players
				thumbnailsFrame[tostring(numberOfPlayersWithRole).."Players"].Visible = true

				for i=1,numberOfPlayersWithRole do
					if thumbnailsImages:FindFirstChild("Player"..tostring(i)) and playersWithRole[i] then
						thumbnailsImages["Player"..tostring(i)].Image = playersWithRole[i]
					end
				end
			end
		end
		
		-- remove the player from the previous role he had selected
		local previousRoleImage : ImageButton? = rolesFrame:FindFirstChild(previousRole)
		if previousRoleImage then
			
			local numberOfPlayersWithPreviousRole : number = #playersWithPreviousRole
			
			-- update the previous role text
			if previousRole == "Healer" then
				previousRoleImage.Description.Text = '-Heal all players by '..tostring(100 / numberOfPlayersWithPreviousRole)..'<font color="#FF0000">♥</font><br /><br />-Regeneration (+10<font color="#FF0000">♥</font>per second) for 10 seconds'
			elseif previousRole == "Tank" then
				previousRoleImage.Description.Text = '-200<font color="#FF0000">♥</font> instead of 100<font color="#FF0000">♥</font><br /><br />-Resistance (damage reduced by <font color="#00FF00">'..tostring(110 - 20 * numberOfPlayersWithPreviousRole)..'%</font>) for 10 seconds for all players'
			elseif previousRole == "Sniper" then
				previousRoleImage.Description.Text = '-Damage of all ranged weapons increased by <font color="#00FF00">15%</font><br /><br />-Damage of all ranged weapons increased by <font color="#00FF00">'..tostring(5 - 1 * numberOfPlayersWithPreviousRole)..'%</font> for all players'
			elseif previousRole == "Barbarian" then
				previousRoleImage.Description.Text = '-Damage of all melee weapons increased by <font color="#00FF00">30%</font><br /><br />-Damage of all melee weapons increased by <font color="#00FF00">'..tostring(12 - 2 * numberOfPlayersWithPreviousRole)..'%</font> for all players'
			elseif previousRole == "Enchanter" then
				previousRoleImage.Description.Text = '-Add an ability to your weapons for 10 seconds once per round<br /><br />-Reduce abilities from zombies by <font color="#00FF00">'..tostring(60 - 10 * numberOfPlayersWithPreviousRole)..'%</font> for 15 seconds for all players'
			end			
			
			local previousThumbnailsFrame : Frame = previousRoleImage:FindFirstChild("Thumbnails")
			if previousThumbnailsFrame then

				-- hide the thumbnails images with the previous number of players (-1)
				if previousThumbnailsFrame:FindFirstChild(tostring(numberOfPlayersWithPreviousRole + 1).."Players") then
					previousThumbnailsFrame[tostring(numberOfPlayersWithPreviousRole + 1).."Players"].Visible = false
				end

				local previousThumbnailsImages : ImageLabel | Frame = previousThumbnailsFrame:FindFirstChild(tostring(numberOfPlayersWithPreviousRole).."Players")
				if previousThumbnailsImages then

					-- show the thumbnails images with the current number of players
					previousThumbnailsFrame[tostring(numberOfPlayersWithPreviousRole).."Players"].Visible = true

					for i=1,numberOfPlayersWithPreviousRole do
						if previousThumbnailsImages:FindFirstChild("Player"..tostring(i)) and playersWithPreviousRole[i] then
							previousThumbnailsImages["Player"..tostring(i)].Image = playersWithPreviousRole[i]
						end
					end
				end
			end
		end
	end
end)


-- countdown in the top right hand corner
coroutine.wrap(function()
	local countdown : TextLabel = rolesGui:WaitForChild("Timer")
	
	for i=30,0,-1 do
		countdown.Text = i
		wait(1)
	end	
end)()


--[[
Healer:
	Heal all players by 100♥ (1P:100, 2P:75, 3P:50, 4P:25, formula: X = 100 / NbPlayers) once per round
	Regeneration (+10♥ every second) for 10 seconds once per round

Tank:
	200♥ instead of 100♥
	Resistance (damage reduced by 90% (1P:90%, 2P:70%, 3P:50%, 4P:30%, formula: X = 110 – 20 * NbPlayers) for 10 seconds for all players once per round

Sniper:
	Damage of all ranged weapons increased by 15%
	Damage of all ranged weapons increased by 4% (1P:4%, 2P:3%, 3P:2%, 4P:1%, formula: X = 4 / NbPlayers) for all players

Barbarian:
	Damage of all melee weapons increased by 30%
	Damage of all melee weapons increased by 10% (1P:10%, 2P:8%, 3P:6%, 4P:4%, formula: X = 4 / NbPlayers) for all players

Enchanter:
	Add an effect (fire, poison, or ice) to your weapons for 10 seconds once per round
	Reduce effects (fire, poison, or ice) from zombies by 50% (1P:50%, 2P:40%, 3P:30%, 4P:20%, formula: X = 60 – 10 * NbPlayers) for 15 seconds for all players
]]--