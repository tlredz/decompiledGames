local React = require(game.ReplicatedStorage.Packages.React)
local Util = require(script.Parent.Util)
local OutlinedText = require(script.Parent.OutlinedText)
local rbxassetfontsfamiliesHighwayGothicjson = Font.new(
	"rbxasset://fonts/families/HighwayGothic.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)

local function RewardItem(props)
	local text

	if props.Text == nil then
		text = props.Amount
	else
		text = props.Text
	end

	return React.createElement("Frame", Util.mergeProps({
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(props.WidthScale or 1, 1)
	}, props.RootProps), {
		uIStroke = React.createElement("UIStroke", Util.mergeProps({
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Enabled = false,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.04
		}, props.StrokeProps)),
		uICorner = React.createElement("UICorner", Util.mergeProps({
			BottomLeftRadius = UDim.new(0.1, 0),
			BottomRightRadius = UDim.new(0.1, 0),
			CornerRadius = UDim.new(0.1, 0),
			TopLeftRadius = UDim.new(0.1, 0),
			TopRightRadius = UDim.new(0.1, 0)
		}, props.CornerProps)),
		colorFade = React.createElement("Frame", Util.mergeProps({
			BackgroundColor3 = props.AccentColor or Color3.fromRGB(255, 230, 53),
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(0.470178, 0.979451),
			Visible = Util.valueOrDefault(props.ShowColorFade, false)
		}, props.FadeProps), {
			uIGradient = React.createElement("UIGradient", Util.mergeProps({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.63125),
					NumberSequenceKeypoint.new(0.788294, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			}, props.FadeGradientProps)),
			uICorner = React.createElement("UICorner", Util.mergeProps({
				BottomLeftRadius = UDim.new(0.1, 0),
				BottomRightRadius = UDim.new(0.1, 0),
				CornerRadius = UDim.new(0.1, 0),
				TopLeftRadius = UDim.new(0.1, 0),
				TopRightRadius = UDim.new(0.1, 0)
			}, props.FadeCornerProps))
		}),
		icon = React.createElement("ImageLabel", Util.mergeProps({
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Image = props.Icon or "",
			Position = UDim2.fromScale(0.03, 0.507),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.269917, 1.047)
		}, props.IconProps), {
			uIAspectRatioConstraint = React.createElement(
				"UIAspectRatioConstraint",
				Util.mergeProps({}, props.IconAspectRatioProps)
			)
		}),
		amount = React.createElement(OutlinedText, Util.mergeProps({
			FontFace = rbxassetfontsfamiliesHighwayGothicjson,
			Position = UDim2.fromScale(0.34, 0.5),
			Size = UDim2.fromScale(0.626181, 0.75),
			Text = text,
			TextColor = props.TextColor or Color3.fromRGB(255, 230, 53),
			StrokeProps = {
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.06
			}
		}, props.TextProps))
	})
end

return React.memo(RewardItem)