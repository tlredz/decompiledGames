local Schema_DataV2 = require(script.Schema_DataV2)
local Schema_DataV3 = require(script.Schema_DataV3)

local function formatFromDefaults(defaults)
	local keys = {}
	local keySet = {}

	for k in pairs(defaults) do
		table.insert(keys, k)
		keySet[k] = true
	end

	table.sort(keys)
	return {
		defaults = defaults,
		keys = keys,
		keySet = keySet
	}
end

local v = {
	{},
	formatFromDefaults(Schema_DataV2),
	(formatFromDefaults(Schema_DataV3))
}
local v2 = v[3]
return {
	getDataSchemaForVersion = function(p: number)
		return v[p]
	end,
	defaults = v2.defaults,
	keys = v2.keys,
	keySet = v2.keySet
}