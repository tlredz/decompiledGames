local createVector = vector.create
local RunService = game:GetService("RunService")
local _ = {
	DURATION = 2.5,
	INTENSITY = 1.5,
	FREQUENCY = 0.03
}
return {
	Run = function(player)
		local character = player.Character

		if not character then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			return
		end

		task.spawn(function()
			local lastTime = os.clock()
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local v = os.clock() - lastTime

				if v >= 2.5 then
					humanoid.CameraOffset = createVector(0, 0, 0)
					renderSteppedConnection:Disconnect()
				else
					local v2 = 1.5 * (1 - v / 2.5)
					humanoid.CameraOffset = Vector3.new(
						(math.random() - 0.5) * 2 * v2,
						(math.random() - 0.5) * 2 * v2,
						(math.random() - 0.5) * 2 * v2 * 0.3
					)
				end
			end)
		end)
	end
}