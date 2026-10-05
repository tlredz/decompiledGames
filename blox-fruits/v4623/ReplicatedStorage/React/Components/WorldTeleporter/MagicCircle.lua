local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local useTheme = require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.useTheme)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local uDim = UDim.new(0.035, 0)
local createElement = React.createElement
return function(props)
	local v = useTheme()
	local v2 = usePeriod(props.RotationPeriod ~= nil, props.RotationPeriod or 1) * 360

	if props.RotateCounterClockwise then
		v2 *= -1
	end

	local borderOffset = props.BorderOffset or uDim
	local thickness = props.Thickness or 0.01
	local edgeThickness = props.EdgeThickness or thickness / 2
	local imageColor3 = props.ImageColor3 or v.Primary
	local mergeFrame = RobloxTypes.mergeFrame({
		Rotation = (props.Rotation or 0) + v2,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, props)
	local shadowContainer

	if props.NoGlow == true then
		shadowContainer = false
	else
		shadowContainer = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BackgroundColor3 = v.Background,
			Size = UDim2.fromScale(0.7, 0.7),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
			}),
			Glow1 = createElement("UIShadow", {
				Color = v.Background,
				BlurRadius = UDim.new(0.5, 0),
				Transparency = props.ImageTransparency,
				ZIndex = CONSTANTS.LAYER.RAISED
			}),
			Glow2 = createElement("UIShadow", {
				Color = v.Background,
				BlurRadius = UDim.new(0.5, 0),
				Transparency = props.ImageTransparency,
				ZIndex = CONSTANTS.LAYER.RAISED
			}),
			Glow3 = createElement("UIShadow", {
				Color = v.Background,
				BlurRadius = UDim.new(0.5, 0),
				Transparency = props.ImageTransparency,
				ZIndex = CONSTANTS.LAYER.RAISED
			})
		})
	end

	return createElement("Frame", mergeFrame, {
		ShadowContainer = shadowContainer,
		GlowContainer = props.NoGlow ~= true and createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(0.8, 0.8),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
			}),
			Glow = createElement("UIShadow", {
				Color = imageColor3,
				BlurRadius = UDim.new(0.5, 0),
				Transparency = props.ImageTransparency
			})
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = props.CornerRadius or CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
		}),
		Inner = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Color = imageColor3,
			Thickness = edgeThickness,
			Transparency = props.EdgeTransparency or props.ImageTransparency,
			BorderOffset = UDim.new(-borderOffset.Scale, borderOffset.Offset)
		}),
		Main = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Color = imageColor3,
			Thickness = thickness,
			Transparency = props.ImageTransparency,
			BorderOffset = UDim.new(0, 0)
		}),
		Outer = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Color = imageColor3,
			Thickness = edgeThickness,
			Transparency = props.EdgeTransparency or props.ImageTransparency,
			BorderOffset = borderOffset
		})
	})
end