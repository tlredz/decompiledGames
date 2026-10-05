local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	ConfigName = "OverrideRarityData",
	ApplyEnvironment = "Both",
	Apply = function(items)
		if typeof(items) ~= "table" then
			return
		end

		local rarities = require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("rarities"))

		for k, item in items do
			if not rarities.Rarities[k] then
				continue
			end

			for k2, v in item do
				rarities.Rarities[k][k2] = v
			end
		end
	end
}