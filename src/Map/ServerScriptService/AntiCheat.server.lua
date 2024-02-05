local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Utilities = require(ServerScriptService:WaitForChild("Utilities"))

local spawnLocation : SpawnLocation = workspace.SpawnLocation

for _,v : Part in ipairs(workspace.AntiCheatLockedZones:GetChildren()) do
	v.Touched:Connect(function(hit)
		
		-- if the zone is locked
		if not Utilities:IsZoneUnlocked(v.Name) then
			
			-- if it's a player, teleport him to the street
			if hit.Parent and Players:GetPlayerFromCharacter(hit.Parent) then
				hit.Parent:MoveTo(spawnLocation.Position + Vector3.new(0,5,0))
			end
		end
	end)
end