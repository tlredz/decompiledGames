local React = require(game.ReplicatedStorage.Packages.React)
local rbxassetfontsfamiliesHighwayGothicjson = Font.new(
	"rbxasset://fonts/families/HighwayGothic.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)
local element = React.createElement("UIStroke", {
	StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
	Thickness = 0.05
})

local function ShadowedText(props)
	return React.createElement("TextLabel", {
		ref = props.labelRef,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesHighwayGothicjson,
		Position = props.position or UDim2.fromScale(0.5, 0.55),
		Size = props.size or UDim2.fromScale(0.8, 0.8),
		Text = props.text,
		TextColor3 = Color3.new(),
		TextScaled = props.textSize == nil,
		TextSize = props.textSize,
		ZIndex = 3
	}, {
		uIStroke = element,
		textShadow = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesHighwayGothicjson,
			Position = UDim2.fromScale(0.5, 0.45),
			Size = UDim2.fromScale(1, 1),
			Text = props.text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = props.textSize == nil,
			TextSize = props.textSize,
			ZIndex = 3
		}, {
			uIStroke = element
		})
	})
end

return ShadowedText