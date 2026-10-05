local RunService = game:GetService("RunService")
local v = 0.016666666666666666

if RunService:IsServer() then
	RunService.Heartbeat:Connect(function(dt)
		v = dt
	end)
else
	RunService.RenderStepped:Connect(function(dt)
		v = dt
	end)
end

return function()
	return v
end