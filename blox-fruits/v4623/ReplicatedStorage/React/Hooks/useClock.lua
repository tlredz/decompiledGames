local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage.Packages.React)
return function()
	local v, v2 = React.useBinding(0)
	React.useEffect(function()
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			v2(v:getValue() + dt)
		end)
		return function()
			heartbeatConnection:Disconnect()
		end
	end, {})
	return v
end