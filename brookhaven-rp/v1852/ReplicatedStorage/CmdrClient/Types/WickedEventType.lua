local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local v = {
	NOT_STARTED = "NOT_STARTED",
	PRE_EVENT = "PRE_EVENT",
	EVENT_STARTED = "EVENT_STARTED",
	EVENT_ENDED = "EVENT_ENDED"
}
return function(registry)
	local function stringsGetter()
		return TableUtil.Keys(v)
	end

	local function stringToObject(p: string)
		return p
	end

	local v2 = CmdrUtil.cleanTypeName("wickedEventType")
	registry:RegisterType(v2, (CmdrUtil.createTypeDefinition(v2, stringsGetter, stringToObject)))
end