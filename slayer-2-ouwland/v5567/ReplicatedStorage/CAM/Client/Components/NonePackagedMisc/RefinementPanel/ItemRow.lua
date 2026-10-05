local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local ItemIcon = require(ReplicatedStorage.CAM.Global.Collectibles.ItemIcon)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Refinement = require(ReplicatedStorage.CAM.Global.Refinement)
local faye = require(ReplicatedStorage.Packages.faye)
require(script.Parent.Types)
local info = faye.Info(0.15, Enum.EasingStyle.Sine)
local color = Color3.new(1, 0.803922, 0.305882)
local color2 = Color3.fromRGB(85, 170, 255)
return function(object, data, layoutOrder: number, object2, object3)
	local rarity = Items[data.Name].Rarity or 1
	local color3 = Rarities.Colors[rarity]
	local v = data.RefineLevel >= Refinement.MaxLevel
	local value = object:Value(0.92)
	local value2 = object:Value(0.8)
	local value3 = object:Value(1)
	local value4 = object:Value(false)
	object:Reactive(function(callback)
		local v2 = callback(object2) == data.Id
		local v3 = callback(value4)

		if v2 then
			value:Set(0.18)
			value2:Set(0.05)
		elseif v3 then
			value:Set(0.45)
			value2:Set(0.25)
		elseif data.Equipped then
			value:Set(0.62)
			value2:Set(0.4)
		else
			value:Reset()
			value2:Reset()
		end

		value3:Set(v2 and 0.15 or data.Equipped and 0.6 or 1)
	end)
	local v2 = object:Create("Frame")
	local v3 = {
		Name = data.Name,
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
	}
	local v4 = object:Create("UICorner")({
		CornerRadius = UDim.new(0, 4)
	})
	local v5 = object:Create("Frame")({
		Name = "Fg",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = color3,
		BackgroundTransparency = object:Animation(value, info),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0, 4)
		}),
		object:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(0.6, 0.9),
				NumberSequenceKeypoint.new(1, 1)
			})
		})
	})
	local v6 = object:Create("Frame")({
		Name = "EqFg",
		ZIndex = 2,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -2, 1, -2),
		BackgroundTransparency = 1,
		object:Create("UICorner")({
			CornerRadius = UDim.new(0, 3)
		}),
		object:Create("UIStroke")({
			Thickness = 1,
			Color = Color3.new(1, 1, 1),
			Transparency = object:Animation(value3, info)
		})
	})
	local v7 = object:Create("UIStroke")({
		Thickness = 1,
		Color = color3,
		Transparency = object:Animation(value2, info)
	})
	local v8 = object:Create("ImageLabel")({
		Name = "Icon",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 6, 0.5, 0),
		Size = UDim2.fromScale(0.8, 0.8),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = ItemIcon.For(Players.LocalPlayer, data.Name)
	})
	local v9 = object:Create("TextLabel")
	local v10 = {
		Name = "ItemName",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 36, 0.5, 0),
		Size = UDim2.new(0.62, -36, 0.5, 0),
		BackgroundTransparency = 1,
		Text = data.Name,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.SourceSansBold
	}

	if rarity >= 6 then
		color3 = color3:Lerp(Color3.new(1, 1, 1), 0.4)
	end

	v10.TextColor3 = color3
	do local _values = table.pack(object:Create("UITextSizeConstraint")({
	MaxTextSize = 16
}), object:Create("UIStroke")({
	Thickness = 1,
	Transparency = 0.5
})); for _k = 1, _values.n do v10[_k] = _values[_k] end end
	local v11 = v9(v10)
	local v12 = object:Create("TextLabel")
	local v13 = {
		Name = "Level",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0.32, -8, 0.56, 0),
		BackgroundTransparency = 1
	}
	local text

	if v then
		text = `+{data.RefineLevel} max`
	else
		text = `+{data.RefineLevel}`
	end

	v13.Text = text
	v13.TextScaled = true
	v13.TextXAlignment = Enum.TextXAlignment.Right
	v13.Font = Enum.Font.SourceSansBold
	local textColor

	if v then
		textColor = color
	else
		textColor = color2
	end

	v13.TextColor3 = textColor
	do local _values = table.pack(object:Create("UITextSizeConstraint")({
	MaxTextSize = 20
}), object:Create("UIStroke")({
	Thickness = 1,
	Transparency = 0.5
})); for _k = 1, _values.n do v13[_k] = _values[_k] end end
	local v16 = v12(v13)
	local v17

	if data.Equipped then
		v17 = object:Create("Frame")({
			Name = "Equipped",
			ZIndex = 2,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0, 12, 1, -3),
			Size = UDim2.fromScale(0.44, 0.44),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			object:Create("ImageLabel")({
				Name = "Square",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.8, 0.8),
				BackgroundTransparency = 1,
				Image = "rbxassetid://116594504938394",
				ImageTransparency = 0.5
			}),
			object:Create("ImageLabel")({
				Name = "Checkmark",
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://115228880374136"
			})
		})
	end

	do local _values = table.pack(v4, v5, v6, v7, v8, v11, v16, v17, object:Create("TextButton")({
	Name = "Hit",
	ZIndex = 3,
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	MouseButton1Click = function()
		if object3:Get() == true then
			return
		end

		ScreenEffects.CircleClick()
		object2:Set(data.Id)
	end,
	MouseEnter = function()
		value4:Set(true)
	end,
	MouseLeave = function()
		value4:Set(false)
	end
})); for _k = 1, _values.n do v3[_k] = _values[_k] end end
	return v2(v3)
end