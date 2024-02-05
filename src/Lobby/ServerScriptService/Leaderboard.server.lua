local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local highestNormalRoundSoloKey : string = "highestNormalRoundSolo1"
local highestHardRoundSoloKey : string = "highestHardRoundSolo1"
local highestNoReviveNormalRoundSoloKey : string = "highestNoReviveNormalRoundSolo1"
local highestNoReviveHardRoundSoloKey : string = "highestNoReviveHardRoundSolo1"
local highestEventRoundSoloKey : string = "highestEventRoundSolo1"
local highestNormalRoundTeamKey : string = "highestNormalRoundTeam1"
local highestHardRoundTeamKey : string = "highestHardRoundTeam1"
local highestNoReviveNormalRoundTeamKey : string = "highestNoReviveNormalRoundTeam1"
local highestNoReviveHardRoundTeamKey : string = "highestNoReviveHardRoundTeam1"
local highestEventRoundTeamKey : string = "highestEventRoundTeam1"
local mostGamesPlayedKey : string = "mostGamesPlayed1"
local mostZombiesKilledKey : string = "mostZombiesKilled1"

local highestNormalRoundSolo : OrderedDataStore = DataStoreService:GetOrderedDataStore(highestNormalRoundSoloKey)
local highestHardRoundSolo : OrderedDataStore = DataStoreService:GetOrderedDataStore(highestHardRoundSoloKey)
local highestNoReviveNormalRoundSolo : OrderedDataStore = DataStoreService:GetOrderedDataStore(highestNoReviveNormalRoundSoloKey)
local highestNoReviveHardRoundSolo : OrderedDataStore = DataStoreService:GetOrderedDataStore(highestNoReviveHardRoundSoloKey)
local highestEventRoundSolo : OrderedDataStore = DataStoreService:GetOrderedDataStore(highestEventRoundSoloKey)
local highestNormalRoundTeam : OrderedDataStore = DataStoreService:GetOrderedDataStore(highestNormalRoundTeamKey)
local highestHardRoundTeam : OrderedDataStore = DataStoreService:GetOrderedDataStore(highestHardRoundTeamKey)
local highestNoReviveNormalRoundTeam : OrderedDataStore = DataStoreService:GetOrderedDataStore(highestNoReviveNormalRoundTeamKey)
local highestNoReviveHardRoundTeam : OrderedDataStore = DataStoreService:GetOrderedDataStore(highestNoReviveHardRoundTeamKey)
local highestEventRoundTeam : OrderedDataStore = DataStoreService:GetOrderedDataStore(highestEventRoundTeamKey)
local mostGamesPlayed : OrderedDataStore = DataStoreService:GetOrderedDataStore(mostGamesPlayedKey)
local mostZombiesKilled : OrderedDataStore = DataStoreService:GetOrderedDataStore(mostZombiesKilledKey)

local highestNormalRoundSoloLeaderboard : ScrollingFrame = workspace:WaitForChild("Leaderboards"):WaitForChild("HighestRoundLeaderboard"):WaitForChild("Leaderboard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("highestNormalRoundSolo")
local highestHardRoundSoloLeaderboard : ScrollingFrame = workspace.Leaderboards:WaitForChild("HighestRoundLeaderboard"):WaitForChild("Leaderboard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("highestHardRoundSolo")
local highestNoReviveNormalRoundSoloLeaderboard : ScrollingFrame = workspace.Leaderboards:WaitForChild("HighestRoundLeaderboard"):WaitForChild("Leaderboard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("highestNoReviveNormalRoundSolo")
local highestNoReviveHardRoundSoloLeaderboard : ScrollingFrame = workspace.Leaderboards:WaitForChild("HighestRoundLeaderboard"):WaitForChild("Leaderboard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("highestNoReviveHardRoundSolo")
local highestEventRoundSoloLeaderboard : ScrollingFrame = workspace.Leaderboards:WaitForChild("HighestRoundLeaderboard"):WaitForChild("Leaderboard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("highestEventRoundSolo")
local highestNormalRoundTeamLeaderboard : ScrollingFrame = workspace.Leaderboards:WaitForChild("HighestRoundLeaderboard"):WaitForChild("Leaderboard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("highestNormalRoundTeam")
local highestHardRoundTeamLeaderboard : ScrollingFrame = workspace.Leaderboards:WaitForChild("HighestRoundLeaderboard"):WaitForChild("Leaderboard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("highestHardRoundTeam")
local highestNoReviveNormalRoundTeamLeaderboard : ScrollingFrame = workspace.Leaderboards:WaitForChild("HighestRoundLeaderboard"):WaitForChild("Leaderboard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("highestNoReviveNormalRoundTeam")
local highestNoReviveHardRoundTeamLeaderboard : ScrollingFrame = workspace.Leaderboards:WaitForChild("HighestRoundLeaderboard"):WaitForChild("Leaderboard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("highestNoReviveHardRoundTeam")
local highestEventRoundTeamLeaderboard : ScrollingFrame = workspace.Leaderboards:WaitForChild("HighestRoundLeaderboard"):WaitForChild("Leaderboard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("highestEventRoundTeam")
local mostGamesPlayedLeaderboard : ScrollingFrame = workspace.Leaderboards:WaitForChild("MostGamesPlayedLeaderboard"):WaitForChild("Leaderboard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("ScrollingFrame")
local mostZombiesKilledLeaderboard : ScrollingFrame = workspace.Leaderboards:WaitForChild("MostZombiesKilledLeaderboard"):WaitForChild("Leaderboard"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("ScrollingFrame")


-- DISPLAY THE TYPING LEADERBOARD

local function DisplayLeaderboard(leaderboard : OrderedDataStore, leaderboardScrollingFrame : ScrollingFrame)
	local leaderboardPages = leaderboard:GetSortedAsync(true, 99) -- 99 players from best to worse
	local leaderboardTop100 = leaderboardPages:GetCurrentPage() -- get first page

	for rank, data in ipairs(leaderboardTop100) do -- loop through all players
		local frame : Frame? = leaderboardScrollingFrame:FindFirstChild(rank)
		
		if frame then
			frame.Rank.Text = rank
			
			local username
			pcall(function()
				username = game.Players:GetNameFromUserIdAsync(data.key)
			end)
			
			if username then
				frame.PlayerName.Text = username
			end
			
			frame.Time.Text = data.value
		end
	end
end


-- load all the leaderboards once
DisplayLeaderboard(highestNormalRoundSolo, highestNormalRoundSoloLeaderboard)
task.wait(1)

DisplayLeaderboard(mostGamesPlayed, mostGamesPlayedLeaderboard)
task.wait(1)

DisplayLeaderboard(mostZombiesKilled, mostZombiesKilledLeaderboard)
task.wait(1)

DisplayLeaderboard(highestHardRoundSolo, highestHardRoundSoloLeaderboard)
task.wait(1)

DisplayLeaderboard(highestNoReviveNormalRoundSolo, highestNoReviveNormalRoundSoloLeaderboard)
task.wait(1)

DisplayLeaderboard(highestNoReviveHardRoundSolo, highestNoReviveHardRoundSoloLeaderboard)
task.wait(1)

DisplayLeaderboard(highestEventRoundSolo, highestEventRoundSoloLeaderboard)
task.wait(1)

DisplayLeaderboard(highestNormalRoundTeam, highestNormalRoundTeamLeaderboard)
task.wait(1)

DisplayLeaderboard(highestHardRoundTeam, highestHardRoundTeamLeaderboard)
task.wait(1)

DisplayLeaderboard(highestNoReviveNormalRoundTeam, highestNoReviveNormalRoundTeamLeaderboard)
task.wait(1)

DisplayLeaderboard(highestNoReviveHardRoundTeam, highestNoReviveHardRoundTeamLeaderboard)
task.wait(1)

DisplayLeaderboard(highestEventRoundTeam, highestEventRoundTeamLeaderboard)
task.wait(1)


-- refresh the leaderboard's data
coroutine.wrap(function()
	while true do
		
		DisplayLeaderboard(highestNormalRoundSolo, highestNormalRoundSoloLeaderboard)
		task.wait(10)

		DisplayLeaderboard(highestHardRoundSolo, highestHardRoundSoloLeaderboard)
		task.wait(10)

		DisplayLeaderboard(highestNoReviveNormalRoundSolo, highestNoReviveNormalRoundSoloLeaderboard)
		task.wait(10)

		DisplayLeaderboard(highestNoReviveHardRoundSolo, highestNoReviveHardRoundSoloLeaderboard)
		task.wait(10)

		DisplayLeaderboard(highestEventRoundSolo, highestEventRoundSoloLeaderboard)
		task.wait(10)

		DisplayLeaderboard(highestNormalRoundTeam, highestNormalRoundTeamLeaderboard)
		task.wait(10)

		DisplayLeaderboard(highestHardRoundTeam, highestHardRoundTeamLeaderboard)
		task.wait(10)

		DisplayLeaderboard(highestNoReviveNormalRoundTeam, highestNoReviveNormalRoundTeamLeaderboard)
		task.wait(10)

		DisplayLeaderboard(highestNoReviveHardRoundTeam, highestNoReviveHardRoundTeamLeaderboard)
		task.wait(10)

		DisplayLeaderboard(highestEventRoundTeam, highestEventRoundTeamLeaderboard)
		task.wait(10)
		
		DisplayLeaderboard(mostGamesPlayed, mostGamesPlayedLeaderboard)
		task.wait(10)
		
		DisplayLeaderboard(mostZombiesKilled, mostZombiesKilledLeaderboard)
		task.wait(10)
	end
end)()