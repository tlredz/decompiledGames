local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	Left = Vector2.new(300, 0),
	Right = Vector2.new(400, 0)
}
local createElement = React.createElement

local function arrowButton(p)
	return createElement("ImageButton", RobloxTypes.mergeImageButton({
		AutoButtonColor = false,
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = CONSTANTS.COLOR.SECONDARY.BACKGROUND,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ImageTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.fromScale(0, 0.24)
	}, p), {
		AspectRatio = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height
		}),
		Outline = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = CONSTANTS.COLOR.SECONDARY.BORDER,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		Highlight = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = CONSTANTS.COLOR.SECONDARY.HIGHLIGHT,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.94, 0.47),
			ZIndex = CONSTANTS.LAYER.CONTENT
		}, {
			Gradient = createElement("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.49, 0),
					NumberSequenceKeypoint.new(0.51, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		}),
		Icon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Image = "rbxassetid://127503254560275",
			ImageRectOffset = v[p.Direction],
			ImageRectSize = Vector2.new(100, 100),
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.7, 0.7),
			ZIndex = CONSTANTS.LAYER.RAISED
		})
	})
end

return function(props)
	local v2 = math.max(props.MaxPage, 1)
	local v3 = math.clamp(props.CurrentPage, 1, v2)
	local v4 = v2 > 1
	local v5 = {}

	if v4 then
		for i = 1, v2 do
			local formatted = `Dot{i}`
			local backgroundColor

			if i == v3 then
				backgroundColor = CONSTANTS.COLOR.PRIMARY.BACKGROUND
			else
				backgroundColor = Color3.fromRGB(158, 158, 158)
			end

			v5[formatted] = createElement("Frame", {
				Active = true,
				BackgroundColor3 = backgroundColor,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				LayoutOrder = i,
				Size = UDim2.fromScale(0, 0.5)
			}, {
				AspectRatio = createElement("UIAspectRatioConstraint", {
					AspectRatio = 1,
					AspectType = Enum.AspectType.ScaleWithParentSize,
					DominantAxis = Enum.DominantAxis.Height
				}),
				UICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
				})
			})
		end
	end

	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
	}, props)
	local v8 = {
		MarginPadding = createElement("UIPadding", {
			PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.MD,
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10)
		}),
		UISizeConstraint = createElement("UISizeConstraint", {
			MinSize = Vector2.new(0, 60)
		}),
		Body = 0,
		Dots = 0
	}
	local v11 = {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(1, v4 and 0.94 or 1)
	}
	local leftButton

	if not (v3 <= 1) then
		leftButton = createElement(arrowButton, {
			AnchorPoint = Vector2.new(1, 0.5),
			Direction = "Left",
			Position = UDim2.fromScale(0, 0.5),
			Selectable = props.Selectable ~= false,
			[React.Event.Activated] = function()
				props.OnPageChanged((math.clamp(v3 - 1, 1, v2)))
			end
		})
	end

	local v12 = {
		LeftButton = leftButton,
		Content = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.95, 1)
		}, {
			MarginPadding = createElement("UIPadding", {
				PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.SM,
				PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.SM,
				PaddingTop = UDim.new(0, 5)
			}),
			ContentComponent = createElement(props.ContentComponent, {
				Size = UDim2.fromScale(1, 1)
			})
		}),
		RightButton = 0
	}
	local rightButton

	if not (v2 <= v3) then
		rightButton = createElement(arrowButton, {
			AnchorPoint = Vector2.new(0, 0.5),
			Direction = "Right",
			Position = UDim2.fromScale(1, 0.5),
			Selectable = props.Selectable ~= false,
			[React.Event.Activated] = function()
				props.OnPageChanged((math.clamp(v3 + 1, 1, v2)))
			end
		})
	end

	v12.RightButton = rightButton
	v8.Body = createElement("Frame", v11, v12)
	local dots

	if v4 then
		dots = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(1, 0.06)
		}, {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = CONSTANTS.SPACING.PADDING.OFFSET.SM,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			Dots = createElement(React.Fragment, {}, v5)
		})
	end

	v8.Dots = dots
	return createElement("Frame", mergeFrame, v8)
end