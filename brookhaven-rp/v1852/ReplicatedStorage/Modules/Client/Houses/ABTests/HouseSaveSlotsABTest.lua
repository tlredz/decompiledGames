local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local Promise = require(ReplicatedStorage.Packages.Promise)
local v = nil
local v2 = Promise.new(function(p)
	v = p
end)
local HouseSaveSlotsABTest = {
	enabled = false,
	isReady = false,
	purchaseLocation = "default",
	variantName = "control",
	fetchSucceeded = false,
	FrameworkInit = function() end
}

function HouseSaveSlotsABTest.FrameworkStart()
	local v3, v4 = ABTest.GetExperimentVariables("house-save-slots"):timeout(10):await()
	HouseSaveSlotsABTest.fetchSucceeded = v3 == true and v4 ~= nil

	if HouseSaveSlotsABTest.fetchSucceeded then
		local enabled = v4.enabled
		local purchaseLocation = v4.purchaseLocation
		local _variantName = v4._variantName

		if typeof(enabled) == "boolean" then
			HouseSaveSlotsABTest.enabled = enabled
		end

		if typeof(purchaseLocation) == "string" then
			HouseSaveSlotsABTest.purchaseLocation = purchaseLocation
		end

		if typeof(_variantName) == "string" then
			HouseSaveSlotsABTest.variantName = _variantName
		end
	end

	HouseSaveSlotsABTest.isReady = true

	if v ~= nil then
		v()
		v = nil
	end
end

function HouseSaveSlotsABTest.WaitForReady()
	if HouseSaveSlotsABTest.isReady then
		return Promise.resolve()
	end

	return v2
end

function HouseSaveSlotsABTest.IsReady()
	return HouseSaveSlotsABTest.isReady
end

function HouseSaveSlotsABTest.IsABEnabled()
	return HouseSaveSlotsABTest.enabled == true
end

function HouseSaveSlotsABTest.IsTopAnchorVariant()
	return HouseSaveSlotsABTest.purchaseLocation == "topAnchor"
end

function HouseSaveSlotsABTest.IsBottomAnchor()
	return HouseSaveSlotsABTest.purchaseLocation == "bottomAnchor"
end

function HouseSaveSlotsABTest.IsSubtleSale()
	return HouseSaveSlotsABTest.purchaseLocation == "subtleSale"
end

function HouseSaveSlotsABTest.IsPurchaseAnchored()
	return HouseSaveSlotsABTest.IsTopAnchorVariant() or HouseSaveSlotsABTest.IsBottomAnchor()
end

return HouseSaveSlotsABTest