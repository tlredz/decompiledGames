local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Locator = require(script.Locator)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local RunService = game:GetService("RunService")
local AreaLocator = {
	CurrentAreas = Locator.Areas,
	AreaEquipped = {
		Parent = "",
		Sub = "",
		Update = simplesignal.new(),
		Biome = nil,
		BiomeUpdate = simplesignal.new(),
		Cave = false,
		Village = false,
		NoPvpSwitch = false
	}
}
local isClient = RunService:IsClient()
local MarkerHandler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("MarkerHandler"))
local v = nil
local v2 = nil
local v3 = false
local v4 = {}
local v5 = false

local function rebuildMarkers(childName, p, p2)
	local v6 = {}

	if workspace.Debree:FindFirstChild("Regions") then
		local child = workspace.Debree.Regions:FindFirstChild(childName)

		if child then
			for _, child2 in child.StationaryNpcs:GetChildren(), nil, nil do
				local marker = child2:GetAttribute("Marker")

				if not (marker == p or marker == childName or marker == true and p2 ~= true) then
					continue
				end

				local head

				if child2:GetAttribute("IdleNpc") == true then
					head = child2:FindFirstChild("Head") or nil
				end

				v6[child2.Name .. "-AddedByAreaLocator"] = {
					Icon = child2:GetAttribute("Icon") or "",
					Position = head or child2:GetAttribute("Top") or Vector3.new(),
					Offset = head ~= nil and createVector(0, 1, 0) or nil
				}
			end

			for _, child2 in child:GetChildren(), nil, nil do
				local spawnArea = child2:GetAttribute("SpawnArea")

				if spawnArea == p or spawnArea == childName and p2 ~= true then
					v6[`SpawnCrystal-{spawnArea}-AddedByAreaLocator`] = {
						Icon = "rbxassetid://117691051732311",
						Position = child2:GetPivot().Position + createVector(0, 3, 0)
					}
				end
			end
		end
	end

	for k in v4 do
		if v6[k] == nil then
			MarkerHandler.removeMarker(k)
		end
	end

	for k, v7 in v6 do
		if not v4[k] then
			MarkerHandler.addMarker(k, {
				markerType = MarkerHandler.markerType.Both,
				offScreenMode = MarkerHandler.offScreenMode.Compass,
				img = v7.Icon,
				transparency = 0.25,
				position = v7.Position,
				offset = v7.Offset,
				minDistance = 5,
				margin = 15,
				color = Color3.new(0.184314, 0.239216, 0.286275),
				in3DSpace = true
			})
		end
	end

	v4 = v6
end

local connections = {}
local v6 = nil

local function watchRegion(childName)
	if v6 == childName then
		return
	end

	v6 = childName

	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
	local regions = workspace.Debree:FindFirstChild("Regions")
	local child = regions and regions:FindFirstChild(childName)
	local stationaryNpcs = child and child:FindFirstChild("StationaryNpcs")

	if stationaryNpcs == nil then
		return
	end

	local function onChange()
		task.defer(function()
			rebuildMarkers(AreaLocator.AreaEquipped.Parent, AreaLocator.AreaEquipped.Sub, v5)
		end)
	end

	table.insert(connections, stationaryNpcs.ChildAdded:Connect(onChange))
	table.insert(connections, stationaryNpcs.ChildRemoved:Connect(onChange))
end

function AreaLocator.Update(_, instance)
	local position = instance.Position
	local v7, v8, v9, v10, v11, v12, v13 = Locator.Find(
		Vector2.new(position.X, position.Z),
		AreaLocator.CurrentAreas,
		position.Y
	)
	local parent = instance.Parent
	local biome = Locator.FindBiome(position)

	if parent ~= nil and parent:GetAttribute("InMuzanLair") == true then
		biome = nil
		v7 = "Muzan's Lair"
		v10 = false
		v8 = "Muzan's Lair"
		v11 = true
		v12 = false
		v9 = false
	end

	if AreaLocator.AreaEquipped.Biome ~= biome then
		local biome2 = AreaLocator.AreaEquipped.Biome
		AreaLocator.AreaEquipped.Biome = biome
		AreaLocator.AreaEquipped.BiomeUpdate:Fire(biome, biome2)
	end

	if v7 == nil or v8 == nil then
		v8 = Locator.DefaultAreaName(position)
		v7 = v8
		v11 = false
		v12 = false
		v9 = false
	end

	if v8 == nil then
		v8 = v7
	end

	if AreaLocator.AreaEquipped.Parent ~= v8 or AreaLocator.AreaEquipped.Sub ~= v7 then
		AreaLocator.AreaEquipped.Parent = v8
		AreaLocator.AreaEquipped.Sub = v7
		AreaLocator.AreaEquipped.Cave = v11 == true
		AreaLocator.AreaEquipped.Village = v12 == true
		AreaLocator.AreaEquipped.NoPvpSwitch = v13 == true

		if isClient then
			if (v ~= v8 or v2 ~= v7) and not v9 and v3 ~= true then
				game.ReplicatedStorage.Communication.CnC.Notifications.BottomCenterNotification:Fire("LocationChange", {
					Text = v8,
					SubText = v7
				})
			end

			v = v8
			v2 = v7
		end

		v3 = v9 == true
		AreaLocator.AreaEquipped.Update:Fire(v8, v7)
		v5 = v10 == true
		rebuildMarkers(v8, v7, v5)

		if isClient then
			watchRegion(v8)
		end
	end
end

return AreaLocator