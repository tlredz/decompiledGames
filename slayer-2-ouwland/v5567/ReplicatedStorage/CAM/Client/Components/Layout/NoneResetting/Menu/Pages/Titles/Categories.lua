local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local CategoryBrowser = require(ReplicatedStorage.CAM.Client.Components.Misc.CategoryBrowser)
local TitleController = require(ReplicatedStorage.CAM.Client.Controllers.TitleController)
require(script.Parent.Types)

local function countsOf(items, p: string, p2: string)
	local totals, v = TitleController.Totals()
	v[p] = totals
	v[p2] = 0
	local vanity = TitleController.Vanity()
	local boost = TitleController.Boost()

	for _, item in items do
		if vanity == item.Id or table.find(boost, item.Id) ~= nil then
			v[p2] += 1
		end
	end

	return v
end

local function categoriesOf(items, p: string, p2: string)
	local result = {}

	for _, item in items do
		if table.find(result, item.Category) == nil then
			table.insert(result, item.Category)
		end
	end

	table.sort(result)
	table.insert(result, 1, p)
	table.insert(result, 2, p2)
	return result
end

return function(p, p2, p3, p4, p5: string, p6: string)
	return CategoryBrowser(p, p2, p3, categoriesOf(p4, p5, p6), {
		Size = UDim2.fromScale(0.15, 1),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0, -8, 0, 0),
		Counts = countsOf(p4, p5, p6)
	})
end