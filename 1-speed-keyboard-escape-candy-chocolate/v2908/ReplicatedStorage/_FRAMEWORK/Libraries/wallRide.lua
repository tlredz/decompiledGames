local createVector = vector.create
local Config = require(script.Config)
local Detection = require(script.Detection)
local Motion = require(script.Motion)
require(script.Types)
local WallRide = {}
local merged = Config.default()
local v = nil
local v2 = true
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = "idle"
local v8 = nil
local v9 = nil
local v10 = 0
local total = 0
local v11 = 0
local now = 0
local total2 = 0
local v12 = false
local position = nil
local v13 = nil
local v14 = {}
local v15 = nil
local jumpRequestConnection = nil

local function releaseTracks()
	for _, v16 in v14 do
		v16:Stop()
		v16:Destroy()
	end

	table.clear(v14)
	v15 = nil
end

local function loadTrack(animator, animationId: string)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = animator:LoadAnimation(animation)
	animation:Destroy()
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = true
	return track
end

local function loadTracks()
	releaseTracks()
	local v16 = v4
	local animations = merged.animations
	local animator

	if v16 ~= nil then
		animator = v16:FindFirstChildOfClass("Animator")
	end

	if animator ~= nil and animations ~= nil then
		for k, animation in animations do
			local v17 = v14
			local formatted = `rbxassetid://{animation}`
			local animation2 = Instance.new("Animation")
			animation2.AnimationId = formatted
			local track = animator:LoadAnimation(animation2)
			animation2:Destroy()
			track.Priority = Enum.AnimationPriority.Action
			track.Looped = true
			v17[k] = track
		end
	end
end

local function checkRunAnimationReady()
	local v16 = v3
	local v17 = v4
	local animator

	if v17 ~= nil then
		animator = v17:FindFirstChildOfClass("Animator")
	end

	local animate

	if v16 ~= nil then
		animate = v16:FindFirstChild("Animate")
	end

	local run

	if animate ~= nil then
		run = animate:FindFirstChild("run")
	end

	local animation

	if run ~= nil then
		animation = run:FindFirstChildOfClass("Animation")
	end

	if animator == nil or animation == nil or animation.AnimationId == "" then
		return false, nil, nil
	end

	return true, animator, animation.AnimationId
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureRunTrack()
	local v16, animator, animationId = checkRunAnimationReady()

	if v16 then
		local v18 = v14
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		local track = animator:LoadAnimation(animation)
		animation:Destroy()
		track.Priority = Enum.AnimationPriority.Action
		track.Looped = true
		v18.run = track
	end
end

local function resolveTrackName(p)
	local selected = p == "right" and "rideRight" or "rideLeft"

	if v14[selected] ~= nil then
		return selected
	end

	if v14.run == nil then
		return nil
	end

	return "run"
end

local function syncTrack(p)
	local v16 = p.side == "right" and "rideRight" or "rideLeft"

	if v14[v16] == nil then
		v16 = v14.run ~= nil and "run" or nil
	end

	if v16 ~= v15 then
		local v17

		if v15 ~= nil then
			v17 = v14[v15]
		end

		local v18

		if v16 ~= nil then
			v18 = v14[v16]
		end

		if v17 ~= nil then
			v17:Stop()
		end

		if v18 ~= nil then
			v18:Play()
		end

		v15 = v16
	end

	local v17

	if v16 ~= nil then
		v17 = v14[v16]
	end

	if v17 ~= nil then
		v17:AdjustSpeed((math.min(v10 / merged.animationSpeedReference, merged.animationMaxSpeed)))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTracks()
	for _, v16 in v14 do
		v16:Stop()
	end

	v15 = nil
end

local function isCharacterUsable()
	local v16 = v4
	local v17 = v5
	local v18 = v2

	if v18 then
		if v16 == nil or v17 == nil or not (v16.Health > 0) then
			return false
		else
			return v17.Parent ~= nil
		end
	end

	return v18
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveUp()
	local getUp = merged.getUp
	local v16 = getUp == nil and createVector(0, 1, 0) or getUp()

	if v16.Magnitude > 0.05 then
		return v16.Unit
	end

	return createVector(0, 1, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveMoveDirection()
	local getMoveDirection = merged.getMoveDirection

	if getMoveDirection == nil then
		return v4.MoveDirection
	end

	return (getMoveDirection())
end

local function projectOntoPlane(vector2: Vector3, vector3: Vector3)
	return vector2 - vector3 * vector2:Dot(vector3)
end

local function probeDirection(vector2: Vector3)
	local v16 = v5
	local moveDirection = resolveMoveDirection() -- equivalent call inferred; original call site unknown
	local v17 = moveDirection - vector2 * moveDirection:Dot(vector2)

	if not (v17.Magnitude > 0.05) then
		local lookVector = v16.CFrame.LookVector
		v17 = lookVector - vector2 * lookVector:Dot(vector2)
	end

	if v17.Magnitude > 0.05 then
		return v17.Unit
	end

	return createVector(0, 0, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function planarSpeed(vector2: Vector3)
	local assemblyLinearVelocity = v5.AssemblyLinearVelocity
	return (assemblyLinearVelocity - vector2 * assemblyLinearVelocity:Dot(vector2)).Magnitude
end

local function detach(p)
	local v16 = v8
	local v17 = v4
	v7 = "cooldown"
	v11 = os.clock() + merged.reattachCooldown
	local v18

	if v16 == nil then
		v18 = v13
	else
		v18 = v16.part
	end

	v13 = v18
	v8 = nil
	v9 = nil
	v10 = 0
	position = nil
	total = 0
	stopTracks() -- equivalent call inferred; original call site unknown

	if v17 ~= nil then
		local v19

		if p == "ground" then
			v19 = Enum.HumanoidStateType.GettingUp
		else
			v19 = Enum.HumanoidStateType.Freefall
		end

		v17:ChangeState(v19)
	end

	local onMotionOwned = merged.onMotionOwned

	if onMotionOwned ~= nil then
		onMotionOwned(false)
	end

	local onDetach = merged.onDetach

	if onDetach ~= nil then
		onDetach(p, v16)
	end
end

local function attach(wall, vector2: Vector3)
	local v16 = v4
	local v17 = v5
	v7 = "riding"
	v8 = wall
	v10 = Motion.resolveRideSpeed(v16.WalkSpeed, merged, wall)
	v9 = Motion.computeFrame(v10, 0, wall, vector2, merged)
	now = os.clock()
	total2 = 0
	v12 = false
	total = 0
	position = v17.Position
	v13 = nil
	v16:ChangeState(Enum.HumanoidStateType.Physics)
	local onMotionOwned = merged.onMotionOwned

	if onMotionOwned ~= nil then
		onMotionOwned(true)
	end

	if merged.useRunAnimation and v14.run == nil then
		ensureRunTrack() -- equivalent call inferred; original call site unknown
	end

	syncTrack(wall)
	local onAttach = merged.onAttach

	if onAttach ~= nil then
		onAttach(wall)
	end
end

local function isAttachStateAllowed(object)
	local isHostDriven = merged.isHostDriven

	if isHostDriven ~= nil and isHostDriven() then
		return true
	end

	local state = object:GetState()

	for _, attachState in merged.attachStates do
		if state == attachState then
			return true
		end
	end

	return false
end

local function canAttachTo(wall, object, flag: boolean, ground: boolean, vector2: Vector3)
	local v16 = merged
	local moveDirection = resolveMoveDirection() -- equivalent call inferred; original call site unknown
	local tangent = Motion.computeTangent(wall, vector2)
	local v17 = not flag or moveDirection:Dot(tangent) >= v16.rideDotThreshold
	local v18 = not flag or moveDirection:Dot(-wall.normal) < v16.headOnThreshold
	local v19 = not flag

	if not v19 then
		v19 = planarSpeed(vector2) >= v16.minEntrySpeed
	end

	local v20 = not (v16.requiresAirborne and ground)
	v19 = not v16.reattachRequiresDifferentWall or wall.part ~= v13

	if not v17 then
		return v17
	end

	if not v18 then
		return v18
	end

	if not v19 then
		return v19
	end

	if not v20 then
		return v20
	end

	if not v19 then
		return v19
	end

	local isHostDriven = merged.isHostDriven

	if isHostDriven ~= nil and isHostDriven() then
		return true
	end

	local state = object:GetState()

	for _, attachState in merged.attachStates do
		if state == attachState then
			return true
		end
	end

	v19 = false
	return false
end

local function resolveExit(p, p2, _, flag: boolean, p3: number)
	local v16 = merged
	local maxDuration

	if p.maxDuration > 0 then
		maxDuration = p.maxDuration
	else
		maxDuration = v16.maxRideDuration
	end

	local moveDirection = resolveMoveDirection() -- equivalent call inferred; original call site unknown

	if moveDirection:Dot(p2.tangent) < v16.holdDotThreshold then
		return "input"
	end

	if flag and v12 then
		return "ground"
	end

	if maxDuration > 0 and maxDuration <= p3 then
		return "exhausted"
	end

	return nil
end

local function advanceRide(sideWall, vector2: Vector3, p: number)
	local v16 = v4
	local v17 = v5
	local v18 = merged
	local v19 = os.clock() - now
	v10 = Motion.resolveRideSpeed(v16.WalkSpeed, v18, sideWall)
	local fallSpeed = Motion.resolveFallSpeed(v19, v18, sideWall)
	local frame = Motion.computeFrame(v10, -fallSpeed, sideWall, vector2, v18)
	v9 = frame
	Motion.apply(v17, frame, p)
	v17.CFrame = Motion.resolveOrientation(v17, frame, vector2, v18, p)
	syncTrack(sideWall)
	local v20 = position

	if v20 ~= nil then
		total2 += (v17.Position - v20).Magnitude
	end

	position = v17.Position
	local onRide = v18.onRide

	if onRide ~= nil then
		onRide(p, frame.commanded, sideWall)
	end

	local ground = Detection.hasGround(v17.Position, vector2, v18, v6)

	if not ground then
		v12 = true
	end

	local v21 = merged
	local maxDuration

	if sideWall.maxDuration > 0 then
		maxDuration = sideWall.maxDuration
	else
		maxDuration = v21.maxRideDuration
	end

	local moveDirection = resolveMoveDirection() -- equivalent call inferred; original call site unknown
	local v22

	if moveDirection:Dot(frame.tangent) < v21.holdDotThreshold then
		v22 = "input"
	elseif ground and v12 then
		v22 = "ground"
	elseif maxDuration > 0 and maxDuration <= v19 then
		v22 = "exhausted"
	else
		v22 = nil
	end

	if v22 ~= nil then
		detach(v22)
	end
end

local function updateRiding(up: Vector3, p: number)
	local v16 = v5
	local v17 = v8
	local sideWall = Detection.findSideWall(v16.Position, Motion.computeTangent(v17, up), v17.side, up, merged, v6, v)

	if sideWall == nil then
		total += p

		if total >= merged.lostWallGrace then
			detach("lostWall")
		else
			Motion.apply(v16, v9, p)
		end
	else
		total = 0
		v8 = sideWall
		advanceRide(sideWall, up, p)
	end
end

local function updateIdle(up: Vector3)
	local v16 = v4
	local v17 = v5
	local v18 = v6
	local ground = Detection.hasGround(v17.Position, up, merged, v18)

	if ground then
		v13 = nil
	end

	local findWall = Detection.findWall
	local position2 = v17.Position
	local v19 = v5
	local moveDirection = resolveMoveDirection() -- equivalent call inferred; original call site unknown
	local v20 = moveDirection - up * moveDirection:Dot(up)

	if not (v20.Magnitude > 0.05) then
		local lookVector = v19.CFrame.LookVector
		v20 = lookVector - up * lookVector:Dot(up)
	end

	local wall = findWall(
		position2,
		not (v20.Magnitude > 0.05) and createVector(0, 0, 0) or v20.Unit,
		up,
		merged,
		v18,
		v
	)

	if wall ~= nil and canAttachTo(wall, v16, true, ground, up) then
		attach(wall, up)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkCharacterReady(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoid == nil or humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
		return false, nil, nil
	end

	return true, humanoid, humanoidRootPart
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyBind(instance, p, p2)
	v3 = instance
	v4 = p
	v5 = p2
	v6 = Detection.buildParams(instance)
	v7 = "idle"
	v8 = nil
	v9 = nil
	v10 = 0
	total2 = 0
	total = 0
	v11 = 0
	position = nil
	v13 = nil
	loadTracks()
end

function WallRide.configure(p)
	merged = Config.merge(merged, p)

	if v3 ~= nil then
		loadTracks()
	end
end

function WallRide.getConfig()
	return merged
end

function WallRide.bind(instance)
	local v16, humanoid, humanoidRootPart = checkCharacterReady(instance) -- equivalent call inferred; original call site unknown

	if not v16 then
		error("wallRide.bind expects a character holding a Humanoid and a HumanoidRootPart")
		return
	end

	if v7 == "riding" then
		detach("unbound")
	end

	applyBind(instance, humanoid, humanoidRootPart) -- equivalent call inferred; original call site unknown
end

function WallRide.unbind()
	if v7 == "riding" then
		detach("unbound")
	end

	releaseTracks()
	v3 = nil
	v4 = nil
	v5 = nil
	v6 = nil
	v7 = "idle"
end

function WallRide.setEnabled(flag: boolean)
	v2 = flag

	if not flag and v7 == "riding" then
		detach("unbound")
	end
end

function WallRide.isEnabled()
	return v2
end

function WallRide.setCanRide(callback)
	v = callback
end

function WallRide.update(p: number)
	local v16 = v4
	local v17 = v5
	local v18 = v2

	if v18 then
		if v16 == nil or v17 == nil or not (v16.Health > 0) then
			v18 = false
		else
			v18 = v17.Parent ~= nil
		end
	end

	if v18 then
		if v7 == "cooldown" then
			local now2 = os.clock()

			if v11 <= now2 then
				v7 = "idle"
			end
		end

		local up = resolveUp() -- equivalent call inferred; original call site unknown

		if v7 == "riding" then
			updateRiding(up, p)
		elseif v7 == "idle" then
			updateIdle(up)
		end
	elseif v7 == "riding" then
		detach("unbound")
	end
end

function WallRide.getState()
	return v7
end

function WallRide.isRiding()
	return v7 == "riding"
end

function WallRide.getSurface()
	return v8
end

function WallRide.getSide()
	local v16 = v8

	if v16 == nil then
		return nil
	end

	return v16.side
end

function WallRide.getRideSpeed()
	return v10
end

function WallRide.getRiddenDistance()
	return total2
end

function WallRide.tryAttach()
	local v16 = v4
	local v17 = v5
	local v18 = v4
	local v19 = v5
	local v20 = v2

	if v20 then
		if v18 == nil or v19 == nil or not (v18.Health > 0) then
			v20 = false
		else
			v20 = v19.Parent ~= nil
		end
	end

	if v20 then
		if v7 == "riding" or v16 == nil then
			v20 = false
		else
			v20 = v17 ~= nil
		end
	end

	if not v20 then
		return false
	end

	local v21 = v6
	local position2 = v17.Position
	local up = resolveUp() -- equivalent call inferred; original call site unknown
	local ground = Detection.hasGround(position2, up, merged, v21)
	local findWall = Detection.findWall
	local v22 = v5
	local moveDirection = resolveMoveDirection() -- equivalent call inferred; original call site unknown
	local v23 = moveDirection - up * moveDirection:Dot(up)

	if not (v23.Magnitude > 0.05) then
		local lookVector = v22.CFrame.LookVector
		v23 = lookVector - up * lookVector:Dot(up)
	end

	local wall = findWall(
		position2,
		not (v23.Magnitude > 0.05) and createVector(0, 0, 0) or v23.Unit,
		up,
		merged,
		v21,
		v
	)

	if wall == nil then
		return false
	end

	local v24 = merged
	local getMoveDirection = merged.getMoveDirection

	if getMoveDirection == nil then
		local _ = v4.MoveDirection
	else
		getMoveDirection()
	end

	Motion.computeTangent(wall, up)
	local v25 = not (v24.requiresAirborne and ground)
	local v26 = not v24.reattachRequiresDifferentWall or wall.part ~= v13

	if v25 then
		if v26 then
			local isHostDriven = merged.isHostDriven

			if isHostDriven == nil or not isHostDriven() then
				local state = v16:GetState()
				local flag = true

				for _, attachState in merged.attachStates do
					if state ~= attachState then
						continue
					end

					v26 = true
					flag = false
					break
				end

				if flag then
					v26 = false
				end
			else
				v26 = true
			end
		end
	else
		v26 = v25
	end

	if v26 then
		attach(wall, up)
		return true
	end

	return false
end

function WallRide.detach(p)
	if v7 == "riding" then
		detach(p == nil and "manual" or p)
	end
end

function WallRide.requestJump()
	local v16 = v8
	local v17 = v9
	local v18

	if v7 == "riding" and v16 ~= nil and v17 ~= nil then
		v18 = not v16.noJump
	else
		v18 = false
	end

	if not v18 then
		return false
	end

	local assemblyLinearVelocity = Motion.computeEject(v17, v16, resolveUp(), merged)
	local v20 = v5
	detach("jump")
	v20.AssemblyLinearVelocity = assemblyLinearVelocity
	local onJump = merged.onJump

	if onJump ~= nil then
		onJump(assemblyLinearVelocity, v16)
	end

	return true
end

function WallRide.bindDefaultInput()
	if jumpRequestConnection == nil then
		local UserInputService = game:GetService("UserInputService")
		jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
			WallRide.requestJump()
		end)
	end
end

function WallRide.unbindDefaultInput()
	local connection = jumpRequestConnection

	if connection ~= nil then
		connection:Disconnect()
		jumpRequestConnection = nil
	end
end

return WallRide