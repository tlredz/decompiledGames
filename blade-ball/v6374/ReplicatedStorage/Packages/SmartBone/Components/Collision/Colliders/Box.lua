local createVector = vector.create

-- equivalent calls inferred from this helper; original call sites unknown
local function SafeUnit(p)
	if p.Magnitude == 0 then
		return createVector(0, 0, 0)
	end

	return p.Unit
end

local function ClosestPointFunc(object, data, p)
	local pointToObjectSpace = object:pointToObjectSpace(p)
	local x = data.x
	local y = data.y
	local z = data.z
	local x2 = pointToObjectSpace.x
	local y2 = pointToObjectSpace.y
	local z2 = pointToObjectSpace.z
	local v = math.clamp(x2, -x * 0.5, x * 0.5)
	local v2 = math.clamp(y2, -y * 0.5, y * 0.5)
	local v3 = math.clamp(z2, -z * 0.5, z * 0.5)

	if v == x2 and v2 == y2 and v3 == z2 then
		local v4 = x2 - x * 0.5
		local v5 = y2 - y * 0.5
		local v6 = z2 - z * 0.5
		local v7 = -x2 - x * 0.5
		local v8 = -y2 - y * 0.5
		local v9 = -z2 - z * 0.5
		local v10 = math.max(v4, v5, v6, v7, v8, v9)

		if v10 == v4 then
			return true, object * Vector3.new(x * 0.5, y2, z2), object.XVector
		end

		if v10 == v5 then
			return true, object * Vector3.new(x2, y * 0.5, z2), object.YVector
		end

		if v10 == v6 then
			return true, object * Vector3.new(x2, y2, z * 0.5), object.ZVector
		end

		if v10 == v7 then
			return true, object * Vector3.new(-x * 0.5, y2, z2), -object.XVector
		end

		if v10 == v8 then
			return true, object * Vector3.new(x2, -y * 0.5, z2), -object.YVector
		end

		if v10 == v9 then
			return true, object * Vector3.new(x2, y2, -z * 0.5), -object.ZVector
		end

		warn("CLOSEST POINT ON BOX FAIL")
		return false, object.Position, createVector(0, 0, 0)
	else
		local v4 = object * Vector3.new(v, v2, v3)
		return false, v4, SafeUnit(p - v4)
	end
end

return function(p, p2, p3, p4)
	local v, v2, v3 = ClosestPointFunc(p, p2, p3)

	if v then
		return v, v2, v3
	end

	return (v2 - p3).Magnitude < p4, v2, v3
end