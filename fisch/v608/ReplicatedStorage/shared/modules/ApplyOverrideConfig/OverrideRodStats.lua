local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
return {
	ConfigName = "OverrideRodStats",
	ApplyEnvironment = "Both",
	Apply = function(items)
		if typeof(items) ~= "table" then
			return
		end

		local rods = require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("rods"))

		for k, item in items do
			if rods[k] then
				rods[k] = GeneralUtils.applyTable(rods[k], item, true)
			end
		end
	end
}