local RunService = game:GetService("RunService")
local uIGradient = script.Parent:WaitForChild("UIGradient")
local total = 0
local size = script.Parent.Size
local rotation = script.Parent.Rotation
RunService.RenderStepped:Connect(function(dt)
	total += dt * 0.5
	local v = total % 1
	local v2 = (total + 0.25) % 1
	local color = Color3.fromHSV(v, 0.8, 1)
	local color2 = Color3.fromHSV(v2, 0.8, 1)
	uIGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color2) })
	local v3 = math.sin(total * 3.141592653589793 * 2 * 1.5) * 0.2 + 1
	script.Parent.Size = UDim2.new(size.X.Scale * v3, size.X.Offset * v3, size.Y.Scale * v3, size.Y.Offset * v3)
	script.Parent.Rotation = rotation + math.cos(total * 3.141592653589793 * 2 * 1.5 * 0.85) * 10
end)