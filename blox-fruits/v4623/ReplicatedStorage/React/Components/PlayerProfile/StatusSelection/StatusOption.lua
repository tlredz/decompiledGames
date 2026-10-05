local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v3 = {
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
		Position = UDim2.fromScale(2.92639e-8, 0.271624)
	}
	local size

	if props.Style == "Primary" then
		size = UDim2.fromScale(0.482, 1)
	else
		size = UDim2.fromScale(0.317, 1)
	end

	v3.Size = size
	v3.Text = ""
	v3.TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK
	v3.TextScaled = true
	v3.LayoutOrder = props.Style == "Primary" and 1 or 4

	v3[React.Event.MouseButton1Click] = function()
		props.SetSelectedStatusId(props.SelectedStatusId == props.Id and 0 or props.Id)
	end

	local v5 = {
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		uIStroke = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = props.Equipped and CONSTANTS.COLOR.PRIMARY.MUTED or CONSTANTS.COLOR.PALETTE.BLACK,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
		}),
		ratio = createElement("UIAspectRatioConstraint", {
			AspectRatio = props.Style == "Primary" and 8.021739130434783 or 5.902439024390244
		}),
		statName = 0,
		frame = 0,
		equippedTag = 0
	}
	local v8 = {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.03, 0.5),
		Size = UDim2.fromScale(0.965, 0.6),
		Text = props.StatusText,
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local v9 = {
		uIStroke = createElement("UIStroke"),
		uiGradient = 0
	}
	local uiGradient

	if props.Color then
		uiGradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, props.Color),
				ColorSequenceKeypoint.new(0.759931, Color3.fromRGB(250, 250, 250)),
				ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.PALETTE.WHITE)
			}),
			Rotation = 90
		})
	end

	v9.uiGradient = uiGradient
	v5.statName = createElement("TextLabel", v8, v9)
	local frame

	if props.Equipped or props.Color then
		frame = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = props.Color or Color3.fromRGB(232, 217, 54),
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

	v5.frame = frame
	local equippedTag

	if props.Equipped then
		equippedTag = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://139971361540768",
			Position = UDim2.fromScale(1.0075, -0.05),
			Size = UDim2.fromScale(0.146314, 0.616294),
			ZIndex = 10
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		})
	end

	v5.equippedTag = equippedTag
	return createElement("TextButton", v3, v5)
end