local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local createElement = React.createElement
return function(data)
	local itemProperties = data.ItemProperties
	local itemConstructor = data.ItemConstructor
	local v = data[React.Change.AbsoluteWindowSize]
	local v2 = data[React.Change.CanvasPosition]
	local clone = table.clone(data)
	clone[React.Change.AbsoluteWindowSize] = nil
	clone[React.Change.CanvasPosition] = nil
	local state, setState = React.useState(Vector2.new(0, 0))
	local state2, setState2 = React.useState(Vector2.new(0, 0))
	local v3 = typeof(data.CanvasPosition) == "Vector2"

	if typeof(data.CanvasPosition) == "Vector2" then
		state2 = data.CanvasPosition
	end

	local windowRegionPx = React.useMemo(function()
		return Rect.new(state2.X, state2.Y, state2.X + state.X, state2.Y + state.Y)
	end, { state, state2 })
	local clone2 = table.clone(itemProperties)
	clone2.WindowRegionPx = windowRegionPx
	return createElement("ScrollingFrame", RobloxTypes.mergeScrollingFrame({
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		[React.Change.AbsoluteWindowSize] = function(p)
			setState(p.AbsoluteWindowSize)

			if v then
				v(p, p.AbsoluteWindowSize)
			end
		end,
		[React.Change.CanvasPosition] = function(p)
			if not v3 then
				setState2(p.CanvasPosition)
			end

			if v2 then
				v2(p, p.CanvasPosition)
			end
		end
	}, clone), {
		Content = createElement(itemConstructor, clone2)
	})
end