local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local coinsMultiplierGui : Frame = script.Parent:WaitForChild("Frame"):WaitForChild("Frame")

local lplr = Players.LocalPlayer

local oneAndAHalfCoinsMultiplierPassId : number = 0
local doubleCoinsMultiplierPassId : number = 0
local tripleCoinsMultiplierPassId : number = 0


-- check if the player owns the game pass x1.5 pass
local success, oneAndAHalfCoinsMultiplierPass : boolean = pcall(function()
	return MarketplaceService:UserOwnsGamePassAsync(lplr.UserId, oneAndAHalfCoinsMultiplierPassId)
end)

if success and oneAndAHalfCoinsMultiplierPass then
	coinsMultiplierGui.OneAndAHalf.Price.Text = "OWNED"
end

-- check if the player owns the game pass x2 pass
local success, doubleCoinsMultiplierPass : boolean = pcall(function()
	return MarketplaceService:UserOwnsGamePassAsync(lplr.UserId, doubleCoinsMultiplierPassId)
end)

if success and doubleCoinsMultiplierPass then
	coinsMultiplierGui.OneAndAHalf.Price.Text = "OWNED"
	coinsMultiplierGui.Double.Price.Text = "OWNED"
end

-- check if the player owns the game pass x3 pass
local success, tripleCoinsMultiplierPass : boolean = pcall(function()
	return MarketplaceService:UserOwnsGamePassAsync(lplr.UserId, tripleCoinsMultiplierPassId)
end)

if success and tripleCoinsMultiplierPass then
	coinsMultiplierGui.OneAndAHalf.Price.Text = "OWNED"
	coinsMultiplierGui.Double.Price.Text = "OWNED"
	coinsMultiplierGui.Triple.Price.Text = "OWNED"
end


-- prompt the game pass purchase when the player clicks on the image buttons
for _,v : Frame | UIListLayout in ipairs(coinsMultiplierGui:GetChildren()) do
	if v:IsA("Frame") then
		
		v.ImageButton.MouseButton1Down:Connect(function()
			if v.Price.Text ~= "OWNED" then
				
				if v.Name == "OneAndAHalf" then
					MarketplaceService:PromptGamePassPurchase(lplr, oneAndAHalfCoinsMultiplierPassId)
					
				elseif v.Name == "Double" then
					MarketplaceService:PromptGamePassPurchase(lplr, doubleCoinsMultiplierPassId)
					
				elseif v.Name == "Triple" then
					MarketplaceService:PromptGamePassPurchase(lplr, tripleCoinsMultiplierPassId)
				end
			end
		end)
	end
end


workspace:WaitForChild("GamepassesShops"):WaitForChild("CoinsMultiplier"):WaitForChild("ProximityPrompt"):WaitForChild("ProximityPrompt").Triggered:Connect(function(plr)
	if plr == lplr then
		script.Parent.Enabled = true
	end
end)


coinsMultiplierGui.Parent:WaitForChild("Close").MouseButton1Down:Connect(function()
	script.Parent.Enabled = false
end)