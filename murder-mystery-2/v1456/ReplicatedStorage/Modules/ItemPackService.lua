local ItemPackService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Remotes")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage3:WaitForChild("Remotes")
local profileDataChanged = remotes:WaitForChild("Inventory"):WaitForChild("ProfileDataChanged")
local getPack = remotes:WaitForChild("Shop"):WaitForChild("GetPack")
local purchaseWeaponPack = remotes:WaitForChild("Shop"):WaitForChild("PurchaseWeaponPack")
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local EventInfoService = require(ReplicatedStorage4:WaitForChild("SharedServices"):WaitForChild("EventInfoService"))
ItemPackService.ItemPacksChanged = Instance.new("BindableEvent")
local currentEvent = EventInfoService:GetCurrentEvent()
local currentItemPack = EventInfoService:GetCurrentItemPack()
local v = {}

if currentEvent and currentEvent.ItemPackItems then
	v.Knife = currentEvent.ItemPackItems.Knife
	v.Gun = currentEvent.ItemPackItems.Gun
	v.Bundle = currentEvent.ItemPackItems.Bundle
	v.Evo = currentEvent.ItemPackItems.Evo
elseif currentItemPack then
	v.Knife = currentItemPack.ItemPackItems.Knife
	v.Gun = currentItemPack.ItemPackItems.Gun
	v.Bundle = currentItemPack.ItemPackItems.Bundle
end

-- equivalent calls inferred from this helper; original call sites unknown
local function promptBuyItem(p: string)
	local itemPacks = ProfileData.ItemPacks
	local v2 = v[p]

	if itemPacks[tostring(v2.GamePassID)] == true then
		if p ~= "Evo" then
			purchaseWeaponPack:FireServer(v2.DevProductID)
		end
	else
		getPack:FireServer(v2.GamePassID)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function promptBuyBundle()
	promptBuyItem("Bundle") -- equivalent call inferred; original call site unknown
end

function ItemPackService.HasItemGamePass(_, p: string)
	return ProfileData.ItemPacks[tostring(v[p].GamePassID)] == true
end

function ItemPackService.PromptBuyKnife(_)
	promptBuyItem("Knife") -- equivalent call inferred; original call site unknown
end

function ItemPackService.PromptBuyGun(_)
	promptBuyItem("Gun") -- equivalent call inferred; original call site unknown
end

function ItemPackService.PromptBuyEvo(_)
	local itemPacks = ProfileData.ItemPacks
	local evo = v.Evo

	if itemPacks[tostring(evo.GamePassID)] == true then
		return
	end

	getPack:FireServer(evo.GamePassID)
end

function ItemPackService.PromptBuyBundle(_)
	promptBuyBundle() -- equivalent call inferred; original call site unknown
end

profileDataChanged.Event:Connect(function(p, _)
	if p ~= "ItemPacks" then
		return
	end

	ItemPackService.ItemPacksChanged:Fire()
end)
return ItemPackService