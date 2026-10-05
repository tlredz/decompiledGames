local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "AlternateExperimentLayoutOrder"
})

function v.Construct(_) end

function v:Start()
	local instance = self.Instance
	local alternateExperimentLayoutOrder_ExperimentName = instance:GetAttribute("AlternateExperimentLayoutOrder_ExperimentName")
	assert(typeof(alternateExperimentLayoutOrder_ExperimentName) == "string")
	self.Promise = ABTest.GetExperimentVariables(alternateExperimentLayoutOrder_ExperimentName):timeout(10):andThen(
		function(items)
			for k, item in pairs(items) do
				if k:sub(1, 1) == "_" then
					continue
				end

				local layoutOrder = tonumber(item)

				if layoutOrder == nil then
					continue
				end

				local v3 = k
				local layoutOrder2 = layoutOrder
				task.spawn(function()
					local guiObject = instance:WaitForChild(v3, 10)

					if guiObject == nil or not guiObject:IsA("GuiObject") then
						return
					end

					guiObject.LayoutOrder = layoutOrder2
				end)
			end
		end,
		function(_)
			warn("Error retrieving A/B test")
		end
	)
end

function v.Stop(p)
	if p.Promise ~= nil then
		p.Promise:cancel()
	end
end

return v