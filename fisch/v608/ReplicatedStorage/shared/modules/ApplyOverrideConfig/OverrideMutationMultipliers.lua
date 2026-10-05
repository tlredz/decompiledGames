local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	ConfigName = "OverrideMutationMultipliers",
	ApplyEnvironment = "Both",
	Apply = function(items)
		if typeof(items) ~= "table" then
			return
		end

		local mutations = require(ReplicatedStorage.shared.modules:WaitForChild("fishing"):WaitForChild("mutations"))

		for k, item in items do
			if not mutations.Mutations[k] then
				continue
			end

			if typeof(item) == "number" then
				mutations.Mutations[k].PriceMultiply = item
			else
				for k2, v in item do
					mutations.Mutations[k][k2] = v
				end
			end
		end
	end
}