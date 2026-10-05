local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CategoryItem = require(ReplicatedStorage.Modules.Shared.Item.CategoryItem)
require(ReplicatedStorage.Modules.Shared.Item.Item)
local MiddlewareUtil = require(ReplicatedStorage.Modules.Shared.Item.Middleware.MiddlewareUtil)
local t = require(ReplicatedStorage.Packages.t)
local v = {
	GetCategory = function(p)
		return p.category
	end,
	IsCategory = function(p)
		return p.isCategory
	end
}
return {
	Name = "Category",
	Arguments = { "IsCategory", "Category" },
	Apply = function(p, p2, category)
		assert(t.optional(t.boolean)(p2))

		if p2 then
			assert(category == nil, "if is category is true then category must be nil")
		else
			assert(t.string(category))
		end

		return (MiddlewareUtil.Apply({
			isCategory = p2 and true or false,
			category = category
		}, CategoryItem, p, v, "CategoryItemImpl"))
	end
}