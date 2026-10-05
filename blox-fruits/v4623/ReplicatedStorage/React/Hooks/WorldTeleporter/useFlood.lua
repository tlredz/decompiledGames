local React = require(game.ReplicatedStorage.Packages.React)
local useStrictLerp = require(game.ReplicatedStorage.React.Hooks.Animation.useStrictLerp)
local CONSTANTS = require(game.ReplicatedStorage.React.Components.WorldTeleporter.CONSTANTS)
local FLOOD = CONSTANTS.FLOOD
local frozen = table.freeze({
	Alpha = 0
})

local function getViewport(instance)
	local layerCollector = instance:FindFirstAncestorWhichIsA("LayerCollector")

	if layerCollector then
		return layerCollector.AbsolutePosition, layerCollector.AbsoluteSize
	end

	local currentCamera = workspace.CurrentCamera
	local zero = Vector2.zero

	if currentCamera then
		return zero, currentCamera.ViewportSize
	end

	return zero, Vector2.zero
end

local function solveGeometry(current)
	local parent = current.Parent

	if not (parent and parent:IsA("GuiBase2d")) then
		return nil
	end

	local layerCollector = current:FindFirstAncestorWhichIsA("LayerCollector")
	local absolutePosition, absoluteSize

	if layerCollector then
		absolutePosition = layerCollector.AbsolutePosition
		absoluteSize = layerCollector.AbsoluteSize
	else
		local currentCamera = workspace.CurrentCamera
		absolutePosition = Vector2.zero

		if currentCamera then
			absoluteSize = currentCamera.ViewportSize
		else
			absoluteSize = Vector2.zero
		end
	end

	local v = current.AbsolutePosition + current.AbsoluteSize / 2
	local v2 = 0

	for _, v3 in {
		absolutePosition,
		absolutePosition + Vector2.new(absoluteSize.X, 0),
		absolutePosition + Vector2.new(0, absoluteSize.Y),
		absolutePosition + absoluteSize
	} do
		v2 = math.max(v2, (v3 - v).Magnitude)
	end

	local v3 = (v2 * 2 + FLOOD.MARGIN) / CONSTANTS.BACKGROUND_SCALE
	local v4 = absolutePosition - parent.AbsolutePosition
	return table.freeze({
		Center = v - parent.AbsolutePosition,
		StartSize = current.AbsoluteSize,
		EndSize = Vector2.new(v3, v3),
		Viewport = table.freeze({
			Position = UDim2.fromOffset(v4.X, v4.Y),
			Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)
		})
	})
end

return function(p, flag: boolean, value: number?)
	local state, setState = React.useState(nil)
	local alpha = useStrictLerp(0, state and 1 or 0, FLOOD.DURATION, FLOOD.EASING_STYLE, FLOOD.EASING_DIRECTION)
	React.useEffect(function()
		local current = p.current

		if flag and current then
			setState(solveGeometry(current))
		elseif not flag then
			setState(nil)
		end
	end, { flag })
	local v2 = math.max(1 - (value or 0), 0)
	return React.useMemo(function()
		if not state then
			return frozen
		end

		local v3 = state.StartSize:Lerp(state.EndSize, alpha) * v2
		return (table.freeze({
			Alpha = alpha,
			Size = UDim2.fromOffset(v3.X, v3.Y),
			Position = UDim2.fromOffset(state.Center.X, state.Center.Y),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Viewport = state.Viewport
		}))
	end, { state, alpha, v2 })
end