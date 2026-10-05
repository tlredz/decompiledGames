local createVector = vector.create
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
return function(data)
	local pos = data.Pos or createVector(0, 0, 0)
	local quantity = data.Quantity or 20
	local properties = data.Properties or {}
	local offsets = data.Offsets or {
		X = { -10, 10 },
		Y = { 0, 10 },
		Z = { -10, 10 },
		Offset = { 10, 20 }
	}
	local goal = data.Goal or {}

	for _ = 1, quantity do
		local clone = script.Orb:Clone()

		for k, property in next, properties, nil do
			clone[k] = property
		end

		local v = pos + Vector3.new(
			math.random(offsets.X[1], offsets.X[2]),
			math.random(offsets.Y[1], offsets.Y[2]),
			math.random(offsets.Z[1], offsets.Z[2])
		)
		clone.CFrame = CFrame.lookAt(v, v - createVector(0, 5, 0))
		clone.Parent = workspace._WorldOrigin
		goal.CFrame = clone.CFrame * CFrame.new(0, 0, math.random(offsets.Offset[1], offsets.Offset[2]))
		local number = Random.new():NextNumber(0.3, 1)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(number, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
			goal
		)
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
	end
end