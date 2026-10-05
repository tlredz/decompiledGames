local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(script.Parent.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v = React.useMemo(function()
		return (props.TitleData.EventName or props.TitleData.Name) == props.CurrentTitle
	end, { props.CurrentTitle })
	local v4 = {
		AutoButtonColor = false,
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
		Position = UDim2.fromScale(8.16589e-8, 0.117021),
		Size = UDim2.fromScale(0.977, 1),
		Text = "",
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true,
		LayoutOrder = props.TitleData.Index * 2 - 1,
		[React.Event.MouseButton1Click] = function()
			if v and ReplicatedStorage.Remotes.CommF_:InvokeServer("activateTitle", "") then
				props.UpdateFromServer()
			end
		end
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
		artwork = 0,
		hint = 0,
		titleName = 0,
		equipButton = 0,
		equippedLabel = 0,
		lockedImage = 0
	}
	local v7 = {
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

	v7.Color = color
	v7.Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
	children.uIStroke = createElement("UIStroke", v7)
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
	children.artwork = createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = props.SpecialData.Image,
		ImageRectSize = props.SpecialData.ImageRectSize,
		ImageRectOffset = props.SpecialData.ImageRectOffset,
		ImageColor3 = props.TitleData.Unlocked and CONSTANTS.COLOR.PALETTE.WHITE or CONSTANTS.COLOR.PALETTE.BLACK,
		Position = UDim2.fromScale(0.00500014, 0.5),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(0.12109, 1.07929)
	})
	children.hint = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.135, 0.734412),
		Size = UDim2.fromScale(0.787, 0.3),
		Text = props.TitleData.Description,
		TextColor3 = CONSTANTS.COLOR.PALETTE.GREY_400,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	children.titleName = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.135, 0.324412),
		Size = UDim2.fromScale(0.787, 0.43),
		Text = string.format("#%.3d - %s", props.TitleData.Index, props.TitleData.Name),
		TextColor3 = props.TitleData.Unlocked and props.TitleData.BaseColor or CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local equipButton

	if not (v or not props.TitleData.Unlocked) then
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
				if ReplicatedStorage.Remotes.CommF_:InvokeServer("activateTitle", props.TitleData.InternalName) then
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
		Visible = not props.TitleData.Unlocked
	}, {
		ratio = createElement("UIAspectRatioConstraint")
	})
	return createElement("TextButton", v4, children)
end