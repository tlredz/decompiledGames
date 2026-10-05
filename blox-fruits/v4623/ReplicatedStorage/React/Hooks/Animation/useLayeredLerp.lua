local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
return function(p: number, target: number, duration: number, p4, p5)
	local state, setState = React.useState(p)
	local state2, setState2 = React.useState(p)
	local state3, setState3 = React.useState((table.freeze({})))
	React.useEffect(function()
		local clone = table.clone(state3)
		local v = {
			Target = target,
			Duration = duration,
			StartedAt = tick(),
			EasingStyle = p4 or Enum.EasingStyle.Linear,
			EasingDirection = p5 or Enum.EasingDirection.InOut
		}
		table.freeze(v)
		table.insert(clone, v)
		table.freeze(clone)

		if #clone == 1 then
			setState2(state)
		end

		setState3(clone)
	end, {
		target,
		duration,
		p4,
		p5
	})
	React.useEffect(function()
		if #state3 == 0 then
			return function() end
		end

		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function(_: number)
			local now = tick()
			local v = state2
			local count = 0

			for _, v2 in state3 do
				local v3 = math.clamp((now - v2.StartedAt) / v2.Duration, 0, 1)

				if v3 == 1 then
					count += 1
				end

				local value = TweenService:GetValue(v3, v2.EasingStyle, v2.EasingDirection)
				v += (v2.Target - v) * value
			end

			if count == #state3 then
				setState3(table.freeze({}))
				renderSteppedConnection:Disconnect()
			end

			setState(v)
		end)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end, { state3, state2 })
	return state
end