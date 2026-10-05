local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Item = require(ReplicatedStorage.Modules.Shared.Item.Item)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local MiddlewareUtil = require(ReplicatedStorage.Modules.Shared.Item.Middleware.MiddlewareUtil)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
local t = require(ReplicatedStorage.Packages.t)
local vehicleItem = {
	Inherits = { Item },
	Cast = function(p)
		return p
	end
}
local VehicleMiddleware = {
	Name = "Vehicle",
	Arguments = {
		"Type",
		"SecondarySkinIcon",
		"NoMotor",
		"IconWhenUnlocked",
		"CornerIcon",
		"HighlightEffect",
		"VehiclePanel",
		"NoMotorAnimated"
	},
	VehicleItem = vehicleItem
}
local v2 = {}

function VehicleMiddleware.Apply(p, p2, secondarySkinIcon, noMotor, iconWhenUnlocked, cornerIcon, highlightEffect, vehiclePanel, noMotorAnimated)
	assert(t.tuple(
		t.optional(t.string),
		t.optional(t.string),
		t.optional(t.string),
		t.optional(t.string),
		t.optional(t.string),
		t.optional(t.boolean),
		t.optional(t.string),
		t.optional(t.boolean)
	)(
		p2,
		secondarySkinIcon,
		noMotor,
		iconWhenUnlocked,
		cornerIcon,
		highlightEffect,
		vehiclePanel,
		noMotorAnimated
	))
	assert(Object.InstanceOf(p, MenuItem))
	return (MiddlewareUtil.Apply({
		Type = p2,
		SecondarySkinIcon = secondarySkinIcon,
		NoMotor = noMotor,
		IconWhenUnlocked = iconWhenUnlocked,
		CornerIcon = cornerIcon,
		HighlightEffect = highlightEffect,
		VehiclePanel = vehiclePanel,
		NoMotorAnimated = noMotorAnimated
	}, vehicleItem, p, v2, "VehicleImpl"))
end

return VehicleMiddleware