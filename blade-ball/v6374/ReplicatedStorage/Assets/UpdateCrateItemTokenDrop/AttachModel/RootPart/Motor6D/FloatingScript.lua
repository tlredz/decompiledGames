local parent = script.Parent
local RunService = game:GetService("RunService")
local total = 0
local v = 0
local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
	total += 1.5707963267948966 * dt
	v = math.sin(os.clock() * 1) * 0.5
	parent.C0 = CFrame.new(0, v, 0) * CFrame.Angles(0, total, 0)
end)
local ancestryChangedConnection = nil
ancestryChangedConnection = script.Parent.AncestryChanged:Connect(function()
	if not script.Parent then
		if ancestryChangedConnection then
			ancestryChangedConnection:Disconnect()
			ancestryChangedConnection = nil
		end

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end
end)