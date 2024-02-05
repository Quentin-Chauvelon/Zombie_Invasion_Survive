local eventEndDate : number = os.time({
	year=2022,
	month=10,
	day=20, -- Date components
	hour=0,
	min=0,
	sec=0 -- Time components
})

local timeLeftTextLabel : TextLabel = workspace:WaitForChild("Event"):WaitForChild("CurrentEvent"):WaitForChild("BillboardGui"):WaitForChild("TimeLeft")


while true do
	local timeLeft : number = os.difftime(eventEndDate, os.time())

	local daysLeft : number = math.floor(timeLeft / 86400)
	timeLeft -= daysLeft * 86400

	local hoursLeft : number = math.floor(timeLeft / 3600)
	timeLeft -= hoursLeft * 3600 

	local minutesLeft : number = math.floor(timeLeft / 60)
	
	timeLeftTextLabel.Text = "Ends in:"..tostring(daysLeft).." days, "..tostring(hoursLeft).."hours, "..tostring(minutesLeft).." minutes" 
	
	task.wait(60)
end