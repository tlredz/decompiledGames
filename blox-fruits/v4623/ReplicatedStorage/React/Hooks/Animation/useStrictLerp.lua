local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
return function(p: number, p2: number, p3: number, p4, p5)
	local state, setState = React.useState(p)
	local ref = React.useRef(p)
	ref.current = state
	local v = useDrawContext() ~= "Offscreen"
	React.useEffect(function()
		local current = ref.current

		if current == p2 then
			return function() end
		end

		if not v or p3 <= 0 then
			setState(p2)
			return function() end
		end

		local v2 = p4 or Enum.EasingStyle.Linear
		local v3 = p5 or Enum.EasingDirection.InOut
		local lastTime = os.clock()
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v4 = math.clamp((os.clock() - lastTime) / p3, 0, 1)

			if v4 >= 1 then
				renderSteppedConnection:Disconnect()
				setState(p2)
			else
				local value = TweenService:GetValue(v4, v2, v3)
				setState(current + (p2 - current) * value)
			end
		end)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end, {
		p2,
		p3,
		p4,
		p5,
		v
	})
	return state
end