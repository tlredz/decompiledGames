local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local useDebounceRef = require(game.ReplicatedStorage.React.Hooks.useDebounceRef)
local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
local Button = require(game.ReplicatedStorage.React.Components.Button)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local state, setState = React.useState(nil)
	local v = useSpring(props.IsOpen and 1 or 0, props.IsOpen and 1 or 0, 0.8, 1.5)
	local v2 = useSpring(props.ErrorMessage and 1 or 0, props.ErrorMessage and 1 or 0, 0.8, 1.5)
	local v3, v4 = useDebounceRef(1.5)

	if v <= 0 then
		return nil
	end

	local mergeGuiObject = RobloxTypes.mergeGuiObject({
		AnchorPoint = Vector2.new(0.5, 0.5 - 0.5 * (1 - v)),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.HALF,
		Position = UDim2.fromScale(0.5, 0.5 + 0.55 * (1 - v)),
		Size = UDim2.fromScale(0.4, 0.4)
	}, props)
	local children = {
		UISizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(1000, 450),
			MinSize = Vector2.new(475, 273)
		}),
		Title = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			Position = UDim2.fromScale(0, 8.59444e-8),
			Size = UDim2.fromScale(1, 0.143191)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
					ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
					ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
				})
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.8, 0.75),
				Text = "Redeem Codes",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				}),
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(1, 1),
					Text = "Redeem Codes",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
					})
				})
			}),
			Close = createElement("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
				BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
				FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
				LayoutOrder = -999,
				Position = UDim2.fromScale(0.985, 0.5),
				Size = UDim2.fromScale(0.7, 0.7),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Text = "",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				ZIndex = CONSTANTS.LAYER.RAISED,
				[React.Event.Activated] = props.OnCloseClick
			}, {
				Trans = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.94, 0.47)
				}),
				Icon = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://127503254560275",
					ImageRectSize = Vector2.new(100, 100),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					ZIndex = CONSTANTS.LAYER.RAISED
				})
			})
		}),
		Content = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			BorderColor3 = Color3.fromRGB(255, 197, 20),
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0, 0.143191),
			Size = UDim2.fromScale(1.00126, 0.691646)
		}, {
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 0.345935),
				Size = UDim2.fromScale(0.652123, 0.429683),
				Text = "Enter gift codes to redeem DLC items and gifts! Follow us @BloxFruits",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				})
			}),
			Frame = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900,
				BackgroundTransparency = 0.02,
				Position = UDim2.fromScale(0.499996, 0.755064),
				Size = UDim2.fromScale(0.7, 0.21147)
			}, {
				UIStroke = createElement("UIStroke", {
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.04
				}),
				UICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
				}),
				TextBox = createElement("TextBox", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					AutomaticSize = Enum.AutomaticSize.None,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					PlaceholderColor3 = CONSTANTS.COLOR.PALETTE.GREY_500,
					PlaceholderText = "Enter Promo Code",
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.9, 0.7),
					Text = state or "",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					[React.Change.Text] = function(p)
						local v19 = p.Text:upper():gsub("%s", ""):gsub("%p", "")
						local v21

						if not (v19:len() <= 0) then
							v21 = v19
						end

						setState(v21)
						p.Text = v19:sub(1, 12)
					end
				})
			}),
			ImageLabel = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://138207268577780",
				Position = UDim2.fromScale(0.5, 1),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1, 0.786076),
				ZIndex = CONSTANTS.LAYER.BASE
			})
		}),
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.8
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XXS
		}),
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		ErrorMessage = 0,
		Footer = 0
	}
	local errorMessage

	if props.ErrorMessage then
		errorMessage = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1 - v2),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.5, 1 + 0.05 * v2),
			Size = UDim2.fromScale(0.9, 0.1),
			Text = props.ErrorMessage,
			TextColor3 = Color3.fromRGB(255, 0, 0),
			TextTransparency = 1 - v2,
			TextScaled = true,
			ZIndex = CONSTANTS.LAYER.CONTENT
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			})
		})
	end

	children.ErrorMessage = errorMessage
	children.Footer = createElement("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		LayoutOrder = 2,
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 0.165164),
		ZIndex = CONSTANTS.LAYER.RAISED
	}, {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = CONSTANTS.SPACING.PADDING.SCALE.MD,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		Redeem = createElement(Button, {
			BackgroundColor3 = Color3.fromHex("FFD531"),
			ElevatedBackgroundColor3 = Color3.fromHex("FFF158"),
			BorderColor3 = CONSTANTS.COLOR.PRIMARY.BORDER,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.454775, 0.15),
			Size = UDim2.fromScale(0.25, 0.7),
			YPadding = UDim.new(0, 0),
			Text = "Redeem",
			IsDisabled = not props.OnSubmitCode and state and true or false,
			OnClick = props.OnSubmitCode and function()
				if v3.current or not state then
					return
				end

				v4()
				setState(nil)
				props.OnSubmitCode(state)
			end or function() end,
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
		})
	})
	return createElement("Frame", mergeGuiObject, children)
end