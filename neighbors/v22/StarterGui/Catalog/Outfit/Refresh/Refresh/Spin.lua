local RunService = game:GetService("RunService")
RunService.Heartbeat:connect(function(p: number)
	script.Parent.Rotation += -p * 40
end)