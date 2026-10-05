local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local formatted = `Tier must be an integer from 0 to {Items.MAX_TIER}.`

local function getTierNames()
	local result = {}

	for i = 0, Items.MAX_TIER do
		table.insert(result, (tostring(i)))
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isTier(p: number?)
	return p ~= nil and p == math.floor(p) and p >= 0 and p <= Items.MAX_TIER
end

return function(registry)
	local result = {}

	for i = 0, Items.MAX_TIER do
		table.insert(result, (tostring(i)))
	end

	registry:RegisterType("itemTier", {
		Transform = function(p: string)
			return (tonumber(p))
		end,
		Validate = function(p: number?)
			return isTier(p), formatted
		end,
		Autocomplete = function()
			return result
		end,
		Parse = function(p: number)
			return p
		end
	})
end