local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Item = require(ReplicatedStorage.Modules.Shared.Item.Item)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local MiddlewareUtil = require(ReplicatedStorage.Modules.Shared.Item.Middleware.MiddlewareUtil)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
local t = require(ReplicatedStorage.Packages.t)
local houseItem = {
	Inherits = { Item },
	Cast = function(p)
		return p
	end
}
local HouseMiddleware = {
	Name = "House",
	Arguments = { "HousePanel" },
	HouseItem = houseItem
}
local v2 = {}

function HouseMiddleware.Apply(p, housePanel)
	assert(t.optional(t.string)(housePanel))
	assert(Object.InstanceOf(p, MenuItem))
	return (MiddlewareUtil.Apply({
		HousePanel = housePanel
	}, houseItem, p, v2, "HouseImpl"))
end

return HouseMiddleware