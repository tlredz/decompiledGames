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
local upperskys1 = SpriteMap.Islands["upper-sky-s1"]
local upperskys1front = SpriteMap.IslandAnimations["upper-sky-s1-front"]
local shadow = SpriteMap.All.Shadow
local awakenedMedal = SpriteMap.UI["Awakened Medal"]
local createElement = React.createElement

function starPath(p)
	local ref = React.useRef(nil)
	local controlPoints = React.useMemo(function()
		local path2DControlPoints = {}
		local path2DControlPoint = Path2DControlPoint.new()
		path2DControlPoint.Position = UDim2.fromScale(0.35, 0.6)
		path2DControlPoint.RightTangent = UDim2.fromScale(0.1, 0)
		table.insert(path2DControlPoints, path2DControlPoint)
		local path2DControlPoint2 = Path2DControlPoint.new()
		path2DControlPoint2.Position = UDim2.fromScale(0.75, 0.35)
		path2DControlPoint2.LeftTangent = UDim2.fromScale(0, 0.3)
		path2DControlPoint2.RightTangent = UDim2.fromScale(0, -0.2)
		table.insert(path2DControlPoints, path2DControlPoint2)
		local path2DControlPoint3 = Path2DControlPoint.new()
		path2DControlPoint3.Position = UDim2.fromScale(0.45, 0.1)
		path2DControlPoint3.LeftTangent = UDim2.fromScale(0.15, 0)
		path2DControlPoint3.RightTangent = UDim2.fromScale(-0.15, 0)
		table.insert(path2DControlPoints, path2DControlPoint3)
		local path2DControlPoint4 = Path2DControlPoint.new()
		path2DControlPoint4.Position = UDim2.fromScale(-0.05, 0.4)
		path2DControlPoint4.LeftTangent = UDim2.fromScale(0, -0.3)
		path2DControlPoint4.RightTangent = UDim2.fromScale(0, 0.2)
		table.insert(path2DControlPoints, path2DControlPoint4)
		local path2DControlPoint5 = Path2DControlPoint.new()
		path2DControlPoint5.Position = UDim2.fromScale(0.35, 0.6)
		path2DControlPoint5.LeftTangent = UDim2.fromScale(-0.2, 0)
		table.insert(path2DControlPoints, path2DControlPoint5)
		return path2DControlPoints
	end, {})
	local alpha = p.Alpha
	local v2 = (not (alpha < 0.05) and 1 or alpha / 0.05) * (not (alpha - 0.95 > 0) and 1 or 1 - (alpha - 0.95) / 0.05)
	return createElement("Frame", RobloxTypes.mergeFrame({
		Active = false,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, p), {
		Path2D = createElement(Path2D, {
			ref = ref,
			ControlPoints = controlPoints,
			Visible = false,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.THICK,
			Color3 = Color3.new(1, 0, 1)
		}),
		Star = ref.current and createElement(Star, {
			Size = UDim2.new(
				p.StarSize.X.Scale * v2,
				p.StarSize.X.Offset * v2,
				p.StarSize.Y.Scale * v2,
				p.StarSize.Y.Offset * v2
			),
			AnchorPoint = Vector2.new(0.5, 0.55),
			Position = ref.current:GetPositionOnCurve(alpha),
			IsCompleted = true
		})
	})
end

return function(props)
	local _, _, v, v2 = useKeyFrames(props.Mode, props.IsLooping)
	local v3 = math.clamp((v2 - 0.5) / 0.5, 0, 1) * 1.2
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
					v6.fire(`{i}`, 1.25, i * 0.15)
				end
			end)
		end

		return function() end
	end, { v > 0, v5 })
	local children = {}

	for k, alpha in v6.active do
		children[`Star{k}`] = createElement(starPath, {
			Size = UDim2.fromScale(1, 1),
			StarSize = UDim2.fromScale(0.125, 0.125):Lerp(UDim2.fromScale(0, 0), 1 - v),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = alpha > 0.5 and 4 or 0,
			Alpha = alpha
		})
	end

	local mergeImageLabel = RobloxTypes.mergeImageLabel({
		Image = upperskys1.Image,
		ImageRectOffset = upperskys1.ImageRectOffset,
		ImageRectSize = upperskys1.ImageRectSize,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}, props)
	local v9 = {
		FrontCover = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(1, 1),
			Image = upperskys1front.Image,
			ImageRectOffset = upperskys1front.ImageRectOffset,
			ImageRectSize = upperskys1front.ImageRectSize,
			ImageColor3 = props.ImageColor3,
			ZIndex = 4
		}),
		Medal = 0,
		Stars = 0
	}
	local medal

	if v2 > 0 then
		medal = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5 - (1 - v2) * 0.3, 0.7):Lerp(UDim2.fromScale(0.5, 0.1), v2),
			AnchorPoint = Vector2.new(0.5, 0.5 - 0.15 * (1 - v2)),
			Size = UDim2.fromScale(0.1, 0.1):Lerp(UDim2.fromScale(0.5, 0.5), v2),
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
					CONSTANTS.COLOR.DISABLED.TINT,
					(math.clamp(1 - (v2 - 0.5) / 0.5, 0, 1))
				),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			})
		})
	else
		medal = false
	end

	v9.Medal = medal
	v9.Stars = createElement(React.Fragment, {}, children)
	return createElement("ImageLabel", mergeImageLabel, v9)
end