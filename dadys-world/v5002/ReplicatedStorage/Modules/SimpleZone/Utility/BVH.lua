local createVector = vector.create

function traverseBVH(p, callback)
	local v = { p }
	local v2 = 1
	local v3 = false

	local function stop()
		table.clear(v)
		v3 = true
	end

	while v2 > 0 and not v3 do
		local v4 = v[v2]
		v2 -= 1

		if v4.volume < 0.001 or not callback(v4, stop) then
			continue
		end

		if v4.right then
			v2 += 1
			v[v2] = v4.right
		end

		if not v4.left then
			continue
		end

		v2 += 1
		v[v2] = v4.left
	end
end

local function getBoundingBox(items)
	local vector2 = createVector(1e999, 1e999, 1e999)
	local vector3 = createVector(-1e999, -1e999, -1e999)

	for _, item in items do
		local cframe = item.cframe
		local v = item.size * 0.5

		for _, v2 in {
			cframe.Position + vector.create(-v.X, -v.Y, -v.Z),
			cframe.Position + vector.create(v.X, -v.Y, -v.Z),
			cframe.Position + vector.create(-v.X, v.Y, -v.Z),
			cframe.Position + vector.create(v.X, v.Y, -v.Z),
			cframe.Position + vector.create(-v.X, -v.Y, v.Z),
			cframe.Position + vector.create(v.X, -v.Y, v.Z),
			cframe.Position + vector.create(-v.X, v.Y, v.Z),
			cframe.Position + vector.create(v.X, v.Y, v.Z)
		} do
			vector2 = vector.create(
				math.min(vector2.X, v2.X) // 4 * 4,
				math.min(vector2.Y, v2.Y) // 4 * 4,
				math.min(vector2.Z, v2.Z) // 4 * 4
			)
			vector3 = vector.create(
				math.max(vector3.X, v2.X) // 4 * 4,
				math.max(vector3.Y, v2.Y) // 4 * 4,
				math.max(vector3.Z, v2.Z) // 4 * 4
			)
		end
	end

	local v = vector3 - vector2
	local midpoint = (vector2 + vector3) / 2
	return CFrame.new(midpoint), v
end

local function determine(p, p2: string, list)
	if #list > 1 then
		local boundingBox, size = getBoundingBox(list)
		p[p2] = {
			cframe = boundingBox,
			size = size,
			volume = size.x * size.y * size.z
		}
		split(p[p2], list)
	elseif #list == 1 then
		local v = list[1]
		p[p2] = {
			cframe = v.cframe,
			size = v.size,
			volume = v.size.x * v.size.y * v.size.z,
			part = v.part
		}
	end
end

function split(p, list)
	local size = p.size
	local v

	if size.X >= size.Y and size.X >= size.Z then
		v = "X"
	elseif size.Y >= size.X and size.Y >= size.Z then
		v = "Y"
	elseif size.Z >= size.Y and size.Z >= size.X then
		v = "Z"
	else
		v = nil
	end

	table.sort(list, function(a, b)
		return a.cframe[v] < b.cframe[v]
	end)
	local count = #list
	local v2 = count // 2
	local v3 = table.create(v2)
	local v4 = table.create(v2)
	table.move(list, 1, v2, 1, v3)
	table.move(list, v2 + 1, count, 1, v4)
	determine(p, "left", v3)
	determine(p, "right", v4)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function calculateDistance(p, p2)
	return (p.cframe.Position - p2.cframe.Position).Magnitude
end

-- equivalent calls inferred from this helper; original call sites unknown
local function needsUpdate(p, p2, p3)
	local magnitude2 = calculateDistance(p, p2) -- equivalent call inferred; original call site unknown
	local magnitude = (p.size - p2.size).Magnitude
	return p3 < magnitude2 or p3 < magnitude
end

local updateBVHNode

updateBVHNode = function(state, p, items, p2)
	if not state then
		return
	end

	if state.part then
		local v = {
			cframe = state.cframe,
			size = state.size,
			volume = state.volume,
			part = state.part
		}
		local v2 = nil

		for _, item in items do
			if item.part ~= state.part then
				continue
			end

			v2 = item
			break
		end

		if not v2 then
			return false
		end

		if not needsUpdate(v, v2, p2) then
			return false
		end

		state.cframe = v2.cframe
		state.size = v2.size
		state.volume = v2.volume
		return true
	else
		local v = updateBVHNode(state.left, p, items, p2)
		local v2 = updateBVHNode(state.right, p, items, p2)

		if not (v or v2) then
			return false
		end

		local v3 = state.left and {
			cframe = state.left.cframe,
			size = state.left.size,
			volume = state.left.volume
		}
		local v4 = state.right and {
			cframe = state.right.cframe,
			size = state.right.size,
			volume = state.right.volume
		}

		if v3 and v4 then
			local position = v3.cframe.Position
			local position2 = v4.cframe.Position
			local vector2 = vector.create(
				math.min(position.X - v3.size.X / 2, position2.X - v4.size.X / 2) // 4 * 4,
				math.min(position.Y - v3.size.Y / 2, position2.Y - v4.size.Y / 2) // 4 * 4,
				math.min(position.Z - v3.size.Z / 2, position2.Z - v4.size.Z / 2) // 4 * 4
			)
			local vector3 = vector.create(
				math.max(position.X + v3.size.X / 2, position2.X + v4.size.X / 2) // 4 * 4,
				math.max(position.Y + v3.size.Y / 2, position2.Y + v4.size.Y / 2) // 4 * 4,
				math.max(position.Z + v3.size.Z / 2, position2.Z + v4.size.Z / 2) // 4 * 4
			)
			local size = vector3 - vector2
			local midpoint = (vector2 + vector3) / 2
			state.cframe = CFrame.new(midpoint)
			state.size = size
			state.volume = size.x * size.y * size.z
		elseif v3 then
			state.cframe = v3.cframe
			state.size = v3.size
			state.volume = v3.volume
		elseif v4 then
			state.cframe = v4.cframe
			state.size = v4.size
			state.volume = v4.volume
		end

		return true
	end
end

local BVH = {}

function BVH.createBVH(p)
	local boundingBox, size = getBoundingBox(p)
	local v2 = {
		cframe = boundingBox,
		size = size,
		volume = size.x * size.y * size.z
	}
	split(v2, p)
	return v2
end

BVH.traverseBVH = traverseBVH

function BVH.updateBVH(p, p2, p3, value)
	return (updateBVHNode(p, p2, p3, value or 0.1))
end

BVH.getBoundingBox = getBoundingBox

function BVH.visualize(p)
	traverseBVH(p, function(data)
		local part = Instance.new("Part")
		part.Anchored = true
		part.Transparency = 0.7
		part.CFrame = data.cframe
		part.Size = data.size
		part.Parent = workspace
		part.CanCollide = false
		part.CanQuery = false

		if not (data.right or data.left) then
			part.Color = Color3.fromRGB(255, 0, 0)
		end

		return true
	end)
end

BVH.VoxelSize = 4
return BVH