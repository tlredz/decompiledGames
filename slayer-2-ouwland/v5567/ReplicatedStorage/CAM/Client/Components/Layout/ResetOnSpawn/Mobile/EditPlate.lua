local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local SlotNumber = require(script.Parent.SlotNumber)
local color = Color3.new(0.15, 0.15, 0.15)
local color2 = Color3.new()
local color3 = Color3.new(1, 1, 1)
return function(object, visible, data)
	local v = data.VisualScale == nil and 1 or data.VisualScale
	local number = data.Number
	local v2 = object:Create("Frame")
	local v3 = {
		Name = "EditPlate",
		Size = UDim2.fromScale(v, v),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Visible = visible
	}
	local v4 = object:Create("ImageLabel")({
		Name = "Bg",
		ZIndex = -1,
		Image = "http://www.roblox.com/asset/?id=134657809787110",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(data.GlowScale, data.GlowScale),
		BackgroundTransparency = 1,
		ImageColor3 = color,
		ImageTransparency = 0.3
	})
	local v5 = object:Create("ImageLabel")({
		Name = "CircleSelect",
		Size = UDim2.fromScale(data.CircleScale, data.CircleScale),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=119489413451678",
		ImageColor3 = color2,
		ImageTransparency = 0.8
	})
	local v6 = object:Create("ImageLabel")({
		Name = "Glyph",
		ZIndex = 2,
		Image = BunchaIcons.Mouse,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		ImageColor3 = color3
	})
	local v7

	if number ~= nil then
		v7 = SlotNumber(object, number.Index, number.At, number.Anchor)
	end

	v3[1], v3[2], v3[3], v3[4] = v4, v5, v6, v7
	return v2(v3)
end