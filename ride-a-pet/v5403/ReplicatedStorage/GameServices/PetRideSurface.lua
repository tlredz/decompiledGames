local createVector = vector.create
local PetRideSurface = {}

function PetRideSurface.Headroom(object, p, p2)
	local v = math.max(0.5, math.min(p.Size.X, p.Size.Z) * 0.45)
	return object:Spherecast(p.Position, v, createVector(0, 12, 0), p2) == nil
end

function PetRideSurface.Ground(object, instance, p, p2, p3, p4)
	local v = p2 * createVector(1, 0, 1) * math.min(p3, 0.15)

	if v.Magnitude > 8 then
		v = v.Unit * 8
	end

	local v2 = math.clamp(math.min(instance.Size.X, instance.Size.Z) * 0.4, 0.4, 1.2)
	local v3 = instance.Position + v
	local v4 = instance.CFrame.RightVector * createVector(1, 0, 1)
	local unit = v4.Magnitude > 0.01 and v4.Unit or createVector(1, 0, 0)
	local raycastResults = {}

	for _, v5 in { createVector(0, 0, 0), unit * v2, -unit * v2 } do
		local raycastResult = object:Raycast(v3 + v5 + createVector(0, 2, 0), createVector(-0, -1, -0) * (p + 16), p4)

		if not raycastResult or raycastResult.Normal.Y < 0.5 then
			return nil
		end

		table.insert(raycastResults, raycastResult)
	end

	local Y = raycastResults[1].Position.Y

	if v2 < v.Magnitude then
		local raycastResult = object:Raycast(
			instance.Position + createVector(0, 2, 0),
			createVector(-0, -1, -0) * (p + 16),
			p4
		)

		if not raycastResult or raycastResult.Normal.Y < 0.5 or math.abs(raycastResult.Position.Y - Y) > 2 then
			return nil
		end
	end

	for _, v5 in raycastResults do
		if math.abs(v5.Position.Y - Y) > 2 then
			return nil
		end
	end

	return raycastResults[1], instance.Position.Y - Y - p
end

function PetRideSurface.Slide(object, p, vector2, p2, p3)
	if vector2.Magnitude < 0.01 then
		return vector2
	end

	local v = math.max(0.5, math.min(p.Size.X, p.Size.Z) * 0.45)
	local v2 = vector2 * math.min(p2, 0.25)
	local spherecast = object:Spherecast(p.Position, v, v2, p3)

	if not spherecast then
		return vector2
	end

	local dot = vector2:Dot(spherecast.Normal)

	if dot >= 0 then
		return vector2
	end

	local v3 = math.min(-dot, math.max(spherecast.Distance - 0.15, 0) / math.max(p2, 0.004166666666666667))
	return vector2 - spherecast.Normal * (dot + v3)
end

function PetRideSurface.InitialRideMode(object, folder, object2, instance, options)
	if object2:GetState() == Enum.HumanoidStateType.Jumping and instance.AssemblyLinearVelocity.Y > 1 then
		return "Fly"
	end

	if object2.FloorMaterial ~= Enum.Material.Air then
		return "Walk"
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local filterDescendantsInstances = { folder }

	for _, v2 in options or {} do
		table.insert(filterDescendantsInstances, v2)
	end

	for _, noCollisionConstraint in folder:GetDescendants() do
		if noCollisionConstraint:IsA("NoCollisionConstraint") and noCollisionConstraint.Name == "VolcanoShellBypass" and noCollisionConstraint.Part1 then
			table.insert(filterDescendantsInstances, noCollisionConstraint.Part1)
		end
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.RespectCanCollide = true
	raycastParams.IgnoreWater = true
	raycastParams.CollisionGroup = instance.CollisionGroup
	local v2 = object2.HipHeight + instance.Size.Y / 2

	if object2.RigType == Enum.HumanoidRigType.R6 then
		local leftLeg = folder:FindFirstChild("Left Leg")
		v2 += leftLeg and leftLeg.Size.Y or 2
	end

	local raycastResult = object:Raycast(instance.Position, createVector(-0, -1, -0) * (v2 + 0.5), raycastParams)

	if raycastResult and raycastResult.Normal.Y >= 0.5 then
		return "Walk"
	end

	return "Fly"
end

return PetRideSurface