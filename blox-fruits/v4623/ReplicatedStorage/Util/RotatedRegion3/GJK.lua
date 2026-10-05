local createVector = vector.create
local GJK = {}
GJK.__index = GJK

-- equivalent calls inferred from this helper; original call sites unknown
local function tripleProduct(p, p2, vector2)
	return p2 * vector2:Dot(p) - p * vector2:Dot(p2)
end

local function containsOrigin(_, list, _)
	local v = list[#list]
	local v2 = -v
	local unit

	if #list == 4 then
		local v3 = list[3]
		local v4 = list[2]
		local v5 = list[1]
		local vector2 = v3 - v
		local vector3 = v4 - v
		local vector4 = v5 - v
		unit = vector2:Cross(vector3)
		local vector5 = vector3:Cross(vector4)
		local vector6 = vector4:Cross(vector2)

		if unit:Dot(vector4) > 0 then
			unit = -unit or unit
		end

		if vector5:Dot(vector2) > 0 then
			vector5 = -vector5 or vector5
		end

		if vector6:Dot(vector3) > 0 then
			unit = -vector6 or vector6
		else
			unit = vector6
		end

		if unit:Dot(v2) > 0 then
			table.remove(list, 1)
			return false, unit
		end

		if vector5:Dot(v2) > 0 then
			table.remove(list, 2)
			unit = vector5
			return false, unit
		elseif unit:Dot(v2) > 0 then
			table.remove(list, 3)
			return false, unit
		else
			return true
		end
	elseif #list == 3 then
		local v3 = list[2]
		local v4 = list[1]
		local vector2 = v3 - v
		local vector3 = v4 - v
		local vector4 = vector2:Cross(vector3)
		unit = (tripleProduct(vector3, vector2, vector2)).Unit
		local unit2 = (tripleProduct(vector2, vector3, vector3)).Unit

		if unit:Dot(v2) > 0 then
			table.remove(list, 1)
			return false, unit
		end

		if unit2:Dot(v2) > 0 then
			table.remove(list, 2)
			unit = unit2
		else
			if v - v ~= createVector(0, 0, 0) then
				return true
			end

			unit = vector4:Dot(v2) > 0 and vector4 or -vector4
		end

		return false, unit
	else
		local vector2 = list[1] - v
		unit = (tripleProduct(vector2, v2, vector2)).Unit
		return false, unit
	end
end

function GJK.new(setA, setB, centroidA, centroidB, supportA, supportB)
	local self = setmetatable({}, GJK)
	self.SetA = setA
	self.SetB = setB
	self.CentroidA = centroidA
	self.CentroidB = centroidB
	self.SupportA = supportA
	self.SupportB = supportB
	return self
end

function GJK.IsColliding(data)
	local unit = (data.CentroidA - data.CentroidB).Unit
	local v = { data.SupportA(data.SetA, unit) - data.SupportB(data.SetB, -unit) }
	local v2 = -unit

	for _ = 1, 20 do
		table.insert(v, data.SupportA(data.SetA, v2) - data.SupportB(data.SetB, -v2))

		if v[#v]:Dot(v2) <= 0 then
			return false
		end

		local v3
		v3, v2 = containsOrigin(data, v, v2)

		if v3 then
			return true
		end
	end

	return false
end

return GJK