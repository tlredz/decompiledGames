local CameraUtils = {
	getCubeoidDiameter = function(data)
		return (math.sqrt(data.x ^ 2 + data.y ^ 2 + data.z ^ 2))
	end
}

function CameraUtils.fitBoundingBoxToCamera(p, p2, p3)
	local v = CameraUtils.getCubeoidDiameter(p) / 2
	return CameraUtils.fitSphereToCamera(v, p2, p3)
end

function CameraUtils:GetBoundingBox(instance)
	if not instance then
		return
	end

	if typeof(instance) == "table" then
		local vector = nil
		local vector2 = nil

		for _, v in pairs(instance) do
			local boundingBox, v2 = CameraUtils:GetBoundingBox(v)

			if not (boundingBox and v2) then
				continue
			end

			local v3 = v2 / 2
			local v4 = {
				boundingBox:PointToWorldSpace((Vector3.new(-v3.X, -v3.Y, -v3.Z))),
				boundingBox:PointToWorldSpace((Vector3.new(v3.X, -v3.Y, -v3.Z))),
				boundingBox:PointToWorldSpace((Vector3.new(-v3.X, -v3.Y, v3.Z))),
				boundingBox:PointToWorldSpace((Vector3.new(v3.X, -v3.Y, v3.Z))),
				boundingBox:PointToWorldSpace((Vector3.new(-v3.X, v3.Y, -v3.Z))),
				boundingBox:PointToWorldSpace((Vector3.new(v3.X, v3.Y, -v3.Z))),
				boundingBox:PointToWorldSpace((Vector3.new(-v3.X, v3.Y, v3.Z))),
				boundingBox:PointToWorldSpace((Vector3.new(v3.X, v3.Y, v3.Z)))
			}

			for _, v5 in ipairs(v4) do
				if vector then
					vector = Vector3.new(math.min(vector.X, v5.X), math.min(vector.Y, v5.Y), (math.min(vector.Z, v5.Z)))
					vector2 = Vector3.new(
						math.max(vector2.X, v5.X),
						math.max(vector2.Y, v5.Y),
						(math.max(vector2.Z, v5.Z))
					)
				else
					vector2 = v5
					vector = vector2
					vector2 = vector
				end
			end
		end

		if vector and vector2 then
			return CFrame.new((vector + vector2) / 2), vector2 - vector
		end

		return nil
	else
		if instance:IsA("Model") then
			return instance:GetBoundingBox()
		end

		if instance:IsA("BasePart") then
			return instance.CFrame, instance.Size
		end
	end
end

function CameraUtils.getBoundingBoxOf(items)
	local vector = nil
	local vector2 = nil

	for _, item in pairs(items) do
		local boundingBox, v = CameraUtils:GetBoundingBox(item)

		if not (boundingBox and v) then
			continue
		end

		local v2 = v / 2

		for i = -1, 1, 2 do
			for i2 = -1, 1, 2 do
				for i3 = -1, 1, 2 do
					local v3 = boundingBox * CFrame.new(v2.X * i3, v2.Y * i, v2.Z * i2)

					if vector then
						vector = Vector3.new(
							math.max(vector.X, v3.X),
							math.max(vector.Y, v3.Y),
							(math.max(vector.Z, v3.Z))
						)
					else
						vector = v3
					end

					if vector2 then
						vector2 = Vector3.new(
							math.min(vector2.X, v3.X),
							math.min(vector2.Y, v3.Y),
							(math.min(vector2.Z, v3.Z))
						)
					else
						vector2 = v3
					end
				end
			end
		end
	end

	local midpoint = (vector + vector2) / 2
	local vector3 = Vector3.new(vector.X - vector2.X, vector.Y - vector2.Y, vector.Z - vector2.Z)
	return CFrame.new(midpoint), vector3
end

function CameraUtils.fitSphereToCamera(p, p2, p3)
	local v = math.rad(p2) * 0.5

	if p3 < 1 then
		v = math.atan(p3 * math.tan(v))
	end

	return p / math.sin(v)
end

function CameraUtils.isOnScreen(object, p)
	local _, v = object:WorldToScreenPoint(p)
	return v
end

return CameraUtils