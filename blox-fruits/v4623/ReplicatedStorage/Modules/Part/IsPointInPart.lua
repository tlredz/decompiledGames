local createVector = vector.create
return function(vector2: Vector3, instance, vector3: Vector3?)
	if typeof(vector2) ~= "Vector3" then
		error("Vector3 is invalid")
	end

	if typeof(instance) ~= "Instance" then
		error("Part is invalid")
	end

	local v = vector3 or createVector(0, 0, 0)

	if instance.Shape == Enum.PartType.Block then
		local v2 = CFrame.fromMatrix(
			instance.CFrame.Position,
			instance.CFrame.XVector / (instance.Size.X + v.X),
			instance.CFrame.YVector / (instance.Size.Y + v.Y),
			instance.CFrame.ZVector / (instance.Size.Z + v.Z)
		):Inverse() * vector2
		return math.abs(v2.X) <= 0.5 and math.abs(v2.Y) <= 0.5 and math.abs(v2.Z) <= 0.5
	elseif instance.Shape == Enum.PartType.Ball then
		local vector4 = Vector3.new(
			vector2.X - instance.Position.X,
			vector2.Y - instance.Position.Y,
			vector2.Z - instance.Position.Z
		)
		local dot = vector4:Dot(vector4)
		local v2 = math.min(instance.Size.X + v.X, (math.min(instance.Size.Y + v.Y, instance.Size.Z + v.Z)))
		return dot <= v2 * v2 * 0.25
	else
		if instance.Shape ~= Enum.PartType.Cylinder then
			error("Invalid Shape Type")
			return false
		end

		local pointToObjectSpace = instance.CFrame:PointToObjectSpace(vector2)

		if not (math.abs(pointToObjectSpace.X) <= (instance.Size.X + v.X) / 2) then
			return false
		end

		local vector4 = Vector2.new(pointToObjectSpace.Y, pointToObjectSpace.Z)
		local dot = vector4:Dot(vector4)
		local v2 = math.min(instance.Size.Y + v.Y, instance.Size.Z + v.Z) * 0.5
		return dot <= v2 * v2
	end
end