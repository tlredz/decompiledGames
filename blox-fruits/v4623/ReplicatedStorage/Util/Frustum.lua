function planeFromPoints(vector: Vector3, vector2: Vector3, vector3: Vector3)
	local unit = (vector2 - vector):Cross(vector3 - vector2).Unit
	local v = {
		Normal = unit,
		Distance = -unit:Dot(vector)
	}
	table.freeze(v)
	return v
end

local Frustum = {}

function Frustum.sphereInFrustum(items, vector: Vector3, p: number)
	for _, item in items do
		if vector:Dot(item.Normal) + item.Distance + p <= 0 then
			return false
		end
	end

	return true
end

function Frustum.fromCamera(data, p: number)
	local v = data.ViewportSize.X / data.ViewportSize.Y
	local v2 = math.rad(data.FieldOfView / 2)
	local v3 = math.tan(v2) * 2 * p / 2
	local v4 = v3 * v
	local v5 = math.tan(v2) * 2 * -data.NearPlaneZ / 2
	local v6 = v5 * v
	local v7 = data.CFrame * Vector3.new(-v4, v3, -p)
	local v8 = data.CFrame * Vector3.new(v4, v3, -p)
	local v9 = data.CFrame * Vector3.new(v4, -v3, -p)
	local v10 = data.CFrame * Vector3.new(-v6, v5, data.NearPlaneZ)
	local v11 = data.CFrame * Vector3.new(v6, v5, data.NearPlaneZ)
	local v12 = data.CFrame * Vector3.new(-v6, -v5, data.NearPlaneZ)
	local v13 = data.CFrame * Vector3.new(v6, -v5, data.NearPlaneZ)
	local v14 = {
		Near = planeFromPoints(v11, v13, v10),
		Far = planeFromPoints(v8, v7, v9),
		Top = planeFromPoints(v11, v10, v8),
		Bottom = planeFromPoints(v13, v9, v12),
		Left = planeFromPoints(v10, v12, v7),
		Right = planeFromPoints(v11, v8, v13)
	}
	table.freeze(v14)
	return v14
end

return Frustum