local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
require(ReplicatedStorage.Packages.faye)
local ItemRow = require(script.Parent.ItemRow)
require(script.Parent.Types)
return function(object, data)
	return object:State(function(callback, object2)
		local v = callback(data.Selected)
		local v2

		if v ~= 0 then
			v2 = Character_info_provider.GetItemFromId(Players.LocalPlayer, v)
		end

		local refineLevel

		if v2 ~= nil then
			refineLevel = v2:FindFirstChild("RefineLevel")
		end

		local v3 = refineLevel == nil and 0 or refineLevel.Value
		local v4 = {}

		for _, v5 in callback(data.Rows) do
			if v5.Id ~= v and v5.RefineLevel < v3 then
				table.insert(v4, v5)
			end
		end

		local v5 = object2:Create("Frame")
		local v6 = {
			Name = "TargetList",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1
		}
		local v7 = object2:Create("TextLabel")({
			Name = "Header",
			Size = UDim2.fromScale(1, 0.06),
			BackgroundTransparency = 1,
			Text = "Transfer",
			TextScaled = true,
			Font = Enum.Font.SourceSansSemibold,
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = 0.5
		})
		local v8 = object2:Create("ScrollingFrame")
		local v9 = {
			Name = "Rows",
			Position = UDim2.fromScale(0, 0.08),
			Size = UDim2.fromScale(1, 0.92),
			BackgroundTransparency = 1,
			ScrollBarThickness = 3,
			ScrollBarImageTransparency = 0.5,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new()
		}
		local v10 = object2:Create("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4)
		})
		local v11 = object2:Create("UIPadding")({
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6)
		})
		local v12 = object2:Iterate(v4, function(p: number, p2, p3)
			return ItemRow(p3, p2, p, data.Target, data.Busy)
		end)
		local v13

		if #v4 == 0 then
			v13 = object2:Create("TextLabel")({
				Size = UDim2.new(1, 0, 0, 60),
				BackgroundTransparency = 1,
				Text = v3 > 0 and "No Target below it." or "Pick a refined item to transfer from.",
				TextScaled = true,
				Font = Enum.Font.SourceSansSemibold,
				TextColor3 = Color3.new(1, 1, 1),
				TextTransparency = 0.5,
				object2:Create("UITextSizeConstraint")({
					MaxTextSize = 16
				})
			})
		end

		v9[1], v9[2], v9[3], v9[4] = v10, v11, v12, v13
		do local _values = table.pack(v7, v8(v9)); for _k = 1, _values.n do v6[_k] = _values[_k] end end
		return v5(v6)
	end)
end