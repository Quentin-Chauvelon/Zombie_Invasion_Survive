local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TitleRemoteEvent = ReplicatedStorage:WaitForChild("Title")
local FilterTitleRemoteFunction = ReplicatedStorage:WaitForChild("FilterTitle")
local titleBillboardToClone : BillboardGui = ReplicatedStorage:WaitForChild("CustomisationTitle")

local title : Model = workspace:WaitForChild("Title") 
local cameraCFrame : CFrame = title:WaitForChild("Camera").CFrame
local characterCFrame : CFrame = title:WaitForChild("CharacterPosition").CFrame

local lplr = Players.LocalPlayer

local currentCamera : Camera = workspace.CurrentCamera

local titleGui : ScreenGui = script.Parent

local titleTextFrame : Frame = titleGui:WaitForChild("Text")
local titleColorFrame: Frame = titleGui:WaitForChild("Color")
local titleSettings : Frame = titleGui:WaitForChild("Settings")
local titleHeader : Frame = titleGui:WaitForChild("Header")

local saveButton : TextButton = titleGui:WaitForChild("Save")

local playButton : TextButton = script.Parent.Parent:WaitForChild("Play"):WaitForChild("Start")
local closeButton : TextButton = script.Parent.Parent.Play:WaitForChild("Close")

local titleTextTemplate : Folder = ReplicatedStorage:WaitForChild("TitleGuiTemplates"):WaitForChild("Text")
local titleColorTemplate : Folder = ReplicatedStorage.TitleGuiTemplates:WaitForChild("Color")

local titleText : string
local titleColor : Color3
local hideFromSelf : boolean

local titleBillboard : BillboardGui

local executedOnce : boolean = false
local settingsDebounce : boolean = false
local titleGamepassId : number = 0


workspace:WaitForChild(lplr.Name)
task.wait(1)
if lplr.Character and lplr.Character.Head:FindFirstChild("Title") then
	lplr.Character.Head.Title.Size = UDim2.new(0,100,0,25)
	lplr.Character.Head.Title.StudsOffset = Vector3.new(0,2,0)
end


-- clone the character and position on one of the hills so that the player can see himself with the title
local function CloneCharacter()
	
	local character : Model? = lplr.Character
	if character then

		-- allows the player to be cloned
		character.Archivable = true
		local characterClone : Model = character:Clone()
		character.Archivable = false
		
		if characterClone:FindFirstChild("ZombiePet") then
			characterClone.ZombiePet:Destroy()
		end
		
		if characterClone.Head:FindFirstChild("Title") then
			characterClone.Head.Title:Destroy()
		end
		
		titleBillboard = titleBillboardToClone:Clone()
		titleBillboard.TextLabel.Text = titleText or "Zombie"
		titleBillboard.TextLabel.TextColor3 = titleColor or Color3.fromRGB(153, 25, 25)
		titleBillboard.Parent = characterClone.Head
		
		characterClone:PivotTo(characterCFrame)
		characterClone.Parent = title
	end
end


-- make the previously selected text button's background white
local function unselectTextButton()
	if titleText and titleTextFrame:FindFirstChild(titleText) then
		titleTextFrame[titleText].BackgroundColor3 = Color3.new(1,1,1)
	end
end


-- select the new title text when the player clicks one of the buttons
local function selectTextButton(titleName : string)
	
	-- unselect the previously selected text
	unselectTextButton()
	
	-- change the new title text button background color to green
	if titleTextFrame:FindFirstChild(titleName) then
		titleTextFrame[titleName].BackgroundColor3 = Color3.fromRGB(0,193,45)
	end
	
	-- store the text in a variable
	titleText = titleName
	
	-- change the text on the character's billboard gui
	if titleBillboard then
		titleBillboard.TextLabel.Text = titleName
	end
end


-- make the previously selected text button's background white
local function unselectColorButton()
	if titleColor then
		
		for _,v in ipairs(titleColorFrame:GetChildren()) do
			if v:IsA("ImageButton") then
				if v.BackgroundColor3 == titleColor then
					v.UIStroke.Color = Color3.new(1,1,1)
				end
			end
		end
	end
end


-- select the new title text when the player clicks one of the buttons
local function selectColorButton(colorButton : ImageButton)

	-- unselect the previously selected color
	unselectColorButton()

	-- change the new title text button background color to green
	colorButton.UIStroke.Color = Color3.fromRGB(0,196,45)

	-- store the text in a variable
	titleColor = colorButton.BackgroundColor3

	-- change the text on the character's billboard gui
	if titleBillboard then
		titleBillboard.TextLabel.TextColor3 = titleColor
	end
end


-- on proximity prompt triggered, clone the player's character + move camera, show the title gui
workspace:WaitForChild("GamepassesShops"):WaitForChild("Title"):WaitForChild("ProximityPrompt"):WaitForChild("ProximityPrompt").Triggered:Connect(function(plr)
	
	if plr == lplr then
		
		if lplr.HasTitle.Value then
			
			if lplr.Character and lplr.Character.Head:FindFirstChild("Title") then
				titleText = lplr.Character.Head.Title.TextLabel.Text
				titleColor = lplr.Character.Head.Title.TextLabel.TextColor3
				hideFromSelf = lplr.Character.Head.Title.PlayerToHideFrom ~= nil
			end
			
			-- clone the character so that the player can see himself with the title
			CloneCharacter()
			
			-- move the camera to the cloned character
			currentCamera.CameraType = Enum.CameraType.Scriptable
			currentCamera.CFrame = cameraCFrame
			
			titleGui.Enabled = true
			
			-- clone all the texts buttons in the text frame
			for _,v in ipairs(titleTextTemplate:GetChildren()) do
				local clone : TextButton = v:Clone()
				
				clone.MouseButton1Down:Connect(function()
					
					-- if the player clicks the custom button, show the frame to input the name
					if clone.Name == "Custom" then
						unselectTextButton()
						clone.BackgroundColor3 = Color3.fromRGB(0,193,45)
						
						-- if it's not visible yet, bind the events and show the gui
						if not clone.CustomTitle.Visible then
							clone.CustomTitle.Visible = true
							
							clone.CustomTitle.Validate.MouseButton1Down:Connect(function()
								
								-- check if the name is not too long (16 characters max)
								if #clone.CustomTitle.TextBox.Text > 16 then
									clone.CustomTitle.Error.Text = "Name too long (16 characters max)."
									
									
								-- filter the string
								else
									if FilterTitleRemoteFunction:InvokeServer(clone.CustomTitle.TextBox.Text) then
										-- store the text in a variable
										titleText = clone.CustomTitle.TextBox.Text

										-- change the text on the character's billboard gui
										if titleBillboard then
											titleBillboard.TextLabel.Text = titleText
										end
										
										
									else
										clone.CustomTitle.Error.Text = "Sorry, you can't use this title."
									end
								end
							end)
						end
						
					else
						selectTextButton(clone.Name)
					end
				end)
				
				clone.Parent = titleTextFrame
			end
			
			if not executedOnce then
				executedOnce = true
				
				-- player clicks on one of the header buttons to change categories
				for _,v : TextButton | UIListLayout in ipairs(titleHeader:GetChildren()) do
					if v:IsA("TextButton") then
						
						v.MouseButton1Down:Connect(function()
							
							-- unselect the previously selected button + hide the frame associated with it
							for _,vv in ipairs(titleHeader:GetChildren()) do
								if vv:IsA("TextButton") then
									
									if vv.BackgroundColor3 == Color3.fromRGB(225,155,41) then
										vv.BackgroundColor3 = Color3.fromRGB(150,105,28)

										if titleGui:FindFirstChild(vv.Name) then
											titleGui[vv.Name].Visible = false
										end
									end
								end
							end
							
							-- select the clicked button
							v.BackgroundColor3 = Color3.fromRGB(225,155,41)
							
							-- show the frame associated with the button
							if titleGui:FindFirstChild(v.Name) then
								titleGui[v.Name].Visible = true
								
								if v.Name == "Color" then
									-- if the buttons have not already been cloned
									if not titleColorFrame:FindFirstChildOfClass("ImageButton") then
										
										-- clone all the image buttons in the color frame
										for _,v in ipairs(titleColorTemplate:GetChildren()) do
											local clone : ImageButton = v:Clone()

											clone.MouseButton1Down:Connect(function()
												selectColorButton(clone)
											end)

											clone.Parent = titleColorFrame
										end
									end
								end
							end
						end)
					end
				end
				
				if hideFromSelf then
					titleSettings.HideFromSelf.Toggle.BackgroundColor3 = Color3.fromRGB(0,193,45)
					titleSettings.HideFromSelf.Toggle.Circle.AnchorPoint = Vector2.new(0,0.5)
					titleSettings.HideFromSelf.Toggle.Circle.Position = UDim2.new(0.95,0,0.5,0)
				end

				titleSettings.HideFromSelf.Toggle.MouseButton1Down:Connect(function()

					if not settingsDebounce then
						settingsDebounce = true
						
						if titleSettings.HideFromSelf.On.Value then
							titleSettings.HideFromSelf.Toggle.BackgroundColor3 = Color3.fromRGB(0,193,45)
							TweenService:Create(titleSettings.HideFromSelf.Toggle.Circle, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Position = UDim2.new(0.95,0,0.5,0), AnchorPoint = Vector2.new(1,0.5)}):Play()
							
							titleSettings.HideFromSelf.On.Value = false
							hideFromSelf = true


						else
							titleSettings.HideFromSelf.Toggle.BackgroundColor3 = Color3.fromRGB(193,193,193)
							TweenService:Create(titleSettings.HideFromSelf.Toggle.Circle, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Position = UDim2.new(0.05,0,0.5,0), AnchorPoint = Vector2.new(0,0.5)}):Play()
							
							titleSettings.HideFromSelf.On.Value = true
							hideFromSelf = false
						end
						
						task.wait(0.2)
						settingsDebounce = false
					end
				end)
				
				saveButton.MouseButton1Down:Connect(function()
					titleGui.Enabled = false
					titleTextFrame.Visible = true
					titleColorFrame.Visible = false
					titleSettings.Visible = false
					playButton.Visible = true
					closeButton.Visible = true
					
					-- destroy the cloned character
					if title:FindFirstChild(lplr.Name) then
						title[lplr.Name]:Destroy()
					end
					
					for _,v in ipairs(titleHeader:GetChildren()) do
						if v:IsA("TextButton") then
							v.BackgroundColor3 = Color3.fromRGB(150,105,28)
						end
					end
					
					titleHeader.Text.BackgroundColor3 = Color3.fromRGB(225,155,41)
					
					currentCamera.CameraType = Enum.CameraType.Custom
					
					-- destroy all the buttons from the text frame
					local UIGridLayout : UIGridLayout = titleTextFrame.UIGridLayout:Clone()
					titleTextFrame:ClearAllChildren()
					UIGridLayout.Parent = titleTextFrame
					
					-- destroy all the buttons from the color frame
					local UIGridLayout : UIGridLayout = titleColorFrame.UIGridLayout:Clone()
					titleColorFrame:ClearAllChildren()
					UIGridLayout.Parent = titleColorFrame
					
					TitleRemoteEvent:FireServer(titleText, titleColor, hideFromSelf)
				end)
			end
			
		else
			MarketplaceService:PromptGamePassPurchase(lplr, titleGamepassId)
		end
	end
end)


-- pet shpo proximity prompt trigger
workspace.GamepassesShops:WaitForChild("Pet"):WaitForChild("ProximityPrompt"):WaitForChild("ProximityPrompt").Triggered:Connect(function(plr)
	if plr == lplr and not plr.Character or not plr.Character:FindFirstChild("ZombiePet") then
		MarketplaceService:PromptGamePassPurchase(lplr, titleGamepassId)
	end
end)