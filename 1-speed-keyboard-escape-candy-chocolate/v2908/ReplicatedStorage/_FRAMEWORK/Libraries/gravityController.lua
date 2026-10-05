local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Animation = require(script.Animation)
local Basis = require(script.Basis)
local Camera = require(script.Camera)
local Climb = require(script.Climb)
local Collider = require(script.Collider)
local Config = require(script.Config)
local Ground = require(script.Ground)
local Motion = require(script.Motion)
local Sources = require(script.Sources)
local StateTracker = require(script.StateTracker)
require(script.Types)
local GravityController = {}
local merged = Config.default()
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local vector2 = createVector(0, 1, 0)
local v6 = createVector(0, 1, 0)
local vector3 = createVector(0, 1, 0)
local v7 = 0
local v8 = createVector(-0, -0, -1)
local v9 = nil
local v10 = false
local part = nil
local v11 = false
local v12 = 0
local position = createVector(0, 0, 0)
local v13 = nil
local vector4 = createVector(0, 1, 0)
local v14 = nil
local v15 = {
	acceleration = 0,
	maxSpeed = 0
}
local v16 = createVector(0, 0, 0)
local v17 = nil
local v18 = 0
local v19 = 0
local v20 = {}
local flag = false
local v21 = nil
local v22 = nil
local v23 = {}
local controls = nil
local v24 = nil
local v25 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function checkCharacterReady(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator

	if humanoid ~= nil then
		animator = humanoid:FindFirstChildOfClass("Animator")
	end

	return humanoidRootPart ~= nil and humanoid ~= nil and animator ~= nil, humanoidRootPart, humanoid, animator
end

local function resolveControls()
	if controls ~= nil then
		return controls
	end

	local localPlayer = Players.LocalPlayer
	local playerScripts

	if localPlayer ~= nil then
		playerScripts = localPlayer:FindFirstChild("PlayerScripts")
	end

	local playerModule

	if playerScripts ~= nil then
		playerModule = playerScripts:FindFirstChild("PlayerModule")
	end

	if playerModule ~= nil and playerModule:IsA("ModuleScript") then
		local success, result = pcall(require, playerModule)

		if success then
			controls = result:GetControls()
		end
	end

	return controls
end

-- equivalent calls inferred from this helper; original call sites unknown
local function readMoveVector()
	local controls2 = resolveControls()

	if controls2 == nil then
		return createVector(0, 0, 0)
	end

	return (controls2:GetMoveVector())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isMotionSuspended()
	return next(v20) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isUnfollowed(instance)
	for _, ancestor in merged.unfollowedInstances do
		if instance:IsDescendantOf(ancestor) then
			return true
		end
	end

	return false
end

local function followStandingPart()
	local v26 = v3
	local v27 = part
	local cframe = v22

	if v26 ~= nil and v27 ~= nil and v27 == v21 and cframe ~= nil and (v27.Position - cframe.Position).Magnitude <= 50 then
		-- equivalent call inferred; original call site unknown
		if not isUnfollowed(v27) then
			v26.CFrame = v27.CFrame * cframe:ToObjectSpace(v26.CFrame)
		end
	end

	v21 = v27
	local v28

	if v27 ~= nil then
		v28 = v27.CFrame
	end

	v22 = v28
end

-- equivalent calls inferred from this helper; original call sites unknown
local function holdHumanoid()
	local v26 = v2

	if v26 ~= nil and v5 ~= nil then
		if not v26.PlatformStand then
			v26.PlatformStand = true
			flag = true
		end

		if v26.AutoRotate then
			v26.AutoRotate = false
		end
	end
end

local function syncCollisionGroup()
	local v26 = v5
	local v27 = v3

	if v26 ~= nil and v27 ~= nil then
		Collider.setCollisionGroup(v26, v27.CollisionGroup)
		Ground.setCollisionGroup(v27.CollisionGroup)
		Climb.setCollisionGroup(v27.CollisionGroup)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropFall()
	v13 = nil
	v14 = nil
end

local function refreshCollider()
	local v26 = v5
	local v27 = v3
	local v28 = v2

	if v26 ~= nil and v27 ~= nil and v28 ~= nil then
		Collider.refresh(v26, v27, v28, merged)
	end
end

local function createRig()
	local v26 = v
	local v27 = v3
	local v28 = v2
	local v29 = v4

	if v26 ~= nil and v27 ~= nil and v28 ~= nil and v29 ~= nil then
		v5 = Collider.create(v26, v27, v28, merged)
		Collider.setMotionEnabled(v5, next(v20) == nil)
		Ground.setCollisionGroup(v27.CollisionGroup)
		Climb.setCollisionGroup(v27.CollisionGroup)
		v8 = Basis.resolvePlanarDirection({ v27.CFrame.LookVector }, vector2)
		position = v27.Position
		dropFall() -- equivalent call inferred; original call site unknown
		vector4 = v6
		v11 = v27.AssemblyLinearVelocity:Dot(v6) > 0
		v10 = false
		part = nil
		v21 = nil
		v22 = nil
		flag = false
		holdHumanoid() -- equivalent call inferred; original call site unknown
		Camera.setBodyOwned(true)
		StateTracker.reset()
		Animation.bind(v26, v29, merged)
		v23 = {
			RunService.PostSimulation:Connect(followStandingPart),
			v28:GetPropertyChangedSignal("HipHeight"):Connect(refreshCollider),
			v27:GetPropertyChangedSignal("Size"):Connect(refreshCollider),
			v27:GetPropertyChangedSignal("CollisionGroup"):Connect(syncCollisionGroup),
			v28:GetPropertyChangedSignal("PlatformStand"):Connect(holdHumanoid),
			v28:GetPropertyChangedSignal("AutoRotate"):Connect(holdHumanoid),
			workspace:GetPropertyChangedSignal("Gravity"):Connect(dropFall)
		}
	end
end

local function destroyRig()
	local v26 = v5
	local v27 = v2

	for _, connection in v23 do
		connection:Disconnect()
	end

	v23 = {}

	if v26 ~= nil then
		Animation.unbind(merged)
		Collider.destroy(v26)
		v5 = nil
	end

	Camera.setBodyOwned(false)

	if v27 ~= nil and v27.Parent ~= nil then
		if flag then
			v27.PlatformStand = false
		end

		v27.AutoRotate = true
	end

	flag = false
	v10 = false
	part = nil
	v21 = nil
	v22 = nil
	v11 = false
	dropFall() -- equivalent call inferred; original call site unknown
	v17 = nil
	v18 = 0
end

local function isCameraRelative()
	if v24 == nil then
		local UserGameSettings = UserSettings():GetService("UserGameSettings")
		v24 = UserGameSettings
	end

	return v25 or v24.RotationType == Enum.RotationType.CameraRelative
end

local function resolveFall(sphere, metrics, flag2: boolean, flag3: boolean, dot: number)
	local acceleration = workspace.Gravity * (not v11 and 1 or merged.jumpGravityScale)

	if flag2 or flag3 then
		dropFall() -- equivalent call inferred; original call site unknown
		vector4 = v6
	elseif v13 == nil or vector4:Dot(v6) < 0.999 then
		local lookAhead = Ground.lookAhead(v, sphere.Position, v6, merged.travelProbeDistance, merged)
		local v27

		if lookAhead ~= nil then
			v27 = math.max(lookAhead - metrics.colliderRadius, 0)
		end

		local travelAcceleration, maxSpeed = Motion.travelAcceleration(v27 or 1e999, -dot, acceleration, merged)
		v13 = v27 == nil and {
			acceleration = acceleration,
			maxSpeed = merged.maxFallSpeed
		} or {
			acceleration = travelAcceleration,
			maxSpeed = maxSpeed
		}
		local v29

		if v27 ~= nil then
			v29 = GravityController.getFallDistance() - v27
		end

		v14 = v29
		vector4 = v6
	end

	v15.acceleration = acceleration
	v15.maxSpeed = merged.maxFallSpeed
	return v13 or v15
end

local function resolveFacingTarget(vector5: Vector3, vector6: Vector3)
	if v24 == nil then
		local UserGameSettings = UserSettings():GetService("UserGameSettings")
		v24 = UserGameSettings
	end

	if v25 or v24.RotationType == Enum.RotationType.CameraRelative then
		return vector6, true
	end

	if vector5.Magnitude > 0.05 then
		return vector5.Unit, false
	end

	return v8, false
end

local function publishState(flag2: boolean, p)
	local onStateChanged = merged.onStateChanged

	if flag2 and onStateChanged ~= nil then
		onStateChanged(StateTracker.getState(), StateTracker.getSpeed())
	end

	Animation.apply(StateTracker.getState(), StateTracker.getSpeed(), p.metrics.scale, merged)
end

local function resolveTruss(p, p2, unit: Vector3)
	local v26 = v17
	local v27

	if v26 == nil then
		v27 = unit
	else
		v27 = -v26
	end

	local metrics = p.metrics
	local v28 = nil

	if not (v27.Magnitude > 0.05) then
		return v28
	end

	if v26 == nil then
		local now = os.clock()

		if not (v19 <= now) then
			return v28
		end
	end

	local v29 = p.sphere.Position - v6 * metrics.colliderRadius * 0.9
	local v30 = v27.Unit * merged.climbReach * metrics.scale
	local v31 = Climb.find(v, p2.Position, v29, v30, v6, merged)
	local v32

	if v31 == nil then
		v32 = false
	else
		v32 = v26 ~= nil or unit:Dot(-v31) >= 0.5
	end

	local v33

	if v26 == nil or not (unit:Dot(v26) > 0.05) then
		v33 = false
	else
		v33 = Ground.probe(v, p.sphere.Position, v6, metrics.groundDistance, metrics.groundRingRadius, "ground", merged).grounded
	end

	if v32 and not v33 then
		return v31
	end

	return v28
end

local function driveClimb(p, p2, p3, truss: Vector3, unit: Vector3, p4: number)
	local now = os.clock()
	local v26 = unit:Dot(-truss) * p3.WalkSpeed * merged.climbSpeedRatio
	local v27 = createVector(0, 1, 0) * (workspace.Gravity * p4)
	v17 = truss
	v18 = v26
	v10 = false
	part = nil
	dropFall() -- equivalent call inferred; original call site unknown
	position = p2.Position

	if p3.Jump and v12 <= now then
		p2.AssemblyLinearVelocity = (truss + v6).Unit * Motion.jumpSpeed(p3, merged) + v27
		v17 = nil
		v19 = now + merged.climbRegrabCooldown
		v12 = now + merged.jumpCooldown
		v11 = true
	else
		p2.AssemblyLinearVelocity = v6 * v26 - truss * merged.stickSpeed + v27
		v11 = false
	end

	v8 = Basis.resolvePlanarDirection({ -truss, v8 }, vector2)
	Collider.setOrientation(p, Motion.orientation(p2.Position, v8, vector2))
	publishState(StateTracker.climb((math.abs(v26))), p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseTruss(p, p2)
	local v26 = v17

	if v26 ~= nil and v18 > 0 then
		local v27 = math.min(v18, Motion.jumpSpeed(p2, merged) * 0.5)
		p.AssemblyLinearVelocity = (v6 - v26) * v27
	end

	v17 = nil
	v18 = 0
end

local function findWall(vector5: Vector3, vector6: Vector3)
	local v26 = Ground.cast(v, vector5, vector6, "wall", merged)

	if v26 == nil or not (v26.Normal:Dot(v6) <= merged.minGroundDot) then
		return nil
	end

	return v26
end

local function absorbIntoWall(p, assemblyLinearVelocity: Vector3, p2: number)
	local vector5 = assemblyLinearVelocity - v6 * assemblyLinearVelocity:Dot(v6)
	local magnitude = vector5.Magnitude
	local colliderRadius = p.metrics.colliderRadius
	local v26

	if magnitude > 0.05 and p2 > 0 then
		local position2 = p.sphere.Position
		local v27 = vector5 / magnitude * (colliderRadius + magnitude * p2)
		v26 = Ground.cast(v, position2, v27, "wall", merged)

		if v26 == nil or not (v26.Normal:Dot(v6) <= merged.minGroundDot) then
			v26 = nil
		end
	end

	if v26 == nil then
		return assemblyLinearVelocity
	end

	local v27 = -vector5:Dot(v26.Normal)
	local v28 = math.max(v26.Distance - colliderRadius, 0) / p2

	if v28 < v27 then
		return assemblyLinearVelocity + v26.Normal * (v27 - v28)
	end

	return assemblyLinearVelocity
end

local function stepUp(p, instance, probe, flag2: boolean, vector5: Vector3, vector6: Vector3, p2: number)
	local metrics = p.metrics

	if vector5.Magnitude > 0.05 then
		vector6 = vector5
	end

	if vector6.Magnitude > 0.05 then
		local v26 = merged.stepHeight * metrics.scale
		local vector7 = vector6.Unit * (metrics.colliderRadius + vector5.Magnitude * p2)
		local v27 = p.sphere.Position - v6 * metrics.colliderRadius
		local v28 = Ground.cast(
			v,
			p.sphere.Position + vector7 + v6 * v26,
			-v6 * (v26 + metrics.colliderRadius),
			"step",
			merged
		)

		if v28 ~= nil and v28.Normal:Dot(v6) > merged.minGroundDot then
			local dot = (v28.Position - v27):Dot(v6)
			local dot2 = probe.normal:Dot(v6)

			if dot - (not (flag2 and merged.minGroundDot < dot2) and 0 or -vector7:Dot(probe.normal) / dot2) > 0.05 * metrics.scale and dot <= v26 then
				instance.CFrame += v6 * dot
			end
		end
	end
end

local function driveMotion(p, instance, p2, unit: Vector3, unit2: Vector3, p3: number)
	local sphere = p.sphere
	local metrics = p.metrics
	local assemblyLinearVelocity = instance.AssemblyLinearVelocity
	local dot = assemblyLinearVelocity:Dot(v6)
	local v26 = dot > 0
	local v27 = v10
	local v28 = assemblyLinearVelocity - v6 * dot
	local v29 = metrics.groundDistance + math.max(-dot, 0) * p3
	local probe = Ground.probe(v, sphere.Position, v6, v29, metrics.groundRingRadius, "ground", merged)
	local v30 = probe.grounded and probe.distance <= metrics.groundDistance
	local v31 = false

	if not v30 and v27 and not v11 then
		local v32 = v28 * p3
		local v33 = metrics.groundDistance + v32.Magnitude * math.tan((math.rad(merged.groundSnapAngle)))
		local probe2 = Ground.probe(v, sphere.Position + v32, v6, v33, metrics.groundRingRadius, "groundSnap", merged)
		local v34 = metrics.groundDistance - metrics.colliderRadius

		if probe2.grounded and Motion.isCrest(probe2, v32, v6, metrics.colliderRadius, v34, merged) then
			probe = probe2
			v30 = true
			v31 = true
		end
	end

	part = probe.part
	v10 = v30 and not (v11 and v26)
	local now = os.clock()
	local v32 = p2.Jump and v10 and v12 <= now

	if v32 then
		local v33 = math.clamp(dot, 0, (Motion.surfaceRiseSpeed(v28, v6, probe, merged))) + Motion.jumpSpeed(p2, merged)
		assemblyLinearVelocity = assemblyLinearVelocity - v6 * dot + v6 * v33
		v12 = now + merged.jumpCooldown
		v11 = true
		v10 = false
	elseif v10 and not v26 then
		v11 = false
	end

	if not v10 then
		assemblyLinearVelocity = absorbIntoWall(p, assemblyLinearVelocity, p3)
	end

	local velocity, v33 = Motion.computeVelocity(
		assemblyLinearVelocity,
		v6,
		unit2 * p2.WalkSpeed,
		probe,
		metrics.colliderRadius,
		resolveFall(sphere, metrics, v10, v26 or v32, dot),
		v10,
		v11,
		v31,
		p3,
		merged
	)
	instance.AssemblyLinearVelocity = velocity

	if not (v11 and v26) then
		stepUp(p, instance, probe, v10, v28, unit2, p3)
	end

	if v10 then
		position = instance.Position
	end

	v8 = Basis.resolvePlanarDirection({ v8, unit }, vector2)

	if v24 == nil then
		local UserGameSettings = UserSettings():GetService("UserGameSettings")
		v24 = UserGameSettings
	end

	local v34

	if v25 or v24.RotationType == Enum.RotationType.CameraRelative then
		v34 = true
	else
		if unit2.Magnitude > 0.05 then
			unit = unit2.Unit
		else
			unit = v8
		end

		v34 = false
	end

	local planarDirection = Basis.resolvePlanarDirection({ unit, v8 }, vector2)
	local v35 = v34 and 1 or math.clamp(merged.turnResponsiveness * p3, 0, 1)
	v8 = Motion.turnToward(v8, planarDirection, vector2, v35)
	Collider.setOrientation(p, Motion.orientation(instance.Position, v8, vector2))
	local v36 = unit2.Magnitude > 0.05
	publishState(StateTracker.update(v33, v6, v10, v11, v36), p)
end

function GravityController.configure(p)
	merged = Config.merge(merged, p)
	Camera.setTau(merged.blendTau)
end

function GravityController.bind(instance)
	GravityController.unbind()
	local v26, humanoidRootPart, humanoid, animator = checkCharacterReady(instance) -- equivalent call inferred; original call site unknown

	if v26 then
		v = instance
		v3 = humanoidRootPart
		v2 = humanoid
		v4 = animator
		position = humanoidRootPart.Position
	end
end

function GravityController.unbind()
	destroyRig()
	Camera.reset()
	table.clear(v20)
	v = nil
	v3 = nil
	v2 = nil
	v4 = nil
	vector2 = createVector(0, 1, 0)
	v6 = createVector(0, 1, 0)
	vector3 = createVector(0, 1, 0)
	v7 = 0
end

function GravityController.setSource(p: string, vector5: Vector3?, p2: number)
	Sources.set(p, vector5, p2)
end

function GravityController.render(p: number)
	local resolved, v26 = Sources.resolve()
	v9 = resolved
	local v27 = v26 or createVector(0, 1, 0)
	local now = os.clock()

	if vector3:Dot(v27) < 0.8660254037844387 and vector2:Dot(v27) >= -0.1736481776669303 then
		v7 = now + merged.blendTau * 3
	end

	vector3 = v27
	vector2 = Motion.blendUp(vector2, v27, Basis.blendAlpha(p, merged.blendTau))
	local v28

	if now < v7 then
		v28 = vector2
	else
		v28 = v27
	end

	v6 = v28

	if resolved == nil or v5 ~= nil then
		if resolved == nil and v5 ~= nil and vector2:Dot(createVector(0, 1, 0)) > 0.999 then
			destroyRig()
		end
	else
		createRig()
	end

	Camera.setTarget(v27)
end

function GravityController.update(p: number)
	local v26 = v5
	local v27 = v3
	local v28 = v2

	if v26 == nil or v27 == nil or v28 == nil or v27.Parent == nil then
		return
	end

	local moveBasis, v29 = Motion.resolveMoveBasis(v6, vector2, v8)
	local moveVector = readMoveVector() -- equivalent call inferred; original call site unknown
	local unit = moveBasis * -moveVector.Z + v29 * moveVector.X

	if unit.Magnitude > 1 then
		unit = unit.Unit
	end

	v16 = unit

	if next(v20) ~= nil then
		part = nil
		v10 = false
		position = v27.Position
	else
		local truss = resolveTruss(v26, v27, unit)

		if truss ~= nil then
			driveClimb(v26, v27, v28, truss, unit, p)
			return
		end

		releaseTruss(v27, v28) -- equivalent call inferred; original call site unknown
		driveMotion(v26, v27, v28, moveBasis, unit, p)
	end
end

function GravityController.isBound()
	return v3 ~= nil
end

function GravityController.isCameraLinked()
	return Camera.isLinked()
end

function GravityController.isActive()
	return v5 ~= nil
end

function GravityController.isGrounded()
	return v10
end

function GravityController.isAirborne()
	return v5 ~= nil and not v10
end

function GravityController.getUp()
	return v6
end

function GravityController.getMoveDirection()
	return v16
end

function GravityController.suspendMotion(p: string, flag2: boolean)
	local motionSuspended = isMotionSuspended() -- equivalent call inferred; original call site unknown

	if flag2 then
		v20[p] = true
	else
		v20[p] = nil
	end

	local motionSuspended2 = isMotionSuspended() -- equivalent call inferred; original call site unknown

	if motionSuspended2 ~= motionSuspended then
		dropFall() -- equivalent call inferred; original call site unknown
		v11 = false
		v17 = nil
		v18 = 0
		local v26 = v5
		local v27 = v3

		if v26 ~= nil and v27 ~= nil then
			if motionSuspended2 then
				Animation.stop(merged)
			else
				local cFrame = v27.CFrame
				v8 = Basis.resolvePlanarDirection({ cFrame.LookVector, v8 }, vector2)
				Collider.setOrientation(v26, cFrame.Rotation)
			end

			Collider.setMotionEnabled(v26, not motionSuspended2)
		end
	end
end

function GravityController.isMotionSuspended()
	return next(v20) ~= nil
end

function GravityController.notifyLaunch()
	v11 = true
	v10 = false
end

function GravityController.getSourceKey()
	return v9
end

function GravityController.getState()
	return StateTracker.getState()
end

function GravityController.getStandingPart()
	return part
end

function GravityController.getFallDistance()
	local v26 = v3

	if v26 == nil then
		return 0
	end

	return ((v26.Position - position):Dot(v6))
end

function GravityController.setCameraRelative(flag2: boolean)
	v25 = flag2
end

function GravityController.resetUp()
	vector2 = createVector(0, 1, 0)
	v6 = createVector(0, 1, 0)
	vector3 = createVector(0, 1, 0)
	v7 = 0
	position = v3 == nil and createVector(0, 0, 0) or v3.Position
end

function GravityController.resetSources()
	Sources.clear()
	dropFall() -- equivalent call inferred; original call site unknown
	position = v3 == nil and createVector(0, 0, 0) or v3.Position
end

function GravityController.getRootPart()
	return v3
end

function GravityController.isAlive()
	return v2 ~= nil and v2.Health > 0
end

function GravityController.getFallLanding()
	return v14
end

function GravityController.getLaunchGravity()
	if v5 == nil then
		return workspace.Gravity
	end

	return workspace.Gravity * merged.jumpGravityScale
end

return GravityController