local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local FireworkConstants = require(ReplicatedStorage.Modules.Shared.Fireworks.FireworkConstants)
return function(registry)
	local function stringsGetter()
		local result = {}

		for k in FireworkConstants.COUNTABLE_PRODUCT_BY_TYPE do
			table.insert(result, k)
		end

		return result
	end

	local v = CmdrUtil.cleanTypeName("fireworkType")
	registry:RegisterType(v, CmdrUtil.createTypeDefinition(v, stringsGetter, function(p: string)
		return p
	end))
end