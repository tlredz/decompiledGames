local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	ConfigName = "OverrideItemData",
	ApplyEnvironment = "Both",
	Apply = function(items)
		if typeof(items) ~= "table" then
			return
		end

		local items2 = require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("items"))

		for k, item in items do
			if not items2.Items[k] then
				continue
			end

			for k2, v in item do
				items2.Items[k][k2] = v
			end
		end
	end
}