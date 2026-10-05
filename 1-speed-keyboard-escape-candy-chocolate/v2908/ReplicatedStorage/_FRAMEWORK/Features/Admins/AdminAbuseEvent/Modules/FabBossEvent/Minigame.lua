local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local SpacialQuery = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.SpacialQuery)
local Interpolate = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Interpolate)
require(script.Parent.Parent.Parent)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local AutoKeycapCover = require(script.Parent.AutoKeycapCover)
local Config = require(script.Parent.Config)
local Config2 = require(ReplicatedStorage.Config)
local Minigame = {}
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local color = Color3.new(0.432594, 0.230681, 0.588235)
local value = Enum.RenderPriority.Last.Value
local cframe = CFrame.new(0, 10, 0)
local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local color2 = Color3.fromRGB(184, 92, 255)
local tweenInfo2 = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local flag = false
local count = 0
local v = {
	lastStructure = nil,
	allStructure = {},
	currentIndex = nil,
	passedStructureIndex = nil,
	structureIndexByStructureModel = {},
	lastStuckSignature = nil,
	destroyedThroughIndex = nil,
	pendingKeycapParts = {},
	isKeycapGenerationRunning = nil,
	lastKeycapGenerationError = nil,
	isFinished = nil,
	forcedSpeedHumanoid = nil,
	walkSpeedBeforeMinigame = nil,
	walkSpeedBaseAnchor = nil,
	isWalkSpeedRenderStepBound = nil,
	isTeleportingBack = nil
}

function onStructureSpawn(p)
	local part = Instance.new("Part")
	Debris:AddItem(part, 10)
	part.CastShadow = false
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(220, 145, 255)
	part.CFrame = p.Zone.CFrame
	part.Size = Vector3.new(p.Zone.Size.X * 0.75, 1000, p.Zone.Size.Z * 0.75)
	part.Transparency = 0.25
	part.Parent = Workspace.Terrain
	TweenService:Create(part, TweenInfo.new(1), {
		Size = Vector3.new(p.Zone.Size.X * 1.1, 1000, p.Zone.Size.X * 1.1),
		Transparency = 1
	}):Play()
end

function onPlayerTeleportBack(vector2: Vector3, vector3: Vector3)
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	v.isTeleportingBack = true
	task.spawn(function()
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			v.isTeleportingBack = false
			return
		end

		local pivot = character:GetPivot()
		local rotation = pivot.Rotation
		local boundingBox, v2 = character:GetBoundingBox()
		local objectSpace = pivot:ToObjectSpace(boundingBox)
		local v3 = math.max(v2.X, v2.Y, v2.Z) * 1.25
		local size = createVector(1, 1, 1) * v3
		local anchored = humanoidRootPart.Anchored
		local v5 = (vector2 + vector3) / 2 + createVector(0, 1, 0) * math.max(
			18,
			Vector3.new(vector3.X - vector2.X, 0, vector3.Z - vector2.Z).Magnitude * 0.35
		)
		local lastTime = os.clock()
		local part = Instance.new("Part")
		part.Name = "TeleportBubble"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Color = color2
		part.Material = Enum.Material.ForceField
		part.Shape = Enum.PartType.Ball
		part.Size = size * 0.8
		part.Transparency = 1
		part.CFrame = pivot * objectSpace
		part.Parent = Workspace.Terrain
		Debris:AddItem(part, 0.8 + tweenInfo3.Time + 2)
		TweenService:Create(part, tweenInfo2, {
			Size = size,
			Transparency = 0.35
		}):Play()
		humanoidRootPart.Anchored = true

		while character.Parent and humanoidRootPart.Parent do
			local v6 = math.clamp((os.clock() - lastTime) / 0.8, 0, 1)
			local value2 = TweenService:GetValue(v6, tweenInfo.EasingStyle, tweenInfo.EasingDirection)
			local bezier = Interpolate.bezier(vector2, v5, vector3, value2)
			local v7 = CFrame.new(bezier) * rotation
			character:PivotTo(v7)
			part.CFrame = v7 * objectSpace

			if v6 >= 1 then
				break
			else
				RunService.RenderStepped:Wait()
			end
		end

		if humanoidRootPart.Parent then
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			humanoidRootPart.Anchored = anchored
		end

		if part.Parent then
			local tween = TweenService:Create(part, tweenInfo3, {
				Size = size * 1.2,
				Transparency = 1
			})
			tween:Play()
			tween.Completed:Wait()
			part:Destroy()
		end

		v.isTeleportingBack = false
	end)
end

function hash(value2: string)
	local v2 = 5381

	for i = 1, #value2 do
		v2 = (v2 * 33 + string.byte(value2, i)) % 4294967296
	end

	return v2
end

function getRandomInteger(p: number, p2: number)
	local formatted = `eee_{v.currentIndex or 0}`
	return p + hash(formatted) % (p2 - p + 1)
end

function setup()
	if RunService:IsServer() or flag then
		return
	end

	flag = true
	local fabAdminAbuse = ReplicatedStorage.AdminAbuse.FabAdminAbuse
	local v2 = {}

	for _, folder in getAllStructureModels() do
		local anchorIN = folder:FindFirstChild("AnchorIN")

		if anchorIN then
			local anchorOUT = folder:FindFirstChild("AnchorOUT")

			if anchorOUT then
				local zone = folder:FindFirstChild("Zone")

				if zone then
					if v2[folder.Name] then
						logger:warn(string.format(
							"Duplicate structure name '%s'; removing the later duplicate for this session.",
							folder.Name
						))
						folder:Destroy()
					else
						v2[folder.Name] = true

						if folder:IsA("Folder") then
							local model = Instance.new("Model")

							for _, child in folder:GetChildren() do
								child.Parent = model
							end

							model.Name = folder.Name
							model.PrimaryPart = anchorIN
							model.Parent = fabAdminAbuse.Structures
							folder:Destroy()
							folder = model
						end

						for _, v3 in folder:QueryDescendants("BasePart") do
							v3.Anchored = true
						end

						zone.Transparency = 1
						zone.CanQuery = false
						zone.CanCollide = false
						zone.CanTouch = false
						anchorIN.Transparency = 1
						anchorIN.CanQuery = false
						anchorIN.CanCollide = false
						anchorIN.CanTouch = false
						anchorOUT.Transparency = 1
						anchorOUT.CanQuery = false
						anchorOUT.CanCollide = false
						anchorOUT.CanTouch = false
						anchorIN:ClearAllChildren()
						anchorOUT:ClearAllChildren()
					end
				else
					logger:warn((`Structure {folder.Name} couldn't find Zone, removing for this session...`))
					folder:Destroy()
				end
			else
				logger:warn((`Structure {folder.Name} couldn't find AnchorOUT, removing for this session...`))
				folder:Destroy()
			end
		else
			logger:warn((`Structure {folder.Name} couldn't find AnchorIN, removing for this session...`))
			folder:Destroy()
		end
	end
end

function getStructureModelFromName(childName: string)
	return ReplicatedStorage.AdminAbuse.FabAdminAbuse.Structures:FindFirstChild(childName)
end

function getAllStructureModels()
	return ReplicatedStorage.AdminAbuse.FabAdminAbuse.Structures:GetChildren()
end

function getAllPlacedStructures()
	return v.allStructure or {}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatVector3(vector2: Vector3)
	return string.format("(%.3f,%.3f,%.3f)", vector2.X, vector2.Y, vector2.Z)
end

local function isStructureDirectionValid(instance, cframe2: CFrame, cframe3: CFrame)
	local v2 = cframe2 * instance:GetPivot():Inverse() * instance.AnchorOUT.CFrame
	local v3 = math.acos((math.clamp(cframe3.LookVector:Dot(v2.LookVector), -1, 1)))
	local v4 = v2.Position - cframe2.Position
	local v5 = not (v4.Magnitude > 1e-6) and 0 or math.acos((math.clamp(cframe3.LookVector:Dot(v4.Unit), -1, 1)))
	return v3 <= 1.570970859720096 and v5 <= 1.570970859720096, v2, math.deg(v3), (math.deg(v5))
end

local function getOrientationKey(cframe2: CFrame)
	local rightVector = cframe2.RightVector
	local upVector = cframe2.UpVector
	local lookVector = cframe2.LookVector
	return string.format(
		"%d,%d,%d,%d,%d,%d,%d,%d,%d",
		math.round(rightVector.X * 10000),
		math.round(rightVector.Y * 10000),
		math.round(rightVector.Z * 10000),
		math.round(upVector.X * 10000),
		math.round(upVector.Y * 10000),
		math.round(upVector.Z * 10000),
		math.round(lookVector.X * 10000),
		math.round(lookVector.Y * 10000),
		(math.round(lookVector.Z * 10000))
	)
end

local canReachForwardCycle

canReachForwardCycle = function(list, cframe2: CFrame, cframe3: CFrame, p, p2)
	local orientationKey = getOrientationKey(cframe2)

	if p[orientationKey] then
		return true
	end

	if p2[orientationKey] then
		return false
	end

	p[orientationKey] = true
	local randomInteger = getRandomInteger(1, #list)

	for i = 0, #list - 1 do
		local structureDirectionValid, v3 = isStructureDirectionValid(
			list[(randomInteger + i - 1) % #list + 1],
			cframe2,
			cframe3
		)

		if not (structureDirectionValid and canReachForwardCycle(list, v3, cframe3, p, p2)) then
			continue
		end

		p[orientationKey] = nil
		return true
	end

	p[orientationKey] = nil
	p2[orientationKey] = true
	return false
end

local function chooseNextStructure(cFrame: CFrame)
	local allStructureModels = getAllStructureModels()
	local cFrame2 = v.lastStructure.AnchorOUT.CFrame
	local orientationKey = getOrientationKey(cFrame2)
	local v2 = {}
	local v3 = {}
	local allStructureModels2 = {}

	for _, allStructureModel in allStructureModels do
		local structureDirectionValid, v4, v5, v6 = isStructureDirectionValid(allStructureModel, cFrame2, cFrame)
		local v7 = structureDirectionValid and canReachForwardCycle(allStructureModels, v4, cFrame, {
			[orientationKey] = true
		}, v2)
		table.insert(
			v3,
			string.format(
				"%s{direct=%s,cycle=%s,direction=%.2f,position=%.2f}",
				allStructureModel.Name,
				tostring(structureDirectionValid),
				tostring(v7),
				v5,
				v6
			)
		)

		if v7 then
			table.insert(allStructureModels2, allStructureModel)
		end
	end

	if #allStructureModels2 > 0 then
		v.lastStuckSignature = nil
		return allStructureModels2[getRandomInteger(1, #allStructureModels2)]
	end

	local formatted = `{v.currentIndex or 0}:{orientationKey}`

	if v.lastStuckSignature == formatted then
		return nil
	end

	v.lastStuckSignature = formatted
	local currentIndex = v.currentIndex or 0
	local passedStructureIndex = v.passedStructureIndex or 0
	local name = v.lastStructure.Name
	local v5 = formatVector3(cFrame.LookVector) -- equivalent call inferred; original call site unknown
	local v6 = formatVector3(cFrame2.Position) -- equivalent call inferred; original call site unknown
	local lookVector2 = cFrame2.LookVector
	logger:warn(string.format(
		"[Generation] stuck currentIndex=%d passedIndex=%d last=%s originalLook=%s lastOutPosition=%s lastOutLook=%s candidates=[%s]",
		currentIndex,
		passedStructureIndex,
		name,
		v5,
		v6,
		string.format("(%.3f,%.3f,%.3f)", lookVector2.X, lookVector2.Y, lookVector2.Z),
		table.concat(v3, ",")
	))
	return nil
end

function getStructureIndexFromStructureModel(p)
	if v.structureIndexByStructureModel then
		return v.structureIndexByStructureModel[p] or -1
	end

	return -1
end

local function checkKeycapGenerationReady()
	local keycaps = ReplicatedStorage.AdminAbuse.FabAdminAbuse:FindFirstChild("Keycaps")
	local keycaps2 = Workspace:FindFirstChild("Keycaps")

	if keycaps == nil or not keycaps:IsA("Folder") then
		return false, nil, nil, "ReplicatedStorage.AdminAbuse.FabAdminAbuse.Keycaps is missing."
	end

	if keycaps2 == nil or not keycaps2:IsA("Folder") then
		return false, nil, nil, "workspace.Keycaps is missing."
	end

	return true, keycaps, keycaps2, nil
end

local function generateQueuedKeycapCovers(p: number)
	while p == count do
		local pendingKeycapParts = v.pendingKeycapParts or {}
		local v2 = table.remove(pendingKeycapParts, 1)

		if v2 == nil then
			break
		end

		if not (v2.target.Parent ~= nil and v2.owner.Parent ~= nil) then
			continue
		end

		local v3, v4, parent, lastKeycapGenerationError = checkKeycapGenerationReady()

		if v3 then
			v.lastKeycapGenerationError = nil
			local v7 = v2
			local v8 = v4
			local parent2 = parent
			local success, result = pcall(function()
				AutoKeycapCover.apply(v7.target, v8, {
					scale = 2,
					keycapsPerFrame = 5,
					parent = parent2,
					owner = v7.owner,
					baseColor = color,
					hueOffsetDegrees = 5,
					saturationOffsetPercent = 15,
					valueOffsetPercent = 22
				})
			end)

			if not success then
				logger:warn(string.format(
					"Could not generate keycaps for %s: %s",
					v2.target:GetFullName(),
					(tostring(result))
				))
			end
		elseif lastKeycapGenerationError ~= v.lastKeycapGenerationError then
			v.lastKeycapGenerationError = lastKeycapGenerationError
			logger:warn(lastKeycapGenerationError)
		end
	end

	if p == count then
		v.isKeycapGenerationRunning = false
	end
end

local function queueStructureKeycapCovers(folder)
	local pendingKeycapParts = v.pendingKeycapParts or {}
	v.pendingKeycapParts = pendingKeycapParts

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") and part:HasTag("FabAAKeycapPart") then
			table.insert(pendingKeycapParts, {
				target = part,
				owner = folder
			})
		end
	end

	if #pendingKeycapParts > 0 and not v.isKeycapGenerationRunning then
		v.isKeycapGenerationRunning = true
		local v2 = count
		task.spawn(generateQueuedKeycapCovers, v2)
	end
end

local function onPlayerFallTeleport(_: Vector3, _: Vector3) end

-- equivalent calls inferred from this helper; original call sites unknown
local function restorePlayerWalkSpeed()
	local forcedSpeedHumanoid = v.forcedSpeedHumanoid
	local walkSpeedBeforeMinigame = v.walkSpeedBeforeMinigame

	if forcedSpeedHumanoid ~= nil and forcedSpeedHumanoid.Parent ~= nil and walkSpeedBeforeMinigame ~= nil then
		forcedSpeedHumanoid.WalkSpeed = walkSpeedBeforeMinigame
	end

	v.forcedSpeedHumanoid = nil
	v.walkSpeedBeforeMinigame = nil
end

local function updatePlayerWalkSpeed(instance)
	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoid == nil or humanoidRootPart == nil then
		restorePlayerWalkSpeed() -- equivalent call inferred; original call site unknown
	else
		if v.forcedSpeedHumanoid ~= nil and v.forcedSpeedHumanoid ~= humanoid then
			restorePlayerWalkSpeed() -- equivalent call inferred; original call site unknown
		end

		if (humanoidRootPart.Position - instance.Position):Dot(instance.CFrame.LookVector) >= 0 then
			if v.forcedSpeedHumanoid == nil then
				v.forcedSpeedHumanoid = humanoid
				v.walkSpeedBeforeMinigame = humanoid.WalkSpeed
			end

			humanoid.WalkSpeed = Config.targetPlayerWalkSpeed
		else
			restorePlayerWalkSpeed() -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unbindPlayerWalkSpeedOverride()
	if v.isWalkSpeedRenderStepBound then
		RunService:UnbindFromRenderStep("FabBossEventMinigameWalkSpeed")
		v.isWalkSpeedRenderStepBound = false
	end

	v.walkSpeedBaseAnchor = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindPlayerWalkSpeedOverride(anchorOUT)
	v.walkSpeedBaseAnchor = anchorOUT

	if not v.isWalkSpeedRenderStepBound then
		v.isWalkSpeedRenderStepBound = true
		RunService:BindToRenderStep("FabBossEventMinigameWalkSpeed", value, function()
			local walkSpeedBaseAnchor = v.walkSpeedBaseAnchor

			if walkSpeedBaseAnchor ~= nil and walkSpeedBaseAnchor.Parent ~= nil and not v.isFinished then
				updatePlayerWalkSpeed(walkSpeedBaseAnchor)
				return
			end

			restorePlayerWalkSpeed() -- equivalent call inferred; original call site unknown
		end)
	end
end

function spawnStructure(instance, instance2, p)
	v.allStructure = v.allStructure or {}
	v.structureIndexByStructureModel = v.structureIndexByStructureModel or {}
	v.currentIndex = v.currentIndex or 0
	v.currentIndex = (v.currentIndex or 0) + 1
	local clone = instance2:Clone()
	clone:PivotTo(instance:GetPivot())
	clone.Parent = p.AllStructures
	queueStructureKeycapCovers(clone)
	onStructureSpawn(clone)
	v.lastStructure = clone
	v.allStructure[v.currentIndex] = clone
	v.structureIndexByStructureModel[clone] = v.currentIndex
end

function getLocalPlayerStructureFromZone()
	local localPlayer = Players.LocalPlayer
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	for _, v2 in getAllPlacedStructures() do
		if SpacialQuery.isPositionInPart(humanoidRootPart.Position, v2.Zone) then
			return v2
		end
	end

	return nil
end

function Minigame.init()
	setup()
	count += 1

	if RunService:IsClient() then
		unbindPlayerWalkSpeedOverride() -- equivalent call inferred; original call site unknown
	end

	restorePlayerWalkSpeed() -- equivalent call inferred; original call site unknown
	table.clear(v)
	v.isFinished = false
end

function Minigame.finish()
	if v.isFinished then
		return
	end

	v.isFinished = true
	count += 1

	if RunService:IsClient() then
		unbindPlayerWalkSpeedOverride() -- equivalent call inferred; original call site unknown
	end

	restorePlayerWalkSpeed() -- equivalent call inferred; original call site unknown

	if RunService:IsServer() then
		local PlayerTeleport = require(ServerScriptService.Utilities.PlayerTeleport)

		for _, v2 in Players:GetPlayers() do
			PlayerTeleport.toLobby(v2, PlayerTeleport.Reason.Event)
		end
	else
		for _, v2 in getAllPlacedStructures() do
			v2:Destroy()
		end
	end

	table.clear(v.pendingKeycapParts or {})
	table.clear(v.allStructure or {})
	table.clear(v.structureIndexByStructureModel or {})
	v.lastStructure = nil
	v.currentIndex = nil
	v.passedStructureIndex = nil
	v.destroyedThroughIndex = nil
	v.isKeycapGenerationRunning = false
end

function Minigame.returnLocalPlayerToLobby()
	if RunService:IsClient() then
		Minigame.finish()
		local character = Players.LocalPlayer.Character
		local humanoidRootPart

		if character ~= nil then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		if character ~= nil and humanoidRootPart ~= nil then
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			local spawnLocation = Workspace:FindFirstChild("SpawnLocation", true)
			local v2

			if spawnLocation == nil or not spawnLocation:IsA("BasePart") then
				v2 = cframe
			else
				v2 = spawnLocation.CFrame * CFrame.new(Config2.SPAWN_OFFSET)
			end

			character:PivotTo(v2)
		end

		Minigame.init()
	end
end

function Minigame.update(p, p2)
	if RunService:IsServer() or v.isFinished then
		return
	end

	updatePlayerWalkSpeed(p2.Scriptables.AnchorOUT)
	bindPlayerWalkSpeedOverride(p2.Scriptables.AnchorOUT) -- equivalent call inferred; original call site unknown

	if not v.lastStructure then
		spawnStructure(p2.Scriptables.AnchorOUT, getStructureModelFromName("Straight"), p2)
	end

	local localPlayerStructureFromZone = getLocalPlayerStructureFromZone()

	if localPlayerStructureFromZone then
		local passedStructureIndex = v.passedStructureIndex or 0
		local passedStructureIndex2 = math.max(
			getStructureIndexFromStructureModel(localPlayerStructureFromZone),
			v.passedStructureIndex or 0
		)

		if passedStructureIndex < passedStructureIndex2 and passedStructureIndex2 >= 2 then
			p.FireClientEvent(Config.checkpointWinRequest)
		end

		v.passedStructureIndex = passedStructureIndex2
		local destroyedThroughIndex = passedStructureIndex2 - 10
		local v4 = (v.destroyedThroughIndex or 0) + 1

		if v4 <= destroyedThroughIndex then
			local allStructure = v.allStructure or {}
			local structureIndexByStructureModel = v.structureIndexByStructureModel

			for i = v4, destroyedThroughIndex do
				local v5 = allStructure[i]

				if not v5 then
					continue
				end

				allStructure[i] = nil

				if structureIndexByStructureModel then
					structureIndexByStructureModel[v5] = nil
				end

				v5:Destroy()
			end

			v.destroyedThroughIndex = destroyedThroughIndex
		end
	elseif v.passedStructureIndex then
		local v2 = getAllPlacedStructures()[v.passedStructureIndex]
		local character = Players.LocalPlayer.Character
		local humanoidRootPart

		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		local humanoid

		if character then
			humanoid = character:FindFirstChildOfClass("Humanoid")
		end

		if v2 and character and humanoidRootPart and humanoid and humanoid.Health > 0 and not v.isTeleportingBack then
			local position = humanoidRootPart.Position
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			local v3 = humanoid.HipHeight + humanoidRootPart.Size.Y / 2
			onPlayerTeleportBack(position, (v2.AnchorIN.CFrame + v2.AnchorIN.CFrame.UpVector * v3).Position)
		end
	end

	while true do
		local v2 = (v.currentIndex or 0) < (v.passedStructureIndex or 0) + 5 and chooseNextStructure(p2.Scriptables.AnchorOUT.CFrame)

		if not v2 then
			break
		end

		spawnStructure(v.lastStructure.AnchorOUT, v2, p2)
	end
end

return Minigame