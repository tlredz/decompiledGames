local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Star = require(game.ReplicatedStorage.React.Components.IslandTile.Star)
local Path2D = require(game.ReplicatedStorage.React.Components.Path2D)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local useKeyFrames = require(game.ReplicatedStorage.React.Hooks.Island.Animation.useKeyFrames)
local useEvent = require(game.ReplicatedStorage.React.Hooks.Animation.useEvent)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.React.Components.Map.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local volcanos1 = SpriteMap.Islands["volcano-s1"]
local volcanos1front = SpriteMap.IslandAnimations["volcano-s1-front"]
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
			path2DControlPoint.Position = UDim2.fromScale(
				0.5 + (props.Direction or 1) * (v2 - 0.5),
				1 - math.sin((math.rad(v2 * 180))) * 1.15
			)
			table.insert(path2DControlPoints, path2DControlPoint)
		end

		return path2DControlPoints
	end, { props.Direction })
	local v2 = not (props.Alpha > 0.8) and 1 or 1 - math.clamp((props.Alpha - 0.8) / 0.2, 0, 1)
	return createElement("Frame", RobloxTypes.mergeFrame({
		Active = false,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.new(props.Size.X, UDim.new(props.Size.Y.Scale, props.Size.Y.Offset))
	}, props), {
		Path2D = createElement(Path2D, {
			ref = ref,
			ControlPoints = controlPoints,
			Visible = false,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.THICK,
			Color3 = Color3.new(1, 0, 1)
		}),
		Glow = ref.current and createElement("ImageLabel", {
			Image = shadow.Image,
			ImageRectOffset = shadow.ImageRectOffset,
			ImageRectSize = shadow.ImageRectSize,
			ImageTransparency = 0.4,
			ImageColor3 = Color3.new(1, 0.266667, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(props.StarSize.X.Scale * 1.75 * v2, props.StarSize.Y.Scale * 1.75 * v2),
			Rotation = props.Alpha * 360,
			AnchorPoint = Vector2.new(0.5, 0.5),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = ref.current:GetPositionOnCurve(props.Alpha)
		}),
		Star = ref.current and createElement(Star, {
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = props.StarSize:Lerp(UDim2.fromScale(0, 0), 1 - v2),
			Rotation = props.Alpha * 360,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = ref.current:GetPositionOnCurve(props.Alpha),
			IsCompleted = true,
			ZIndex = CONSTANTS.LAYER.RAISED
		})
	})
end

return function(props)
	local _, _, v, v2 = useKeyFrames(props.Mode, props.IsLooping)
	local value = TweenService:GetValue(
		math.clamp((v2 - 0.6) / 0.4, 0, 1),
		Enum.EasingStyle.Cubic,
		Enum.EasingDirection.InOut
	)
	local v4 = math.clamp((v2 - 0.3) / 0.7, 0, 1) * 1.2
	local v5 = usePeriod(v4 > 0, 3) * 360
	local uDim = UDim2.fromScale(0.35, 0.35)
	local v6

	if props.Mode == "OneStar" then
		v6 = 1
	elseif props.Mode == "TwoStar" then
		v6 = 2
	elseif props.Mode == "ThreeStar" or props.Mode == "Completed" then
		v6 = 3
	else
		v6 = 0
	end

	local v7 = useEvent()
	React.useEffect(function()
		if v > 0 then
			task.spawn(function()
				for i = 1, v6 do
					v7.fire(`{i}`, 1.25, i * 0.15)
				end
			end)
		end

		return function() end
	end, { v > 0, v6 })
	local children = {}

	for k, alpha in v7.active do
		local direction = 0
		local v10 = 1

		if k == "1" then
			v10 = 0.7
			direction = -1
		elseif k == "2" then
			v10 = 1
			direction = 0.5
		elseif k == "3" then
			v10 = 0.8
			direction = 1
		end

		children[`Star{k}`] = createElement(starPath, {
			Size = UDim2.fromScale(1, v10),
			StarSize = UDim2.fromScale(0.2, 0.2),
			Position = UDim2.fromScale(0.5, 1),
			Direction = direction,
			AnchorPoint = Vector2.new(0.5 - direction * 0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = CONSTANTS.LAYER.RAISED,
			Alpha = alpha
		})
	end

	local mergeImageLabel = RobloxTypes.mergeImageLabel({
		Image = volcanos1.Image,
		ImageRectOffset = volcanos1.ImageRectOffset,
		ImageRectSize = volcanos1.ImageRectSize,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}, props)
	local v10 = {
		FrontCover = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(1, 1),
			Image = volcanos1front.Image,
			ImageRectOffset = volcanos1front.ImageRectOffset,
			ImageRectSize = volcanos1front.ImageRectSize,
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
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5 - 0.45 * v2),
			Size = UDim2.fromScale(0.4, 0.4):Lerp(UDim2.fromScale(0.15, 0.15), 1 - value),
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
				ImageTransparency = CONSTANTS.ALPHA.HALF,
				ImageColor3 = Color3.new(1, 0, 0),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
			}),
			Star1 = createElement(Star, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = uDim,
				IsCompleted = true,
				ZIndex = CONSTANTS.LAYER.RAISED,
				Position = UDim2.fromScale(
					math.cos((math.rad(v5))) * v4 * 0.5 + 0.5,
					math.sin((math.rad(v5))) * v4 * 0.5 + 0.5
				)
			}, {
				Glow = createElement("ImageLabel", {
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = shadow.Image,
					ImageRectOffset = shadow.ImageRectOffset,
					ImageRectSize = shadow.ImageRectSize,
					Size = UDim2.fromScale(2, 2),
					ImageTransparency = (1 - v4) * 0.2 + 0.8,
					ImageColor3 = Color3.new(1, 0.85098, 0),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
				})
			}),
			Star2 = createElement(Star, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = uDim,
				IsCompleted = true,
				ZIndex = CONSTANTS.LAYER.RAISED,
				Position = UDim2.fromScale(
					math.cos((math.rad(v5 + 120))) * v4 * 0.5 + 0.5,
					math.sin((math.rad(v5 + 120))) * v4 * 0.5 + 0.5
				)
			}, {
				Glow = createElement("ImageLabel", {
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = shadow.Image,
					ImageRectOffset = shadow.ImageRectOffset,
					ImageRectSize = shadow.ImageRectSize,
					Size = UDim2.fromScale(2, 2),
					ImageTransparency = (1 - v4) * 0.2 + 0.8,
					ImageColor3 = Color3.new(1, 0.85098, 0),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
				})
			}),
			Star3 = createElement(Star, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = uDim,
				IsCompleted = true,
				ZIndex = CONSTANTS.LAYER.RAISED,
				Position = UDim2.fromScale(
					math.cos((math.rad(v5 - 120))) * v4 * 0.5 + 0.5,
					math.sin((math.rad(v5 - 120))) * v4 * 0.5 + 0.5
				)
			}, {
				Glow = createElement("ImageLabel", {
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = shadow.Image,
					ImageRectOffset = shadow.ImageRectOffset,
					ImageRectSize = shadow.ImageRectSize,
					Size = UDim2.fromScale(2, 2),
					ImageTransparency = (1 - v4) * 0.2 + 0.8,
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
				ImageColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			})
		})
	else
		medal = false
	end

	v10.Medal = medal
	v10.StarJumps = v > 0 and createElement("Frame", {
		Size = UDim2.fromScale(0.4, 0.7),
		Position = UDim2.fromScale(0.5, 0.35),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ZIndex = CONSTANTS.LAYER.RAISED
	}, {
		Stars = createElement(React.Fragment, {}, children)
	})
	return createElement("ImageLabel", mergeImageLabel, v10)
end