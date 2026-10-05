local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.Spritesheets)
local useTime = require(game.ReplicatedStorage.React.Hooks.Animation.useTime)
local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local color = Color3.fromHSV(0, 0, 0.5)
local color2 = Color3.fromHSV(0, 0, 0.6)
local color3 = Color3.fromHSV(0, 0, 0.7)
local color4 = Color3.fromHSV(0, 0, 0.4)
local BODY = CONSTANTS.FONT.FACE.BODY
local createElement = React.createElement

function lockColorGradient(props)
	local color32 = props.Color3
	local lockColor3 = props.LockColor3
	local alpha = props.Alpha
	return createElement("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color32),
			ColorSequenceKeypoint.new((1 - alpha) * 0.998 + 0.001, color32),
			ColorSequenceKeypoint.new((1 - alpha) * 0.998 + 0.001 + 0.0005, lockColor3),
			ColorSequenceKeypoint.new(1, lockColor3)
		}),
		Rotation = 0
	})
end

function lockTransparencyGradient(p)
	local isInverted = p.IsInverted
	local alpha = p.Alpha
	return createElement("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, isInverted and 1 or 0),
			NumberSequenceKeypoint.new((1 - alpha) * 0.998 + 0.001, isInverted and 1 or 0),
			NumberSequenceKeypoint.new((1 - alpha) * 0.998 + 0.001 + 0.0005, isInverted and 0 or 1),
			NumberSequenceKeypoint.new(1, isInverted and 0 or 1)
		}),
		Rotation = 0
	})
end

function getLocalAlpha(p: number, point: Vector2?, point2: Vector2?, point3: Vector2?, point4: Vector2?)
	if not (point and point2 and point3 and point4) then
		return p
	end

	assert(point and point2 and point3 and point4)
	local _ = point4.X == 0

	if point2.X == 0 then
		return p
	end

	local v = (point3.X - point.X) / point2.X

	if p < v then
		return 0
	end

	local v2 = point4.X / point2.X

	if v + v2 < p then
		return 1
	end

	return (p - v) / v2
end

return function(props)
	local text = props.Text
	local fontFace = props.FontFace
	local elevatedBackgroundColor3 = props.ElevatedBackgroundColor3
	local backgroundColor3 = props.BackgroundColor3 or elevatedBackgroundColor3
	local onClick = props.OnClick
	local icon = props.Icon
	local isDisabled = props.IsDisabled
	local swipeTransparency = props.SwipeTransparency or 1
	local initialLockDuration = props.InitialLockDuration
	local state, setState = React.useState(false)
	local state2, setState2 = React.useState(false)
	local state3, setState3 = React.useState(nil)
	local state4, setState4 = React.useState(nil)
	local state5, setState5 = React.useState(Vector2.zero)
	local state6, setState6 = React.useState(nil)
	local state7, setState7 = React.useState(nil)
	local state8, setState8 = React.useState(nil)
	local state9, setState9 = React.useState(nil)
	local state10, setState10 = React.useState(nil)
	local state11, setState11 = React.useState(nil)
	local state12, setState12 = React.useState(nil)
	local state13, setState13 = React.useState(nil)
	local state14, setState14 = React.useState(nil)
	local state15, setState15 = React.useState(nil)
	local v = useSpring(state and 1 or 0, state and 1 or 0, 1, 15)
	local v2 = 1 - v
	local v3 = useSpring(state2 and 1 or 0, state2 and 1 or 0, 1, 15)
	local v4 = useTime(initialLockDuration ~= nil)
	local v5 = props.Image ~= nil or props.HoverImage ~= nil
	local alpha = not initialLockDuration and 0 or TweenService:GetValue(
		1 - math.clamp(v4 / initialLockDuration, 0, 1),
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)
	local v7 = alpha > 0 or isDisabled

	if v7 then
		if state then
			setState(false)
		end

		if state2 then
			setState2(false)
		end

		if state3 then
			setState3(nil)
		end
	end

	local lockColor

	if v3 > 0 then
		lockColor = elevatedBackgroundColor3:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.2 * v3)
	elseif v > 0 then
		lockColor = elevatedBackgroundColor3:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 0.2 * v)
	else
		lockColor = elevatedBackgroundColor3
	end

	local lockColor2

	if v3 > 0 and backgroundColor3 then
		lockColor2 = backgroundColor3:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.2 * v3)
	elseif v > 0 and backgroundColor3 then
		lockColor2 = backgroundColor3:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 0.2 * v)
	else
		lockColor2 = backgroundColor3
	end

	local WHITE = CONSTANTS.COLOR.PALETTE.WHITE
	local BLACK = CONSTANTS.COLOR.PALETTE.BLACK
	local lockColor3, lockColor4

	if v7 then
		lockColor = color2
		lockColor2 = color
		lockColor3 = color3
		lockColor4 = color4
	else
		lockColor4 = BLACK
		lockColor3 = WHITE
	end

	local v12 = math.max(2, (math.ceil(state5.Y * 0.03)))
	local v13 = math.max(2, (math.ceil(state5.Y * 0.02)))
	local v14

	if state4 and state5 then
		v14 = math.min(state4 * 2 * 1.5 * (350 / state5.X), 1)
	else
		v14 = nil
	end

	local v15

	if v14 then
		v15 = 1 - math.abs(0.5 - v14) * 2
	end

	React.useEffect(function()
		if state and not state3 then
			if swipeTransparency < 1 then
				setState3((tick()))
			end
		elseif v14 and v14 >= 1 and state3 then
			setState3(nil)
		end

		return function() end
	end, { state, v14, swipeTransparency })
	React.useEffect(function()
		local renderSteppedConnection

		if state3 and swipeTransparency < 1 then
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				setState4(tick() - state3)
			end)
		else
			renderSteppedConnection = nil
		end

		return function()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end
		end
	end, { state3, swipeTransparency })
	local mergeImageButton = RobloxTypes.mergeImageButton
	local v18 = {
		Active = not v7,
		Interactable = not v7,
		AutoButtonColor = false,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ClipsDescendants = false,
		ImageTransparency = v7 and alpha <= 0 and 1 or math.max(v, v3) * 0.2
	}
	local imageColor

	if initialLockDuration then
		imageColor = CONSTANTS.COLOR.PALETTE.WHITE
	else
		imageColor = lockColor3
	end

	v18.ImageColor3 = imageColor
	v18.Selectable = not v7
	local WHITE2

	if initialLockDuration then
		WHITE2 = CONSTANTS.COLOR.PALETTE.WHITE
	elseif v5 then
		if v7 then
			WHITE2 = lockColor2
		else
			WHITE2 = CONSTANTS.COLOR.PALETTE.WHITE:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.2 * v3)
		end
	else
		WHITE2 = lockColor
	end

	v18.BackgroundColor3 = WHITE2

	v18[React.Change.AbsoluteSize] = function(p)
		if alpha > 0 then
			setState6(p.AbsoluteSize)
		end

		setState5(p.AbsoluteSize)
	end

	v18[React.Change.AbsolutePosition] = alpha > 0 and function(p)
		setState7(p.AbsolutePosition)
	end or nil
	v18[React.Event.Activated] = not v7 and function()
		onClick()
	end or nil
	v18[React.Event.MouseButton1Down] = not v7 and function()
		if not state2 then
			setState2(true)
		end
	end or nil
	v18[React.Event.MouseButton1Up] = not v7 and function()
		if state2 then
			setState2(false)
		end
	end or nil
	v18[React.Event.MouseEnter] = not v7 and function()
		if not state then
			setState(true)
		end
	end or nil
	v18[React.Event.MouseLeave] = not v7 and function()
		setState(false)

		if state2 then
			setState2(false)
		end
	end or nil
	v18[React.Event.SelectionGained] = not v7 and function(_)
		if not state then
			setState(true)
		end
	end or nil
	v18[React.Event.SelectionLost] = not v7 and function()
		if state then
			setState(false)
		end
	end or nil
	local backgroundLockGradient

	if initialLockDuration and v5 then
		backgroundLockGradient = createElement(lockTransparencyGradient, {
			Alpha = alpha
		})
	end

	local disabledBackground

	if initialLockDuration and v5 then
		disabledBackground = createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = color,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
		}, {
			BackgroundLockGradient = createElement(lockTransparencyGradient, {
				Alpha = alpha,
				IsInverted = true
			})
		})
	end

	local lockGradient

	if initialLockDuration and not v5 then
		local lockColorGradient2 = lockColorGradient
		local color5

		if alpha > 0 then
			color5 = elevatedBackgroundColor3
		else
			color5 = lockColor
		end

		lockGradient = createElement(lockColorGradient2, {
			Color3 = color5,
			LockColor3 = lockColor,
			Alpha = alpha
		})
	end

	local v25 = {
		ClipsDescendants = true,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.fromScale(1, 1)
	}
	local shineEffect

	if v14 and v15 and not v7 then
		shineEffect = createElement("Frame", {
			AnchorPoint = Vector2.new(1 - v14, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(v14 or 0.5, 0.5),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.fromScale(0.991, 1),
			ZIndex = -998
		}, {
			UIGradient = createElement("UIGradient", {
				Rotation = 20,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.35 - 0.15 * v14, 1),
					NumberSequenceKeypoint.new(0.45 - 0.15 * v14, swipeTransparency),
					NumberSequenceKeypoint.new(0.55 + 0.15 * v14, swipeTransparency),
					NumberSequenceKeypoint.new(0.65 + 0.15 * v14, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		})
	end

	local children = {
		BackgroundLockGradient = backgroundLockGradient,
		DisabledBackground = disabledBackground,
		LockGradient = lockGradient,
		ShineFrame = createElement("Frame", v25, {
			ShineEffect = shineEffect
		}),
		TextContainer = 0,
		BackgroundContainer = 0,
		UIStroke = 0,
		Shadow = 0
	}
	local v30 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local v31 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.015, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			HorizontalFlex = Enum.UIFlexAlignment.None
		}),
		IconContainer = 0,
		LabelContainer = 0
	}
	local iconContainer

	if icon then
		local v35 = {
			LayoutOrder = 0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.fromScale(0.6, 0.6),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			[React.Change.AbsolutePosition] = alpha > 0 and function(p)
				setState9(p.AbsolutePosition)
			end or nil,
			[React.Change.AbsoluteSize] = alpha > 0 and function(p)
				setState8(p.AbsoluteSize)
			end or nil
		}
		local icon2

		if icon then
			local v40 = {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = 0,
				ImageRectOffset = 0,
				ImageRectSize = 0,
				LayoutOrder = 0,
				Position = 0,
				AnchorPoint = 0,
				ImageColor3 = 0,
				ScaleType = 0,
				Size = 0
			}
			local image

			if typeof(icon) == "table" then
				image = icon.Image
			else
				image = icon
			end

			v40.Image = image
			local imageRectOffset

			if typeof(icon) == "table" then
				imageRectOffset = icon.ImageRectOffset
			end

			v40.ImageRectOffset = imageRectOffset
			local imageRectSize

			if typeof(icon) == "table" then
				imageRectSize = icon.ImageRectSize
			end

			v40.ImageRectSize = imageRectSize
			v40.Position = UDim2.fromScale(0.5, 0.5)
			v40.AnchorPoint = Vector2.new(0.5, 0.5)
			v40.ImageColor3 = lockColor3:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.2 * v3)
			v40.ScaleType = Enum.ScaleType.Fit
			v40.Size = UDim2.fromScale(1, 1):Lerp(UDim2.fromScale(1.2, 1.2), v2)
			local lockGradient2

			if not (alpha <= 0) then
				lockGradient2 = createElement(lockTransparencyGradient, {
					Alpha = 1 - getLocalAlpha(alpha, state7, state6, state9, state8)
				})
			end

			local lockIcon

			if not (alpha <= 0) then
				lockIcon = createElement("ImageLabel", {
					Image = icon,
					ImageColor3 = WHITE,
					ScaleType = Enum.ScaleType.Fit,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Size = UDim2.fromScale(1, 1)
				}, {
					LockGradient = createElement(lockTransparencyGradient, {
						Alpha = 1 - getLocalAlpha(1 - alpha, state7, state6, state9, state8)
					})
				})
			end

			icon2 = createElement("ImageLabel", v40, {
				LockGradient = lockGradient2,
				LockIcon = lockIcon
			})
		end

		iconContainer = createElement("Frame", v35, {
			Icon = icon2
		})
	end

	v31.IconContainer = iconContainer
	local v35 = {
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		LayoutOrder = 1,
		Size = UDim2.new(
			UDim.new(0, 0),
			UDim.new(
				not props.YPadding and 0.725 or 1 - props.YPadding.Scale * 2,
				not props.YPadding and 0 or -props.YPadding.Offset * 2
			)
		)
	}
	local v36 = {
		UIAspectRatio = createElement("UIAspectRatioConstraint", {
			AspectRatio = props.Text:len() / 3,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height
		}),
		UIPadding = createElement("UIPadding", {
			PaddingTop = CONSTANTS.SPACING.PADDING.SCALE.XXL
		}),
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.015, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			HorizontalFlex = Enum.UIFlexAlignment.None
		}),
		OverLabel = 0
	}
	local uDim = UDim.new(0, 0)
	local v40

	if props.YPadding then
		v40 = UDim.new(1 - props.YPadding.Scale * 2, -props.YPadding.Offset * 2)
	else
		v40 = UDim.new(0.9, 0)
	end

	local v39 = {
		RichText = true,
		Size = UDim2.new(uDim, v40):Lerp(UDim2.fromScale(0, 1), v2),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		AutomaticSize = Enum.AutomaticSize.X,
		FontFace = fontFace or BODY,
		Text = text
	}
	local textColor

	if initialLockDuration then
		textColor = CONSTANTS.COLOR.PALETTE.WHITE
	else
		textColor = lockColor4:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 0.2 * v)
	end

	v39.TextColor3 = textColor
	v39.TextScaled = true
	v39.TextSize = 14
	v39.TextWrapped = true
	v39.ZIndex = CONSTANTS.LAYER.RAISED
	v39[React.Change.AbsolutePosition] = alpha > 0 and function(p)
		setState11(p.AbsolutePosition)
	end or nil
	v39[React.Change.AbsoluteSize] = alpha > 0 and function(p)
		setState10(p.AbsoluteSize)
	end or nil
	local v42 = {
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
		}),
		LockGradient = 0,
		UnderLabel = 0
	}
	local lockGradient3

	if initialLockDuration then
		local lockColorGradient2 = lockColorGradient

		if not (alpha > 0) then
			BLACK = lockColor4:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 0.2 * v)
		end

		lockGradient3 = createElement(lockColorGradient2, {
			Color3 = BLACK,
			LockColor3 = lockColor4,
			Alpha = 1 - getLocalAlpha(1 - alpha, state7, state6, state11, state10)
		})
	end

	v42.LockGradient = lockGradient3
	local v46 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = fontFace or BODY,
		Position = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromScale(1, 1),
		RichText = true,
		Text = text,
		TextColor3 = 0,
		TextScaled = true,
		TextSize = 14,
		TextWrapped = true,
		ZIndex = 0
	}
	local textColor2

	if initialLockDuration then
		textColor2 = CONSTANTS.COLOR.PALETTE.WHITE
	else
		textColor2 = lockColor3:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.2 * v3)
	end

	v46.TextColor3 = textColor2
	v46.ZIndex = CONSTANTS.LAYER.RAISED
	local v48 = {
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
		}),
		LockGradient = 0
	}
	local lockGradient4

	if initialLockDuration then
		local lockColorGradient2 = lockColorGradient

		if not (alpha > 0) then
			WHITE = lockColor3:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.2 * v3)
		end

		lockGradient4 = createElement(lockColorGradient2, {
			Color3 = WHITE,
			LockColor3 = lockColor3,
			Alpha = 1 - getLocalAlpha(1 - alpha, state7, state6, state11, state10)
		})
	end

	v48.LockGradient = lockGradient4
	v42.UnderLabel = createElement("TextLabel", v46, v48)
	v36.OverLabel = createElement("TextLabel", v39, v42)
	v31.LabelContainer = createElement("Frame", v35, v36)
	children.TextContainer = createElement("Frame", v30, v31)
	local backgroundContainer

	if not v5 then
		local v53 = {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = CONSTANTS.LAYER.CONTENT
		}
		local v54 = {
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, v12),
				PaddingLeft = UDim.new(0, v12),
				PaddingRight = UDim.new(0, v12),
				PaddingTop = UDim.new(0, v12)
			}),
			Background = 0
		}
		local v57 = {
			AnchorPoint = Vector2.new(0.5, 0.5)
		}
		local backgroundColor

		if initialLockDuration then
			backgroundColor = CONSTANTS.COLOR.PALETTE.WHITE
		else
			backgroundColor = lockColor2
		end

		v57.BackgroundColor3 = backgroundColor
		v57.BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
		v57.Position = UDim2.fromScale(0.5, 0.5)
		v57.Size = UDim2.fromScale(1, 1)
		v57[React.Change.AbsolutePosition] = alpha > 0 and function(p)
			setState13(p.AbsolutePosition)
		end or nil
		v57[React.Change.AbsoluteSize] = alpha > 0 and function(p)
			setState12(p.AbsoluteSize)
		end or nil
		local lockGradient2

		if initialLockDuration then
			local lockColorGradient2 = lockColorGradient

			if not (alpha > 0) then
				backgroundColor3 = lockColor2
			end

			lockGradient2 = createElement(lockColorGradient2, {
				Color3 = backgroundColor3,
				LockColor3 = lockColor2,
				Alpha = 1 - getLocalAlpha(1 - alpha, state7, state6, state13, state12)
			})
		end

		local v59 = {
			LockGradient = lockGradient2,
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, v13),
				PaddingLeft = UDim.new(0, v13),
				PaddingRight = UDim.new(0, v13),
				PaddingTop = UDim.new(0, v13)
			}),
			Highlight = 0
		}
		local v63 = {
			AnchorPoint = Vector2.new(0.5, 0)
		}
		local backgroundColor2

		if initialLockDuration then
			backgroundColor2 = CONSTANTS.COLOR.PALETTE.WHITE
		else
			backgroundColor2 = lockColor
		end

		v63.BackgroundColor3 = backgroundColor2
		v63.BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
		v63.Position = UDim2.fromScale(0.5, 0)
		v63.Size = UDim2.fromScale(1, 0.4)
		v63[React.Change.AbsolutePosition] = alpha > 0 and function(p)
			setState15(p.AbsolutePosition)
		end or nil
		v63[React.Change.AbsoluteSize] = alpha > 0 and function(p)
			setState14(p.AbsoluteSize)
		end or nil
		local lockGradient5

		if initialLockDuration then
			local lockColorGradient2 = lockColorGradient

			if not (alpha > 0) then
				elevatedBackgroundColor3 = lockColor
			end

			lockGradient5 = createElement(lockColorGradient2, {
				Color3 = elevatedBackgroundColor3,
				LockColor3 = lockColor,
				Alpha = 1 - getLocalAlpha(1 - alpha, state7, state6, state15, state14)
			})
		end

		v59.Highlight = createElement("Frame", v63, {
			LockGradient = lockGradient5
		})
		v54.Background = createElement("Frame", v57, v59)
		backgroundContainer = createElement("Frame", v53, v54)
	end

	children.BackgroundContainer = backgroundContainer
	children.UIStroke = createElement("UIStroke", {
		Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
	})
	children.Shadow = createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 0.2 * v),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.fromScale(1, 0.1)
	})
	v18.children = children
	return createElement("ImageButton", mergeImageButton(v18, props))
end