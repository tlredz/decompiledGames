local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local StatIcon = require(ReplicatedStorage.React.Components.StatIcon)
require(script.Parent.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v = props.Modifier == nil and 27 or 47
	local text = React.useMemo(function()
		if props.Modifier == nil then
			return nil
		end

		if props.Modifier.Rerolling then
			return (`<s><font color="#FF4F4F">{props.Modifier.Name}</font></s> &gt; Reroll Modifier Stat`)
		end

		if props.Mystery then
			return "New Modifier Stat"
		end

		return props.Modifier.Name
	end, { props.Modifier })
	local text2 = React.useMemo(function()
		if props.Mystery then
			if props.Modifier == nil or not props.Modifier.Rerolling then
				return "Bonus Stat"
			end

			return "???"
		else
			if not props.StatValue then
				return "Unknown"
			end

			local v4 = props.StatValue.Index.StatType ~= "Complex" and "" or " - " .. tostring(props.StatValue.Index.Variant)
			return props.StatValue.DisplayName .. v4
		end
	end, { props.Mystery, props.StatValue, props.Modifier })
	local v4 = React.useMemo(function()
		if props.Modifier ~= nil and props.Modifier.Rerolling then
			return CONSTANTS.COLOR.DANGER.BACKGROUND
		end

		if props.Mystery then
			return Color3.fromRGB(91, 91, 91)
		end

		return nil
	end, { props.Modifier, props.Mystery })
	local v7 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.new(0, 222, 0, v),
		ZIndex = props.Index
	}
	local modifier

	if text ~= nil then
		modifier = createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Size = UDim2.fromScale(0.807, 0.36),
			Text = text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.GREY_400,
			TextScaled = true,
			RichText = true,
			TextStrokeTransparency = CONSTANTS.ALPHA.MID,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = CONSTANTS.LAYER.OVERLAY
		})
	end

	local v12 = {
		BackgroundTransparency = v4 and 0 or 1,
		BackgroundColor3 = v4 or CONSTANTS.COLOR.PALETTE.BLACK,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Size = UDim2.new(1, 0, 0, 27),
		Position = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		LayoutOrder = props.Index
	}
	local v13 = {
		uIGradient = createElement("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.494),
				NumberSequenceKeypoint.new(0.8, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		icon = 0,
		rarity = 0,
		statChange = 0
	}
	local icon

	if props.StatValue == nil or props.Mystery ~= false then
		icon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://104198112362749",
			ImageRectOffset = Vector2.new(67, 131),
			ImageRectSize = Vector2.new(52, 64),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.85, 0.85),
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint"),
			arrow = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://93625939283816",
				ImageColor3 = Color3.fromRGB(49, 255, 56),
				Position = UDim2.fromScale(0.1, 1),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.4, 0.4),
				ZIndex = CONSTANTS.LAYER.OVERLAY
			})
		})
	else
		icon = createElement(StatIcon, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.85, 0.85),
			ZIndex = CONSTANTS.LAYER.OVERLAY,
			Icon = props.StatValue.Icon
		})
	end

	v13.icon = icon
	v13.rarity = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.13, 0.5),
		Size = UDim2.fromScale(0.507, 0.65),
		Text = text2,
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextStrokeTransparency = CONSTANTS.ALPHA.MID,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = CONSTANTS.LAYER.OVERLAY
	})
	local v17 = {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		LayoutOrder = -2,
		Position = UDim2.fromScale(1, 0.499999),
		Size = UDim2.fromScale(0.325, 0.675)
	}
	local textLabel

	if not (props.OldStatValue == nil or props.StatValue == nil or props.Mystery ~= false) then
		textLabel = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://75390376041031",
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.14, 0.7)
		})
	end

	local v18 = {
		textLabel = textLabel,
		right = createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromScale(0.375, 1),
			Text = (not props.StatValue or props.Mystery ~= false) and "???" or props.StatValue.Text or "???",
			TextColor3 = ((props.OldStatValue ~= nil or props.Mystery) and true or false) and CONSTANTS.COLOR.PRIMARY.BACKGROUND or CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true
		}),
		left = 0
	}
	local left

	if not (props.OldStatValue == nil or props.Mystery ~= false) then
		left = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.375, 1),
			Text = props.OldStatValue.Text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true
		})
	end

	v18.left = left
	v13.statChange = createElement("Frame", v17, v18)
	return createElement("Frame", v7, {
		modifier = modifier,
		stat = createElement("Frame", v12, v13)
	})
end