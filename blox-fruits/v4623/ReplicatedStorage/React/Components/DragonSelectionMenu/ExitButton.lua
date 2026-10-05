local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local color = Color3.fromRGB(43, 43, 43)
local color2 = Color3.fromHSV(0, 0, 0.5)
local color3 = Color3.fromHSV(0, 0, 0.7)
local color4 = Color3.fromHSV(0, 0, 0.4)
local createElement = React.createElement
return function(props)
	local isDisabled = props.IsDisabled
	local onClick = props.OnClick
	local backgroundColor3 = props.BackgroundColor3 or color
	local borderColor3 = props.BorderColor3 or CONSTANTS.COLOR.PRIMARY.HIGHLIGHT
	local buttonTransparency = props.ButtonTransparency or 0
	local v = props.IsShadowEnabled == nil or props.IsShadowEnabled
	local state, setState = React.useState(false)
	local state2, setState2 = React.useState(false)
	local v2 = useSpring(state and 1 or 0, state and 1 or 0, 1, 15)
	local v3 = useSpring(state2 and 1 or 0, state2 and 1 or 0, 1, 15)

	if isDisabled then
		if state then
			setState(false)
		end

		if state2 then
			setState2(false)
		end
	end

	if v3 > 0 then
		backgroundColor3 = backgroundColor3:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.2 * v3)
	elseif v2 > 0 then
		backgroundColor3 = backgroundColor3:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 0.5 * v2)
	end

	if v3 > 0 then
		borderColor3 = borderColor3:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.2 * v3)
	elseif v2 > 0 then
		borderColor3 = borderColor3:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 0.5 * v2)
	end

	local color5

	if isDisabled then
		backgroundColor3 = color2
		borderColor3 = color3
		color5 = color4
	else
		color5 = borderColor3
	end

	local mergeImageButton = RobloxTypes.mergeImageButton
	local v7 = {
		AutoButtonColor = false,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ClipsDescendants = false,
		Image = "",
		Selectable = true,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		[React.Event.Activated] = not isDisabled and function()
			onClick()
		end or nil,
		[React.Event.MouseButton1Down] = not isDisabled and function()
			if not state2 then
				setState2(true)
			end
		end or nil,
		[React.Event.MouseButton1Up] = not isDisabled and function()
			if state2 then
				setState2(false)
			end
		end or nil
	}
	local children = {
		Button = createElement("Frame", {
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			ZIndex = CONSTANTS.LAYER.RAISED,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = backgroundColor3,
			BackgroundTransparency = buttonTransparency,
			[React.Event.MouseEnter] = not isDisabled and function()
				if not state then
					setState(true)
				end
			end or nil,
			[React.Event.MouseLeave] = not isDisabled and function()
				if state then
					setState(false)
				end

				if state2 then
					setState2(false)
				end
			end or nil,
			[React.Event.SelectionGained] = not isDisabled and function(instance)
				print((`selected: {instance:GetFullName()}`))

				if not state then
					setState(true)
				end
			end or nil,
			[React.Event.SelectionLost] = not isDisabled and function()
				if state then
					setState(false)
				end
			end or nil
		}, {
			TextContainer = createElement("TextLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(1.5, 1.2),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Text = "X",
				TextTransparency = buttonTransparency,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextColor3 = borderColor3,
				TextScaled = true,
				TextYAlignment = Enum.TextYAlignment.Center,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				ZIndex = CONSTANTS.LAYER.CONTENT
			}, {}),
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
			}),
			UIStroke = createElement("UIStroke", {
				Color = color5,
				Transparency = buttonTransparency,
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			})
		}),
		Shadow = 0
	}
	local shadow

	if v then
		shadow = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 0.5 * v2),
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.new(0.5, 0, 0.5, 4)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
			})
		})
	end

	children.Shadow = shadow
	v7.children = children
	return createElement("ImageButton", mergeImageButton(v7, props))
end