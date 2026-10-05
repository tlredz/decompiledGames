local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(script.Parent.Parent.Parent.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local key = props.Skill.Key
	local starCount = props.Skill.StarCount
	local displayName = props.Skill.DisplayName
	local selectionAlpha = props.SelectionAlpha
	local starBackgroundColor3 = props.StarBackgroundColor3
	local chipBackgroundColor3 = props.ChipBackgroundColor3 or CONSTANTS.COLOR.PALETTE.BLACK
	local chipTransparency = props.ChipTransparency or 0.55
	return createElement("Frame", RobloxTypes.mergeGuiObject({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		AutomaticSize = Enum.AutomaticSize.None,
		LayoutOrder = starCount,
		Size = UDim2.fromScale(1, 0.14)
	}, props), {
		MoveName = createElement("TextLabel", {
			LayoutOrder = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.61, 0),
			Size = UDim2.fromScale(0, 1),
			Text = displayName,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextSize = 14,
			TextStrokeTransparency = 0.7,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			Visible = false
		}),
		UIListLayout9 = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = CONSTANTS.SPACING.PADDING.SCALE.SM,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		Mastery = createElement("Frame", {
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			LayoutOrder = 3,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = CONSTANTS.ALPHA.HALF,
			BackgroundColor3 = starBackgroundColor3,
			Position = UDim2.fromScale(0.769, -0.025),
			Size = UDim2.fromScale(4, 1.14)
		}, {
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticSize = Enum.AutomaticSize.None,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				LayoutOrder = 4,
				Position = UDim2.fromScale(0.5, 0.51),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.fromScale(1.5, 0.9),
				Text = `{starCount}`,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextStrokeTransparency = CONSTANTS.ALPHA.HALF,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextWrapped = true
			}),
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.035, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			ImageLabel = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Image = "rbxassetid://113701888044237",
				Position = UDim2.fromScale(0.05, -0.35),
				ScaleType = Enum.ScaleType.Fit,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.fromScale(0.9, 0.9)
			}),
			UIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.199, 0),
					NumberSequenceKeypoint.new(0.8, 0),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		}),
		Keybind = createElement("Frame", {
			BackgroundColor3 = chipBackgroundColor3,
			BackgroundTransparency = chipTransparency,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.654, -0.07),
			Size = UDim2.fromScale(1.14, 1.14),
			LayoutOrder = 2,
			SizeConstraint = Enum.SizeConstraint.RelativeYY
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.15, 0)
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				LayoutOrder = 4,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.85),
				Text = `{key.Name}`,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextSize = 14,
				TextWrapped = true
			})
		}),
		Title = createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = chipBackgroundColor3,
			BackgroundTransparency = 1 - selectionAlpha * (1 - chipTransparency),
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			LayoutOrder = -999,
			Position = UDim2.fromScale(-0.169, 0.491),
			Size = UDim2.fromScale(0, 1.14),
			Visible = selectionAlpha > 0
		}, {
			Label = createElement("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromScale(0, 0.9),
				Text = displayName,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextSize = 14,
				TextWrapped = true,
				TextTransparency = 1 - selectionAlpha
			}),
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.15, 0)
			}),
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = CONSTANTS.SPACING.PADDING.OFFSET.XS,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			UIPadding = createElement("UIPadding", {
				PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.SM,
				PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.SM
			})
		})
	})
end