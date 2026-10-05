local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local v = { "092_House", "093_House" }
return function(registry)
	local v2 = CmdrUtil.cleanTypeName("interactableHouseId")
	registry:RegisterType(v2, CmdrUtil.createTypeDefinition(v2, function()
		return v
	end, function(p: string)
		return p
	end))
end