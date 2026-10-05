local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local createElement = React.createElement

local function headerTextLabel(_)
	return createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		Position = UDim2.fromScale(0.5, 0.55),
		Size = UDim2.fromScale(0.8, 0.75),
		Text = "Dungeon Results",
		TextColor3 = Color3.new(),
		TextScaled = true
	}, {
		uIStroke = createElement("UIStroke", {
			Thickness = 2
		}),
		textLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.new(
				"rbxasset://fonts/families/HighwayGothic.json",
				Enum.FontWeight.Bold,
				Enum.FontStyle.Normal
			),
			Position = UDim2.fromScale(0.5, 0.45),
			Size = UDim2.fromScale(1, 1),
			Text = "Dungeon Results",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true
		}, {
			uIStroke = createElement("UIStroke", {
				Thickness = 2
			})
		})
	})
end

local function closeButton(p)
	return createElement("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 79, 79),
		BorderColor3 = Color3.fromRGB(131, 40, 40),
		BorderSizePixel = 2,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
		LayoutOrder = -999,
		Position = UDim2.fromScale(0.985, 0.5),
		Size = UDim2.fromScale(0.0628963, 0.768694),
		Text = "",
		TextColor3 = Color3.new(),
		TextScaled = true,
		TextStrokeColor3 = Color3.new(1, 1, 1),
		ZIndex = 2,
		[ReactRoblox.Event.Activated] = function()
			p.onClose()
		end
	}, {
		trans = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(255, 112, 112),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.94, 0.47)
		}),
		icon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://127503254560275",
			ImageRectSize = Vector2.new(100, 100),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2
		}),
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
	})
end

local function TitleBar(p)
	return createElement("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Position = UDim2.fromScale(0, 3.19143e-8),
		Size = UDim2.fromScale(0.998668, 0.100986)
	}, {
		uICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.1, 0)
		}),
		uIStroke = createElement("UIStroke", {
			Thickness = 2
		}),
		uIGradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 199, 29)),
				ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 239, 60)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 199, 29))
			})
		}),
		Close = createElement(closeButton, {
			onClose = p.onClose
		}),
		TextLabel = createElement(headerTextLabel, {})
	})
end

return TitleBar