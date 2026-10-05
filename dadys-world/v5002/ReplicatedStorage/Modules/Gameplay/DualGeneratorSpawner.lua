local createVector = vector.create
local DualGeneratorSpawner = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local MultiGenConfig = require(ServerStorage.Modules.Data.MultiGenConfig)
local genSlotSuffix = ReplicatedStorage.Modules.Gameplay:FindFirstChild("GenSlotSuffix")
local success, result = pcall(function()
	return genSlotSuffix and require(genSlotSuffix)
end)
local count = 0
local flag = false

local function acquireSpawnLock()
	local lastTime = tick()

	while flag do
		task.wait()

		if not (tick() - lastTime > 5) then
			continue
		end

		warn("[DualGeneratorSpawner] spawn lock held >5s; force-releasing (likely a leaked lock from a prior errored Spawn)")
		break
	end

	flag = true
end

local function releaseSpawnLock()
	flag = false
end

local overlapParams = OverlapParams.new()
overlapParams.MaxParts = 1
local v2 = { "Wall", "Obstacle" }
local v3 = true
local v4 = nil

for _, v5 in ipairs(v2) do
	CollectionService:GetInstanceAddedSignal(v5):Connect(function()
		v3 = true
	end)
	CollectionService:GetInstanceRemovedSignal(v5):Connect(function()
		v3 = true
	end)
end

local function getObstacleList()
	if not v3 then
		return v4
	end

	local v5 = {}

	for _, tag in ipairs(v2) do
		for _, v6 in ipairs(CollectionService:GetTagged(tag)) do
			table.insert(v5, v6)
		end
	end

	v4 = v5
	v3 = false
	return v4
end

local v5 = nil
local vector2 = nil
local flag2 = false

local function getWalkBaseFootprint()
	if flag2 then
		return v5, vector2
	end

	flag2 = true
	local ServerStorage2 = game:GetService("ServerStorage")
	local generators = ServerStorage2:FindFirstChild("Generators")
	local generator = generators and generators:FindFirstChild("Generator")
	local treadmillGame = generator and generator:FindFirstChild("TreadmillGame")
	local treadmillWalkBase = treadmillGame and treadmillGame:FindFirstChild("TreadmillWalkBase")

	if treadmillWalkBase and treadmillWalkBase:IsA("BasePart") then
		v5 = generator:GetPivot():Inverse() * treadmillWalkBase.CFrame
		vector2 = Vector3.new(treadmillWalkBase.Size.X * 0.2, treadmillWalkBase.Size.Y, treadmillWalkBase.Size.Z * 0.2)
		return v5, vector2
	else
		warn("[DualGeneratorSpawner] TreadmillWalkBase missing — treadmill clip pre-check disabled")
		return nil, nil
	end
end

local v6 = nil
local vector3 = nil
local flag3 = false

local function getChassisFootprint()
	if flag3 then
		return v6, vector3
	end

	flag3 = true
	local ServerStorage2 = game:GetService("ServerStorage")
	local generators = ServerStorage2:FindFirstChild("Generators")
	local generator = generators and generators:FindFirstChild("Generator")
	local baseMachine = generator and (generator:FindFirstChild("BaseMachine") or generator:FindFirstChild("wipGenerator"))

	if not baseMachine then
		warn("[DualGeneratorSpawner] BaseMachine missing — non-treadmill chassis pre-check disabled")
		return nil, nil
	end

	local success2, result2, v7 = pcall(function()
		local boundingBox, v8 = baseMachine:GetBoundingBox()
		return boundingBox, v8
	end)

	if success2 and result2 and v7 then
		v6 = generator:GetPivot():Inverse() * result2
		vector3 = Vector3.new(v7.X * 0.3, v7.Y, v7.Z * 0.3)
		return v6, vector3
	else
		warn("[DualGeneratorSpawner] BaseMachine GetBoundingBox failed — chassis pre-check disabled")
		return nil, nil
	end
end

function DualGeneratorSpawner.canFitDualAtPosition(cframe, p, list)
	local obstacleList = getObstacleList()

	if #obstacleList == 0 then
		return true
	end

	overlapParams.IncludeInstances = obstacleList
	local walkBaseFootprint, v7 = getWalkBaseFootprint()
	local chassisFootprint, v8 = getChassisFootprint()
	local v9 = select(2, cframe:ToOrientation())
	local v10 = 0

	if list and #list == 1 then
		local angleDeg = list[1].angleDeg or 180

		if math.abs(math.abs(angleDeg) - 180) > 5 then
			v10 = -math.rad(angleDeg) / 2
		end
	end

	local v11 = v9 + v10

	-- equivalent calls inferred from this helper; original call sites unknown
	local function probeHalf(p2, p3)
		if p3 == "MovementTreadmill" then
			return not v7 or #Workspace:GetPartBoundsInBox(p2 * walkBaseFootprint, v7, overlapParams) == 0
		else
			return not v8 or #Workspace:GetPartBoundsInBox(p2 * chassisFootprint, v8, overlapParams) == 0
		end
	end

	-- equivalent call inferred; original call site unknown
	if not probeHalf(CFrame.new(cframe.Position) * CFrame.Angles(0, v11, 0), p) then
		return false
	end

	if not list then
		return true
	end

	for _, v13 in ipairs(list) do
		local v14 = v11 + math.rad(v13.angleDeg or 180)

		-- equivalent call inferred; original call site unknown
		if not probeHalf(CFrame.new(cframe.Position) * CFrame.Angles(0, v14, 0), v13.type or p) then
			return false
		end
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRoomCenter(model)
	local success2, result2 = pcall(function()
		return model:GetBoundingBox()
	end)

	if success2 and result2 then
		return result2.Position
	end

	return model:GetPivot().Position
end

local object = setmetatable({}, {
	__mode = "k"
})

local function pickCentralTriggerZoneCFrame()
	local currentRoom = Workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		return nil, "no CurrentRoom"
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if not model then
		return nil, "no room model in CurrentRoom"
	end

	local triggerZones = model:FindFirstChild("TriggerZones")

	if not triggerZones then
		return nil, "no TriggerZones folder"
	end

	local roomCenter = getRoomCenter(model) -- equivalent call inferred; original call site unknown
	local v7 = {}

	for _, part in ipairs(triggerZones:GetChildren()) do
		if part.Name ~= "TriggerZone" then
			continue
		end

		local part2 = part:IsA("BasePart") and part or part:FindFirstChildWhichIsA("BasePart", true)

		if not part2 or CollectionService:HasTag(part2, "Obstacle") then
			continue
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.FilterDescendantsInstances = { part }

		if Workspace:Raycast(part2.Position + createVector(0, 2, 0), createVector(0, -200, 0), raycastParams) then
			table.insert(v7, {
				part = part2,
				dist = (part2.Position - roomCenter).Magnitude
			})
		end
	end

	if #v7 == 0 then
		return nil, "no valid trigger zone"
	end

	table.sort(v7, function(a, b)
		return a.dist < b.dist
	end)
	local v8 = object[model]

	if not v8 then
		v8 = {}
		object[model] = v8
	end

	local part = nil

	for _, v10 in ipairs(v7) do
		if v8[v10.part] then
			continue
		end

		part = v10.part
		break
	end

	if not part then
		for k in pairs(v8) do
			v8[k] = nil
		end

		part = v7[1].part
	end

	v8[part] = true
	local v10 = select(2, part.CFrame:ToOrientation())
	return CFrame.new(part.Position) * CFrame.Angles(0, v10, 0), "TriggerZone." .. part.Name
end

local object2 = setmetatable({}, {
	__mode = "k"
})

local function pickNormalGeneratorSpawnCFrame()
	local currentRoom = Workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		return nil, "no CurrentRoom"
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if not model then
		return nil, "no room model in CurrentRoom"
	end

	local v7 = {}
	local generatorSpawnPointsCache = model:FindFirstChild("GeneratorSpawnPointsCache")

	if generatorSpawnPointsCache then
		for _, cFrameValue in ipairs(generatorSpawnPointsCache:GetChildren()) do
			if cFrameValue:IsA("CFrameValue") then
				table.insert(v7, {
					part = cFrameValue,
					source = "cache",
					cframe = cFrameValue.Value
				})
			end
		end
	end

	if #v7 == 0 then
		local generatorSpawnPoints = model:FindFirstChild("GeneratorSpawnPoints")

		if generatorSpawnPoints then
			for _, part in ipairs(generatorSpawnPoints:GetChildren()) do
				if part:IsA("BasePart") then
					table.insert(v7, {
						part = part,
						source = "live",
						cframe = part.CFrame
					})
				end
			end
		end
	end

	if #v7 == 0 then
		local generators = model:FindFirstChild("Generators")

		if generators then
			for _, model2 in ipairs(generators:GetChildren()) do
				if model2:IsA("Model") then
					table.insert(v7, {
						part = model2,
						source = "existing-gen",
						cframe = model2:GetPivot()
					})
				end
			end
		end
	end

	if #v7 == 0 then
		return nil, "no GeneratorSpawnPoints/Cache/Generators found"
	end

	local function clearanceOf(position)
		local generators = model:FindFirstChild("Generators")

		if not generators then
			return 1e999
		end

		local v8 = 1e999

		for _, child in ipairs(generators:GetChildren()) do
			local position2 = nil

			if child:IsA("Model") then
				local v9 = child
				local success2, result2 = pcall(function()
					return v9:GetPivot()
				end)

				if success2 and result2 then
					position2 = result2.Position
				end
			elseif child:IsA("BasePart") then
				position2 = child.Position
			end

			if not position2 then
				continue
			end

			local magnitude = (position2 - position).Magnitude

			if magnitude < v8 then
				v8 = magnitude
			end
		end

		return v8
	end

	for _, v8 in ipairs(v7) do
		v8.clearance = clearanceOf(v8.cframe.Position)
	end

	local v8 = (object2[model] or 0) + 1
	local v9 = #v7 < v8 and 1 or v8
	local v10 = nil

	for i = 0, #v7 - 1 do
		local v11 = (v9 - 1 + i) % #v7 + 1
		local v12 = v7[v11]

		if not (v12.clearance > 18) then
			continue
		end

		object2[model] = v11
		v10 = v12
		break
	end

	if not v10 then
		local clearance = -1
		local v11 = 1

		for i, v12 in ipairs(v7) do
			if not (clearance < v12.clearance) then
				continue
			end

			clearance = v12.clearance
			v10 = v12
			v11 = i
		end

		object2[model] = v11
		warn(string.format(
			"[DualGeneratorSpawner] All %d normal-spawn candidates have a gen within %d studs; picking most-clear (%.1f studs from nearest gen)",
			#v7,
			18,
			clearance
		))
	end

	local v11 = select(2, v10.cframe:ToOrientation())
	return
		CFrame.new(v10.cframe.Position) * CFrame.Angles(0, v11, 0),
		v10.source .. "." .. (v10.part:IsA("BasePart") and v10.part.Name or v10.part.Name)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCanonicalTemplate()
	local ServerStorage2 = game:GetService("ServerStorage")
	local generators = ServerStorage2:FindFirstChild("Generators")
	return generators and generators:FindFirstChild("Generator") or nil
end

local function getRoomGeneratorsFolder()
	local currentRoom = Workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		return nil
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if not model then
		return nil
	end

	local v7 = model:FindFirstChild("Generators")

	if not v7 then
		v7 = Instance.new("Folder")
		v7.Name = "Generators"
		v7.Parent = model
	end

	return v7
end

local function applyScaleWithValveLock(clone, scale, debugPrint)
	if not scale or scale == 1 then
		return
	end

	local v7 = {}

	local function snapshot(part, p)
		local v8 = 1 + (scale - 1) * p
		table.insert(v7, {
			part = part,
			targetSize = part.Size * v8,
			originalCFrame = part.CFrame,
			originalY = part.Position.Y,
			originalRotation = part.CFrame - part.CFrame.Position
		})
	end

	local baseMachine = clone:FindFirstChild("BaseMachine") or clone:FindFirstChild("wipGenerator")

	if baseMachine then
		for _, part in ipairs(baseMachine:GetDescendants()) do
			if part:IsA("BasePart") and part.Name:find("Valve") then
				snapshot(part, 0)
			end
		end
	end

	local treadmillGame = clone:FindFirstChild("TreadmillGame")

	if treadmillGame then
		for _, part in ipairs(treadmillGame:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			local name = part.Name

			if not (name:find("Light") == nil and name:lower():find("tm_base") == nil) then
				continue
			end

			snapshot(part, 0.15)
		end
	end

	local circleMinigame = clone:FindFirstChild("CircleMinigame")

	if circleMinigame then
		for _, part in ipairs(circleMinigame:GetDescendants()) do
			if not part:IsA("BasePart") or part.Name:find("Light") then
				continue
			end

			snapshot(part, 0)
		end
	end

	if baseMachine then
		for _, childName in ipairs({
			"BaseShape_4Slot",
			"BaseShape_4SlotCircle",
			"BaseShape_6Slot",
			"BaseShape_8Slot"
		}) do
			local part = baseMachine:FindFirstChild(childName)

			if part and part:IsA("BasePart") then
				snapshot(part, 0)
			elseif part then
				for _, part2 in ipairs(part:GetDescendants()) do
					if not part2:IsA("BasePart") or part2.Name:find("Light") then
						continue
					end

					snapshot(part2, 0)
				end
			end
		end
	end

	local valveReference = clone:FindFirstChild("ValveReference")
	local value = valveReference and valveReference:IsA("ObjectValue") and valveReference.Value or baseMachine and baseMachine:FindFirstChild("Valve")
	local position = value and value.Position
	local treadmillGame2 = clone:FindFirstChild("TreadmillGame")
	local treadmillWalkBase = treadmillGame2 and (treadmillGame2:FindFirstChild("TreadmillWalkBase") or treadmillGame2:FindFirstChild("TreadmillCenterBase") or treadmillGame2:FindFirstChildWhichIsA(
		"BasePart",
		true
	))
	local position2 = treadmillWalkBase and treadmillWalkBase.Position
	local v8 = {}

	local function snapshotTeleport(folder, referencePart, position3)
		if not folder then
			return
		end

		for _, part in ipairs(folder:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			local v9 = {
				part = part,
				originalY = part.Position.Y,
				originalRotation = part.CFrame - part.CFrame.Position,
				originalSize = part.Size,
				originalCFrame = part.CFrame
			}

			if referencePart and position3 then
				v9.referencePart = referencePart
				v9.offsetFromRef = part.Position - position3
			end

			table.insert(v8, v9)
		end
	end

	snapshotTeleport(clone:FindFirstChild("TeleportPositions"), value, position)
	snapshotTeleport(clone:FindFirstChild("TreadmillTeleportPositions"), treadmillWalkBase, position2)
	local treadmillLeavePosition = clone:FindFirstChild("TreadmillLeavePosition")

	if treadmillLeavePosition then
		if treadmillLeavePosition:IsA("BasePart") then
			local v9 = {
				part = treadmillLeavePosition,
				originalY = treadmillLeavePosition.Position.Y,
				originalRotation = treadmillLeavePosition.CFrame - treadmillLeavePosition.CFrame.Position,
				originalSize = treadmillLeavePosition.Size,
				originalCFrame = treadmillLeavePosition.CFrame
			}

			if treadmillWalkBase and position2 then
				v9.referencePart = treadmillWalkBase
				v9.offsetFromRef = treadmillLeavePosition.Position - position2
			end

			table.insert(v8, v9)
		else
			snapshotTeleport(treadmillLeavePosition, treadmillWalkBase, position2)
		end
	end

	local success2, result2 = pcall(function()
		clone:ScaleTo(scale)
	end)

	if not success2 then
		warn("[DualGeneratorSpawner] ScaleTo failed: " .. tostring(result2))
		return
	end

	for _, v9 in ipairs(v7) do
		v9.part.Size = v9.targetSize
		local position3 = v9.part.Position
		v9.part.CFrame = CFrame.new(position3.X, v9.originalY, position3.Z) * v9.originalRotation
	end

	for _, v9 in ipairs(v8) do
		v9.part.Size = v9.originalSize

		if v9.referencePart and v9.offsetFromRef then
			local v10 = v9.referencePart.Position + v9.offsetFromRef
			v9.part.CFrame = CFrame.new(v10.X, v9.originalY, v10.Z) * v9.originalRotation
		else
			local position3 = v9.part.Position
			v9.part.CFrame = CFrame.new(position3.X, v9.originalY, position3.Z) * v9.originalRotation
		end
	end

	if debugPrint then
		print(string.format(
			"[DualGeneratorSpawner] Scaled chassis to %.2f× (valves 1×, treadmill/circle %.2f×, lights full %.2f×, %d interactive locked, %d teleport locked, lock_policy=%s)",
			scale,
			1 + (scale - 1) * 0.15,
			scale,
			#v7,
			#v8,
			"xz-scaled-y-locked"
		))
	end
end

local v7 = {
	LightChassis = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function mirrorUsesValve(p)
	return p == "Original" or p == "Circle" or p == "Barnaby" or p == nil
end

local v8 = {
	Light = true,
	LightChassis = true,
	LightReference = true
}
local v9 = {
	TreadmillLight = true,
	TreadmillLightBase = true,
	TreadmillLightReference = true,
	TreadmillCenterBase = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function shouldKeepInsideWip(name, p)
	if name:find("Valve") then
		return mirrorUsesValve(p)
	end

	if v7[name] then
		return true
	end

	if p == "MovementTreadmill" then
		return v9[name] == true
	end

	return v8[name] == true
end

local function shouldKeepTopLevel(name, p)
	if name:match("_Mirror$") or name:match("_S%d+$") or name:match("^Prompt%d+$") then
		return false
	end

	if name == "Prompt" or (name == "BaseMachine" or name == "wipGenerator") then
		return true
	end

	if name == "TeleportPositions" then
		return true
	elseif name == "TreadmillTeleportPositions" then
		return true
	elseif name == "TreadmillLeavePosition" then
		return true
	elseif name == "QuickLinks" then
		return true
	end

	if v7[name] or p == "Circle" and name == "CircleMinigame" or p == "MovementTreadmill" and name == "TreadmillGame" or p == "Barnaby" and name == "SwimmyBarnaby" then
		return true
	end

	if name:find("Circle") and p ~= "Circle" or name:find("Treadmill") and p ~= "MovementTreadmill" then
		return false
	end

	if name:find("Valve") and (p == "Original" or p == "Circle" or p == "Barnaby" or p == nil) or name:find("Light") then
		return true
	end

	return false
end

local forSlot = (success and result or {
	forSlot = function(p)
		if p == 1 then
			return ""
		elseif p == 2 then
			return "_Mirror"
		end

		return "_S" .. p
	end
}).forSlot

local function addEntryPoint(clone, p, type2, value, cframe)
	local name = "Prompt" .. p

	if clone:FindFirstChild(name) then
		return
	end

	local v11 = type2 or clone:GetAttribute("MinigameType") or "Original"
	local v12 = value or 3.141592653589793
	local clone2 = clone:Clone()

	if cframe then
		clone2:PivotTo(cframe)
	else
		clone2:PivotTo(clone:GetPivot() * CFrame.Angles(0, v12, 0))
	end

	for _, child in ipairs(clone2:GetChildren()) do
		if not shouldKeepTopLevel(child.Name, v11) then
			child:Destroy()
		end
	end

	local baseMachine = clone2:FindFirstChild("BaseMachine") or clone2:FindFirstChild("wipGenerator")

	if baseMachine then
		for _, child in ipairs(baseMachine:GetChildren()) do
			-- equivalent call inferred; original call site unknown
			if not shouldKeepInsideWip(child.Name, v11) then
				child:Destroy()
			end
		end
	end

	local prompt = clone2:FindFirstChild("Prompt")

	if prompt then
		prompt.Name = name
		prompt:SetAttribute("MirrorAngleDeg", (math.deg(v12)))
	end

	local v13 = forSlot(p)

	for _, child in ipairs(clone2:GetChildren()) do
		if child.Name ~= name and clone:FindFirstChild(child.Name) then
			child.Name ..= v13
		end

		child.Parent = clone
	end

	clone2:Destroy()
end

function DualGeneratorSpawner.Spawn(targetCF2)
	local v10 = typeof(targetCF2) == "CFrame" and {
		targetCF = targetCF2
	} or targetCF2 or {}
	local sideAType = v10.sideAType or "Original"
	local targetCF = v10.targetCF
	local positionSource = v10.positionSource or "auto"
	local sides = v10.sides or {
		{
			type = v10.sideBType or sideAType,
			angleDeg = v10.mirrorAngleDeg or 180
		}
	}
	local canonicalTemplate = getCanonicalTemplate() -- equivalent call inferred; original call site unknown

	if not canonicalTemplate then
		warn("[DualGeneratorSpawner] canonical template missing at workspace.NewGenerator.wipGenerator.Generator")
		return nil
	end

	local parentOverride = v10.parentOverride or getRoomGeneratorsFolder()

	if not parentOverride then
		warn("[DualGeneratorSpawner] no CurrentRoom — cannot find Generators folder to parent into")
		return nil
	end

	local flag4, v11

	if targetCF then
		flag4 = false
		v11 = "caller-provided"
	else
		acquireSpawnLock()
		flag4 = true
		local v12 = #sides + 1
		local v13

		if positionSource == "normal" then
			v13 = true
		elseif positionSource == "trigger" then
			v13 = false
		else
			v13 = v12 <= 2
		end

		if v13 then
			targetCF, v11 = pickNormalGeneratorSpawnCFrame()

			if not targetCF then
				targetCF, v11 = pickCentralTriggerZoneCFrame()

				if targetCF then
					v11 = (v11 or "trigger") .. " (normal-fallback)"
				end
			end
		else
			targetCF, v11 = pickCentralTriggerZoneCFrame()
		end

		if not targetCF then
			flag = false
			warn("[DualGeneratorSpawner] could not pick spawn position: " .. tostring(v11))
			return nil
		end
	end

	local clone = canonicalTemplate:Clone()
	count += 1
	clone.Name = string.format("DualGen_%d_%d", os.time(), count)
	clone:SetAttribute("IsDualGen", true)
	clone:SetAttribute("MinigameType", sideAType)

	if type(v10.pipestacks) == "number" and v10.pipestacks >= 1 then
		clone:SetAttribute("Pipestacks", (math.floor(v10.pipestacks)))
	end

	clone.Parent = parentOverride

	if flag4 then
		flag = false
	end

	local v12 = select(2, targetCF:ToOrientation())

	if v11 and (tostring(v11):find("^cache%.") or tostring(v11):find("^live%.") or tostring(v11):find("^existing%-gen%.")) and #sides == 1 then
		local angleDeg = sides[1].angleDeg or 180

		if math.abs(math.abs(angleDeg) - 180) <= 5 then
			sides[1] = {
				type = sides[1].type,
				angleDeg = 90
			}
			print(string.format(
				"[DualGeneratorSpawner] Auto-V'd dual at normal spot %s (was %d° → 90°)",
				tostring(v11),
				angleDeg
			))
		end
	end

	local v13 = 0
	local flag5 = false

	if #sides == 1 then
		local angleDeg = sides[1].angleDeg or 180

		if math.abs(math.abs(angleDeg) - 180) > 5 then
			v13 = -angleDeg / 2
			flag5 = true
		end
	end

	local v14 = v12 + math.rad(v13)
	clone:PivotTo(CFrame.new(targetCF.Position) * CFrame.Angles(0, v14, 0))
	local GEN_SPAWN_Y_OFFSET = MultiGenConfig.GEN_SPAWN_Y_OFFSET or -0.144
	clone:PivotTo(clone:GetPivot() + Vector3.new(0, GEN_SPAWN_Y_OFFSET, 0))
	applyScaleWithValveLock(clone, v10.scale or 1, v10.debugPrint)

	for i, side in ipairs(sides) do
		local v15 = i + 1
		local type2 = side.type or sideAType
		local angleDeg = side.angleDeg or 360 / (#sides + 1) * i
		clone:SetAttribute("Prompt" .. v15 .. "MinigameType", type2)
		local v16

		if flag5 then
			local v17 = v14 + math.rad(angleDeg)
			local v18 = targetCF.Position + Vector3.new(0, GEN_SPAWN_Y_OFFSET, 0)
			v16 = CFrame.new(v18) * CFrame.Angles(0, v17, 0)
		end

		addEntryPoint(clone, v15, type2, math.rad(angleDeg), v16)
	end

	local v15 = #(v10.sides or {}) + 1
	clone:SetAttribute("MachineFamily", v15 == 2 and "DUAL" or v15 == 4 and "QUAD" or v15 == 8 and "OCTA" or "SINGLE")

	if not v10.parentOverride then
		local success2, generatorFillScript = pcall(require, ReplicatedStorage.Modules.Gameplay.GeneratorFillScript)

		if success2 and generatorFillScript and type(generatorFillScript.Initialize) == "function" then
			task.spawn(function()
				local success3, result2 = pcall(generatorFillScript.Initialize, clone)

				if not success3 then
					warn("[DualGeneratorSpawner] Initialize threw: " .. tostring(result2) .. " — destroying half-built gen " .. tostring(clone.Name))

					if clone and clone.Parent then
						pcall(function()
							clone:Destroy()
						end)
					end
				end
			end)
		else
			warn("[DualGeneratorSpawner] GeneratorFillScript.Initialize unavailable")
			return clone
		end
	end

	local v16 = { "A=" .. sideAType }
	local v17 = {
		"B",
		"C",
		"D",
		"E",
		"F",
		"G"
	}

	for i, side in ipairs(sides) do
		local v18 = v17[i] or "Slot" .. i + 1
		table.insert(v16, string.format("%s=%s@%d°", v18, side.type or sideAType, side.angleDeg or 0))
	end

	local v18 = (not v10.scale or v10.scale == 1) and "" or string.format(" scale=%.2f×", v10.scale)
	print(string.format(
		"[DualGeneratorSpawner] Spawned %d-entry gen at %s (source=%s)%s under %s (%s)",
		#sides + 1,
		tostring(targetCF.Position),
		v11,
		v18,
		parentOverride:GetFullName(),
		table.concat(v16, " | ")
	))
	return clone
end

return DualGeneratorSpawner