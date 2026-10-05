local React = require(game.ReplicatedStorage.Packages.React)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local EasterEggs = require(game.ReplicatedStorage.Modules.Data.EasterEggs)
local useSprite = require(game.ReplicatedStorage.React.Hooks.useSprite)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	Image = "rbxassetid://88521607622333",
	ImageRectOffset = Vector2.new(272, 0),
	ImageRectSize = Vector2.new(136, 168)
}
local createElement = React.createElement
return function(props)
	local v2 = assert(EasterEggs.List[props.Name])
	local v3 = props.NumOwned > 0
	local color = RarityUtil.matchRarity(v2.Rarity):unwrap().Color
	local v4 = useSprite(props.Name .. "1")

	if not (v4 and v3) then
		v4 = v
	end

	local v7 = {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900,
		BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
		Size = UDim2.fromOffset(100, 100),
		LayoutOrder = props.LayoutOrder,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5)
	}
	local children = {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XS
		}),
		UIStroke = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.HAIRLINE
		}),
		CodexNumber = 0,
		EggIcon = 0,
		EggIsNew = 0,
		EggName = 0,
		Fade = 0
	}
	local v10 = {
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		Size = UDim2.fromScale(1, 0.13),
		Position = UDim2.new(0, 2, 0, 2),
		ZIndex = CONSTANTS.LAYER.RAISED_HIGH,
		Text = 0,
		FontFace = 0
	}
	local v12

	if props.LayoutOrder < 10 then
		v12 = `0{props.LayoutOrder}`
	else
		v12 = props.LayoutOrder
	end

	v10.Text = `#{v12}`
	v10.FontFace = CONSTANTS.FONT.FACE.DISPLAY
	children.CodexNumber = createElement("TextLabel", v10)
	children.EggIcon = createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = v4 and v4.Image,
		ImageRectOffset = v4 and v4.ImageRectOffset,
		ImageRectSize = v4 and v4.ImageRectSize,
		Position = UDim2.fromScale(0.5, 0.402),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(0.8, 0.649451),
		ImageColor3 = v3 and CONSTANTS.COLOR.PALETTE.WHITE or CONSTANTS.COLOR.PALETTE.BLACK,
		ZIndex = CONSTANTS.LAYER.RAISED
	})
	local eggIsNew

	if props.IsNew then
		eggIsNew = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://137891132578039",
			Position = UDim2.new(1, 1, 0, -1),
			Size = UDim2.fromScale(0.27, 0.27)
		}, {
			UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
				AspectRatio = 1
			})
		})
	end

	children.EggIsNew = eggIsNew
	children.EggName = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.DISPLAY,
		Position = UDim2.fromScale(0.5, 0.94),
		Size = UDim2.fromScale(0.9, 0.3),
		Text = v3 and props.Name or "???",
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextYAlignment = Enum.TextYAlignment.Bottom,
		ZIndex = CONSTANTS.LAYER.RAISED_HIGH
	}, {
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.HAIRLINE,
			StrokeSizingMode = Enum.StrokeSizingMode.FixedSize
		})
	})
	children.Fade = createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = color,
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.fromScale(1, 0.761712),
		ZIndex = CONSTANTS.LAYER.BASE
	}, {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XS
		}),
		UIGradient = createElement("UIGradient", {
			Rotation = -90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.581),
				NumberSequenceKeypoint.new(0.356, 0.813),
				NumberSequenceKeypoint.new(0.776, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		})
	})
	return createElement("Frame", v7, children)
end