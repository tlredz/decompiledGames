local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarkerHandler = require(ReplicatedStorage.CAM.Client.Modules.MarkerHandler)
local color = Color3.fromRGB(195, 140, 255)
local v = {}

local function anchorsFolder()
	local v2 = workspace:FindFirstChild("TrackedSpawnAnchors")

	if v2 == nil then
		v2 = Instance.new("Folder")
		v2.Name = "TrackedSpawnAnchors"
		v2.Parent = workspace
	end

	return v2
end

local function markerKey(p: string)
	return (`Tracked_{p}`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function remove(p: string)
	local v2 = v[p]

	if v2 == nil then
		return
	end

	v[p] = nil
	MarkerHandler.removeMarker((`Tracked_{p}`))
	v2:Destroy()
end

local function add(p: string, position)
	remove(p) -- equivalent call inferred; original call site unknown
	local part = Instance.new("Part")
	part.Name = `Tracked_{p}`
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Position = position.Position
	local parent = workspace:FindFirstChild("TrackedSpawnAnchors")

	if parent == nil then
		parent = Instance.new("Folder")
		parent.Name = "TrackedSpawnAnchors"
		parent.Parent = workspace
	end

	part.Parent = parent
	v[p] = part
	MarkerHandler.addMarker(`Tracked_{p}`, {
		markerType = MarkerHandler.markerType.Regular,
		img = position.Icon,
		position = part,
		tag = "Default",
		displayDistance = true,
		minDistance = 20,
		margin = 10,
		indicator = true,
		indicatorColor = color,
		onMap = true,
		ping = color,
		kind = "TrackedSpawn"
	})
end

return function(p: string, p2: string, position)
	if p2 == nil then
		return
	end

	if p == "Add" and position ~= nil and position.Position ~= nil then
		add(p2, position)
	elseif p == "Move" and typeof(position) == "Vector3" then
		local v2 = v[p2]

		if v2 ~= nil then
			v2.Position = position
		end
	elseif p == "Remove" then
		remove(p2) -- equivalent call inferred; original call site unknown
	end
end