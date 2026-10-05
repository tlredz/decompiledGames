local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
AdminPermissions.linkCommandToPermission("ReverseGravity", "cmdr")
return {
	Name = "ReverseGravity",
	Aliases = { "revgrav" },
	Description = "Flip a player's gravity so their ceiling becomes their floor (default: yourself). Run again to restore it.",
	Group = "Debug",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Target player (default: you).",
			Optional = true
		}
	}
}