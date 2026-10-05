local React = require(game.ReplicatedStorage.Packages.React)
local rbxassetfontsfamiliesHighwayGothicjson = Font.new("rbxasset://fonts/families/HighwayGothic.json")
local rbxassetfontsfamiliesHighwayGothicjson2 = Font.new(
	"rbxasset://fonts/families/HighwayGothic.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)
local v = utf8.char(57346) .. "349"
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 239, 60)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 199, 29))
})
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.267746, 0),
	NumberSequenceKeypoint.new(0.743462, 0),
	NumberSequenceKeypoint.new(1, 1)
})
local numberSequence2 = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.100872, 0.24375),
	NumberSequenceKeypoint.new(0.701121, 0.25),
	NumberSequenceKeypoint.new(1, 1)
})
local numberSequence3 = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.330012, 1),
	NumberSequenceKeypoint.new(0.403487, 0),
	NumberSequenceKeypoint.new(0.500623, 0),
	NumberSequenceKeypoint.new(0.569116, 1),
	NumberSequenceKeypoint.new(1, 1)
})

local function stroke(value: number?)
	return React.createElement("UIStroke", {
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		Thickness = value or 0.06
	})
end

local function StrokedText(props)
	local strokeThickness = props.strokeThickness
	local v2 = {
		uIStroke = React.createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = strokeThickness or 0.06
		}),
		uIGradient = 0
	}
	local uIGradient

	if props.gradient then
		uIGradient = React.createElement("UIGradient", {
			Color = props.gradient
		})
	end

	v2.uIGradient = uIGradient

	if props.children then
		for k, v4 in props.children do
			v2[k] = v4
		end
	end

	return React.createElement("TextLabel", {
		AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
		AutoLocalize = false,
		BackgroundTransparency = 1,
		FontFace = props.fontFace or rbxassetfontsfamiliesHighwayGothicjson,
		Position = props.position,
		Size = props.size,
		Text = props.text,
		TextColor3 = props.color or Color3.new(1, 1, 1),
		TextScaled = true,
		TextXAlignment = props.textXAlignment or Enum.TextXAlignment.Center,
		ZIndex = props.zIndex
	}, v2)
end

local function TitleText(p)
	return React.createElement(StrokedText, {
		text = p.text,
		fontFace = rbxassetfontsfamiliesHighwayGothicjson2,
		color = Color3.new(),
		position = UDim2.fromScale(0.676, 0.275),
		size = UDim2.fromScale(0.587, 0.35),
		textXAlignment = Enum.TextXAlignment.Left,
		zIndex = p.zIndex
	}, {
		textLabel = React.createElement(StrokedText, {
			text = p.text,
			fontFace = rbxassetfontsfamiliesHighwayGothicjson2,
			color = Color3.new(1, 1, 1),
			position = UDim2.fromScale(0.5, 0.45),
			size = UDim2.fromScale(1, 1),
			textXAlignment = Enum.TextXAlignment.Left,
			gradient = colorSequence,
			zIndex = p.zIndex
		})
	})
end

local function PriceBadge(p)
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Color3.new(),
		Position = UDim2.fromScale(0.54, 0.95),
		Size = UDim2.fromScale(0.92, 0.250741),
		ZIndex = p.zIndex
	}, {
		uICorner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0.1, 0)
		}),
		textLabel = React.createElement(StrokedText, {
			text = p.text,
			fontFace = rbxassetfontsfamiliesHighwayGothicjson2,
			position = UDim2.fromScale(0.45, 0.5),
			size = UDim2.fromScale(0.8, 0.9),
			zIndex = p.zIndex
		}),
		uIGradient = React.createElement("UIGradient", {
			Transparency = numberSequence
		})
	})
end

local function ProductImage(props)
	return React.createElement("ImageLabel", {
		BackgroundTransparency = 1,
		Image = props.image,
		Position = UDim2.fromScale(0.0389899, -0.0648819),
		Size = UDim2.fromScale(0.312281, 1.12658),
		ZIndex = props.zIndex
	}, {
		priceBadge = React.createElement(PriceBadge, {
			text = props.priceText,
			zIndex = (props.zIndex or 1) + 1
		}),
		uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint")
	})
end

local function Shine(p)
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Visible = p.visible == true,
		ZIndex = p.zIndex
	}, {
		uIGradient = React.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
			}),
			Offset = Vector2.new(0, -1.2),
			Rotation = 45,
			Transparency = numberSequence3
		})
	})
end

local function FastBoatsGamepassPopup(props)
	local productName = props.productName or "Fast Boats"
	local zIndex = props.zIndex
	local zIndex2 = (zIndex or 1) + 6
	local createElement = React.createElement
	local v4 = {
		AutoLocalize = false,
		BackgroundColor3 = Color3.fromRGB(26, 6, 6),
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		Position = props.position or UDim2.fromScale(0.124138, -0.485516),
		Size = props.size or UDim2.fromScale(0.982759, 0.434161),
		Visible = props.visible ~= false,
		ZIndex = zIndex
	}
	local v5 = {
		productImage = React.createElement(ProductImage, {
			image = props.productImage or "rbxassetid://131964327842020",
			priceText = props.priceText or v,
			zIndex = zIndex
		}),
		uIGradient = React.createElement("UIGradient", {
			Transparency = numberSequence2
		}),
		name = React.createElement(TitleText, {
			text = productName,
			zIndex = zIndex
		}),
		desc = React.createElement(StrokedText, {
			text = props.description or "Access luxurious fast  boats permanently!",
			fontFace = rbxassetfontsfamiliesHighwayGothicjson,
			position = UDim2.fromScale(0.676, 0.435),
			size = UDim2.fromScale(0.587028, 0.487543),
			anchorPoint = Vector2.new(0.5, 0),
			textXAlignment = Enum.TextXAlignment.Left,
			zIndex = zIndex
		}),
		shine = React.createElement(Shine, {
			visible = props.shineVisible,
			zIndex = (zIndex or 1) + 4
		}),
		uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 3.60759
		}),
		button = 0
	}
	local button

	if props.onActivated then
		button = React.createElement("TextButton", {
			Active = true,
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Modal = props.modal ~= false,
			Selectable = true,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			ZIndex = zIndex2,
			[React.Event.Activated] = props.onActivated
		})
	end

	v5.button = button
	return createElement("Frame", v4, v5)
end

return FastBoatsGamepassPopup