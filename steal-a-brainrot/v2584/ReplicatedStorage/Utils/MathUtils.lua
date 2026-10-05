function isPointInVolume(vector2: Vector3, cframe: CFrame, vector3: Vector3)
	local vector4 = vector.abs(cframe:Inverse() * vector2)
	return vector4.x <= vector3.x * 0.5 and vector4.y <= vector3.y * 0.5 and vector4.z <= vector3.z * 0.5
end

function isPointInVolume_direct(vector2: Vector3, cframe: CFrame, vector3: Vector3)
	local vector4 = vector.abs(cframe * vector2)
	return vector4.x <= vector3.x * 0.5 and vector4.y <= vector3.y * 0.5 and vector4.z <= vector3.z * 0.5
end

local MathUtils = {}
MathUtils.isPointInVolume = isPointInVolume
MathUtils.isPointInVolume_direct = isPointInVolume_direct

function MathUtils.quadBezier(p: number, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + (1 - p) * 2 * p * p3 + p ^ 2 * p4
end

function MathUtils.cubicBezier(p: number, p2, p3, p4, p5)
	return (1 - p) ^ 3 * p2 + (1 - p) ^ 2 * 3 * p * p3 + (1 - p) * 3 * p ^ 2 * p4 + p ^ 3 * p5
end

function MathUtils.sortByXdesc(...)
	local v = select("#", ...)

	if v == 1 then
		error("sortByXdesc requires at least 2 vectors")
	elseif v == 2 then
		local v2, v3 = ...

		if v2.x >= v3.x then
			return v2, v3
		end

		return v3, v2
	elseif v == 3 then
		local v2, v3, v4 = ...

		if v2.x >= v3.x and v2.x >= v4.x then
			if v3.x >= v4.x then
				return v2, v3, v4
			end

			return v2, v4, v3
		elseif v3.x >= v2.x and v3.x >= v4.x then
			if v2.x >= v4.x then
				return v3, v2, v4
			end

			return v3, v4, v2
		elseif v2.x >= v3.x then
			return v4, v2, v3
		else
			return v4, v3, v2
		end
	end

	local v2 = { ... }
	table.sort(v2, function(a, b)
		return a.x > b.x
	end)
	return table.unpack(v2, 1, v)
end

function MathUtils.sortByYdesc(...)
	local v = select("#", ...)

	if v == 1 then
		error("sortByYdesc requires at least 2 vectors")
	elseif v == 2 then
		local v2, v3 = ...

		if v2.y >= v3.y then
			return v2, v3
		end

		return v3, v2
	elseif v == 3 then
		local v2, v3, v4 = ...

		if v2.y >= v3.y and v2.y >= v4.y then
			if v3.y >= v4.y then
				return v2, v3, v4
			end

			return v2, v4, v3
		elseif v3.y >= v2.y and v3.y >= v4.y then
			if v2.y >= v4.y then
				return v3, v2, v4
			end

			return v3, v4, v2
		elseif v2.y >= v3.y then
			return v4, v2, v3
		else
			return v4, v3, v2
		end
	end

	local v2 = { ... }
	table.sort(v2, function(a, b)
		return a.y > b.y
	end)
	return table.unpack(v2, 1, v)
end

function MathUtils.sortByZdesc(...)
	local v = select("#", ...)

	if v == 1 then
		error("sortByZdesc requires at least 2 vectors")
	elseif v == 2 then
		local v2, v3 = ...

		if v2.z >= v3.z then
			return v2, v3
		end

		return v3, v2
	elseif v == 3 then
		local v2, v3, v4 = ...

		if v2.z >= v3.z and v2.z >= v4.z then
			if v3.z >= v4.z then
				return v2, v3, v4
			end

			return v2, v4, v3
		elseif v3.z >= v2.z and v3.z >= v4.z then
			if v2.z >= v4.z then
				return v3, v2, v4
			end

			return v3, v4, v2
		elseif v2.z >= v3.z then
			return v4, v2, v3
		else
			return v4, v3, v2
		end
	end

	local v2 = { ... }
	table.sort(v2, function(a, b)
		return a.z > b.z
	end)
	return table.unpack(v2, 1, v)
end

function MathUtils.areVectorsAligned(vector2: Vector3, vector3: Vector3, p: number)
	return math.deg((math.acos((math.clamp(vector.dot(vector.normalize(vector2), (vector.normalize(vector3))), -1, 1))))) <= p
end

function MathUtils.simulateGravity(p: number)
	return p * p * 98.1
end

function MathUtils.calculateTimeToGround(p: number, p2: number)
	return (math.sqrt((p - p2) * 2 / 196.2))
end

function MathUtils.getSweptAABB(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local v = vector4 * 0.5
	local vector5 = vector.min(vector2 - v, vector3 - v)
	local vector6 = vector.max(vector2 + v, vector3 + v)
	return (vector5 + vector6) * 0.5, vector6 - vector5
end

return MathUtils