local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local v = {
	"notify",
	"center",
	"centerSmall",
	"slide",
	"alwaysVisible",
	"editor"
}
return function(registry)
	local v2 = CmdrUtil.cleanTypeName("notificationType")
	registry:RegisterType(v2, CmdrUtil.createTypeDefinition(v2, function()
		return v
	end, function(p: string)
		return p
	end))
end