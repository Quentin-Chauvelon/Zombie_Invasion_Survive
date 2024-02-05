local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local LeaderboardBindableEvent = ServerStorage:WaitForChild("Leaderboard")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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


-- get the 100th value (minimum to get on the leaderboard)
local function GetLastLeaderboardValue(leaderboard : OrderedDataStore) : number
	local leaderboardPages = leaderboard:GetSortedAsync(true, 99) -- 99 players from best to worst
	local leaderboardTop100 = leaderboardPages:GetCurrentPage() -- get the first page
	
	local numberOfPlayersOnLeaderboard : number = #leaderboardTop100
	
	if numberOfPlayersOnLeaderboard > 0 then
		return leaderboardTop100[numberOfPlayersOnLeaderboard].value
	end
	
	return 0
end


local function IsPlayerBetterThanTheLastPlayerOnTheLeaderboard(leaderboard : OrderedDataStore, value : number) : boolean
	local lastLeaderboardValue : number? = GetLastLeaderboardValue(leaderboard)
	
	if lastLeaderboardValue and value then
		return value > lastLeaderboardValue
	end
	
	return false
end


local function AddPlayerToLeaderboard(leaderboard : OrderedDataStore, value : number, userId : number)

	-- check if the player already is on the leaderboard and if he has a higher value than the previous one he had
	local best : number
	pcall(function()
		best = leaderboard:GetAsync(userId)
	end)

	-- if he beats it or doesn't already have one, add them on the leaderboard
	if not best or value > best then
		pcall(function()
			leaderboard:SetAsync(userId, value)
		end)
	end
end


-- add the player on the highest round leaderboard when he dies, if he has a higher round than the last player on the leaderboard
LeaderboardBindableEvent.Event:Connect(function(plr : Player)
	
	-- highest round
	local round : number = require(ServerScriptService:WaitForChild("Rounds")):GetRound()
	
	-- get the right leaderbaord based on the team size and the mode	
	local highestRoundLeaderboard : OrderedDataStore
	if ReplicatedStorage.NumberOfPlayers.Value == 1 then
		
		if ServerStorage.Mode.Value == 1 then
			highestRoundLeaderboard = highestNormalRoundSolo
		elseif ServerStorage.Mode.Value == 2 then
			highestRoundLeaderboard = highestHardRoundSolo
		elseif ServerStorage.Mode.Value == 3 then
			highestRoundLeaderboard = highestNoReviveNormalRoundSolo
		elseif ServerStorage.Mode.Value == 4 then
			highestRoundLeaderboard = highestNoReviveHardRoundSolo
		elseif ServerStorage.Mode.Value == 5 then
			highestRoundLeaderboard = highestEventRoundSolo
		end
		
	elseif ReplicatedStorage.NumberOfPlayers.Value == 4 then
		
		if ServerStorage.Mode.Value == 1 then
			highestRoundLeaderboard = highestNormalRoundTeam
		elseif ServerStorage.Mode.Value == 2 then
			highestRoundLeaderboard = highestHardRoundTeam
		elseif ServerStorage.Mode.Value == 3 then
			highestRoundLeaderboard = highestNoReviveNormalRoundTeam
		elseif ServerStorage.Mode.Value == 4 then
			highestRoundLeaderboard = highestNoReviveHardRoundTeam
		elseif ServerStorage.Mode.Value == 5 then
			highestRoundLeaderboard = highestEventRoundTeam
		end
	end
	
	if highestRoundLeaderboard then
		-- if the player's round of death is greater than the last player on the leaderboard, then add him onto the leaderboard
		if IsPlayerBetterThanTheLastPlayerOnTheLeaderboard(highestRoundLeaderboard, round) then
			AddPlayerToLeaderboard(highestRoundLeaderboard, round, plr.UserId)
		end
	end
	
	
	-- most games played
	local gamesPlayed : number = plr.GameStats.GamesPlayed.Value

	-- if the player's number of games played is greater than the last player on the leaderboard, then add him onto the leaderboard
	if IsPlayerBetterThanTheLastPlayerOnTheLeaderboard(mostGamesPlayed, gamesPlayed) then
		AddPlayerToLeaderboard(mostGamesPlayed, gamesPlayed, plr.UserId)
	end
	
	
	-- most zombies killed
	local zombiesKilled : number = plr.GameStats.ZombiesKilled.Value

	-- if the player's number of zombies killed is greater than the last player on the leaderboard, then add him onto the leaderboard
	if IsPlayerBetterThanTheLastPlayerOnTheLeaderboard(mostZombiesKilled, zombiesKilled) then
		AddPlayerToLeaderboard(mostZombiesKilled, zombiesKilled, plr.UserId)
	end
end)