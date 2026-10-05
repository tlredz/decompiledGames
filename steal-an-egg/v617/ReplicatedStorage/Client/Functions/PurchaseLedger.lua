local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Products = require(ReplicatedStorage.Data.Products)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = nil
local v3 = {
	OwnedPerProfile = function(p: number)
		local v4 = Save.Peek()
		local products

		if v4 ~= nil then
			products = v4.Products
		end

		return type(products) == "table" and products[tostring(p)] == true
	end,
	AwaitingReceipt = function(p: number)
		return v[p] == true
	end,
	HasOpenTicket = function()
		return v2 ~= nil
	end,
	OpenTicket = function(skuId: number)
		local v4 = {
			SkuId = skuId,
			Live = true
		}
		v2 = v4
		task.delay(90, function()
			if v2 == v4 then
				v4.Live = false
				v2 = nil
			end
		end)
		return v4
	end,
	CloseTicket = function(p: number)
		local v4 = v2

		if v4 ~= nil and v4.SkuId == p then
			v4.Live = false
			v2 = nil
		end
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function settleReceipt(p: number)
	v[p] = nil
	v3.CloseTicket(p)
end

local function onPromptClosed(p: number, p2: number?, flag: boolean)
	if p ~= localPlayer.UserId or p2 == nil then
		return
	end

	v3.CloseTicket(p2)

	if not flag then
		v[p2] = nil
		return
	end

	local v4 = Products.FromProductId(p2)

	if v4 ~= nil and v4.OneTime and not v3.OwnedPerProfile(p2) then
		v[p2] = true
	end
end

if not RunService:IsClient() then
	return table.freeze(v3)
end

local storefront = Remotes.Storefront
storefront.PurchaseRejected.OnClientEvent:Connect(function(p)
	settleReceipt(p.ProductId) -- equivalent call inferred; original call site unknown
end)
storefront.PurchaseSettled.OnClientEvent:Connect(function(_, p)
	settleReceipt(p.ProductId) -- equivalent call inferred; original call site unknown
end)
storefront.ReceiptCleared.OnClientEvent:Connect(function(p: number, _: string, _: boolean?)
	settleReceipt(p) -- equivalent call inferred; original call site unknown
end)
MarketplaceService.PromptProductPurchaseFinished:Connect(onPromptClosed)
return table.freeze(v3)