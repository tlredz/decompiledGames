local createVector = vector.create
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local NPCManager = require(game.ReplicatedStorage.NPCManager)
local Effect = require(game.ReplicatedStorage.Effect)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local Util = require(game.ReplicatedStorage.Util)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
local localPlayer = game.Players.LocalPlayer
local rescueHasan = script["Rescue Hasan"]
local folder = Instance.new("Folder", script)
folder.Name = "StatueBin"
local hasan = workspace.NPCs:WaitForChild("Hasan")
local pivot = hasan:GetPivot()
local children = {}

for i = 1, 4 do
	local child = rescueHasan.Statues:FindFirstChild(i)

	if child then
		table.insert(children, child)
	end
end

local v = {
	{
		part = "Camera1",
		drift = createVector(10, 0, 0),
		hold = 2.6
	},
	{
		part = "Camera2",
		drift = createVector(-10, 0, 0),
		hold = 2.6
	},
	{
		part = "Camera3"
	}
}
local frozen = table.freeze({
	"DesertBonusMoments.BF_DesertBonus_Bone_Rattling_01",
	"DesertBonusMoments.BF_DesertBonus_Bone_Rattling_02",
	"DesertBonusMoments.BF_DesertBonus_Bone_Rattling_03",
	"DesertBonusMoments.BF_DesertBonus_Bone_Rattling_04",
	"DesertBonusMoments.BF_DesertBonus_Bone_Rattling_05"
})
local v2 = {
	PAN_TIME = 1.2,
	BLEND_IN = 0.35,
	FADE_OUT = 0.7
}
local color = Color3.fromRGB(214, 179, 122)
local color2 = Color3.fromRGB(143, 109, 63)
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function shakeAt(vector2: Vector3, p: number, p2: number, p3: number, p4: number)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local magnitude = (currentCamera.CFrame.Position - vector2).Magnitude

	if magnitude > 140 then
		return
	end

	Util.CameraShaker:ShakeOnce(p * (1 - magnitude / 140), p2, p3, p4)
end

local function rayParams(items)
	local filterDescendantsInstances = { rescueHasan, folder, hasan }

	for _, childName in { "Enemies", "RescueHasanScene", "RescueHasanLids" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(filterDescendantsInstances, child)
		end
	end

	if localPlayer.Character then
		table.insert(filterDescendantsInstances, localPlayer.Character)
	end

	if items then
		for _, item in items do
			table.insert(filterDescendantsInstances, item)
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	return raycastParams
end

-- equivalent calls inferred from this helper; original call sites unknown
local function castGround(vector2: Vector3, p)
	local raycastResult = workspace:Raycast(vector2 + createVector(0, 8, 0), createVector(-0, -56, -0), (rayParams(p)))

	if raycastResult then
		return raycastResult.Position
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function worldHalfHeight(cframe: CFrame, vector2: Vector3)
	return (math.abs(cframe.RightVector.Y) * vector2.X + math.abs(cframe.UpVector.Y) * vector2.Y + math.abs(cframe.LookVector.Y) * vector2.Z) / 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flatten(lookVector: Vector3)
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector2.Magnitude > 0.001 then
		return vector2.Unit
	end

	return createVector(0, 0, 1)
end

local function randomRange(p: number, p2: number)
	return p + math.random() * (p2 - p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function randomSigned(p: number)
	return (math.random() - 0.5) * 2 * p
end

local function newLidProfile()
	return {
		speed = 7 + math.random() * 5,
		lift = 1 + math.random() * 3,
		tipSpin = 1.2 + math.random() * 1.2,
		yawSpin = randomSigned(0.6),
		pitch = 0.9 + math.random() * 0.20000000000000007
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSceneFolder()
	local desert = workspace.Map:FindFirstChild("Desert")

	if desert then
		return (desert:FindFirstChild("Rescue Hasan"))
	end

	return nil
end

local function nearestStatue(position: Vector3)
	local v4 = 1e999
	local v5 = nil

	for _, v6 in children do
		local magnitude = (v6:GetPivot().Position - position).Magnitude

		if not (magnitude < v4) then
			continue
		end

		v5 = v6
		v4 = magnitude
	end

	return v5
end

local function buildCoffins()
	if v3 then
		return v3
	end

	local sceneFolder = getSceneFolder() -- equivalent call inferred; original call site unknown
	local models = {}

	if sceneFolder then
		for _, model in sceneFolder:GetChildren() do
			if not (model.Name == "Coffin" and model:IsA("Model")) then
				continue
			end

			local skeleton_CF = model:FindFirstChild("Skeleton_CF")

			if skeleton_CF and skeleton_CF:IsA("BasePart") then
				table.insert(models, model)
			end
		end

		table.sort(models, function(a, b)
			local position = a:FindFirstChild("Skeleton_CF").Position
			local position2 = b:FindFirstChild("Skeleton_CF").Position

			if position.X == position2.X then
				return position.Z < position2.Z
			end

			return position.X < position2.X
		end)
	end

	local result = {}

	for _, model in models do
		local skeleton_CF = model:FindFirstChild("Skeleton_CF")
		local coffin = model:FindFirstChild("coffin")
		local lid = model:FindFirstChild("Lid")

		if not (coffin and coffin:IsA("BasePart")) then
			coffin = nil
		end

		if not (lid and lid:IsA("BasePart")) then
			lid = nil
		end

		local lookVector = skeleton_CF.CFrame.LookVector

		if coffin then
			lookVector = coffin.CFrame.UpVector
		elseif lid then
			lookVector = lid.CFrame.UpVector
		end

		local position = skeleton_CF.Position
		local raycastResult = workspace:Raycast(
			position + createVector(0, 8, 0),
			createVector(-0, -56, -0),
			(rayParams({ model }))
		)
		local position2

		if raycastResult then
			position2 = raycastResult.Position
		end

		local v5 = coffin or lid
		local v6

		if v5 then
			v6 = worldHalfHeight(v5.CFrame, v5.Size)
		else
			v6 = 7
		end

		local Y

		if v5 then
			Y = v5.Position.Y
		else
			Y = skeleton_CF.Position.Y
		end

		local position3

		if coffin then
			position3 = coffin.Position
		else
			position3 = skeleton_CF.Position
		end

		local flat = flatten(lookVector) -- equivalent call inferred; original call site unknown
		local v8 = {
			model = model,
			lead = model:GetAttribute("Lead") == true,
			body = coffin,
			lid = lid,
			statue = nearestStatue(skeleton_CF.Position),
			markerPosition = skeleton_CF.Position,
			groundPosition = position2 or skeleton_CF.Position - createVector(0, 4, 0),
			outward = lookVector,
			flat = flat,
			frontBase = Vector3.new(position3.X, 0, position3.Z) + flat * 3,
			bottomY = Y - v6,
			height = v6 * 2,
			profile = newLidProfile(),
			closedPivot = model:GetPivot(),
			lidClosed = 0,
			lidCanCollide = 0,
			lidTransparency = 0,
			debris = nil,
			opened = false,
			generation = 0,
			connections = 0
		}
		local lidClosed

		if lid then
			lidClosed = lid.CFrame
		else
			lidClosed = CFrame.identity
		end

		v8.lidClosed = lidClosed
		v8.lidCanCollide = not lid or lid.CanCollide
		v8.lidTransparency = not lid and 0 or lid.Transparency
		v8.connections = {}
		table.insert(result, v8)
	end

	v3 = result
	return result
end

local function getLeadCoffin()
	for k, v4 in buildCoffins() do
		if v4.lead then
			return v4, k
		end
	end

	return nil, nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopEntry(state)
	state.generation += 1

	for _, connection in state.connections do
		connection:Disconnect()
	end

	table.clear(state.connections)
end

local function sandBurst(position: Vector3, p: number, p2: number, duration: number)
	Effect.new("DustExplosion"):play({
		CFrame = CFrame.new(position),
		Size = { p, p2 },
		Duration = duration,
		ColorSequence = ColorSequence.new(color, color2)
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function frontPoint(data, p: number, value: number?)
	local v4 = data.frontBase + data.flat * (value or 0)
	return (Vector3.new(v4.X, data.bottomY + data.height * p, v4.Z))
end

local function rumbleCoffin(data)
	stopEntry(data) -- equivalent call inferred; original call site unknown
	local model = data.model

	if not model.Parent then
		return
	end

	shakeAt(data.markerPosition, 2.5, 14, 0.15, 0.45) -- equivalent call inferred; original call site unknown
	local closedPivot = data.closedPivot
	local lastTime = os.clock()
	local v4 = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v5 = (os.clock() - lastTime) / 0.45

		if v5 >= 1 or not model.Parent then
			heartbeatConnection:Disconnect()
			model:PivotTo(closedPivot)
		else
			local v6 = 0.11 * v5
			local v7 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 2 * v6
			model:PivotTo(closedPivot * CFrame.new(v7))
			local now = os.clock()

			if v4 <= now then
				v4 = os.clock() + 0.15
				local v10 = 0.15 + math.random() * 0.7999999999999999
				local v11 = randomSigned(1) -- equivalent call inferred; original call site unknown
				sandBurst(frontPoint(data, v10, v11), 1.5, 5, 0.5)
			end
		end
	end)
	table.insert(data.connections, heartbeatConnection)
end

local v4 = nil

local function getDebrisFolder()
	local v5 = v4

	if v5 and v5.Parent then
		return v5
	end

	local folder2 = Instance.new("Folder")
	folder2.Name = "RescueHasanLids"
	folder2.Parent = workspace
	v4 = folder2
	return folder2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideLid(p)
	local lid = p.lid

	if not lid then
		return
	end

	lid.CanCollide = false
	lid.Transparency = 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearDebris(p)
	local debris = p.debris

	if debris then
		p.debris = nil
		debris:Destroy()
	end
end

local function despawnLid(state)
	local debris = state.debris

	if debris and debris.Parent then
		Effect.new("Chests.Despawn"):play({
			CFrame = CFrame.new(debris.Position)
		})
	end

	clearDebris(state) -- equivalent call inferred; original call site unknown
end

local function shoveLid(state)
	stopEntry(state) -- equivalent call inferred; original call site unknown
	clearDebris(state) -- equivalent call inferred; original call site unknown
	state.model:PivotTo(state.closedPivot)
	local profile = state.profile
	local v5 = frontPoint(state, 0.5) -- equivalent call inferred; original call site unknown
	Sound:Play("Other.StoneDoor", v5, nil, profile.pitch * 0.55, 1)
	Sound:Play("Terrain.TileShatter", v5, nil, profile.pitch * 0.7, 0.35)
	local v7 = state.frontBase + state.flat * 0.5
	sandBurst(Vector3.new(v7.X, state.bottomY + state.height * 0.76, v7.Z), 2, 8, 0.8)
	local v9 = state.frontBase + state.flat * 0.5
	sandBurst(Vector3.new(v9.X, state.bottomY + state.height * 0.3, v9.Z), 2, 7, 0.8)
	shakeAt(v5, 2, 9, 0.05, 0.5) -- equivalent call inferred; original call site unknown
	local lid = state.lid

	if not lid or state.opened then
		return
	end

	local clone = lid:Clone()
	clone.Name = "CoffinLidDebris"
	clone.Anchored = false
	clone.CanCollide = true
	clone.CanQuery = false
	clone.CanTouch = false
	clone.CollisionGroup = "Chest"
	clone.CFrame = state.lidClosed + state.flat * 0.15
	local parent = v4

	if not (parent and parent.Parent) then
		parent = Instance.new("Folder")
		parent.Name = "RescueHasanLids"
		parent.Parent = workspace
		v4 = parent
	end

	clone.Parent = parent
	clone.AssemblyLinearVelocity = state.flat * profile.speed + createVector(0, 1, 0) * profile.lift
	clone.AssemblyAngularVelocity = (createVector(0, 1, 0)):Cross(state.flat).Unit * profile.tipSpin + createVector(
		0,
		1,
		0
	) * profile.yawSpin
	state.debris = clone
	state.opened = true
	hideLid(state) -- equivalent call inferred; original call site unknown
	local generation = state.generation
	task.delay(3, function()
		if state.generation ~= generation then
			return
		end

		despawnLid(state)
	end)
end

local function wakeBurst(p)
	local groundPosition = p.groundPosition
	local position = groundPosition + createVector(0, 5.5, 0)
	Sound:Play("Sand1.SandVExplosion", position, nil, p.profile.pitch * 0.8, 0.7)
	sandBurst(groundPosition + createVector(0, 1, 0), 5, 18, 0.9)
	sandBurst(position, 4, 14, 0.8)
	Effect.new("ShineExplosion"):play({
		Position = position,
		Size = 8,
		Lifetime = { 0.2, 0.35 }
	})
	Effect.new("ExpandRing"):play({
		Origin = CFrame.lookAt(groundPosition, groundPosition + createVector(0, 1, 0)),
		Color = color2,
		Size = { createVector(4, 4, 1), createVector(22, 22, 1) },
		Duration = 0.45
	})
	shakeAt(groundPosition, 4, 10, 0.03, 0.7) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCoffinOpen(coffin, opened: boolean)
	stopEntry(coffin) -- equivalent call inferred; original call site unknown
	clearDebris(coffin) -- equivalent call inferred; original call site unknown
	coffin.model:PivotTo(coffin.closedPivot)
	local lid = coffin.lid

	if not lid then
		return
	end

	coffin.opened = opened

	if opened then
		if not coffin.lead then
			hideLid(coffin) -- equivalent call inferred; original call site unknown
		end
	else
		lid.CanCollide = coffin.lidCanCollide
		lid.Transparency = coffin.lidTransparency
	end
end

local function reflectSkeletonVisibility(p)
	local coffins = buildCoffins()

	if #coffins == 0 then
		for k, v5 in children do
			if k <= p then
				v5.Parent = folder
			else
				v5.Parent = rescueHasan.Statues
			end
		end
	else
		for k, coffin in coffins do
			local opened = k <= p

			if coffin.statue then
				local statue = coffin.statue
				local parent

				if opened then
					parent = folder
				else
					parent = rescueHasan.Statues
				end

				statue.Parent = parent
			end

			setCoffinOpen(coffin, opened)
		end

		local v5 = nil

		for _, v7 in buildCoffins() do
			if not v7.lead then
				continue
			end

			v5 = v7
			break
		end

		if v5 then
			if v5.statue then
				v5.statue.Parent = folder
			end

			stopEntry(v5) -- equivalent call inferred; original call site unknown
			clearDebris(v5) -- equivalent call inferred; original call site unknown
			v5.model:PivotTo(v5.closedPivot)

			if not v5.lid then
				return
			end

			v5.opened = true

			if not v5.lead then
				hideLid(v5) -- equivalent call inferred; original call site unknown
			end
		end
	end
end

local v5 = nil
local v6 = nil
local v7 = nil
local v8 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function isRealHasanHidden()
	return next(v8) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHasanNPC()
	return NPCManager.getNPCsByName("Hasan")[1]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setHasanInteractable(flag: boolean)
	local hasanNPC = getHasanNPC() -- equivalent call inferred; original call site unknown

	if not hasanNPC then
		return
	end

	local _modelState = hasanNPC._modelState
	local _instance

	if _modelState then
		_instance = _modelState._instance
	end

	if _instance then
		_instance:SetAttribute("LockedInteraction", not flag)
	end

	local _interactionController = hasanNPC._interactionController
	local _entry

	if _interactionController then
		_entry = _interactionController._entry
	end

	local GUI

	if _entry then
		GUI = _entry.GUI
	end

	local interactionLock

	if GUI then
		interactionLock = GUI.InteractionLock
	end

	if interactionLock then
		if flag then
			interactionLock:Unlock("RescueHasanMoment")
		else
			interactionLock:Lock("RescueHasanMoment")
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyHasanAura()
	local hasanNPC = getHasanNPC() -- equivalent call inferred; original call site unknown
	local _interactionController

	if hasanNPC then
		_interactionController = hasanNPC._interactionController
	end

	local aura

	if _interactionController then
		aura = _interactionController.Aura
	end

	if aura then
		_interactionController.Aura = nil
		aura:Destroy()
	end
end

local function ensureHasanAura(type: number?)
	local hasanNPC = getHasanNPC() -- equivalent call inferred; original call site unknown
	local _interactionController

	if hasanNPC then
		_interactionController = hasanNPC._interactionController
	end

	if not _interactionController then
		return
	end

	local questInfo = hasanNPC._npcInfo.QuestInfo

	if not type then
		if questInfo then
			type = questInfo.Type
		else
			type = nil
		end
	end

	if type and questInfo and questInfo.Type ~= type then
		_interactionController:ChangeType(type)
	elseif not _interactionController.Aura then
		_interactionController:_updateQuestTypeVisuals()
	end
end

local function setRealHasanHidden(flag: boolean, p: number?)
	if flag then
		for _, descendant in hasan:GetDescendants() do
			if v8[descendant] ~= nil then
				continue
			end

			if descendant:IsA("BasePart") then
				v8[descendant] = descendant.Transparency
				descendant.Transparency = 1
			elseif descendant:IsA("BillboardGui") then
				v8[descendant] = descendant.Enabled
				descendant.Enabled = false
			end
		end

		setHasanInteractable(false) -- equivalent call inferred; original call site unknown
		destroyHasanAura() -- equivalent call inferred; original call site unknown
	else
		for instance, v9 in v8 do
			if not instance.Parent then
				continue
			end

			if instance:IsA("BasePart") then
				instance.Transparency = v9
			elseif instance:IsA("BillboardGui") then
				instance.Enabled = v9
			end
		end

		table.clear(v8)
		setHasanInteractable(true) -- equivalent call inferred; original call site unknown
		ensureHasanAura(p)
	end
end

local function stripToMannequin(folder2)
	local humanoidRootPart = folder2:FindFirstChild("HumanoidRootPart")
	local descendants = {}

	for _, descendant in folder2:GetDescendants() do
		if not (descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") or descendant:IsA("ProximityPrompt") or descendant:IsA("ClickDetector") or descendant:IsA("Highlight") or descendant:IsA("LuaSourceContainer") or humanoidRootPart ~= nil and descendant:IsA("BasePart") and descendant.Parent == humanoidRootPart) then
			continue
		end

		table.insert(descendants, descendant)
	end

	for _, v9 in descendants do
		v9:Destroy()
	end

	for _, descendant in folder2:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = descendant == humanoidRootPart
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		elseif descendant:IsA("Humanoid") then
			descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			descendant.AutoRotate = false
			descendant.WalkSpeed = 0
			descendant.JumpPower = 0
		end
	end
end

local function getAnimator(instance)
	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		return nil
	end

	local animator = humanoid:FindFirstChildWhichIsA("Animator")

	if animator then
		return animator
	end

	local animator2 = Instance.new("Animator")
	animator2.Parent = humanoid
	return animator2
end

local function playMannequinAnimation(clone, animationId: string)
	local humanoid = clone:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		warn((`[Rescue Hasan] {clone.Name} has no Humanoid, cannot pose it`))
		return
	end

	local parent = humanoid:FindFirstChildWhichIsA("Animator")

	if not parent then
		parent = Instance.new("Animator")
		parent.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.Name = "MannequinPose"
	animation.AnimationId = animationId
	animation.Parent = parent
	local track = parent:LoadAnimation(animation)
	track.Looped = true
	track.Priority = Enum.AnimationPriority.Action
	track:Play(0)
end

local function placeMannequin(instance, p, name: string, folder2, animationId: string)
	local clone = instance:Clone()
	clone.Name = name
	stripToMannequin(clone)
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		clone.PrimaryPart = humanoidRootPart
		clone.WorldPivot = humanoidRootPart.CFrame
	end

	clone:PivotTo(p.CFrame)
	clone.Parent = folder2
	playMannequinAnimation(clone, animationId)
	return clone
end

local function buildScene()
	local v9 = v5

	if v9 and v9.Parent then
		return
	end

	local sceneFolder = getSceneFolder() -- equivalent call inferred; original call site unknown

	if not sceneFolder then
		return
	end

	local folder2 = Instance.new("Folder")
	folder2.Name = "RescueHasanScene"
	folder2.Parent = workspace
	v5 = folder2
	local hasan_CF = sceneFolder:FindFirstChild("Hasan_CF")

	if hasan_CF and hasan_CF:IsA("BasePart") and hasan:IsA("Model") then
		local realHasanHidden = isRealHasanHidden() -- equivalent call inferred; original call site unknown

		if realHasanHidden then
			setRealHasanHidden(false)
		end

		v6 = placeMannequin(hasan, hasan_CF, "Hasan Mannequin", folder2, "rbxassetid://113996497594874")

		if realHasanHidden then
			setRealHasanHidden(true)
		end
	end

	local skeleton_CF = sceneFolder:FindFirstChild("Skeleton_CF")
	local desertSkeleton = script:FindFirstChild("Desert Skeleton")

	if skeleton_CF and skeleton_CF:IsA("BasePart") and desertSkeleton and desertSkeleton:IsA("Model") then
		v7 = placeMannequin(
			desertSkeleton,
			skeleton_CF,
			"Desert Skeleton Mannequin",
			folder2,
			"rbxassetid://85793859115096"
		)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearScene()
	v6 = nil
	v7 = nil
	local v9 = v5

	if v9 then
		v5 = nil
		v9:Destroy()
	end
end

local function findStoredAnimation(childName: string)
	local storage = game.ReplicatedStorage:FindFirstChild("Storage")
	local anims

	if storage then
		anims = storage:FindFirstChild("Anims")
	end

	local animation

	if anims then
		animation = anims:FindFirstChild(childName, true)
	end

	if animation and animation:IsA("Animation") then
		return animation
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function standOffset(instance)
	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoid and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoid.HipHeight + humanoidRootPart.Size.Y / 2
	end

	return 2.35
end

local function walkMannequinHome(instance, pivot2: CFrame, handOver)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		handOver()
		return
	end

	local storedAnimation = findStoredAnimation("NPC_Walk")
	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")
	local v9

	if humanoid then
		v9 = humanoid:FindFirstChildWhichIsA("Animator")

		if not v9 then
			v9 = Instance.new("Animator")
			v9.Parent = humanoid
		end
	end

	if storedAnimation and v9 then
		for _, v10 in v9:GetPlayingAnimationTracks() do
			v10:Stop(0.2)
		end

		local track = v9:LoadAnimation(storedAnimation)
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Movement
		track:Play(0.2)
	end

	local v10 = standOffset(instance) -- equivalent call inferred; original call site unknown
	local position = humanoidRootPart.Position
	local magnitude = (Vector3.new(pivot2.Position.X, 0, pivot2.Position.Z) - Vector3.new(position.X, 0, position.Z)).Magnitude
	local lastTime = os.clock()
	local Y = humanoidRootPart.Position.Y
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if not (instance.Parent and humanoidRootPart.Parent) then
			heartbeatConnection:Disconnect()
			return
		end

		local position2 = humanoidRootPart.Position
		local vector2 = Vector3.new(pivot2.Position.X - position2.X, 0, pivot2.Position.Z - position2.Z)
		local magnitude2 = vector2.Magnitude

		if magnitude2 <= 0.35 or os.clock() - lastTime > 12 then
			heartbeatConnection:Disconnect()
			instance:PivotTo(pivot2)
			handOver()
		else
			local v11 = math.min(9 * dt, magnitude2)
			local unit = vector2.Unit
			local v12 = position2 + unit * v11
			local v14 = castGround(Vector3.new(v12.X, position2.Y, v12.Z), { instance }) -- equivalent call inferred; original call site unknown
			local v15

			if v14 then
				v15 = v14.Y + v10
			else
				v15 = Y
			end

			Y = math.max(v15, Y - 26 * dt)
			local v16 = magnitude - magnitude2
			local v17 = not (magnitude > 0) and 1 or math.clamp(v16 / magnitude, 0, 1)
			local rotation = CFrame.lookAt(createVector(0, 0, 0), unit).Rotation
			local v18 = math.clamp((v17 - 0.85) / 0.15000000000000002, 0, 1)
			local lerped = rotation:Lerp(pivot2.Rotation, v18)
			humanoidRootPart.CFrame = CFrame.new(v12.X, Y, v12.Z) * lerped
		end
	end)
end

local function getCameraShot(childName: string)
	local sceneFolder = getSceneFolder() -- equivalent call inferred; original call site unknown
	local part

	if sceneFolder then
		part = sceneFolder:FindFirstChild(childName)
	end

	if part and part:IsA("BasePart") then
		return part.CFrame
	end

	return nil
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function smoothstep(p: number)
	return p * p * (3 - p * 2)
end

local function sweepCamera(object, cframe: CFrame, cframe2: CFrame, p: number, isFinished)
	if p <= 0 then
		object:SetCFrame(cframe2)
		return not isFinished()
	end

	local total = 0

	while total < p do
		if isFinished() then
			return false
		end

		total += RunService.RenderStepped:Wait()
		object:SetCFrame(cframe:Lerp(cframe2, smoothstep(math.clamp(total / p, 0, 1))))
	end

	return not isFinished()
end

local v9 = false
local v10 = false
local v11 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function freezePlayer(parent, object)
	object:Disable()

	if not parent:FindFirstChild("DisableMovement") then
		local folder2 = Instance.new("Folder")
		folder2.Name = "DisableMovement"
		folder2.Parent = parent
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unfreezePlayer(instance, object)
	object:Enable()
	local disableMovement = instance:FindFirstChild("DisableMovement")

	if disableMovement then
		disableMovement:Destroy()
	end
end

local function buildCutsceneDialogue(object, object2)
	local v12 = DialogueController.new()
	v12:setTitle("Hasan")
	return v12:addPage("Panic", function(object3)
		object3:setTitle("Hasan")
		object3:noCancel()
		object3:addText("<AnimateEffect=ShoutShake>HELP!! IS ANYBODY THERE?! IN HERE!!<AnimateEffect=/>")
		object3:addText("I JUST SPAWNED IN!! GET THIS THING AWAY FROM ME! I HATEEE SKELETONS!")
		object3:addText("I HEARD SOMEONE! IF YOU'RE LISTENING, I NEED HELP! BUT BE WARNED.. THERE MIGHT BE MORE SKELETONS HIDING!")
		object3:addOptionType("Chat", function(object4)
			object4:setText("Help Hasan")
			object4:onSelected(function()
				v10 = true
				object2:MoveTo(rescueHasan.WalkInPoint.Position)
				object:FireServer("StartWaves")
			end)
		end)
		object3:addOptionType("Leave", function(object4)
			object4:setText("Walk away")
			object4:onSelected(function()
				object2:MoveTo(rescueHasan.WalkAwayPoint.Position)
			end)
		end)
	end):build()
end

local function startCutscene(state, character, humanoid, controls)
	if v9 or DialogueController.Active or DialogueController.Terminating then
		return
	end

	v9 = true
	freezePlayer(character, controls) -- equivalent call inferred; original call site unknown
	local v12 = CameraController.new(nil, 1, 0.35)
	local flag = false
	task.spawn(function()
		while not flag do
			Sound:Play(frozen[math.random(1, #frozen)])
			task.wait(1.5 + math.random() * 1)
		end
	end)

	local function finish()
		if flag then
			return
		end

		flag = true
		v9 = false
		v11 = nil
		unfreezePlayer(character, controls) -- equivalent call inferred; original call site unknown
		v12:FadeOut(0.7)
	end

	v11 = finish
	humanoid.Died:Once(finish)
	task.spawn(function()
		local function isFinished()
			return flag
		end

		local v13 = nil

		for _, v14 in v do
			local part = v14.part
			local sceneFolder = getSceneFolder() -- equivalent call inferred; original call site unknown
			local part2

			if sceneFolder then
				part2 = sceneFolder:FindFirstChild(part)
			end

			local cFrame

			if part2 and part2:IsA("BasePart") then
				cFrame = part2.CFrame
			end

			if cFrame then
				if v13 then
					if not sweepCamera(v12, v13, cFrame, 1.2, isFinished) then
						return
					end
				else
					v12:SetCFrame(cFrame)
				end

				local drift = v14.drift

				if drift then
					v13 = cFrame * CFrame.new(drift)

					if not sweepCamera(v12, cFrame, v13, v14.hold or 0, isFinished) then
						return
					end
				else
					v13 = cFrame
				end
			else
				warn((`[Rescue Hasan] no "{v14.part}" part under Desert.Rescue Hasan, beat skipped`))
			end
		end

		if flag then
			return
		end

		local cutsceneDialogue = buildCutsceneDialogue(state, humanoid)
		cutsceneDialogue:getMaid():GiveTask(finish)

		if not DialogueController.start(cutsceneDialogue) then
			if flag then
				return
			end

			flag = true
			v9 = false
			v11 = nil
			unfreezePlayer(character, controls) -- equivalent call inferred; original call site unknown
			v12:FadeOut(v2.FADE_OUT)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateHasanFloorPos()
	hasan:SetAttribute("FloorPos", hasan:GetPivot().Position - createVector(0, 2.385, 0))
end

local function releaseSkeletonMannequin()
	local v12 = v7

	if not v12 then
		return
	end

	v7 = nil
	v12:Destroy()
end

local flag = false

local function returnHasanHome()
	if flag then
		return
	end

	flag = true
	local v12 = v7
	v7 = nil

	if v12 then
		v12:Destroy()
	end

	local v13 = v6
	v6 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function handOver()
		clearScene() -- equivalent call inferred; original call site unknown
		setRealHasanHidden(false, 2)
	end

	if v13 and v13.Parent then
		walkMannequinHome(v13, pivot, handOver)
		return
	end

	handOver() -- equivalent call inferred; original call site unknown
end

local RescueHasan = {}
RescueHasan.DataName = script.Name
RescueHasan.LoadWhenCompleted = true

function RescueHasan.OnLoad(state)
	rescueHasan.Parent = workspace
	local hasanNPC = getHasanNPC() -- equivalent call inferred; original call site unknown

	while not hasanNPC._isInitialized do
		task.wait(0.1)
	end

	hasan:PivotTo(pivot)

	if state.Completed then
		flag = true
		clearScene() -- equivalent call inferred; original call site unknown
		setRealHasanHidden(false, 2)
		state.Progress = 2
		reflectSkeletonVisibility(4)
	else
		flag = false
		hasanNPC._interactionController:ChangeType(4)
		buildScene()
		setRealHasanHidden(true)
		state.Progress = 0
		reflectSkeletonVisibility(0)
		local PlayerModule = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
		local controls = PlayerModule:GetControls()
		state.Trove:Add(rescueHasan.CutsceneTrigger.Touched:Connect(function(otherPart)
			local character = localPlayer.Character

			if v10 or v9 or not (character and character.PrimaryPart and otherPart:IsDescendantOf(character)) then
				return
			end

			local humanoid = character:FindFirstChildWhichIsA("Humanoid")

			if not humanoid then
				return
			end

			startCutscene(state, character, humanoid, controls)
		end))
	end

	updateHasanFloorPos() -- equivalent call inferred; original call site unknown
	state.Trove:Add(function()
		if v11 then
			v11()
		end

		v10 = false
		flag = false
		clearScene() -- equivalent call inferred; original call site unknown
		setRealHasanHidden(false)

		for _, v12 in buildCoffins() do
			setCoffinOpen(v12, false) -- equivalent call inferred; original call site unknown
		end

		if v4 then
			v4:Destroy()
			v4 = nil
		end

		rescueHasan.Parent = script
	end)
end

RescueHasan.RemoteEvents = {
	UpdateProgress = function(p, progress)
		p.Progress = progress

		if progress >= 1 then
			returnHasanHome()
		end
	end,
	CoffinRumble = function(_, p)
		local v12 = buildCoffins()[p]

		if v12 then
			rumbleCoffin(v12)
		end
	end,
	CoffinOpen = function(_, p)
		local v12 = buildCoffins()[p]

		if v12 then
			shoveLid(v12)
		end
	end,
	MenaceAwakened = function(_)
		local v12 = v7

		if not v12 then
			return
		end

		v7 = nil
		v12:Destroy()
	end,
	MobSpawned = function(_, p, p2)
		local v12

		if p2 then
			v12 = buildCoffins()[p2]
		end

		if not v12 then
			reflectSkeletonVisibility(p)
			return
		end

		if v12.statue then
			v12.statue.Parent = folder
		end

		wakeBurst(v12)
	end
}

function RescueHasan.OnComplete(_, p)
	if p then
		returnHasanHome()
	end
end

return RescueHasan