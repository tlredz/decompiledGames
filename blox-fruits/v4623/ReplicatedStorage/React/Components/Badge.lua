local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.React.Components.HUD.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	Red = {
		Inner = Color3.fromRGB(255, 43, 46)
	},
	Blue = {
		Inner = Color3.fromRGB(34, 170, 255)
	},
	Split = {
		InnerGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 170, 255)),
			ColorSequenceKeypoint.new(0.499, Color3.fromRGB(34, 170, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 43, 46)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 43, 46))
		})
	}
}
local createElement = React.createElement
return function(p)
	local mergeGuiObject = RobloxTypes.mergeGuiObject
	local WHITE

	if p.Variant == "Split" then
		WHITE = CONSTANTS.COLOR.PALETTE.WHITE
	elseif p.Variant == "Red" then
		WHITE = v.Red.Inner
	elseif p.Variant == "Blue" then
		WHITE = v.Blue.Inner
	end

	local v5 = mergeGuiObject({
		BackgroundColor3 = WHITE
	}, p)
	local v6 = {
		UICorner = createElement("UICorner", {
			BottomLeftRadius = UDim.new(0.5, 0),
			BottomRightRadius = UDim.new(0.5, 0),
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE,
			TopLeftRadius = UDim.new(0.5, 0),
			TopRightRadius = UDim.new(0.5, 0)
		}),
		TextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new(
				"rbxasset://fonts/families/GothamSSm.json",
				Enum.FontWeight.Heavy,
				Enum.FontStyle.Normal
			),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -4, 0.6, 0),
			Text = p.Text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextStrokeTransparency = CONSTANTS.ALPHA.MID,
			ZIndex = -10
		}),
		UIGradient = 0
	}
	local uIGradient

	if p.Variant == "Split" then
		uIGradient = createElement("UIGradient", {
			Color = v.Split.InnerGradient,
			Rotation = 225
		})
	end

	v6.UIGradient = uIGradient
	return createElement("Frame", v5, v6)
end