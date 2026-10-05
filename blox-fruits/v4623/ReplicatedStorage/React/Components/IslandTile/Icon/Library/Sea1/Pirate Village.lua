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
local piratevillages1 = SpriteMap.Islands["pirate-village-s1"]
local piratevillages1front = SpriteMap.IslandAnimations["pirate-village-s1-front"]
local shadow = SpriteMap.All.Shadow
local awakenedMedal = SpriteMap.UI["Awakened Medal"]
local createElement = React.createElement

function starPath(props)
	local ref = React.useRef(nil)
	local controlPoints = React.useMemo(function()
		local path2DControlPoints = {}

		for i = 0, 20 do
			local path2DControlPoint = Path2DControlPoint.new()
			path2DControlPoint.Position = props.Offset + UDim2.fromScale(
				math.sin((math.rad(i / 20 * 360))) * 0.7 + 0.45,
				0
			)
			table.insert(path2DControlPoints, path2DControlPoint)
		end

		return path2DControlPoints
	end, { props.Offset })
	local alpha = props.Alpha
	local v2 = math.sin((math.rad(alpha * 180))) * 0.35 + 0.65

	if alpha > 0.99 then
		v2 *= 1 - (alpha - 0.99) / 0.01
	end

	return createElement(React.Fragment, {}, {
		Path2D = createElement(Path2D, {
			ref = ref,
			ControlPoints = controlPoints,
			Visible = false,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.THICK,
			Color3 = Color3.new(1, 0, 1)
		}),
		Star = ref.current and createElement(Star, {
			Size = UDim2.new(
				props.StarSize.X.Scale * v2,
				props.StarSize.X.Offset * v2,
				props.StarSize.Y.Scale * v2,
				props.StarSize.Y.Offset * v2
			),
			AnchorPoint = Vector2.new(0.5, 0.55),
			Position = ref.current:GetPositionOnCurve(alpha) + UDim2.fromScale(0, math.abs(0.5 - alpha) * 0.5),
			IsCompleted = true,
			ZIndex = alpha > 0.25 and alpha < 0.85 and 4 or 1
		})
	})
end

return function(props)
	local _, _, v, v2 = useKeyFrames(props.Mode, props.IsLooping)
	local v3 = math.clamp((v2 - 0.7) / 0.3, 0, 1) * 1.2
	local v4 = usePeriod(v3 > 0, 3) * 360
	local uDim = UDim2.fromScale(0.35, 0.35)
	local v5

	if props.Mode == "OneStar" then
		v5 = 1
	elseif props.Mode == "TwoStar" then
		v5 = 2
	elseif props.Mode == "ThreeStar" or props.Mode == "Completed" then
		v5 = 3
	else
		v5 = 0
	end

	local v6 = useEvent()
	React.useEffect(function()
		if v > 0 then
			task.spawn(function()
				for i = 1, v5 do
					v6.fire(`{i}`, 1.5, i * 0.35)
				end
			end)
		end

		return function() end
	end, { v > 0, v5 })
	local children = {}

	for k, alpha in v6.active do
		local uDim2 = UDim2.fromScale(0, 0.375)
		children[`Star{k}`] = createElement(starPath, {
			StarSize = UDim2.fromScale(0.15, 0.15):Lerp(UDim2.fromScale(0, 0), 1 - v),
			Offset = uDim2,
			Alpha = alpha
		})
	end

	local mergeImageLabel = RobloxTypes.mergeImageLabel({
		ImageTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}, props)
	local v9 = {
		BackCover = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(1, 1),
			Image = piratevillages1.Image,
			ImageRectOffset = piratevillages1.ImageRectOffset,
			ImageRectSize = piratevillages1.ImageRectSize,
			ImageColor3 = props.ImageColor3,
			ZIndex = CONSTANTS.LAYER.CONTENT
		}),
		FrontCover = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(1, 1),
			Image = piratevillages1front.Image,
			ImageRectOffset = piratevillages1front.ImageRectOffset,
			ImageRectSize = piratevillages1front.ImageRectSize,
			ImageColor3 = props.ImageColor3,
			ZIndex = 4
		}),
		MedalContainer = 0,
		Stars = 0
	}
	local v12 = {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.75),
		Size = UDim2.fromScale(1, 1.5),
		ZIndex = CONSTANTS.LAYER.RAISED_HIGH,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Active = false,
		ClipsDescendants = true
	}
	local medal

	if v2 > 0 then
		medal = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 1):Lerp(UDim2.fromScale(0.5, 0.4), v2),
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.fromScale(0.4, 0.4):Lerp(UDim2.fromScale(0.4, 0.4), v2),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
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
				Size = uDim,
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
				Size = uDim,
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
				Size = uDim,
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
					Color3.new(0.4, 0.4, 0.4),
					(math.clamp(1 - (v2 - 0.5) / 0.5, 0, 1))
				),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			})
		})
	else
		medal = false
	end

	v9.MedalContainer = createElement("Frame", v12, {
		Medal = medal
	})
	v9.Stars = createElement(React.Fragment, {}, children)
	return createElement("ImageLabel", mergeImageLabel, v9)
end