local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local localPlayer = Players.LocalPlayer
local ABGuaranteedLegendaryController = {
	_Used = false,
	IsEligible = function(self)
		return legacyLocalPlayerData.fetch():WaitForChild("Stats").tracker_fishcaught.Value == 1 and localPlayer:GetAttribute("AB_LegendaryExperiment") == true
	end
}

function ABGuaranteedLegendaryController.Call(_)
	if ABGuaranteedLegendaryController._Used or not ABGuaranteedLegendaryController:IsEligible() then
		return false
	end

	ABGuaranteedLegendaryController._Used = true
	return true
end

return ABGuaranteedLegendaryController