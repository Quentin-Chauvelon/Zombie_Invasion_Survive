local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TitleBindableEvent = ServerStorage:WaitForChild("Title")
local titleToClone : BillboardGui = ServerStorage:WaitForChild("Title")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TitleRemoteEvent = ReplicatedStorage:WaitForChild("Title")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))

local defaultStatsTable = {
	numberOfGamesPlayed = 0,
	totalRounds = 0,
	totalTime = 0,
	totalCoinsEarnt = 0,
	bestRound = 0,
	bestRoundTime = 0,
	numberOfZombiesKill = 0,
	numberOfDeaths = 0,
	numberOfRevives = 0,
	refusedToGiveFeedback = 0
}

DataStore2.Combine("Data", "Stats")


Players.PlayerAdded:Connect(function(plr)
	local statsDataStore = DataStore2("Stats", plr)
	local statsTable = statsDataStore:Get(defaultStatsTable)
	
	if statsTable.title then
		local title = titleToClone:Clone()
		title.TextLabel.Text = statsTable.title.text
		title.TextLabel.TextColor3 = Color3.new(statsTable.title.color.r, statsTable.title.color.g, statsTable.title.color.b)
		
		if statsTable.title.hideFromSelf then
			title.PlayerToHideFrom = plr
		end
		
		plr:WaitForChild("HasTitle").Value = true
		
		title.Parent = workspace:WaitForChild(plr.Name):WaitForChild("Head")
	end
end)


TitleRemoteEvent.OnServerEvent:Connect(function(plr : Player, text : string, color : Color3, hideFromSelf : boolean)

	if text and color and hideFromSelf ~= nil and typeof(text) == "string" and typeof(color) == "Color3" and typeof(hideFromSelf) == "boolean" then

		if plr.Character then
			local titleBillboardGui : BillboardGui = plr.Character.Head:FindFirstChild("Title")

			if titleBillboardGui then
				
				local statsDataStore = DataStore2("Stats", plr)
				local statsTable = statsDataStore:Get(defaultStatsTable)
				
				if statsTable.title then
					
					-- filter the text
					local success, filteredText = pcall(function()
						return TextService:FilterStringAsync(text, plr.UserId)
					end)

					if success and filteredText then

						local success, filteredTextToUse = pcall(function()
							return filteredText:GetNonChatStringForUserAsync(plr.UserId)
						end)

						if success and filteredTextToUse and filteredTextToUse ~= "" then
							titleBillboardGui.TextLabel.Text = filteredTextToUse

							-- save the text the player chose
							statsTable.title.text = filteredTextToUse
						end
					end

					titleBillboardGui.TextLabel.TextColor3 = color

					-- save the color the player chose
					statsTable.title.color.r = color.R
					statsTable.title.color.g = color.G
					statsTable.title.color.b = color.B

					if hideFromSelf then
						titleBillboardGui.PlayerToHideFrom = plr
					else
						titleBillboardGui.PlayerToHideFrom = nil
					end

					-- save the hideFromSelf value the player chose
					statsTable.title.hideFromSelf = hideFromSelf

					statsDataStore:Set(statsTable)
				end
			end
		end
	end
end)