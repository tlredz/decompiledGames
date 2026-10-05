local RunService = game:GetService("RunService")
local uIGradient = script.Parent:WaitForChild("UIGradient")
local total = 0
RunService.RenderStepped:Connect(function(dt)
	total += dt * 0.1
	local v = total % 1
	local v2 = (total + 0.05) % 1
	local color = Color3.fromHSV(v, 0.8, 1)
	local color2 = Color3.fromHSV(v2, 0.8, 1)
	uIGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color2) })
end)