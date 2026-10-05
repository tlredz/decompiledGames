local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local CategoryBrowser = require(ReplicatedStorage.CAM.Client.Components.Misc.CategoryBrowser)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)

local function countsOf(list, p: string)
	local result = {
		[p] = #list
	}

	for _, v in list do
		local inventoryCategory = Items[v].InventoryCategory or "Items"
		result[inventoryCategory] = (result[inventoryCategory] or 0) + 1
	end

	return result
end

local function categoriesOf(items, p: string)
	local result = {}

	for _, item in items do
		local inventoryCategory = Items[item].InventoryCategory or "Items"

		if table.find(result, inventoryCategory) == nil then
			table.insert(result, inventoryCategory)
		end
	end

	table.sort(result)
	table.insert(result, 1, p)
	return result
end

return function(p, p2, p3, p4, p5: string)
	return CategoryBrowser(p, p2, p3, categoriesOf(p4, p5), {
		Size = UDim2.fromScale(0.15, 1),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0, -8, 0, 0),
		TabHeight = 0.05,
		Overscan = 2,
		Counts = countsOf(p4, p5)
	})
end