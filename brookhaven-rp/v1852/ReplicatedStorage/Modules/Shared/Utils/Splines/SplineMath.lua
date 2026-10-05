local createVector = vector.create
local v = nil
local SplineMath = {
	Init = function(_, p)
		v = p
	end
}

local function GetSplineData(instance)
	if not instance:IsA("Instance") then
		warn("[SplineMath] Spline is not an instance")
		return nil
	end

	local controlPoints = instance:FindFirstChild("ControlPoints")

	if not controlPoints then
		return nil
	end

	local closed2 = false
	local metadata = instance:FindFirstChild("Metadata")

	if metadata then
		local closed = metadata:FindFirstChild("Closed")

		if closed then
			closed2 = closed.Value
		end
	end

	local children = controlPoints:GetChildren()
	table.sort(children, function(a, b)
		return (tonumber(a.Name:match("%d+")) or 0) < (tonumber(b.Name:match("%d+")) or 0)
	end)
	local positions = {}

	for _, part in ipairs(children) do
		if part:IsA("BasePart") then
			table.insert(positions, part.Position)
		end
	end

	if #positions < 2 then
		return nil
	end

	return {
		points = positions,
		closed = closed2
	}
end

local function CatmullRom(p, p2, p3, p4, p5)
	local v2 = p * p
	local v3 = p * p * p
	return 0.5 * (2 * p3 + (-p2 + p4) * p + (2 * p2 - 5 * p3 + 4 * p4 - p5) * v2 + (-p2 + 3 * p3 - 3 * p4 + p5) * v3)
end

local function GetPointFromPositions(list, p, p2)
	local count = #list

	if count < 2 then
		return list[1]
	end

	local v2 = p2 and count or count - 1
	local v3 = p * v2
	local v4 = math.floor(v3)
	local v5 = v3 - v4

	if not p2 and v2 <= v4 then
		v4 = v2 - 1
		v5 = 1
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function pt(p3)
		if p2 then
			return list[p3 % count + 1]
		end

		return list[math.clamp(p3 + 1, 1, count)]
	end

	local v7 = pt(v4 - 1) -- equivalent call inferred; original call site unknown
	local v8 = pt(v4) -- equivalent call inferred; original call site unknown
	local v10 = pt(v4 + 1) -- equivalent call inferred; original call site unknown
	local v12 = pt(v4 + 2) -- equivalent call inferred; original call site unknown
	local v13 = v5 * v5
	local v14 = v5 * v5 * v5
	return 0.5 * (2 * v8 + (-v7 + v10) * v5 + (2 * v7 - 5 * v8 + 4 * v10 - v12) * v13 + (-v7 + 3 * v8 - 3 * v10 + v12) * v14)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetTangentFromPositions(points, p, closed)
	local v2 = math.max(0, p - 0.001)
	local v3 = math.min(1, p + 0.001)
	local pointFromPositions = GetPointFromPositions(points, v2, closed)
	local v5 = GetPointFromPositions(points, v3, closed) - pointFromPositions
	return v5.Magnitude > 0 and v5.Unit or createVector(0, 0, 1)
end

function SplineMath.GetPointOnSpline(_, p, p2)
	local splineData = GetSplineData(p)

	if not splineData then
		warn("[SplineMath] Spline not found: ", p)
		return nil, nil
	end

	return
		GetPointFromPositions(splineData.points, p2, splineData.closed),
		GetTangentFromPositions(splineData.points, p2, splineData.closed)
end

function SplineMath.GetSplineLength(_, p)
	local splineData = GetSplineData(p)

	if not splineData then
		return 0
	end

	local sampleResolution = v and v.SampleResolution or 200
	local pointFromPositions = GetPointFromPositions(splineData.points, 0, splineData.closed)
	local total = 0

	for i = 1, sampleResolution do
		local v4 = i / sampleResolution
		local pointFromPositions2 = GetPointFromPositions(splineData.points, v4, splineData.closed)
		total += (pointFromPositions2 - pointFromPositions).Magnitude
		pointFromPositions = pointFromPositions2
	end

	return total
end

return SplineMath