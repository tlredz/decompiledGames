local createVector = vector.create
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Utility = require(ReplicatedStorage.Modules.Shared.Utils.LessSimpleZone.ZoneTypes.PartsZone.Utility)
local BVH = {}
local traverseBVH

traverseBVH = function(p, callback)
	if not (p and callback(p)) then
		return
	end

	if p.left then
		traverseBVH(p.left, callback)
	end

	if p.right then
		traverseBVH(p.right, callback)
	end
end

local r_traverseBVHFromBox

r_traverseBVHFromBox = function(data, vector2: Vector3, callback)
	if not data then
		return
	end

	if not Utility.isPointInBox(vector2, data.cframe, data.size) then
		return nil
	end

	if not (data.left or data.right) then
		return callback(data) and data or nil
	end

	local v

	if data.left then
		v = r_traverseBVHFromBox(data.left, vector2, callback) or nil
	end

	return v or data.right and r_traverseBVHFromBox(data.right, vector2, callback) or nil
end

local function getBoundingBox(items)
	local vector2 = createVector(1e999, 1e999, 1e999)
	local vector3 = createVector(-1e999, -1e999, -1e999)

	for _, item in items do
		local cframe = item.cframe
		local v = item.size * 0.5

		for _, v2 in {
			(cframe * CFrame.new(-v.X, -v.Y, -v.Z)).Position,
			(cframe * CFrame.new(v.X, -v.Y, -v.Z)).Position,
			(cframe * CFrame.new(-v.X, v.Y, -v.Z)).Position,
			(cframe * CFrame.new(v.X, v.Y, -v.Z)).Position,
			(cframe * CFrame.new(-v.X, -v.Y, v.Z)).Position,
			(cframe * CFrame.new(v.X, -v.Y, v.Z)).Position,
			(cframe * CFrame.new(-v.X, v.Y, v.Z)).Position,
			(cframe * CFrame.new(v.X, v.Y, v.Z)).Position
		} do
			vector2 = Vector3.new(math.min(vector2.X, v2.X), math.min(vector2.Y, v2.Y), (math.min(vector2.Z, v2.Z)))
			vector3 = Vector3.new(math.max(vector3.X, v2.X), math.max(vector3.Y, v2.Y), (math.max(vector3.Z, v2.Z)))
		end
	end

	local v = vector3 - vector2
	local midpoint = (vector2 + vector3) / 2
	return CFrame.new(midpoint), v
end

local function determine(p, p2: string, boxes)
	if #boxes > 1 then
		local boundingBox, size = getBoundingBox(boxes)
		p[p2] = {
			boxes = boxes,
			cframe = boundingBox,
			size = size
		}
		split(p[p2])
	elseif #boxes == 1 then
		local v = boxes[1]
		p[p2] = {
			boxes = boxes,
			cframe = v.cframe,
			size = v.size,
			part = v.part
		}
	end
end

function split(p)
	local size = p.size
	local v

	if size.X > size.Y and size.X > size.Z then
		v = "X"
	elseif size.Y > size.X and size.Y > size.Z then
		v = "Y"
	elseif size.Z > size.Y and size.Z > size.X then
		v = "Z"
	else
		v = "X"
	end

	table.sort(p.boxes, function(a, b)
		return a.cframe[v] < b.cframe[v]
	end)
	local count = #p.boxes
	local v2 = count // 2
	local boxes = { unpack(p.boxes, 1, v2) }
	local boxes2 = { unpack(p.boxes, v2 + 1, count) }
	determine(p, "left", boxes)
	determine(p, "right", boxes2)
end

function BVH.createBVH(boxes)
	local boundingBox, size = getBoundingBox(boxes)
	local v2 = {
		boxes = boxes,
		cframe = boundingBox,
		size = size
	}
	split(v2)
	local v3 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn(p2)
		if p2.left or p2.right then
			return true
		end

		table.insert(v3, p2)
		return false
	end

	if not v2 then
		return v2, v3
	end

	-- equivalent call inferred; original call site unknown
	if not fn(v2) then
		return v2, v3
	end

	if v2.left then
		traverseBVH(v2.left, fn)
	end

	if v2.right then
		traverseBVH(v2.right, fn)
	end

	return v2, v3
end

function BVH.createParallelShareableBVH(boxes)
	local boundingBox, size = getBoundingBox(boxes)
	local v2 = {
		boxes = boxes,
		cframe = boundingBox,
		size = size
	}
	split(v2)
	local v3 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn(p2)
		if p2.left or p2.right then
			return true
		end

		table.insert(v3, p2)
		return false
	end

	if not v2 then
		return v2, v3
	end

	-- equivalent call inferred; original call site unknown
	if not fn(v2) then
		return v2, v3
	end

	if v2.left then
		traverseBVH(v2.left, fn)
	end

	if v2.right then
		traverseBVH(v2.right, fn)
	end

	return v2, v3
end

BVH.traverseBVH = traverseBVH

function BVH.getBoxFromPosition(p, vector2: Vector3, _: boolean)
	return r_traverseBVHFromBox(p, vector2, function(p2)
		if Utility.isPointInBox(vector2, p2.cframe, p2.size) then
			return p2
		end

		return nil
	end)
end

function BVH.getNodeFromPosition(p, vector2: Vector3)
	BVH.traverseBVH(p, function(data)
		task.wait(1)
		local _ = data.cframe.Position - vector2

		if data.right or data.left or Utility.isPointInBox(vector2, data.cframe, data.size) then
			return true
		end

		return false
	end)
end

function BVH.visualize(p)
	local function fn(state)
		local part = Instance.new("Part")
		part.Anchored = true
		part.Transparency = 1
		part.CFrame = state.cframe
		part.Size = state.size
		part.Parent = workspace
		part.CanCollide = false
		part.CanQuery = false
		state.debugPart = part

		if not (state.right or state.left) then
			part.Color = Color3.fromRGB(255, 0, 0)
			part.Transparency = 1
		end

		return true
	end

	if not (p and fn(p)) then
		return
	end

	if p.left then
		traverseBVH(p.left, fn)
	end

	if p.right then
		traverseBVH(p.right, fn)
	end
end

return BVH