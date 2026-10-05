local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FilterableItem = require(ReplicatedStorage.Modules.Shared.Item.FilterableItem)
require(ReplicatedStorage.Modules.Shared.Item.Item)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local MiddlewareUtil = require(ReplicatedStorage.Modules.Shared.Item.Middleware.MiddlewareUtil)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
local t = require(ReplicatedStorage.Packages.t)
local v = {
	IsPaid = function(p)
		return p.paid
	end,
	GetFilter = function(p)
		return p.filter
	end
}
return {
	Name = "Filterable",
	Arguments = { "Paid", "Filter" },
	Apply = function(p, p2, filter)
		if not Object.InstanceOf(p, MenuItem) then
			error("Filterable middleware can only be used on MenuItems")
		end

		assert(t.optional(t.boolean)(p2))
		assert(t.optional(t.union(t.table, t.string))(filter))
		return (MiddlewareUtil.Apply({
			paid = p2 == true,
			filter = filter
		}, FilterableItem, p, v, "FilterableItemImpl"))
	end
}