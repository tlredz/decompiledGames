local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemIcon = require(ReplicatedStorage.CAM.Global.Collectibles.ItemIcon)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
require(ReplicatedStorage.Packages.faye)
local Connector = require(script.Parent.Connector)
local color = Color3.new(1, 1, 1)
local color2 = Color3.fromRGB(85, 170, 255)
local color3 = Color3.new(1, 0.803922, 0.305882)

local function side(object, layoutOrder: number, data, name: string)
	local v

	if data ~= nil then
		v = Items[data.Name]
	end

	local v2 = v == nil and 1 or v.Rarity or 1
	local color4 = Rarities.Colors[v2]
	local v3 = object:Create("Frame")
	local v4 = {
		Name = layoutOrder == 1 and "From" or "To",
		LayoutOrder = layoutOrder,
		Size = UDim2.fromScale(0.4, 1),
		BackgroundTransparency = 1
	}
	local v5 = object:Create("Frame")
	local v6 = {
		Name = "Plate",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(0.64, 0.64),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
		BackgroundTransparency = data == nil and 0.6 or 0.15
	}
	local v7 = object:Create("UICorner")({
		CornerRadius = UDim.new(0.12)
	})
	local v8 = object:Create("UIStroke")
	local v9 = {
		BorderOffset = UDim.new(0, 3),
		Color = 0,
		Thickness = 1.5,
		Transparency = 0
	}
	local color5

	if data == nil then
		color5 = color
	else
		color5 = color4
	end

	v9.Color = color5
	v9.Transparency = data == nil and 0.75 or 0.3
	local v11 = v8(v9)
	local v12

	if data == nil then
		v12 = object:Create("TextLabel")({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Text = "?",
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			TextColor3 = color,
			TextTransparency = 0.6
		})
	else
		v12 = object:Create("ImageLabel")({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.86, 0.86),
			BackgroundTransparency = 1,
			Image = ItemIcon.For(Players.LocalPlayer, data.Name)
		})
	end

	v6[1], v6[2], v6[3] = v7, v11, v12
	local v13 = v5(v6)
	local v14 = object:Create("TextLabel")
	local v15 = {
		Name = "ItemName",
		Position = UDim2.fromScale(0, 0.68),
		Size = UDim2.fromScale(1, 0.15),
		BackgroundTransparency = 1
	}

	if data ~= nil then
		name = data.Name
	end

	v15.Text = name
	v15.TextScaled = true
	v15.Font = Enum.Font.SourceSansBold

	if data == nil then
		color4 = color
	elseif v2 >= 6 then
		color4 = color4:Lerp(color, 0.4)
	end

	v15.TextColor3 = color4
	v15.TextTransparency = data == nil and 0.45 or 0
	do local _values = table.pack(object:Create("UIStroke")({
	Thickness = 1.5,
	Transparency = 0.4
})); for _k = 1, _values.n do v15[_k] = _values[_k] end end
	local v16 = v14(v15)
	local v17

	if data ~= nil then
		local v18 = object:Create("TextLabel")
		local v19 = {
			Name = "Change",
			Position = UDim2.fromScale(0, 0.85),
			Size = UDim2.fromScale(1, 0.15),
			BackgroundTransparency = 1,
			RichText = true,
			Text = `<font transparency="0.35">{data.Now}</font>  →  {data.After}`,
			TextScaled = true,
			Font = Enum.Font.SourceSansBold
		}
		local textColor

		if data.Gains then
			textColor = color3
		else
			textColor = color2
		end

		v19.TextColor3 = textColor
		do local _values = table.pack(object:Create("UIStroke")({
	Thickness = 1.5,
	Transparency = 0.35
})); for _k = 1, _values.n do v19[_k] = _values[_k] end end
		v17 = v18(v19)
	end

	v4[1], v4[2], v4[3] = v13, v16, v17
	return v3(v4)
end

return function(object, p, p2, p3: string)
	return object:Create("Frame")({
		Name = "TransferPair",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0.03, 0)
		}),
		side(object, 1, p, p3),
		object:Create("Frame")({
			Name = "ConnectorSlot",
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.1, 0.64),
			BackgroundTransparency = 1,
			Connector(object, UDim2.fromScale(0, 0.5), 1)
		}),
		side(object, 3, p2, p3)
	})
end