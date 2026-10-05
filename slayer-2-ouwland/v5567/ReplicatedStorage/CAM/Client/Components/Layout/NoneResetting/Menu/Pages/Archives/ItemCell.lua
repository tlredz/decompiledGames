local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local RarityShine = require(ReplicatedStorage.CAM.Client.Components.Misc.RarityShine)
local color = Color3.new(0.15, 0.15, 0.15)
local uDim = UDim.new(0.1)
local color2 = Color3.new(1, 1, 1)
local info = faye.Info(0.15)
local color3 = Color3.new(0.45, 0.45, 0.45)
local color4 = Color3.new(1, 1, 1)
local info2 = faye.Info(0.3)
return function(object, name: string, object2, p2, p3, size, position)
	local item = Items[name]
	local color6

	if item ~= nil then
		color6 = Rarities.Gradients[item.Rarity or 1]
	end

	local color5

	if color6 == nil then
		color5 = item ~= nil and Rarities.Colors[item.Rarity or 1] or Color3.new()
	else
		color5 = Color3.new(1, 1, 1)
	end

	local flag = false
	local flag2 = false
	local v2 = object:Create("Frame")
	local v3 = {
		Name = name,
		Size = size,
		Position = position,
		BackgroundColor3 = color
	}
	local v4 = object:Create("UICorner")({
		CornerRadius = uDim
	})
	local v5 = object:Create("UIStroke")
	local v8

	if item ~= nil then
		v8 = item.Rarity or nil
	end

	do local _values = table.pack(v4, v5({
	Thickness = 1,
	Color = color5,
	Transparency = 0.3,
	RarityShine(v8, "Spin")
}), object:Create("Frame")({
	Name = "Fg",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = color5,
	BackgroundTransparency = 0.5,
	object:Create("UICorner")({
		CornerRadius = uDim
	}),
	object:Create("UIGradient")({
		Rotation = -90,
		Color = color6,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.6, 0.9),
			NumberSequenceKeypoint.new(0.8, 1),
			NumberSequenceKeypoint.new(1, 1)
		})
	})
}), object:Create("ImageLabel")({
	Name = "Img",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Image = item == nil and "" or item.Icon or "",
	ImageColor3 = object:Do(function(callback)
		local selected

		if callback(p2)[name] == true then
			selected = color4
		else
			selected = color3
		end

		if flag then
			return object:Animation(selected, info2)
		end

		flag = true
		return selected
	end)
}), object:Create("Frame")({
	object:State(function(callback, object3)
		if callback(p2)[name] ~= true then
			return object3:Create("ImageLabel")({
				Name = "Lock",
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.45, 0.45),
				BackgroundTransparency = 1,
				Image = BunchaIcons.Locked,
				ImageTransparency = 0.4,
				object3:Create("UIShadow")({
					BlurRadius = UDim.new(0.25, 0),
					Offset = UDim2.fromScale(0.05, 0.05),
					Transparency = 0.4
				})
			})
		end

		if callback(p3)[name] == true then
			return
		else
			return object3:Create("ImageLabel")({
				Name = "NotHeld",
				ZIndex = 2,
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromOffset(5, 5),
				Size = UDim2.fromScale(0.3, 0.3),
				BackgroundTransparency = 1,
				Image = BunchaIcons.NotHeld,
				ImageTransparency = 0.4,
				object3:Create("UIShadow")({
					BlurRadius = UDim.new(0.25, 0),
					Offset = UDim2.fromScale(0.05, 0.05),
					Transparency = 0.4
				})
			})
		end
	end),
	Name = "SelFg",
	ZIndex = 2,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(1, -5, 1, -5),
	BackgroundTransparency = 1,
	object:Create("UICorner")({
		CornerRadius = uDim
	}),
	object:Create("UIStroke")({
		Thickness = 1,
		Color = color2,
		Transparency = object:Do(function(callback)
			local selected = callback(object2) == name and 0 or 1

			if flag2 then
				return object:Animation(selected, info)
			end

			flag2 = true
			return selected
		end)
	})
}), object:Create("TextButton")({
	Name = "Clickbox",
	ZIndex = 3,
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	MouseButton1Click = function()
		ScreenEffects.CircleClick()

		if object2:Compare(name) then
			object2:Set("")
		else
			object2:Set(name)
		end
	end
})); for _k = 1, _values.n do v3[_k] = _values[_k] end end
	return v2(v3)
end