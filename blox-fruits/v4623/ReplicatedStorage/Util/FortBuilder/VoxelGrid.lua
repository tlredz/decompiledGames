local createVector = vector.create
local VoxelGrid = {}
VoxelGrid.__index = VoxelGrid

function VoxelGrid.new(value: number?, vector2: Vector3?)
	local self = setmetatable({}, VoxelGrid)
	self.voxelSideLength = value or 4
	self.origin = vector2 or createVector(0, 0, 0)
	self._voxelDataStore = {}
	return self
end

local function getDebugPart(p: string, p2)
	local v = workspace:FindFirstChild(p .. "_Debug")

	if v ~= nil then
		return v
	end

	v = Instance.new("Part")
	v.Color = Color3.fromHSV(math.random(), 1, 1)
	v.CastShadow = false
	v.CanCollide = false
	v.CanTouch = false
	v.CanQuery = false
	v.Locked = true
	v.TopSurface = Enum.SurfaceType.Smooth
	v.BottomSurface = Enum.SurfaceType.Smooth
	v.Anchored = true
	v.Name = p .. "_Debug"
	v.Parent = p2 or workspace
	return v
end

local function visualizeVector(p: string, vector2: Vector3, vector3: Vector3, p2: number, p3: number)
	local debugPart = getDebugPart(p)
	local unit = vector3.Unit
	debugPart.Size = Vector3.new(p3, p3, p2)
	debugPart.CFrame = CFrame.lookAt(vector2, vector2 + unit * p2) * CFrame.new(0, 0, -p2 * 0.5 + 0.01 * math.random())
	debugPart.Material = Enum.Material.Neon

	if debugPart:GetAttribute("ColorAlreadySet") == nil then
		debugPart.Color = Color3.fromHSV(math.random(), 1, 1)
		debugPart:SetAttribute("ColorAlreadySet", true)
	end

	local debugPart2 = getDebugPart(p .. "_Arrowhead")
	debugPart2.Shape = Enum.PartType.Ball
	debugPart2.Size = Vector3.new(p3, p3, p3) * 2
	debugPart2.CFrame = CFrame.new(vector2 + unit * p2)
	debugPart2.Color = debugPart.Color
	debugPart2.Material = Enum.Material.Neon
	return debugPart
end

function VoxelGrid:WorldPositionToCell(vector2: Vector3)
	local v = vector2 - self.origin
	return (Vector3.new(
		math.floor(v.X / self.voxelSideLength),
		math.floor(v.Y / self.voxelSideLength),
		(math.floor(v.Z / self.voxelSideLength))
	))
end

function VoxelGrid:CellToWorldCorner(vector2: Vector3)
	local v = vector2.X * self.voxelSideLength
	local v2 = vector2.Y * self.voxelSideLength
	local v3 = vector2.Z * self.voxelSideLength
	return self.origin + Vector3.new(v, v2, v3)
end

function VoxelGrid:CellToWorldCenter(vector2: Vector3)
	local cellToWorldCorner = self:CellToWorldCorner(vector2)
	local v = self.voxelSideLength * 0.5
	return cellToWorldCorner + Vector3.new(v, v, v)
end

function VoxelGrid:CellToBoundingSurfaceWorldCenter(vector2: Vector3, vector3: Vector3)
	return self:CellToWorldCenter(vector2) + vector3 * self.voxelSideLength * 0.5
end

function VoxelGrid:WorldPositionToCellWorldCenter(vector2: Vector3)
	return self:CellToWorldCenter(self:WorldPositionToCell(vector2))
end

function VoxelGrid:_cellToKey(vector2: Vector3)
	return string.format("%d_%d_%d", vector2.X, vector2.Y, vector2.Z)
end

function VoxelGrid:GetVoxelData(vector2: Vector3)
	local _cellToKey = self:_cellToKey(vector2)
	return self._voxelDataStore[_cellToKey]
end

function VoxelGrid:SetVoxelData(vector2: Vector3, p)
	local _cellToKey = self:_cellToKey(vector2)
	self._voxelDataStore[_cellToKey] = p
end

function VoxelGrid:ClearVoxelData(vector2: Vector3)
	local _cellToKey = self:_cellToKey(vector2)
	self._voxelDataStore[_cellToKey] = nil
end

function VoxelGrid:ClearAllVoxelData()
	table.clear(self._voxelDataStore)
end

function VoxelGrid:GetVoxelDataAtWorld(vector2: Vector3)
	return self:GetVoxelData((self:WorldPositionToCell(vector2)))
end

function VoxelGrid:SetVoxelDataAtWorld(vector2: Vector3, p)
	self:SetVoxelData(self:WorldPositionToCell(vector2), p)
end

function VoxelGrid:DebugPrintAllData()
	for k, v in pairs(self._voxelDataStore) do
		print(k, v)
	end
end

function VoxelGrid:visualizeVoxelFromWorldPosition(vector2: Vector3)
	local cellToWorldCorner = self:CellToWorldCorner((self:WorldPositionToCell(vector2)))
	local voxelSideLength = self.voxelSideLength
	local debugPart = getDebugPart("Voxel")
	debugPart.Size = Vector3.new(voxelSideLength, voxelSideLength, voxelSideLength)
	debugPart.CFrame = CFrame.new(cellToWorldCorner + debugPart.Size * 0.5)
	debugPart.Transparency = 1
	local v = debugPart:FindFirstChildOfClass("SelectionBox")

	if not v then
		v = Instance.new("SelectionBox")
		v.Name = "VoxelSelectionBox"
		v.Adornee = debugPart
		v.Parent = debugPart
	end

	v.LineThickness = 0.05
	v.SurfaceColor3 = Color3.new(0, 1, 0)
	v.SurfaceTransparency = 1
	v.Color3 = Color3.new(0, 1, 0)
	return debugPart
end

return VoxelGrid