local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")
return function(list)
	local v, v2, v3 = unpack(list)
	TweenService:Create(v, TweenInfo.new(v3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = createVector(0.005, 0.003, 0.005) * v2
	}):Play()
end