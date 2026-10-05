local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Library = require(script.Icon.Library)
local Star = require(script.Star)
local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local useSequence = require(game.ReplicatedStorage.React.Hooks.Animation.useSequence)
local useSpringMap = require(game.ReplicatedStorage.React.Hooks.Animation.useSpringMap)
local useKeyFrames = require(game.ReplicatedStorage.React.Hooks.Animation.useKeyFrames)
local useStrictLerp = require(game.ReplicatedStorage.React.Hooks.Animation.useStrictLerp)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
require(game.ReplicatedStorage.Definitions.Map.Types)
require(game.ReplicatedStorage.React.Components.Map.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local questionMark = SpriteMap.UI.QuestionMark
local createElement = React.createElement

function awakenedEffect(p)
	local value = TweenService:GetValue(usePeriod(true, 3), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local v2 = 1 - math.abs(value - 0.5) * 2
	local transparency = useSequence(value, value + 0.01, 0, 1 - v2 * 0.4, 0.2)
	return createElement("ImageLabel", {
		Image = p.Island.Display.IconOutline.Image,
		ImageRectOffset = p.Island.Display.IconOutline.ImageRectOffset,
		ImageRectSize = p.Island.Display.IconOutline.ImageRectSize,
		ImageTransparency = CONSTANTS.ALPHA.OPAQUE,
		ImageColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 4
	}, {
		UIGradient = createElement("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(Color3.fromHSV(0, 1 - v2 * 0.15, 1)),
			Transparency = transparency
		})
	})
end

function selectionEmblem(p)
	local state, setState = React.useState(nil)
	local v, _ = useKeyFrames({
		{
			Duration = 0.1,
			Id = "Start"
		},
		{
			Duration = 0.1,
			Id = "Ascend"
		},
		{
			Duration = 0.2,
			Id = "MoveToFront"
		},
		{
			Duration = 0.1,
			Id = "Finish"
		}
	}, state ~= nil, false, state)
	React.useEffect(function()
		task.spawn(function()
			if p.IsSelected then
				setState(1)
			else
				setState(-1)
			end
		end)
		return function() end
	end, { p.IsSelected })
	local v2 = useSpringMap("Start", v, 1.1, 1.8, {
		Ascend = -0.015,
		MoveToFront = -0.15
	}, 0.75)
	local imageTransparency = useSpringMap("Start", v, 1.1, 1.8, {
		Start = 1
	}, 0)
	local v4 = useSpringMap("Start", v, 1.1, 1.8, {
		Ascend = 0.5,
		MoveToFront = 0.5
	}, 1)
	local v5 = useSpringMap("Start", v, 1.1, 1.8, {
		Start = 0.3,
		Ascend = 0.3,
		MoveToFront = 0.5,
		Finish = 0.5
	}, 0.65)
	local zIndex = useSpringMap("Start", v, 1.1, 1.8, {
		MoveToFront = 12,
		Finish = 12
	}, 0)
	local marineIcon = p.Variant == "Marines" and SpriteMap.UI["Marine Icon"] or SpriteMap.UI["Pirate Icon"]
	local marineIconOutline = p.Variant == "Marines" and SpriteMap.UI["Marine Icon Outline"] or SpriteMap.UI["Pirate Icon Outline"]
	return state ~= nil and createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.fromScale(v5, v5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, v2),
		AnchorPoint = Vector2.new(0.5, v4),
		ImageTransparency = imageTransparency,
		Image = marineIconOutline.Image,
		ImageRectOffset = marineIconOutline.ImageRectOffset,
		ImageRectSize = marineIconOutline.ImageRectSize,
		ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		ZIndex = zIndex
	}, p), {
		Icon = createElement("ImageLabel", {
			ZIndex = CONSTANTS.LAYER.RAISED,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(1, 1),
			Image = marineIcon.Image,
			ImageRectOffset = marineIcon.ImageRectOffset,
			ImageRectSize = marineIcon.ImageRectSize
		})
	}) or nil
end

return function(props)
	local imageTransparency = useSpring(props.IsGlowEnabled and 0.3 or 1, props.IsGlowEnabled and 0.3 or 1, 0.75, 1.25)
	local imageTransparency2 = useSpring(props.IsLocked and 1 or 0, props.IsLocked and 1 or 0, 0.75, 1.25)
	local v3 = useSpring(props.IsRecommended and 1 or 0, props.IsRecommended and 1 or 0, 0.85, 1.75)
	local v4 = useStrictLerp(
		props.IsSelected and 1 or 0,
		props.IsSelected and 1 or 0,
		0.3,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	)
	local state, setState = React.useState(Enum.GuiState.Idle)

	if not props.OnClick then
		state = Enum.GuiState.Idle
	end

	local v5 = useDrawContext()

	if v5 ~= "Default" then
		state = Enum.GuiState.Idle
	end

	local children = {}

	for i = 1, props.Stars or 0 do
		children[`Star{i}`] = createElement(Star, {
			Size = UDim2.fromScale(1, 1):Lerp(UDim2.new(0, 0), 1 - v4),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			LayoutOrder = i,
			ImageTransparency = imageTransparency2,
			IsCompleted = i <= (props.StarsFilled or 0)
		})
	end

	local v6 = Library[props.Island.Index.Map]
	local v7

	if not (props.IconMode == "Default" or not v6) then
		v7 = v6[props.Island.Index.Key]
	end

	local clone = table.clone(props)
	local v8 = clone[React.Tag]
	local v9 = props.IsSelected and 4 or 0
	local v10

	if state == Enum.GuiState.Hover then
		v10 = props.IsSelected and 1 or 2
	else
		v10 = state ~= Enum.GuiState.Press and 0 or props.IsSelected and 0.5 or 1
	end

	local v11 = (v9 + v10) / 5
	local v12 = useSpring(v11, v11, 0.8, 2.5)
	clone[React.Tag] = nil
	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ZIndex = (props.ZIndex or 0) + v12 * 40
	}, clone)
	local v15 = {
		UIScale = createElement("UIScale", {
			Scale = 1.05 ^ (v12 * 5)
		}),
		SelectionEmblem = 0,
		RecommendationBanner = 0,
		AwakenedIcon = nil,
		Icon = 0,
		Glow = 0,
		OutlineIcon = 0,
		Stars = 0
	}
	local selectionEmblem2

	if props.SelectionEmblem then
		selectionEmblem2 = createElement(selectionEmblem, {
			Variant = props.SelectionEmblem,
			IsSelected = props.IsSelected == true
		}) or nil
	end

	v15.SelectionEmblem = selectionEmblem2
	local recommendationBanner

	if v3 > 0 then
		recommendationBanner = createElement("Frame", {
			Size = UDim2.fromScale(1.5, 0.8),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.25),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = 10
		}, {
			UISizeConstraint = createElement("UISizeConstraint", {
				MinSize = Vector2.zero,
				MaxSize = Vector2.new(150, 80) * 0.4 * 2.1
			}),
			Icon = createElement("ImageLabel", {
				Image = questionMark.Image,
				ImageRectOffset = questionMark.ImageRectOffset,
				ImageRectSize = questionMark.ImageRectSize,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				ImageTransparency = 1 - v3,
				Size = UDim2.fromScale(0.5, 0.5),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Position = UDim2.fromScale(0.5, 0.65),
				AnchorPoint = Vector2.new(0.5, 1),
				ZIndex = 10
			}),
			LabelContainer = createElement("Frame", {
				BackgroundTransparency = 1 - v3,
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				ZIndex = 20,
				Size = UDim2.fromScale(1.5, 0.3),
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 1)
			}, {
				UIGradient = createElement("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.2, 0.5),
						NumberSequenceKeypoint.new(0.3, 0.3),
						NumberSequenceKeypoint.new(0.7, 0.3),
						NumberSequenceKeypoint.new(0.8, 0.5),
						NumberSequenceKeypoint.new(1, 1)
					})
				}),
				Label = createElement("TextLabel", {
					Text = "Recommended",
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					TextScaled = true,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					TextTransparency = 1 - v3,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextWrapped = false,
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromScale(1, 1.2)
				})
			})
		})
	else
		recommendationBanner = false
	end

	v15.RecommendationBanner = recommendationBanner
	v15.Icon = createElement("ImageButton", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ImageTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Active = v5 == "Default" and props.OnClick ~= nil,
		Selectable = v5 == "Default" and props.OnClick ~= nil,
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 4,
		[React.Tag] = v8,
		[React.Change.GuiState] = function(p)
			setState(p.GuiState)
		end,
		[React.Event.Activated] = v5 == "Default" and props.OnClick and function()
			props.OnClick()
		end or nil
	}, {
		Icon = createElement("ImageLabel", {
			Image = props.Island.Display.Icon.Image,
			ImageRectOffset = props.Island.Display.Icon.ImageRectOffset,
			ImageRectSize = props.Island.Display.Icon.ImageRectSize,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ImageTransparency = v7 and 1 or 0,
			Active = false,
			ImageColor3 = Color3.fromHSV(0, 0, 1 - imageTransparency2 * 0.8),
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}),
		Animation = v7 and createElement(v7, {
			Mode = props.IconMode,
			ImageColor3 = Color3.fromHSV(0, 0, 1 - imageTransparency2 * 0.8),
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 4
		}),
		Level = props.Level and createElement("TextLabel", {
			Text = `Lv. {props.Level}`,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Position = UDim2.fromScale(0.5, 0.55),
			AnchorPoint = Vector2.new(0.5, 0.5),
			FontFace = CONSTANTS.FONT.FACE.DISPLAY_LIGHT,
			TextScaled = true,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			TextTransparency = 1 - imageTransparency2,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			Size = UDim2.fromScale(0.6, 0.4),
			TextWrapped = false,
			ZIndex = 20
		}),
		ShadowContainer = createElement("Frame", {
			Size = UDim2.fromScale(0.5 + 0.1 * v12, 0.25 + 0.05 * v12),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.75 + 0.1 * v12),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = CONSTANTS.LAYER.BASE
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
			}),
			Shadow = createElement("UIShadow", {
				Color = CONSTANTS.COLOR.PALETTE.BLACK,
				BlurRadius = UDim.new(0.5, 0),
				Offset = UDim2.fromScale(0, 0),
				Spread = UDim2.fromScale(0.3, 0.1),
				Transparency = 0.4 + 0.2 * v12
			})
		})
	})
	local glow

	if not (imageTransparency >= 1) then
		glow = createElement("ImageLabel", {
			Image = Spritesheets.match("Shadow"):unwrap().Image,
			ImageRectOffset = Spritesheets.match("Shadow"):unwrap().ImageRectOffset,
			ImageRectSize = Spritesheets.match("Shadow"):unwrap().ImageRectSize,
			Active = false,
			Size = UDim2.fromScale(1.5, 1.5),
			ImageColor3 = Color3.fromHex("#FFE635"),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ImageTransparency = imageTransparency,
			ZIndex = CONSTANTS.LAYER.RAISED
		})
	end

	v15.Glow = glow
	local outlineIcon

	if not (state == Enum.GuiState.Idle and not (props.IsGlowEnabled or props.IsSelected)) then
		outlineIcon = createElement("ImageButton", {
			Image = props.Island.Display.IconOutline.Image,
			ImageRectOffset = props.Island.Display.IconOutline.ImageRectOffset,
			ImageRectSize = props.Island.Display.IconOutline.ImageRectSize,
			ImageTransparency = state == Enum.GuiState.Press and 0.3 or 0,
			ImageColor3 = Color3.fromHex("#FFE635"),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		})
	end

	v15.OutlineIcon = outlineIcon
	local stars = props.Stars

	if stars then
		if props.Stars > 0 and v4 > 0 and props.IsLocked ~= true then
			stars = createElement("ImageLabel", {
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.9, 0, 0.2, 0),
				Position = UDim2.fromScale(0.5, 0.8 + 0.2 * v4),
				AnchorPoint = Vector2.new(0.5, 1),
				ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				ImageTransparency = CONSTANTS.ALPHA.INVISIBLE,
				ZIndex = (v4 >= 1 and 30 or 0) + 1
			}, {
				UIListLayout = createElement("UIListLayout", {
					Padding = CONSTANTS.SPACING.PADDING.SCALE.LG,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal
				}),
				Stars = createElement(React.Fragment, {}, children),
				UICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
				}),
				Shadow = createElement("UIShadow", {
					Color = CONSTANTS.COLOR.PALETTE.BLACK,
					BlurRadius = UDim.new(0.5, 0),
					Offset = UDim2.fromScale(0, 0.1 + 0.1 * v12),
					Spread = UDim2.fromScale(0, -0.1),
					Transparency = 0.4 + 0.4 * v12
				})
			})
		else
			stars = false
		end
	end

	v15.Stars = stars
	return createElement("Frame", mergeFrame, v15)
end