local Players = game:GetService("Players")

local playersThumbnails : {string} = {}

local Utilities = {}


-- get the thumbnails of all the players
function Utilities:GetThumbnailsOfAllPlayers() : {string}
	return playersThumbnails
end


-- get the thumbnail of the specified player
function Utilities:GetThumbnailForPlayer(playerName : string) : string
	if playerName then

		-- if the player is in the server, use the cached thumbnail id, otherwise query the roblox website
		if playersThumbnails[playerName] then
			return playersThumbnails[playerName]

		else
			local userId : number? = Players:GetUserIdFromNameAsync(playerName)
			
			if userId then
				return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			end
		end
	end
	
	return ""
end


-- add the player thumbnail to the playersThumbnails table on added
Players.PlayerAdded:Connect(function(plr : Player)
	local playerThumbnail, isReady = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	
	if playerThumbnail then
		playersThumbnails[plr.Name] = playerThumbnail
	end
end)


-- add all the players that already connected to the playersThumbnails table because module scripts only run once they are required, thus the player are added before the script runs
for _,player : Player in ipairs(Players:GetPlayers()) do
	if not playersThumbnails[player.Name] then
		
		local playerThumbnail, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		if playerThumbnail then
			playersThumbnails[player.Name] = playerThumbnail
		end
	end
end


-- remove the player thumbnail from the playersThumbnails table on leave
Players.PlayerRemoving:Connect(function(plr : Player)
	if playersThumbnails[plr.Name] then
		playersThumbnails[plr.Name] = nil
	end
end)

return Utilities