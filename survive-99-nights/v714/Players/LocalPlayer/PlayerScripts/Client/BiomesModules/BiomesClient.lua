local createVector = vector.create
local BiomesClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}
local v2 = nil

function AddBiomeZone(p)
	p.Touched:Connect(function() end)
end

function GetTouchingBiome()
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local touchingParts = humanoidRootPart:GetTouchingParts()

		for _, touchingPart in pairs(touchingParts) do
			local biomeName = touchingPart:GetAttribute("BiomeName")

			if biomeName and touchingPart:HasTag("BiomeZone") then
				return biomeName
			end
		end
	end
end

function UpdateCurrentBiome()
	task.spawn(function()
		while true do
			task.wait(0.5)
			CheckCurrentBiome()
		end
	end)
end

function CheckCurrentBiome()
	local position = workspace.CurrentCamera.CFrame.Position

	if workspace.CurrentCamera.CameraSubject then
		local parent = workspace.CurrentCamera.CameraSubject.Parent

		if parent then
			position = parent:GetPivot().Position
		end
	end

	local v3 = GetTouchingBiome() or BiomesClient.GetBiome(position)
	local zone = Client.ZoneModule.GetZone(position)

	if zone and zone ~= "Forest" then
		v3 = zone
	end

	local preloadLighting = localPlayer:GetAttribute("PreloadLighting")

	if preloadLighting then
		if preloadLighting == "Forest" and zone ~= "Forest" then
			v3 = nil
		else
			v3 = preloadLighting
		end
	end

	local v4 = Client.ChristmasDecorClient.InChristmasSafezone(position) and "ChristmasSafezone" or v3

	if v4 ~= v2 then
		v2 = v4
		BiomeEntered(v4)
	end
end

Client.Events.UpdateLighting:Connect(function()
	CheckCurrentBiome()
end)

function BiomeEntered(p)
	print("Entered biome", p)
	Client.Events.BiomeEntered:Fire(p)
end

function BiomesClient.GetCurrentBiome()
	return v2
end

function BiomesClient.ReloadBiomes()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function addBiome(child)
		local v3 = {}

		for k, v4 in pairs(child:GetAttributes()) do
			v3[k] = v4
		end

		v[child.Name] = v3
	end

	local biomes = workspace:WaitForChild("Map"):WaitForChild("Biomes")

	for _, child in pairs(biomes:GetChildren()) do
		addBiome(child) -- equivalent call inferred; original call site unknown
	end
end

function LoadBiomes()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function addBiome(child)
		local v3 = {}

		for k, v4 in pairs(child:GetAttributes()) do
			v3[k] = v4
		end

		v[child.Name] = v3
	end

	local biomes = workspace:WaitForChild("Map"):WaitForChild("Biomes")
	biomes.ChildAdded:Connect(addBiome)

	for _, child in pairs(biomes:GetChildren()) do
		addBiome(child) -- equivalent call inferred; original call site unknown
	end
end

function GetBiomeRadius(data, p)
	local unit = (p - data.Center).Unit
	local angleBetweenVectors, v3 = Client.Utility.GetAngleBetweenVectors(createVector(0, 0, -1), unit)
	local v4 = data.BiomeMaxRadius - data.BiomeMinRadius

	if v3 < 0 then
		angleBetweenVectors += 180
	end

	local v5 = math.abs(angleBetweenVectors)
	local midpoint = (math.noise(data.Seed, v5 * 2) + 1) / 2
	local midpoint2 = (math.noise(data.Seed, v5 * 10) + 1) / 2
	local v8 = math.clamp(midpoint * 0.5 + midpoint2 * 0.5, 0, 1)
	return data.BiomeMinRadius + v4 * v8
end

local function SeedAxis(p)
	return p * 0.6180339887 % 256
end

function GetAngularNoise(_, p, p2)
	local v3 = p2 * 0.6180339887 % 256
	local v4 = p / 120
	return (math.deg((math.atan((math.noise(v3, v4) + math.noise(v3 + 71.5, v4 * 2.03) * 0.5 + math.noise(
		v3 + 143.7,
		v4 * 4.07
	) * 0.25) / 1.75 * 2 * 120 / math.max(p, 1)))))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function EdgeGrain(p, p2, seed)
	local v3 = seed * 0.6180339887 % 256
	return math.noise(p / 43, p2 / 43, v3) * 2 * 55
end

local v3 = {
	{ 40, 0 },
	{ -40, 0 },
	{ 0, 40 },
	{ 0, -40 },
	{ 40, 40 },
	{ 40, -40 },
	{ -40, 40 },
	{ -40, -40 }
}

local function InWedge(data, p, p2)
	local vector2 = Vector3.new(p, 0, p2)
	local magnitude = vector2.Magnitude

	if magnitude < data.BiomeMinRadius then
		return false
	end

	local unit = (data.Center * createVector(1, 0, 1)).Unit
	local angleBetweenVectors, v4 = Client.Utility.GetAngleBetweenVectors(unit, vector2.Unit)
	local v5 = math.deg(angleBetweenVectors) * v4
	return math.rad(data.WedgeAngle / 2 + GetAngularNoise(data, magnitude, v5 >= 0 and data.Seed or data.Seed2) - math.abs(v5)) * magnitude + EdgeGrain(
		p,
		p2,
		data.Seed
	) > 0
end

local function NearWedge(data, p)
	local magnitude = p.Magnitude

	if magnitude <= 0 then
		return false
	end

	local angleBetweenVectors = Client.Utility.GetAngleBetweenVectors(
		(data.Center * createVector(1, 0, 1)).Unit,
		p.Unit
	)
	local v4 = math.min(
		math.rad(data.WedgeAngle / 2 - math.deg(angleBetweenVectors)) * magnitude,
		magnitude - data.BiomeMinRadius
	)
	return v4 > -357.5 and v4 < 357.5
end

function GetBiome(p, p2)
	local vector2 = Vector3.new(p, 0, p2)
	local v4 = nil

	for k, v5 in pairs(v) do
		if v5.WedgeBiome then
			if InWedge(v5, p, p2) then
				return k, v5, nil, 1
			end

			if v4 == nil then
				local magnitude = vector2.Magnitude
				local v6

				if magnitude <= 0 then
					v6 = false
				else
					local angleBetweenVectors = Client.Utility.GetAngleBetweenVectors(
						(v5.Center * createVector(1, 0, 1)).Unit,
						vector2.Unit
					)
					local v7 = math.min(
						math.rad(v5.WedgeAngle / 2 - math.deg(angleBetweenVectors)) * magnitude,
						magnitude - v5.BiomeMinRadius
					)

					if v7 > -357.5 then
						v6 = v7 < 357.5
					else
						v6 = false
					end
				end

				if v6 then
					for _, v8 in ipairs(v3) do
						if not InWedge(v5, p + v8[1], p2 + v8[2]) then
							continue
						end

						v4 = k .. "Edge"
						break
					end
				end
			end
		else
			local magnitude = (v5.Center - vector2).Magnitude
			local _ = v5.BiomeMaxRadius

			if magnitude <= v5.BiomeMinRadius then
				return k, v5
			end

			if magnitude <= v5.BiomeMaxRadius + 80 then
				local v6 = GetBiomeRadius(v5, vector2)

				if magnitude <= v6 then
					return k, v5
				end

				if magnitude <= v6 + 68 then
					return nil, nil, k .. "Edge"
				end
			end
		end
	end

	if v4 then
		return nil, nil, v4
	end
end

function BiomesClient.GetBiome(p)
	local rounded = round(p.X, 40)
	local rounded2 = round(p.Z, 40)
	return GetBiome(rounded, rounded2)
end

function BiomesClient.GetBiomeXZ(p, p2)
	local rounded = round(p, 40)
	local rounded2 = round(p2, 40)
	return GetBiome(rounded, rounded2)
end

function round(p, p2)
	local v4 = math.round(p / p2) * p2

	if v4 == -0 then
		return 0
	end

	return v4
end

function BiomesClient.Init()
	task.spawn(function()
		Client.Utility.ForAllTagged("BiomeZone", AddBiomeZone)
		LoadBiomes()
		UpdateCurrentBiome()
	end)
end

return BiomesClient