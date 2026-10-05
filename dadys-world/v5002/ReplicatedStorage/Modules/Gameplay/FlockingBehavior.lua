local createVector = vector.create
local FlockingBehavior = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = nil
pcall(function()
	local MonsterBuddySystem = require(script.Parent.MonsterBuddySystem)
	v = MonsterBuddySystem
end)
local v2 = {
	NEIGHBOR_RADIUS = 12,
	SEPARATION_RADIUS = 18,
	OBSTACLE_DETECT_RANGE = 8,
	SEPARATION_WEIGHT = 6.5,
	ALIGNMENT_WEIGHT = 0.05,
	COHESION_WEIGHT = 0.01,
	TARGET_WEIGHT = 2,
	OBSTACLE_WEIGHT = 2.5,
	MAX_NEIGHBORS = 8,
	BASE_UPDATE_RATE = 0.05,
	ADAPTIVE_SCALING = true,
	MONSTER_COUNT_THRESHOLD = 6,
	FORCE_SMOOTHING = 0.5,
	ENABLE_FLANKING = false,
	ENABLE_FORMATIONS = false,
	FORMATION_TYPE = "V"
}

function FlockingBehavior.GetConfig()
	local result = {}

	for k, v3 in pairs(v2) do
		result[k] = v3
	end

	return result
end

local v3 = {}

function FlockingBehavior.SetMonsterOverride(instance, p, p2)
	if typeof(instance) ~= "Instance" then
		return false, "monster must be an Instance"
	end

	if v2[p] == nil then
		return false, string.format("unknown flocking key %q", (tostring(p)))
	end

	if p2 ~= nil and type(p2) ~= type(v2[p]) then
		return false, string.format("%s expects a %s, got %s", tostring(p), type(v2[p]), (type(p2)))
	end

	local v4 = v3[instance]

	if p2 == nil then
		if v4 then
			v4[p] = nil

			if next(v4) == nil then
				v3[instance] = nil
			end
		end
	else
		if not v4 then
			v4 = {}
			v3[instance] = v4
		end

		v4[p] = p2
	end

	return true
end

function FlockingBehavior.ClearMonsterOverrides(p)
	v3[p] = nil
end

function FlockingBehavior.GetMonsterOverrides(p)
	local v4 = v3[p]

	if not v4 then
		return nil
	end

	local result = {}

	for k, v5 in pairs(v4) do
		result[k] = v5
	end

	return result
end

local v4 = {}

function FlockingBehavior.SetConfig(items)
	for k, item in pairs(items) do
		if v2[k] == nil then
			if not v4[k] then
				v4[k] = true
				warn(string.format(
					"[FlockingBehavior] SetConfig: unknown key %q ignored (typo? see CONFIG)",
					(tostring(k))
				))
			end
		elseif type(item) == type(v2[k]) then
			v2[k] = item
		else
			warn(string.format(
				"[FlockingBehavior] SetConfig: %s expects %s, got %s - ignored",
				k,
				type(v2[k]),
				(type(item))
			))
		end
	end
end

local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}

local function resolveProfile(instance)
	if instance:GetAttribute("_PackSwarm") == true then
		return FlockingBehavior.Presets.PackSwarm
	end

	local flockingProfile = instance:GetAttribute("FlockingProfile")

	if flockingProfile == nil then
		local v12 = v10[instance]

		if v12 ~= nil then
			return v12 and FlockingBehavior.Presets[v12] or nil
		end

		local flockingProfile2 = nil
		pcall(function()
			local monsterData = ReplicatedStorage:FindFirstChild("MonsterData")
			local child = monsterData and monsterData:FindFirstChild(instance.Name)

			if child then
				local module = require(child)
				flockingProfile2 = module.FlockingProfile
			end
		end)

		if typeof(flockingProfile2) == "string" and FlockingBehavior.Presets[flockingProfile2] then
			v10[instance] = flockingProfile2
			return FlockingBehavior.Presets[flockingProfile2]
		end

		if typeof(flockingProfile2) == "string" and not v11[flockingProfile2] then
			v11[flockingProfile2] = true
			warn("[FlockingBehavior] Unknown FlockingProfile '" .. flockingProfile2 .. "' in MonsterData[" .. instance.Name .. "] - ignoring (using global CONFIG)")
		end

		v10[instance] = false
		return nil
	else
		if typeof(flockingProfile) ~= "string" then
			return nil
		end

		local preset = FlockingBehavior.Presets[flockingProfile]

		if preset then
			return preset
		end

		if not v11[flockingProfile] then
			v11[flockingProfile] = true
			warn("[FlockingBehavior] Unknown FlockingProfile attribute '" .. flockingProfile .. "' on " .. instance.Name .. " - ignoring (using global CONFIG)")
		end

		return nil
	end
end

local children = {}
local v12 = 0

local function getNeighbors(instance, NEIGHBOR_RADIUS, p)
	local result = {}
	local position = instance.PrimaryPart and instance.PrimaryPart.Position

	if not position then
		return result
	end

	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		return result
	end

	local monsters = currentRoom:FindFirstChildOfClass("Model") and currentRoom:FindFirstChildOfClass("Model"):FindFirstChild("Monsters")

	if not monsters then
		return result
	end

	local count = 0

	for _, child in pairs(monsters:GetChildren()) do
		if not (child ~= instance and child:FindFirstChild("HumanoidRootPart")) then
			continue
		end

		local position2 = child.HumanoidRootPart.Position
		local magnitude = Vector3.new(position.X - position2.X, 0, position.Z - position2.Z).Magnitude
		local verticalDelta = math.abs(position.Y - position2.Y)

		if not (magnitude < NEIGHBOR_RADIUS and magnitude > 0 and verticalDelta < 8) then
			continue
		end

		table.insert(result, {
			monster = child,
			position = position2,
			distance = magnitude,
			verticalDelta = verticalDelta,
			velocity = child.HumanoidRootPart.AssemblyLinearVelocity
		})
		count += 1

		if p.MAX_NEIGHBORS <= count then
			break
		end
	end

	table.sort(result, function(a, b)
		return a.distance < b.distance
	end)
	return result
end

local function updateFilterListCache()
	local now = tick()

	if now - v12 < 0.5 then
		return
	end

	v12 = now
	children = {}
	local currentRoom = workspace:FindFirstChild("CurrentRoom")
	local monsters = currentRoom and currentRoom:FindFirstChildOfClass("Model") and currentRoom:FindFirstChildOfClass("Model"):FindFirstChild("Monsters")

	if monsters then
		for _, child in pairs(monsters:GetChildren()) do
			table.insert(children, child)
		end
	end
end

local function calculateWallAvoidance(instance, p)
	local position = instance.PrimaryPart.Position
	updateFilterListCache()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = children
	local v13 = createVector(0, 0, 0)

	for _, v14 in ipairs({
		createVector(1, 0, 0),
		createVector(-1, 0, 0),
		createVector(0, 0, 1),
		createVector(0, 0, -1)
	}) do
		local raycastResult = workspace:Raycast(
			position + createVector(0, 2, 0),
			v14 * p.OBSTACLE_DETECT_RANGE,
			raycastParams
		)

		if not raycastResult then
			continue
		end

		local v15 = 1 - raycastResult.Distance / p.OBSTACLE_DETECT_RANGE
		local vector2 = Vector3.new(raycastResult.Normal.X, 0, raycastResult.Normal.Z)

		if vector2.Magnitude > 0.01 then
			v13 += vector2.Unit * v15
		end
	end

	return v13 * p.OBSTACLE_WEIGHT
end

local function calculateSeparation(instance, neighbors, p)
	local position = instance.PrimaryPart.Position
	local isLethal = instance:GetAttribute("IsLethal") or instance:GetAttribute("IsMain")
	local v13 = #neighbors + 1
	local v14 = math.min(p.SEPARATION_RADIUS + v13 * 0.5, (math.max(12, p.SEPARATION_RADIUS)))
	local v15 = createVector(0, 0, 0)

	for _, v16 in pairs(neighbors) do
		local isLethal2 = v16.monster:GetAttribute("IsLethal") or v16.monster:GetAttribute("IsMain")
		local v17, v18

		if v and v.ENABLED then
			v17, v18 = v.AreBuddies(instance.Name, v16.monster.Name)
		else
			v17 = false
		end

		local v19

		if isLethal2 and not isLethal then
			v19 = v14 * 2.5
		elseif isLethal or isLethal2 then
			v19 = v14
		else
			v19 = v14 * 1.15
		end

		if not (v16.distance < v19) then
			continue
		end

		local vector2 = Vector3.new(position.X - v16.position.X, 0, position.Z - v16.position.Z)
		local unit = vector2.Magnitude > 0.01 and vector2.Unit or createVector(1, 0, 0)
		local v20 = 1 - v16.distance / v19
		local v21 = v13 * 0.15 + 1

		if isLethal2 and not isLethal then
			v21 *= 1.5
		end

		if instance.Name == v16.monster.Name and not v17 then
			v20 *= 1.15
		end

		if v17 and v18 then
			v20 *= v18.separationMultiplier
			v21 *= 0.5
		end

		v15 += unit * v20 * v21
	end

	return v15 * p.SEPARATION_WEIGHT
end

local function calculateAlignment(_, neighbors, instance, assemblyLinearVelocity, p)
	if instance and assemblyLinearVelocity and assemblyLinearVelocity.Magnitude < 2 or #neighbors == 0 then
		return createVector(0, 0, 0)
	end

	local v13 = createVector(0, 0, 0)
	local count = 0

	for _, v14 in pairs(neighbors) do
		local vector2 = Vector3.new(v14.velocity.X, 0, v14.velocity.Z)

		if not (vector2.Magnitude > 1) then
			continue
		end

		v13 += vector2.Unit
		count += 1
	end

	if count > 0 then
		return v13 / count * p.ALIGNMENT_WEIGHT
	end

	return createVector(0, 0, 0)
end

local function calculateCohesion(instance, neighbors, instance2, assemblyLinearVelocity, p)
	if #neighbors == 0 or instance2 and assemblyLinearVelocity and assemblyLinearVelocity.Magnitude < 2 then
		return createVector(0, 0, 0)
	end

	local position = instance.PrimaryPart.Position
	local vector2 = Vector3.new(position.X, 0, position.Z)
	local v13 = createVector(0, 0, 0)
	local v14 = createVector(0, 0, 0)

	for _, v15 in pairs(neighbors) do
		local vector3 = Vector3.new(v15.position.X, 0, v15.position.Z)
		v13 += vector3

		if not (v and v.ENABLED) then
			continue
		end

		local areBuddies, v16 = v.AreBuddies(instance.Name, v15.monster.Name)

		if not (areBuddies and v16 and v15.distance > v16.maxDistance) then
			continue
		end

		local v17 = vector3 - vector2

		if v17.Magnitude > 0.01 then
			v14 += v17.Unit * ((v15.distance - v16.maxDistance) / v16.maxDistance) * v16.cohesionMultiplier
		end
	end

	local v15 = v13 / #neighbors - vector2
	return (not (v15.Magnitude > 0) and createVector(0, 0, 0) or v15.Unit * p.COHESION_WEIGHT) + v14
end

local function calculateFlanking(instance, instance2, neighbors, p)
	if not (p.ENABLE_FLANKING and instance2) then
		return createVector(0, 0, 0)
	end

	local position = instance.PrimaryPart.Position
	local position2 = instance2:FindFirstChild("HumanoidRootPart") and instance2.HumanoidRootPart.Position

	if not position2 then
		return createVector(0, 0, 0)
	end

	local vector2 = Vector3.new(position2.X - position.X, 0, position2.Z - position.Z)

	if vector2.Magnitude < 3 then
		return createVector(0, 0, 0)
	end

	local unit = vector2:Cross(createVector(0, 1, 0)).Unit
	local count = 0
	local count2 = 0

	for _, item in pairs(neighbors) do
		if Vector3.new(item.position.X - position2.X, 0, item.position.Z - position2.Z):Dot(unit) > 0 then
			count += 1
		else
			count2 += 1
		end
	end

	if not (count < count2) then
		if count2 < count then
			unit = -unit
		else
			local total = 0

			for i = 1, #instance.Name do
				total += string.byte(instance.Name, i)
			end

			unit = total % 2 == 0 and unit or -unit
		end
	end

	return (vector2.Unit * 0.3 + unit * 0.7) * p.SEPARATION_WEIGHT
end

function FlockingBehavior.CalculateFlockingForce(instance, instance2, items, p, p2)
	local v13 = 0
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if currentRoom then
		local monsters = currentRoom:FindFirstChildOfClass("Model") and currentRoom:FindFirstChildOfClass("Model"):FindFirstChild("Monsters")
		v13 = monsters and #monsters:GetChildren() or v13
	end

	if v13 <= 1 then
		v5[instance] = createVector(0, 0, 0)
		return createVector(0, 0, 0)
	end

	local v14 = v13 == 2 and 0.5 or v13 == 3 and 0.7 or 1
	local BASE_UPDATE_RATE = v2.BASE_UPDATE_RATE

	if v2.ADAPTIVE_SCALING and v2.MONSTER_COUNT_THRESHOLD < v13 then
		local v15 = (v13 - v2.MONSTER_COUNT_THRESHOLD) * 0.0125
		BASE_UPDATE_RATE = math.min(v2.BASE_UPDATE_RATE + v15, 0.1)
	end

	local now = tick()

	if now - (v6[instance] or 0) < BASE_UPDATE_RATE then
		return v5[instance] or createVector(0, 0, 0)
	end

	v6[instance] = now
	local v15 = {}

	for k, v16 in pairs(v2) do
		v15[k] = v16
	end

	local profile = resolveProfile(instance)

	if profile then
		for k, v16 in pairs(profile) do
			v15[k] = v16
		end
	end

	if items then
		for k, item in pairs(items) do
			v15[k] = item
		end
	end

	local v16 = v3[instance]

	if v16 then
		for k, v17 in pairs(v16) do
			v15[k] = v17
		end
	end

	local neighbors = getNeighbors(instance, v15.NEIGHBOR_RADIUS, v15)
	local assemblyLinearVelocity, magnitude

	if instance2 and instance2:FindFirstChild("HumanoidRootPart") then
		assemblyLinearVelocity = instance2.HumanoidRootPart.AssemblyLinearVelocity
		magnitude = (instance2.HumanoidRootPart.Position - instance.PrimaryPart.Position).Magnitude
	else
		assemblyLinearVelocity = createVector(0, 0, 0)
		magnitude = 1e999
	end

	local v17 = assemblyLinearVelocity.Magnitude < 2
	local v18 = magnitude < 6

	if v17 and v18 then
		if not v9[instance] then
			v9[instance] = now
		end
	else
		v9[instance] = nil
	end

	local v19 = (not v9[instance] and 0 or now - v9[instance] or 0) > 0.5
	local v20 = createVector(0, 0, 0)

	if v19 and instance2 and instance2:FindFirstChild("HumanoidRootPart") then
		if not v8[instance] or v8[instance] < now then
			local v21 = math.min(magnitude * 0.4, 8)
			local position = instance.PrimaryPart.Position
			local position2 = instance2.HumanoidRootPart.Position
			local v22 = position.X - position2.X
			local v23 = position.Z - position2.Z
			local v24

			if v22 * v22 + v23 * v23 > 0.25 then
				v24 = math.atan2(v23, v22) + (math.random() - 0.5) * 2.6179938779914944
			else
				v24 = math.random() * 3.141592653589793 * 2
			end

			local v25 = math.max(3, v21) + math.random() * 3
			local vector2 = Vector3.new(math.cos(v24) * v25, 0, math.sin(v24) * v25)
			v7[instance] = instance2.HumanoidRootPart.Position + vector2
			v8[instance] = now + 0.6 + math.random() * 0.6
		end

		local v21 = v7[instance]

		if v21 then
			local position = instance.PrimaryPart.Position
			local vector2 = Vector3.new(v21.X - position.X, 0, v21.Z - position.Z)

			if vector2.Magnitude > 1 then
				v20 = vector2.Unit * 12
			else
				v8[instance] = 0
			end
		end
	else
		v7[instance] = nil
		v8[instance] = nil
	end

	local v21 = calculateWallAvoidance(instance, v15)
	local v22 = calculateSeparation(instance, neighbors, v15)
	local v23 = calculateAlignment(instance, neighbors, instance2, assemblyLinearVelocity, v15)
	local v24 = calculateCohesion(instance, neighbors, instance2, assemblyLinearVelocity, v15)
	local v25 = calculateFlanking(instance, instance2, neighbors, v15)
	local v26 = createVector(0, 0, 0)

	if not v19 and v15.ENABLE_FORMATIONS and p2 then
		local FORMATION_TYPE = v15.FORMATION_TYPE or p

		if FORMATION_TYPE then
			local unit = nil
			local primaryPart = instance.PrimaryPart
			local primaryPart2 = instance2 and (instance2.PrimaryPart or instance2:FindFirstChild("HumanoidRootPart"))

			if primaryPart and primaryPart2 then
				local v27 = primaryPart2.Position - primaryPart.Position
				local vector2 = Vector3.new(v27.X, 0, v27.Z)

				if vector2.Magnitude > 0.5 then
					unit = vector2.Unit
				end
			end

			v26 = FlockingBehavior.GetFormationOffset(instance, FORMATION_TYPE, p2, unit)
		end
	end

	local v27

	if v19 then
		v27 = v21 + v20
	else
		v27 = v21 + v22 + v23 + v24 + v25 + v26
	end

	local vector2 = Vector3.new(v27.X, 0, v27.Z)
	local v28 = v19 and 10 or 5

	if v28 < vector2.Magnitude then
		vector2 = vector2.Unit * v28
	end

	local v29 = v5[instance]

	if v29 and v15.FORCE_SMOOTHING > 0 then
		vector2 = v29:Lerp(vector2, 1 - v15.FORCE_SMOOTHING)
	end

	local v30 = vector2 * v14
	v5[instance] = v30
	return v30
end

function FlockingBehavior.GetFormationOffset(_, p, p2, p3)
	local vector2

	if p == "V" then
		local v13 = math.floor(p2 / 2)
		vector2 = Vector3.new((p2 % 2 == 0 and 1 or -1) * v13 * 3, 0, v13 * -3)
	elseif p == "Line" then
		vector2 = Vector3.new(0, 0, p2 * -4)
	elseif p == "Circle" then
		local v13 = p2 / 8 * 3.141592653589793 * 2
		local v14 = math.floor(p2 / 8) * 3 + 5
		vector2 = Vector3.new(math.cos(v13) * v14, 0, math.sin(v13) * v14)
	elseif p == "Square" then
		local v13 = math.floor(p2 / 8)
		local v14 = p2 % 8
		local v15 = v13 * 3 + 5
		local v16 = ({
			{ 1, 1 },
			{ 1, 0 },
			{ 1, -1 },
			{ 0, -1 },
			{ -1, -1 },
			{ -1, 0 },
			{ -1, 1 },
			{ 0, 1 }
		})[v14 + 1]
		vector2 = Vector3.new(v16[1] * v15, 0, v16[2] * v15)
	else
		if p ~= "Triangle" then
			return createVector(0, 0, 0)
		end

		local count = 0

		while count < p2 do
			p2 -= count + 1
			count += 1
		end

		vector2 = Vector3.new((p2 - count / 2) * 3, 0, count * -3)
	end

	if p3 then
		return Vector3.new(-p3.Z, 0, p3.X) * vector2.X + p3 * vector2.Z
	end

	return vector2
end

local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
	for k, _ in pairs(v5) do
		if k.Parent then
			continue
		end

		v5[k] = nil
		v3[k] = nil
		v6[k] = nil
		v7[k] = nil
		v8[k] = nil
		v9[k] = nil
		v10[k] = nil
	end
end)
FlockingBehavior.Presets = {
	Aggressive = {
		SEPARATION_WEIGHT = 1.2,
		ALIGNMENT_WEIGHT = 0.2,
		COHESION_WEIGHT = 0.1,
		TARGET_WEIGHT = 3,
		ENABLE_FLANKING = true
	},
	Defensive = {
		SEPARATION_WEIGHT = 1,
		ALIGNMENT_WEIGHT = 0.5,
		COHESION_WEIGHT = 0.8,
		TARGET_WEIGHT = 1.5,
		ENABLE_FLANKING = true,
		ENABLE_FORMATIONS = true
	},
	Swarming = {
		SEPARATION_WEIGHT = 0.8,
		ALIGNMENT_WEIGHT = 0.1,
		COHESION_WEIGHT = 0.3,
		TARGET_WEIGHT = 2.5,
		ENABLE_FLANKING = false
	},
	Stalking = {
		SEPARATION_WEIGHT = 6.5,
		ALIGNMENT_WEIGHT = 0.05,
		COHESION_WEIGHT = 0.01,
		TARGET_WEIGHT = 2,
		ENABLE_FLANKING = true,
		SEPARATION_RADIUS = 18
	},
	PackSwarm = {
		SEPARATION_WEIGHT = 1.2,
		SEPARATION_RADIUS = 6,
		ALIGNMENT_WEIGHT = 0.6,
		COHESION_WEIGHT = 0.8,
		TARGET_WEIGHT = 2.5,
		ENABLE_FLANKING = true
	},
	IceSkate = {
		SEPARATION_WEIGHT = 1.5,
		SEPARATION_RADIUS = 8,
		ALIGNMENT_WEIGHT = 0.5,
		COHESION_WEIGHT = 0.3,
		TARGET_WEIGHT = 2,
		FORCE_SMOOTHING = 0.85,
		ENABLE_FLANKING = false
	}
}
return FlockingBehavior