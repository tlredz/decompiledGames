local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local util = ReplicatedStorage.Util
local Tween = require(util.Tween)

function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

return function(list)
	local v, v2, v3, v4, v5 = unpack(list)
	local position = v3.Position
	local position2 = typeof(v2) == "Vector3" and v2 or v2.Position
	local magnitude = (position - position2).Magnitude
	local lastTime = tick()

	while tick() - lastTime < v4 do
		local sine = Tween.ease.inout.sine(tick() - lastTime, 0, 1, v4)
		position2 = typeof(v2) == "Vector3" and v2 or v2.Position
		v3.Position = position:Lerp(position2, sine) + v.CFrame.RightVector * magnitude * math.sin(3.141592653589793 * sine) + Vector3.new(
			0,
			magnitude * math.sin(3.141592653589793 * sine)
		)
		RunService.RenderStepped:Wait()
	end

	if typeof(v2) == "Instance" then
		while v5.Parent and not v5.Value and v2.Parent do
			v3.Position = v2.Position
			RunService.RenderStepped:Wait()
		end
	else
		for _ = 1, 60 do
			v3.Position = position2
			RunService.RenderStepped:Wait()
		end
	end
end