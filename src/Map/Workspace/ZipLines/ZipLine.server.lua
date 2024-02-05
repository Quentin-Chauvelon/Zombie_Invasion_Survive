local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Utilities = require(ServerScriptService:WaitForChild("Utilities"))

local lineEnd : Folder = script.Parent:WaitForChild("LineEnd")
local zipLines : Folder = ServerStorage:WaitForChild("ZipLines")
local seats = script.Parent:WaitForChild("Seats")

local tweenInfo : TweenInfo = TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local function DetectPlayerSeatedOnSeat(seat : Seat)
	seat:GetPropertyChangedSignal("Occupant"):Connect(function()

		-- if the zone is unlocked
		if seat.Name == "Casino" or seat.Name == "Bank" or Utilities:IsZoneUnlocked(seat.Name) then


			if seat.Occupant and lineEnd:FindFirstChild(seat.Name) then

				local zipLineTweeen : Tween = TweenService:Create(seat, tweenInfo, {CFrame = lineEnd[seat.Name].CFrame})
				zipLineTweeen:Play()
				
				zipLineTweeen.Completed:Wait()

				-- unsit the player before destroying the seat and spawning a new one back at the top of the skyscraper
				if seat.Occupant then
					seat.Occupant.Sit = false
				end

				task.wait(0.2)

				seat:Destroy()
				
				-- clone the new one at the top to be able to ride again
				if zipLines:FindFirstChild(seat.Name) then
					local seatClone = zipLines[seat.Name]:Clone()
					
					-- allow the seat to detect when someone seats to ride the zip line
					DetectPlayerSeatedOnSeat(seatClone)
					
					seatClone.Parent = seats
				end
			end
		end
	end)
end


-- when the player seats, tween the seat from the top of the skyscraper to the desired zone
for _,v : Seat in ipairs(seats:GetChildren()) do
	DetectPlayerSeatedOnSeat(v)
end