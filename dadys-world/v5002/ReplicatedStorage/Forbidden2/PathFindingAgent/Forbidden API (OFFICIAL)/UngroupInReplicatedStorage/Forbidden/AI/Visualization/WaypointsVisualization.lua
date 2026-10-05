local createVector = vector.create
local Debris = game:GetService("Debris")
local parent = script.Parent.Parent.Parent
require(parent.AI.Types)
local ConfigHandler = require(parent.AI.ConfigHandler)
local Common = require(parent.Common)
local WaypointsVisualization = {}
local v = {}
local forbiddenStorageFolder = Common.GetForbiddenStorageFolder()
local folder = Instance.new("Folder")
folder.Name = "Visualization"
folder.Parent = forbiddenStorageFolder

local function CreateVisualizedParts(config, items)
	local function createPart(k: number, item)
		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Color = config.Visualization.PathColor
		part.Material = Enum.Material.Neon
		part.CFrame = CFrame.new(item.Position)
		part.Name = tostring(k)
		part.Anchored = true
		part.Size = createVector(1, 1, 1)
		part.CanCollide = false
		part.CanQuery = false
		return part
	end

	local result = {}

	for k, item in pairs(items) do
		table.insert(result, (createPart(k, item)))
	end

	return result
end

local function DeleteVisualizedParts(instance)
	for _, child in pairs(instance:GetChildren()) do
		Debris:AddItem(child, 0)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ParentVisualizedParts(instance, items)
	local parent2 = v[instance]

	for _, item in pairs(items) do
		item.Parent = parent2
	end
end

function WaypointsVisualization.VisualizeWaypoints(instance, p)
	local config = ConfigHandler.GetConfig(instance)

	if v[instance] then
		local visualizedParts = CreateVisualizedParts(config, p)
		DeleteVisualizedParts(v[instance])
		ParentVisualizedParts(instance, visualizedParts) -- equivalent call inferred; original call site unknown
	end

	if v[instance] then
		return v[instance]
	end

	local folder2 = Instance.new("Folder")
	folder2.Name = instance:GetFullName()
	folder2.Parent = folder
	v[instance] = folder2
	ParentVisualizedParts(instance, CreateVisualizedParts(config, p)) -- equivalent call inferred; original call site unknown
	return v[instance]
end

function WaypointsVisualization.DeleteVisualization(p)
	if p == nil or not v[p] or #v[p]:GetChildren() < 1 then
		return
	end

	DeleteVisualizedParts(v[p])
end

function WaypointsVisualization.TriggerCleanup(p)
	if not v[p] then
		return
	end

	DeleteVisualizedParts(v[p])
	v[p]:Destroy()
	v[p] = nil
end

return WaypointsVisualization