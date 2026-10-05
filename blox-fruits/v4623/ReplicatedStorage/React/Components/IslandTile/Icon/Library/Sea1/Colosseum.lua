local React = require(game.ReplicatedStorage.Packages.React)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Star = require(game.ReplicatedStorage.React.Components.IslandTile.Star)
local Path2D = require(game.ReplicatedStorage.React.Components.Path2D)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
local useKeyFrames = require(game.ReplicatedStorage.React.Hooks.Island.Animation.useKeyFrames)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.React.Components.Map.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local colosseums1 = SpriteMap.Islands["colosseum-s1"]
local colosseums1front = SpriteMap.IslandAnimations["colosseum-s1-front"]
local shadow = SpriteMap.All.Shadow
local awakenedMedal = SpriteMap.UI["Awakened Medal"]
local createElement = React.createElement

function starPath(props)
	local ref = React.useRef(nil)
	local controlPoints = React.useMemo(function()
		local path2DControlPoints = {}

		for i = 0, 10 do
			local path2DControlPoint = Path2DControlPoint.new()
			local v2 = i / 10
			path2DControlPoint.Position = UDim2.fromScale((v2 - 0.5) * 1.5 + 0.5, 1 - math.sin((math.rad(v2 * 180))))
			table.insert(path2DControlPoints, path2DControlPoint)
		end

		return path2DControlPoints
	end, {})
	local v2 = useSpring(0, props.IsPlaying and 1 or 0, 2.2, 2)
	local v3 = useSpring(1, 1, 1.5, 1.2)
	local animationPeriod = props.AnimationPeriod or 1.5
	local animationDelay = props.AnimationDelay or 0
	local v4 = animationPeriod + animationDelay
	local v5 = usePeriod(true, v4)

	if props.AnimationOffset then
		v5 += props.AnimationOffset * v4
	end

	local v6 = v5 % 1
	local v7 = not (animationDelay / v4 < v6) and 0 or (v6 - animationDelay / v4) / (1 - animationDelay / v4)
	return createElement("Frame", RobloxTypes.mergeFrame({
		Active = false,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.new(props.Size.X, UDim.new(props.Size.Y.Scale + v3 * 0.15 * 3, props.Size.Y.Offset)):Lerp(
			UDim2.new(props.Size.X, UDim.new(0, 1)),
			1 - v2
		)
	}, props), {
		Path2D = createElement(Path2D, {
			ref = ref,
			ControlPoints = controlPoints,
			Visible = false,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.THICK,
			Color3 = Color3.new(1, 0, 1)
		}),
		Star = ref.current and createElement(Star, {
			Size = props.StarSize,
			Rotation = v7 * 360,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = ref.current:GetPositionOnCurve(v7),
			IsCompleted = true
		})
	})
end

return function(props)
	local _, _, v, v2 = useKeyFrames(props.Mode, props.IsLooping)
	local v3 = math.clamp((v2 - 0.5) / 0.5, 0, 1) * 1.2
	local v4 = usePeriod(v3 > 0, 3) * 360
	local uDim = UDim2.fromScale(1.5, 1.5)
	local uDim2 = UDim2.fromScale(0.35, 0.35)
	local mergeImageLabel = RobloxTypes.mergeImageLabel({
		Image = colosseums1.Image,
		ImageRectOffset = colosseums1.ImageRectOffset,
		ImageRectSize = colosseums1.ImageRectSize,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}, props)
	local v7 = {
		FrontCover = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(1, 1),
			Image = colosseums1front.Image,
			ImageRectOffset = colosseums1front.ImageRectOffset,
			ImageRectSize = colosseums1front.ImageRectSize,
			ImageColor3 = props.ImageColor3,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		}),
		Medal = 0,
		StarJumps = 0
	}
	local medal

	if v2 > 0 then
		medal = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			AnchorPoint = Vector2.new(0.5, 0.35 + v2 * 0.25),
			Position = UDim2.fromScale(0.5, 0.5 - 0.45 * v2),
			Size = UDim2.fromScale(0.4, 0.4),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			ZIndex = CONSTANTS.LAYER.CONTENT
		}, {
			Glow = createElement("ImageLabel", {
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = shadow.Image,
				ImageRectOffset = shadow.ImageRectOffset,
				ImageRectSize = shadow.ImageRectSize,
				Size = UDim2.fromScale(1.35, 1.35),
				ImageTransparency = 0.5 + 0.5 * (1 - v2),
				ImageColor3 = Color3.new(1, 0, 0),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
			}),
			Star1 = createElement(Star, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = uDim2,
				IsCompleted = true,
				ZIndex = CONSTANTS.LAYER.RAISED,
				Position = UDim2.fromScale(
					math.cos((math.rad(v4))) * v3 * 0.5 + 0.5,
					math.sin((math.rad(v4))) * v3 * 0.5 + 0.5
				)
			}, {
				Glow = createElement("ImageLabel", {
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = shadow.Image,
					ImageRectOffset = shadow.ImageRectOffset,
					ImageRectSize = shadow.ImageRectSize,
					Size = UDim2.fromScale(2, 2),
					ImageTransparency = (1 - v3) * 0.2 + 0.8,
					ImageColor3 = Color3.new(1, 0.85098, 0),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
				})
			}),
			Star2 = createElement(Star, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = uDim2,
				IsCompleted = true,
				ZIndex = CONSTANTS.LAYER.RAISED,
				Position = UDim2.fromScale(
					math.cos((math.rad(v4 + 120))) * v3 * 0.5 + 0.5,
					math.sin((math.rad(v4 + 120))) * v3 * 0.5 + 0.5
				)
			}, {
				Glow = createElement("ImageLabel", {
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = shadow.Image,
					ImageRectOffset = shadow.ImageRectOffset,
					ImageRectSize = shadow.ImageRectSize,
					Size = UDim2.fromScale(2, 2),
					ImageTransparency = (1 - v3) * 0.2 + 0.8,
					ImageColor3 = Color3.new(1, 0.85098, 0),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
				})
			}),
			Star3 = createElement(Star, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = uDim2,
				IsCompleted = true,
				ZIndex = CONSTANTS.LAYER.RAISED,
				Position = UDim2.fromScale(
					math.cos((math.rad(v4 - 120))) * v3 * 0.5 + 0.5,
					math.sin((math.rad(v4 - 120))) * v3 * 0.5 + 0.5
				)
			}, {
				Glow = createElement("ImageLabel", {
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = shadow.Image,
					ImageRectOffset = shadow.ImageRectOffset,
					ImageRectSize = shadow.ImageRectSize,
					Size = UDim2.fromScale(2, 2),
					ImageTransparency = (1 - v3) * 0.2 + 0.8,
					ImageColor3 = Color3.new(1, 0.85098, 0),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
				})
			}),
			Medal = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Image = awakenedMedal.Image,
				ImageRectOffset = awakenedMedal.ImageRectOffset,
				ImageRectSize = awakenedMedal.ImageRectSize,
				ImageColor3 = CONSTANTS.COLOR.PALETTE.WHITE:Lerp(
					Color3.new(0.3, 0.3, 0.3),
					(math.clamp(1 - (v2 - 0.5) / 0.5, 0, 1))
				),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			})
		})
	else
		medal = false
	end

	v7.Medal = medal
	local starJumps

	if v > 0 then
		local v12 = {
			Size = UDim2.new(0.4, 0, 0.5 * v, 1 * (1 - v)),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = CONSTANTS.LAYER.RAISED
		}
		local v13 = {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Bottom
			}),
			StarPath1 = createElement(starPath, {
				IsPlaying = props.Mode ~= "Default",
				LayoutOrder = 1,
				AnimationDelay = 0.2,
				AnimationPeriod = 1.2,
				AnimationOffset = 0.5,
				Size = UDim2.fromScale(0.25, 0.6),
				StarSize = uDim
			}),
			StarPath2 = 0,
			StarPath3 = 0
		}
		local starPath2 = starPath
		v13.StarPath2 = createElement(starPath2, {
			IsPlaying = props.Mode ~= "Default" and props.Mode ~= "OneStar",
			AnimationDelay = 0.75,
			AnimationPeriod = 1.5,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.3333333333333333, 0.7),
			StarSize = uDim,
			ZIndex = CONSTANTS.LAYER.RAISED
		})
		v13.StarPath3 = createElement(starPath, {
			IsPlaying = props.Mode == "Completed" or props.Mode == "ThreeStar",
			LayoutOrder = 3,
			AnimationDelay = 0.1,
			AnimationPeriod = 1.15,
			AnimationOffset = 0.3,
			Size = UDim2.fromScale(0.25, 0.65),
			StarSize = uDim
		})
		starJumps = createElement("Frame", v12, v13)
	else
		starJumps = false
	end

	v7.StarJumps = starJumps
	return createElement("ImageLabel", mergeImageLabel, v7)
end