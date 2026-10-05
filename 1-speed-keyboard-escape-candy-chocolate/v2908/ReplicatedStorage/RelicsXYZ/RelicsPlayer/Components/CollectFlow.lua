local parent = script.Parent.Parent
local components = parent.Components
local shared = parent.Parent.Shared
local React = require(shared.React)
require(parent.State)
require(shared.GamePasses)
require(shared.MusicData)
local TitleButton = require(components.TitleButton)
local GamePassItem = require(components.GamePassItem)

local function CollectFlow(data)
	local children = {}

	for i, node in ipairs(data.Nodes) do
		local formatted = `Node{i}`

		if node.Type == "GamePass" then
			local gamePass = node.GamePass
			children[formatted] = React.createElement(GamePassItem, {
				[React.Tag] = data[React.Tag],
				GamePass = gamePass,
				NoStencil = node.NoStencil,
				ColorCoded = node.ColorCoded,
				OverrideBackgroundImage = node.OverrideBackgroundImage,
				ColorCodedPadding = node.ColorCodedPadding,
				Size = UDim2.fromScale(1, 1),
				Compact = node.Compact,
				LayoutOrder = i
			})
		elseif node.Type == "FlowItem" then
			local createElement = React.createElement
			local v2 = {
				[React.Tag] = data[React.Tag],
				Title = node.Title,
				Image = node.Image,
				ForegroundImage = node.ForegroundImage,
				ForegroundImageScale = node.ForegroundImageScale,
				Widget = node.Widget,
				StrokeColor = node.StrokeColor,
				BackgroundColor = node.BackgroundColor,
				NoTextStroke = node.NoTextStroke,
				Playlist = node.Playlist
			}
			local sizeConstraint

			if data.FillDirection == Enum.FillDirection.Vertical then
				sizeConstraint = Enum.SizeConstraint.RelativeXX
			else
				sizeConstraint = Enum.SizeConstraint.RelativeYY
			end

			v2.SizeConstraint = sizeConstraint
			v2.LayoutOrder = i
			children[formatted] = createElement(TitleButton, v2, {
				Render = node.Render and React.createElement(node.Render, {
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.fromScale(0, 0),
					AnchorPoint = Vector2.zero
				})
			})
		end
	end

	local padding

	if data.Padding ~= false then
		padding = typeof(data.Padding) == "UDim" and data.Padding or UDim.new(0.1, 0)
	end

	local size = data.Size or UDim2.fromScale(1, 1)
	local createElement = React.createElement
	local v2 = {
		[React.Tag] = "CollectFlowScrollContainer",
		Size = size,
		Position = data.Position,
		AnchorPoint = data.AnchorPoint,
		LayoutOrder = data.LayoutOrder,
		BackgroundTransparency = 1
	}
	local automaticCanvasSize

	if data.FillDirection == Enum.FillDirection.Vertical then
		automaticCanvasSize = Enum.AutomaticSize.Y
	else
		automaticCanvasSize = Enum.AutomaticSize.X
	end

	v2.AutomaticCanvasSize = automaticCanvasSize
	local scrollingDirection

	if data.FillDirection == Enum.FillDirection.Vertical then
		scrollingDirection = Enum.ScrollingDirection.Y
	else
		scrollingDirection = Enum.ScrollingDirection.X
	end

	v2.ScrollingDirection = scrollingDirection
	local canvasSize

	if data.FillDirection == Enum.FillDirection.Vertical then
		canvasSize = size - UDim2.fromOffset(0, 1)
	else
		canvasSize = size - UDim2.fromOffset(1, 0)
	end

	v2.CanvasSize = canvasSize
	local createElement2 = React.createElement
	local automaticSize

	if data.FillDirection == Enum.FillDirection.Vertical then
		automaticSize = Enum.AutomaticSize.Y
	else
		automaticSize = Enum.AutomaticSize.X
	end

	if data.FillDirection == Enum.FillDirection.Vertical then
	end

	local v8 = {
		AutomaticSize = automaticSize,
		Size = UDim2.fromScale(1, 0.9),
		AnchorPoint = 0,
		Position = 0,
		BackgroundTransparency = 1
	}
	local anchorPoint

	if data.FillDirection == Enum.FillDirection.Vertical then
		anchorPoint = Vector2.new(0.5, 0)
	else
		anchorPoint = Vector2.new(0, 0.5)
	end

	v8.AnchorPoint = anchorPoint
	local position

	if data.FillDirection == Enum.FillDirection.Vertical then
		position = UDim2.fromScale(0.5, 0)
	else
		position = UDim2.fromScale(0, 0.5)
	end

	v8.Position = position
	return createElement("ScrollingFrame", v2, {
		Content = createElement2("Frame", v8, {
			Padding = React.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5)
			}),
			List = React.createElement("UIListLayout", {
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = data.FillDirection or Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalFlex = Enum.UIFlexAlignment.SpaceEvenly
			}),
			__front = padding and React.createElement("Frame", {
				Size = UDim2.new(padding, padding),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				LayoutOrder = -2147483648,
				BackgroundTransparency = 1
			}),
			__back = padding and React.createElement("Frame", {
				Size = UDim2.new(padding, padding),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 2147483647,
				BackgroundTransparency = 1
			})
		}, children)
	})
end

return CollectFlow