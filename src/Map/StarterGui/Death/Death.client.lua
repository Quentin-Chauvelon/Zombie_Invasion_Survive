local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayAgainRemoteEvent = ReplicatedStorage:WaitForChild("PlayAgain")
local BackToLobbyRemoteEvent = ReplicatedStorage:WaitForChild("BackToLobby")
local PlayAgainStatusRemoteEvent = ReplicatedStorage:WaitForChild("PlayAgainStatus")

local lplr : Player = Players.LocalPlayer

-- get the number of zombies killed the player had before this game
local totalNumberOfZombiesKilled : number = 0
lplr:WaitForChild("GameStats"):WaitForChild("GamesPlayed")
local getNumberOfGamesPlayedValueChanged 
getNumberOfGamesPlayedValueChanged = lplr.GameStats.GamesPlayed:GetPropertyChangedSignal("Value"):Connect(function()
	if lplr.GameStats.GamesPlayed.Value ~= 0 then
		totalNumberOfZombiesKilled = lplr.GameStats.ZombiesKilled.Value
		getNumberOfGamesPlayedValueChanged:Disconnect()
	end
end)


local DeathGui = script.Parent

DeathGui.PlayAgain.MouseButton1Down:Connect(function()
	PlayAgainRemoteEvent:FireServer()
end)


DeathGui.BackToLobby.MouseButton1Down:Connect(function()
	BackToLobbyRemoteEvent:FireServer()
end)


PlayAgainRemoteEvent.OnClientEvent:Connect(function(round : number, totalTime : number)

	if ReplicatedStorage.NumberOfPlayers.Value > 1 then
		local summaryGui : Frame = DeathGui.Summary
		summaryGui.Visible = true

		summaryGui.Round.Text = "Round "..tostring(round)
		summaryGui.Timer.Text = string.format("%02i : %02i", math.floor(totalTime / 60), math.floor(totalTime % 60))

		if round > lplr.GameStats.BestRound.Value then
			summaryGui.NewBest.Text = "New best! (+"..tostring(round - lplr.GameStats.BestRound.Value)..")"
			summaryGui.NewBest.Visible = true
		end

		summaryGui.ZombiesKilled.Text = "Zombies killed: "..tostring(lplr.GameStats.ZombiesKilled.Value)
		summaryGui.Deaths.Text = "Deaths: "..tostring(lplr.GameStats.Deaths.Value)
		summaryGui.Revived.Text = "Revived: "..tostring(lplr.GameStats.Revived.Value)
		summaryGui.CoinsEarnt.Text = "Coins earnt: "..tostring(lplr.GameStats.CoinsEarnt.Value)

		summaryGui.Players.Player1.PlayerName.Text = lplr.Name

		if #Players:GetPlayers() == ReplicatedStorage.NumberOfPlayers.Value then
			summaryGui.Players.Player1.PlayAgain.Visible = true

			summaryGui.Players.Player1.PlayAgain.MouseButton1Down:Connect(function()
				PlayAgainRemoteEvent:FireServer()
			end)

		else
			summaryGui.Status.Visible = true
		end

		summaryGui.Players.Player1.BackToLobby.MouseButton1Down:Connect(function()
			BackToLobbyRemoteEvent:FireServer()
		end)

		local currentPlayer : number = 2	
		for _,player in ipairs(Players:GetPlayers()) do
			if player.Name ~= lplr.Name then

				if summaryGui.Players:FindFirstChild("Player"..tostring(currentPlayer)) then
					summaryGui.Players["Player"..tostring(currentPlayer)].PlayerName.Text = player.Name
					summaryGui.Players["Player"..tostring(currentPlayer)].Name = player.Name
				end

				currentPlayer += 1
			end
		end
		
	else
		local summaryGui : Frame = DeathGui.SummarySolo
		summaryGui.Visible = true

		summaryGui.Round.Text = "Round "..tostring(round)
		summaryGui.Timer.Text = string.format("%02i : %02i", math.floor(totalTime / 60), math.floor(totalTime % 60))

		if round > lplr.GameStats.BestRound.Value then
			summaryGui.NewBest.Text = "New best! (+"..tostring(round - lplr.GameStats.BestRound.Value)..")"
			summaryGui.NewBest.Visible = true
		end

		summaryGui.ZombiesKilled.Text = "Zombies killed: "..tostring(lplr.GameStats.ZombiesKilled.Value - totalNumberOfZombiesKilled)
		summaryGui.CoinsEarnt.Text = "Coins earnt: "..tostring(lplr.GameStats.CoinsEarnt.Value)
	end
end)


PlayAgainStatusRemoteEvent.OnClientEvent:Connect(function(player : string, status : number)
	if DeathGui.Summary.Players:FindFirstChild(player) then

		DeathGui.Summary.Players[player].Waiting.Visible = false

		if status == 1 then
			DeathGui.Summary.Players[player].PlayAgain.Visible = true
		elseif status == 2 then
			DeathGui.Summary.Players[player].Quit.Visible = true
			DeathGui.Summary.Player1.Status.Visible = true
		end
	end
end)

-- waiting for all players to join the game text not updating