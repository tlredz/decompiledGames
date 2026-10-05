local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local class = {}
class.__index = class

function class:GetLength(value)
	if self.length then
		return self.length
	end

	local path = self:GetPath(value or 0.1)
	local total = 0

	for i = 2, #path do
		total += (path[i - 1] - path[i]).Magnitude
	end

	self.length = total
	return self.length
end

function class:GetPath(value)
	assert(type(value) == "number", "Must provide a step increment")
	local v

	if value > 0 then
		v = value < 1
	else
		v = false
	end

	assert(v, "Step out of domain; should be between 0 and 1 (exclusive)")
	local result = {}
	local v2 = 0

	for i = 0, 1, value do
		result[#result + 1] = self:Get(i)
		v2 = i
	end

	if v2 < 1 then
		local v3 = 1 - v2 < value * 0.5
		result[#result + (v3 and 0 or 1)] = self:Get(1)
	end

	return result
end

function class:GetPathByNumberSegments(value)
	assert(type(value) == "number", "Must provide number of segments")
	assert(value > 0, "Number of segments must be greater than 0")
	return self:GetPath(1 / value)
end

function class:GetPathBySegmentLength(value)
	assert(type(value) == "number", "Must provide a segment length")
	assert(value > 0, "Segment length must be greater than 0")
	return self:GetPathByNumberSegments((math.floor(self:GetLength() / value + 0.5)))
end

function class:Get(p, p2)
	if self.isQuadratic then
		local point = self.points[1]
		local point2 = self.points[2]
		local point3 = self.points[3]

		if p2 then
			p = p < 0 and 0 or p > 1 and 1 or p
		end

		return (1 - p) * (1 - p) * point + 2 * (1 - p) * p * point2 + p * p * point3
	elseif self.isCubic then
		local point = self.points[1]
		local point2 = self.points[2]
		local point3 = self.points[3]
		local point4 = self.points[4]

		if p2 then
			p = p < 0 and 0 or p > 1 and 1 or p
		end

		return (1 - p) * (1 - p) * (1 - p) * point + 3 * (1 - p) * (1 - p) * p * point2 + 3 * (1 - p) * p * p * point3 + p * p * p * point4
	else
		if p2 then
			p = p < 0 and 0 or p > 1 and 1 or p
		end

		for i = 1, self.numLines do
			local line = self.lines[i]
			local lerped = line[1]:lerp(line[2], p)
			local v = line[3]
			local X = lerped.X
			local Y = lerped.Y
			local Z = lerped.Z
			v[1] = X
			v[2] = Y
			v[3] = Z
		end

		return self.finalLine[3]:ToVector3()
	end
end

function class.GetPoints(p)
	return p.points
end

local Bezier = {}

function Bezier.QuadBezier(p, p2, p3, p4)
	local v = p2 + (p3 - p2) * p
	return v + (p3 + (p4 - p3) * p - v) * p
end

function Bezier.CubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

function Bezier.new(...)
	local points = { ... }
	assert(#points >= 3, "Must have at least 3 points")
	local v2 = {
		nPoints = #points,
		Points = points,
		lines = {},
		numLines = nil,
		finalLine = nil,
		isQuadratic = #points == 3,
		isCubic = #points == 4
	}

	local function CreatePoint(data)
		return {
			data.X,
			data.Y,
			data.Z,
			ToVector3 = function(self)
				return (vector.create(self[1], self[2], self[3]))
			end,
			lerp = function(self, object2, p)
				return (vector.lerp(self:ToVector3(), object2:ToVector3(), p))
			end
		}
	end

	if v2.isQuadratic or v2.isCubic then
		return v2
	end

	for i = 1, #points - 1 do
		local point = CreatePoint(points[i])
		local v4 = { point, CreatePoint(points[i + 1]), (CreatePoint(point)) }
		v2.lines[#v2.lines + 1] = v4
	end

	local lines = v2.lines

	for i = #v2.lines, 2, -1 do
		local v3 = {}

		for i2 = 1, i - 1 do
			local line = lines[i2]
			local line2 = lines[i2 + 1]
			local v4 = { line[3], line2[3], (CreatePoint(line[3])) }
			v3[i2] = v4
			v2.lines[#v2.lines + 1] = v4
		end

		lines = v3
	end

	v2.finalLine = lines[1]
	v2.numLines = #v2.lines
	return v2
end

return Bezier