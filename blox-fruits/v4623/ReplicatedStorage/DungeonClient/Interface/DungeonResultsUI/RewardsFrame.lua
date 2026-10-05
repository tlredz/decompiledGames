local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.Packages.ReactRoblox)
local createElement = React.createElement

local function RewardsScroller(p)
	return createElement("ScrollingFrame", {
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 6,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Size = UDim2.fromScale(1, 1)
	}, { createElement("UIGridLayout", {
			CellPadding = UDim2.fromScale(0.03, 0.12),
			CellSize = UDim2.fromScale(0.7, 0.7),
			SortOrder = Enum.SortOrder.LayoutOrder
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		}), createElement("UIPadding", {
			PaddingTop = UDim.new(0.02, 0)
		}), p.children })
end

local function RewardsPaddedFrame(p)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.196),
		Size = UDim2.fromScale(1, 0.762)
	}, {
		uIPadding = createElement("UIPadding", {
			PaddingLeft = UDim.new(0.015, 0),
			PaddingRight = UDim.new(0.01, 0)
		}),
		scroller = createElement(RewardsScroller, p)
	})
end

local function RewardsHeader(p)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.071),
		Size = UDim2.fromScale(0.4, 0.143)
	}, {
		uIGradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 201, 31)),
				ColorSequenceKeypoint.new(0.492228, Color3.fromRGB(255, 238, 59)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 30))
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
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Text = p.Text or "Rewards",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true
		}, {
			uIStroke = createElement("UIStroke", {
				Thickness = 1.5
			})
		})
	})
end

return function(p)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = p.BackgroundColor3 or Color3.fromRGB(20, 20, 20),
		BackgroundTransparency = 0.02,
		Position = UDim2.fromScale(0.498459, 0.965142),
		Size = UDim2.fromScale(0.946198, 0.418377)
	}, {
		uICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.02, 0)
		}),
		uIStroke = createElement("UIStroke", {
			Thickness = 2
		}),
		rewardsHeader = createElement(RewardsHeader, p),
		rewardsPaddedFrame = createElement(RewardsPaddedFrame, p)
	})
end