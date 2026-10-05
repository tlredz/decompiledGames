local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.Packages.ReactRoblox)
local createElement = React.createElement
local Spritesheets = require(ReplicatedStorage.Spritesheets)
local HSV, v, v2 = Color3.toHSV(Color3.fromRGB(51, 218, 203))
return function(p)
	local v3 = HSV
	local v4 = v
	local v5 = v2

	if p.Tier == "Bronze" then
		v3, v4, v5 = Color3.toHSV(Color3.fromRGB(217, 105, 0))
	elseif p.Tier == "Silver" then
		v3, v4, v5 = Color3.toHSV(Color3.fromRGB(210, 227, 231))
	elseif p.Tier == "Gold" then
		v3, v4, v5 = Color3.toHSV(Color3.fromRGB(255, 203, 70))
	elseif p.Tier == "Platinum" then
		v3, v4, v5 = Color3.toHSV(Color3.fromRGB(122, 189, 255))
	elseif p.Tier == "Diamond" then
		v3, v4, v5 = Color3.toHSV(Color3.fromRGB(52, 211, 255))
	end

	local v6 = Spritesheets.MAP[`{p.Tier} Medal1`]
	return createElement("ImageLabel", {
		BackgroundTransparency = 1,
		Image = v6.Image,
		ImageRectOffset = v6.ImageRectOffset,
		ImageRectSize = v6.ImageRectSize,
		Position = UDim2.fromScale(0.057502, 0.18),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(0.2, 0.2)
	}, {
		frame = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.495706, 1.1248),
			Size = UDim2.fromScale(1.68, 0.32)
		}, {
			uIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(v3, v4, v5 * 0.4)),
					ColorSequenceKeypoint.new(0.5, Color3.fromHSV(v3, v4, v5)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(v3, v4, v5 * 0.4))
				}),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.296389, 0.24375),
					NumberSequenceKeypoint.new(0.699875, 0.25),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			tier = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				FontFace = Font.new(
					"rbxasset://fonts/families/HighwayGothic.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				),
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(1, 1),
				Text = p.Tier,
				TextColor3 = Color3.new(),
				TextScaled = true
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = 1.5
				}),
				tier = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					FontFace = Font.new(
						"rbxasset://fonts/families/HighwayGothic.json",
						Enum.FontWeight.Bold,
						Enum.FontStyle.Normal
					),
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(1, 1),
					Text = p.Tier,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true
				}, {
					uIStroke = createElement("UIStroke", {
						Thickness = 1.5
					})
				})
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
				Position = UDim2.fromScale(0.5, 1.5),
				Size = UDim2.fromScale(1, 0.7),
				Text = "Reward Tier",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = 1.5
				})
			})
		}),
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
	})
end