local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.FeatureConfigs.Items)

local function getEventItemKeys()
	local result = {}

	for k, v in Items.ITEMS do
		if v.EventKey then
			table.insert(result, k)
		end
	end

	table.sort(result)
	return result
end

return function(registry)
	registry:RegisterType("eventItem", registry.Cmdr.Util.MakeEnumType("eventItem", (getEventItemKeys())))
end