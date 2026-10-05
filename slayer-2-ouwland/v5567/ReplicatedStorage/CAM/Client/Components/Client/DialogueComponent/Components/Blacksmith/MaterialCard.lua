local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
require(ReplicatedStorage.CAM.Global.Types.CraftingTypes)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local RefineBadge = require(script.Parent.RefineBadge)
local TierBadge = require(script.Parent.TierBadge)
local info = faye.Info(0.2)
local color = Color3.fromRGB(255, 95, 95)
local color2 = Color3.new(1, 1, 1)
return function(object, p, callback, callback2, p2: number?)
	local item = Items[p.name]
	local v = item ~= nil and Rarities.Colors[item.Rarity] or Color3.new(1, 1, 1)
	local name

	if #p.name > 16 then
		name = `{string.sub(p.name, 1, 14)}..`
	else
		name = p.name
	end

	local v2 = object:Create("Frame")
	local v3 = {
		Name = p.name,
		Size = UDim2.fromScale(1, 0.3),
		BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		BackgroundTransparency = 0.5
	}
	local v4 = object:Create("UICorner")({
		CornerRadius = UDim.new(0.2)
	})
	local v5 = object:Create("UIStroke")({
		Color = Color3.new(1, 1, 1),
		BorderOffset = UDim.new(0, -4),
		Transparency = 0.9
	})
	local v6 = object:Create("Frame")
	local v7 = {
		Name = "IconHolder",
		Size = UDim2.fromScale(0.75, 0.75),
		Instance.new("UIAspectRatioConstraint"),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 6, 0.5),
		BackgroundTransparency = 1
	}
	local v8 = object:Create("ImageLabel")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.1, 1.1),
		BackgroundTransparency = 1,
		Image = item == nil and "" or item.Icon or "",
		ZIndex = 2
	})
	local v9

	if callback2 ~= nil then
		v9 = RefineBadge(object, function(p3)
			return callback2(p3, p.name)
		end) or nil
	end

	local v10

	if p2 ~= nil then
		v10 = TierBadge(object, p2) or nil
	end

	do local _values = table.pack(v8, v9, v10, object:Create("Frame")({
	Name = "Bg",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.6, 0.6),
	Rotation = 45,
	BackgroundColor3 = v,
	object:Create("UICorner")({
		CornerRadius = UDim.new(0.2)
	}),
	object:Create("UIGradient")({
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 1) }),
		Rotation = -90
	}),
	object:Create("UIShadow")({
		BlurRadius = UDim.new(1),
		Color = v,
		Spread = UDim2.fromScale(-0.5, -0.5)
	})
})); for _k = 1, _values.n do v7[1 + _k] = _values[_k] end end
	do local _values = table.pack(v4, v5, v6(v7), object:Create("TextLabel")({
	Name = "ItemName",
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0.36, 0.52),
	Size = UDim2.fromScale(0.6, 0.32),
	BackgroundTransparency = 1,
	Font = Enum.Font.SourceSansSemibold,
	Text = name,
	TextColor3 = Color3.new(1, 1, 1),
	TextScaled = true,
	TextXAlignment = Enum.TextXAlignment.Left
}), object:Create("TextLabel")({
	Name = "Count",
	Position = UDim2.fromScale(0.36, 0.54),
	Size = UDim2.fromScale(0.6, 0.338),
	BackgroundTransparency = 1,
	Font = Enum.Font.SourceSansBold,
	Text = object:Do(function(p3)
		return (`{callback(p3, p.name)}/{p.amount}`)
	end),
	TextColor3 = object:Do(function(p3)
		local v12

		if callback(p3, p.name) >= p.amount then
			v12 = color2
		else
			v12 = color
		end

		return object:Animation(v12, info)
	end),
	TextTransparency = 0.15,
	TextScaled = true,
	TextStrokeTransparency = 0.8,
	TextXAlignment = Enum.TextXAlignment.Left
})); for _k = 1, _values.n do v3[_k] = _values[_k] end end
	return v2(v3)
end