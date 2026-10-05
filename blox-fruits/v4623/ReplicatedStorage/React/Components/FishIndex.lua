local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishIndexMain = require(script.FishIndexMain)
require(ReplicatedStorage.Modules.SerData.FishIndex)
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.React.Components.FishIndex.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local font = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO)
return function(p)
	return React.createElement("Frame", {
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 1, 0),
		Visible = p.IsOpen
	}, {
		uICorner = React.createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XXS
		}),
		uIStroke = React.createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		uiAspectRationConstraint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.36
		}),
		header = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			Position = UDim2.fromScale(0.5, 3.38207e-8),
			Size = UDim2.fromScale(1, 0.0898869)
		}, {
			uICorner = React.createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			uIStroke = React.createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			uIGradient = React.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
					ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
					ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
				})
			}),
			textLabel = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.8, 0.75),
				Text = "Fish Index",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true
			}, {
				uIStroke = React.createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				}),
				textLabel = React.createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(1, 1),
					Text = "Fish Index",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					uIStroke = React.createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
					})
				})
			}),
			close = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
				BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
				FontFace = font,
				LayoutOrder = -999,
				Position = UDim2.fromScale(0.99, 0.5),
				Size = UDim2.fromScale(0.053, 0.794626),
				Text = "",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				ZIndex = CONSTANTS.LAYER.RAISED,
				[React.Event.MouseButton1Up] = function()
					p.SetIsOpen(false)
				end
			}, {
				trans = React.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.94, 0.47),
					ZIndex = CONSTANTS.LAYER.RAISED_HIGH
				}),
				icon = React.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://127503254560275",
					ImageRectSize = Vector2.new(100, 100),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					ZIndex = 4
				})
			})
		}),
		indexFrame = React.createElement(FishIndexMain, p)
	})
end