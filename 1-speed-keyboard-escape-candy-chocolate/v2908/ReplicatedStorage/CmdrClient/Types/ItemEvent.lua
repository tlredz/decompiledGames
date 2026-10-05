local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.FeatureConfigs.Items)

local function getEventKeys()
	local v = {}
	local eventKeys = {}

	for _, v2 in Items.ITEMS do
		if not v2.EventKey or v[v2.EventKey] then
			continue
		end

		v[v2.EventKey] = true
		table.insert(eventKeys, v2.EventKey)
	end

	table.sort(eventKeys)
	return eventKeys
end

return function(registry)
	registry:RegisterType("itemEvent", registry.Cmdr.Util.MakeEnumType("itemEvent", (getEventKeys())))
end