local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local GetMasteryStatus = require(ReplicatedStorage.CAM.Global.SkillService.GetMasteryStatus)
local MasteryItem = require(script.Parent.Toolbar.MasteryItem)
return function(object, parent, _)
	local value = object:Value(GetMasteryStatus.GetMasteries())
	object:Connect(GetMasteryStatus.Changed, function(p2)
		value:Set(p2)
	end)
	return object:Create("Frame")({
		Name = "MasteryHolder",
		Parent = parent,
		LayoutOrder = 10,
		Size = UDim2.fromScale(1, 0.6579999999999999),
		BackgroundTransparency = 1,
		Visible = object:Do(function(callback)
			local v = callback(value)
			return v ~= nil and #v > 0
		end),
		object:Create("Frame")({
			Name = "Actual",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 5)
			}),
			object:State(function(callback, p2, _)
				local v = callback(value)

				if v == nil then
					return
				end

				local result = {}

				for _, v2 in ipairs(v) do
					table.insert(result, MasteryItem(p2, v2))
				end

				return result
			end)
		})
	})
end