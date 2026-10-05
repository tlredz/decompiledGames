local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
return {
	ConfigName = "OverrideFishData",
	ApplyEnvironment = "Both",
	Apply = function(items)
		if typeof(items) ~= "table" then
			return
		end

		local fish = require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("fish"))

		for k, item in items do
			if fish[k] then
				fish[k] = GeneralUtils.applyTable(fish[k], item, true)
			end
		end
	end
}