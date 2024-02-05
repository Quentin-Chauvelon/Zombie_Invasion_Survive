local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FeedbackRemoteEvent = ReplicatedStorage:WaitForChild("Feedback")
local LaterFeedbackRemoteEvent = ReplicatedStorage:WaitForChild("LaterFeedback")

local feedbackScreenGui : ScreenGui = script.Parent

-- unselect all the radio buttons when one is selected
local function UnselectRadioButtons(object : Frame)
	for _,radioButton in ipairs(object:GetChildren()) do
		if radioButton:IsA("ImageButton") then
			radioButton.BackgroundColor3 = Color3.new(1,1,1)
		end
	end
end


-- make all the radio buttons selectable
local function MakeRadioButtonsSelectable(object : Frame)
	for _,radioButton in ipairs(object:GetChildren()) do
		if radioButton:IsA("ImageButton") then
			
			radioButton.MouseButton1Down:Connect(function()
				if object.Parent:FindFirstChild("SelectedRadioButton") then
					UnselectRadioButtons(object)

					-- store the button that has been selected
					object.Parent.SelectedRadioButton.Value = radioButton.LayoutOrder
					
					-- change the color of the inside of the button to make look like it's selected
					radioButton.BackgroundColor3 = Color3.fromRGB(64,64,64)
				end
			end)
		end
	end
end


FeedbackRemoteEvent.OnClientEvent:Connect(function()
	feedbackScreenGui.Enabled = true

	feedbackScreenGui.GiveFeedback.Sure.MouseButton1Down:Connect(function()
		local feedbackGui : Frame = feedbackScreenGui.FeedbackFrame
		
		feedbackScreenGui.GiveFeedback.Visible = false
		feedbackGui.Visible = true	
		
		-- show the feedback gui if the player previously closed it
		feedbackScreenGui.Show.MouseButton1Down:Connect(function()
			feedbackScreenGui.Show.Visible = false
			feedbackGui.Visible = true
		end)
		
		-- hide the feedback gui if the player clicks the arrow
		feedbackGui.Hide.MouseButton1Down:Connect(function()
			feedbackGui.Visible = false
			feedbackScreenGui.Show.Visible = true
		end)
		
		
		-- if the player clicks cancel, delete the screen gui
		feedbackGui.Cancel.MouseButton1Down:Connect(function()
			feedbackScreenGui:Destroy()
		end)
		
		
		-- if the player clicks submit, fire the server to give him the player's feedback and delete the screen gui (limit the express yourself text box text to 300 characters)
		feedbackGui.Submit.MouseButton1Down:Connect(function()
			FeedbackRemoteEvent:FireServer(feedbackGui.OverallGrade.SelectedRadioButton.Value, feedbackGui.GameBalance.SelectedRadioButton.Value, feedbackGui.NewFeature.SelectedRadioButton.Value, feedbackGui.ExpressYourself.TextBox.Text:sub(1,300))
			
			feedbackScreenGui:Destroy()
		end)
		
		MakeRadioButtonsSelectable(feedbackGui.OverallGrade.Frame)
		MakeRadioButtonsSelectable(feedbackGui.GameBalance.Frame)
		MakeRadioButtonsSelectable(feedbackGui.NewFeature.Frame)
	end)


	-- if the player clicks later, tell the server to save the number of times the player clicked later + destroy the screen gui as it's not needed anymore
	feedbackScreenGui.GiveFeedback.Later.MouseButton1Down:Connect(function()
		LaterFeedbackRemoteEvent:FireServer()
		feedbackScreenGui:Destroy()
	end)
end)