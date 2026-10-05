local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local ContentCreatorsSkyboxes = require(ReplicatedStorage.Modules.Shared.ContentCreators.ContentCreatorsSkyboxes)
return function(registry)
	local function stringsGetter()
		return ContentCreatorsSkyboxes.GetNames()
	end

	local function stringToObject(p: string)
		return p
	end

	local v = CmdrUtil.cleanTypeName("contentCreatorsSkyboxName")
	registry:RegisterType(v, (CmdrUtil.createTypeDefinition(v, stringsGetter, stringToObject)))
end