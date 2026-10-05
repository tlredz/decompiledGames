local createVector = vector.create

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cubicBezier(p, p2, p3, p4, p5)
	return (1 - p5) ^ 3 * p + 3 * (1 - p5) ^ 2 * p5 * p2 + 3 * (1 - p5) * p5 ^ 2 * p3 + p5 ^ 3 * p4
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cubicBezierDerivative(x, x2, x3, x4, p)
	return 3 * (1 - p) ^ 2 * (x2 - x) + 6 * (1 - p) * p * (x3 - x2) + 3 * p ^ 2 * (x4 - x3)
end

local Bezier = {}
Bezier.__index = Bezier

function Bezier.new(points, value: number?)
	local self = setmetatable({}, Bezier)
	self.points = points
	self.accuracy = value or 20
	self.point_count = 0
	self.cumulative_lengths = {}
	self:_recalculate()
	return self
end

function Bezier:setPoints(points)
	self.points = points
	self:_recalculate()
end

function Bezier:getSegmentPoints(p2: number)
	if p2 < 1 or self.point_count - 1 < p2 then
		if p2 <= 0 then
			return createVector(0, 0, 0), createVector(0, 0, 0), createVector(0, 0, 0), createVector(0, 0, 0)
		else
			error("attempt to get a non-existent segment at index " .. p2)
		end
	end

	local v = math.max((p2 - 1) * 4 - math.max(p2 - 2, 0), 1)
	return self.points[v], self.points[v + 1], self.points[v + 2], self.points[v + 3]
end

function Bezier:forSample(p: number, callback)
	local v = self.length // p

	if v == 0 then
		return
	end

	for i = 0, v do
		callback(self:getPositionArcSpace(i / v), i)
	end
end

function Bezier:getPosition(p: number)
	local segmentIndex, v = self:getSegmentIndex(p)
	local segmentPoints, v2, v3, v4 = self:getSegmentPoints(segmentIndex)
	return cubicBezier(segmentPoints, v2, v3, v4, v)
end

function Bezier:getSegmentIndex(value: number)
	local v = math.clamp(value, 0, 1)
	local v2 = self.point_count - 1
	local v3 = v * v2
	local v4 = math.min(math.floor(v3) + 1, v2)
	local v5 = v3 - math.floor(v3)
	return v4, v == 1 and 1 or v5
end

function Bezier:getEasedSegmentIndex(p: number)
	local v = self.point_count - 1

	for i = 1, v do
		local segmentPoints, _, _, v3 = self:getSegmentPoints(i)
		local x = segmentPoints.x
		local x2 = v3.x

		if x <= p and p < x2 then
			return i, (p - x) / (x2 - x)
		end
	end

	return v, 1
end

function Bezier:getEase(p: number)
	local easedSegmentIndex, v = self:getEasedSegmentIndex(p)
	local segmentPoints, v2, v3, v4 = self:getSegmentPoints(easedSegmentIndex)

	for _ = 1, 5 do
		local v5 = cubicBezier(segmentPoints.x, v2.x, v3.x, v4.x, v)
		local v6 = cubicBezierDerivative(segmentPoints.x, v2.x, v3.x, v4.x, v)

		if v6 == 0 then
			break
		end

		local v7 = (v5 - p) / v6
		local v8 = v - v7
		v = v8 < 0 and 0 or v8 > 1 and 1 or v8

		if math.abs(v7) < 0.001 then
			break
		end
	end

	return cubicBezier(segmentPoints, v2, v3, v4, v)
end

function Bezier:getPositionArcSpace(value: number)
	if self.length <= 0 then
		return self.points[1] or createVector(0, 0, 0)
	end

	local v = math.clamp(value, 0, 1) * self.cumulative_lengths[self.accuracy + 1]
	local v2 = self.accuracy + 1
	local v3 = 1
	local v4 = nil

	while v3 < v2 do
		v4 = v3 + (v2 - v3) // 2

		if self.cumulative_lengths[v4] < v then
			v3 = v4 + 1
		else
			v2 = v4
		end
	end

	if v < self.cumulative_lengths[v4] and v4 > 1 then
		v4 -= 1
	end

	local cumulative_length = self.cumulative_lengths[v4]

	if cumulative_length == v then
		return self:getPosition((v4 - 1) / self.accuracy)
	end

	return self:getPosition((v4 - 1 + (v - cumulative_length) / (self.cumulative_lengths[v4 + 1] - cumulative_length)) / self.accuracy)
end

function Bezier:_recalculate()
	table.clear(self.cumulative_lengths)
	table.insert(self.cumulative_lengths, 0)
	self.point_count = math.ceil(#self.points / 3)
	local v = nil
	local total = 0

	for i = 1, self.accuracy do
		local position = self:getPosition(i / self.accuracy)
		total += vector.magnitude(position - (v or self:getPosition(0)))
		table.insert(self.cumulative_lengths, total)
		v = position
	end

	self.length = total

	for k, cumulative_length in self.cumulative_lengths do
		self.cumulative_lengths[k] = cumulative_length / total
	end
end

return Bezier