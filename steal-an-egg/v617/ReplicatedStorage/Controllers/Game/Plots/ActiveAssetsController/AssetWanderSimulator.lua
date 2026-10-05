local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetItem = require(ReplicatedStorage.Shared.Types.AssetItem)
local Assets = require(ReplicatedStorage.Data.Assets)
local personalities = Assets.Personalities
local Log = require(ReplicatedStorage.Packages.Log)
require(ReplicatedStorage.Data.Assets)
local t = require(ReplicatedStorage.Packages.t)
local AssetMutationWalkSpeed = require(script.Parent.AssetMutationWalkSpeed)
local AssetPersonalityMotion = require(script.Parent.AssetPersonalityMotion)
local AssetRetreatMotion = require(script.Parent.AssetRetreatMotion)
local AssetWanderArea = require(script.Parent.AssetWanderArea)
local AssetWanderMotion = require(script.Parent.AssetWanderMotion)
local v = Log.new()
local AssetWanderSimulator = {}
AssetWanderSimulator.__index = AssetWanderSimulator
AssetWanderSimulator.__class = "AssetWanderSimulator"

function AssetWanderSimulator.new(p: number, owner, assetArea, itemData, flag: boolean, p2: number, p3: number)
	t.strict(t.number)(p)
	t.strict(t.instanceIsA("Player"))(owner)
	t.strict(t.instanceIsA("BasePart"))(assetArea)
	assert(AssetItem.AssetItemData(itemData), "Invalid asset item data")
	t.strict(t.boolean)(flag)
	t.strict(t.number)(p2)
	t.strict(t.number)(p3)
	local random = Random.new(p)
	local localPlayer = Players.LocalPlayer
	assert(localPlayer ~= nil, "Asset wander simulator requires a local player")
	local config = personalities.GetConfig(itemData.Personality)
	local self = setmetatable({}, AssetWanderSimulator)
	self._random = random
	self._owner = owner
	self._localPlayer = localPlayer
	self._assetArea = assetArea
	self._itemData = itemData
	self._config = config
	self._greetingOrbitRadius = math.max(p2, 2.5)
	self._jumpHeight = math.min(math.max(p3, 1) * 2, 20)
	self._destination = assetArea.Position
	self._idleRemaining = 0
	self._idleAnchorCFrame = nil
	self._idleElapsed = 0
	self._walkSpeed = self:_rollWalkSpeed()
	self._mode = "Destination"
	self._phase = "Normal"
	self._greetRemaining = 0
	self._randomOrbitInsideSeconds = 0
	self._farSeconds = 0
	self._farRequiredSeconds = random:NextNumber(105, 180)
	self._joinGreetingPending = true
	self._finishJumpsRemaining = 0
	self._finishJumpCooldown = 0
	self._returnGreetingHoldRemaining = 0
	self._returnGreetingJumpsRemaining = 0
	self._returnGreetingJumpCooldown = 0
	self._returnGreetingOwnerOffset = nil
	self._affectionInsideSeconds = 0
	self._affectionHoldRemaining = 0
	self._affectionJumpsRemaining = 0
	self._affectionJumpCooldown = 0
	self._affectionOwnerOffset = nil
	self._loyalOwnerOffset = AssetPersonalityMotion.RandomOwnerOffset(assetArea, random, self._greetingOrbitRadius)
	self._pendingBubbleText = nil
	self._jumpRemaining = 0
	self._jumpElapsed = 0
	self._spinYaw = 0
	self._spinAppliedYaw = 0
	self._curveAngle = random:NextNumber(-3.141592653589793, 3.141592653589793)
	self._curveRotationSpeed = random:NextNumber(-0.8, 0.8)
	self._nextCurveChangeSeconds = random:NextNumber(5, 10)
	self._curveChangeElapsed = 0
	self._retreatOwnerWasClose = false
	self._retreatActive = false
	self._lastOwnerPosition = nil
	self:_chooseNextDestination()

	if flag then
		self:_tryStartFirstPlacementGreeting()
	end

	v:AtDebug():Log((`Created asset wander simulator with seed {p}`))
	return self
end

function AssetWanderSimulator:_rollWalkSpeed()
	local movement = self._config.Movement
	return math.max(self._random:NextNumber(movement.WalkSpeedMin, movement.WalkSpeedMax), 4.5) * AssetMutationWalkSpeed.GetMultiplier(self._itemData)
end

function AssetWanderSimulator:_ownerRootPosition()
	return AssetPersonalityMotion.OwnerRootPosition(self._owner)
end

function AssetWanderSimulator:_distanceFromLocalPlayerToAreaCenter()
	return AssetPersonalityMotion.DistanceFromPlayerToAreaCenter(self._localPlayer, self._assetArea)
end

function AssetWanderSimulator:_chooseNextDestination()
	local _ownerRootPosition = self:_ownerRootPosition()
	local movement = self._config.Movement
	self._walkSpeed = self:_rollWalkSpeed()
	self._destination = AssetPersonalityMotion.ChooseDestination(
		self._assetArea,
		self._random,
		movement,
		_ownerRootPosition
	)
	self._mode = self._random:NextNumber() < movement.CurvedWanderChance and "Curve" or "Destination"
end

function AssetWanderSimulator:_tryRetreatFromOwner(vector: Vector3, vector2: Vector3)
	local retreat = self._config.Movement.Retreat

	if retreat == nil then
		self._retreatOwnerWasClose = false
		self._retreatActive = false
		return false
	elseif Vector3.new(vector.X - vector2.X, 0, vector.Z - vector2.Z).Magnitude <= retreat.TriggerDistance then
		if self._retreatActive then
			self._destination = AssetRetreatMotion.Destination(self._assetArea, self._random, retreat, vector2, vector)
			self._mode = "Destination"
			self._idleRemaining = 0
			self._idleAnchorCFrame = nil
		else
			if self._retreatOwnerWasClose then
				return false
			end

			self._retreatOwnerWasClose = true

			if not AssetPersonalityMotion.RollChance(self._random, retreat.Chance) then
				return false
			end

			self._retreatActive = true
			self._destination = AssetRetreatMotion.Destination(self._assetArea, self._random, retreat, vector2, vector)
			self._mode = "Destination"
			self._idleRemaining = 0
			self._idleAnchorCFrame = nil
			self._walkSpeed = self:_rollWalkSpeed()
		end

		return true
	else
		self._retreatOwnerWasClose = false
		self._retreatActive = false
		return false
	end
end

function AssetWanderSimulator:_beginIdle(idleAnchorCFrame: CFrame)
	local movement = self._config.Movement
	self._idleRemaining = self._random:NextNumber(movement.IdleSecondsMin, movement.IdleSecondsMax)
	self._idleAnchorCFrame = idleAnchorCFrame
	self._idleElapsed = 0
end

function AssetWanderSimulator:_stepIdle(p: number)
	local _idleAnchorCFrame = self._idleAnchorCFrame
	assert(_idleAnchorCFrame ~= nil, "Idle phase requires a stable anchor CFrame")
	local v2, idleRemaining, idleElapsed, v5 = AssetPersonalityMotion.StepIdle(
		p,
		self._idleRemaining,
		self._idleElapsed,
		_idleAnchorCFrame,
		self._config.Movement.IdleTremble
	)
	self._idleRemaining = idleRemaining
	self._idleElapsed = idleElapsed

	if v5 then
		self._idleAnchorCFrame = nil
		self._idleElapsed = 0
	end

	return self:_applyJump(p, v2)
end

function AssetWanderSimulator:_tryAmbientJump(p: number)
	local movement = self._config.Movement

	if AssetPersonalityMotion.ShouldStartAmbientJump(
		self._random,
		movement.AmbientJumpRatePerSecond,
		p,
		self._jumpRemaining > 0
	) then
		self:_startJump(movement.AmbientSpinJumpChance)
	end
end

function AssetWanderSimulator:_startJump(spinJumpChance: number?)
	if self._jumpRemaining > 0 then
		return
	end

	if spinJumpChance == nil then
		spinJumpChance = self._config.Greeting.SpinJumpChance
	end

	self._jumpRemaining = 0.45
	self._jumpElapsed = 0
	self._spinAppliedYaw = 0
	local v2 = self._random:NextNumber() < 0.5 and -1 or 1
	self._spinYaw = not (self._random:NextNumber() < spinJumpChance) and 0 or 6.283185307179586 * v2
end

function AssetWanderSimulator:_resetGreetingFinish()
	self._finishJumpsRemaining = 0
	self._finishJumpCooldown = 0
end

function AssetWanderSimulator:_resetReturnGreeting()
	self._returnGreetingHoldRemaining = 0
	self._returnGreetingJumpsRemaining = 0
	self._returnGreetingJumpCooldown = 0
	self._returnGreetingOwnerOffset = nil
end

function AssetWanderSimulator:_resetAffection()
	self._affectionHoldRemaining = 0
	self._affectionJumpsRemaining = 0
	self._affectionJumpCooldown = 0
	self._affectionOwnerOffset = nil
	self._pendingBubbleText = nil
end

function AssetWanderSimulator:_popBubbleText()
	local _pendingBubbleText = self._pendingBubbleText
	self._pendingBubbleText = nil
	return _pendingBubbleText
end

function AssetWanderSimulator:_beginGreetingFinish()
	self._phase = "GreetingFinish"
	self._greetRemaining = 1.2
	self._finishJumpsRemaining = 2
	self._finishJumpCooldown = 0
	self._lastOwnerPosition = nil
end

function AssetWanderSimulator:_beginGreetingOrbit(flag: boolean)
	t.strict(t.boolean)(flag)
	local greeting = self._config.Greeting
	self._phase = "GreetingOrbit"
	self._greetRemaining = math.min(greeting.DurationSeconds, 3)
	self._randomOrbitInsideSeconds = 0
	self._idleRemaining = 0
	self._lastOwnerPosition = nil
	self:_resetGreetingFinish()
	self:_resetReturnGreeting()
	self:_resetAffection()

	if flag then
		self._pendingBubbleText = AssetPersonalityMotion.RandomConfiguredText(
			self._random,
			greeting.Texts,
			self._config._id,
			"greeting"
		)
	end
end

function AssetWanderSimulator:_tryStartGreetingOrbit(p: number, flag: boolean)
	t.strict(t.boolean)(flag)
	local greeting = self._config.Greeting

	if p <= 0 or greeting.DurationSeconds <= 0 or not AssetPersonalityMotion.RollChance(self._random, p) then
		return false
	end

	self:_beginGreetingOrbit(flag)
	return true
end

function AssetWanderSimulator:_beginNormalGreeting(vector: Vector3, returnGreetingJumpsRemaining: number, p: number, flag: boolean)
	t.strict(t.boolean)(flag)
	local randomOwnerOffset = AssetPersonalityMotion.RandomOwnerOffset(
		self._assetArea,
		self._random,
		self._greetingOrbitRadius
	)
	self._phase = "ReturnGreetingApproach"
	self._returnGreetingOwnerOffset = randomOwnerOffset
	self._returnGreetingHoldRemaining = math.min(p, 20)
	self._returnGreetingJumpsRemaining = returnGreetingJumpsRemaining
	self._returnGreetingJumpCooldown = 0
	self._destination = AssetWanderArea.PointNearOwner(self._assetArea, vector, randomOwnerOffset)
	self._idleRemaining = 0
	self._walkSpeed = self:_rollWalkSpeed()
	self._lastOwnerPosition = nil
	self:_resetGreetingFinish()
	self:_resetAffection()

	if flag then
		self._pendingBubbleText = AssetPersonalityMotion.RandomConfiguredText(
			self._random,
			self._config.Greeting.Texts,
			self._config._id,
			"greeting"
		)
	end
end

function AssetWanderSimulator:_tryStartFirstPlacementGreeting()
	self._joinGreetingPending = false
	local greeting = self._config.Greeting

	if self:_tryStartGreetingOrbit(greeting.FirstPlacementChance, true) then
		return
	end

	local firstPlacementBubbleChance = greeting.FirstPlacementBubbleChance

	if firstPlacementBubbleChance ~= nil and firstPlacementBubbleChance > 0 and AssetPersonalityMotion.RollChance(
		self._random,
		firstPlacementBubbleChance
	) then
		self._pendingBubbleText = AssetPersonalityMotion.RandomConfiguredText(
			self._random,
			greeting.Texts,
			self._config._id,
			"greeting"
		)
		return
	end

	local _ownerRootPosition = self:_ownerRootPosition()

	if _ownerRootPosition == nil or not AssetPersonalityMotion.RollChance(
		self._random,
		greeting.FirstPlacementNormalChance
	) then
		return
	end

	local firstPlacementNormalJumpCount = greeting.FirstPlacementNormalJumpCount

	if firstPlacementNormalJumpCount <= 0 then
		return
	end

	self:_beginNormalGreeting(
		_ownerRootPosition,
		firstPlacementNormalJumpCount,
		0.6 * firstPlacementNormalJumpCount,
		true
	)
end

function AssetWanderSimulator:_tryStartReturnGreeting(vector: Vector3, flag: boolean)
	t.strict(t.boolean)(flag)
	local greeting = self._config.Greeting

	if greeting.Chance <= 0 or greeting.DurationSeconds <= 0 or not AssetPersonalityMotion.RollChance(
		self._random,
		greeting.Chance
	) or flag and self:_tryStartGreetingOrbit(greeting.ReturnOrbitChance, false) then
		return
	end

	self:_beginNormalGreeting(vector, greeting.ReturnNormalJumpCount, math.min(greeting.DurationSeconds, 20), false)
end

function AssetWanderSimulator:_beginAffection(vector: Vector3)
	local affection = self._config.Affection
	local randomOwnerOffset = AssetPersonalityMotion.RandomOwnerOffset(
		self._assetArea,
		self._random,
		self._greetingOrbitRadius
	)
	self._phase = "AffectionApproach"
	self._affectionOwnerOffset = randomOwnerOffset
	self._destination = AssetWanderArea.PointNearOwner(self._assetArea, vector, randomOwnerOffset)
	self._idleRemaining = 0
	self._walkSpeed = self:_rollWalkSpeed()
	self._affectionHoldRemaining = affection.DurationSeconds
	self._affectionJumpsRemaining = affection.JumpCount
	self._affectionJumpCooldown = 0
	self._pendingBubbleText = nil
	self._lastOwnerPosition = nil
	self:_resetGreetingFinish()
end

function AssetWanderSimulator:_updateAffectionTrigger(p: number, vector: Vector3?)
	if self._phase ~= "Normal" then
		return
	end

	local affection = self._config.Affection

	if not affection.Enabled or affection.IntervalSeconds <= 0 or vector == nil then
		self._affectionInsideSeconds = 0
		return
	end

	if not AssetWanderArea.IsPositionInside(self._assetArea, vector) then
		self._affectionInsideSeconds = 0
		return
	end

	self._affectionInsideSeconds += p

	if self._affectionInsideSeconds < affection.IntervalSeconds then
		return
	end

	self._affectionInsideSeconds = 0

	if AssetPersonalityMotion.RollChance(self._random, affection.Chance) then
		self:_beginAffection(vector)
	end
end

function AssetWanderSimulator:_updateOrbitGreetingTrigger(p: number, vector: Vector3?)
	if self._phase ~= "Normal" then
		return
	end

	local greeting = self._config.Greeting

	if greeting.RandomOrbitChance <= 0 or greeting.RandomOrbitIntervalSeconds <= 0 or greeting.DurationSeconds <= 0 or vector == nil then
		self._randomOrbitInsideSeconds = 0
		return
	end

	if not AssetWanderArea.IsPositionInside(self._assetArea, vector) then
		self._randomOrbitInsideSeconds = 0
		return
	end

	self._randomOrbitInsideSeconds += p

	if self._randomOrbitInsideSeconds < greeting.RandomOrbitIntervalSeconds then
		return
	end

	self._randomOrbitInsideSeconds = 0
	self:_tryStartGreetingOrbit(greeting.RandomOrbitChance, false)
end

function AssetWanderSimulator:_updateReturnGreeting(p: number)
	if self._phase ~= "Normal" then
		return
	end

	if self._joinGreetingPending then
		local _ownerRootPosition = self:_ownerRootPosition()

		if _ownerRootPosition == nil then
			return
		end

		self._joinGreetingPending = false
		self._farSeconds = 0
		self._farRequiredSeconds = self._random:NextNumber(105, 180)
		self:_tryStartReturnGreeting(
			_ownerRootPosition,
			AssetWanderArea.IsPositionInside(self._assetArea, _ownerRootPosition)
		)
	else
		local _distanceFromLocalPlayerToAreaCenter = self:_distanceFromLocalPlayerToAreaCenter()

		if _distanceFromLocalPlayerToAreaCenter == nil then
			return
		end

		if _distanceFromLocalPlayerToAreaCenter >= 200 then
			self._farSeconds += p
		elseif self._farSeconds >= self._farRequiredSeconds and _distanceFromLocalPlayerToAreaCenter <= 200 then
			self._farSeconds = 0
			self._farRequiredSeconds = self._random:NextNumber(105, 180)
			local _ownerRootPosition = self:_ownerRootPosition()

			if _ownerRootPosition ~= nil and AssetWanderArea.IsPositionInside(self._assetArea, _ownerRootPosition) then
				self:_tryStartReturnGreeting(_ownerRootPosition, true)
			end
		else
			self._farSeconds = 0
		end
	end
end

function AssetWanderSimulator:_updateGreeting(p: number)
	if self._phase ~= "GreetingOrbit" and self._phase ~= "GreetingFinish" then
		return
	end

	local _distanceFromLocalPlayerToAreaCenter = self:_distanceFromLocalPlayerToAreaCenter()

	if _distanceFromLocalPlayerToAreaCenter == nil or not (_distanceFromLocalPlayerToAreaCenter > 300) then
		self._greetRemaining = math.max(self._greetRemaining - p, 0)

		if self._phase == "GreetingOrbit" then
			if self._greetRemaining <= 0 then
				self:_beginGreetingFinish()
			elseif self._random:NextNumber() < self._config.Greeting.JumpChancePerSecond * p then
				self:_startJump()
			end
		else
			self._finishJumpCooldown = math.max(self._finishJumpCooldown - p, 0)

			if self._finishJumpsRemaining > 0 and self._finishJumpCooldown <= 0 then
				self:_startJump(0)
				self._finishJumpsRemaining -= 1
				self._finishJumpCooldown = 0.6
			end

			if self._finishJumpsRemaining <= 0 and self._jumpRemaining <= 0 and self._greetRemaining <= 0 then
				self._phase = "Normal"
				self:_resetGreetingFinish()
				self:_resetReturnGreeting()
				self:_resetAffection()
				self:_chooseNextDestination()
			end
		end
	else
		self._phase = "Normal"
		self._greetRemaining = 0
		self:_resetGreetingFinish()
		self:_resetReturnGreeting()
		self:_resetAffection()
		self:_chooseNextDestination()
	end
end

function AssetWanderSimulator:_stepReturnGreeting(p: number, cframe: CFrame, vector: Vector3)
	if self._phase == "ReturnGreetingApproach" then
		local _returnGreetingOwnerOffset = self._returnGreetingOwnerOffset
		assert(_returnGreetingOwnerOffset ~= nil, "Return greeting approach requires a stable owner offset")
		self._destination = AssetWanderArea.PointNearOwner(self._assetArea, vector, _returnGreetingOwnerOffset)
		local v2, v3, v4 = AssetWanderMotion.StepMoveToward(p, cframe, self._destination, self._walkSpeed)

		if Vector3.new(self._destination.X - v2.Position.X, 0, self._destination.Z - v2.Position.Z).Magnitude > 2.25 then
			local _applyJump, v5 = self:_applyJump(p, v2)
			return _applyJump, v3 or self._jumpRemaining > 0, v5, v4
		end

		self._phase = "ReturnGreetingHold"
		self._returnGreetingJumpCooldown = 0

		if self._returnGreetingJumpsRemaining > 0 then
			self:_startJump(0)
			self._returnGreetingJumpsRemaining -= 1
			self._returnGreetingJumpCooldown = 0.6
		end

		local _applyJump, v5 = self:_applyJump(p, (AssetWanderMotion.FaceOwnerCFrame(v2, vector, p, true)))
		return _applyJump, v3 or self._jumpRemaining > 0, v5, v4
	else
		self._returnGreetingHoldRemaining = math.max(self._returnGreetingHoldRemaining - p, 0)
		self._returnGreetingJumpCooldown = math.max(self._returnGreetingJumpCooldown - p, 0)

		if self._returnGreetingJumpsRemaining > 0 and self._returnGreetingJumpCooldown <= 0 then
			self:_startJump(0)
			self._returnGreetingJumpsRemaining -= 1
			self._returnGreetingJumpCooldown = 0.6
		end

		local _applyJump, v2 = self:_applyJump(p, (AssetWanderMotion.FaceOwnerCFrame(cframe, vector, p)))

		if self._returnGreetingHoldRemaining <= 0 and self._returnGreetingJumpsRemaining <= 0 and self._jumpRemaining <= 0 then
			self._phase = "Normal"
			self:_resetReturnGreeting()
			self:_chooseNextDestination()
		end

		return _applyJump, self._jumpRemaining > 0, v2, self._walkSpeed
	end
end

function AssetWanderSimulator:_stepAffection(p: number, cframe: CFrame, vector: Vector3)
	if self._phase == "AffectionApproach" then
		local _affectionOwnerOffset = self._affectionOwnerOffset
		assert(_affectionOwnerOffset ~= nil, "Affection approach requires a stable owner offset")
		self._destination = AssetWanderArea.PointNearOwner(self._assetArea, vector, _affectionOwnerOffset)
		local v2, v3, v4 = AssetWanderMotion.StepMoveToward(p, cframe, self._destination, self._walkSpeed)

		if Vector3.new(self._destination.X - v2.Position.X, 0, self._destination.Z - v2.Position.Z).Magnitude > 2.25 then
			local _applyJump, v5 = self:_applyJump(p, v2)
			return _applyJump, v3 or self._jumpRemaining > 0, v5, v4
		end

		self._phase = "AffectionHold"
		self._affectionJumpCooldown = 0.6
		self._pendingBubbleText = AssetPersonalityMotion.RandomConfiguredText(
			self._random,
			self._config.Affection.Texts,
			self._config._id,
			"affection"
		)

		if self._affectionJumpsRemaining > 0 then
			self:_startJump(0)
			self._affectionJumpsRemaining -= 1
		end

		local _applyJump, v5 = self:_applyJump(p, (AssetWanderMotion.FaceOwnerCFrame(v2, vector, p, true)))
		return _applyJump, v3 or self._jumpRemaining > 0, v5, v4
	else
		self._affectionHoldRemaining = math.max(self._affectionHoldRemaining - p, 0)
		self._affectionJumpCooldown = math.max(self._affectionJumpCooldown - p, 0)

		if self._affectionJumpsRemaining > 0 and self._affectionJumpCooldown <= 0 then
			self:_startJump(0)
			self._affectionJumpsRemaining -= 1
			self._affectionJumpCooldown = 0.6
		end

		local _applyJump, v2 = self:_applyJump(p, (AssetWanderMotion.FaceOwnerCFrame(cframe, vector, p)))

		if self._affectionHoldRemaining <= 0 and self._affectionJumpsRemaining <= 0 and self._jumpRemaining <= 0 then
			self._phase = "Normal"
			self:_resetAffection()
			self:_chooseNextDestination()
		end

		return _applyJump, self._jumpRemaining > 0, v2, self._walkSpeed
	end
end

function AssetWanderSimulator:_updateCurve(p: number, vector: Vector3)
	self._curveChangeElapsed += p

	if self._curveChangeElapsed >= self._nextCurveChangeSeconds then
		self._curveChangeElapsed = 0
		self._nextCurveChangeSeconds = self._random:NextNumber(5, 10)
		self._curveAngle = self._random:NextNumber(-3.141592653589793, 3.141592653589793)
		self._curveRotationSpeed = self._random:NextNumber(-0.8, 0.8)
	end

	self._curveAngle += self._curveRotationSpeed * p
	local v2 = vector + Vector3.new(math.cos(self._curveAngle), 0, (math.sin(self._curveAngle))) * 9
	self._destination = AssetWanderArea.ClampedPointToward(self._assetArea, v2)
end

function AssetWanderSimulator:_orbitGreetingCFrame(p: number, cframe: CFrame, vector: Vector3)
	local ownerMoveVector, lastOwnerPosition = AssetWanderMotion.OwnerMoveVector(p, vector, self._lastOwnerPosition)
	self._lastOwnerPosition = lastOwnerPosition
	return AssetWanderMotion.OrbitGreetingCFrame(
		self._assetArea,
		p,
		cframe,
		vector,
		ownerMoveVector,
		self._greetingOrbitRadius,
		22,
		0.75
	)
end

function AssetWanderSimulator:_applyJump(p: number, cframe: CFrame)
	if self._jumpRemaining <= 0 then
		return cframe, true
	end

	self._jumpRemaining = math.max(self._jumpRemaining - p, 0)
	self._jumpElapsed = math.min(self._jumpElapsed + p, 0.45)
	local v2 = self._jumpElapsed / 0.45
	local v3 = math.sin(v2 * 3.141592653589793) * self._jumpHeight
	local spinAppliedYaw = self._spinYaw == 0 and 0 or self._spinYaw * v2
	local v5 = spinAppliedYaw - self._spinAppliedYaw
	self._spinAppliedYaw = spinAppliedYaw
	local v6 = CFrame.new(cframe.Position + Vector3.new(0, v3, 0)) * cframe.Rotation

	if v5 ~= 0 then
		v6 *= CFrame.Angles(0, v5, 0)
	end

	if self._jumpRemaining <= 0 then
		self._spinAppliedYaw = 0
	end

	return v6, self._jumpRemaining <= 0
end

function AssetWanderSimulator:SetAssetArea(assetArea)
	t.strict(t.instanceIsA("BasePart"))(assetArea)
	local v2 = self._assetArea ~= assetArea
	self._assetArea = assetArea

	if v2 then
		self._loyalOwnerOffset = AssetPersonalityMotion.RandomOwnerOffset(
			assetArea,
			self._random,
			self._greetingOrbitRadius
		)
		local returnGreetingOwnerOffset

		if self._returnGreetingOwnerOffset ~= nil then
			returnGreetingOwnerOffset = AssetPersonalityMotion.RandomOwnerOffset(
				assetArea,
				self._random,
				self._greetingOrbitRadius
			)
		end

		self._returnGreetingOwnerOffset = returnGreetingOwnerOffset
		local affectionOwnerOffset

		if self._affectionOwnerOffset ~= nil then
			affectionOwnerOffset = AssetPersonalityMotion.RandomOwnerOffset(
				assetArea,
				self._random,
				self._greetingOrbitRadius
			)
		end

		self._affectionOwnerOffset = affectionOwnerOffset
	end

	self:_chooseNextDestination()
end

function AssetWanderSimulator:SetItemData(itemData, flag: boolean)
	assert(AssetItem.AssetItemData(itemData), "Invalid asset item data")
	t.strict(t.boolean)(flag)
	self._itemData = itemData
	self._config = personalities.GetConfig(itemData.Personality)

	if flag then
		self:_tryStartFirstPlacementGreeting()
	end
end

function AssetWanderSimulator:Step(p: number, cframe: CFrame)
	t.strict(t.number)(p)
	t.strict(t.CFrame)(cframe)
	self:_updateReturnGreeting(p)
	self:_updateGreeting(p)
	local position = cframe.Position
	local _ownerRootPosition = self:_ownerRootPosition()

	if self._phase ~= "Normal" and _ownerRootPosition == nil then
		self._phase = "Normal"
		self._greetRemaining = 0
		self:_resetGreetingFinish()
		self:_resetReturnGreeting()
		self:_resetAffection()
		self:_chooseNextDestination()
	end

	self:_updateAffectionTrigger(p, _ownerRootPosition)
	self:_updateOrbitGreetingTrigger(p, _ownerRootPosition)
	local v2

	if self._phase == "Normal" and _ownerRootPosition ~= nil then
		v2 = self:_tryRetreatFromOwner(position, _ownerRootPosition)
	else
		v2 = false
	end

	if self._phase == "Normal" then
		self:_tryAmbientJump(p)
	end

	if self._idleRemaining > 0 and self._phase == "Normal" then
		local _stepIdle, v3 = self:_stepIdle(p)
		return _stepIdle, self._jumpRemaining > 0, v3, 0, false, self:_popBubbleText()
	end

	if self._phase == "GreetingOrbit" and _ownerRootPosition ~= nil then
		local _orbitGreetingCFrame, v3, v4 = self:_orbitGreetingCFrame(p, cframe, _ownerRootPosition)
		local _applyJump, v5 = self:_applyJump(p, _orbitGreetingCFrame)
		return _applyJump, v3 or self._jumpRemaining > 0, v5, v4, true, self:_popBubbleText()
	else
		if self._phase == "GreetingFinish" and _ownerRootPosition ~= nil then
			local _applyJump, v3 = self:_applyJump(
				p,
				(AssetWanderMotion.FaceOwnerCFrame(cframe, _ownerRootPosition, p))
			)
			return _applyJump, self._jumpRemaining > 0, v3, self._walkSpeed, true, self:_popBubbleText()
		end

		if (self._phase == "ReturnGreetingApproach" or self._phase == "ReturnGreetingHold") and _ownerRootPosition ~= nil then
			local _stepReturnGreeting, v3, v4, v5 = self:_stepReturnGreeting(p, cframe, _ownerRootPosition)
			return _stepReturnGreeting, v3, v4, v5, false, self:_popBubbleText()
		end

		if (self._phase == "AffectionApproach" or self._phase == "AffectionHold") and _ownerRootPosition ~= nil then
			local _stepAffection, v3, v4, v5 = self:_stepAffection(p, cframe, _ownerRootPosition)
			return _stepAffection, v3, v4, v5, false, self:_popBubbleText()
		end

		if self._config.Movement.FollowOwnerInPen and _ownerRootPosition ~= nil and AssetWanderArea.IsPositionInside(
			self._assetArea,
			_ownerRootPosition
		) then
			local v3, v4, v5 = AssetWanderMotion.StepFollowOwner(
				self._assetArea,
				p,
				cframe,
				_ownerRootPosition,
				self._loyalOwnerOffset,
				self._walkSpeed,
				2.25
			)
			local _applyJump, v6 = self:_applyJump(p, v3)
			return _applyJump, v4 or self._jumpRemaining > 0, v6, v5, false, self:_popBubbleText()
		else
			if self._mode == "Curve" then
				self:_updateCurve(p, cframe.Position)
			end

			local _destination = self._destination
			local v3 = _destination - position

			if Vector3.new(v3.X, 0, v3.Z).Magnitude <= 0.35 and not v2 then
				self:_beginIdle(cframe)
				self:_chooseNextDestination()
				local _applyJump, v4 = self:_applyJump(p, cframe)
				return _applyJump, self._jumpRemaining > 0, v4, self._walkSpeed, false, self:_popBubbleText()
			else
				local _walkSpeed = self._walkSpeed

				if self._random:NextNumber() < self._config.Movement.BurstChance * p then
					_walkSpeed = self._config.Movement.WalkSpeedMax * 1.25 * AssetMutationWalkSpeed.GetMultiplier(self._itemData)
					self:_startJump()
				end

				local v4, v5, v6 = AssetWanderMotion.StepMoveToward(p, cframe, _destination, _walkSpeed)
				local _applyJump, v7 = self:_applyJump(p, v4)
				return _applyJump, v5 or self._jumpRemaining > 0, v7, v6, false, self:_popBubbleText()
			end
		end
	end
end

return AssetWanderSimulator