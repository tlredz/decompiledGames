local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local NewEstatesSurfacingAbTestController = {
	enabled = false,
	panelName = "default",
	variantName = "control",
	isReady = false,
	fetchSucceeded = false,
	FrameworkInit = function() end
}

function NewEstatesSurfacingAbTestController.FrameworkStart()
	local v, v2 = ABTest.GetExperimentVariables("estates-surfacing"):timeout(10):await()
	NewEstatesSurfacingAbTestController.fetchSucceeded = v == true and v2 ~= nil

	if NewEstatesSurfacingAbTestController.fetchSucceeded then
		local enabled = v2.enabled
		local panelName = v2.panelName
		local _variantName = v2._variantName

		if typeof(enabled) == "boolean" then
			NewEstatesSurfacingAbTestController.enabled = enabled
		end

		if typeof(panelName) == "string" then
			NewEstatesSurfacingAbTestController.panelName = panelName
		end

		if typeof(_variantName) == "string" then
			NewEstatesSurfacingAbTestController.variantName = _variantName
		end
	end

	NewEstatesSurfacingAbTestController.isReady = true
end

function NewEstatesSurfacingAbTestController.IsReady()
	return NewEstatesSurfacingAbTestController.isReady
end

function NewEstatesSurfacingAbTestController.IsSurfacingEnabled()
	return NewEstatesSurfacingAbTestController.enabled == true
end

function NewEstatesSurfacingAbTestController.GetPanelName()
	return NewEstatesSurfacingAbTestController.panelName
end

function NewEstatesSurfacingAbTestController.GetVariantName()
	return NewEstatesSurfacingAbTestController.variantName
end

function NewEstatesSurfacingAbTestController.IsExistingCameraViewPanel()
	return NewEstatesSurfacingAbTestController.panelName == "existingView"
end

function NewEstatesSurfacingAbTestController.IsNewPopupPanel()
	return NewEstatesSurfacingAbTestController.panelName == "newPopup"
end

return NewEstatesSurfacingAbTestController