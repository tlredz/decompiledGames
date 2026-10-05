local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local ExitButton = require(script.ExitButton)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local selectable

	if useDrawContext() == "Default" then
		selectable = props.Selectable ~= false
	else
		selectable = false
	end

	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
	}, props)
	local v4 = {
		Outline = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		Corner = createElement("UICorner", {
			CornerRadius = UDim.new(0, 1)
		}),
		Gradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
				ColorSequenceKeypoint.new(0.5, CONSTANTS.COLOR.HEADER.HIGHLIGHT),
				ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
			})
		}),
		Title = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY_LIGHT,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.745),
			Text = props.Title,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true
		}, {
			Stroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			})
		}),
		ExitButton = 0
	}
	local exitButton

	if props.OnExit ~= nil then
		exitButton = createElement(ExitButton, {
			[React.Tag] = props.ExitButtonTag,
			IsDisabled = props.IsExitDisabled,
			OnExit = props.OnExit,
			Position = UDim2.fromScale(0.9915, 0.5),
			Selectable = selectable,
			Size = UDim2.fromScale(0.0493, 0.745),
			ZIndex = CONSTANTS.LAYER.RAISED
		})
	end

	v4.ExitButton = exitButton
	return createElement("Frame", mergeFrame, v4)
end