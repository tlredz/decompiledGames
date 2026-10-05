local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
local CustomCollisions = require(ReplicatedStorage.CustomCollisions)
local Maid = require(ReplicatedStorage.Util.Maid)
local Sound = require(ReplicatedStorage.Util.Sound)
require(ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Util = require(ReplicatedStorage.Util)
local frozen = table.freeze({
	ISLAND = "Jungle",
	BUSHEL_COUNT = 30,
	BUSHELS_PER_HIT_MIN = 2,
	BUSHELS_PER_HIT_MAX = 3,
	BUSHEL_BANANAS_MIN = 4,
	BUSHEL_BANANAS_MAX = 6,
	BUSHEL_STEM_SIZE = createVector(0.4, 0.4, 0.4),
	BUSHEL_RADIUS = 0.62,
	BUSHEL_DROP = 0.7,
	BUSHEL_TILT = 0.4886921905584123,
	BUSHEL_TILT_JITTER = 0.12217304763960307,
	BUSHEL_ANGLE_JITTER = 0.3,
	BUSHEL_LEAN = 0.15707963267948966,
	BUSHEL_HANG_RADIUS = 4,
	BUSHEL_HANG_RATIO = 0.18,
	BUSHEL_HANG_DEPTH = 4,
	BUSHEL_PLACEMENT_ATTEMPTS = 8,
	BUSHEL_PLACEMENT_PADDING = 4,
	BUSHEL_SURFACE_OFFSET = 0.45,
	BUSHEL_SWAY_RESPONSE = 14,
	BUSHEL_SWAY_GAIN = 0.0016,
	BUSHEL_SWAY_MAX = 0.55,
	BUSHEL_SWAY_IDLE = 0.5,
	BUSHEL_BURST_OFFSET = 0.35,
	BUSHEL_BURST_INHERIT = 0.25,
	BUSHEL_BURST_SPEED = 3.5,
	BUSHEL_BURST_RISE = 1.5,
	BUSHEL_BURST_SPIN = 4,
	BANANA_MESH_ID = "rbxassetid://119574562",
	BANANA_TEXTURE_ID = "rbxassetid://64374853",
	BANANA_MESH_SCALE = createVector(3, 3.01, 3),
	BANANA_SIZE = createVector(1.2, 1.55, 1.2),
	BANANA_PHYSICS = PhysicalProperties.new(2.4, 1.6, 0, 10, 100),
	BANANA_COLLISION_GROUP = "Rocks",
	BANANA_SQUASH = createVector(1.16, 0.8, 1.16),
	BANANA_SETTLE_DURATION = 0.24,
	DROP_SPEED = 6,
	DROP_SPREAD = 0.9,
	DROP_SPIN = 2.4,
	FALL_STAGGER_MIN = 0.006,
	FALL_STAGGER_MAX = 0.03,
	HIT_STAGGER_MAX = 0.09,
	FALL_LIFETIME = 8,
	FALL_KILL_DEPTH = 40,
	LAND_ARM_SPEED = 30,
	LAND_SPEED = 18,
	LAND_DRAG = 5.5,
	REST_SPEED = 1.5,
	REST_SPIN = 1.5,
	REST_TIME = 0.3,
	IMPACT_INTERVAL = 0.13,
	IMPACT_VOLUME = 0.95,
	IMPACT_SOUNDS = table.freeze({
		"JungleBonusMoments.BF_Jungle_Banana_Fall_From_Tree_Thud_01",
		"JungleBonusMoments.BF_Jungle_Banana_Fall_From_Tree_Thud_02",
		"JungleBonusMoments.BF_Jungle_Banana_Fall_From_Tree_Thud_03"
	}),
	TREE_SHAKE_SOUNDS = table.freeze({
		"JungleBonusMoments.BF_Jungle_Tree_Shake_01",
		"JungleBonusMoments.BF_Jungle_Tree_Shake_02",
		"JungleBonusMoments.BF_Jungle_Tree_Shake_03",
		"JungleBonusMoments.BF_Jungle_Tree_Shake_04",
		"JungleBonusMoments.BF_Jungle_Tree_Shake_05",
		"JungleBonusMoments.BF_Jungle_Tree_Shake_06"
	}),
	NOTICE_VOX_SOUNDS = table.freeze({
		"JungleBonusMoments.BF_Jungle_Monkey_Vox_Indicator_01",
		"JungleBonusMoments.BF_Jungle_Monkey_Vox_Indicator_02",
		"JungleBonusMoments.BF_Jungle_Monkey_Vox_Indicator_03",
		"JungleBonusMoments.BF_Jungle_Monkey_Vox_Indicator_04",
		"JungleBonusMoments.BF_Jungle_Monkey_Vox_Indicator_05"
	}),
	SNAP_WHIP_SOUND = "Swing.MeleeSwingLoud",
	SNAP_WHIP_SPEED = 0.72,
	SNAP_WHIP_VOLUME = 0.7,
	SNAP_ROTATION_IMPULSE = createVector(0.8, -2.2, 1.4),
	SNAP_FIELD_OF_VIEW = 37,
	SNAP_FIELD_OF_VIEW_HOLD = 0.16,
	CAMERA_BLEND_TIME = 0.26,
	CAMERA_FADE_TIME = 0.4,
	CAMERA_MAX_HOLD_TIME = 8,
	SHOT_DRIFT_FREQUENCY = 0.75,
	BOSS_HEAD_FALLBACK_HEIGHT = 4.5,
	TREE_SHOT_DURATION = 1.15,
	TREE_SHOT_MIN_HEIGHT = 24,
	TREE_SHOT_FOCUS_RATIO = 0.5,
	TREE_SHOT_CAMERA_RATIO = 0.3,
	TREE_SHOT_DISTANCE_RATIO = 0.72,
	TREE_SHOT_DISTANCE_MIN = 34,
	TREE_SHOT_DISTANCE_MAX = 120,
	TREE_SHOT_FIELD_OF_VIEW = 58,
	TREE_SHOT_CRANE = 6,
	TREE_SHOT_CRANE_FOCUS = 14,
	NOTICE_DISTANCE = 10,
	NOTICE_HEIGHT = -0.4,
	NOTICE_CREEP = 1.8,
	NOTICE_CREEP_RISE = 0.5,
	NOTICE_BISECTOR_MIN = 0.45,
	NOTICE_FIELD_OF_VIEW = 42,
	PILE_CUT_DELAY = 1.05,
	PILE_FRAME_SCALE = 1.2,
	PILE_FRAME_PAD = 14,
	PILE_DISTANCE_MIN = 24,
	PILE_DISTANCE_MAX = 46,
	PILE_CAMERA_RATIO = 0.4,
	PILE_FOCUS_HEIGHT = 3.5,
	PILE_PUSH_RATIO = 0.2,
	PILE_PUSH_DROP = 3,
	PILE_FIELD_OF_VIEW = 55,
	RAGE_DISTANCE = 19,
	RAGE_HEIGHT = 3,
	RAGE_FOCUS_HEIGHT = 3.5,
	RAGE_PULL = 4.5,
	RAGE_RISE = 1.6,
	RAGE_FIELD_OF_VIEW = 50
})
local localPlayer = Players.LocalPlayer
local v = CustomCollisions.new(frozen.BANANA_COLLISION_GROUP)
local v2 = {
	flatten = function(vector2: Vector3)
		return vector2 * createVector(1, 0, 1)
	end
}

function v2.directionOr(vector2: Vector3, vector3: Vector3)
	local flattened = v2.flatten(vector2)

	if flattened.Magnitude > 0.05 then
		return flattened.Unit
	end

	return vector3
end

function v2.playRandom(p, list, vector2: Vector3, p2: number?)
	Sound:Play(list[p.rng:NextInteger(1, #list)], vector2, nil, p.rng:NextNumber(0.92, 1.08), p2)
end

function v2:closeCamera(p2, p3: number?)
	if p2 and self.camera ~= p2 then
		return
	end

	local camera = self.camera
	self.camera = nil

	if camera then
		camera:FadeOut(p3 or frozen.CAMERA_FADE_TIME)
	end
end

function v2:stopFallLoop()
	local fallConnection = self.fallConnection
	self.fallConnection = nil

	if fallConnection then
		fallConnection:Disconnect()
	end
end

function v2:stopSwayLoop()
	local swayConnection = self.swayConnection
	self.swayConnection = nil
	self.swayResidual = false

	if swayConnection then
		swayConnection:Disconnect()
	end
end

function v2:clearDressing()
	v2.stopFallLoop(self)
	v2.stopSwayLoop(self)
	local fxFolder = self.fxFolder
	self.fxFolder = nil
	self.pileCenter = nil
	self.pileSpread = 0
	self.canopyHeight = 0
	self.treeAxis = createVector(0, 0, 0)
	table.clear(self.leaves)
	table.clear(self.leafPoses)
	table.clear(self.hanging)
	table.clear(self.piles)
	table.clear(self.falling)

	if fxFolder then
		fxFolder:Destroy()
	end
end

function v2:resetState()
	v2.closeCamera(self, nil, 0)
	v2.clearDressing(self)
	self.tree = nil
	self.boss = nil
	self.available = false
	self.finishing = false
end

function v2.getState(maid)
	local _bananaTreeState = maid.MiscData._bananaTreeState

	if _bananaTreeState then
		return _bananaTreeState
	end

	local bananaTreeState = {
		maid = Maid.new(),
		tree = nil,
		boss = nil,
		fxFolder = nil,
		leaves = {},
		leafPoses = {},
		treeAxis = createVector(0, 0, 0),
		hanging = {},
		piles = {},
		pileCenter = nil,
		pileSpread = 0,
		canopyHeight = 0,
		falling = {},
		fallConnection = nil,
		swayConnection = nil,
		swayResidual = false,
		lastImpact = 0,
		camera = nil,
		available = false,
		finishing = false,
		rng = Random.new(localPlayer.UserId)
	}
	maid.MiscData._bananaTreeState = bananaTreeState
	maid:GiveTask(bananaTreeState.maid)
	bananaTreeState.maid:GiveTask(localPlayer:GetAttributeChangedSignal("CurrentLocation"):Connect(function()
		if localPlayer:GetAttribute("CurrentLocation") ~= frozen.ISLAND then
			v2.resetState(bananaTreeState)
		end
	end))
	bananaTreeState.maid:GiveTask(function()
		v2.resetState(bananaTreeState)
	end)
	return bananaTreeState
end

function v2.createBanana()
	local part = Instance.new("Part")
	part.Name = "BananaTreeBanana"
	part.Size = frozen.BANANA_SIZE
	part.Color = Color3.new(1, 1, 1)
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CustomPhysicalProperties = frozen.BANANA_PHYSICS
	pcall(function()
		v:ApplyCollision(part)
	end)
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.FileMesh
	specialMesh.MeshId = frozen.BANANA_MESH_ID
	specialMesh.TextureId = frozen.BANANA_TEXTURE_ID
	specialMesh.Scale = frozen.BANANA_MESH_SCALE
	specialMesh.Parent = part
	return part, specialMesh
end

function v2.getBananaOffset(object, p: number, p2: number)
	local BUSHEL_ANGLE_JITTER = frozen.BUSHEL_ANGLE_JITTER
	local v3 = (p - 1) / p2 * 3.141592653589793 * 2 + object:NextNumber(-BUSHEL_ANGLE_JITTER, BUSHEL_ANGLE_JITTER)
	local v4 = frozen.BUSHEL_TILT + object:NextNumber(-frozen.BUSHEL_TILT_JITTER, frozen.BUSHEL_TILT_JITTER)
	return CFrame.Angles(0, v3, 0) * CFrame.new(
		frozen.BUSHEL_RADIUS * object:NextNumber(0.85, 1.15),
		-frozen.BUSHEL_DROP * object:NextNumber(0.9, 1.1),
		0
	) * CFrame.Angles(0, 0, v4)
end

function v2.createBushel(p, cFrame: CFrame, parent)
	local rng = p.rng
	local model = Instance.new("Model")
	model.Name = "BananaTreeBushel"
	local part = Instance.new("Part")
	part.Name = "Stem"
	part.Size = frozen.BUSHEL_STEM_SIZE
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CustomPhysicalProperties = frozen.BANANA_PHYSICS
	part.CFrame = cFrame
	part.Parent = model
	local integer = rng:NextInteger(frozen.BUSHEL_BANANAS_MIN, frozen.BUSHEL_BANANAS_MAX)
	local bananas = {}
	local meshes = {}

	for i = 1, integer do
		local banana, v4 = v2.createBanana()
		banana.CFrame = cFrame * v2.getBananaOffset(rng, i, integer)
		banana.Parent = model
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part
		weldConstraint.Part1 = banana
		weldConstraint.Parent = part
		table.insert(bananas, banana)
		table.insert(meshes, v4)
	end

	model.PrimaryPart = part
	model.Parent = parent
	return {
		model = model,
		root = part,
		bananas = bananas,
		meshes = meshes
	}
end

function v2.getBushelCFrame(p, p2, p3)
	local rng = p.rng
	local v3 = math.min(
		frozen.BUSHEL_HANG_RADIUS,
		p2.Size.X * frozen.BUSHEL_HANG_RATIO,
		p2.Size.Z * frozen.BUSHEL_HANG_RATIO
	)
	local number = rng:NextNumber(0, 6.283185307179586)
	local v4 = v3 * math.sqrt((rng:NextNumber()))
	local v5 = p2.Position + Vector3.new(math.cos(number) * v4, 0, math.sin(number) * v4)
	local treeAxis = p.treeAxis

	if (v2.flatten(v5) - treeAxis).Magnitude > (v2.flatten(p2.Position) - treeAxis).Magnitude then
		return nil
	end

	local v6 = p2.Size.Magnitude + frozen.BUSHEL_PLACEMENT_PADDING
	p3.FilterDescendantsInstances = { p2 }
	local raycastResult = workspace:Raycast(v5 - createVector(0, 1, 0) * v6, createVector(0, 1, 0) * v6 * 2, p3)

	if not raycastResult then
		return nil
	end

	local BUSHEL_LEAN = frozen.BUSHEL_LEAN
	local v7 = raycastResult.Position + raycastResult.Normal * frozen.BUSHEL_SURFACE_OFFSET - createVector(0, 1, 0) * rng:NextNumber(
		0,
		frozen.BUSHEL_HANG_DEPTH
	)
	return CFrame.new(v7) * CFrame.Angles(0, rng:NextNumber(-3.141592653589793, 3.141592653589793), 0) * CFrame.Angles(
		rng:NextNumber(-BUSHEL_LEAN, BUSHEL_LEAN),
		0,
		rng:NextNumber(-BUSHEL_LEAN, BUSHEL_LEAN)
	)
end

function v2.hangBushels(data, p)
	local leaves = data.leaves
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.IgnoreWater = true
	raycastParams.RespectCanCollide = false
	local count = 0

	while #data.hanging < frozen.BUSHEL_COUNT and count < frozen.BUSHEL_COUNT * frozen.BUSHEL_PLACEMENT_ATTEMPTS do
		count += 1
		local integer = data.rng:NextInteger(1, #leaves)
		local leave = leaves[integer]
		local pile = data.piles[integer]
		local v3

		if pile then
			v3 = v2.getBushelCFrame(data, leave, raycastParams)
		end

		if not (v3 and pile) then
			continue
		end

		pile.count += 1
		table.insert(data.hanging, {
			bushel = v2.createBushel(data, v3, p),
			pile = pile,
			leaf = leave,
			attachPoint = leave.CFrame:PointToObjectSpace(v3.Position),
			restRotation = v3.Rotation,
			lastPosition = v3.Position,
			sway = createVector(0, 0, 0)
		})
	end
end

function v2:measurePiles()
	local v3 = createVector(0, 0, 0)
	local total = 0
	local count = 0

	for k, pile in self.piles do
		local leave = self.leaves[k]

		if not (pile.count > 0 and leave) then
			continue
		end

		v3 += pile.origin
		total += leave.Position.Y - pile.origin.Y
		count += 1
	end

	if count == 0 then
		self.pileCenter = nil
		self.pileSpread = 0
		self.canopyHeight = 0
	else
		local pileCenter = v3 / count
		local total2 = 0

		for _, pile in self.piles do
			if pile.count > 0 then
				total2 += v2.flatten(pile.origin - pileCenter).Magnitude
			end
		end

		self.pileCenter = pileCenter
		self.pileSpread = total2 / count
		self.canopyHeight = total / count
	end
end

function v2.getSwayCFrame(vector2: Vector3)
	local v3 = vector2 * -frozen.BUSHEL_SWAY_GAIN
	local v4 = math.min(v3.Magnitude, frozen.BUSHEL_SWAY_MAX)

	if v4 < 0.001 then
		return CFrame.identity
	end

	return CFrame.fromAxisAngle(-(createVector(0, 1, 0)):Cross(v3.Unit), (math.atan(v4)))
end

function v2.leavesMoved(p)
	local v3 = false

	for k, leave in p.leaves do
		local cFrame = leave.CFrame

		if p.leafPoses[k] == cFrame then
			continue
		end

		p.leafPoses[k] = cFrame
		v3 = true
	end

	return v3
end

function v2:stepSway(p: number)
	if #self.hanging == 0 then
		v2.stopSwayLoop(self)
		return
	end

	if not (v2.leavesMoved(self) or self.swayResidual) then
		return
	end

	local v3 = math.clamp(p * frozen.BUSHEL_SWAY_RESPONSE, 0, 1)
	local swayResidual = false

	for _, v5 in self.hanging do
		local model = v5.bushel.model

		if not (v5.leaf.Parent and model.Parent) then
			continue
		end

		local pointToWorldSpace = v5.leaf.CFrame:PointToWorldSpace(v5.attachPoint)
		local v6 = v2.flatten(pointToWorldSpace - v5.lastPosition) / math.max(p, 0.0001)
		v5.lastPosition = pointToWorldSpace
		v5.sway = v5.sway:Lerp(v6, v3)

		if v5.sway.Magnitude < frozen.BUSHEL_SWAY_IDLE then
			v5.sway = createVector(0, 0, 0)
		else
			swayResidual = true
		end

		model:PivotTo(CFrame.new(pointToWorldSpace) * v2.getSwayCFrame(v5.sway) * v5.restRotation)
	end

	self.swayResidual = swayResidual
end

function v2:startSwayLoop()
	if self.swayConnection or #self.hanging == 0 then
		return
	end

	self.swayConnection = RunService.Heartbeat:Connect(function(dt: number)
		v2.stepSway(self, dt)
	end)
end

function v2:dressTree(tree, boss, list, items)
	v2.clearDressing(self)
	self.tree = tree
	self.boss = boss
	self.available = true
	self.finishing = false

	if #list == 0 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = `BananaTreeFX_{localPlayer.UserId}`
	folder.Parent = workspace
	self.fxFolder = folder
	self.treeAxis = v2.flatten(tree:GetBoundingBox().Position)

	for k, item in items do
		self.leaves[k] = list[k]
		self.piles[k] = {
			origin = item,
			count = 0
		}
	end

	v2.hangBushels(self, folder)
	v2.measurePiles(self)
	v2.startSwayLoop(self)
end

function v2:playImpact(vector2: Vector3)
	local now = os.clock()

	if now - self.lastImpact < frozen.IMPACT_INTERVAL then
		return
	end

	self.lastImpact = now
	v2.playRandom(self, frozen.IMPACT_SOUNDS, vector2, frozen.IMPACT_VOLUME)
end

function v2.playLanding(p, p2)
	local tweenInfo = TweenInfo.new(frozen.BANANA_SETTLE_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	for _, mesh in p2.bushel.meshes do
		mesh.Scale = frozen.BANANA_MESH_SCALE * frozen.BANANA_SQUASH
		TweenService:Create(mesh, tweenInfo, {
			Scale = frozen.BANANA_MESH_SCALE
		}):Play()
	end

	v2.playImpact(p, p2.bushel.root.Position)
end

function v2.breakBushel(p, p2)
	local bushel = p2.bushel
	local position = bushel.root.Position
	local v3 = bushel.root.AssemblyLinearVelocity * frozen.BUSHEL_BURST_INHERIT
	local BUSHEL_BURST_SPIN = frozen.BUSHEL_BURST_SPIN
	bushel.root:Destroy()
	local bananas = {}

	for _, banana in bushel.bananas do
		if not banana.Parent then
			continue
		end

		local directionOr = v2.directionOr(banana.Position - position, createVector(0, 0, 1))
		banana.CFrame += directionOr * frozen.BUSHEL_BURST_OFFSET
		banana.AssemblyLinearVelocity = v3 + directionOr * frozen.BUSHEL_BURST_SPEED + createVector(0, 1, 0) * frozen.BUSHEL_BURST_RISE
		banana.AssemblyAngularVelocity = Vector3.new(
			p.rng:NextNumber(-BUSHEL_BURST_SPIN, BUSHEL_BURST_SPIN),
			p.rng:NextNumber(-BUSHEL_BURST_SPIN, BUSHEL_BURST_SPIN),
			p.rng:NextNumber(-BUSHEL_BURST_SPIN, BUSHEL_BURST_SPIN)
		)
		table.insert(bananas, banana)
	end

	p2.bodies = bananas
end

function v2.anchorBushel(p)
	for _, banana in p.bushel.bananas do
		if not banana.Parent then
			continue
		end

		banana.AssemblyLinearVelocity = createVector(0, 0, 0)
		banana.AssemblyAngularVelocity = createVector(0, 0, 0)
		banana.Anchored = true
	end

	local root = p.bushel.root

	if root.Parent then
		root.AssemblyLinearVelocity = createVector(0, 0, 0)
		root.AssemblyAngularVelocity = createVector(0, 0, 0)
		root.Anchored = true
	end
end

function v2.trackBodies(p)
	local bodies = p.bodies
	local v3 = 0
	local v4 = 0

	for i = #bodies, 1, -1 do
		local body = bodies[i]

		if body.Parent then
			if body.Position.Y < p.killY then
				table.remove(bodies, i)
				body:Destroy()
			else
				v3 = math.max(v3, body.AssemblyLinearVelocity.Magnitude)
				v4 = math.max(v4, body.AssemblyAngularVelocity.Magnitude)
			end
		else
			table.remove(bodies, i)
		end
	end

	return v3, v4
end

function v2.dampBodies(p, p2: number)
	for _, body in p.bodies do
		body.AssemblyLinearVelocity *= p2
		body.AssemblyAngularVelocity *= p2
	end
end

function v2.stepFalling(p, p2: number)
	local falling = p.falling

	for i = #falling, 1, -1 do
		local v3 = falling[i]
		local trackBodies, v4 = v2.trackBodies(v3)

		if #v3.bodies == 0 then
			table.remove(falling, i)
			v3.bushel.model:Destroy()
		else
			v3.elapsed += p2

			if frozen.LAND_ARM_SPEED < trackBodies then
				v3.armed = true
			elseif v3.armed and not v3.landed and trackBodies < frozen.LAND_SPEED then
				v3.landed = true
				v2.playLanding(p, v3)
				v2.breakBushel(p, v3)
			end

			if v3.landed then
				v2.dampBodies(v3, (math.exp(-frozen.LAND_DRAG * p2)))
			end

			if trackBodies < frozen.REST_SPEED and v4 < frozen.REST_SPIN then
				v3.resting += p2
			else
				v3.resting = 0
			end

			if v3.resting >= frozen.REST_TIME or v3.elapsed >= frozen.FALL_LIFETIME then
				table.remove(falling, i)

				if not v3.landed then
					v2.breakBushel(p, v3)
				end

				v2.anchorBushel(v3)
			end
		end
	end

	if #falling == 0 then
		v2.stopFallLoop(p)
	end
end

function v2:startFallLoop()
	if self.fallConnection then
		return
	end

	self.fallConnection = RunService.Heartbeat:Connect(function(dt: number)
		v2.stepFalling(self, dt)
	end)
end

function v2.dropBushel(p, p2)
	local bushel = p2.bushel
	local root = bushel.root

	if not root.Parent then
		return
	end

	for _, banana in bushel.bananas do
		banana.CanCollide = true
		banana.Anchored = false
	end

	local DROP_SPREAD = frozen.DROP_SPREAD
	local DROP_SPIN = frozen.DROP_SPIN
	root.Anchored = false
	root.AssemblyLinearVelocity = Vector3.new(
		p.rng:NextNumber(-DROP_SPREAD, DROP_SPREAD),
		-frozen.DROP_SPEED,
		p.rng:NextNumber(-DROP_SPREAD, DROP_SPREAD)
	)
	root.AssemblyAngularVelocity = Vector3.new(
		p.rng:NextNumber(-DROP_SPIN, DROP_SPIN),
		p.rng:NextNumber(-DROP_SPIN, DROP_SPIN),
		p.rng:NextNumber(-DROP_SPIN, DROP_SPIN)
	)
	table.insert(p.falling, {
		bushel = bushel,
		bodies = { root },
		killY = p2.pile.origin.Y - frozen.FALL_KILL_DEPTH,
		elapsed = 0,
		resting = 0,
		armed = false,
		landed = false
	})
	v2.startFallLoop(p)
end

function v2.releaseBushels(p, p2: number, p3: number)
	local total = 0

	for _ = 1, p2 do
		local v3 = table.remove(p.hanging)

		if not (v3 and v3.bushel.root.Parent) then
			continue
		end

		if total <= 0 then
			v2.dropBushel(p, v3)
		else
			task.delay(total, v2.dropBushel, p, v3)
		end

		total += p.rng:NextNumber(frozen.FALL_STAGGER_MIN, p3)
	end
end

function v2.getHeadPosition(instance, cframe: CFrame)
	local head = instance:FindFirstChild("Head")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local v3

	if head and head:IsA("BasePart") and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		v3 = head.Position.Y - humanoidRootPart.Position.Y
	else
		v3 = frozen.BOSS_HEAD_FALLBACK_HEIGHT
	end

	return cframe.Position + createVector(0, 1, 0) * v3
end

function v2:openTreeShot(cframe: CFrame)
	local currentCamera = workspace.CurrentCamera
	local pileCenter = self.pileCenter

	if not (currentCamera and pileCenter) then
		return nil
	end

	local directionOr = v2.directionOr(pileCenter - cframe.Position, cframe.LookVector)
	local v3 = math.max(self.canopyHeight, frozen.TREE_SHOT_MIN_HEIGHT)
	local v4 = math.clamp(
		v3 * frozen.TREE_SHOT_DISTANCE_RATIO + self.pileSpread,
		frozen.TREE_SHOT_DISTANCE_MIN,
		frozen.TREE_SHOT_DISTANCE_MAX
	)
	local v5 = pileCenter + createVector(0, 1, 0) * v3 * frozen.TREE_SHOT_FOCUS_RATIO
	local v6 = pileCenter - directionOr * v4 + createVector(0, 1, 0) * v3 * frozen.TREE_SHOT_CAMERA_RATIO
	local camera = CameraController.new(currentCamera, 1, frozen.CAMERA_BLEND_TIME)
	camera:SetCFrame(CFrame.lookAt(v6, v5))
	camera.Animations:AnimateFieldOfView(frozen.TREE_SHOT_FIELD_OF_VIEW, 1, 5)
	camera.Animations:AnimateTo(
		CFrame.lookAt(
			v6 - createVector(0, 1, 0) * frozen.TREE_SHOT_CRANE,
			v5 - createVector(0, 1, 0) * frozen.TREE_SHOT_CRANE_FOCUS
		),
		1,
		frozen.SHOT_DRIFT_FREQUENCY
	)
	self.camera = camera
	task.delay(frozen.CAMERA_MAX_HOLD_TIME, function()
		v2.closeCamera(self, camera)
	end)
	return camera
end

function v2.cutToNotice(p, object, p2, cframe: CFrame)
	local pileCenter = p.pileCenter

	if p.camera ~= object or not pileCenter then
		return
	end

	local headPosition = v2.getHeadPosition(p2, cframe)
	local vector2 = v2.directionOr(pileCenter - cframe.Position, cframe.LookVector)
	local flattened = v2.flatten(v2.directionOr(cframe.LookVector, vector2) + vector2)
	local unit

	if flattened.Magnitude > frozen.NOTICE_BISECTOR_MIN then
		unit = flattened.Unit
	else
		unit = vector2:Cross(createVector(0, 1, 0)).Unit
	end

	local v3 = headPosition + unit * frozen.NOTICE_DISTANCE + createVector(0, 1, 0) * frozen.NOTICE_HEIGHT
	object:SetCFrame(CFrame.lookAt(v3, headPosition))
	object.Animations:AnimateFieldOfView(frozen.NOTICE_FIELD_OF_VIEW, 1, 5)
	object.Animations:AnimateTo(
		CFrame.lookAt(v3 - unit * frozen.NOTICE_CREEP + createVector(0, 1, 0) * frozen.NOTICE_CREEP_RISE, headPosition),
		1,
		frozen.SHOT_DRIFT_FREQUENCY
	)
end

function v2.cutToPiles(data, object, cframe: CFrame)
	local pileCenter = data.pileCenter

	if data.camera ~= object or not pileCenter then
		return
	end

	local directionOr = v2.directionOr(pileCenter - cframe.Position, cframe.LookVector)
	local v3 = math.clamp(
		data.pileSpread * frozen.PILE_FRAME_SCALE + frozen.PILE_FRAME_PAD,
		frozen.PILE_DISTANCE_MIN,
		frozen.PILE_DISTANCE_MAX
	)
	local v4 = pileCenter + createVector(0, 1, 0) * frozen.PILE_FOCUS_HEIGHT
	local v5 = pileCenter - directionOr * v3 + createVector(0, 1, 0) * v3 * frozen.PILE_CAMERA_RATIO
	object:SetCFrame(CFrame.lookAt(v5, v4))
	object.Animations:AnimateFieldOfView(frozen.PILE_FIELD_OF_VIEW, 1, 5)
	object.Animations:AnimateTo(
		CFrame.lookAt(
			v5 + directionOr * (v3 * frozen.PILE_PUSH_RATIO) - createVector(0, 1, 0) * frozen.PILE_PUSH_DROP,
			v4
		),
		1,
		frozen.SHOT_DRIFT_FREQUENCY
	)
end

function v2.cutToRage(p, cframe: CFrame)
	local camera = p.camera

	if not camera then
		return
	end

	local character = localPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local v3

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		v3 = v2.directionOr(humanoidRootPart.Position - cframe.Position, cframe.LookVector)
	else
		v3 = v2.directionOr(cframe.LookVector, createVector(0, 0, 1))
	end

	local v4 = cframe.Position + createVector(0, 1, 0) * frozen.RAGE_FOCUS_HEIGHT
	local v5 = v4 + v3 * frozen.RAGE_DISTANCE + createVector(0, 1, 0) * frozen.RAGE_HEIGHT
	camera:SetCFrame(CFrame.lookAt(v5, v4))
	camera.Animations:AnimateFieldOfView(frozen.RAGE_FIELD_OF_VIEW, 1, 5)
	camera.Animations:AnimateTo(
		CFrame.lookAt(v5 + v3 * frozen.RAGE_PULL + createVector(0, 1, 0) * frozen.RAGE_RISE, v4),
		1,
		frozen.SHOT_DRIFT_FREQUENCY
	)
end

function v2.playSnap(p)
	local boss = p.boss
	local head

	if boss then
		head = boss:FindFirstChild("Head")
	end

	if head and head:IsA("BasePart") then
		Sound:Play(frozen.SNAP_WHIP_SOUND, head.Position, nil, frozen.SNAP_WHIP_SPEED, frozen.SNAP_WHIP_VOLUME)
		v2.playRandom(p, frozen.NOTICE_VOX_SOUNDS, head.Position)
	end

	local camera = p.camera

	if not camera then
		return
	end

	camera.Animations:RotationImpulse(frozen.SNAP_ROTATION_IMPULSE)
	camera.Animations:AnimateFieldOfView(frozen.SNAP_FIELD_OF_VIEW, 0.6, 13)
	task.delay(frozen.SNAP_FIELD_OF_VIEW_HOLD, function()
		if p.camera == camera then
			camera.Animations:AnimateFieldOfView(frozen.NOTICE_FIELD_OF_VIEW, 1, 4)
		end
	end)
	pcall(function()
		Util.CameraShaker:ShakeOnce(6, 9, 0.02, 0.55, createVector(1, 1, 1), createVector(1, 1, 1))
	end)
end

function v2.setAvailability(p, p2, p3, p4, p5)
	local state = v2.getState(p)

	if state.finishing then
		return
	end

	if p2 and p3 and p4 and p5 and p2.Parent and p3.Parent then
		v2.dressTree(state, p2, p3, p4, p5)
		return
	end

	state.available = false
	state.tree = nil
	state.boss = nil
	v2.clearDressing(state)
end

function v2.handleHit(p)
	local state = v2.getState(p)

	if state.available and not state.finishing then
		v2.releaseBushels(
			state,
			state.rng:NextInteger(frozen.BUSHELS_PER_HIT_MIN, frozen.BUSHELS_PER_HIT_MAX),
			frozen.HIT_STAGGER_MAX
		)
	end
end

function v2.playFinale(p, instance, p2, cframe: CFrame, p3, p4)
	local state = v2.getState(p)

	if state.finishing or not (instance.Parent and p2.Parent) then
		return
	end

	if state.fxFolder == nil then
		v2.dressTree(state, instance, p2, p3, p4)
	end

	state.finishing = true
	state.available = false
	v2.playRandom(state, frozen.TREE_SHAKE_SOUNDS, state.pileCenter or instance:GetPivot().Position)
	v2.releaseBushels(state, #state.hanging, frozen.FALL_STAGGER_MAX)
	local treeShot = v2.openTreeShot(state, cframe)

	if not treeShot then
		return
	end

	task.delay(frozen.TREE_SHOT_DURATION, function()
		v2.cutToNotice(state, treeShot, p2, cframe)
	end)
	task.delay(frozen.TREE_SHOT_DURATION + frozen.PILE_CUT_DELAY, function()
		v2.cutToPiles(state, treeShot, cframe)
	end)
end

return {
	Repeatable = true,
	OnLoad = function(object)
		v2.getState(object)
		object:FireServer("Initialize")
	end,
	RemoteEvents = {
		Reset = function(p)
			v2.resetState(v2.getState(p))
		end,
		Availability = function(p, p2, p3, p4, p5)
			v2.setAvailability(p, p2, p3, p4, p5)
		end,
		Hit = function(p)
			v2.handleHit(p)
		end,
		Finale = function(p, p2, p3, cframe: CFrame, p4, p5)
			v2.playFinale(p, p2, p3, cframe, p4, p5)
		end,
		Snap = function(p)
			v2.playSnap(v2.getState(p))
		end,
		Turn = function(p, cframe: CFrame)
			v2.cutToRage(v2.getState(p), cframe)
		end,
		CameraHandoff = function(p)
			v2.closeCamera(v2.getState(p))
		end
	}
}