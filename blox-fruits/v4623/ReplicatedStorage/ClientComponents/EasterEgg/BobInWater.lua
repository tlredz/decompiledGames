return function(instance, vector: Vector3)
	local GetWaterHeightAtLocation = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)
	local waterHeightAtLocation = GetWaterHeightAtLocation(vector)
	print((`waterHeight={waterHeightAtLocation}`))
	local v2 = tick() + math.random(2, 5)
	local total = 0
	local RunService = game:GetService("RunService")
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt
		local v3 = math.sin(total * 2 * 0.5) * 0.2
		local v4 = math.sin(total * 2) * 0.5
		local v5 = math.sin(total * 2) * 0.08726646259971647
		instance:PivotTo(CFrame.new(vector + Vector3.new(v3, v4, 0)) * CFrame.Angles(0, 0, v5))

		if v2 - tick() <= 0 then
			v2 = tick() + math.random(2, 5)
			local Effect = require(game.ReplicatedStorage.Effect)
			Effect.new("Water.Swim.Idle"):replicate({
				CFrame = CFrame.new(vector.X, waterHeightAtLocation < -30 and waterHeightAtLocation or -4, vector.Z),
				Scale = 1.5,
				Duration = 0.5
			})
		end
	end)
	return function()
		heartbeatConnection:Disconnect()
	end
end