local v = { script.Parent.Spin1, script.Parent.Spin2, script.Parent.Spin3 }
local heartbeatConnection = nil
local RunService = game:GetService("RunService")
heartbeatConnection = RunService.Heartbeat:Connect(function(_: number)
	if script:IsDescendantOf(game) == false then
		heartbeatConnection:Disconnect()
		return
	end

	for i, v2 in ipairs(v) do
		v2.WorldCFrame = CFrame.Angles(0, 7 * time() * (i % 2 == 0 and -1 or 1), 0) + v2.WorldCFrame.Position
	end
end)