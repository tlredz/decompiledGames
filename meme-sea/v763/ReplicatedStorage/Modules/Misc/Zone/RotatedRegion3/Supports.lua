local createVector = vector.create

local function rayPlane(p, vector2, p2, p3)
	local v = -(p - p2):Dot(p3) / vector2:Dot(p3)
	return p + v * vector2, v
end

local Supports = {}

function Supports.PointCloud(list, p)
	local v = list[1]
	local dot = list[1]:Dot(p)

	for i = 2, #list do
		local dot2 = list[i]:Dot(p)

		if not (dot < dot2) then
			continue
		end

		v = list[i]
		dot = dot2
	end

	return v
end

function Supports.Cylinder(list, p)
	local cframe, v = unpack(list)
	local vector2 = cframe:VectorToObjectSpace(p)
	local v2 = math.min(v.y, v.z)
	local dot = vector2:Dot(createVector(1, 0, 0))
	local vector3 = Vector3.new(v.x, 0, 0)
	local v3

	if dot == 0 then
		v3 = vector2.Unit * v2
	else
		local v4 = dot > 0 and vector3 or -vector3
		v3 = v4 + (createVector(0, 0, 0) + -(createVector(0, 0, 0) - v4):Dot(createVector(1, 0, 0)) / vector2:Dot(createVector(
			1,
			0,
			0
		)) * vector2 - v4).Unit * v2
	end

	return cframe:PointToWorldSpace(v3)
end

function Supports.Ellipsoid(list, p)
	local cframe, v = unpack(list)
	return cframe:PointToWorldSpace(v * (v * cframe:VectorToObjectSpace(p)).Unit)
end

return Supports