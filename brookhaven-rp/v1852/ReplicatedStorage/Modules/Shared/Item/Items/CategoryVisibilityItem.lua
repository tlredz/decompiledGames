local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CategoryItem = require(ReplicatedStorage.Modules.Shared.Item.CategoryItem)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
local CategoryVisibilityItem = {}
CategoryVisibilityItem.__index = CategoryVisibilityItem
CategoryVisibilityItem.Inherits = { MenuItem, CategoryItem }

function CategoryVisibilityItem.Cast(p)
	return p
end

function CategoryVisibilityItem.new(id: string, displayName: string?, icon: string, category: string, categoryRegistry: string)
	local self = setmetatable({
		id = id,
		displayName = displayName,
		icon = icon,
		category = category,
		categoryRegistry = categoryRegistry
	}, CategoryVisibilityItem)
	self.__index = CategoryVisibilityItem
	return self
end

function CategoryVisibilityItem.OnDenied(_, _, _: string, _)
	error("category item should never be denied")
end

function CategoryVisibilityItem.GetName(p)
	return p.id
end

function CategoryVisibilityItem.GetDisplayName(p)
	return p.displayName or p.id
end

function CategoryVisibilityItem.GetIcon(p)
	return p.icon
end

function CategoryVisibilityItem.IsAlwaysVisible(_)
	return false
end

function CategoryVisibilityItem.IsUnlockedServer(_, _)
	error("category visiblity item should only work client side")
end

function CategoryVisibilityItem:IsUnlockedClient()
	local registry = ItemRegistry.GetRegistryByName(self.categoryRegistry)
	assert(registry, (`invalid registry {self.categoryRegistry}`))

	for _, v in ItemRegistry.GetRegistry(registry) do
		if Object.InstanceOf(v, CategoryItem) and v ~= self and not v:IsCategory() and v:GetCategory() == self.category and v:IsUnlockedClient() then
			return true
		end
	end

	return false
end

function CategoryVisibilityItem:IsCategory()
	return true
end

function CategoryVisibilityItem:GetCategory()
	return nil
end

return CategoryVisibilityItem