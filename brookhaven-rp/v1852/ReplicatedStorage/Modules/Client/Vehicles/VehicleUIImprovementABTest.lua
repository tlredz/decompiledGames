local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local VehicleUIImprovementABTest = {
	enabled = false,
	variantName = "control",
	isReady = false,
	fetchSucceeded = false,
	FrameworkInit = function() end
}

function VehicleUIImprovementABTest.FrameworkStart()
	local v, v2 = ABTest.GetExperimentVariables("vehicle-ui-improvement"):timeout(10):await()
	VehicleUIImprovementABTest.fetchSucceeded = v == true and v2 ~= nil

	if VehicleUIImprovementABTest.fetchSucceeded then
		local enabled = v2.enabled
		local _variantName = v2._variantName

		if typeof(enabled) == "boolean" then
			VehicleUIImprovementABTest.enabled = enabled
		end

		if typeof(_variantName) == "string" then
			VehicleUIImprovementABTest.variantName = _variantName
		end
	end

	VehicleUIImprovementABTest.isReady = true
end

function VehicleUIImprovementABTest.IsReady()
	return VehicleUIImprovementABTest.isReady
end

function VehicleUIImprovementABTest.IsEnabled()
	return VehicleUIImprovementABTest.enabled == true
end

function VehicleUIImprovementABTest.GetVariantName()
	return VehicleUIImprovementABTest.variantName
end

return VehicleUIImprovementABTest