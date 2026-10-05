local class = {}
class.__index = class

function class.new(point: Vector2, point2: Vector2)
	if point.X > point2.X or point.X == point2.X and point.Y > point2.Y then
		point2, point = point, point2
	end

	return (setmetatable({
		a = point,
		b = point2
	}, class))
end

function class:key()
	return ("%f,%f:%f,%f"):format(self.a.X, self.a.Y, self.b.X, self.b.Y)
end

local class2 = {}
class2.__index = class2

function class2.new(point: Vector2, point2: Vector2, point3: Vector2)
	return (setmetatable({
		a = point,
		b = point2,
		c = point3
	}, class2))
end

function class2:edges()
	return { class.new(self.a, self.b), class.new(self.b, self.c), class.new(self.c, self.a) }
end

-- equivalent calls inferred from this helper; original call sites unknown
local function orient2d(a: Vector2, b: Vector2, c: Vector2)
	return (b.X - a.X) * (c.Y - a.Y) - (b.Y - a.Y) * (c.X - a.X)
end

function class2:containsInCircumcircle(point: Vector2)
	local v = self.a.X - point.X
	local v2 = self.a.Y - point.Y
	local v3 = self.b.X - point.X
	local v4 = self.b.Y - point.Y
	local v5 = self.c.X - point.X
	local v6 = self.c.Y - point.Y
	local v7 = (v * v + v2 * v2) * (v3 * v6 - v5 * v4) - (v3 * v3 + v4 * v4) * (v * v6 - v5 * v2) + (v5 * v5 + v6 * v6) * (v * v4 - v3 * v2)
	local v8 = orient2d(self.a, self.b, self.c) -- equivalent call inferred; original call site unknown

	if v8 > 0 and v7 > 0 then
		return true
	elseif v8 < 0 then
		return v7 < 0
	else
		return false
	end
end

function class2:hasVertex(point: Vector2)
	return self.a == point or self.b == point or self.c == point
end

local function Triangulate(list)
	assert(#list >= 3, "Need at least three points for triangulation.")
	local clone = table.clone(list)
	local X = clone[1].X
	local Y = clone[1].Y
	local Y2 = Y
	local X2 = X

	for i = 2, #clone do
		local v = clone[i]

		if v.X < X then
			X = v.X
		end

		if v.Y < Y then
			Y = v.Y
		end

		if X2 < v.X then
			X2 = v.X
		end

		if Y2 < v.Y then
			Y2 = v.Y
		end
	end

	local v = math.max(X2 - X, Y2 - Y) * 2
	local midpointX = (X + X2) / 2
	local midpointY = (Y + Y2) / 2
	local vector = Vector2.new(midpointX - v * 2, midpointY - v)
	local vector2 = Vector2.new(midpointX, midpointY + v * 2)
	local vector3 = Vector2.new(midpointX + v * 2, midpointY - v)
	local v4 = { class2.new(vector, vector2, vector3) }

	for _, v5 in ipairs(clone) do
		local v6 = {}

		for _, v7 in ipairs(v4) do
			if v7:containsInCircumcircle(v5) then
				v6[#v6 + 1] = v7
			end
		end

		local v7 = {}

		for _, v8 in ipairs(v6) do
			for _, v9 in ipairs(v8:edges()) do
				local key = v9:key()

				if v7[key] then
					v7[key] = nil
				else
					v7[key] = v9
				end
			end
		end

		for i = #v4, 1, -1 do
			local v8 = v4[i]

			for _, v10 in ipairs(v6) do
				if v8 ~= v10 then
					continue
				end

				table.remove(v4, i)
				break
			end
		end

		for _, v8 in pairs(v7) do
			v4[#v4 + 1] = class2.new(v8.a, v8.b, v5)
		end
	end

	local result = {}

	for _, v5 in ipairs(v4) do
		if v5:hasVertex(vector) or v5:hasVertex(vector2) or v5:hasVertex(vector3) then
			continue
		end

		result[#result + 1] = { v5.a, v5.b, v5.c }
	end

	return result
end

return Triangulate