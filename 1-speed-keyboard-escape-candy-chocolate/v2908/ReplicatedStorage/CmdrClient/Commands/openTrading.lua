local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
AdminPermissions.linkCommandToPermission("openTrading", "cmdr")
return {
	Name = "openTrading",
	Aliases = { "opentrade", "tradeui" },
	Description = "Open the item trading target modal for yourself.",
	Group = "Debug",
	Args = {}
}