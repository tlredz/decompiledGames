local Teams = game:GetService("Teams")
local Map = require(game.ReplicatedStorage.Definitions.Map)
local WaitFor = require(game.ReplicatedStorage.Util.WaitFor)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("SpawnPoint"):display():traceback():build()
local currentMap = Map.findCurrentMap()
local v2 = {}
local islandEntries = {}
local pirates = Teams:WaitForChild("Pirates")
local marines = Teams:WaitForChild("Marines")
local localPlayer = game.Players.LocalPlayer
local lastSpawnPoint = localPlayer:WaitForChild("Data"):WaitForChild("LastSpawnPoint")
local character = game.Players.LocalPlayer.Character or script.Parent
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local function loadSpawnModel(model)
	local parent = model.Parent
	assert(parent, "bad team folder")
	v.trace((`loaded island model "{model}" for team "{parent}"`))
	local position = model:GetModelCFrame().Position
	local parts = {}

	for _, part in model:GetChildren() do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	local key = nil

	if currentMap then
		for _, v4 in Map.getIslandsByReference(currentMap, "PlayerSpawn", model.Name) do
			if table.find(v4.Tags, "Starter") then
				if v4.Index.Key == "Pirate Starter" and parent.Name == "Pirates" then
					key = v4.Index.Key
					break
				elseif v4.Index.Key == "Marine Starter" and parent.Name == "Marines" then
					key = v4.Index.Key
					break
				end
			else
				key = v4.Index.Key
			end
		end
	end

	table.insert(islandEntries, {
		Name = model.Name,
		Team = parent.Name == pirates.Name and pirates or marines,
		Position = position,
		Points = parts,
		IslandKey = key
	})
end

local function connectSpawns(name: string, position: Vector3, p: number)
	v2[name] = v2[name] or {}
	local count = 0
	local v3 = {}

	local function considerSpawn(p2)
		if (p2.Position - position).Magnitude <= p then
			count += 1
			v3[p2] = true
			table.insert(v2[name], p2)
			v.trace(function()
				return `added location to zone "{name}": `, p2
			end)
		end
	end

	for _, v4 in pairs(islandEntries) do
		if not ((v4.Position - position).Magnitude <= p) then
			continue
		end

		count += 1
		v3[v4] = true
		table.insert(v2[name], v4)
		local v5 = v4
		v.trace(function()
			return `added location to zone "{name}": `, v5
		end)
	end

	if currentMap then
		for _, v4 in Map.getIslandsByReference(currentMap, "Location", name) do
			for _, v5 in pairs(islandEntries) do
				if not v5.IslandKey or v5.IslandKey ~= v4.Index.Key or v3[v5] then
					continue
				end

				v3[v5] = true
				count += 1
				table.insert(v2[name], v5)
				local v6 = v5
				v.trace(function()
					return `added location to zone "{name}" from zone: `, v6
				end)
			end
		end
	end

	if count == 0 then
		v.warn((`couldn't find a single valid spawn for zone "{name}"`))
	end
end

v.info("booting")
WaitFor(workspace, "_WorldOrigin", "PlayerSpawns", "Marines")
WaitFor(workspace, "_WorldOrigin", "PlayerSpawns", "Pirates")
WaitFor(workspace, "_WorldOrigin", "Locations")
WaitFor(workspace, "_WorldOrigin", "EnemyRegions")

for _, child in pairs(workspace._WorldOrigin.PlayerSpawns:GetChildren()) do
	for _, model in pairs(child:GetChildren()) do
		if model:IsA("Model") then
			loadSpawnModel(model)
		end
	end

	child.ChildAdded:Connect(function(model)
		if model:IsA("Model") then
			loadSpawnModel(model)
		end
	end)
end

for _, part in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
	if part:IsA("BasePart") then
		v.trace((`adding zone "{part}"`))
		v2[part.Name] = v2[part.Name] or {}
		local mesh = part:FindFirstChild("Mesh")

		if mesh and mesh:IsA("SpecialMesh") then
			local v3 = part.Size.X * mesh.Scale.X / 2
			connectSpawns(part.Name, part.Position, v3)
		else
			v.warn((`no location mesh for "{part:GetFullName()}"`))
		end
	else
		v.warn((`not a part: "{part:GetFullName()}"`))
	end
end

for _, part in pairs(workspace._WorldOrigin.EnemyRegions:GetChildren()) do
	if part:IsA("BasePart") then
		part.Transparency = 1
	end
end

repeat
	task.wait(1)
until character:IsDescendantOf(workspace.Characters)

v.info("character loaded")

local function step()
	local extended = v.extend("step", true, "ERROR")
	extended.info("step")
	local v3 = 1e999
	local v4 = nil
	local v5 = 1e999
	local name = nil

	if not localPlayer.Team then
		extended.trace("returning, no team")
		return
	end

	for _, part in workspace._WorldOrigin.Locations:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local mesh = part:FindFirstChild("Mesh")

		if not (mesh and mesh:IsA("SpecialMesh")) then
			continue
		end

		local magnitude = (humanoidRootPart.Position - part.Position).Magnitude
		local v6 = mesh.Scale.X * part.Size.X / 2
		extended.trace((`location "{part}" distance ({math.round(magnitude * 10) / 10}) <= radius {math.round(v6 * 10) / 10}: {magnitude <= v6}`))

		if not (magnitude <= v6) then
			continue
		end

		if v2[part.Name] then
			local count = 0

			for _, v7 in pairs(v2[part.Name]) do
				if v7.Team ~= localPlayer.Team then
					continue
				end

				count += 1
				local magnitude2 = (humanoidRootPart.Position - v7.Position).Magnitude

				if not (magnitude2 < v5) then
					continue
				end

				extended.trace((`closest: "{v7.Name}"`))
				name = v7.Name
				v5 = magnitude2
			end

			if count == 0 then
				extended.warn((`location "{part.Name}" has an empty zone`))
			end
		else
			extended.warn((`no zone "{part.Name}"`))
		end
	end

	for _, part in workspace._WorldOrigin.EnemyRegions:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local mesh = part:FindFirstChild("Mesh")

		if not (mesh and mesh:IsA("SpecialMesh")) then
			continue
		end

		local magnitude = (humanoidRootPart.Position - part.Position).Magnitude

		if not (magnitude <= mesh.Scale.X * part.Size.X / 2) then
			continue
		end

		extended.trace((`within radius location for "{part}"`))

		if not (magnitude < v3) then
			continue
		end

		extended.trace((`closest location is now "{part}"`))
		v4 = part
		v3 = magnitude
	end

	if name and name ~= lastSpawnPoint.Value then
		extended.info((`invoking "SetLastSpawnPoint" for point {name}`))
		game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SetLastSpawnPoint", name)
	end

	local locationTag = localPlayer:FindFirstChild("LocationTag")

	if not locationTag or locationTag.Value ~= v4 then
		local info = extended.info
		local v7

		if v4 then
			v7 = v4:GetFullName() or nil
		end

		info((`firing "Location" for closestPoint {v7}`))
		game.ReplicatedStorage.Remotes.Location:FireServer(v4)
	end
end

while true do
	task.wait(1)
	local success, result = pcall(function()
		step()
	end)

	if not success then
		warn(result)
	end
end