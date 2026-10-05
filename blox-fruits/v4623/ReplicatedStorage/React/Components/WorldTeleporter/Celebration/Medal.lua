local React = require(game.ReplicatedStorage.Packages.React)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local Star = require(game.ReplicatedStorage.React.Components.IslandTile.Star)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local PALETTE = CONSTANTS.COLOR.PALETTE
local goldMedal1 = SpriteMap.All["Gold Medal1"]
local shadow = SpriteMap.All.Shadow
local color = Color3.new(1, 0.85098, 0)
local uDim = UDim2.fromScale(0.35, 0.35)
local createElement = React.createElement

local function glow(p: number, color2: Color3, value: number, zIndex: number?)
	return createElement("ImageLabel", {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = shadow.Image,
		ImageRectOffset = shadow.ImageRectOffset,
		ImageRectSize = shadow.ImageRectSize,
		Size = UDim2.fromScale(p, p),
		ImageTransparency = math.clamp(value, 0, 1),
		ImageColor3 = color2,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Active = false,
		ZIndex = zIndex
	})
end

local function orbitStar(i: number, p: number, p2: number, p3: number)
	local v = math.rad(p + (i - 1) * 360 / 3)
	return createElement(Star, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = uDim,
		IsCompleted = true,
		ZIndex = CONSTANTS.LAYER.RAISED,
		Position = UDim2.fromScale(math.cos(v) * p2 + 0.5, math.sin(v) * p2 + 0.5)
	}, {
		Glow = glow(2, color, p3)
	})
end

return function(props)
	local v = math.clamp(props.Alpha, 0, 1)
	local v2 = math.clamp((v - 0.5) / 0.5, 0, 1)
	local v3 = usePeriod(v2 > 0, 3) * 360
	local v4 = math.max(props.Alpha, 0) * (1 + 0.08 * props.Pulse)
	local size = props.Size or UDim2.fromScale(0.5, 0.5)
	local position = props.Position or UDim2.fromScale(0.5, 0.5)
	local v5 = {}

	for i = 1, 3 do
		v5[`Star{i}`] = orbitStar(i, v3, v2 * 0.55, (1 - v2) * 0.2 + 0.8)
	end

	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = position + UDim2.fromScale(0, (1 - v) * 0.35),
		Size = UDim2.fromScale(size.X.Scale * v4, size.Y.Scale * v4),
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}, props), {
		Glow = glow(1.35, PALETTE.WHITE, (1 - v) * 0.5 + 0.5 - 0.25 * props.Pulse, CONSTANTS.LAYER.CONTENT),
		Stars = createElement(React.Fragment, {}, v5),
		Medal = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Rotation = (1 - v) * -25,
			Image = goldMedal1.Image,
			ImageRectOffset = goldMedal1.ImageRectOffset,
			ImageRectSize = goldMedal1.ImageRectSize,
			ImageColor3 = PALETTE.WHITE:Lerp(CONSTANTS.COLOR.DISABLED.TINT, 1 - v2),
			Active = false,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		})
	})
end