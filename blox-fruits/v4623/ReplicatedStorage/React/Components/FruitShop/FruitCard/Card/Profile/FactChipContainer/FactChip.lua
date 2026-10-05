local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(script.Parent.Parent.Parent.Parent.Parent.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local text = props.Fact.Text
	local icon = props.Fact.Icon
	local selectionAlpha = props.SelectionAlpha
	local v = math.max(0, selectionAlpha - 0.1 * (1 - selectionAlpha))
	local backgroundTransparency = props.BackgroundTransparency or 0.55
	local backgroundColor3 = props.BackgroundColor3 or CONSTANTS.COLOR.PALETTE.BLACK
	local state, setState = React.useState(Vector2.zero)
	local state2, setState2 = React.useState(Vector2.zero)
	local v2 = 4 * (icon and 1 or selectionAlpha)
	local mergeGuiObject = RobloxTypes.mergeGuiObject
	local v5 = {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = backgroundColor3,
		BackgroundTransparency = 0,
		SizeConstraint = 0,
		Size = 0,
		Visible = 0
	}

	if not icon then
		backgroundTransparency = 1 - (1 - backgroundTransparency) * selectionAlpha
	end

	v5.BackgroundTransparency = backgroundTransparency
	v5.SizeConstraint = Enum.SizeConstraint.RelativeXX
	v5.Size = UDim2.fromScale(0, 0.075)
	v5.Visible = text ~= nil or icon ~= nil
	local v6 = mergeGuiObject(v5, props)
	local icon2

	if icon then
		icon2 = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			LayoutOrder = 1,
			Image = icon,
			ImageTransparency = CONSTANTS.ALPHA.OPAQUE,
			Size = UDim2.fromScale(1, not text and 0.8 or 0.6 + (1 - selectionAlpha) * 0.2)
		}, {
			UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		})
	end

	local textContainer

	if selectionAlpha > 0 and text then
		textContainer = createElement("Frame", {
			LayoutOrder = 2,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ClipsDescendants = true,
			Size = UDim2.new(0, (state.X + v2) * v, 0.75, 0),
			[React.Change.AbsoluteSize] = selectionAlpha > 0 and function(p)
				setState2(p.AbsoluteSize)
			end or nil
		}, {
			TextLabel = createElement("TextLabel", {
				Position = UDim2.fromScale(0, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = 0,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				FontFace = CONSTANTS.FONT.FACE.BODY,
				Size = UDim2.fromScale(0, 1),
				Text = text,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = false,
				TextSize = state2.Y,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = false,
				TextTransparency = 1 - selectionAlpha,
				[React.Change.AbsoluteSize] = selectionAlpha > 0 and function(p)
					setState(p.AbsoluteSize)
				end or nil
			})
		})
	end

	return createElement("Frame", v6, {
		Icon = icon2,
		TextContainer = textContainer,
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.15, 0)
		}),
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(not text and 0 or 0.1 * selectionAlpha, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		UIPadding = createElement("UIPadding", {
			PaddingLeft = UDim.new(not text and 0 or 0.1 * selectionAlpha, v2),
			PaddingRight = UDim.new(0, v2)
		})
	})
end