local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1) })
local createElement = React.createElement
return function(props)
	local rbxassetfontsfamiliesGothamSSmjson = Font.new(
		"rbxasset://fonts/families/GothamSSm.json",
		Enum.FontWeight.Heavy,
		Enum.FontStyle.Normal
	)
	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, props)
	local v6 = {
		Size = UDim2.fromScale(1, 1.25),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = props.Image,
		ImageRectSize = props.ImageRectSize
	}
	local v7 = {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
		}),
		TextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Position = props.AmountPosition or UDim2.fromScale(1, 0.7),
			Size = props.AmountSize or UDim2.new(1, -4, 0.6, 0),
			Text = props.Amount,
			TextColor3 = props.AmountColor,
			TextScaled = true,
			TextStrokeColor3 = props.AmountStrokeColor,
			TextStrokeTransparency = CONSTANTS.ALPHA.MID
		}),
		TextLabel2 = 0,
		Caret = 0
	}
	local v10 = {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = rbxassetfontsfamiliesGothamSSmjson,
		Position = props.DescriptionPosition or UDim2.fromScale(1.25, 0.5),
		Size = props.DescriptionSize or UDim2.fromScale(10, 0.6),
		Text = props.Description,
		TextColor3 = props.DescriptionColor or CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextStrokeTransparency = CONSTANTS.ALPHA.MID
	}
	local uIGradient

	if not props.IsDescriptionVisible then
		uIGradient = createElement("UIGradient", {
			Transparency = numberSequence
		})
	end

	v7.TextLabel2 = createElement("TextLabel", v10, {
		UIGradient = uIGradient
	})
	local caret

	if props.HasCaret then
		caret = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new("rbxasset://fonts/families/Guru.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.819131, 0.617105),
			RichText = true,
			Size = UDim2.new(1.8271, -4, 0.907417, 0),
			Text = "^",
			TextColor3 = props.AmountColor,
			TextScaled = true,
			TextStrokeTransparency = CONSTANTS.ALPHA.MID
		})
	end

	v7.Caret = caret
	return createElement("Frame", mergeFrame, {
		Image = createElement("ImageButton", v6, v7)
	})
end