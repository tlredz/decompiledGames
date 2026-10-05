local PartUtility = {
	RaycastToFront = function(cframe: CFrame, vector: Vector3, cframe2: CFrame)
		local v = (cframe2 * CFrame.new(0, 0, -vector.Z / 2)):Inverse() * cframe
		local lookVector = v.LookVector
		local v2 = math.atan2((lookVector.X ^ 2 + lookVector.Y ^ 2) ^ 0.5, lookVector.Z)
		local v3 = v.Z / math.cos(v2)
		local position = (v * CFrame.new(0, 0, v3)).Position
		return 1 - (0.5 + position.X / vector.X), 1 - (0.5 + position.Y / vector.Y), -v.Z * (1 / lookVector.Z)
	end,
	ProjectToFront = function(position: Vector3, vector: Vector3, cframe: CFrame)
		local v = (cframe * CFrame.new(0, 0, -vector.Z / 2)):Inverse() * CFrame.new(position)
		return 1 - (0.5 + v.X / vector.X), 1 - (0.5 + v.Y / vector.Y), -v.Z
	end
}

function PartUtility.Raycast(instance, cframe: CFrame, p)
	local size = instance.Size

	if p == Enum.NormalId.Front or p == "Front" then
		return PartUtility.RaycastToFront(cframe, size, instance.CFrame)
	end

	if p == Enum.NormalId.Back or p == "Back" then
		return PartUtility.RaycastToFront(cframe, size, instance.CFrame * CFrame.Angles(0, 3.141592653589793, 0))
	end

	if p == Enum.NormalId.Top or p == "Top" then
		local raycastToFront, v, v2 = PartUtility.RaycastToFront(
			cframe,
			Vector3.new(size.X, size.Z, size.Y),
			instance.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
		)
		return 1 - raycastToFront, v, v2
	end

	if p == Enum.NormalId.Bottom or p == "Bottom" then
		local raycastToFront, v, v2 = PartUtility.RaycastToFront(
			cframe,
			Vector3.new(size.X, size.Z, size.Y),
			instance.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
		)
		return raycastToFront, 1 - v, v2
	end

	if p == Enum.NormalId.Left or p == "Left" then
		return PartUtility.RaycastToFront(
			cframe,
			Vector3.new(size.Z, size.Y, size.X),
			instance.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
		)
	end

	if p == Enum.NormalId.Right or p == "Right" then
		return PartUtility.RaycastToFront(
			cframe,
			Vector3.new(size.Z, size.Y, size.X),
			instance.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
		)
	end

	error("Unknown face type: " .. tostring(p))
end

function PartUtility.Project(instance, vector: Vector3, p)
	local size = instance.Size

	if p == Enum.NormalId.Front or p == "Front" then
		return PartUtility.ProjectToFront(vector, size, instance.CFrame)
	end

	if p == Enum.NormalId.Back or p == "Back" then
		return PartUtility.ProjectToFront(vector, size, instance.CFrame * CFrame.Angles(0, 3.141592653589793, 0))
	end

	if p == Enum.NormalId.Top or p == "Top" then
		local projectToFront, v, v2 = PartUtility.ProjectToFront(
			vector,
			Vector3.new(size.X, size.Z, size.Y),
			instance.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
		)
		return 1 - projectToFront, v, v2
	end

	if p == Enum.NormalId.Bottom or p == "Bottom" then
		local projectToFront, v, v2 = PartUtility.ProjectToFront(
			vector,
			Vector3.new(size.X, size.Z, size.Y),
			instance.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
		)
		return projectToFront, 1 - v, v2
	end

	if p == Enum.NormalId.Left or p == "Left" then
		return PartUtility.ProjectToFront(
			vector,
			Vector3.new(size.Z, size.Y, size.X),
			instance.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
		)
	end

	if p == Enum.NormalId.Right or p == "Right" then
		return PartUtility.ProjectToFront(
			vector,
			Vector3.new(size.Z, size.Y, size.X),
			instance.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
		)
	end

	error("Unknown face type: " .. tostring(p))
end

return PartUtility