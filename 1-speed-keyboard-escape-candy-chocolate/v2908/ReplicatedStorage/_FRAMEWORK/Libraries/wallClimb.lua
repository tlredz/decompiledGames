local createVector = vector.create
local Config = require(script.Config)
local Detection = require(script.Detection)
local Motion = require(script.Motion)
require(script.Types)
local v = {
	[Enum.HumanoidStateType.Running] = true,
	[Enum.HumanoidStateType.RunningNoPhysics] = true,
	[Enum.HumanoidStateType.Landed] = true
}
local WallClimb = {}
local merged = Config.default()
local v2 = nil
local v3 = true
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = "unavailable"
local v9 = false
local v10 = false
local normal = nil
local jumpRequestConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveUp()
	local getUp = merged.getUp
	local v11 = getUp == nil and createVector(0, 1, 0) or getUp()

	if v11.Magnitude > 0.05 then
		return v11.Unit
	end

	return createVector(0, 1, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveGravity()
	local getGravity = merged.getGravity

	if getGravity == nil then
		return workspace.Gravity
	end

	return (getGravity())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveMoveDirection(p)
	local getMoveDirection = merged.getMoveDirection

	if getMoveDirection == nil then
		return p.MoveDirection
	end

	return (getMoveDirection())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function projectOntoPlane(vector2: Vector3, vector3: Vector3)
	local v11 = vector2 - vector3 * vector2:Dot(vector3)

	if v11.Magnitude > 0.05 then
		return v11.Unit
	end

	return createVector(0, 0, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isAirborne(p)
	local isAirborne2 = merged.isAirborne

	if isAirborne2 == nil then
		return p.FloorMaterial == Enum.Material.Air
	end

	return (isAirborne2(p))
end

local function isCharacterUsable()
	local v11 = v4
	local v12 = v5
	local v13 = v3

	if v13 then
		if v11 == nil or v12 == nil or not (v11.Health > 0) then
			return false
		else
			return v12.Parent ~= nil
		end
	end

	return v13
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isBlockedState(object)
	local state = object:GetState()

	for _, blockedState in merged.blockedStates do
		if state == blockedState then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function facesWall(p, p2, up: Vector3)
	local moveDirection = resolveMoveDirection(p) -- equivalent call inferred; original call site unknown
	local vector2 = projectOntoPlane(moveDirection, up) -- equivalent call inferred; original call site unknown
	return not (vector2.Magnitude > 0.05) or vector2:Dot(-p2.normal) >= merged.inputDotThreshold
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveRise(p, vector2: Vector3)
	local v11 = v5
	return math.max((p.position + vector2 * p.height - v11.Position):Dot(vector2), 0) + merged.heightOvershoot
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isOppositeWall(wall)
	local v11 = normal
	return v11 == nil or wall.normal:Dot(v11) <= merged.resetNormalDot
end

local function computeState()
	local v11 = v7
	local v12 = v4

	if v11 == nil or v12 == nil then
		return "unavailable"
	end

	if v9 or v11.noBoost then
		return "spent"
	end

	-- equivalent call inferred; original call site unknown
	if isBlockedState(v12) then
		return "unavailable"
	end

	local up = resolveUp() -- equivalent call inferred; original call site unknown

	if facesWall(v12, v11, up) then
		return "ready"
	end

	return "unavailable"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshState()
	local v11 = v7
	local v12 = v4
	local v13

	if v11 == nil or v12 == nil then
		v13 = "unavailable"
	elseif v9 or v11.noBoost then
		v13 = "spent"
	else
		-- equivalent call inferred; original call site unknown
		if isBlockedState(v12) then
			v13 = "unavailable"
		else
			local up = resolveUp() -- equivalent call inferred; original call site unknown
			v13 = facesWall(v12, v11, up) and "ready" or "unavailable"
		end
	end

	if v13 ~= v8 then
		local v14 = v8 == "ready"
		v8 = v13

		if v13 == "ready" then
			local onReady = merged.onReady

			if onReady ~= nil then
				onReady(v7)
			end
		elseif v14 then
			local onLost = merged.onLost

			if onLost ~= nil then
				onLost()
			end
		end
	end
end

local function probeDirection(vector2: Vector3)
	local v12 = v5
	local moveDirection = resolveMoveDirection(v4) -- equivalent call inferred; original call site unknown
	local selected = projectOntoPlane(moveDirection, vector2) -- equivalent call inferred; original call site unknown

	if selected.Magnitude > 0.05 then
		return selected
	end

	local lookVector = v12.CFrame.LookVector
	local v14 = lookVector - vector2 * lookVector:Dot(vector2)

	if v14.Magnitude > 0.05 then
		return v14.Unit
	end

	return createVector(0, 0, 0)
end

local function applyBoost(up: Vector3)
	local v11 = v4
	local v12 = v5
	local v13 = v7
	local computeBoost = Motion.computeBoost
	local rise = resolveRise(v13, up) -- equivalent call inferred; original call site unknown
	local gravity = resolveGravity() -- equivalent call inferred; original call site unknown
	local assemblyLinearVelocity = computeBoost(rise, gravity, up, v13, merged)
	v11.Jump = false
	v12.AssemblyLinearVelocity = assemblyLinearVelocity

	if v[v11:GetState()] then
		v11:ChangeState(Enum.HumanoidStateType.Freefall)
	end

	v9 = true
	normal = v13.normal
	refreshState() -- equivalent call inferred; original call site unknown
	local onBoost = merged.onBoost

	if onBoost ~= nil then
		onBoost(assemblyLinearVelocity, v13)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkAbsorbReady(p: number, up: Vector3)
	local v11 = v4
	local v12 = projectOntoPlane(v5.AssemblyLinearVelocity, up) -- equivalent call inferred; original call site unknown
	local absorbImpact = merged.absorbImpact

	if not absorbImpact then
		return absorbImpact, v12
	end

	if p > 0 and v12.Magnitude > 0 then
		local isAirborne2 = merged.isAirborne

		if isAirborne2 == nil then
			absorbImpact = v11.FloorMaterial == Enum.Material.Air
		else
			absorbImpact = isAirborne2(v11)
		end

		if absorbImpact then
			local blockedState = isBlockedState(v11) -- equivalent call inferred; original call site unknown
			absorbImpact = not blockedState
		end
	else
		absorbImpact = false
	end

	return absorbImpact, v12
end

local function applyAbsorb(p: number, up: Vector3, vector2: Vector3)
	local v11 = v5
	local v12 = merged
	local assemblyLinearVelocity = v11.AssemblyLinearVelocity
	local v13 = v12.absorbClearance + assemblyLinearVelocity:Dot(vector2) * p
	local impact = Detection.findImpact(v11.Position, vector2, v13, up, v12, v6, v2)

	if impact ~= nil then
		v11.AssemblyLinearVelocity = Motion.absorbImpact(
			assemblyLinearVelocity,
			impact.normal,
			impact.distance,
			v12.absorbClearance,
			p
		)
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
	v4 = p
	v5 = p2
	v6 = Detection.buildParams(instance)
	v7 = nil
	v8 = "unavailable"
	v9 = false
	v10 = false
	normal = nil
end

function WallClimb.configure(p)
	merged = Config.merge(merged, p)
end

function WallClimb.getConfig()
	return merged
end

function WallClimb.bind(instance)
	local v11, humanoid, humanoidRootPart = checkCharacterReady(instance) -- equivalent call inferred; original call site unknown

	if not v11 then
		error("wallClimb.bind expects a character holding a Humanoid and a HumanoidRootPart")
		return
	end

	applyBind(instance, humanoid, humanoidRootPart) -- equivalent call inferred; original call site unknown
end

function WallClimb.unbind()
	v4 = nil
	v5 = nil
	v6 = nil
	v7 = nil
	v8 = "unavailable"
	v9 = false
	v10 = false
	normal = nil
end

function WallClimb.setEnabled(flag: boolean)
	v3 = flag

	if not flag then
		v7 = nil
		refreshState() -- equivalent call inferred; original call site unknown
	end
end

function WallClimb.isEnabled()
	return v3
end

function WallClimb.setCanClimb(callback)
	v2 = callback
end

function WallClimb.update(p: number)
	local v11 = v4
	local v12 = v5
	local v13 = v3

	if v13 then
		if v11 == nil or v12 == nil or not (v11.Health > 0) then
			v13 = false
		else
			v13 = v12.Parent ~= nil
		end
	end

	if v13 then
		local v14 = v4
		local v15 = v5
		local up = resolveUp() -- equivalent call inferred; original call site unknown

		-- equivalent call inferred; original call site unknown
		if not isAirborne(v14) then
			v9 = false
			normal = nil
		end

		local findWall = Detection.findWall
		local position = v15.Position
		local v17 = v5
		local moveDirection = resolveMoveDirection(v4) -- equivalent call inferred; original call site unknown
		local v18 = projectOntoPlane(moveDirection, up) -- equivalent call inferred; original call site unknown

		if not (v18.Magnitude > 0.05) then
			v18 = projectOntoPlane(v17.CFrame.LookVector, up)
		end

		local wall = findWall(position, v18, up, merged, v6, v2)

		if wall ~= nil and merged.resetOnOppositeWall and isOppositeWall(wall) then
			v9 = false
		end

		v7 = wall
		refreshState() -- equivalent call inferred; original call site unknown

		if v10 and v8 == "ready" then
			applyBoost(up)
		end

		v10 = false
		local absorbImpact, v20 = checkAbsorbReady(p, up) -- equivalent call inferred; original call site unknown

		if absorbImpact then
			applyAbsorb(p, up, v20)
		end
	else
		v7 = nil
		v10 = false
		refreshState() -- equivalent call inferred; original call site unknown
	end
end

function WallClimb.getState()
	return v8
end

function WallClimb.isReady()
	return v8 == "ready"
end

function WallClimb.getSurface()
	return v7
end

function WallClimb.getWallHeight()
	local v11 = v7

	if v11 == nil then
		return 0
	end

	return v11.height
end

function WallClimb.getBoostSpeed()
	local v11 = v7

	if v8 ~= "ready" or v11 == nil or v5 == nil then
		return 0
	end

	local resolveBoostSpeed = Motion.resolveBoostSpeed
	local up = resolveUp() -- equivalent call inferred; original call site unknown
	local rise = resolveRise(v11, up) -- equivalent call inferred; original call site unknown
	local gravity = resolveGravity() -- equivalent call inferred; original call site unknown
	return resolveBoostSpeed(rise, gravity, merged, v11)
end

function WallClimb.requestJump()
	if v8 ~= "ready" then
		return false
	end

	v10 = true
	return true
end

function WallClimb.bindDefaultInput()
	if jumpRequestConnection == nil then
		local UserInputService = game:GetService("UserInputService")
		jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
			WallClimb.requestJump()
		end)
	end
end

function WallClimb.unbindDefaultInput()
	local connection = jumpRequestConnection

	if connection ~= nil then
		connection:Disconnect()
		jumpRequestConnection = nil
	end
end

return WallClimb