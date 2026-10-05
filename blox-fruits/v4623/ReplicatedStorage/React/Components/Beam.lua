local React = require(game.ReplicatedStorage.Packages.React)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement

function segment(props)
	return createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = props.Texture,
		ImageColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		ImageTransparency = CONSTANTS.ALPHA.OPAQUE
	}, props), {
		UIGradient = (props.TextureTransparency or props.TextureColor) and createElement("UIGradient", {
			Rotation = 90,
			Transparency = props.TextureTransparency,
			Color = props.TextureColor
		})
	})
end

return function(props)
	local v = props.Axis == Enum.Axis.X
	local state, setState = React.useState(Vector2.zero)
	local X

	if v then
		X = state.X
	else
		X = state.Y
	end

	local Y

	if v then
		Y = state.Y
	else
		Y = state.X
	end

	local v2 = {}
	local textureSpeed = math.abs(props.TextureSpeed or 0)
	local v3

	if props.TextureMode == Enum.TextureMode.Wrap or props.TextureMode == Enum.TextureMode.Static then
		v3 = math.max(props.TextureLength or 1, X / 40, 1) / math.max(X, 1)
	else
		v3 = 1 / (props.TextureLength or 1)
	end

	local v4 = math.max(math.round(1 / v3), 2)
	local v5 = usePeriod(textureSpeed ~= 0, (textureSpeed == 0 and 1 or 1 / textureSpeed) / math.max(v4, 1))
	local _ = (props.TextureSpeed or 0) < 0
	local v6 = -1

	for i = 0, v4 do
		local v7

		if v6 == 1 then
			v7 = v3 * (i - 1 + v5)
		else
			v7 = v3 * (i - v5)
		end

		local v8 = X * v3
		local formatted = `Segment{i}`
		local segment2 = segment
		local anchorPoint

		if v then
			anchorPoint = Vector2.new(0, 0.5)
		else
			anchorPoint = Vector2.new(0.5, 0)
		end

		local v10 = {
			AnchorPoint = anchorPoint,
			Size = UDim2.fromOffset(Y, v8),
			Rotation = props.Axis == Enum.Axis.X and 90 or 0,
			Position = 0,
			Axis = 0,
			Texture = 0
		}
		local position

		if v then
			position = UDim2.fromScale(v7, 0.5)
		else
			position = UDim2.fromScale(0.5, v7)
		end

		v10.Position = position
		v10.Axis = props.Axis
		v10.Texture = props.Texture
		v2[formatted] = createElement(segment2, v10)
	end

	return createElement("CanvasGroup", RobloxTypes.mergeCanvasGroup({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		ClipsDescendants = true,
		[React.Change.AbsoluteSize] = function(p)
			if state ~= p.AbsoluteSize then
				setState(p.AbsoluteSize)
			end
		end
	}, props), {
		Children = createElement(React.Fragment, {}, props.children),
		Segments = createElement(React.Fragment, {}, v2)
	})
end