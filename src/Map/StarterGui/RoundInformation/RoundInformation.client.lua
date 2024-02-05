local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundInformationRemoteEvent = ReplicatedStorage:WaitForChild("RoundInformation")
local CountdownRemoteEvent = ReplicatedStorage:WaitForChild("Countdown")
local TimerRemoteEvent = ReplicatedStorage:WaitForChild("Timer")
local UpdateZombieCount = ReplicatedStorage:WaitForChild("UpdateZombieCount")

local roundInformationGui = script.Parent

local zombiesLeftGui = roundInformationGui:WaitForChild("ZombiesLeft")

local countdown = false
local timerRunning = false
local totalTimeEllapsed = 0


-- change the round and timer texts at the top of the screen when the server fires the remote event
RoundInformationRemoteEvent.OnClientEvent:Connect(function(textLabelName : string, text : string, text2 : string?)
	
	-- change both text labels at once (rather than firing twice the remote event)
	if textLabelName and textLabelName == "Both" then
		if text and text2 then
			roundInformationGui.Round.Text = text
			roundInformationGui.Timer.Text = text2
		end
		
	else
		if roundInformationGui:FindFirstChild(textLabelName) and text then
			roundInformationGui[textLabelName].Text = text
			
			-- if it's round 30, tell the player that their health will be decreased
			if textLabelName == "Round" and text == "Round 30 starting in: 15" then
				roundInformationGui.Round30.Visible = true
				
				coroutine.wrap(function()
					wait(15)
					roundInformationGui.Round30.Visible = false
				end)()
			end
		end
	end
end)


-- start a countodwn on the given text label when the server fires the remote event
CountdownRemoteEvent.OnClientEvent:Connect(function(textLabelName : string, text : string, timeToCountdown : number)
	
	-- if a countdown is running, stop it
	if countdown then
		countdown = false
		
		-- wait for the running countodwn to have stopped before starting a new one (otherwise both will run at the same time)
		wait(1)
	end
	
	if roundInformationGui:FindFirstChild(textLabelName) and text then
		
		-- countdown
		coroutine.wrap(function()
			countdown = true
			
			for i = timeToCountdown,0,-1 do
				
				if not countdown then break end

				roundInformationGui[textLabelName].Text = text..tostring(i)
				wait(1)
			end
			
			countdown = false
		end)()
	end
end)


-- runs the timer (text at the top of the screen)
local function RunTimer()
	timerRunning = true
	
	-- while the timer is not being pause
	while timerRunning do
		wait(1)
		totalTimeEllapsed += 1
		roundInformationGui.Timer.Text = string.format("%02i : %02i", math.floor(totalTimeEllapsed / 60), math.floor(totalTimeEllapsed % 60))
		--roundInformationGui.Timer.Text = tostring(math.floor(totalTimeEllapsed / 60)).." : "..tostring(math.floor(totalTimeEllapsed % 60))
	end
end



-- change the state of the overall timer when the server fires the remote event
TimerRemoteEvent.OnClientEvent:Connect(function(action : string, timeSinceLastResume : number?)
	
	-- start the timer
	if action == "Start" then
		countdown = false
		wait(1)
		RunTimer()

	-- pause the timer
	elseif action == "Pause" then
		timerRunning = false
		
		-- change the based on the time of the server after each round (to avoid the timer being off by too much)
		if timeSinceLastResume then
			totalTimeEllapsed = timeSinceLastResume
		end
		
	-- resume the timer
	elseif action == "Resume" then
		RunTimer()
	end
end)


-- update the number of zombies left in the round (in the bottom right hand corner)
UpdateZombieCount.OnClientEvent:Connect(function(zombiesLeft : number)
	zombiesLeftGui.Text = zombiesLeft
end)