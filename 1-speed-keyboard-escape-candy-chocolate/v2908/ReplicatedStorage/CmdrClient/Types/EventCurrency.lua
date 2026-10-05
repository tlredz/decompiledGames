local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsConfig = require(ReplicatedStorage.EventsConfig)

local function getCurrencyKeys()
	local result = {}

	for _, currency in EventsConfig.Currencies do
		table.insert(result, currency.Key)
	end

	return result
end

return function(registry)
	local makeEnumType = registry.Cmdr.Util.MakeEnumType
	local v = {}

	for _, currency in EventsConfig.Currencies do
		table.insert(v, currency.Key)
	end

	registry:RegisterType("eventCurrency", makeEnumType("eventCurrency", v))
end