local createVector = vector.create
local v = os.time() - tick()
local v2 = {}
local v3 = {}

local function isTideEnabled()
	return script.Parent:GetAttribute("Enabled") == true
end

local function getHourlyDipValueSmooth()
	if script.Parent:GetAttribute("Enabled") ~= true then
		return -2162.033
	end

	local v4 = (tick() + v) % 80

	if v4 < 10 then
		return -2174.033 + 12 * (1 - v4 / 10)
	end

	if v4 < 40 then
		return -2174.033
	end

	if v4 < 50 then
		return -2174.033 + 12 * ((v4 - 40) / 10)
	end

	return -2162.033
end

local function resort()
	local v4 = {}
	local v5 = {}

	for k, v6 in v2 do
		if not v6 then
			continue
		end

		table.insert(v4, v6)
		v5[v6] = k
	end

	table.sort(v4, function(a, b)
		return a.Scale.Magnitude < b.Scale.Magnitude
	end)
	local v6 = {}

	for k, v7 in v4 do
		local position = v7.Position
		local vector2 = v7.Scale * 0.5
		v6[k] = {
			Name = v5[v7],
			MinX = position.X - vector2.X,
			MaxX = position.X + vector2.X,
			MinY = position.Y - vector2.Y,
			MaxY = position.Y + vector2.Y,
			MinZ = position.Z - vector2.Z,
			MaxZ = position.Z + vector2.Z,
			WaterHeight = v7.WaterHeight
		}
	end

	v3 = v6
end

task.spawn(function()
	local submergedIsland = workspace._WorldOrigin.Locations:WaitForChild("Submerged Island", 900)
	v2["Submerged Island"] = submergedIsland and {
		LocationInstance = submergedIsland,
		Position = submergedIsland.Position,
		Scale = submergedIsland.Mesh.Scale,
		WaterHeight = getHourlyDipValueSmooth
	} or nil
	resort()
end)
task.spawn(function()
	workspace._WorldOrigin.Locations:WaitForChild("Sealed Cavern", 900)
	local v4 = 1

	for _, child in workspace._WorldOrigin.Locations:GetChildren() do
		if child.Name ~= "Sealed Cavern" then
			continue
		end

		v2["Sealed Cavern" .. v4] = {
			LocationInstance = child,
			Position = child.Position,
			Scale = child.Mesh.Scale * 2,
			WaterHeight = function()
				return -2173.033
			end
		}
		resort()
		v4 += 1
	end
end)
task.spawn(function()
	local locations = workspace._WorldOrigin:WaitForChild("Locations")

	local function addObservatory(locationInstance)
		v2.Observatory = {
			LocationInstance = locationInstance,
			Position = locationInstance.Position,
			Scale = not locationInstance.Mesh and createVector(1, 1, 1) or locationInstance.Mesh.Scale or createVector(
				1,
				1,
				1
			),
			WaterHeight = function()
				return locationInstance.Position.Y - 300
			end
		}
		resort()
	end

	local observatory = locations:FindFirstChild("Observatory")

	if observatory then
		addObservatory(observatory)
	end

	locations.ChildAdded:Connect(function(child)
		if child.Name == "Observatory" then
			child:WaitForChild("Mesh", 3)
			addObservatory(child)
		end
	end)
	locations.ChildRemoved:Connect(function(child)
		if child.Name == "Observatory" then
			v2.Observatory = nil
			resort()
		end
	end)
end)
task.spawn(function()
	local SewerSystem = require(game.ReplicatedStorage.Modules.World.SewerSystem)
	local part = workspace._WorldOrigin.Locations:WaitForChild(SewerSystem.LOCATION_NAME, 900)

	if not (part and part:IsA("BasePart")) then
		return
	end

	local mesh = part:WaitForChild("Mesh", 30)

	if mesh and mesh:IsA("SpecialMesh") then
		v2[SewerSystem.LOCATION_NAME] = {
			LocationInstance = part,
			Position = part.Position,
			Scale = mesh.Scale,
			WaterHeight = function()
				return part.Position.Y - mesh.Scale.Y / 2
			end
		}
		resort()
	end
end)
task.spawn(function()
	local sharkmanArena = workspace._WorldOrigin.Locations:WaitForChild("Sharkman Arena", 900)
	v2["Sharkman Arena"] = sharkmanArena and {
		LocationInstance = sharkmanArena,
		Position = sharkmanArena.Position,
		Scale = sharkmanArena.Mesh.Scale,
		WaterHeight = function()
			return sharkmanArena.Position.Y - 50
		end
	} or nil
	resort()
end)
local Legacy = {}

for _, v4 in { "Oni Realm", "Celestial Domain" } do
	local v5 = v4
	task.spawn(function()
		local child = workspace._WorldOrigin.Locations:WaitForChild(v5, 900)
		v2[v5] = child and {
			LocationInstance = child,
			Position = child.Position,
			Scale = child.Mesh.Scale,
			WaterHeight = function()
				return -9164.033
			end
		} or nil
		resort()
	end)

	for _, v6 in { " (Interior)", " <Interior>" } do
		local v7 = v4
		local v8 = v6
		task.spawn(function()
			local child = workspace._WorldOrigin.Locations:WaitForChild(v7 .. v8, 900)
			v2[v7 .. v8] = child and {
				LocationInstance = child,
				Position = child.Position,
				Scale = child.Mesh.Scale,
				WaterHeight = function()
					return -15000
				end
			} or nil
			resort()
		end)
	end
end

function Legacy.getHeight(p: number, p2: number, p3: number)
	for _, v4 in v3 do
		if v4.MinY < p2 and p2 < v4.MaxY and v4.MinX < p and p < v4.MaxX and v4.MinZ < p3 and p3 < v4.MaxZ then
			return v4.WaterHeight(), v4.Name
		end
	end

	return nil, nil
end

return Legacy