local React = require(game.ReplicatedStorage.Packages.React)
local rbxassetfontsfamiliesRobotoCondensedjson = Font.new(
	"rbxasset://fonts/families/RobotoCondensed.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Italic
)

local function AlertIcon(props)
	local zIndex = props.ZIndex or 20
	local icon = props.Icon
	local visible

	if icon == nil then
		visible = false
	else
		visible = icon ~= ""
	end

	local text = props.Text or "!"
	return React.createElement("Frame", {
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Interactable = false,
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		Size = props.Size or UDim2.fromScale(1, 1),
		ZIndex = zIndex
	}, {
		customIcon = React.createElement("ImageLabel", {
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = icon or "",
			ImageColor3 = props.IconColor or Color3.new(1, 1, 1),
			ImageRectOffset = props.IconRectOffset or Vector2.zero,
			ImageRectSize = props.IconRectSize or Vector2.zero,
			Interactable = false,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.72, 0.72),
			Visible = visible,
			ZIndex = zIndex + 1
		}),
		textLabel = React.createElement("TextLabel", {
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesRobotoCondensedjson,
			Interactable = false,
			Position = UDim2.fromScale(0.52, 0.54),
			Size = UDim2.fromScale(1.1, 1.1),
			Text = text,
			TextColor3 = props.TextBackColor or Color3.fromRGB(115, 48, 6),
			TextScaled = true,
			Visible = not visible,
			ZIndex = zIndex
		}, {
			uIStroke = React.createElement("UIStroke", {
				Color = props.TextBackStrokeColor or Color3.fromRGB(115, 48, 6),
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.02
			}),
			textLabel = React.createElement("TextLabel", {
				Active = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				FontFace = rbxassetfontsfamiliesRobotoCondensedjson,
				Interactable = false,
				Position = UDim2.fromScale(0.46, 0.45),
				Size = UDim2.fromScale(1, 1),
				Text = text,
				TextColor3 = props.TextFrontColor or Color3.fromRGB(247, 239, 25),
				TextScaled = true,
				ZIndex = zIndex + 1
			}, {
				uIStroke = React.createElement("UIStroke", {
					Color = props.TextFrontStrokeColor or Color3.fromRGB(238, 115, 0),
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.02
				})
			})
		})
	})
end

return React.memo(AlertIcon)