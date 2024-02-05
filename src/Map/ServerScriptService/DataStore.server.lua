local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SaveDataBindableEvent = ServerStorage:WaitForChild("SaveData")
local titleToClone : BillboardGui = ServerStorage:WaitForChild("Title")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FeedbackRemoteEvent = ReplicatedStorage:WaitForChild("Feedback")
local LaterFeedbackRemoteEvent = ReplicatedStorage:WaitForChild("LaterFeedback")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local key : string = "feedback2"

local Utilities = require(ServerScriptService:WaitForChild("Utilities"))
local Rounds = require(ServerScriptService:WaitForChild("Rounds"))
local PlayersModuleScript = require(ServerScriptService:WaitForChild("Players"))

local feedbackDataStore = DataStoreService:GetDataStore("Feedback")

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
	
	-- clone all the player's folder
	for _,v in ipairs(ServerStorage:WaitForChild("DataStore"):GetChildren()) do
		v:Clone().Parent = plr
	end
	
	workspace:WaitForChild(plr.Name)
	if plr.Character and plr.Character:FindFirstChild("Humanoid") then
		plr.Character.Humanoid.NameDisplayDistance = 0
	end
	
	plr.GameStats.BestRound.Value = statsTable.bestRound
	
	statsTable.numberOfGamesPlayed += 1
	plr.GameStats.GamesPlayed.Value = statsTable.numberOfGamesPlayed
	
	-- add the title to the player if he has one
	if statsTable.title then
		local title = titleToClone:Clone()
		title.TextLabel.Text = statsTable.title.text
		title.TextLabel.TextColor3 = Color3.new(statsTable.title.color.r, statsTable.title.color.g, statsTable.title.color.b)

		if statsTable.title.hideFromSelf then
			title.PlayerToHideFrom = plr
		end

		title.Parent = workspace:WaitForChild(plr.Name):WaitForChild("Head")
	end
	
	statsDataStore:Set(statsTable)
end)


-- save the data for all players after each round
SaveDataBindableEvent.Event:Connect(function(plr : Player)

	local statsDataStore = DataStore2("Stats", plr)
	local statsTable = statsDataStore:Get(defaultStatsTable)
	
	local round : number = Rounds:GetRound()
	local totalTime : number = Utilities:GetTime()
	
	statsTable.totalRounds += round
	statsTable.totalTime += totalTime
	statsTable.totalCoinsEarnt += plr.GameStats.CoinsEarnt.Value
	
	if statsTable.bestRound < round then
		statsTable.bestRound = round
		statsTable.bestRoundTime = totalTime
	end

	statsTable.numberOfZombiesKill += plr.GameStats.ZombiesKilled.Value
	plr.GameStats.ZombiesKilled.Value = statsTable.numberOfZombiesKill
	statsTable.numberOfDeaths += plr.GameStats.Deaths.Value
	statsTable.numberOfRevives += plr.GameStats.Revived.Value
	
	-- ask the player if he wants to give us his feedback (if he hasn't clicked the later button more than 3 times)
	if statsTable.refusedToGiveFeedback ~= nil and statsTable.refusedToGiveFeedback < 3 then
		
		-- check if the player already gave his feedback, if he already did, set the refusedToGiveFeedback value to 10 so that he won't be asked again
		local success, errormessage = pcall(function()
			local feedbacks = feedbackDataStore:GetAsync(key)
			
			if feedbacks then
				local userId : number = plr.UserId
				
				for _,v in pairs(feedbacks) do
					if v.userId == plr.UserId then
						statsTable.refusedToGiveFeedback = 10
					end
				end
			end
		end)
		
		if not success or statsTable.refusedToGiveFeedback < 3 then
			FeedbackRemoteEvent:FireClient(plr)
		end
	end
	
	statsDataStore:Set(statsTable)
end)


LaterFeedbackRemoteEvent.OnServerEvent:Connect(function(plr)
	
	-- if the player is dead
	if not PlayersModuleScript:IsAlive(plr) then
		
		local statsDataStore = DataStore2("Stats", plr)
		local statsTable = statsDataStore:Get(defaultStatsTable)
		
		statsTable.refusedToGiveFeedback += 1
		
		statsDataStore:Set(statsTable)
	end
end)