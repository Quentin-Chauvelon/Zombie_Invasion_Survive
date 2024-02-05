local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local starterPacksGui : Frame = script.Parent:WaitForChild("Frame"):WaitForChild("Frame")

local lplr = Players.LocalPlayer

local basicStarterPackPassId : number = 0
local proStarterPackPassId : number = 0
local undeadStarterPackPassId : number = 0
local ultimateStarterPackPassId : number = 0


-- check if the player owns the game pass basic pack
local success, BasicStarterPackPass : boolean = pcall(function()
	return MarketplaceService:UserOwnsGamePassAsync(lplr.UserId, basicStarterPackPassId)
end)

if success and BasicStarterPackPass then
	starterPacksGui.BasicPack.ImageButton.Price.Text = "OWNED"
end

-- check if the player owns the game pass pro pack
local success, proStarterPackPassId : boolean = pcall(function()
	return MarketplaceService:UserOwnsGamePassAsync(lplr.UserId, proStarterPackPassId)
end)

if success and proStarterPackPassId then
	starterPacksGui.BasicPack.ImageButton.Price.Text = "OWNED"
	starterPacksGui.ProPack.ImageButton.Price.Text = "OWNED"
end

-- check if the player owns the game pass undead pack
local success, undeadStarterPackPass : boolean = pcall(function()
	return MarketplaceService:UserOwnsGamePassAsync(lplr.UserId, undeadStarterPackPassId)
end)

if success and undeadStarterPackPass then
	starterPacksGui.BasicPack.ImageButton.Price.Text = "OWNED"
	starterPacksGui.ProPack.ImageButton.Price.Text = "OWNED"
	starterPacksGui.UndeadPack.ImageButton.Price.Text = "OWNED"
end


-- check if the player owns the game pass ultimate pack
local success, ultimateStarterPackPass : boolean = pcall(function()
	return MarketplaceService:UserOwnsGamePassAsync(lplr.UserId, ultimateStarterPackPassId)
end)

if success and ultimateStarterPackPass then
	starterPacksGui.BasicPack.ImageButton.Price.Text = "OWNED"
	starterPacksGui.ProPack.ImageButton.Price.Text = "OWNED"
	starterPacksGui.UndeadPack.ImageButton.Price.Text = "OWNED"
	starterPacksGui.UltimatePack.ImageButton.Price.Text = "OWNED"
end


-- prompt the game pass purchase when the player clicks on the image buttons
for _,v : Frame | UIListLayout in ipairs(starterPacksGui:GetChildren()) do
	if v:IsA("Frame") then
		
		v.ImageButton.MouseButton1Down:Connect(function()
			if v.Price.Text ~= "OWNED" then
				
				if v.Name == "BasicPack" then
					MarketplaceService:PromptGamePassPurchase(lplr, basicStarterPackPassId)
					
				elseif v.Name == "ProPack" then
					MarketplaceService:PromptGamePassPurchase(lplr, proStarterPackPassId)
					
				elseif v.Name == "UndeadPack" then
					MarketplaceService:PromptGamePassPurchase(lplr, undeadStarterPackPassId)
					
				elseif v.Name == "UltimatePack" then
					MarketplaceService:PromptGamePassPurchase(lplr, ultimateStarterPackPassId)
				end
			end
		end)
	end
end


workspace:WaitForChild("GamepassesShops"):WaitForChild("StarterPacks"):WaitForChild("ProximityPrompt"):WaitForChild("ProximityPrompt").Triggered:Connect(function(plr)
	if plr == lplr then
		script.Parent.Enabled = true
	end
end)


starterPacksGui.Parent:WaitForChild("Close").MouseButton1Down:Connect(function()
	script.Parent.Enabled = false
end)