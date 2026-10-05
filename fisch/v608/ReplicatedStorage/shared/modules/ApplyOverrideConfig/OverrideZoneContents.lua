local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	ConfigName = "OverrideZoneContents",
	ApplyEnvironment = "Both",
	Apply = function(items)
		if typeof(items) ~= "table" then
			return
		end

		local zones = require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("fish"):WaitForChild("zones"))

		for k, item in items do
			if not zones[k] then
				continue
			end

			local v = next(item)

			if typeof(v) == "string" then
				for k2, v2 in item do
					zones[k][k2] = v2
				end
			elseif typeof(v) == "number" then
				zones[k].Pool = item
			end
		end
	end
}