local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "AlternateExperimentBackgroundColor"
})

function v.Construct(_) end

function v:Start()
	if not self.Instance:IsA("GuiObject") then
		return
	end

	local instance = self.Instance
	local alternateExperimentBackgroundColor_ExperimentName = instance:GetAttribute("AlternateExperimentBackgroundColor_ExperimentName")
	assert(typeof(alternateExperimentBackgroundColor_ExperimentName) == "string")
	local alternateExperimentBackgroundColor_ExperimentVariable = instance:GetAttribute("AlternateExperimentBackgroundColor_ExperimentVariable")
	assert(typeof(alternateExperimentBackgroundColor_ExperimentVariable) == "string")
	local alternateExperimentBackgroundColor_Default = instance:GetAttribute("AlternateExperimentBackgroundColor_Default")
	assert(alternateExperimentBackgroundColor_Default == nil or typeof(alternateExperimentBackgroundColor_Default) == "string")
	self.Promise = ABTest.GetExperimentVariable(
		alternateExperimentBackgroundColor_ExperimentName,
		alternateExperimentBackgroundColor_ExperimentVariable
	):timeout(10):andThen(
		function(p2)
			local success, result = pcall(function()
				return Color3.fromHex(p2)
			end)

			if success then
				self.PreviousColour = instance.BackgroundColor3
				instance.BackgroundColor3 = result
			else
				local success2, result2 = pcall(function()
					return Color3.fromHex(alternateExperimentBackgroundColor_Default)
				end)

				if success2 then
					self.PreviousColour = instance.BackgroundColor3
					instance.BackgroundColor3 = result2
				end
			end
		end,
		function(_)
			warn("Error retrieving A/B test")

			if alternateExperimentBackgroundColor_Default == nil then
				return
			end

			local success, result = pcall(function()
				return Color3.fromHex(alternateExperimentBackgroundColor_Default)
			end)

			if success then
				self.PreviousColour = instance.BackgroundColor3
				instance.BackgroundColor3 = result
			end
		end
	)
end

function v.Stop(data)
	if data.Promise ~= nil then
		data.Promise:cancel()
	end

	if data.PreviousColour then
		data.Instance.BackgroundColor3 = data.PreviousColour
	end
end

return v