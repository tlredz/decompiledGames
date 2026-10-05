local RunService = game:GetService("RunService")
local parent = script.Parent
local total = 0
RunService.RenderStepped:Connect(function(dt)
	total += 18 * dt
	parent.Rotation = total % 360
end)