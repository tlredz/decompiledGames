local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
return function(flag: boolean, p: number)
	local state, setState = React.useState(0)
	local v = useDrawContext()
	React.useEffect(function()
		if not flag then
			setState(0)
			return
		end

		if v == "Offscreen" then
			setState(p)
			return
		end

		setState(0)
		local lastTime = tick()
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v2 = math.min(tick() - lastTime, p)
			setState(v2)

			if p <= v2 then
				renderSteppedConnection:Disconnect()
			end
		end)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end, { flag, p, v ~= "Offscreen" })
	return state
end