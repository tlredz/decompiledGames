local createVector = vector.create
local RunService = game:GetService("RunService")
local RideCollisionGuard = {
	RemoveIntoSurface = function(vector2, unit)
		if math.abs(unit.Y) < 0.7 then
			local vector3 = Vector3.new(unit.X, 0, unit.Z)

			if vector3.Magnitude < 0.001 then
				return vector2
			else
				unit = vector3.Unit
			end
		end

		local dot = vector2:Dot(unit)

		if dot < 0 then
			vector2 = vector2 - unit * dot or vector2
		end

		return vector2
	end
}

function RideCollisionGuard.Attach(p, p2, instance, object, instance2)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { p, p2 }
	raycastParams.RespectCanCollide = true
	raycastParams.IgnoreWater = true
	local position = instance.Position
	local assemblyLinearVelocity = instance.AssemblyLinearVelocity
	local v = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function FlightActive()
		return instance2 and instance2.Parent and instance2.Enabled
	end

	local function Active()
		return v and instance.Parent and p.Parent and object.Health > 0
	end

	local function Sweep(position2, p3)
		local magnitude = p3.Magnitude

		if magnitude < 0.001 then
			return nil
		end

		raycastParams.CollisionGroup = instance.CollisionGroup
		local v2 = math.max(instance.Size.X, instance.Size.Z)
		local vector2 = Vector3.new(
			math.max(v2 - 0.1, 0.5),
			math.max(instance.Size.Y - 0.1, 0.5),
			(math.max(v2 - 0.1, 0.5))
		)
		local v3 = p3 / magnitude
		local total = 0

		while total < magnitude do
			local v4 = math.min(magnitude - total, 512)
			local blockcast = workspace:Blockcast(CFrame.new(position2 + v3 * total), vector2, v3 * v4, raycastParams)

			if blockcast then
				if blockcast.Normal.Y > 0.55 then
					return nil
				end

				return blockcast, total + blockcast.Distance
			else
				total += v4
			end
		end

		return nil
	end

	local preSimulationConnection = RunService.PreSimulation:Connect(function(dt)
		if not (v and instance.Parent and p.Parent and object.Health > 0) then
			return
		end

		position = instance.Position
		assemblyLinearVelocity = instance.AssemblyLinearVelocity
		local vectorVelocity = FlightActive() and instance2.VectorVelocity or assemblyLinearVelocity
		local v2 = vectorVelocity * math.min(dt, 0.1)
		local v3, v4 = Sweep(position, v2)

		if v3 then
			local v5 = math.min(1, math.max(0, v4 - 0.15) / math.max(v2.Magnitude, 0.001))
			local v6 = RideCollisionGuard.RemoveIntoSurface(vectorVelocity, v3.Normal)
			local vectorVelocity2 = v6 + (vectorVelocity - v6) * v5
			instance.AssemblyLinearVelocity = RideCollisionGuard.RemoveIntoSurface(assemblyLinearVelocity, v3.Normal)

			if FlightActive() then
				instance2.VectorVelocity = vectorVelocity2
			end
		end
	end)
	local postSimulationConnection = RunService.PostSimulation:Connect(function(dt)
		if not (v and instance.Parent and p.Parent and object.Health > 0) then
			return
		end

		local v2 = instance.Position - position
		local v3, v4

		if math.max(128, assemblyLinearVelocity.Magnitude * math.max(dt, 0.016) * 4 + 32) >= v2.Magnitude then
			v3, v4 = Sweep(position, v2)
		end

		local assemblyLinearVelocity2 = instance.AssemblyLinearVelocity

		if v3 then
			local v5 = position + v2.Unit * math.max(0, v4 - 0.15)
			instance.CFrame = CFrame.new(v5) * instance.CFrame.Rotation
			local v6 = RideCollisionGuard.RemoveIntoSurface(assemblyLinearVelocity2, v3.Normal)
			local v7 = math.max(assemblyLinearVelocity.Y, 0)

			if object:GetState() == Enum.HumanoidStateType.Jumping then
				v7 = math.max(
					v7,
					object.UseJumpPower and object.JumpPower or math.sqrt(2 * workspace.Gravity * object.JumpHeight)
				)
			end

			if FlightActive() then
				v7 = math.max(v7, instance2.VectorVelocity.Y)
				instance2.VectorVelocity = RideCollisionGuard.RemoveIntoSurface(instance2.VectorVelocity, v3.Normal)
			end

			assemblyLinearVelocity2 = Vector3.new(v6.X, math.min(v6.Y, v7), v6.Z)
			instance.AssemblyAngularVelocity = createVector(0, 0, 0)
		end

		local jumpPower = object.UseJumpPower and object.JumpPower or math.sqrt(2 * workspace.Gravity * object.JumpHeight)
		local v5 = FlightActive() and math.max(30, instance2.VectorVelocity.Y) + 10 or jumpPower + 10

		if v5 < assemblyLinearVelocity2.Y then
			assemblyLinearVelocity2 = Vector3.new(assemblyLinearVelocity2.X, v5, assemblyLinearVelocity2.Z)
		end

		if assemblyLinearVelocity2 ~= instance.AssemblyLinearVelocity then
			instance.AssemblyLinearVelocity = assemblyLinearVelocity2
		end

		position = instance.Position
	end)
	return {
		Disconnect = function()
			v = false
			preSimulationConnection:Disconnect()
			postSimulationConnection:Disconnect()
		end
	}
end

return RideCollisionGuard