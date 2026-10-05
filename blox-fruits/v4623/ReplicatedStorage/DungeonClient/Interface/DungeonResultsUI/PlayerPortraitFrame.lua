local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.Packages.ReactRoblox)
local createElement = React.createElement
return function(props)
	local v3 = {
		BackgroundColor3 = Color3.fromRGB(18, 20, 21),
		BackgroundTransparency = 0.26,
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		Position = 0,
		Size = 0
	}
	local position

	if props.isMainPlayer then
		position = UDim2.fromScale(0.201, 0.12)
	else
		position = UDim2.fromScale(0, 0)
	end

	v3.Position = position
	local size

	if props.Size then
		size = props.Size
	else
		size = UDim2.fromScale(0.592133, 0.524249)
	end

	v3.Size = size
	local v6 = {
		uIStroke = createElement("UIStroke", {
			Thickness = 2
		}),
		image = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = `https://www.roblox.com/bust-thumbnail/image?userId={props.portraitUserId}&width=420&height=420&format=png`,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1)
		}),
		statusGradient = createElement("Frame", {
			BackgroundColor3 = props.statusGradientColor,
			BackgroundTransparency = 0.25,
			BorderColor3 = Color3.new(),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 0
		}, {
			uIGradient = createElement("UIGradient", {
				Rotation = -90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.798257, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		}),
		mVPIcon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://105008549141725",
			Position = UDim2.fromScale(0.09, 0.09),
			Rotation = -15,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.458452, 0.285636),
			Visible = props.isMVP
		}),
		uIAspectRatioConstraint = 0
	}
	local _ = props.isMainPlayer
	v6.uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
	return createElement("Frame", v3, v6)
end