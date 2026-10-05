local RunService = game:GetService("RunService")
local parent = script.Parent
local loading = parent:WaitForChild("Loading")
local heartbeatConnection = nil
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if parent.Visible == false then
		return
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		loading.Rotation += 2
	end)
end)