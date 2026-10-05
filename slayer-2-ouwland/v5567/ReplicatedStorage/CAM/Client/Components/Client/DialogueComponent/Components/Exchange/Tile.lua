local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local Adders = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.Adders)
local info = faye.Info(0.2)
local color = Color3.fromRGB(255, 95, 95)
return function(object, layoutOrder: number, name: string, data)
	local item = Items[name]
	local backgroundColor = item ~= nil and Rarities.Colors[item.Rarity] or Color3.new(1, 1, 1)
	local text = item == nil and "" or item.SetMaterial or ""
	local text2 = string.gsub(name, "^%a+ ", "")
	local v4

	if data.Owned == nil then
		v4 = nil
	else
		v4 = data.Owned[name] or 0
	end

	local v5 = v4 == 0
	local flag = false
	local value2 = object:Value(false)

	local function state(callback)
		if callback(data.Picked) == name then
			return 2
		end

		if callback(value2) and not v5 then
			return 1
		end

		return 0
	end

	local v6 = object:Create("Frame")
	local v7 = {
		Name = name,
		LayoutOrder = layoutOrder,
		Size = UDim2.fromScale(1, 1),
		object:Create("UIAspectRatioConstraint")({
			DominantAxis = Enum.DominantAxis.Height
		}),
		BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		BackgroundTransparency = object:Do(function(callback)
			return object:Animation(
				({ 0.7, 0.5, 0.3 })[(callback(data.Picked) == name and 2 or callback(value2) and not v5 and 1 or 0) + 1],
				info
			)
		end)
	}
	local v8 = object:Create("UICorner")({
		CornerRadius = UDim.new(0.15)
	})
	local v9 = object:Create("UIStroke")({
		Color = Color3.new(1, 1, 1),
		BorderOffset = UDim.new(0, -4),
		Transparency = object:Do(function(callback)
			return object:Animation(
				({ 0.9, 0.6, 0.2 })[(callback(data.Picked) == name and 2 or callback(value2) and not v5 and 1 or 0) + 1],
				info
			)
		end),
		Thickness = object:Do(function(callback)
			return object:Animation(
				({ 1, 1.5, 2 })[(callback(data.Picked) == name and 2 or callback(value2) and not v5 and 1 or 0) + 1],
				info
			)
		end)
	})
	local v10 = object:Create("Frame")({
		Name = "Glow",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.fromScale(1, 0.5),
		BackgroundColor3 = backgroundColor,
		ZIndex = 0,
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.15)
		}),
		object:Create("UIGradient")({
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1) }),
			Rotation = -90
		})
	})
	local v11 = object:Create("ImageLabel")({
		Name = "Icon",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.04),
		Size = UDim2.fromScale(0.46, 0.46),
		BackgroundTransparency = 1,
		ImageTransparency = v5 and 0.6 or 0,
		Image = item == nil and "" or item.Icon or ""
	})
	local v12 = object:Create("TextLabel")({
		Name = "SetName",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.51),
		Size = UDim2.fromScale(0.92, 0.1),
		BackgroundTransparency = 1,
		Font = Enum.Font.SourceSansSemibold,
		Text = text,
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = v5 and 0.7 or 0.3,
		TextScaled = true
	})
	local v13 = object:Create("TextLabel")({
		Name = "ItemName",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.61),
		Size = UDim2.fromScale(0.92, 0.15),
		BackgroundTransparency = 1,
		Font = Enum.Font.SourceSansSemibold,
		Text = text2,
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = v5 and 0.5 or 0,
		TextScaled = true
	})
	local v14

	if v4 ~= nil then
		local v15 = object:Create("TextLabel")
		local v16 = {
			Name = "Count",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.76),
			Size = UDim2.fromScale(0.9, 0.2),
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansBold,
			Text = `x{v4}`,
			TextColor3 = 0,
			TextScaled = true,
			TextStrokeTransparency = 0.8
		}
		local textColor

		if v5 then
			textColor = color
		else
			textColor = Color3.new(1, 1, 1)
		end

		v16.TextColor3 = textColor
		v14 = v15(v16) or nil
	end

	do local _values = table.pack(v8, v9, v10, v11, v12, v13, v14, object:State(function(callback, object2)
	local editor = data.Editor

	if editor == nil or callback(data.Picked) ~= name or (v4 or 0) < 2 then
		return
	end

	local step = editor.Step
	return object2:Create("Frame")({
		ZIndex = 5,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.3),
		Size = UDim2.fromScale(0.9, 0.25),
		BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
		BackgroundTransparency = object2:Animation(0.2, info, {
			From = 1
		}),
		object2:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.25, 0),
				NumberSequenceKeypoint.new(0.75, 0),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		object2:Create("TextLabel")({
			ZIndex = 5,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.45, 0.95),
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansBold,
			Text = object2:Do(function(callback2)
				return (tostring(callback2(editor.Amount)))
			end),
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true
		}),
		Adders(object2, {}, -90, function()
			step(1)
		end),
		Adders(object2, {
			Position = UDim2.fromScale(1, 0.5),
			AnchorPoint = Vector2.new(1, 0.5)
		}, 90, function()
			step(-1)
		end)
	})
end), object:Create("TextButton")({
	Name = "Hover",
	ZIndex = 3,
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	MouseButton1Click = function()
		if v5 then
			return
		end

		ScreenEffects.CircleClick()
		data.Pick(name)
	end,
	MouseEnter = function()
		if flag then
			return
		end

		flag = true
		value2:Set(true)
	end,
	MouseLeave = function()
		if not flag then
			return
		end

		flag = false
		value2:Reset()
	end
})); for _k = 1, _values.n do v7[1 + _k] = _values[_k] end end
	return v6(v7)
end