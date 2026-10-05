local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "AlternateExperimentTargetPanel"
})

function v.Construct(_) end

function v:Start()
	local instance = self.Instance
	local alternateExperimentTargetPanel_ExperimentName = instance:GetAttribute("AlternateExperimentTargetPanel_ExperimentName")
	assert(typeof(alternateExperimentTargetPanel_ExperimentName) == "string")
	local alternateExperimentTargetPanel_ExperimentVariable = instance:GetAttribute("AlternateExperimentTargetPanel_ExperimentVariable")
	assert(typeof(alternateExperimentTargetPanel_ExperimentVariable) == "string")
	local alternateExperimentTargetPanel_TargetPanel = instance:GetAttribute("AlternateExperimentTargetPanel_TargetPanel")
	assert(typeof(alternateExperimentTargetPanel_TargetPanel) == "string")
	self.Promise = ABTest.GetExperimentVariable(
		alternateExperimentTargetPanel_ExperimentName,
		alternateExperimentTargetPanel_ExperimentVariable
	):timeout(10):andThen(
		function(p2)
			if p2 then
				instance:SetAttribute("TargetPanel", alternateExperimentTargetPanel_TargetPanel)
			end
		end,
		function(_)
			warn("Error retrieving A/B test")
		end
	)
end

function v.Stop(p)
	p.Promise:cancel()
end

return v