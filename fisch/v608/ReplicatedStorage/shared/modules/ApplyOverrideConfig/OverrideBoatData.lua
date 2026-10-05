local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	ConfigName = "OverrideBoatData",
	ApplyEnvironment = "Both",
	Apply = function(items)
		if typeof(items) ~= "table" then
			return
		end

		local vessels = require(ReplicatedStorage.shared.modules:WaitForChild("vessels"))

		for k, item in items do
			if not vessels.library[k] then
				continue
			end

			for k2, v in item do
				vessels.library[k][k2] = v
			end
		end
	end
}