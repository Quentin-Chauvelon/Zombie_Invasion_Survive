local Players = game:GetService("Players")

local highestRoundLeaderboard : Model = workspace:WaitForChild("Leaderboards"):WaitForChild("HighestRoundLeaderboard")
local highestRoundLeaderboardScrollingFrames : Frame = highestRoundLeaderboard:WaitForChild("Leaderboard"):WaitForChild("SurfaceGui"):WaitForChild("Frame")
local highestRoundLeaderboardModeButtons : Folder = highestRoundLeaderboard:WaitForChild("ModeButtons")
local highestRoundLeaderboardTeamSizeButtons : Folder = highestRoundLeaderboard:WaitForChild("TeamSizeButtons")

local lplr = Players.LocalPlayer

local previouslySelectedMode : string = "Normal"
local previouslySelectedTeamSize : string = "Solo"


local function HidePreviousLeaderbardMode() : boolean
	if highestRoundLeaderboardScrollingFrames:FindFirstChild("highest"..previouslySelectedMode.."Round"..previouslySelectedTeamSize) and highestRoundLeaderboardModeButtons:FindFirstChild(previouslySelectedMode) then
		highestRoundLeaderboardScrollingFrames["highest"..previouslySelectedMode.."Round"..previouslySelectedTeamSize].Visible = false
		highestRoundLeaderboardModeButtons[previouslySelectedMode].SurfaceGui.TextLabel.BackgroundColor3 = Color3.fromRGB(206,206,206)
		
		return true
	end
	
	return false
end


local function HidePreviousLeaderbardTeamSize() : boolean
	if highestRoundLeaderboardScrollingFrames:FindFirstChild("highest"..previouslySelectedMode.."Round"..previouslySelectedTeamSize) and highestRoundLeaderboardTeamSizeButtons:FindFirstChild(previouslySelectedTeamSize) then
		highestRoundLeaderboardScrollingFrames["highest"..previouslySelectedMode.."Round"..previouslySelectedTeamSize].Visible = false
		highestRoundLeaderboardTeamSizeButtons[previouslySelectedTeamSize].SurfaceGui.TextLabel.BackgroundColor3 = Color3.fromRGB(206,206,206)
		
		return true
	end
	
	return false
end


-- get all mode buttons clicks and change the displayed leaderboard accordingly
for _,v : Part in ipairs(highestRoundLeaderboardModeButtons:GetChildren()) do
	v.ClickDetector.MouseClick:Connect(function(plr)
		
		if plr == lplr then
			
			-- if the previously selected mode button and scrolling frames can be found, change the displayed leaderboard
			if HidePreviousLeaderbardMode() then
				
				-- display the new selected leaderboard
				if highestRoundLeaderboardScrollingFrames:FindFirstChild("highest"..v.Name.."Round"..previouslySelectedTeamSize) then
					highestRoundLeaderboardScrollingFrames["highest"..v.Name.."Round"..previouslySelectedTeamSize].Visible = true
					v.SurfaceGui.TextLabel.BackgroundColor3 = Color3.new(0,1,0)
					
					previouslySelectedMode = v.Name
				end
			end
		end
	end)
end


-- get all mode buttons clicks and change the displayed leaderboard accordingly
for _,v : Part in ipairs(highestRoundLeaderboardTeamSizeButtons:GetChildren()) do
	v.ClickDetector.MouseClick:Connect(function(plr)
		
		if plr == lplr then
			
			-- if the previously selected mode button and scrolling frames can be found, change the displayed leaderboard
			if HidePreviousLeaderbardTeamSize() then
				
				-- display the new selected leaderboard
				if highestRoundLeaderboardScrollingFrames:FindFirstChild("highest"..previouslySelectedMode.."Round"..v.Name) then
					highestRoundLeaderboardScrollingFrames["highest"..previouslySelectedMode.."Round"..v.Name].Visible = true
					v.SurfaceGui.TextLabel.BackgroundColor3 = Color3.new(0,1,0)
					
					previouslySelectedTeamSize = v.Name
				end
			end
		end
	end)
end