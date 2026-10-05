local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local Header = require(game.ReplicatedStorage.React.Components.Gacha.ChromaticBanner.Header)
local Selection = require(game.ReplicatedStorage.React.Components.Gacha.ChromaticBanner.Selection)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	return createElement("Frame", RobloxTypes.mergeFrame({
		Size = props.Size or UDim2.fromScale(1, 1),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900
	}, props), {
		Header = createElement(Header, {
			Size = UDim2.fromScale(1, 0.17)
		}),
		Selection = createElement(Selection, {
			Position = UDim2.fromScale(0.218718, 0.34),
			Size = UDim2.fromScale(0.440815, 0.137569),
			ZIndex = 10,
			AnchorPoint = Vector2.new(0.5, 1),
			TimeEnds = props.TimeEnds
		}),
		PatternFade = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://81943835360193",
			Position = UDim2.fromScale(0.5, 0.37),
			ScaleType = Enum.ScaleType.Crop,
			Size = UDim2.fromScale(1, 0.57),
			TileSize = UDim2.fromScale(0.65, 1),
			ZIndex = -999
		}),
		LowerColorFade = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://128316975538665",
			ImageTransparency = 0.1,
			Position = UDim2.fromScale(0.5, 1),
			Rotation = 180,
			Size = UDim2.fromScale(1, 0.387951)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XS
			}),
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.354059, Color3.fromRGB(255, 93, 177)),
					ColorSequenceKeypoint.new(0.666667, Color3.fromRGB(156, 106, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 221, 255))
				}),
				Rotation = 180
			})
		}),
		UpperColorFade = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://128316975538665",
			ImageTransparency = 0.66,
			Position = UDim2.fromScale(0.5, 0.14),
			Size = UDim2.fromScale(1, 0.533921),
			ZIndex = -99999999
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XS
			}),
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.354059, Color3.fromRGB(255, 93, 177)),
					ColorSequenceKeypoint.new(0.666667, Color3.fromRGB(156, 106, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 221, 255))
				})
			})
		}),
		InnerStroke = createElement("UIStroke", {
			Color = CONSTANTS.COLOR.PALETTE.WHITE,
			Thickness = 0.01,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			BorderStrokePosition = Enum.BorderStrokePosition.Outer,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.354059, Color3.fromRGB(255, 93, 177)),
					ColorSequenceKeypoint.new(0.666667, Color3.fromRGB(156, 106, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 221, 255))
				})
			})
		}),
		OuterStroke = createElement("UIStroke", {
			Color = CONSTANTS.COLOR.PALETTE.BLACK,
			Thickness = 0.013,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			BorderStrokePosition = Enum.BorderStrokePosition.Outer,
			ZIndex = CONSTANTS.LAYER.CONTENT
		})
	}, props.children)
end