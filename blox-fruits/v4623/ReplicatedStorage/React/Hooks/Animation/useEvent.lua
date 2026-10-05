local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)

function resolveRange(p)
	if typeof(p) ~= "NumberRange" then
		return p
	end

	if p.Max == p.Min then
		return p.Min
	end

	return (math.clamp(p.Min + math.random() * (p.Max - p.Min), p.Min, p.Max))
end

return function()
	local state, setState = React.useState((table.freeze({})))
	local ref = React.useRef(0)
	local useRef = React.useRef(state)
	useRef.current = state
	local state2, setState2 = React.useState((table.freeze({})))
	local ref2 = React.useRef(0)
	local ref3 = React.useRef(state2)
	ref3.current = state2
	React.useEffect(function()
		if ref2.current == 0 then
			return function() end
		end

		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function(_: number)
			local now = tick()
			local count = 0
			local v = {}
			local count2 = 0

			for k, v2 in ref3.current do
				if now < v2.StartAt then
					count += 1
				elseif now < v2.StartAt + v2.Duration then
					v[k] = v2
					count2 += 1
				end
			end

			if count + count2 == 0 then
				renderSteppedConnection:Disconnect()
				ref2.current = 0
				setState2(table.freeze({}))
			elseif count2 == 0 then
				if ref.current > 0 then
					setState(table.freeze({}))
				end
			else
				local count3 = 0
				local v2 = {}

				for k, v3 in v do
					count3 += 1
					v2[k] = math.clamp((now - v3.StartAt) / v3.Duration, 0, 1)
				end

				ref.current = count3
				table.freeze(v2)
				setState(v2)
			end
		end)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end, { ref2.current > 0 })
	return table.freeze({
		active = state,
		fire = function(p, p2, p3)
			local frozen = table.freeze({
				Duration = resolveRange(p2),
				StartAt = tick() + (type(p3) == "nil" and 0 or resolveRange(p3))
			})
			local clone = table.clone(ref3.current)
			clone[p] = frozen
			table.freeze(clone)
			local count = 0

			for _, _ in clone do
				count += 1
			end

			ref2.current = count
			ref3.current = clone
			setState2(clone)
		end
	})
end