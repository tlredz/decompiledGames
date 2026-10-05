local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local v = {
	"BananaTornado",
	"PinkBunny",
	"Tentacles",
	"Irene",
	"Philips"
}
return function(registry)
	local function stringsGetter()
		return v
	end

	local function stringToObject(p: string)
		return p
	end

	local v2 = CmdrUtil.cleanTypeName("minionsDisasterId")
	registry:RegisterType(v2, (CmdrUtil.createTypeDefinition(v2, stringsGetter, stringToObject)))
end