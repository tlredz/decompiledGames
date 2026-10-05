local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	ConfigName = "OverrideBaitData",
	ApplyEnvironment = "Both",
	Apply = function(items)
		if typeof(items) ~= "table" then
			return
		end

		local bait = require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("bait"))

		for k, item in items do
			if not bait[k] then
				continue
			end

			for k2, v in item do
				bait[k][k2] = v
			end
		end
	end
}