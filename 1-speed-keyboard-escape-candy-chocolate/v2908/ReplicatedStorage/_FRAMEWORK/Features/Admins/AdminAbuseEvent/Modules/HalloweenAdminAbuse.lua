local parentModule = require(script.Parent.Parent)
local MapAdminAbuse = require(script.Parent.Parent.MapAdminAbuse)
local Config = require(script.Config)
parentModule.register(script.Name, {
	displayName = "Halloween Map Admin Abuse",
	slot = "main",
	needsDuration = false,
	load = MapAdminAbuse.create(Config)
})
return {}