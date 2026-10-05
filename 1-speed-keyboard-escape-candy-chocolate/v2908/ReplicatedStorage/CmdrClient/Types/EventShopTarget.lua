local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local eventShops = require(ReplicatedStorage._FRAMEWORK.Features.eventShops)

local function getSuggestions()
	local baseSlotIds = eventShops.getBaseSlotIds()
	local v = {}

	for k, v2 in Items.ITEMS do
		if v2.EventKey then
			table.insert(v, k)
		end
	end

	table.sort(v)
	table.move(v, 1, #v, #baseSlotIds + 1, baseSlotIds)
	return baseSlotIds
end

local function indexByLowerName(suggestions)
	local result = {}

	for _, item in suggestions do
		result[string.lower(item)] = item
	end

	return result
end

return function(registry)
	local suggestions = getSuggestions()
	local fuzzyFinder = registry.Cmdr.Util.MakeFuzzyFinder(suggestions)
	local v = indexByLowerName(suggestions)
	registry:RegisterType("eventShopTarget", {
		Validate = function(p: string)
			return p ~= "", "Enter a slot id, an item key or an added listing id (extra_...)."
		end,
		Autocomplete = function(p: string)
			return fuzzyFinder(p)
		end,
		Parse = function(value: string)
			return v[string.lower(value)] or value
		end
	})
end