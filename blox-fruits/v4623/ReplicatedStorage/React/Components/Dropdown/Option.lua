local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local state, setState = React.useState(Enum.GuiState.Idle)
	local isDisabled = props.IsDisabled == true
	local v

	if isDisabled then
		v = 0
	elseif state == Enum.GuiState.Hover then
		v = 0.1
	elseif state == Enum.GuiState.Press then
		v = 0.05
	else
		v = 0
	end

	local v2

	if isDisabled then
		v2 = 0
	elseif state == Enum.GuiState.Hover then
		v2 = 0.1267
	elseif state == Enum.GuiState.Press then
		v2 = 0.0532
	else
		v2 = 0
	end

	local v3

	if props.IsSelected then
		v3 = CONSTANTS.COLOR.PALETTE.WHITE
	else
		v3 = CONSTANTS.COLOR.PANEL.BACKGROUND
	end

	local lerped = v3:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, v):Lerp(CONSTANTS.COLOR.PALETTE.WHITE, v2)
	local mergeImageButton = RobloxTypes.mergeImageButton
	local v6 = {
		AutoButtonColor = false,
		BackgroundColor3 = lerped,
		BackgroundTransparency = props.IsSelected and 0.95 or CONSTANTS.ALPHA.SUBTLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ImageTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.new(1, 0, 0, props.HeightPx)
	}
	local activated = React.Event.Activated
	local v7

	if not isDisabled then
		v7 = props.OnActivated
	end

	v6[activated] = v7

	v6[React.Change.GuiState] = function(p)
		if p.GuiState ~= state then
			setState(p.GuiState)
		end
	end

	local v8 = mergeImageButton(v6, props)
	local v9 = {
		Corner = createElement("UICorner", {
			CornerRadius = UDim.new(0, 2)
		}),
		Text = 0
	}
	local v12 = {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.DISPLAY,
		LineHeight = 0,
		Position = UDim2.fromScale(0.02, 0.5),
		Size = UDim2.fromScale(0.94, 0.72),
		Text = props.Text,
		TextColor3 = 0,
		TextScaled = true,
		TextTruncate = 0,
		TextXAlignment = 0
	}
	local textColor

	if isDisabled then
		textColor = CONSTANTS.COLOR.DISABLED.TEXT
	else
		textColor = CONSTANTS.COLOR.PALETTE.WHITE
	end

	v12.TextColor3 = textColor
	v12.TextTruncate = Enum.TextTruncate.AtEnd
	v12.TextXAlignment = Enum.TextXAlignment.Left
	v9.Text = createElement("TextLabel", v12)
	return createElement("ImageButton", v8, v9)
end