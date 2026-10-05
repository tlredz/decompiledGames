local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FakePurchasePromptView = require(ReplicatedStorage.Modules.Client.Monetization.FakePurchasePrompt.FakePurchasePromptView)
local FakePurchasePromptAvailability = require(ReplicatedStorage.Modules.Shared.Monetization.FakePurchasePromptAvailability)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local t = require(ReplicatedStorage.Packages.t)
local v = nil
local interface = t.interface({
	productId = t.number,
	purchaseType = t.union(t.literal("GamePass"), t.literal("Product")),
	name = t.string,
	priceInRobux = t.optional(t.number),
	iconAssetId = t.optional(t.number)
})

-- equivalent calls inferred from this helper; original call sites unknown
local function showPrompt(p)
	if v ~= nil then
		v:Destroy()
		v = nil
	end

	local v2 = FakePurchasePromptView.new(p)
	v = v2
	v2:Show(function(flag: boolean)
		if v ~= v2 then
			return
		end

		v2:Destroy()
		v = nil

		if p.purchaseType == "GamePass" then
			Remotes.fireServer("FakePromptGamePassPurchaseResult", p.productId, flag)
		else
			Remotes.fireServer("FakePromptProductPurchaseResult", p.productId, flag)
		end
	end)
end

local function onPromptReceived(p)
	if not interface(p) then
		return
	end

	showPrompt(p) -- equivalent call inferred; original call site unknown
end

local FakePurchasePromptController = {}

function FakePurchasePromptController.FrameworkInit() end

function FakePurchasePromptController.FrameworkStart()
	if not FakePurchasePromptAvailability.isAvailable() then
		return
	end

	Remotes.connect("FakePromptProductPurchase", onPromptReceived)
	Remotes.connect("FakePromptGamePassPurchase", onPromptReceived)
end

return FakePurchasePromptController