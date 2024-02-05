local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TimerRemoteEvent = ReplicatedStorage:WaitForChild("Timer")

local Utilities = {}

local lastPauseTime : number = 0
local totalTime : number = 0

--[[
Checks if the player has enough coins

Params : 
plr : The player who wants to buy something
value : The amount of coins needed

Return :
Boolean (true if the player has enough coins, false otherwise)
]]--
function Utilities:PlayerHasEnoughCoins(plr : Player, value : number) : boolean
	
	if plr and value and typeof(value) == "number" and plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Coins") then
		return plr.leaderstats.Coins.Value >= value
	end
	
	return false
end


--[[
Remove coins from a player

Params : 
plr : The player whom the coins will be removed from
value : The amount of coins to remove

Return :
Boolean (true if the coins were successfully removed, false otherwise)
]]--
function Utilities:RemoveCoins(plr : Instance, value : number)
	
	if plr and value and typeof(value) == "number" and plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Coins") then
		plr.leaderstats.Coins.Value -= value
		return true
	end
	
	return false
end


--[[
Check if the zone has been unlocked

Params : 
zone : A string representing the zone

Return :
Boolean (true if the zone has been unlocked, false otherwise)
]]--
function Utilities:IsZoneUnlocked(zone : string) : boolean
	
	if zone and typeof(zone) == "string" and workspace.LockedZones:FindFirstChild(zone) then
		return workspace.LockedZones[zone].Value == false
		
	else
		return false
	end
end


--[[
Check if the player already has the specified tool

Params : 
plr : The player who may have the tool
toolName : the name of the tool

Return :
Boolean (true if the player already has the tool, false otherwise)
]]--
function Utilities:PlayerAlreadyHasTool(plr : Player, toolName : string) : boolean
	
	if plr and toolName and typeof(toolName) == "string" and plr.Character then
		
		if plr.Character:FindFirstChild(toolName) or plr.Backpack:FindFirstChild(toolName) then
			return true
		end
		
	end
	
	return false
end


--[[
Give the specified tool to the player

Params : 
plr : The player who will receive the tool
toolName : the name of the tool

Return :
Tool (the tool created using the toolName, nil otherwise)
]]--
function Utilities:GiveToolToPlayer(plr : Player, toolName : string) : Tool?
	
	if plr and toolName and typeof(toolName) == "string" and plr.Character and ServerStorage:WaitForChild("Tools"):FindFirstChild(toolName) then
		if not plr.Character:FindFirstChild(toolName) and not plr.Backpack:FindFirstChild(toolName) then

			-- if player already as a tool equipped, set its parent to the player's backpack
			if plr.Character:FindFirstChildOfClass("Tool") then
				plr.Character:FindFirstChildOfClass("Tool").Parent = plr.Backpack
			end

			local tool = ServerStorage.Tools[toolName]:Clone()
			tool.Parent = plr.Character

			return tool
		end
	end

	return nil
end


--[[
Check if the player already bought the specified piece of armor or a better one

Params : 
plr : The player who may have bought the armor
piece : The name of the piece of armor the player wants to buy (helmet, chestplate, pants, boots)
defense : The defense of the piece the player wants to buy

Return :
Boolean (true if the player already bought the armor or a better one, false otherwise)
]]--
function Utilities:PlayerAlreadyHasArmor(plr : Player, piece : string, defense : number) : boolean

	if plr and piece and defense and typeof(piece) == "string" and typeof(defense) == "number"
		and plr:FindFirstChild("Stats") and plr.Stats:FindFirstChild("Defense") and plr.Stats.Defense:FindFirstChild(piece) then

		if plr.Stats.Defense[piece].Value >= defense then
			return true
		end

		return false
	end
end


--[[
Check if the player already bought the specified piece of armor or a better one

Params : 
plr : The player who may have bought the armor
piece : The name of the piece of armor the player wants to buy (helmet, chestplate, pants, boots)
defense : The defense of the piece the player wants to buy

Return :
Boolean (true if the player already bought the armor or a better one, false otherwise)
]]--
function Utilities:GiveArmorToPlayer(plr : Player, piece : string, defense : number)

	if plr and piece and defense and typeof(piece) == "string" and typeof(defense) == "number" and
		plr:FindFirstChild("Stats") and plr.Stats:FindFirstChild("Defense") and plr.Stats.Defense:FindFirstChild(piece) then

		plr.Stats.Defense[piece].Value = defense
		
		-- calculate the total defense of the player
		if plr.Stats:FindFirstChild("TotalDefense") then
			local sum = 0
			
			for _,v in ipairs(plr.Stats.Defense:GetChildren()) do
				sum += v.Value
			end
			
			plr.Stats.TotalDefense.Value = sum
		end
	end
end


--[[
Starts the timer (that is displayed at the top)
]]--
function Utilities:StartTimer()
	lastPauseTime = os.time()
	TimerRemoteEvent:FireAllClients("Start")
end


--[[
Pauses the timer (that is displayed at the top)
]]--
function Utilities:PauseTimer()
	
	-- get time since last pause and add it to the total time ellapsed
	totalTime += os.time() - lastPauseTime
	TimerRemoteEvent:FireAllClients("Pause", totalTime)
end


--[[
Resumes the timer (that is displayed at the top)
]]--
function Utilities:ResumeTimer()
	lastPauseTime = os.time()
	TimerRemoteEvent:FireAllClients("Resume")
end


function Utilities:GetTime() : number
	return totalTime
end

return Utilities