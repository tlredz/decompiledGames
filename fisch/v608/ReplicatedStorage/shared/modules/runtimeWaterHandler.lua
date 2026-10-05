local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = ReplicatedStorage.world.use_part_water.Value and RunService:IsStudio()
local folder = Instance.new("Folder")
folder.Name = "PartWater"

if not RunService:IsServer() then
	return
end

local camera = Instance.new("Camera")
camera.Name = "ServerNoReplicateWater"
camera.Parent = workspace.Terrain
folder.Parent = camera
local v2 = {}
local v3 = {
	surface = {},
	bottom = {}
}
local v4 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function createStandInSurface(p, vector2: Vector3)
	if v then
		return
	end

	local clone = script.StandInWater:Clone()
	clone.CFrame = CFrame.new(vector2.X * 256, p.upperY, vector2.Y * 256)
	clone.Size = createVector(256, 0.05, 256)
	clone.Parent = folder
	return clone
end

local function queueChunkGeneration(p, vector2: Vector3, isPreloaded: boolean?)
	if v2[vector2] then
		return
	end

	local v5 = vector2 * 256
	local v6 = v4[vector2]
	v2[vector2] = true
	local surface = v3.surface
	local v7 = {
		cframe = CFrame.new(v5.X, p.upperY - 2, v5.Y),
		size = createVector(256, 4, 256),
		part = 0,
		isPreloaded = 0
	}
	local standInSurface = createStandInSurface(p, vector2) -- equivalent call inferred; original call site unknown
	v7.part = standInSurface
	v7.isPreloaded = isPreloaded
	table.insert(surface, v7)
	local lowerY = p.lowerY

	if v6 and v6.addLowerY then
		lowerY += v6.addLowerY
	end

	local v8 = p.upperY - 2
	local v9 = v8 - (v8 - lowerY) / 2
	table.insert(v3.bottom, {
		cframe = CFrame.new(v5.X, v9, v5.Y),
		size = Vector3.new(256, p.upperY - lowerY - 4, 256),
		isPreloaded = isPreloaded
	})
end

workspace:WaitForChild("world"):WaitForChild("water"):WaitForChild("seaVolumes"):WaitForChild("MainSea")
local v5 = {}
local v6 = {}
local v7 = false

for _, child in workspace.world.water.customChunkConfig:GetChildren() do
	local _ = child.sea.Value
	local v8 = (child.Position - child.Size / 2) // 256 + createVector(1, 1, 1)
	local v9 = (child.Position + child.Size / 2) // 256

	for i = v8.X, v9.X do
		for i2 = v8.Z, v9.Z do
			v4[Vector3.new(i, i2)] = {
				addLowerY = child.addLowerY.Value
			}
		end
	end
end

for _, part in workspace.world.water.seaVolumes:GetChildren() do
	if not part:IsA("Part") then
		continue
	end

	part.Transparency = 1
	local v8 = part.Size * part.Mesh.Scale
	local cFrame = part.CFrame
	table.insert(v5, {
		upperY = cFrame.Y + v8.Y / 2,
		lowerY = cFrame.Y - v8.Y / 2,
		bounds = v8 / 2,
		cframe = cFrame
	})

	for _, part2 in workspace.world.water.preloads:GetChildren() do
		if not (part2:IsA("Part") and part2.Name == part.Name) then
			continue
		end

		local vector2 = Vector3.new(part2.Position.X // 256, part2.Position.Z // 256)

		for i = -4, 4 do
			for i2 = -4, 4 do
				queueChunkGeneration(v5[#v5], Vector3.new(vector2.X + i, vector2.Y + i2), true)
			end
		end
	end
end

for _, part in workspace.world.water.partToTerrain:GetChildren() do
	if not part:IsA("Part") then
		continue
	end

	table.insert(v3.surface, {
		cframe = part.CFrame,
		size = part.Size,
		isPreloaded = true
	})
	part.Transparency = 1
end

workspace.world.water.partToTerrain.ChildAdded:Connect(function(part)
	if not part:IsA("Part") then
		return
	end

	table.insert(v3.surface, {
		cframe = part.CFrame,
		size = part.Size,
		isPreloaded = true
	})
	part.Transparency = 1
end)
local character, humanoidRootPart, position, v8, v9, vector2, count, cframe, size, part, v10, v11, players, humanoidRootPart2, magnitude, clone, flag

if v then
	warn("USING PART WATER AS THE SETTING IS ENABLED")
end

while true do
	for _, v12 in Players:GetPlayers() do
		character = v12.Character

		if not character then
			continue
		end

		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			continue
		end

		position = humanoidRootPart.Position
		v8 = nil

		for _, v14 in v5 do
			v9 = v14.cframe.Position - position

			if not (v9.X < v14.bounds.X and v9.X > -v14.bounds.X and v9.Z < v14.bounds.X and v9.Z > -v14.bounds.Z) then
				continue
			end

			v8 = v14
			break
		end

		if not v8 then
			continue
		end

		vector2 = Vector3.new(position.X // 256, position.Z // 256)

		if v6[vector2] then
			continue
		end

		v6[vector2] = true
		queueChunkGeneration(v8, vector2)

		for i = -4, 4 do
			for i2 = -4, 4 do
				queueChunkGeneration(v8, (Vector3.new(vector2.X + i, vector2.Y + i2)))
			end
		end
	end

	task.wait(0.03)
	count = 0

	for _ = 1, 10 do
		if count > 2 then
			break
		end

		cframe = nil
		size = nil
		part = nil

		if v3.surface[1] then
			v10 = 1
			v11 = 99999999

			if RunService:IsServer() then
				players = Players:GetPlayers()
			else
				players = { Players.LocalPlayer }
			end

			for k, v13 in v3.surface do
				for _, player in players do
					humanoidRootPart2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart2 then
						continue
					end

					magnitude = (humanoidRootPart2.Position - v13.cframe.Position).Magnitude

					if not (magnitude < v11) then
						continue
					end

					v10 = k
					v11 = magnitude
				end

				if v11 < 512 then
					break
				end
			end

			cframe = v3.surface[v10].cframe
			size = v3.surface[v10].size
			part = v3.surface[v10].part
			table.remove(v3.surface, v10)
		elseif v3.bottom[1] then
			cframe = v3.bottom[1].cframe
			size = v3.bottom[1].size
			table.remove(v3.bottom, 1)
			count += 1
		end

		if not cframe then
			break
		end

		if v then
			clone = script.StandInWater:Clone()
			clone.CFrame = cframe
			clone.Size = size
			clone.Parent = folder
			clone:AddTag("PartWater")
		else
			if part then
				part:Destroy()
			end

			if not pcall(function()
				workspace.Terrain:FillBlock(cframe, size, Enum.Material.Water)
			end) then
				print("failed at", cframe)
			end
		end
	end

	if v7 then
		continue
	end

	flag = true

	for _, v13 in v3.surface do
		if not v13.isPreloaded then
			continue
		end

		flag = false
		break
	end

	for _, v14 in v3.bottom do
		if not v14.isPreloaded then
			continue
		end

		flag = false
		break
	end

	if not flag then
		continue
	end

	v7 = true

	for _, child in workspace.world.water.neverGenerate:GetChildren() do
		workspace.Terrain:FillBlock(child.CFrame, child.Size, Enum.Material.Air)
	end
end