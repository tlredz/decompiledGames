local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local TierBadge = require(script.Parent.TierBadge)
local info = faye.Info(0.2)
local info2 = faye.Info(0.2, Enum.EasingStyle.Back)
return function(object, object2, object3, p: string, p2, size, layoutOrder: number)
	local item = Items[p2.result]

	if item == nil then
		return nil
	end

	local v = Rarities.Colors[item.Rarity] or Color3.new(1, 1, 1)
	local icon = item.Icon
	local result

	if #p2.result > 20 then
		result = `{string.sub(p2.result, 1, 18)}..`
	else
		result = p2.result
	end

	local v2 = {
		Id = p,
		In = object:Value(false),
		BgColor = object:Value(Color3.new(0.1, 0.1, 0.1)),
		BgTransparency = object:Value(0.7),
		StrokeTransparency = object:Value(0.9),
		StrokeThickness = object:Value(1),
		NameGlowTransparency = object:Value(0.8),
		TextPosition = object:Value(UDim2.fromScale(0.5, 0.5)),
		IconSize = object:Value(UDim2.fromScale(1.2, 1.2)),
		IconBgRotation = object:Value(45)
	}
	object2:Add(v2, object, true):Call():Connect(v2.In.Changed)
	local v3 = object:Create("Frame")
	local v4 = {
		Name = p,
		LayoutOrder = layoutOrder,
		Size = size,
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.2)
		}),
		BackgroundColor3 = object:Animation(v2.BgColor, info),
		BackgroundTransparency = object:Animation(v2.BgTransparency, info)
	}
	local v5 = object:Create("UIStroke")({
		Color = Color3.new(1, 1, 1),
		BorderOffset = UDim.new(0, -4),
		Transparency = object:Animation(v2.StrokeTransparency, info),
		Thickness = object:Animation(v2.StrokeThickness, info)
	})
	local v6 = object:Create("TextButton")({
		Name = "Hitbox",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 5,
		MouseButton1Click = function(p5)
			ScreenEffects.StrokeClick(p5.Parent, UDim.new(0.2))
			object3:Set(object3:Compare(p) and "" or p)
		end,
		MouseEnter = function()
			v2.In:Set(true)
		end,
		MouseLeave = function()
			if not v2.In:Compare(true) then
				return
			end

			v2.In:Set(false)
		end
	})
	local v7 = object:Create("Frame")({
		Name = "NameHolder",
		Size = UDim2.fromScale(0.75, 1),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0.24, 0.5),
		BackgroundTransparency = 1,
		object:Create("TextLabel")({
			Font = Enum.Font.SourceSansSemibold,
			Size = UDim2.fromScale(1, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = object:Animation(v2.TextPosition, info),
			BackgroundTransparency = 1,
			Text = result,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true
		}),
		object:Create("Frame")({
			Name = "Bg",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(-0.05, 0, 0.5),
			Size = UDim2.fromScale(1, 0.5),
			ZIndex = -1,
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			BackgroundColor3 = v,
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.9),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			object:Create("UIShadow")({
				BlurRadius = UDim.new(1),
				Color = v,
				Transparency = object:Animation(v2.NameGlowTransparency, info),
				Spread = UDim2.fromScale(-0.5, -0.5)
			})
		})
	})
	local v8 = object:Create("Frame")
	local v9 = {
		Name = "IconHolder",
		Size = UDim2.fromScale(0.75, 0.75),
		Instance.new("UIAspectRatioConstraint"),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 4, 0.5),
		ZIndex = 3,
		BackgroundTransparency = 1
	}
	local v10 = object:Create("ImageLabel")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = icon,
		Size = object:Animation(v2.IconSize, info2),
		ZIndex = 2
	})
	local v11

	if p2.tier ~= nil then
		v11 = TierBadge(object, p2.tier) or nil
	end

	do local _values = table.pack(v10, v11, object:Create("Frame")({
	Name = "Bg",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 4, 0.5),
	Size = UDim2.fromScale(0.6, 0.6),
	object:Create("UICorner")({
		CornerRadius = UDim.new(0.2)
	}),
	BackgroundColor3 = v,
	object:Create("UIGradient")({
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 1) }),
		Rotation = -90
	}),
	object:Create("UIShadow")({
		BlurRadius = UDim.new(1),
		Color = v,
		Spread = UDim2.fromScale(-0.5, -0.5)
	}),
	Rotation = object:Animation(v2.IconBgRotation, info2)
})); for _k = 1, _values.n do v9[1 + _k] = _values[_k] end end
	do local _values = table.pack(v5, v6, v7, v8(v9)); for _k = 1, _values.n do v4[1 + _k] = _values[_k] end end
	return v3(v4)
end