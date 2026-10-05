local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local guardMovement = require(ReplicatedStorage.Shared.Flags.GameplayBalance).GuardMovement
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Constants = require(ReplicatedStorage2.Shared.Globals.Constants)
local CollisionGroups = require(ReplicatedStorage2.Shared.Types.CollisionGroups)
local GuardChasePolicy = require(script.Parent.GuardChasePolicy)
local GuardDistance = require(script.Parent.GuardDistance)
local GuardEggRetrievalComponent = require(script.Parent.GuardEggRetrievalComponent)
local GuardReturnHomeDistanceResolver = require(script.Parent.GuardReturnHomeDistanceResolver)
local GuardMovementRecovery = require(script.Parent.GuardMovementRecovery)
local GuardPresentationComponent = require(script.Parent.GuardPresentationComponent)
require(ReplicatedStorage2.Data.Guards)
local Log = require(ReplicatedStorage2.Packages.Log)
local Player = require(ReplicatedStorage2.Shared.Player)
local t = require(ReplicatedStorage2.Packages.t)
require(script.Parent.Types.Interface)
local WaitFor = require(ReplicatedStorage2.Packages.WaitFor)
local GuardComponent = {}
GuardComponent.__index = GuardComponent
GuardComponent.__class = "GuardComponent"
GuardComponent.ATTACK_MIN_INTERVAL = guardMovement.ATTACK_MIN_INTERVAL
local BalanceConfig = require(ReplicatedStorage2.Shared.Flags.BalanceConfig)
BalanceConfig.Changed:Connect(function()
	GuardComponent.ATTACK_MIN_INTERVAL = guardMovement.ATTACK_MIN_INTERVAL
end)
local v = Log.new()

function GuardComponent.new(areaId: string, folder, bounds, p, config, targetResolver, data)
	local self = setmetatable({}, GuardComponent)
	t.strict(t.string)(areaId)
	t.strict(t.instanceIsA("Model"))(folder)
	t.strict(t.instanceIsA("BasePart"))(bounds)
	t.strict(t.instanceIsA("BasePart"))(p)
	t.strict(t.table)(config)
	t.strict(t.callback)(targetResolver)
	t.strict(t.table)(data)
	t.strict(t.callback)(data.Attack)
	t.strict(t.boolean)(data.ServerOwnsPhysics)
	t.strict(t.callback)(data.Wake)
	local v2, humanoid = WaitFor.Descendant(folder, "Humanoid", Constants.STUDIO_YIELD_TIMEOUT):await()
	local v3, animator = WaitFor.Descendant(folder, "Animator", Constants.STUDIO_YIELD_TIMEOUT):await()
	local humanoidRootPart = folder:WaitForChild("HumanoidRootPart", Constants.STUDIO_YIELD_TIMEOUT)
	local collider = folder:WaitForChild("Collider", Constants.STUDIO_YIELD_TIMEOUT)
	local v4, v5 = WaitFor.Descendant(folder, "Head", Constants.STUDIO_YIELD_TIMEOUT):await()
	assert(v2, (`Failed to resolve Humanoid under {folder:GetFullName()}: {tostring(humanoid)}`))
	assert(v3, (`Failed to resolve Animator under {folder:GetFullName()}: {tostring(animator)}`))
	assert(
		humanoidRootPart,
		(`Failed to resolve HumanoidRootPart under {folder:GetFullName()}: {tostring(humanoidRootPart)}`)
	)
	assert(collider, (`Failed to resolve Collider under {folder:GetFullName()}`))
	assert(v4, (`Failed to resolve Head under {folder:GetFullName()}: {tostring(v5)}`))
	assert(humanoid:IsA("Humanoid"), (`{folder:GetFullName()}.Humanoid must be a Humanoid`))
	assert(animator:IsA("Animator"), (`{folder:GetFullName()}.Animator must be an Animator`))
	assert(humanoidRootPart:IsA("BasePart"), (`{folder:GetFullName()}.HumanoidRootPart must be a BasePart`))
	assert(collider:IsA("BasePart"), (`{folder:GetFullName()}.Collider must be a BasePart`))

	if Constants.IS_STUDIO and animator.Parent == humanoid and not folder:FindFirstChild("Model") then
		error((`Animator has to be parented to the animation controller for {folder:GetFullName()}`))
	end

	local currentPhysicalProperties = collider.CurrentPhysicalProperties
	collider.CustomPhysicalProperties = PhysicalProperties.new(
		0.01,
		currentPhysicalProperties.Friction,
		currentPhysicalProperties.Elasticity,
		currentPhysicalProperties.FrictionWeight,
		currentPhysicalProperties.ElasticityWeight
	)
	local v6 = data.ServerOwnsPhysics and folder:GetAttribute("Hidden") == true

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		if not v6 then
			part.Anchored = false
		end

		part.CollisionGroup = CollisionGroups.GUARD_COLLISION_GROUP
	end

	self._areaId = areaId
	self._attackHandler = data.Attack
	self._bounds = bounds
	self._config = config
	self._eggRetrieval = GuardEggRetrievalComponent.new(folder, humanoidRootPart, humanoidRootPart.CFrame)
	self._enabled = true
	self._currentMoveTo = nil
	self._creatorPause = nil
	self._guardModel = folder
	self._homeCFrame = humanoidRootPart.CFrame
	self._humanoid = humanoid
	self._lastAttackTime = 0
	self._lastNetworkOwnerRetry = -1e999
	self._lastTargetRefresh = 0
	self._movementRecovery = GuardMovementRecovery.new(humanoidRootPart, p)
	self._attackResumeTime = 0
	self._ragdollEndTime = 0
	self._presentation = GuardPresentationComponent.new(humanoidRootPart, animator, config)
	self._root = humanoidRootPart
	self._serverOwnsPhysics = data.ServerOwnsPhysics
	self._sleepTurnConnection = nil
	self._sleepTurnFromCFrame = nil
	self._sleepTurnStartTime = 0
	self._state = "Sleeping"
	self._stolenEggUidByPlayer = {}
	self._stolenPlayerByEggUid = {}
	self._stolenPriorityByEggUid = {}
	self._targetPlayer = nil
	self._targetResolver = targetResolver
	self._wakeHandler = data.Wake
	self._wakingStartedAt = 0
	self._walkResumeTime = 0
	folder:SetAttribute("TargetPlayer", "")
	folder:SetAttribute("Sleeping", false)
	folder:SetAttribute("GuardState", "")
	folder:SetAttribute("AreaId", areaId)
	folder:SetAttribute("WakeTargetPlayer", "")
	humanoid.WalkSpeed = config.WalkSpeed
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	self:_trySetNetworkOwner(os.clock(), true)
	self:_enterSleepState()
	return self
end

function GuardComponent:_setState(state)
	self._state = state

	if state ~= "Chasing" then
		self._presentation:CancelAfterWake()
	end
end

function GuardComponent:_isHitPaused(p2: number)
	t.strict(t.number)(p2)
	return p2 < math.max(self._walkResumeTime, self._attackResumeTime)
end

function GuardComponent:_holdIfHitPaused(p: number)
	t.strict(t.number)(p)

	if not self:_isHitPaused(p) then
		return false
	end

	self._humanoid.WalkSpeed = 0
	self:_stopMovement()
	self._presentation:StopWalkAnimation()
	self._presentation:EnsureIdleAnimation()
	self._presentation:StopFootstepSound()
	return true
end

function GuardComponent:_enterSleepState()
	self:_setState("Sleeping")
	self._targetPlayer = nil
	self._currentMoveTo = nil
	self._movementRecovery:Reset()
	self:_cancelSleepTurn()
	self._wakingStartedAt = 0

	if not self._serverOwnsPhysics or self._guardModel:GetAttribute("Hidden") ~= true then
		self._root.Anchored = false
	end

	self._root.AssemblyAngularVelocity = createVector(0, 0, 0)
	self._root.AssemblyLinearVelocity = createVector(0, 0, 0)
	self._guardModel:PivotTo(self._homeCFrame)
	self._root.AssemblyAngularVelocity = createVector(0, 0, 0)
	self._root.AssemblyLinearVelocity = createVector(0, 0, 0)
	self._humanoid.WalkSpeed = 0
	self._humanoid:Move(createVector(0, 0, 0), false)
	self._guardModel:SetAttribute("Sleeping", true)
	self._guardModel:SetAttribute("TargetPlayer", "")
	self._guardModel:SetAttribute("WakeTargetPlayer", "")
	self._guardModel:SetAttribute("GuardState", self._state)
	self._presentation:StopWalkAnimation()
	self._presentation:StopIdleAnimation()
	self._presentation:StopFootstepSound()
	self._presentation:PlaySleep(0.75)
end

function GuardComponent:_enterWakingState(wakingStartedAt: number)
	t.strict(t.number)(wakingStartedAt)

	if self._state == "Waking" then
		return
	end

	self:_cancelSleepTurn()
	self:_setTarget(nil)
	self:_setState("Waking")
	self._currentMoveTo = nil
	self._movementRecovery:Reset()
	self._wakingStartedAt = wakingStartedAt
	self._guardModel:SetAttribute("TargetPlayer", "")
	self._guardModel:SetAttribute("GuardState", self._state)
	self:_refreshWakeTarget()
end

function GuardComponent:_updateWaking(p: number)
	t.strict(t.number)(p)

	if not (self:HasStolenEggs() or self._eggRetrieval:HasPending()) then
		self:_enterSleepState()
		return
	end

	self:_refreshWakeTarget()

	if p - self._wakingStartedAt < GuardChasePolicy.GetWakingDuration() then
		return
	end

	if self._eggRetrieval:HasPending() then
		self:_enterEggRetrievalState(p)
		return
	end

	self:_enterChaseState(p)
	self:_updateChase(p)
end

function GuardComponent:_getChaseWalkSpeed(p2: number)
	t.strict(t.number)(p2)
	return GuardChasePolicy.ResolveWalkSpeed(self._config.WalkSpeed, self._config.FlatRadius, p2)
end

function GuardComponent:_getReturnWalkSpeed()
	return self._config.WalkSpeed * guardMovement.RETURN_WALK_SPEED_MULTIPLIER
end

function GuardComponent:_enterChaseState(walkResumeTime: number)
	local v2 = self._state == "Waking"
	self:_cancelSleepTurn()

	if self._state ~= "Chasing" then
		self._wakingStartedAt = 0

		if not self._serverOwnsPhysics or self._guardModel:GetAttribute("Hidden") ~= true then
			self._root.Anchored = false
		end

		self:_trySetNetworkOwner(walkResumeTime, true)
		self._humanoid.WalkSpeed = self._config.WalkSpeed
		self._guardModel:SetAttribute("Sleeping", false)
		self._guardModel:SetAttribute("GuardState", "Chasing")
		self._guardModel:SetAttribute("WakeTargetPlayer", "")
		self._presentation:StopSleep(0.4)
		self._wakeHandler(self._guardModel)
	end

	self:_setState("Chasing")

	if v2 then
		self._presentation:ScheduleAfterWake(walkResumeTime)
	end

	if self._walkResumeTime < walkResumeTime then
		self._walkResumeTime = walkResumeTime
	end
end

function GuardComponent:_enterEggRetrievalState(p: number)
	t.strict(t.number)(p)
	local v2 = self._state == "Waking"
	self:_cancelSleepTurn()
	self:_setTarget(nil)
	self:_setState("RetrievingEgg")
	self._wakingStartedAt = 0

	if not self._serverOwnsPhysics or self._guardModel:GetAttribute("Hidden") ~= true then
		self._root.Anchored = false
	end

	self:_trySetNetworkOwner(p, true)
	self._guardModel:SetAttribute("Sleeping", false)
	self._guardModel:SetAttribute("GuardState", self._state)
	self._guardModel:SetAttribute("WakeTargetPlayer", "")

	if v2 then
		self._presentation:StopSleep(0.4)
		self._wakeHandler(self._guardModel)
	end
end

function GuardComponent:_updateEggRetrieval(p: number)
	t.strict(t.number)(p)

	if self._eggRetrieval:HasPending() then
		local currentEggUid = self._eggRetrieval:GetCurrentEggUid()
		local eggPickupDistance = self._config.EggPickupDistance or GuardChasePolicy.ResolveHitDistance(self._config.HitDistance)
		local kind = self._eggRetrieval:TryTransition(eggPickupDistance)

		if kind == nil then
			local moveTarget = self._eggRetrieval:GetMoveTarget()
			assert(moveTarget ~= nil, "Pending guard retrieval requires a movement target")

			if not self:_holdIfHitPaused(p) then
				self._humanoid.WalkSpeed = self:_getReturnWalkSpeed()
				self:_ensureWalkAnimation(p)
				self:_moveTo(moveTarget)
			end

			return nil
		else
			assert(currentEggUid ~= nil, "Guard retrieval transition requires an egg UID")
			local v3 = {
				AreaId = self._areaId,
				EggUid = currentEggUid,
				Kind = kind
			}

			if kind == "Deposited" then
				if self._eggRetrieval:HasPending() then
					self:_enterEggRetrievalState(p)
					return v3
				end

				if not self:HasStolenEggs() then
					self:_enterReturnHomeState(p)
					return v3
				end

				self:_enterChaseState(p)
				self:_updateChase(p)
				return v3
			else
				local moveTarget = self._eggRetrieval:GetMoveTarget()
				assert(moveTarget ~= nil, "Attached guard retrieval egg requires a home movement target")

				if not self:_holdIfHitPaused(p) then
					self._humanoid.WalkSpeed = self:_getReturnWalkSpeed()
					self:_ensureWalkAnimation(p)
					self:_moveTo(moveTarget)
				end

				return v3
			end
		end
	else
		if self:HasStolenEggs() then
			self:_enterChaseState(p)
			self:_updateChase(p)
		else
			self:_enterReturnHomeState(p)
		end

		return nil
	end
end

function GuardComponent:_enterReturnHomeState(p: number)
	if self._eggRetrieval:HasPending() then
		self:_enterEggRetrievalState(p)
		return
	end

	self:_setState("ReturningHome")
	self._guardModel:SetAttribute("GuardState", "ReturningHome")
	self:_setTarget(nil)
	self:_cancelSleepTurn()

	if not self._serverOwnsPhysics or self._guardModel:GetAttribute("Hidden") ~= true then
		self._root.Anchored = false
	end

	if self:_isHitPaused(p) then
		self._humanoid.WalkSpeed = 0
		self:_stopMovement()
		self._presentation:StopWalkAnimation()
		self._presentation:EnsureIdleAnimation()
		self._presentation:StopFootstepSound()
	else
		self._humanoid.WalkSpeed = self:_getReturnWalkSpeed()
		self:_moveTo(self._homeCFrame.Position)
	end
end

function GuardComponent:_updateChase(lastTargetRefresh: number)
	if self._eggRetrieval:HasPending() then
		self:_enterEggRetrievalState(lastTargetRefresh)
		return
	end

	if not self:HasStolenEggs() then
		self:_enterReturnHomeState(lastTargetRefresh)
		return
	end

	local _targetPlayer = self._targetPlayer
	local v2, v3, v4

	if not (_targetPlayer == nil or self._stolenEggUidByPlayer[_targetPlayer] == nil) then
		v2, v3 = self:_resolvePlayerTarget(_targetPlayer)
		v4 = self._stolenEggUidByPlayer[_targetPlayer]
	end

	if v2 == nil or v3 == nil or lastTargetRefresh - self._lastTargetRefresh >= 0.3 then
		_targetPlayer, v2, v3, v4 = self:_chooseTargetPlayer()
		self._lastTargetRefresh = lastTargetRefresh
	end

	if _targetPlayer == nil or v2 == nil or v3 == nil then
		self:_setTarget(nil)
		self:_enterReturnHomeState(lastTargetRefresh)
	else
		self:_setTarget(_targetPlayer)

		if GuardDistance.XZ(self._root.Position, v2.Position) <= GuardChasePolicy.ResolveHitDistance(self._config.HitDistance) then
			self:_attemptAttack(_targetPlayer, v2, v3, v4, lastTargetRefresh)
			return
		end

		local _getChaseWalkSpeed = self:_getChaseWalkSpeed(GuardDistance.XZ(self._root.Position, v2.Position))
		self._humanoid.WalkSpeed = _getChaseWalkSpeed
		self:_ensureWalkAnimation(lastTargetRefresh)
		self:_moveThrough(v2.Position)
	end
end

function GuardComponent:_updateReturnHome(p: number)
	if self._eggRetrieval:HasPending() then
		self:_enterEggRetrievalState(p)
		return
	end

	if self:HasStolenEggs() then
		self:_enterChaseState(p)
		return
	end

	if self._sleepTurnConnection ~= nil or self:_updateSleepTurn(p) then
		return
	end

	if (self._root.Position - self._homeCFrame.Position).Magnitude <= GuardReturnHomeDistanceResolver.Resolve(self._areaId) then
		self:_beginSleepTurn(p)
	elseif self:_isHitPaused(p) then
		self._humanoid.WalkSpeed = 0
		self:_stopMovement()
		self._presentation:StopWalkAnimation()
		self._presentation:EnsureIdleAnimation()
		self._presentation:StopFootstepSound()
	else
		self._humanoid.WalkSpeed = self:_getReturnWalkSpeed()
		self:_ensureWalkAnimation(p)
		self:_moveTo(self._homeCFrame.Position)
	end
end

function GuardComponent:_beginSleepTurn(sleepTurnStartTime: number)
	t.strict(t.number)(sleepTurnStartTime)
	self._sleepTurnFromCFrame = self._root.CFrame
	self._sleepTurnStartTime = sleepTurnStartTime

	if self._sleepTurnConnection == nil then
		self._sleepTurnConnection = RunService.Heartbeat:Connect(function()
			self:_updateSleepTurn(os.clock())
		end)
	end

	self._humanoid.WalkSpeed = 0
	self:_stopMovement()
	self._presentation:StopWalkAnimation()
	self._presentation:EnsureIdleAnimation()
	self._presentation:StopFootstepSound()
	self:_updateSleepTurn(sleepTurnStartTime)
end

function GuardComponent:_cancelSleepTurn()
	local _sleepTurnConnection = self._sleepTurnConnection

	if _sleepTurnConnection ~= nil then
		self._sleepTurnConnection = nil
		_sleepTurnConnection:Disconnect()
	end

	self._sleepTurnFromCFrame = nil
	self._sleepTurnStartTime = 0
end

function GuardComponent:_updateSleepTurn(p: number)
	t.strict(t.number)(p)
	local _sleepTurnFromCFrame = self._sleepTurnFromCFrame

	if _sleepTurnFromCFrame == nil then
		return false
	end

	if self:HasStolenEggs() or self._eggRetrieval:HasPending() then
		self:_cancelSleepTurn()
		return false
	end

	local v2 = math.clamp((p - self._sleepTurnStartTime) / 0.3, 0, 1)
	local vector2 = Vector3.new(self._homeCFrame.Position.X, self._root.Position.Y, self._homeCFrame.Position.Z)
	local v3 = CFrame.new(vector2) * _sleepTurnFromCFrame.Rotation
	local v4 = CFrame.new(vector2) * self._homeCFrame.Rotation
	self._guardModel:PivotTo(v3:Lerp(v4, v2))

	if v2 >= 1 then
		self:_enterSleepState()
	end

	return true
end

function GuardComponent:_updateMovementRecovery(p: number)
	t.strict(t.number)(p)
	local v2

	if self._currentMoveTo == nil or self._state ~= "Chasing" and self._state ~= "ReturningHome" and self._state ~= "RetrievingEgg" then
		v2 = false
	else
		v2 = not self:_isHitPaused(p)
	end

	if self._movementRecovery:Step(p, v2, self._state == "ReturningHome") then
		return self:_recoverToHome()
	end

	return nil
end

function GuardComponent:_recoverToHome()
	self:_stopMovement()

	if not self._eggRetrieval:HasPending() then
		self:_enterSleepState()
		return nil
	end

	self._guardModel:PivotTo(self._homeCFrame)
	self:_enterEggRetrievalState(os.clock())
	return self:_updateEggRetrieval(os.clock())
end

function GuardComponent:_chooseTargetPlayer()
	local v2 = -1e999
	local v3 = 1e999
	local v4 = nil
	local v5 = nil
	local v6 = nil
	local v7 = nil

	for k, v8 in pairs(self._stolenPlayerByEggUid) do
		if not (v8 ~= nil and table.find(Players:GetPlayers(), v8)) then
			continue
		end

		local _resolvePlayerTarget, v9 = self:_resolvePlayerTarget(v8)

		if not (_resolvePlayerTarget ~= nil and v9 ~= nil) then
			continue
		end

		local v10 = self._stolenPriorityByEggUid[k] or 0
		local magnitude = (self._root.Position - _resolvePlayerTarget.Position).Magnitude

		if not (v2 < v10 or v10 == v2 and magnitude < v3) then
			continue
		end

		v7 = k
		v6 = v9
		v5 = _resolvePlayerTarget
		v4 = v8
		v3 = magnitude
		v2 = v10
	end

	return v4, v5, v6, v7
end

function GuardComponent:_refreshWakeTarget()
	local _chooseTargetPlayer = self:_chooseTargetPlayer()
	local v2 = _chooseTargetPlayer == nil and "" or tostring(_chooseTargetPlayer.UserId)

	if self._guardModel:GetAttribute("WakeTargetPlayer") == v2 then
		return
	end

	self._guardModel:SetAttribute("WakeTargetPlayer", v2)
end

function GuardComponent:_resolvePlayerTarget(p2)
	if not (self._targetResolver(p2) and Player.FindCharacter(p2) ~= nil) then
		return nil, nil
	end

	local part = Player.FindRootPart(p2)
	local humanoid = Player.FindHumanoid(p2)

	if part == nil or humanoid == nil then
		return nil, nil
	end

	assert(part:IsA("BasePart"), (`{part:GetFullName()} must be a BasePart`))

	if humanoid.Health <= 0 then
		return nil, nil
	end

	return part, humanoid
end

function GuardComponent:_attemptAttack(player, playerRoot, playerHumanoid, eggUid: string?, lastAttackTime: number)
	t.strict(t.instanceIsA("Player"))(player)
	t.strict(t.instanceIsA("BasePart"))(playerRoot)
	t.strict(t.instanceIsA("Humanoid"))(playerHumanoid)
	t.strict(t.optional(t.string))(eggUid)
	t.strict(t.number)(lastAttackTime)

	if lastAttackTime < self._attackResumeTime or lastAttackTime < self._ragdollEndTime or lastAttackTime - self._lastAttackTime < guardMovement.ATTACK_MIN_INTERVAL then
		return
	end

	self._lastAttackTime = lastAttackTime
	self._currentMoveTo = nil
	self._movementRecovery:Reset()
	local v2 = self._presentation:PlayHit()
	local ATTACK_MIN_INTERVAL = guardMovement.ATTACK_MIN_INTERVAL

	if v2 > 0 then
		ATTACK_MIN_INTERVAL = math.max(ATTACK_MIN_INTERVAL, v2)
	end

	self._walkResumeTime = lastAttackTime + ATTACK_MIN_INTERVAL
	self._attackResumeTime = math.max(self._attackResumeTime, lastAttackTime + ATTACK_MIN_INTERVAL)
	self._attackHandler({
		AreaId = self._areaId,
		Bounds = self._bounds,
		EggUid = eggUid,
		GuardHomePosition = self._homeCFrame.Position,
		GuardModel = self._guardModel,
		GuardRoot = self._root,
		GuardWalkSpeed = self._config.WalkSpeed,
		Player = player,
		PlayerHumanoid = playerHumanoid,
		PlayerRoot = playerRoot
	})
end

function GuardComponent:_moveTo(vector2: Vector3)
	t.strict(t.Vector3)(vector2)
	local vector3 = Vector3.new(vector2.X, self._root.Position.Y, vector2.Z)
	self._currentMoveTo = vector3
	self._humanoid:MoveTo(vector3)
end

function GuardComponent:_moveThrough(vector2: Vector3)
	t.strict(t.Vector3)(vector2)
	self:_moveTo(vector2 + Vector3.new(vector2.X - self._root.Position.X, 0, vector2.Z - self._root.Position.Z).Unit * 100)
end

function GuardComponent:_stopMovement()
	self._currentMoveTo = nil
	self._movementRecovery:Reset()
	self._humanoid:MoveTo(self._root.Position)
	self._humanoid:Move(createVector(0, 0, 0), false)
end

function GuardComponent:_setTarget(targetPlayer)
	if self._targetPlayer == targetPlayer then
		return
	end

	self._targetPlayer = targetPlayer

	if targetPlayer == nil then
		self._guardModel:SetAttribute("TargetPlayer", "")
		return
	end

	self._guardModel:SetAttribute("TargetPlayer", (tostring(targetPlayer.UserId)))
	self._presentation:PlayWake()
end

function GuardComponent:_ensureWalkAnimation(p: number)
	t.strict(t.number)(p)

	if p < self._walkResumeTime then
		self._presentation:EnsureIdleAnimation()
	else
		self._presentation:EnsureWalkAnimation(self._humanoid.WalkSpeed)
	end
end

function GuardComponent:_trySetNetworkOwner(lastNetworkOwnerRetry: number, flag: boolean)
	t.strict(t.number)(lastNetworkOwnerRetry)
	t.strict(t.boolean)(flag)

	if not self._serverOwnsPhysics or self._root.Anchored or not flag and lastNetworkOwnerRetry - self._lastNetworkOwnerRetry < 5 then
		return
	end

	self._lastNetworkOwnerRetry = lastNetworkOwnerRetry

	if self._root:CanSetNetworkOwnership() then
		self._root:SetNetworkOwner(nil)
	else
		v:AtWarning():Log((`Guard root network ownership cannot be set yet: {self._root:GetFullName()}`))
	end
end

function GuardComponent:Destroy()
	self:_setCreatorPaused(false, os.clock())
	self._eggRetrieval:Destroy()
	self:_cancelSleepTurn()
	self:_stopMovement()
	self._presentation:Destroy()
	table.clear(self._stolenEggUidByPlayer)
	table.clear(self._stolenPlayerByEggUid)
	table.clear(self._stolenPriorityByEggUid)
end

function GuardComponent:RegisterStolenEgg(p, p2: string, p3: number)
	t.strict(t.instanceIsA("Player"))(p)
	t.strict(t.string)(p2)
	t.strict(t.number)(p3)
	local v2 = self._stolenPlayerByEggUid[p2]

	if v2 == p then
		return false
	end

	if v2 ~= nil then
		error((`Stolen egg "{p2}" is already registered to {v2.Name}`))
	end

	local v3 = self._stolenEggUidByPlayer[p]

	if v3 ~= nil then
		self._stolenPlayerByEggUid[v3] = nil
		self._stolenPriorityByEggUid[v3] = nil
	end

	self._stolenPlayerByEggUid[p2] = p
	self._stolenEggUidByPlayer[p] = p2
	self._stolenPriorityByEggUid[p2] = p3

	if not self._enabled then
		return true
	end

	local now = os.clock()

	if self._eggRetrieval:HasPending() then
		if self._state == "Sleeping" then
			self:_enterWakingState(now)
		end
	elseif self._state == "Sleeping" or self._state == "Waking" then
		self:_enterWakingState(now)
	else
		self:_enterChaseState(now)
		self:_updateChase(now)
	end

	return true
end

function GuardComponent:RegisterDroppedEgg(p)
	t.strict(t.table)(p)

	if not self._eggRetrieval:Register(p) then
		return false
	end

	if not self._enabled then
		return true
	end

	local now = os.clock()

	if self._state == "Sleeping" then
		self:_enterWakingState(now)
	elseif self._state ~= "Waking" then
		self:_enterEggRetrievalState(now)
	end

	return true
end

function GuardComponent:ClearDroppedEgg(p: string)
	t.strict(t.string)(p)

	if not self._eggRetrieval:Clear(p) then
		return false
	end

	if self._state ~= "RetrievingEgg" or self._eggRetrieval:HasPending() then
		return true
	end

	local now = os.clock()

	if self:HasStolenEggs() then
		self:_enterChaseState(now)
		self:_updateChase(now)
	else
		self:_enterReturnHomeState(now)
	end

	return true
end

function GuardComponent:IsDroppedEggAttached(p2: string)
	return self._eggRetrieval:IsAttached(p2)
end

function GuardComponent:ClearStolenEgg(p: string)
	t.strict(t.string)(p)
	local v2 = self._stolenPlayerByEggUid[p]

	if v2 == nil then
		return false
	end

	self._stolenPlayerByEggUid[p] = nil
	self._stolenPriorityByEggUid[p] = nil

	if self._stolenEggUidByPlayer[v2] == p then
		self._stolenEggUidByPlayer[v2] = nil
	end

	if self._targetPlayer == v2 then
		self:_setTarget(nil)
	end

	if self:HasStolenEggs() or self._eggRetrieval:HasPending() then
		return true
	end

	if self._state == "Waking" or self._state == "Sleeping" then
		self:_enterSleepState()
	else
		self:_enterReturnHomeState(os.clock())
	end

	return true
end

function GuardComponent:ClearPlayer(p)
	t.strict(t.instanceIsA("Player"))(p)
	local v2 = self._stolenEggUidByPlayer[p]

	if v2 ~= nil then
		self._stolenEggUidByPlayer[p] = nil
		self._stolenPlayerByEggUid[v2] = nil
		self._stolenPriorityByEggUid[v2] = nil
	end

	if self._targetPlayer == p then
		self:_setTarget(nil)
	end

	if not self:HasStolenEggs() then
		if self._eggRetrieval:HasPending() then
			return
		end

		if self._state == "Waking" or self._state == "Sleeping" then
			self:_enterSleepState()
		else
			self:_enterReturnHomeState(os.clock())
		end
	end
end

function GuardComponent:HasStolenEggs()
	return next(self._stolenPlayerByEggUid) ~= nil
end

function GuardComponent:IsEnabled()
	return self._enabled
end

function GuardComponent:SetEnabled(enabled: boolean)
	t.strict(t.boolean)(enabled)

	if self._enabled == enabled then
		return
	end

	self._enabled = enabled

	if not enabled then
		self:_setCreatorPaused(false, os.clock())
		self:_enterSleepState()
	end
end

function GuardComponent:_setCreatorPaused(flag: boolean, lastTargetRefresh: number)
	local _creatorPause = self._creatorPause

	if flag then
		if not _creatorPause then
			_creatorPause = {
				StartedAt = lastTargetRefresh,
				Anchored = self._root.Anchored,
				AutoRotate = self._humanoid.AutoRotate,
				WalkSpeed = self._humanoid.WalkSpeed,
				Tracks = {}
			}
			self._creatorPause = _creatorPause
			self:_cancelSleepTurn()
			self:_stopMovement()
			self._presentation:StopFootstepSound()
			self._guardModel:SetAttribute("CreatorPursuitPaused", true)
		end

		self._root.Anchored = true
		self._root.AssemblyLinearVelocity = createVector(0, 0, 0)
		self._root.AssemblyAngularVelocity = createVector(0, 0, 0)
		self._humanoid.AutoRotate = false
		self._humanoid.WalkSpeed = 0
		local animator = self._guardModel:FindFirstChildWhichIsA("Animator", true)

		if animator then
			for _, v2 in animator:GetPlayingAnimationTracks() do
				if _creatorPause.Tracks[v2] == nil then
					_creatorPause.Tracks[v2] = v2.Speed
				end

				v2:AdjustSpeed(0)
			end
		end
	elseif _creatorPause then
		self._creatorPause = nil
		self._guardModel:SetAttribute("CreatorPursuitPaused", nil)
		self._root.Anchored = _creatorPause.Anchored or self._serverOwnsPhysics and self._guardModel:GetAttribute("Hidden") == true
		self._humanoid.AutoRotate = _creatorPause.AutoRotate
		self._humanoid.WalkSpeed = _creatorPause.WalkSpeed

		for k, track in _creatorPause.Tracks do
			k:AdjustSpeed(track)
		end

		local v2 = lastTargetRefresh - _creatorPause.StartedAt
		self._wakingStartedAt += v2
		self._walkResumeTime += v2
		self._attackResumeTime += v2
		self._lastAttackTime += v2
		self._lastTargetRefresh = lastTargetRefresh
		self._movementRecovery:Reset()
		self:_trySetNetworkOwner(lastTargetRefresh, true)
	end
end

function GuardComponent:Step(p: number)
	t.strict(t.number)(p)

	if not self._enabled then
		return nil
	end

	local _targetPlayer = self._targetPlayer

	if _targetPlayer == nil and self:HasStolenEggs() then
		_targetPlayer = self:_chooseTargetPlayer()
	end

	local v2

	if _targetPlayer == nil or self._stolenEggUidByPlayer[_targetPlayer] == nil or self:_resolvePlayerTarget(_targetPlayer) == nil then
		v2 = false
	else
		v2 = _targetPlayer:GetAttribute("CreatorPauseGuard_all") == true or _targetPlayer:GetAttribute("CreatorPauseGuard_" .. self._areaId) == true
	end

	self:_setCreatorPaused(v2, p)

	if v2 then
		return nil
	end

	if self._movementRecovery:ShouldRecoverFromFall() then
		return self:_recoverToHome()
	end

	self:_trySetNetworkOwner(p, false)

	if self._state ~= "Waking" and self._state ~= "RetrievingEgg" and self._eggRetrieval:HasPending() then
		self:_enterEggRetrievalState(p)
	end

	local v3 = nil

	if self._state == "Sleeping" then
		if self:HasStolenEggs() then
			self:_enterWakingState(p)
		end
	elseif self._state == "Waking" then
		self:_updateWaking(p)
	elseif self._state == "Chasing" then
		self:_updateChase(p)
	elseif self._state == "ReturningHome" then
		self:_updateReturnHome(p)
	elseif self._state == "RetrievingEgg" then
		v3 = self:_updateEggRetrieval(p)
	end

	self._presentation:UpdateAfterWake(p, self._state == "Chasing")

	if v3 == nil then
		return self:_updateMovementRecovery(p)
	end

	return v3
end

return GuardComponent