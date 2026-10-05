local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local Spring = require(game.ReplicatedStorage.Packages.Spring)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
return function(p: number, p2: number, p3: number, p4: number)
	local state, setState = React.useState(p)
	local ref = React.useRef(0)
	local v = useDrawContext()
	React.useEffect(function()
		if v == "Offscreen" then
			if p2 ~= state and p2 == p2 then
				setState(p2)
				ref.current = 0
			end

			return function() end
		else
			local v2 = Spring.new(p3, p4, state)
			v2.Velocity = ref.current
			v2:Set(p2)
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
				v2:Step(dt)
				ref.current = v2.Velocity
				local v3 = v2:Get()

				if math.abs(v2.Velocity) <= 1e-7 and math.abs(p2 - v3) <= 1e-7 then
					v3 = p2
					ref.current = 0
					renderSteppedConnection:Disconnect()
				end

				setState(v3)
			end)
			return function()
				renderSteppedConnection:Disconnect()
			end
		end
	end, {
		p2,
		p4,
		p3,
		v ~= "Offscreen"
	})
	return state
end