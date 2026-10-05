local RunService = game:GetService("RunService")
local visible = script.Parent.Visible
local heartbeatConnection = nil

local function update()
	visible = script.Parent.Visible

	if visible then
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			script.Parent.Rotation += dt * script.Parent.SpinSpeed.Value
		end)
		return
	end

	heartbeatConnection:Disconnect()
	heartbeatConnection = nil
end

script.Parent:GetPropertyChangedSignal("Visible"):Connect(update)
visible = script.Parent.Visible

if visible then
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		script.Parent.Rotation += dt * script.Parent.SpinSpeed.Value
	end)
else
	heartbeatConnection:Disconnect()
	heartbeatConnection = nil
end