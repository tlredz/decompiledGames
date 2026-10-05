local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.FeatureConfigs.Items)

local function getItemKeys()
	local result = {}

	for k in Items.ITEMS do
		table.insert(result, k)
	end

	table.sort(result)
	return result
end

return function(registry)
	local makeEnumType = registry.Cmdr.Util.MakeEnumType
	local v = {}

	for k in Items.ITEMS do
		table.insert(v, k)
	end

	table.sort(v)
	registry:RegisterType("item", makeEnumType("item", v))
end