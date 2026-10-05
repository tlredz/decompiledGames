local React = require(game.ReplicatedStorage.Packages.React)
local Config = require(game.ReplicatedStorage.React.Components.Gacha.SceneEffect.Config)
require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(106, 73, 245)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(253, 195, 253)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(106, 73, 245))
})
local createElement = React.createElement

-- equivalent calls inferred from this helper; original call sites unknown
local function findIndex(selections, itemId: number)
	for i = 1, #selections do
		if selections[i] == itemId then
			return i
		end
	end

	return 1
end

function arrowButton(p)
	return createElement("TextButton", RobloxTypes.mergeTextButton({
		BackgroundColor3 = CONSTANTS.COLOR.SECONDARY.BACKGROUND,
		BorderColor3 = CONSTANTS.COLOR.SECONDARY.BORDER,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
		Text = "",
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true,
		TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE
	}, p), {
		Icon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://13435332979",
			Position = UDim2.fromScale(0.5, 0.525),
			Rotation = p.IconRotation,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.9, 0.8),
			ZIndex = CONSTANTS.LAYER.RAISED
		}),
		Trans = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = CONSTANTS.COLOR.SECONDARY.HIGHLIGHT,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.45)
		})
	})
end

return function(props)
	local title = props.Selected.Display and (props.Selected.Display.Title or props.Selected.Display.Name) or props.Selected.Index.StorageKey
	local v = {}

	for k, selection in pairs(props.Selections) do
		local formatted = `Page{k}_{selection}`
		local v4 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			BackgroundTransparency = 0,
			BorderColor3 = 0,
			BorderSizePixel = 0,
			Size = 0,
			LayoutOrder = 0
		}
		local backgroundTransparency

		if props.Selected.Index.ItemId == selection then
			backgroundTransparency = CONSTANTS.ALPHA.OPAQUE
		else
			backgroundTransparency = CONSTANTS.ALPHA.HALF
		end

		v4.BackgroundTransparency = backgroundTransparency
		v4.BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK
		v4.BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
		v4.Size = UDim2.fromScale(0.0133929, 0.949579)
		v4.LayoutOrder = k
		v[formatted] = createElement("Frame", v4)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cycleSelection(p: number)
		if props.Select then
			local index = findIndex(props.Selections, props.Selected.Index.ItemId) -- equivalent call inferred; original call site unknown
			local v2 = index + p
			local v3 = #props.Selections < v2 and 1 or v2 <= 0 and #props.Selections or v2
			props.Select(props.Selections[v3])
		end
	end

	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, props)
	local v6 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.DISPLAY,
		Position = UDim2.fromScale(0.5, 0.284504),
		Size = UDim2.fromScale(0.8, 0.407),
		Text = title,
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true
	}
	local v7 = {
		UIStroke = createElement("UIStroke"),
		TextLabel = 0
	}
	local v10 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.DISPLAY,
		Position = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromScale(1, 1),
		Text = title,
		TextColor3 = Color3.fromRGB(254, 254, 254),
		TextScaled = true
	}
	local color

	if Config[props.Selected.Index.ItemId] then
		color = Config[props.Selected.Index.ItemId].TitleColor
	else
		color = colorSequence
	end

	v7.TextLabel = createElement("TextLabel", v10, {
		UIGradient = createElement("UIGradient", {
			Color = color
		}),
		UIStroke = createElement("UIStroke")
	})
	local children = {
		Title = createElement("TextLabel", v6, v7),
		NextButton = 0,
		CarouselIndicator = 0,
		BackButton = 0,
		AssetType = 0,
		UIAspectRatioConstraint = 0
	}
	local arrowButton2 = arrowButton
	children.NextButton = createElement(arrowButton2, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromScale(0.0833333, 0.440945),
		ZIndex = CONSTANTS.LAYER.RAISED,
		IconRotation = 90,
		[React.Event.Activated] = props.Select and function()
			cycleSelection(1) -- equivalent call inferred; original call site unknown
		end or nil
	})
	children.CarouselIndicator = createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.925),
		Size = UDim2.fromScale(1, 0.074629)
	}, {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.012, 0),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Pages = createElement(React.Fragment, {}, v)
	})
	local arrowButton3 = arrowButton
	children.BackButton = createElement(arrowButton3, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromScale(0.0833333, 0.440945),
		ZIndex = CONSTANTS.LAYER.RAISED,
		IconRotation = -90,
		[React.Event.Activated] = props.Select and function()
			cycleSelection(-1) -- equivalent call inferred; original call site unknown
		end or nil
	})
	children.AssetType = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.5, 0.628504),
		Size = UDim2.fromScale(0.636668, 0.279418),
		Text = not props.Selected.Display.Category and "" or `[{props.Selected.Display.Category}]`,
		TextColor3 = Color3.fromRGB(254, 254, 254),
		TextScaled = true
	}, {
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
		})
	})
	children.UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
		AspectRatio = 5
	})
	return createElement("Frame", mergeFrame, children)
end