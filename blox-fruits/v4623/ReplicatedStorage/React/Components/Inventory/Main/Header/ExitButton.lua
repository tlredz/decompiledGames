local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local state, setState = React.useState(Enum.GuiState.Idle)
	local v = p.IsDisabled == true or state == Enum.GuiState.NonInteractable
	local v2

	if v then
		v2 = 0
	elseif state == Enum.GuiState.Hover then
		v2 = 0.1267
	elseif state == Enum.GuiState.Press then
		v2 = 0.0532
	else
		v2 = 0
	end

	local WHITE = CONSTANTS.COLOR.PALETTE.WHITE
	local v3

	if v then
		v3 = Color3.fromHex("#9E9E9E")
	else
		v3 = CONSTANTS.COLOR.DANGER.BACKGROUND
	end

	local lerped = v3:Lerp(WHITE, v2)
	local v4

	if v then
		v4 = Color3.fromHex("#BFBFBF")
	else
		v4 = CONSTANTS.COLOR.DANGER.HIGHLIGHT
	end

	local lerped2 = v4:Lerp(WHITE, v2)
	local v5

	if v then
		v5 = CONSTANTS.COLOR.DISABLED.BORDER
	else
		v5 = CONSTANTS.COLOR.DANGER.BORDER
	end

	local lerped3 = v5:Lerp(WHITE, v2)
	local mergeImageButton = RobloxTypes.mergeImageButton
	local v8 = {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = lerped,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ImageTransparency = CONSTANTS.ALPHA.INVISIBLE
	}
	local activated = React.Event.Activated
	local v9

	if not v then
		v9 = p.OnExit
	end

	v8[activated] = v9

	v8[React.Change.GuiState] = function(p2)
		if p2.GuiState ~= state then
			setState(p2.GuiState)
		end
	end

	local v10 = mergeImageButton(v8, p)
	local v11 = {
		AspectRatio = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1
		}),
		Outline = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = lerped3,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		Highlight = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = lerped2,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.94, 0.47)
		}),
		Icon = 0
	}
	local v14 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Image = "rbxassetid://127503254560275",
		ImageColor3 = 0,
		ImageRectSize = 0,
		Position = 0,
		ScaleType = 0,
		Size = 0,
		ZIndex = 0
	}
	local imageColor

	if v then
		imageColor = CONSTANTS.COLOR.DISABLED.TEXT
	end

	v14.ImageColor3 = imageColor
	v14.ImageRectSize = Vector2.new(100, 100)
	v14.Position = UDim2.fromScale(0.5, 0.5)
	v14.ScaleType = Enum.ScaleType.Fit
	v14.Size = UDim2.fromScale(0.7, 0.7)
	v14.ZIndex = CONSTANTS.LAYER.RAISED
	v11.Icon = createElement("ImageLabel", v14)
	return createElement("ImageButton", v10, v11)
end