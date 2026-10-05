local React = require(game.ReplicatedStorage.Packages.React)
local StatIcon = require(game.ReplicatedStorage.React.Components.StatIcon)
require(game.ReplicatedStorage.React.Hooks.Item.useStats)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local createElement = React.createElement
return function(p)
	local ref = React.useRef(nil)
	local mergeFrame = RobloxTypes.mergeFrame({
		ref = ref,
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.25,
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		Active = false,
		Size = UDim2.fromScale(1, 0.1),
		SizeConstraint = Enum.SizeConstraint.RelativeXX
	}, p)
	local v3 = {
		UIGradient = createElement("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.298879, 0.24375),
				NumberSequenceKeypoint.new(0.500623, 0.075),
				NumberSequenceKeypoint.new(0.699875, 0.2375),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		Number = createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
			Position = UDim2.fromScale(0.95, 0.52),
			Size = UDim2.fromScale(0, 0.625),
			Text = p.StatValue.Text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextStrokeTransparency = 0.6,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = 5
		}),
		StatName = 0,
		StatHint = nil,
		Icon = 0
	}
	local v6 = {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
		Position = UDim2.fromScale(0.16, 0.52),
		Size = UDim2.fromScale(0.64, 0.625),
		Text = 0,
		TextColor3 = 0,
		TextScaled = true,
		TextWrapped = false,
		TextStrokeTransparency = 0.6,
		TextXAlignment = 0,
		TextYAlignment = 0,
		ZIndex = 5
	}
	local text

	if p.StatValue.Index.StatType == "Complex" then
		text = tostring(p.StatValue.Index.Variant) .. " - " .. p.StatValue.DisplayName
	else
		text = p.StatValue.DisplayName
	end

	v6.Text = text
	v6.TextColor3 = Color3.new(1, 1, 1)
	v6.TextXAlignment = Enum.TextXAlignment.Left
	v6.TextYAlignment = Enum.TextYAlignment.Center
	v3.StatName = createElement("TextLabel", v6)
	v3.Icon = createElement(StatIcon, {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Icon = p.StatValue.Icon,
		Position = UDim2.fromScale(0.055, 0.47),
		Size = UDim2.fromScale(0.83, 0.83),
		ZIndex = 5
	})
	return createElement("Frame", mergeFrame, v3)
end