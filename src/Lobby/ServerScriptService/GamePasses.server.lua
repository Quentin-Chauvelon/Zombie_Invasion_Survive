local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TextService = game:GetService("TextService")
local ServerStorage = game:GetService("ServerStorage")
local zombiePet : Model = ServerStorage:WaitForChild("ZombiePet")
local titleToClone : BillboardGui = ServerStorage:WaitForChild("Title")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FilterTitleRemoteFunction = ReplicatedStorage:WaitForChild("FilterTitle")

local titlePassId : number = 86188278
--local weaponsSkinsPassId: number = 0
--local sparklesSkinsPassId: number = 0
--local hitHighlightColorSkinsPassId: number = 0
--local ZombieSkinsPassId: number = 0
local zombiePetPassId: number = 86190437


local function AddPetToPlayer(plr : Player)
	local character : Model = workspace:WaitForChild(plr.Name)

	local pet = zombiePet:Clone()
	pet:PivotTo(character:WaitForChild("HumanoidRootPart").CFrame)

	local modelSize : Vector3 = pet.PetSize.Size

	local characterAttachment : Attachment = Instance.new("Attachment")
	characterAttachment.Position = Vector3.new(2,1,0) * modelSize
	characterAttachment.Parent = character.HumanoidRootPart

	local petAttachment : Attachment = Instance.new("Attachment")
	petAttachment.Parent = pet.PrimaryPart

	local alignPosition : AlignPosition = Instance.new("AlignPosition")
	alignPosition.Attachment0 = petAttachment
	alignPosition.Attachment1 = characterAttachment
	alignPosition.MaxForce = 25000
	alignPosition.Responsiveness = 25
	alignPosition.Parent = pet.PrimaryPart

	local alignOrientation : AlignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = petAttachment
	alignOrientation.Attachment1 = characterAttachment
	alignOrientation.MaxTorque = 50000
	alignOrientation.Responsiveness = 15
	alignOrientation.Parent = pet.PrimaryPart

	pet.Parent = character
end


Players.PlayerAdded:Connect(function(plr)
	
	
	-- check if the player owns the game pass
	local success, zombiePetPass : boolean = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(plr.UserId, zombiePetPassId)
	end)
	
	if success and zombiePetPass then
		AddPetToPlayer(plr)
	end
end)


-- filter the text the player wants to use
FilterTitleRemoteFunction.OnServerInvoke = function(plr : Player, title : string)
	if title and typeof(title) == "string" and #title <= 16 then
		local success, filteredText = pcall(function()
			return TextService:FilterStringAsync(title, plr.UserId)
		end)
		
		if success and filteredText then
			return true
		end
	end

	return false
end


-- player wants to purchase a gamepass
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr : Player, purchasedPassID : number, purchaseSuccess : boolean)
	
	if purchaseSuccess == true then
		
		if purchasedPassID == titlePassId then

			plr.Title.Value = true

			if plr.Character then
				titleToClone:Clone().Parent = plr.Character.Head
			end
			
		elseif purchasedPassID == zombiePetPassId then
			AddPetToPlayer(plr)
		end
	end
end)