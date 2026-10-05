local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
return function(p: number, p2: number, p3: number)
	local state, setState = React.useState(p)
	React.useEffect(function()
		if state == p2 then
			return function() end
		end

		local renderSteppedConnection = nil
		local v = state
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
			if p2 == v then
				renderSteppedConnection:Disconnect()
				return
			end

			local v2 = dt * math.sign(p2 - v) / p3
			v = math.clamp(v + v2, 0, 1)
			setState(v)
		end)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end, { p2, p3 })
	return state
end