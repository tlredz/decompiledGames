local GJK = require(script:WaitForChild("GJK"))
local Supports = require(script:WaitForChild("Supports"))
local Vertices = require(script:WaitForChild("Vertices"))
local RotatedRegion3 = {}
RotatedRegion3.__index = RotatedRegion3

local function worldBoundingBox(list)
	local v = {}
	local v2 = {}
	local zes = {}

	for i = 1, #list do
		local x = list[i].x
		local y = list[i].y
		local z = list[i].z
		v[i] = x
		v2[i] = y
		zes[i] = z
	end

	return
		Vector3.new(math.min(unpack(v)), math.min(unpack(v2)), (math.min(unpack(zes)))),
		(Vector3.new(math.max(unpack(v)), math.max(unpack(v2)), (math.max(unpack(zes)))))
end

function RotatedRegion3.new(cFrame, size)
	local object = setmetatable({}, RotatedRegion3)
	local block = Vertices.Block(cFrame, size / 2)
	object.CFrame = cFrame
	object.Size = size
	object.Shape = "Block"
	object.Set = block
	object.Support = Supports.PointCloud
	object.Centroid = cFrame.p
	object.AlignedRegion3 = Region3.new(worldBoundingBox(block))
	return object
end

RotatedRegion3.Block = RotatedRegion3.new

function RotatedRegion3.Wedge(cFrame, size)
	local self = setmetatable({}, RotatedRegion3)
	local block = Vertices.Block(cFrame, size / 2)
	self.CFrame = cFrame
	self.Size = size
	self.Shape = "Wedge"
	self.Set = Vertices.Wedge(cFrame, size / 2)
	self.Support = Supports.PointCloud
	self.Centroid = Vertices.GetCentroid(self.Set)
	self.AlignedRegion3 = Region3.new(worldBoundingBox(block))
	return self
end

function RotatedRegion3.CornerWedge(cFrame, size)
	local self = setmetatable({}, RotatedRegion3)
	local block = Vertices.Block(cFrame, size / 2)
	self.CFrame = cFrame
	self.Size = size
	self.Shape = "CornerWedge"
	self.Set = Vertices.CornerWedge(cFrame, size / 2)
	self.Support = Supports.PointCloud
	self.Centroid = Vertices.GetCentroid(self.Set)
	self.AlignedRegion3 = Region3.new(worldBoundingBox(block))
	return self
end

function RotatedRegion3.Cylinder(cFrame, size)
	local object = setmetatable({}, RotatedRegion3)
	local block = Vertices.Block(cFrame, size / 2)
	object.CFrame = cFrame
	object.Size = size
	object.Shape = "Cylinder"
	object.Set = { cFrame, size / 2 }
	object.Support = Supports.Cylinder
	object.Centroid = cFrame.p
	object.AlignedRegion3 = Region3.new(worldBoundingBox(block))
	return object
end

function RotatedRegion3.Ball(cFrame, size)
	local object = setmetatable({}, RotatedRegion3)
	local block = Vertices.Block(cFrame, size / 2)
	object.CFrame = cFrame
	object.Size = size
	object.Shape = "Ball"
	object.Set = { cFrame, size / 2 }
	object.Support = Supports.Ellipsoid
	object.Centroid = cFrame.p
	object.AlignedRegion3 = Region3.new(worldBoundingBox(block))
	return object
end

function RotatedRegion3.FromPart(instance)
	return RotatedRegion3[Vertices.Classify(instance)](instance.CFrame, instance.Size)
end

function RotatedRegion3.CastPoint(data, p)
	return GJK.new(data.Set, { p }, data.Centroid, p, data.Support, Supports.PointCloud):IsColliding()
end

function RotatedRegion3:CastPart(p)
	local v = RotatedRegion3.FromPart(p)
	return GJK.new(self.Set, v.Set, self.Centroid, v.Centroid, self.Support, v.Support):IsColliding()
end

function RotatedRegion3:FindPartsInRegion3(p, p2)
	local partsInRegion3 = game.Workspace:FindPartsInRegion3(self.AlignedRegion3, p, p2)
	local result = {}

	for i = 1, #partsInRegion3 do
		if self:CastPart(partsInRegion3[i]) then
			table.insert(result, partsInRegion3[i])
		end
	end

	return result
end

function RotatedRegion3:FindPartsInRegion3WithIgnoreList(options, p)
	local partsInRegion3 = game.Workspace:FindPartsInRegion3WithIgnoreList(self.AlignedRegion3, options or {}, p)
	local result = {}

	for i = 1, #partsInRegion3 do
		if self:CastPart(partsInRegion3[i]) then
			table.insert(result, partsInRegion3[i])
		end
	end

	return result
end

function RotatedRegion3:FindPartsInRegion3WithWhiteList(options, p)
	local partsInRegion3 = game.Workspace:FindPartsInRegion3WithWhiteList(self.AlignedRegion3, options or {}, p)
	local result = {}

	for i = 1, #partsInRegion3 do
		if self:CastPart(partsInRegion3[i]) then
			table.insert(result, partsInRegion3[i])
		end
	end

	return result
end

function RotatedRegion3:FindPartsInRegion3WithWhitelist(options, p)
	local partsInRegion3 = game.Workspace:FindPartsInRegion3WithWhiteList(self.AlignedRegion3, options or {}, p)
	local result = {}

	for i = 1, #partsInRegion3 do
		if self:CastPart(partsInRegion3[i]) then
			table.insert(result, partsInRegion3[i])
		end
	end

	return result
end

function RotatedRegion3:Cast(p, p2)
	return self:FindPartsInRegion3WithIgnoreList(type(p) == "table" and p or { p }, p2)
end

return RotatedRegion3