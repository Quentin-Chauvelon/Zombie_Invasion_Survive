local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local HuntBindableEvent : BindableEvent = ServerStorage:WaitForChild("Hunt")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateZombieCount = ReplicatedStorage:WaitForChild("UpdateZombieCount")
local UpdateHealth = ReplicatedStorage:WaitForChild("UpdateHealth")
local CountdownRemoteEvent = ReplicatedStorage:WaitForChild("Countdown")
local RoundInformationRemoteEvent = ReplicatedStorage:WaitForChild("RoundInformation")
local StartRoundRemoteEvent = ReplicatedStorage:WaitForChild("StartRound")

local Rounds = {}
local Zombies = require(ServerScriptService:WaitForChild("Zombies"))

-- stats of all the zombies
local zombiesStats = {
	NormalZombie = {
		Health = 100,
		Damage = 8,
		AttackSpeed = 0.6,
		Speed = 18,
		Coins = 8
	},

	FastZombie = {
		Health = 100,
		Damage = 5,
		AttackSpeed = 0.6,
		Speed = 22,
		Coins = 12
	},

	TankZombie = {
		Health = 500,
		Damage = 10,
		AttackSpeed = 0.5,
		Speed = 18,
		Coins = 15
	},

	BoomZombie = {
		Health = 40,
		Damage = 25,
		AttackSpeed = 0,
		Speed = 20,
		Coins = 23
	},

	BabyZombie = {
		Health = 100,
		Damage = 10,
		AttackSpeed = 0.3,
		Speed = 21,
		Coins = 27
	},
	
	LeatherZombie = {
		Health = 125,
		Damage = 10,
		AttackSpeed = 0.6,
		Speed = 18,
		Coins = 12
	},
	
	ChainsZombie = {
		Health = 150,
		Damage = 15,
		AttackSpeed = 0.6,
		Speed = 19,
		Coins = 17
	},
	
	IronZombie = {
		Health = 175,
		Damage = 20,
		AttackSpeed = 0.6,
		Speed = 20,
		Coins = 21
	},
	
	DiamondZombie = {
		Health = 200,
		Damage = 25,
		AttackSpeed = 0.6,
		Speed = 20,
		Coins = 25
	},
	
	GiantZombie = {
		Health = 250,
		Damage = 30,
		AttackSpeed = 1,
		Speed = 18,
		Coins = 30
	},
	
	FireZombie = {
		Health = 150,
		Damage = 11,
		AttackSpeed = 0.6,
		Speed = 20,
		Coins = 23
	},

	PoisonZombie = {
		Health = 150,
		Damage = 11,
		AttackSpeed = 0.6,
		Speed = 20,
		Coins = 23
	},

	IceZombie = {
		Health = 150,
		Damage = 11,
		AttackSpeed = 0.6,
		Speed = 20,
		Coins = 23
	}
}

-- number of zombies to spawn per rounds
local zombiesPerRounds = {
	
	-- round 1
	{
		NormalZombie = 8
	},
	
	-- round 2
	{
		NormalZombie = 17,
		FastZombie = 3
	},
	
	-- round 3
	{
		NormalZombie = 20,
		FastZombie = 10,
		TankZombie = 5
	},
	
	-- round 4
	{
		NormalZombie = 20,
		FastZombie = 15,
		TankZombie = 12,
		BoomZombie = 3
	},

	-- round 5
	{
		LeatherZombie = 50,
		FastZombie = 7,
		TankZombie = 7,
		BoomZombie = 6
	},

	-- round 6
	{
		LeatherZombie = 40,
		FastZombie = 10,
		TankZombie = 10,
		BoomZombie = 10,
		BabyZombie = 10
	},

	-- round 7
	{
		LeatherZombie = 10,
		FastZombie = 20,
		TankZombie = 20,
		BoomZombie = 20,
		BabyZombie = 10
	},

	-- round 8
	{
		LeatherZombie = 30,
		FastZombie = 20,
		TankZombie = 20,
		BoomZombie = 20,
		BabyZombie = 10
	},

	-- round 9
	{
		LeatherZombie = 10,
		FastZombie = 30,
		TankZombie = 20,
		BoomZombie = 20,
		BabyZombie = 20
	},

	-- round 10
	{
		ChainsZombie = 30,
		FastZombie = 20,
		TankZombie = 20,
		BoomZombie = 20,
		BabyZombie = 20,
		FireZombie = 5
	},

	-- round 11
	{
		ChainsZombie = 15,
		FastZombie = 22,
		TankZombie = 22,
		BoomZombie = 22,
		BabyZombie = 22,
		FireZombie = 22
	},

	-- round 12
	{
		ChainsZombie = 15,
		FastZombie = 22,
		TankZombie = 22,
		BoomZombie = 22,
		BabyZombie = 22,
		FireZombie = 22,
		PoisonZombie = 5
	},
	
	-- round 13
	{
		ChainsZombie = 8,
		FastZombie = 22,
		TankZombie = 22,
		BoomZombie = 22,
		BabyZombie = 22,
		FireZombie = 22,
		PoisonZombie = 22
	},

	-- round 14
	{
		ChainsZombie = 8,
		FastZombie = 22,
		TankZombie = 22,
		BoomZombie = 22,
		BabyZombie = 22,
		FireZombie = 22,
		PoisonZombie = 22,
		IceZombie = 5
	},

	-- round 15
	{
		IronZombie = 40,
		FastZombie = 16,
		TankZombie = 16,
		BoomZombie = 16,
		BabyZombie = 16,
		FireZombie = 17,
		PoisonZombie = 17,
		IceZombie = 17
	},

	-- round 16
	{
		IronZombie = 30,
		FastZombie = 10,
		TankZombie = 10,
		BoomZombie = 10,
		BabyZombie = 10,
		FireZombie = 30,
		PoisonZombie = 30,
		IceZombie = 30
	},

	-- round 17
	{
		IronZombie = 30,
		FastZombie = 50,
		TankZombie = 10,
		BoomZombie = 10,
		BabyZombie = 10,
		FireZombie = 20,
		PoisonZombie = 20,
		IceZombie = 20
	},

	-- round 18
	{
		IronZombie = 30,
		FastZombie = 10,
		TankZombie = 10,
		BoomZombie = 50,
		BabyZombie = 10,
		FireZombie = 23,
		PoisonZombie = 23,
		IceZombie = 24
	},

	-- round 19
	{
		IronZombie = 30,
		FastZombie = 10,
		TankZombie = 10,
		BoomZombie = 10,
		BabyZombie = 50,
		FireZombie = 26,
		PoisonZombie = 27,
		IceZombie = 27
	},

	-- round 20
	{
		DiamondZombie = 70,
		FastZombie = 10,
		TankZombie = 10,
		BoomZombie = 10,
		BabyZombie = 10,
		FireZombie = 30,
		PoisonZombie = 30,
		IceZombie = 30
	},

	-- round 21
	{
		DiamondZombie = 30,
		FastZombie = 10,
		TankZombie = 10,
		BoomZombie = 30,
		BabyZombie = 30,
		FireZombie = 30,
		PoisonZombie = 30,
		IceZombie = 30
	},

	-- round 22
	{
		DiamondZombie = 30,
		FastZombie = 5,
		TankZombie = 5,
		BoomZombie = 40,
		BabyZombie = 40,
		FireZombie = 30,
		PoisonZombie = 30,
		IceZombie = 30
	},

	-- round 23
	{
		DiamondZombie = 30,
		FastZombie = 5,
		TankZombie = 5,
		BoomZombie = 30,
		BabyZombie = 30,
		FireZombie = 40,
		PoisonZombie = 40,
		IceZombie = 40
	},

	-- round 24
	{
		DiamondZombie = 30,
		FastZombie = 5,
		TankZombie = 5,
		BoomZombie = 40,
		BabyZombie = 40,
		FireZombie = 40,
		PoisonZombie = 40,
		IceZombie = 40
	},

	-- round 25
	{
		DiamondZombie = 20,
		FastZombie = 5,
		TankZombie = 5,
		BoomZombie = 50,
		BabyZombie = 50,
		FireZombie = 40,
		PoisonZombie = 40,
		IceZombie = 40
	},

	-- round 26
	{
		DiamondZombie = 20,
		FastZombie = 5,
		TankZombie = 5,
		BoomZombie = 40,
		BabyZombie = 40,
		FireZombie = 50,
		PoisonZombie = 50,
		IceZombie = 50
	},

	-- round 27
	{
		DiamondZombie = 10,
		FastZombie = 5,
		TankZombie = 5,
		BoomZombie = 50,
		BabyZombie = 50,
		FireZombie = 50,
		PoisonZombie = 50,
		IceZombie = 50
	},

	-- round 28
	{
		DiamondZombie = 30,
		BoomZombie = 50,
		BabyZombie = 50,
		FireZombie = 50,
		PoisonZombie = 50,
		IceZombie = 50
	},

	-- round 29
	{
		DiamondZombie = 40,
		BoomZombie = 50,
		BabyZombie = 50,
		FireZombie = 50,
		PoisonZombie = 50,
		IceZombie = 50
	},

	-- round 30
	{
		DiamondZombie = 40,
		FastZombie = 30,
		TankZombie = 30,
		BoomZombie = 40,
		BabyZombie = 40,
		FireZombie = 50,
		PoisonZombie = 50,
		IceZombie = 50
	},
}

local currentRound : number = 1


--[[
Starts a ronud and creates all the zombies for said round
]]--
function Rounds:StartRound()
	
	-- reset the players abilities
	
	for _,player : Player in ipairs(Players:GetPlayers()) do
		player.Ability1Used.Value = false
		player.Ability2Used.Value = false

		StartRoundRemoteEvent:FireClient(player)
	end
	
	-- if the round is after 30 and before 50, decrease the player health
	if currentRound > 30 then

		if currentRound <= 50 then
			-- destroy the health machine is it's the 30th round
			if currentRound == 30 then
				if workspace.Machines:FindFirstChild("HealthMachine") then
					workspace.Machines.HealthMachine:Destroy()
				end
			end

			-- decrease all the players health by 10 every round until round 50
			for _,player : Player in ipairs(Players:GetPlayers()) do
				local maxHealth = player.Stats:FindFirstChild("MaxHelath")
				local health = player.Stats:FindFirstChild("Health")

				if health and maxHealth then
					-- decrease the max health
					if maxHealth.Value > 10 then
						maxHealth.Value -= 10

						-- if the health is greater than the max health, decrease the health
						if health.Value > maxHealth.Value then
							health.Value = maxHealth.Value
						end
					end
				end

				UpdateHealth:FireAllClients(player)
			end
			
		-- if we are after round 50
		else
			if zombiesPerRounds[30] then
				for i,_ in pairs(zombiesPerRounds[30]) do
					if zombiesPerRounds[30][i] then
						zombiesPerRounds[30][i] += 2
					end
				end
			end
		end
	end
	
	-- spawn the zombies
	if zombiesPerRounds[math.min(currentRound, 30)] then
		
		-- move all zombies towards players
		HuntBindableEvent:Fire()

		for name : string, v : number in pairs(zombiesPerRounds[math.min(currentRound, 30)]) do
			local index : number = 1

			if zombiesStats[name] then
				local zombieStats = zombiesStats[name]

				while index <= v do
					for _,spawner : Part in ipairs(workspace.UnlockedSpawners:GetChildren()) do
						
						--Zombies.new(name, zombieStats["Health"], zombieStats["Damage"], zombieStats["AttackSpeed"], zombieStats["Speed"], zombieStats["Coins"], spawner.Position)
						Zombies.new(name, spawner.Position)
						index += 1

						if index > v then
							break
						end

						wait(0.3)
					end
				end
			end
		end
		
		UpdateZombieCount:FireAllClients(#workspace.Zombies:GetChildren())
	end
end


function Rounds:EndOfRound()
	currentRound += 1

	RoundInformationRemoteEvent:FireAllClients("Round", "Round "..tostring(currentRound).." starting in: 15")
	CountdownRemoteEvent:FireAllClients("Round", "Round "..tostring(currentRound).." starting in: ", 15)

	-- heal all players
	--for _, player : Player in ipairs(Players:GetPlayers()) do
	--	if player:FindFirstChild("Stats") and player.Stats:FindFirstChild("Health") and player.Stats:FindFirstChild("MaxHealth") then
	--		player.Stats.Health.Value = player.Stats.MaxHealth.Value
	--		UpdateHealth:FireAllClients(player)
	--	end
	--end

	coroutine.wrap(function()
		wait(17)

		RoundInformationRemoteEvent:FireAllClients("Round", "Round "..tostring(currentRound))

		Rounds:StartRound()
	end)()
end


function Rounds:GetRound() : number
	return currentRound
end

return Rounds