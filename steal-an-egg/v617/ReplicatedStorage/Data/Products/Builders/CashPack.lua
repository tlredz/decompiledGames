local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CashPacks = require(ReplicatedStorage.Data.CashPacks)
require(script.Parent.Parent.Internal.ProductTypes)

local function CreateCashPackProductConfig(name: string, productId: number)
	local slot = CashPacks.FindSlot(productId)
	assert(slot ~= nil, (`Unknown cash pack {productId}`))
	local offer = CashPacks.Offers[slot]
	assert(offer.Name == name, "Cash pack catalog key does not match its product")

	local function authorize(p3)
		local CashPackService = require(ServerScriptService.Controllers.CashPackService)

		if CashPackService.GetAmount(p3, slot) == nil then
			return false, "Your cash packs are still loading. Please try again."
		end

		return true
	end

	local function precheck()
		if CashPacks.GetShownAmount(Players.LocalPlayer, slot) == nil then
			return false, "Your cash packs are still loading. Please try again."
		end

		return true
	end

	local function grant(p3, p4)
		local CashPackService = require(ServerScriptService.Controllers.CashPackService)
		return CashPackService.Grant(p3, slot, p4)
	end

	return {
		Name = name,
		ProductId = productId,
		DisplayName = offer.DisplayName,
		Desc = "",
		HoldWhilePending = true,
		Silent = true,
		Precheck = precheck,
		Authorize = authorize,
		Grant = grant
	}
end

return CreateCashPackProductConfig