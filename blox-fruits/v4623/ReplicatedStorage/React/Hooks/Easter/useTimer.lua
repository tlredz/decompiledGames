local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
return function(p: number, p2: number)
	local state, setState = React.useState(0)
	React.useEffect(function()
		local total = 1

		local function fn()
			local unixTimestamp = DateTime.now().UnixTimestamp
			local v

			if unixTimestamp < p then
				v = p
			else
				v = p2
			end

			return (math.max(0, v - unixTimestamp))
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			if total >= 0.2 then
				total = 0
				setState(fn)
			end

			total += dt
		end)
		return function()
			heartbeatConnection:Disconnect()
		end
	end, { p, p2 })
	return state
end