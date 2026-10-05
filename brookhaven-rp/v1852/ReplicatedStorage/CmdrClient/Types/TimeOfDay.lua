local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
return function(registry)
	local function stringsGetter()
		return { "AM", "PM" }
	end

	local function stringToObject(p: string)
		return p
	end

	local v = CmdrUtil.cleanTypeName("am_pm")
	registry:RegisterType(v, (CmdrUtil.createTypeDefinition(v, stringsGetter, stringToObject)))
end