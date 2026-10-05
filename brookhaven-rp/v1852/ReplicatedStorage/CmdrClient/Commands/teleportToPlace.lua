local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
return {
	Name = "teleportToPlace",
	Aliases = {},
	Description = "Teleports a player to a place",
	Group = "Utility",
	Args = {
		{
			Type = "players",
			Name = "player",
			Description = "Player(s) to teleport"
		},
		{
			Type = "placeType",
			Name = "placeType",
			Description = "Place Type"
		},
		function(object)
			local value = object:GetArgument(2):GetValue()
			return {
				Type = CmdrUtil.cleanTypeName(("placeId%s"):format(value)),
				Name = "placeId",
				Description = "placeId"
			}
		end
	}
}