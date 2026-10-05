local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "AlternateExperimentVisibility"
})

function v.Construct(_) end

function v:Start()
	local instance = self.Instance
	local alternateExperimentVisibility_ExperimentName = instance:GetAttribute("AlternateExperimentVisibility_ExperimentName")
	assert(
		typeof(alternateExperimentVisibility_ExperimentName) == "string",
		"AlternateExperimentVisibility_ExperimentName must be a string"
	)
	local alternateExperimentVisibility_ExperimentVariable = instance:GetAttribute("AlternateExperimentVisibility_ExperimentVariable")
	assert(
		typeof(alternateExperimentVisibility_ExperimentVariable) == "string",
		"AlternateExperimentVisibility_ExperimentVariable must be a string"
	)
	local alternateExperimentVisibility_Inverted = instance:GetAttribute("AlternateExperimentVisibility_Inverted")
	assert(
		alternateExperimentVisibility_Inverted == nil or typeof(alternateExperimentVisibility_Inverted) == "boolean",
		"AlternateExperimentVisibility_Inverted must be a boolean"
	)
	self.Promise = ABTest.GetExperimentVariable(
		alternateExperimentVisibility_ExperimentName,
		alternateExperimentVisibility_ExperimentVariable
	):timeout(10):andThen(
		function(p2)
			local visible = p2 == true
			local instance2 = instance

			if alternateExperimentVisibility_Inverted == true then
				visible = not visible
			end

			instance2.Visible = visible
		end,
		function() end
	)
end

function v.Stop(p)
	p.Promise:cancel()
end

return v