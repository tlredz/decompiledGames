local React = require(game.ReplicatedStorage.Packages.React)
require(script.Parent.Types)
local rbxassetfontsfamiliesSourceSansProjson = Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.Regular,
	Enum.FontStyle.Normal
)
local element = React.createElement("UIAspectRatioConstraint", {
	AspectRatio = 10
})
local element2 = React.createElement("UISizeConstraint", {
	MinSize = Vector2.new(300, 300)
})

local function NotifierLabel(props)
	return React.createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		FontFace = rbxassetfontsfamiliesSourceSansProjson,
		LayoutOrder = props.layoutOrder,
		Position = UDim2.new(0.5, 0, 0.95, -125),
		Size = props.size,
		Text = props.text,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		TextSize = 34,
		TextStrokeColor3 = Color3.fromRGB(77, 77, 77),
		TextStrokeTransparency = 0,
		TextWrapped = true,
		Visible = props.visible,
		ZIndex = -19
	}, {
		aspectRatio = element,
		sizeConstraint = element2
	})
end

return NotifierLabel