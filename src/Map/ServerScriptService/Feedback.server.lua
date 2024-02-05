local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FeedbackRemoteEvent = ReplicatedStorage:WaitForChild("Feedback")

local feedbackDataStore = DataStoreService:GetDataStore("Feedback")
local key : string = "feedback2"

local playersWhoAlreadySubmitted : {number} = {}


local function GetFeedbackTable(plr : Player, overallGrade : number, gameBalance : number, newFeature : number, expressYourself : string) : {number | string}
	-- create the feedback table to save the data
	local feedbackTable = {userId = plr.UserId}

	if overallGrade > 0 and overallGrade < 11 then
		feedbackTable.overallGrade = overallGrade
	end

	if gameBalance > 0 and gameBalance < 4 then
		feedbackTable.gameBalance = gameBalance
	end

	if newFeature > 0 and newFeature < 5 then
		feedbackTable.newFeature = newFeature
	end

	if #expressYourself < 302 then
		feedbackTable.expressYourself = expressYourself
	end
	
	return feedbackTable
end


FeedbackRemoteEvent.OnServerEvent:Connect(function(plr : Player, overallGrade : number, gameBalance : number, newFeature : number, expressYourself : string)
	if overallGrade and gameBalance and newFeature and expressYourself and typeof(overallGrade) == "number" and typeof(gameBalance) == "number" and typeof(newFeature) == "number" and typeof(expressYourself) == "string" then
		
		-- check if the player already tried to submit (to prevent datastore spamming)
		if not table.find(playersWhoAlreadySubmitted, plr.UserId) then
			table.insert(playersWhoAlreadySubmitted, plr.UserId)
			
			-- if the player hasn't already submitted feedback info
			local success, result = pcall(function()
				return feedbackDataStore:GetAsync(key)
			end)

			if success then

				if result then
					local userId : number = plr.UserId
					
					for _,v in ipairs(result) do
						if v[1] == userId then
							return
						end
					end

					local feedbackTable = GetFeedbackTable(plr, overallGrade, gameBalance, newFeature, expressYourself)
					if feedbackTable then

						-- add the feedback to the datastore
						local success, errormessage = pcall(function()
							feedbackDataStore:UpdateAsync(key, function(old)
								old = old or {}
								table.insert(old, feedbackTable)
								return old
							end)
						end)
					end
					
				else
					local feedbackTable = GetFeedbackTable(plr, overallGrade, gameBalance, newFeature, expressYourself)
					
					if feedbackTable then
						feedbackDataStore:SetAsync(key, feedbackTable)
					end
				end
			end
		end
	end
end)

--local DataStoreService = game:GetService("DataStoreService")
--local feedbackDataStore = DataStoreService:GetDataStore("Feedback")
--print(feedbackDataStore:GetAsync("feedback2"))