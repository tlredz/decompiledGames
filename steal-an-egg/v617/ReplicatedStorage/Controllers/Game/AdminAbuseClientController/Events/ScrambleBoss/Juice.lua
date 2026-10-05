local createVector = vector.create
local RunService = game:GetService("RunService")
local Kit = require(script.Parent.Kit)
return {
	Throw = function(instance, p, position: Vector3, p2: number)
		local position2 = instance.Position
		local v = math.max(position2.Y, position.Y) + 55
		local vector2 = Vector3.new(
			(position2.X + position.X) / 2,
			v * 2 - (position2.Y + position.Y) / 2,
			(position2.Z + position.Z) / 2
		)
		local flat = Kit.Flat(position - position2)
		local v2 = not (flat.Magnitude > 0.1) and createVector(1, 0, 0) or (createVector(0, 1, 0)):Cross(flat.Unit)
		local rotation = instance.CFrame.Rotation
		local lastTime = os.clock()
		p.PlatformStand = true
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v3 = math.clamp((os.clock() - lastTime) / p2, 0, 1)
			local v4 = 1 - v3
			local v5 = position2 * (v4 * v4) + vector2 * (v4 * 2 * v3) + position * (v3 * v3)
			instance.AssemblyLinearVelocity = createVector(0, 0, 0)
			instance.AssemblyAngularVelocity = createVector(0, 0, 0)
			instance.CFrame = CFrame.new(v5) * CFrame.fromAxisAngle(v2, v3 * 3.141592653589793 * 4) * rotation

			if v3 >= 1 or instance.Parent == nil or p.Health <= 0 then
				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
				end

				instance.CFrame = CFrame.new(position) * rotation
				instance.AssemblyLinearVelocity = createVector(0, -20, 0)
				p.PlatformStand = false
			end
		end)
	end
}