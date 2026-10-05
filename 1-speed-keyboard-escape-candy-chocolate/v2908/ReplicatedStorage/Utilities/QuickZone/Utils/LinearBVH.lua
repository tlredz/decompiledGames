local createVector = vector.create
local Geometry = require(script.Parent.Geometry)
require(script.Parent.Parent.Types)
local v = createVector(1, 1, 1) * 1e999
local v2 = -v
local unionBounds = Geometry.unionBounds
local getObjectBounds = Geometry.getObjectBounds
local getMortonScale = Geometry.getMortonScale
local positionToMortonCode = Geometry.positionToMortonCode
local LinearBVH = {}
local v3 = {}
local v4 = {}
local objectBounds = {}
local v5 = {}

local function getSplitPos(p, p2: number, p3: number)
	if p3 == p2 + 1 then
		return p2 + 1
	end

	local mortonCode = p[p2].mortonCode
	local mortonCode2 = p[p3].mortonCode

	if mortonCode == mortonCode2 then
		return (p2 + p3) // 2
	end

	local v6 = bit32.lshift(1, 31 - bit32.countlz((bit32.bxor(mortonCode, mortonCode2))))
	local v7 = bit32.band(mortonCode, v6)

	while p3 - p2 > 1 do
		local v8 = (p2 + p3) // 2

		if bit32.band(p[v8].mortonCode, v6) == v7 then
			p2 = v8
		else
			p3 = v8
		end
	end

	return p2 + 1
end

local buildFlatTree

buildFlatTree = function(p, p2, p3, p4: number, p5: number, p6, p7: number)
	local node = p6.nodes[p7]

	if not node then
		node = {}
		p6.nodes[p7] = node
	end

	if p4 == p5 then
		local id = p[p4].id
		local vector2 = p2[id]
		local vector3 = p3[id]
		node.min = vector2
		node.max = vector3
		node.id = id
		node.skipIndex = p7 + 1
		return p7 + 1, vector2, vector3
	else
		local splitPos = getSplitPos(p, p4, p5)
		node.id = -1
		local v6, v7, v8 = buildFlatTree(p, p2, p3, p4, splitPos - 1, p6, p7 + 1)
		local skipIndex, v10, v11 = buildFlatTree(p, p2, p3, splitPos, p5, p6, v6)
		local min, max = unionBounds(v7, v8, v10, v11)
		node.min = min
		node.max = max
		node.skipIndex = skipIndex
		return skipIndex, min, max
	end
end

function LinearBVH:build(items, p2)
	table.clear(objectBounds)
	table.clear(v5)
	local v6 = v
	local v7 = v2
	local count = 0

	for k, item in items do
		local objectBounds2, v8 = getObjectBounds(item, p2[k])
		objectBounds[k] = objectBounds2
		v5[k] = v8
		v6 = vector.min(v6, objectBounds2)
		v7 = vector.max(v7, v8)
		count += 1
		local v9 = v3[count]

		if not v9 then
			local count2 = #v4

			if count2 > 0 then
				v9 = v4[count2]
				v4[count2] = nil
			else
				v9 = {
					id = 0,
					mortonCode = 0
				}
			end

			v3[count] = v9
		end

		v9.id = k
	end

	if count == 0 then
		self.count = 0
		return
	end

	local count2 = #v3

	if count < count2 then
		local count3 = #v4

		for i = count + 1, count2 do
			count3 += 1
			v4[count3] = v3[i]
			v3[i] = nil
		end
	end

	local vector2 = vector.max(createVector(1, 1, 1), (v7 - v6) * 0.01)
	local v8 = v6 - vector2
	local mortonScale, v10, v11 = getMortonScale(v8, v7 + vector2)

	for i = 1, count do
		local v12 = v3[i]
		v12.mortonCode = positionToMortonCode(items[v12.id].Position, v8, mortonScale, v10, v11)
	end

	table.sort(v3, function(a, b)
		return a.mortonCode < b.mortonCode
	end)
	self.count = buildFlatTree(v3, objectBounds, v5, 1, count, self, 1) - 1
end

function LinearBVH.queryPoint(p, vector2: Vector3, callback)
	local nodes = p.nodes
	local count = p.count
	local X = vector2.X
	local Y = vector2.Y
	local Z = vector2.Z
	local skipIndex = 1

	while skipIndex <= count do
		local node = nodes[skipIndex]
		local min = node.min
		local max = node.max

		if min.X <= X and X <= max.X and min.Y <= Y and Y <= max.Y and min.Z <= Z and Z <= max.Z then
			skipIndex += 1
			local id = node.id

			if id > 0 then
				callback(id)
			end
		else
			skipIndex = node.skipIndex
		end
	end
end

return LinearBVH