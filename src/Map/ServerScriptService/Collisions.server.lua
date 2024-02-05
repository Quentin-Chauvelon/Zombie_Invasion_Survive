--local Players = game:GetService("Players")
--local PhysicsService = game:GetService("PhysicsService")

--local playerCollisionGroup : string = "PlayerCollisions"

--PhysicsService:CreateCollisionGroup(playerCollisionGroup)
--PhysicsService:CollisionGroupSetCollidable(playerCollisionGroup, playerCollisionGroup, false)
--PhysicsService:CollisionGroupSetCollidable(playerCollisionGroup, zombieCollisionGroup, false)


---- add all the parts of the player to the collision group to disable them
--local function onCharacterAdded(character : Model)
--	print("adding all parts to collision group")
--	for _,v in ipairs(character:GetDescendants()) do
--		if v:IsA("BasePart") then
--			print("added part", v)
--			PhysicsService:SetPartCollisionGroup(v, playerCollisionGroup)
--		end
--	end
--end

--local function onPlayerAdded(player)
--	player.CharacterAdded:Connect(onCharacterAdded)
--end

--Players.PlayerAdded:Connect(onPlayerAdded)


local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local playerCollisionGroupName = "Players"
local zombieCollisionGroupName : string = "Zombies"
PhysicsService:CreateCollisionGroup(playerCollisionGroupName)
PhysicsService:CreateCollisionGroup(zombieCollisionGroupName)

-- remove the collisions between players
PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupName, playerCollisionGroupName, false)
-- remove the collisions between zombies
PhysicsService:CollisionGroupSetCollidable(zombieCollisionGroupName, zombieCollisionGroupName, false)
-- remove the collisions between the players and the zombies
PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupName, zombieCollisionGroupName, false)

local previousCollisionGroups = {}

local function setCollisionGroup(object)
	if object:IsA("BasePart") then
		previousCollisionGroups[object] = object.CollisionGroupId
		PhysicsService:SetPartCollisionGroup(object, playerCollisionGroupName)
	end
end

local function setCollisionGroupRecursive(object)
	setCollisionGroup(object)

	for _, child in ipairs(object:GetChildren()) do
		setCollisionGroupRecursive(child)
	end
end

local function resetCollisionGroup(object)
	local previousCollisionGroupId = previousCollisionGroups[object]
	if not previousCollisionGroupId then return end 

	local previousCollisionGroupName = PhysicsService:GetCollisionGroupName(previousCollisionGroupId)
	if not previousCollisionGroupName then return end

	PhysicsService:SetPartCollisionGroup(object, previousCollisionGroupName)
	previousCollisionGroups[object] = nil
end

local function onCharacterAdded(character)
	setCollisionGroupRecursive(character)

	character.DescendantAdded:Connect(setCollisionGroup)
	character.DescendantRemoving:Connect(resetCollisionGroup)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(onCharacterAdded)
end

Players.PlayerAdded:Connect(onPlayerAdded)