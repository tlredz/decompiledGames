local React = require(game.ReplicatedStorage.Packages.React)

function compare(p: number, p2: number, p3: number)
	if p3 == 0 then
		return p == p2
	end

	return math.abs(p - p2) < p3
end

return function(instance, value: number?)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		if instance then
			local function fn()
				local rect = Rect.new(
					instance.AbsolutePosition.X,
					instance.AbsolutePosition.Y,
					instance.AbsolutePosition.X + instance.AbsoluteSize.X,
					instance.AbsolutePosition.Y + instance.AbsoluteSize.Y
				)

				if not state then
					setState(rect)
					return
				end

				local v = value or 0.0001

				if not (compare(state.Min.X, rect.Min.X, v) and compare(state.Min.Y, rect.Min.Y, v) and compare(
					state.Max.X,
					rect.Max.X,
					v
				) and compare(state.Max.Y, rect.Max.Y, v)) then
					setState(rect)
				end
			end

			local absoluteSizeChangedConnection = instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(fn)
			local absolutePositionChangedConnection = instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(fn)
			fn()
			return function()
				absoluteSizeChangedConnection:Disconnect()
				absolutePositionChangedConnection:Disconnect()
			end
		else
			if state then
				setState(nil)
			end

			return function() end
		end
	end, { instance, state, value })
	return state
end