local createVector = vector.create
local Workspace = game:GetService("Workspace")
local Config = require(script.Config)
require(script.Types)
local RayDebug = {}
local merged = Config.default()
local v = false
local v2 = nil
local v3 = {}
local v4 = {}
local v5 = 0

local function resolveFolder()
	local v6 = v2

	if v6 ~= nil and v6.Parent ~= nil then
		return v6
	end

	local folder = Instance.new("Folder")
	folder.Name = merged.folderName
	folder.Parent = Workspace
	v2 = folder
	return folder
end

local function buildPart(shape)
	local part = Instance.new("Part")
	part.Shape = shape
	part.Size = createVector(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Locked = true
	part.Material = Enum.Material.Neon
	part.Transparency = 1
	local parent = v2

	if parent == nil or parent.Parent == nil then
		parent = Instance.new("Folder")
		parent.Name = merged.folderName
		parent.Parent = Workspace
		v2 = parent
	end

	part.Parent = parent
	return part
end

local function acquire()
	local v6 = table.remove(v4)

	if v6 ~= nil then
		return v6
	end

	local block = Enum.PartType.Block
	local part = Instance.new("Part")
	part.Shape = block
	part.Size = createVector(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Locked = true
	part.Material = Enum.Material.Neon
	part.Transparency = 1
	local parent = v2

	if parent == nil or parent.Parent == nil then
		parent = Instance.new("Folder")
		parent.Name = merged.folderName
		parent.Parent = Workspace
		v2 = parent
	end

	part.Parent = parent
	local ball = Enum.PartType.Ball
	local part2 = Instance.new("Part")
	part2.Shape = ball
	part2.Size = createVector(1, 1, 1)
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.CastShadow = false
	part2.Locked = true
	part2.Material = Enum.Material.Neon
	part2.Transparency = 1
	local parent2 = v2

	if parent2 == nil or parent2.Parent == nil then
		parent2 = Instance.new("Folder")
		parent2.Name = merged.folderName
		parent2.Parent = Workspace
		v2 = parent2
	end

	part2.Parent = parent2
	return {
		beam = part,
		marker = part2
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function release(visual)
	visual.beam.Transparency = 1
	visual.marker.Transparency = 1
	table.insert(v4, visual)
end

local function resolveEntry(p: string)
	local v6 = v3[p]

	if not v then
		return nil
	end

	if v6 ~= nil then
		return v6
	end

	if not (v5 < merged.maxParts) then
		return nil
	end

	local v7 = {
		visual = acquire(),
		touchedAt = 0
	}
	v3[p] = v7
	v5 += 1
	return v7
end

local function applyDraw(p, vector2: Vector3, vector3: Vector3, raycastResult: RaycastResult?, missColor: Color3?)
	local v6 = merged
	local position

	if raycastResult == nil then
		position = vector2 + vector3
	else
		position = raycastResult.Position
	end

	local v7 = position - vector2
	local v8 = not (v7.Magnitude > 0.05) and createVector(0, 0, 1) or v7.Unit
	local v9 = math.max(v7.Magnitude, 0.05)
	local beam = p.visual.beam
	local marker = p.visual.marker
	beam.Size = Vector3.new(v6.thickness, v6.thickness, v9)
	beam.CFrame = CFrame.lookAt(vector2 + v8 * (v9 * 0.5), vector2 + v8 * v9)

	if raycastResult == nil then
		if missColor == nil then
			missColor = v6.missColor
		end
	else
		missColor = v6.hitColor
	end

	beam.Color = missColor
	beam.Transparency = v6.transparency
	marker.Size = createVector(1, 1, 1) * v6.markerSize
	marker.CFrame = CFrame.new(position)
	marker.Color = v6.hitColor
	marker.Transparency = raycastResult == nil and 1 or v6.transparency
	p.touchedAt = os.clock()
end

function RayDebug.configure(p)
	merged = Config.merge(merged, p)
end

function RayDebug.getConfig()
	return merged
end

function RayDebug.draw(p: string, vector2: Vector3, vector3: Vector3, raycastResult: RaycastResult?, color: Color3?)
	local v6 = v3[p]

	if v then
		if v6 == nil then
			if v5 < merged.maxParts then
				v6 = {
					visual = acquire(),
					touchedAt = 0
				}
				v3[p] = v6
				v5 += 1
			else
				v6 = nil
			end
		end
	else
		v6 = nil
	end

	if v6 ~= nil then
		applyDraw(v6, vector2, vector3, raycastResult, color)
	end
end

function RayDebug.step()
	local v6 = os.clock() - merged.lifetime

	for k, v7 in v3 do
		if not (v7.touchedAt < v6) then
			continue
		end

		release(v7.visual) -- equivalent call inferred; original call site unknown
		v3[k] = nil
		v5 -= 1
	end
end

function RayDebug.clear()
	for k, v6 in v3 do
		release(v6.visual) -- equivalent call inferred; original call site unknown
		v3[k] = nil
	end

	v5 = 0
end

function RayDebug.setEnabled(flag: boolean)
	v = flag

	if not flag then
		RayDebug.clear()
	end
end

function RayDebug.isEnabled()
	return v
end

function RayDebug.destroy()
	local v6 = v2
	RayDebug.clear()
	table.clear(v4)

	if v6 ~= nil then
		v6:Destroy()
		v2 = nil
	end
end

return RayDebug