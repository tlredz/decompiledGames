local createVector = vector.create
local Utility = {}

local function barycentric(pointToWorldSpace: Vector3, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local vector5 = vector3 - vector2
	local vector6 = vector4 - vector2
	local vector7 = pointToWorldSpace - vector2
	local dot = vector5:Dot(vector5)
	local dot2 = vector5:Dot(vector6)
	local dot3 = vector6:Dot(vector6)
	local dot4 = vector7:Dot(vector5)
	local dot5 = vector7:Dot(vector6)
	local v = dot * dot3 - dot2 * dot2
	local v2 = (dot3 * dot4 - dot2 * dot5) / v
	local v3 = (dot * dot5 - dot2 * dot4) / v
	return 1 - v2 - v3, v2, v3
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function barycentriccheck(p, p2)
	return p >= 0 and p2 >= 0 and p <= 1 and p2 <= 1 and p + p2 <= 1
end

local function cpart(position)
	local part = Instance.new("Part")
	part.Anchored = true
	part.Material = Enum.Material.Neon
	part.Position = position
	part.Size = createVector(1, 1, 1)
	part.Parent = workspace
end

local v = {
	Block = function(p, instance)
		return Utility.isPointInBox(p, instance.CFrame, instance.Size)
	end,
	Cylinder = function(p, instance)
		local position = instance.Position
		local cFrame = instance.CFrame
		local extentsSize = instance.ExtentsSize
		local _ = extentsSize.X
		local v2 = extentsSize.Y / 2
		local pointToObjectSpace = cFrame:PointToObjectSpace(p)
		return (position + cFrame.XVector.Unit * pointToObjectSpace.X - p).Magnitude <= v2
	end,
	Ball = function(p, p2)
		return p2.ExtentsSize.X / 2 >= (p - p2.Position).Magnitude
	end,
	Wedge = function(p, instance)
		local position = instance.Position
		local cFrame = instance.CFrame
		local size = instance.Size
		local halfSize = size / 2
		local v3 = cFrame.XVector.Unit * halfSize.X
		local v4 = cFrame.YVector.Unit * halfSize.Y
		local v5 = cFrame.ZVector.Unit * halfSize.Z
		local v6 = position + v3 + v5 + v4
		local v7 = position + v3 + v5 - v4
		local v8 = position + v3 - v5 - v4
		local v9, v10 = barycentric(
			cFrame:PointToWorldSpace(cFrame:PointToObjectSpace(p) * createVector(0, 1, 1) + Vector3.new(
				size.X / 2,
				0,
				0
			)),
			v6,
			v7,
			v8
		)
		return barycentriccheck(v9, v10)
	end,
	CornerWedge = function(p, instance)
		local position = instance.Position
		local cFrame = instance.CFrame
		local size = instance.Size
		local halfSize = size / 2
		local v3 = cFrame.XVector.Unit * halfSize.X
		local v4 = cFrame.YVector.Unit * halfSize.Y
		local v5 = cFrame.ZVector.Unit * halfSize.Z
		local v6 = position + v3 - v5 + v4
		local v7 = position + v3 - v5 - v4
		local v8 = position - v3 - v5 - v4
		local v9 = position + v3 + v5 - v4
		local v10, v11 = barycentric(
			cFrame:PointToWorldSpace(cFrame:PointToObjectSpace(p) * createVector(1, 1, 0) - Vector3.new(
				0,
				0,
				size.Z / 2
			)),
			v6,
			v7,
			v8
		)
		local v12, v13 = barycentric(
			cFrame:PointToWorldSpace(cFrame:PointToObjectSpace(p) * createVector(0, 1, 1) + Vector3.new(
				size.X / 2,
				0,
				0
			)),
			v6,
			v7,
			v9
		)
		local v14 = barycentriccheck(v10, v11)

		if v14 then
			if v12 >= 0 and v13 >= 0 and v12 <= 1 and v13 <= 1 then
				return v12 + v13 <= 1
			else
				return false
			end
		end

		return v14
	end
}

function Utility.getRandomPointInSimplex(p, list)
	if #list < 2 then
		error("Not enough points to form a simplex.")
	end

	local v2 = {}
	local v3 = {}
	local v4 = {}
	local total = 0

	while #v2 < p + 1 do
		local v5 = math.random(1, #list)

		if v3[v5] then
			continue
		end

		local v6 = list[v5]
		v2[#v2 + 1] = v6
		v3[v5] = true
		local v7 = math.random()
		v4[#v4 + 1] = v7
		total += v7
	end

	local v5 = createVector(0, 0, 0)

	for i = 1, p + 1 do
		v5 += v2[i] * (v4[i] / total)
	end

	return v5
end

function Utility.isPointInShape(vector2: Vector3, p)
	local v2 = v[p.Shape.Name]

	if not v2 then
		error((`Shape check function not found for {p}`))
	end

	return v2(vector2, p)
end

function Utility.getBoxesVertices(p, items)
	local result = {}
	local result2 = {}

	for _, part in items do
		if not part:IsA("Part") then
			error("PartsZone.new() must be fed a pure array of parts.")
		end

		local name = part.Shape.Name
		local v2 = p[name]

		if not v2 then
			error((`Shape {name} could not be converted into points.`))
		end

		local vertices = v2(part)
		result[#result + 1] = vertices
		result2[#result2 + 1] = {
			cframe = part.CFrame,
			size = part.Size,
			part = part,
			vertices = vertices
		}
	end

	return result2, result
end

local v2 = {}

function Utility.isPointInBox(p, cframe, p2)
	local v3 = v2[p2] or p2 / 2
	v2[p2] = v3
	local pointToObjectSpace = cframe:PointToObjectSpace(p)
	local v4 = math.abs(pointToObjectSpace.X) <= v3.X
	local v5 = math.abs(pointToObjectSpace.Y) <= v3.Y
	local v6 = math.abs(pointToObjectSpace.Z) <= v3.Z
	return v4 and v5 and v6
end

return Utility