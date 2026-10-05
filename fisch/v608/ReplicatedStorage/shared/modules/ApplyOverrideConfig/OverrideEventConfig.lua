local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	ConfigName = "OverrideEventConfig",
	ApplyEnvironment = "Both",
	Apply = function(items)
		if typeof(items) ~= "table" then
			return
		end

		local EventConfig = require(ReplicatedStorage.shared.modules:WaitForChild("EventConfig"))

		for k, item in items do
			if not EventConfig[k] then
				continue
			end

			for k2, v in item do
				EventConfig[k][k2] = v
			end
		end
	end
}