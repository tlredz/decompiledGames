local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local equippedOptions = {
	Toolbar = require(script.EquippedOptions.Toolbar),
	Accessories = require(script.EquippedOptions.Accessories),
	Bait = require(script.EquippedOptions.Bait)
}
return function(object, p, object2)
	local v2 = {}
	local value = object:Value(v2)
	local value2 = object:Value(UDim2.fromScale(1, 1))

	local function updateItem(p2)
		table.clear(v2)

		if p2 == nil then
			table.insert(v2, "Toolbar")
		else
			local item = Items[p2.Name]

			if item.EquipType == Menum.ItemEquipType.Toolbar then
				table.insert(v2, "Toolbar")
			elseif item.EquipType == Menum.ItemEquipType.Accessory or item.EquipType == Menum.ItemEquipType.Costume or item.EquipType == Menum.ItemEquipType.Clothing then
				table.insert(v2, "Accessories")
			elseif item.EquipType == Menum.ItemEquipType.Bait then
				table.insert(v2, "Bait")
			end
		end

		value2:Refresh()
		value:Refresh()
	end

	updateItem(object2:Get())
	object:Connect(object2.Changed, updateItem)
	return object:Create("Frame")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = object:Animation(value2, object.SpringInfo(0.25, 1, 0.65), {
			AlwaysFrom = UDim2.fromScale(0.97, 0.97)
		}),
		BackgroundTransparency = 1,
		object:Create("Frame")({
			Name = "Eq",
			Size = UDim2.fromScale(1, 0.5),
			Position = UDim2.fromScale(0.5, 0.415),
			AnchorPoint = Vector2.new(0.5),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Vertical,
				Wraps = true,
				Padding = UDim.new(0.05, 0),
				SortOrder = Enum.SortOrder.Name
			}),
			object:Iterate(value, function(_, p2, p3)
				return equippedOptions[p2](p3, p, object2)
			end)
		})
	})
end