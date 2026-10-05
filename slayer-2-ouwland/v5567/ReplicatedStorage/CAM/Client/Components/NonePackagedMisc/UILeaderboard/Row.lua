local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
require(ReplicatedStorage.Packages.faye)
local lvlColor = gameSettings.lvlColor
local color = Color3.fromRGB(85, 170, 255)

local function shorten(name: string)
	if utf8.len(name) == nil or not (utf8.len(name) > 20) then
		return name
	end

	return string.sub(name, 1, (utf8.offset(name, 19) or #name + 1) - 1) .. ".."
end

local localPlayer = Players.LocalPlayer
return function(object, p, layoutOrder: number, p3: number, parent2)
	local v = layoutOrder <= 3
	local size = object:Value(UDim2.fromScale(0, 0.78))
	local textSize = object:Value(14)
	local textSize2 = object:Value(14)

	local function fitDisc(parent)
		local Y = parent.AbsoluteSize.Y

		if Y <= 0 then
			return
		end

		textSize:Set((math.max(math.floor(Y * 0.55), 1)))
		local rank = parent:FindFirstChild("Rank")
		local v2 = rank == nil and 0 or rank.TextBounds.X
		local v3 = not (v2 > 0) and 0 or math.ceil(v2 + Y * 0.55)
		size:Set(UDim2.new(0, math.max(math.ceil(Y), v3), 0.78, 0))
	end

	local v2 = object:Create("Frame")
	local v3 = {
		Name = `Rank{layoutOrder}`,
		Parent = parent2,
		AbsoluteSizeOnChangedInit = function(p5)
			textSize2:Set((math.max(math.floor(p5.AbsoluteSize.Y * 0.5), 1)))
		end,
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 1 / p3, -4),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.55
	}
	local v4 = object:Create("UICorner")({
		CornerRadius = UDim.new(1)
	})
	local v5 = object:Create("UIGradient")({
		Rotation = -90,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.5) })
	})
	local v6 = object:Create("UIStroke")({
		Thickness = 2,
		BorderOffset = UDim.new(0, -2),
		Color = object:Do(function(callback)
			local v7 = callback(p)[layoutOrder]

			if v7 == nil or v7.UserId ~= localPlayer.UserId then
				return (Color3.new(1, 1, 1))
			end

			return color
		end),
		Transparency = object:Do(function(callback)
			local v7 = callback(p)[layoutOrder]

			if v7 == nil or v7.UserId ~= localPlayer.UserId then
				return 0.85
			end

			return 0
		end)
	})
	local v7 = object:Create("UIListLayout")({
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6)
	})
	local v8 = object:Create("UIPadding")({
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 9)
	})
	local v9 = object:Create("Frame")
	local v10 = {
		Name = "Disc",
		LayoutOrder = 1,
		Size = size,
		AbsoluteSizeOnChangedInit = fitDisc
	}
	local backgroundColor

	if v then
		backgroundColor = lvlColor
	else
		backgroundColor = Color3.new(0.15, 0.15, 0.15)
	end

	v10.BackgroundColor3 = backgroundColor
	v10.BackgroundTransparency = v and 0 or 0.25
	local v12 = object:Create("UICorner")({
		CornerRadius = UDim.new(1)
	})
	local v13 = object:Create("UIStroke")({
		Color = Color3.new(1, 1, 1),
		Transparency = 0.75
	})
	local v14 = object:Create("TextLabel")
	local v15 = {
		Name = "Rank",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = tostring(layoutOrder),
		TextSize = textSize,
		TextWrapped = false,
		TextBoundsOnChangedInit = function(p5)
			fitDisc(p5.Parent)
		end,
		TextColor3 = 0,
		FontFace = 0
	}
	local textColor

	if v then
		textColor = Color3.new(0.1, 0.1, 0.1)
	else
		textColor = Color3.new(1, 1, 1)
	end

	v15.TextColor3 = textColor
	v15.FontFace = gameSettings.preferedFont
	do local _values = table.pack(v12, v13, v14(v15)); for _k = 1, _values.n do v10[_k] = _values[_k] end end
	local v17 = v9(v10)
	local v18 = object:Create("ImageLabel")({
		Name = "Tier",
		LayoutOrder = 2,
		Size = UDim2.fromScale(0.82, 0.82),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = object:Do(function(callback)
			local v19 = callback(p)[layoutOrder]

			if v19 == nil or v19.Icon == nil then
				return ""
			end

			return v19.Icon
		end)
	})
	local v19 = object:Create("TextLabel")({
		Name = "Name",
		LayoutOrder = 3,
		Size = UDim2.fromScale(0, 0.6),
		BackgroundTransparency = 1,
		Text = object:Do(function(callback)
			local v20 = callback(p)[layoutOrder]

			if v20 == nil then
				return "Unclaimed"
			end

			return (shorten(v20.Name))
		end),
		TextSize = textSize2,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = object:Do(function(callback)
			if callback(p)[layoutOrder] == nil then
				return 0.5
			end

			return 0
		end),
		FontFace = gameSettings.preferedFont,
		object:Create("UIFlexItem")({
			FlexMode = Enum.UIFlexMode.Fill
		}),
		object:Create("UIStroke")({
			Thickness = 2,
			Transparency = 0.9
		})
	})
	local v20 = object:Create("TextLabel")
	local v21 = {
		Name = "Score",
		LayoutOrder = 4,
		Size = UDim2.fromScale(0.26, 0.6),
		BackgroundTransparency = 1,
		Text = object:Do(function(callback)
			local v22 = callback(p)[layoutOrder]

			if v22 == nil then
				return ""
			end

			return (Utility.addCommasToNumber(v22.Score))
		end),
		TextSize = textSize2,
		TextXAlignment = Enum.TextXAlignment.Right
	}
	local textColor2

	if v then
		textColor2 = lvlColor
	else
		textColor2 = Color3.new(1, 1, 1)
	end

	v21.TextColor3 = textColor2
	v21.FontFace = gameSettings.preferedFont
	do local _values = table.pack(object:Create("UIStroke")({
	Thickness = 2,
	Transparency = 0.9
})); for _k = 1, _values.n do v21[_k] = _values[_k] end end
	do local _values = table.pack(v4, v5, v6, v7, v8, v17, v18, v19, v20(v21)); for _k = 1, _values.n do v3[_k] = _values[_k] end end
	return v2(v3)
end