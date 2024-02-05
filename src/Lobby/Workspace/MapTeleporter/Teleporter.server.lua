local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local mapTeleporter : Part = workspace:WaitForChild("MapTeleporter"):WaitForChild("MapTeleporter")
local lobbyTeleporter : Part = workspace:WaitForChild("MapTeleporter"):WaitForChild("LobbyTeleporter")
local mapSpawn : Part = workspace.MapTeleporter:WaitForChild("Spawn")
local spawnLocation : SpawnLocation = workspace:WaitForChild("SpawnLocation")

local TeleporterColorChangeDuration : number = 3


-- teleport players to the map on teleporter touch
mapTeleporter.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and Players:GetPlayerFromCharacter(hit.Parent) then
		hit.CFrame = mapSpawn.CFrame
	end
end)


-- teleport players back to the lobby on teleporter touch
lobbyTeleporter.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and Players:GetPlayerFromCharacter(hit.Parent) then
		hit.Position = spawnLocation.Position + Vector3.new(0,5,0)
	end
end)



-- tween the teleporter from its current color to the colorGoal value
local function TweenTeleporterColor(colorGoal : Color3) : Tween
	
	local tween : Tween = TweenService:Create(mapTeleporter, TweenInfo.new(TeleporterColorChangeDuration), {Color = colorGoal})
	tween:Play()
	
	return tween
end


-- tween the teleporter color to get a rainbow effect
coroutine.wrap(function()
	while true do
		TweenTeleporterColor(Color3.new(1,0,0)).Completed:Wait()
		TweenTeleporterColor(Color3.new(1,1,0)).Completed:Wait()
		TweenTeleporterColor(Color3.new(0,1,0)).Completed:Wait()
		TweenTeleporterColor(Color3.new(0,1,1)).Completed:Wait()
		TweenTeleporterColor(Color3.new(0,0,1)).Completed:Wait()
		TweenTeleporterColor(Color3.new(1,0,1)).Completed:Wait()
	end
end)()