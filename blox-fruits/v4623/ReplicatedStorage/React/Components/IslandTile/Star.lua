local React = require(game.ReplicatedStorage.Packages.React)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local useStrictLerp = require(game.ReplicatedStorage.React.Hooks.Animation.useStrictLerp)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local badgeStar = SpriteMap.UI["Badge Star"]
local createElement = React.createElement
return function(p)
	local v = useStrictLerp(
		p.IsCompleted and 1 or 0,
		p.IsCompleted and 1 or 0,
		0.3,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	)
	return createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		Image = badgeStar.Image,
		ImageRectOffset = badgeStar.ImageRectOffset,
		ImageRectSize = badgeStar.ImageRectSize,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ImageColor3 = Color3.fromHSV(0, 0, 1 - (1 - v) * 1),
		ScaleType = Enum.ScaleType.Fit
	}, p), {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
		}),
		Shadow = createElement("UIShadow", {
			Color = Color3.new(1, 0.678431, 0.117647):Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 1 - v),
			BlurRadius = UDim.new(0.5, 0),
			Offset = UDim2.fromScale(0, 0),
			Spread = UDim2.fromScale(0.2, 0.2),
			Transparency = 0.2,
			ZIndex = p.IsCompleted and 2 or 0
		})
	})
end