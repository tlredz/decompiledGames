local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local client = require3(ReplicatedStorage2.Packages.Replion).Client
local client2 = require3(ReplicatedStorage2.Shared.Inventory).Client
local v2 = require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoteFunction(p)
	if v2.isTradingPlazaServer() then
		return v:RemoteFunction(p)
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoteEvent(p)
	if v2.isTradingPlazaServer() then
		return v:RemoteEvent(p)
	end

	return nil
end

local remoteFunction = RemoteFunction("CreatingBoothListing") -- equivalent call inferred; original call site unknown
local remoteFunction2 = RemoteFunction("PurchaseBoothListing") -- equivalent call inferred; original call site unknown
local remoteFunction3 = RemoteFunction("RemoveBoothListing") -- equivalent call inferred; original call site unknown

if v2.isTradingPlazaServer() then
	v:RemoteFunction("EditBoothListing")
end

local remoteEvent = RemoteEvent("UnclaimBooth") -- equivalent call inferred; original call site unknown
local localPlayer = Players.LocalPlayer
local BoothController = {
	BoothListings = nil
}

if v2.isTradingPlazaServer() then
	BoothController.BoothListings = client:WaitReplion("BoothListings")
end

function BoothController.UnclaimBooth(_)
	remoteEvent:FireServer()
end

function BoothController.GetPlayerBoothListing(p, p2)
	return p.BoothListings:Get({ p2 }) or {}
end

function BoothController.PurchaseListing(_, owner, listingId: string)
	return remoteFunction2:InvokeServer({
		Owner = owner,
		ListingId = listingId
	})
end

function BoothController.CreateListing(_, p: string, itemKey: string, _: number, price: number)
	client2:KeyToItem(itemKey)
	return remoteFunction:InvokeServer({
		Type = p,
		ItemKey = itemKey,
		Amount = 1,
		Price = price
	})
end

function BoothController.DeleteListing(_, p: string)
	return remoteFunction3:InvokeServer(p)
end

function BoothController.FindInventoryTypeFromKey(_, p: string)
	for _, v7 in {
		"Sword",
		"Explosion",
		"Emote",
		"Ability",
		"Booth"
	} do
		if #client2:FindItemsWithKey(v7, p) > 0 then
			return v7
		end
	end

	return nil
end

function BoothController:UpdateProximityPrompts()
	local hasBooth = localPlayer:GetAttribute("HasBooth") == true

	for _, model in CollectionService:GetTagged("TradeBoothStand") do
		if not (model:IsA("Model") and model.PrimaryPart) then
			continue
		end

		local proximityPrompt = model.PrimaryPart:FindFirstChildWhichIsA("ProximityPrompt", true)

		if not proximityPrompt then
			continue
		end

		local owner = model:GetAttribute("Owner")
		proximityPrompt.Enabled = not hasBooth or owner ~= nil
	end
end

function BoothController:Start()
	if not v2.isTradingPlazaServer() then
		return
	end

	localPlayer:GetAttributeChangedSignal("HasBooth"):Connect(function()
		self:UpdateProximityPrompts()
	end)
end

return BoothController