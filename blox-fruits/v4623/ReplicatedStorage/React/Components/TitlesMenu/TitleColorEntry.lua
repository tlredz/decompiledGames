local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(script.Parent.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v = React.useMemo(function()
		return props.InternalName == props.CurrentTitleColor
	end, { props.CurrentTitleColor })
	local v2 = React.useMemo(function()
		return props.ColorData.ColorName == "Default" and props.ColorData.Color:ToHex() == "ffffff"
	end)
	local v3 = React.useMemo(function()
		if v2 then
			return CONSTANTS.COLOR.PALETTE.GREY_400
		end

		return props.ColorData.Color
	end, { props.ColorData })
	local v6 = {
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
		Position = UDim2.fromScale(8.16589e-8, 0.117021),
		Size = UDim2.fromScale(0.977, 1),
		Text = "",
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true,
		LayoutOrder = props.Index
	}
	local children = {
		ratio = createElement("UIAspectRatioConstraint", {
			AspectRatio = 9.066666666666666
		}),
		uICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.07, 0)
		}),
		uIStroke = 0,
		colorFade = 0,
		equippedTag = 0,
		hint = 0,
		titleName = 0,
		equipButton = 0,
		color = 0,
		equippedLabel = 0,
		lockedImage = 0
	}
	local v9 = {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = 0,
		Thickness = 0
	}
	local color

	if v then
		color = CONSTANTS.COLOR.PRIMARY.MUTED
	else
		color = CONSTANTS.COLOR.PALETTE.BLACK
	end

	v9.Color = color
	v9.Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
	children.uIStroke = createElement("UIStroke", v9)
	local colorFade

	if v then
		colorFade = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(232, 217, 54),
			BackgroundTransparency = 0.85,
			BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.BASE
		}, {
			uIGradient = createElement("UIGradient", {
				Rotation = -90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.466999, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		})
	end

	children.colorFade = colorFade
	local equippedTag

	if v then
		equippedTag = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://139971361540768",
			Position = UDim2.fromScale(1.005, -0.0499997),
			Size = UDim2.fromScale(0.0618747, 0.529873),
			Visible = false,
			ZIndex = 10
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		})
	end

	children.equippedTag = equippedTag
	children.hint = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.11442, 0.734412),
		Size = UDim2.fromScale(0.787, 0.3),
		Text = props.ColorData.Desc,
		TextColor3 = CONSTANTS.COLOR.PALETTE.GREY_400,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	children.titleName = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.11442, 0.324412),
		Size = UDim2.fromScale(0.787, 0.43),
		Text = props.ColorData.ColorName,
		TextColor3 = v3,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local equipButton

	if not (v or not props.ColorData.Unlocked) then
		equipButton = createElement("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			BorderColor3 = CONSTANTS.COLOR.PRIMARY.BORDER,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
			Position = UDim2.fromScale(0.98, 0.5),
			Size = UDim2.fromScale(0.152951, 0.525712),
			Text = "",
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			[React.Event.MouseButton1Click] = function()
				if ReplicatedStorage.Remotes.CommF_:InvokeServer("activateTitleColor", props.InternalName) then
					props.UpdateFromServer()
				end
			end
		}, {
			trans = createElement("Frame", {
				BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromOffset(2, 2),
				Size = UDim2.new(1, -4, 0.4, 0),
				ZIndex = CONSTANTS.LAYER.BASE
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.95, 0.75),
				Text = "Equip",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				}),
				textLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(1, 1),
					Text = "Equip",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					uIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
					})
				})
			})
		})
	end

	children.equipButton = equipButton
	local v16 = {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = v2 and 1 or 0,
		BackgroundColor3 = v3,
		Position = UDim2.fromScale(0.01676, 0.5),
		Size = UDim2.fromScale(0.0815196, 0.714574)
	}
	local v17 = {
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		uIStroke = 0,
		frame = 0
	}
	local uIStroke

	if v2 then
		uIStroke = createElement("UIStroke", {
			Color = CONSTANTS.COLOR.PALETTE.GREY_400,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
		})
	end

	v17.uIStroke = uIStroke
	local frame

	if v2 then
		frame = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = v3,
			BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = 45,
			Size = UDim2.fromScale(0.025, 1.375)
		})
	end

	v17.frame = frame
	children.color = createElement("Frame", v16, v17)
	local equippedLabel

	if v then
		equippedLabel = createElement("Frame", {
			Active = true,
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(158, 158, 158),
			BorderColor3 = CONSTANTS.COLOR.DISABLED.BORDER,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			Position = UDim2.fromScale(0.98, 0.5),
			Selectable = true,
			Size = UDim2.fromScale(0.178831, 0.524555)
		}, {
			trans = createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(191, 191, 191),
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromOffset(2, 2),
				Size = UDim2.new(1, -4, 0.4, 0),
				ZIndex = CONSTANTS.LAYER.BASE
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.53),
				Size = UDim2.fromScale(0.95, 0.75),
				Text = "Equipped",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				}),
				textLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(1, 1),
					Text = "Equipped",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					uIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
					})
				})
			})
		})
	end

	children.equippedLabel = equippedLabel
	children.lockedImage = createElement("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://99266539906486",
		ImageColor3 = CONSTANTS.COLOR.PALETTE.GREY_400,
		Position = UDim2.fromScale(0.98, 0.485017),
		Size = UDim2.fromScale(0.062, 0.554),
		Visible = not props.ColorData.Unlocked
	}, {
		ratio = createElement("UIAspectRatioConstraint")
	})
	return createElement("TextButton", v6, children)
end