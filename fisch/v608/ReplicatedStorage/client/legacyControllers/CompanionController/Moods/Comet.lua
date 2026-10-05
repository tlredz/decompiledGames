local createVector = vector.create
local TweenService = game:GetService("TweenService")
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local companions = require(ReplicatedStorage.shared.modules.library.companions)
local v = {
	HeadRest = {
		Chance = 20,
		Interval = 15
	},
	SpinBurst = {
		Chance = 5,
		Interval = 20
	},
	Dance = {
		Chance = 15,
		Interval = 25
	},
	Wander = {
		Chance = 30,
		Interval = 12
	}
}
local v2 = {
	"Fly",
	"Swim",
	"Run",
	"Hover",
	"Idle"
}
local v3 = { "Sleep", "Hover", "Idle" }
local v4 = {
	"Hover",
	"Idle",
	"Fly",
	"Swim"
}
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function smoothstep(p: number)
	return p * p * (3 - p * 2)
end

local function evalArc(vector2: Vector3, vector3: Vector3, p: number, p2: number)
	return vector2:Lerp(vector3, p2) + Vector3.new(0, p * 4 * p2 * (1 - p2), 0)
end

local Comet = {}
Comet.__index = Comet
setmetatable(Comet, CompanionBehavior)

function Comet.new(p)
	local v5 = CompanionBehavior.new(p)
	setmetatable(v5, Comet)
	v5:RegisterMoods(v)
	v5.moodStartTime = 0
	v5.headRestPhaseGen = 0
	v5.resting = false
	v5.restElapsed = 0
	v5.restDuration = 0
	v5.restStartOwnerPos = nil
	v5.restAttachment = nil
	v5.restConstraints = nil
	v5._headRestEnded = false
	v5.departing = false
	v5.spinning = false
	v5.spinElapsed = 0
	v5.spinStartYaw = 0
	v5._spinEnded = false
	v5.danceActive = false
	v5.dancePhaseGen = 0
	v5.danceAngle = 0
	v5.danceRadius = 5
	v5.danceTargetRadius = 5
	v5.danceYOffset = 0
	v5.danceSpin = 0
	v5.danceDirection = 1
	v5.danceBobPhase = 0
	v5.danceElapsed = 0
	v5._danceEnded = false
	v5.wanderPhaseGen = 0
	v5.wandering = false
	v5.wanderLegsLeft = 0
	v5.wanderSpots = {}
	v5.wanderSpotIndex = 0
	v5._wanderEnded = false
	v5.flight = nil
	v5.starParts = nil
	v5.starPartsHidden = false
	v5.companion.AlwaysTickUpdate = true
	v5.trove:Add(function()
		v5:_DetachFromHead()
		v5:_SetStarPartsHidden(false, true)
	end)
	v5:SetStateData(v5.companion.StateData)
	return v5
end

function Comet:_GetStarParts()
	if self.starParts then
		return self.starParts
	end

	local result = {}
	local model = self.companion.Model

	if model then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") and part:GetAttribute("Hide") == true then
				table.insert(result, {
					Part = part,
					Transparency = part.Transparency,
					Tween = nil
				})
			end
		end
	end

	self.starParts = result
	return result
end

function Comet:_SetStarPartsHidden(starPartsHidden: boolean, flag: boolean?)
	if self.starPartsHidden == starPartsHidden then
		return
	end

	self.starPartsHidden = starPartsHidden

	for _, v5 in ipairs(self:_GetStarParts()) do
		if not v5.Part.Parent then
			continue
		end

		if v5.Tween then
			v5.Tween:Cancel()
			v5.Tween = nil
		end

		local transparency = starPartsHidden and 1 or v5.Transparency

		if flag then
			v5.Part.Transparency = transparency
		else
			local tween = TweenService:Create(v5.Part, tweenInfo, {
				Transparency = transparency
			})
			v5.Tween = tween
			tween:Play()
		end
	end
end

function Comet:SetStateData(p)
	self:_SetStarPartsHidden(p ~= nil and p.StarBuff == true)
end

function Comet:_PlayFirstAvailable(list)
	for _, v5 in ipairs(list) do
		if not self.companion.Animations[v5] then
			continue
		end

		self:PlayAnimation(v5)
		break
	end
end

function Comet.GetWalkAnimation(p)
	for _, v5 in ipairs(v2) do
		if p.companion.Animations[v5] then
			return v5
		end
	end

	return "Idle"
end

function Comet:_GetHead()
	return self:GetOwnerBodyPart("Head")
end

function Comet:_GetOwnerRootPosition()
	local ownerBodyPart = self:GetOwnerBodyPart("HumanoidRootPart")

	if ownerBodyPart then
		return ownerBodyPart.Position
	end

	return nil
end

function Comet:_GetReturnPosition()
	local ownerBodyPart = self:GetOwnerBodyPart("HumanoidRootPart")

	if not ownerBodyPart then
		return nil
	end

	local companion = companions.Companions[self.companion.CompanionType]
	local followOffset = companion and companion.FollowOffset or createVector(-4, 3, 0)
	return ownerBodyPart.CFrame:PointToWorldSpace(followOffset)
end

function Comet:_GetHeadRestPosition()
	local _GetHead = self:_GetHead()

	if _GetHead then
		return _GetHead.Position + createVector(0, 1.6, 0)
	end

	return nil
end

function Comet:_AttachToHead()
	self:_DetachFromHead()
	local _GetHead = self:_GetHead()
	local rootPart = self.companion.RootPart

	if not (_GetHead and rootPart) then
		return false
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "CometRestA0"
	attachment.CFrame = CFrame.Angles(0, -3.141592653589793, 0)
	attachment.Parent = rootPart
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "CometRestA1"
	attachment2.Position = createVector(0, 1.6, 0)
	attachment2.Parent = _GetHead
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Attachment0 = attachment
	alignPosition.Attachment1 = attachment2
	alignPosition.RigidityEnabled = false
	alignPosition.MaxForce = 50000
	alignPosition.MaxVelocity = 1e999
	alignPosition.Responsiveness = 45
	alignPosition.Parent = rootPart
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = attachment
	alignOrientation.Attachment1 = attachment2
	alignOrientation.RigidityEnabled = false
	alignOrientation.MaxTorque = 50000
	alignOrientation.MaxAngularVelocity = 1e999
	alignOrientation.Responsiveness = 45
	alignOrientation.Parent = rootPart
	self.companion.SuppressPositionUpdates = true
	rootPart.Anchored = false
	self.restAttachment = attachment2
	self.restConstraints = {
		attachment,
		attachment2,
		alignPosition,
		alignOrientation
	}
	return true
end

function Comet:_DetachFromHead()
	self.companion.SuppressPositionUpdates = false

	if self.restConstraints then
		for _, restConstraint in ipairs(self.restConstraints) do
			restConstraint:Destroy()
		end

		self.restConstraints = nil
	end

	self.restAttachment = nil
	local rootPart = self.companion.RootPart

	if rootPart then
		rootPart.Anchored = true
	end
end

function Comet:StartFlight(vector2: Vector3, dynamicTarget, onArrive)
	local position = self.companion.RootPart.Position
	self.flight = {
		startPos = position,
		target = vector2,
		elapsed = 0,
		duration = math.clamp((vector2 - position).Magnitude / 18, 0.5, 2.5),
		dynamicTarget = dynamicTarget,
		onArrive = onArrive
	}
end

function Comet:StopFlight()
	self.flight = nil
end

function Comet:_TickFlight(p: number)
	local flight = self.flight

	if not flight then
		return
	end

	local target = flight.dynamicTarget and flight.dynamicTarget()

	if target then
		flight.target = target
	end

	flight.elapsed += p
	local v6 = math.min(flight.elapsed / flight.duration, 1)
	local v7 = smoothstep(v6)
	self.companion.MoodPositionOverride = flight.startPos:Lerp(flight.target, v7) + Vector3.new(
		0,
		v7 * 12 * (1 - v7),
		0
	)
	self.companion.MoodSmoothTime = 0.05

	if v6 >= 1 then
		local onArrive = flight.onArrive
		self.flight = nil

		if onArrive then
			onArrive()
		end
	end
end

function Comet:_FlyBackToFollow(callback, callback2)
	self.departing = true
	self:SetState("Walking")
	self:_PlayFirstAvailable(v2)
	local rootPart = self.companion.RootPart

	if rootPart then
		self.companion.LastPosition = rootPart.Position
	end

	self.companion.PositionVelocity = createVector(0, 0, 0)
	self.companion.AnchorPosition = nil
	self.companion.IsFollowing = false
	local _GetReturnPosition = self:_GetReturnPosition()

	if _GetReturnPosition then
		self:StartFlight(_GetReturnPosition, function()
			return self:_GetReturnPosition()
		end, function()
			if not callback() then
				return
			end

			task.delay(0.4, function()
				if callback() then
					callback2()
				end
			end)
		end)
		return
	end

	self.companion.MoodPositionOverride = nil
	self.companion.MoodSmoothTime = nil
	callback2()
end

function Comet.Update(object, p: number)
	if object.activeMood then
		return nil
	end

	return object:RollMoods(p)
end

function Comet:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self.moodStartTime = tick()
	self.departing = false
	self._headRestEnded = false
	self._spinEnded = false
	self._danceEnded = false
	self._wanderEnded = false

	if activeMood == "HeadRest" then
		self:StartHeadRest()
	elseif activeMood == "SpinBurst" then
		self:StartSpinBurst()
	elseif activeMood == "Dance" then
		self:StartDance()
	elseif activeMood == "Wander" then
		self:StartWander(p)
	end
end

function Comet:UpdateMood(p: number)
	if self.flight == nil and not (self.resting or self.departing or self.danceActive or self.wandering) then
		self:_TickMovement(p)
	end

	self:_TickFlight(p)
	self:_TickRest(p)
	self:_TickSpin(p)
	self:_TickDance(p)

	if self._headRestEnded or self._spinEnded or self._danceEnded or self._wanderEnded then
		return true
	end

	return false
end

function Comet:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "HeadRest" then
		self:CleanupHeadRest()
	elseif self.activeMood == "SpinBurst" then
		self:CleanupSpinBurst()
	elseif self.activeMood == "Dance" then
		self:CleanupDance()
	elseif self.activeMood == "Wander" then
		self:CleanupWander()
	end

	self.activeMood = nil
end

function Comet:StartHeadRest()
	if not self:_GetHeadRestPosition() then
		self._headRestEnded = true
		return
	end

	self:SetState("MoodAction")
	self.companion.MoodUninterruptible = true
	self:EnterHeadRestPhase("FlyTo")
end

function Comet:EnterHeadRestPhase(p: string)
	self.headRestPhaseGen += 1
	local headRestPhaseGen = self.headRestPhaseGen

	local function stillValid()
		return self.activeMood == "HeadRest" and self.headRestPhaseGen == headRestPhaseGen
	end

	if p == "FlyTo" then
		local _GetHeadRestPosition = self:_GetHeadRestPosition()

		if not _GetHeadRestPosition then
			self._headRestEnded = true
			return
		end

		self:_PlayFirstAvailable(v2)
		self:StartFlight(_GetHeadRestPosition, function()
			return self:_GetHeadRestPosition()
		end, function()
			local v5

			if self.activeMood == "HeadRest" then
				v5 = self.headRestPhaseGen == headRestPhaseGen
			else
				v5 = false
			end

			if v5 then
				self:EnterHeadRestPhase("Rest")
			end
		end)
	elseif p == "Rest" then
		self:StopMoving()

		if not self:_AttachToHead() then
			self._headRestEnded = true
			return
		end

		self.resting = true
		self.restElapsed = 0
		self.restStartOwnerPos = self:_GetOwnerRootPosition()
		self.restDuration = 6 + math.random() * 8
		self:_PlayFirstAvailable(v3)
		self:SetParticles("Sleep/Particle", true)
	elseif p == "Depart" then
		self.resting = false
		self.departing = true
		self:SetParticles("Sleep/Particle", false)
		self:_DetachFromHead()
		self:StopFlight()
		self:SetState("Walking")
		self:_PlayFirstAvailable(v2)
		local rootPart = self.companion.RootPart

		if rootPart then
			self.companion.LastPosition = rootPart.Position
		end

		self.companion.PositionVelocity = createVector(0, 0, 0)
		self.companion.AnchorPosition = nil
		self.companion.IsFollowing = false
		local _GetReturnPosition = self:_GetReturnPosition()

		if _GetReturnPosition then
			self:StartFlight(_GetReturnPosition, function()
				return self:_GetReturnPosition()
			end, function()
				local v5

				if self.activeMood == "HeadRest" then
					v5 = self.headRestPhaseGen == headRestPhaseGen
				else
					v5 = false
				end

				if not v5 then
					return
				end

				task.delay(0.4, function()
					local v6

					if self.activeMood == "HeadRest" then
						v6 = self.headRestPhaseGen == headRestPhaseGen
					else
						v6 = false
					end

					if v6 then
						self._headRestEnded = true
					end
				end)
			end)
		else
			self.companion.MoodPositionOverride = nil
			self.companion.MoodSmoothTime = nil
			self._headRestEnded = true
		end
	end
end

function Comet:_TickRest(p: number)
	if not self.resting then
		return
	end

	local _GetHead = self:_GetHead()
	local restAttachment = self.restAttachment

	if _GetHead and _GetHead.Parent and restAttachment and restAttachment.Parent then
		self.restElapsed += p
		local _GetOwnerRootPosition = self:_GetOwnerRootPosition()
		local restStartOwnerPos = self.restStartOwnerPos

		if _GetOwnerRootPosition and restStartOwnerPos and (_GetOwnerRootPosition - restStartOwnerPos).Magnitude >= 10 then
			self:EnterHeadRestPhase("Depart")
		elseif self.restElapsed >= self.restDuration then
			self:EnterHeadRestPhase("Depart")
		end
	else
		self.resting = false
		self:SetParticles("Sleep/Particle", false)
		self:_DetachFromHead()
		self._headRestEnded = true
	end
end

function Comet:CleanupHeadRest()
	self.headRestPhaseGen += 1
	self.resting = false
	self:SetParticles("Sleep/Particle", false)
	self:_DetachFromHead()
	self:StopFlight()
	self:StopMoving()
	self.restElapsed = 0
	self.restStartOwnerPos = nil
	self.departing = false
	self._headRestEnded = false
	local rootPart = self.companion.RootPart

	if rootPart then
		self.companion.LastPosition = rootPart.Position
	end

	self.companion.PositionVelocity = createVector(0, 0, 0)
	self.companion.AnchorPosition = nil
	self.companion.IsFollowing = false
	self.companion.IdleSettleTime = tick()
	self.companion.MoodUninterruptible = false
	self.companion.MoodPositionOverride = nil
	self.companion.MoodSmoothTime = nil
end

function Comet:StartSpinBurst()
	self:SetState("MoodAction")
	self.companion.MoodUninterruptible = true
	local _, spinStartYaw = self.companion.RootPart.CFrame:ToOrientation()
	self.spinStartYaw = spinStartYaw
	self.spinElapsed = 0
	self.spinning = true

	if self.companion.Animations.Spin then
		self:PlayAnimation("Spin")
	else
		self:_PlayFirstAvailable(v2)
	end
end

function Comet:_TickSpin(p: number)
	if not self.spinning then
		return
	end

	self.spinElapsed += p
	local v5 = math.min(self.spinElapsed / 0.9, 1)
	local v6 = 1 - (1 - v5) ^ 3
	local v7 = self.spinStartYaw + v6 * 2 * 3.141592653589793 * 2
	local cframe = CFrame.Angles(0, v7, 0)
	local rootPart = self.companion.RootPart
	rootPart.CFrame = CFrame.new(rootPart.Position) * cframe * CFrame.Angles(0, 3.141592653589793, 0)
	self.companion.TargetRotation = cframe

	if v5 >= 1 then
		self.spinning = false
		self._spinEnded = true
	end
end

function Comet:CleanupSpinBurst()
	self.spinning = false
	self.spinElapsed = 0
	self._spinEnded = false
	self:_PlayFirstAvailable(v2)
	self.companion.MoodUninterruptible = false
end

function Comet:StartDance()
	if not self.companion.Animations.Dance then
		self._danceEnded = true
		return
	end

	local _GetOwnerRootPosition = self:_GetOwnerRootPosition()

	if not _GetOwnerRootPosition then
		self._danceEnded = true
		return
	end

	self:SetState("MoodAction")
	self:StopMoving()
	local rootPart = self.companion.RootPart
	local v5 = (rootPart.Position - _GetOwnerRootPosition) * createVector(1, 0, 1)

	if v5.Magnitude < 0.1 then
		self.danceAngle = math.random() * 3.141592653589793 * 2
		self.danceRadius = 5
	else
		self.danceAngle = math.atan2(v5.Z, v5.X)
		self.danceRadius = v5.Magnitude
	end

	self.danceTargetRadius = 5 + math.random() * 2
	self.danceYOffset = rootPart.Position.Y - _GetOwnerRootPosition.Y
	local _, danceSpin = rootPart.CFrame:ToOrientation()
	self.danceSpin = danceSpin
	self.danceDirection = math.random() > 0.5 and 1 or -1
	self.danceBobPhase = 0
	self.danceElapsed = 0
	self.danceActive = true
	self:PlayAnimation("Dance")
end

function Comet:_TickDance(p: number)
	if not self.danceActive then
		return
	end

	local _GetOwnerRootPosition = self:_GetOwnerRootPosition()

	if _GetOwnerRootPosition then
		self.danceElapsed += p
		self.danceAngle += p * 1.2566370614359172 * self.danceDirection
		self.danceSpin += p * 1.0471975511965976 * self.danceDirection
		self.danceBobPhase += p * 3
		local v5 = math.min(p * 4, 1)
		self.danceRadius += (self.danceTargetRadius - self.danceRadius) * v5
		self.danceYOffset += (2.5 - self.danceYOffset) * v5
		local v6 = math.sin(self.danceBobPhase) * 0.25
		local v7 = _GetOwnerRootPosition + Vector3.new(
			math.cos(self.danceAngle) * self.danceRadius,
			self.danceYOffset + v6,
			math.sin(self.danceAngle) * self.danceRadius
		)
		local rootPart = self.companion.RootPart
		local targetRotation = CFrame.Angles(0, self.danceSpin, 0) * CFrame.Angles(0, 3.141592653589793, 0)
		rootPart.CFrame = CFrame.new(v7) * targetRotation
		self.companion.TargetRotation = targetRotation

		if self.danceElapsed >= 8 then
			self.danceActive = false
			self:_StartDanceReturn()
		end
	else
		self.danceActive = false
		self._danceEnded = true
	end
end

function Comet:_StartDanceReturn()
	self.dancePhaseGen += 1
	local dancePhaseGen = self.dancePhaseGen

	local function stillValid()
		return self.activeMood == "Dance" and self.dancePhaseGen == dancePhaseGen
	end

	self:_FlyBackToFollow(stillValid, function()
		self._danceEnded = true
	end)
end

function Comet:CleanupDance()
	self.dancePhaseGen += 1
	self.danceActive = false
	self.danceElapsed = 0
	self.departing = false
	self._danceEnded = false
	self:StopFlight()
	self:StopMoving()
	self:_PlayFirstAvailable(v2)
	local rootPart = self.companion.RootPart

	if rootPart then
		self.companion.LastPosition = rootPart.Position
	end

	self.companion.PositionVelocity = createVector(0, 0, 0)
	self.companion.AnchorPosition = nil
	self.companion.IsFollowing = false
	self.companion.IdleSettleTime = tick()
	self.companion.MoodPositionOverride = nil
	self.companion.MoodSmoothTime = nil
end

function Comet:_GetWanderTarget()
	if #self.wanderSpots > 0 then
		self.wanderSpotIndex += 1
		local wanderSpot = self.wanderSpots[self.wanderSpotIndex]

		if wanderSpot then
			return wanderSpot + createVector(0, 3, 0)
		end

		return nil
	else
		if self.wanderLegsLeft <= 0 then
			return nil
		end

		self.wanderLegsLeft -= 1
		local _GetOwnerRootPosition = self:_GetOwnerRootPosition()

		if not _GetOwnerRootPosition then
			return nil
		end

		local v5 = math.random() * 3.141592653589793 * 2
		local v6 = 5 + math.random() * 6
		local v7 = 2 + math.random() * 3
		return _GetOwnerRootPosition + Vector3.new(math.cos(v5) * v6, v7, math.sin(v5) * v6)
	end
end

function Comet:StartWander(p)
	self:SetState("MoodAction")
	self.wanderSpots = p and p.WanderSpots or {}
	self.wanderSpotIndex = 0
	self.wanderLegsLeft = math.random(2, 4)
	self.wandering = true
	self:EnterWanderPhase("FlyToNext")
end

function Comet:EnterWanderPhase(p: string)
	self.wanderPhaseGen += 1
	local wanderPhaseGen = self.wanderPhaseGen

	local function stillValid()
		return self.activeMood == "Wander" and self.wanderPhaseGen == wanderPhaseGen
	end

	if p == "FlyToNext" then
		local _GetWanderTarget = self:_GetWanderTarget()

		if not _GetWanderTarget then
			self:EnterWanderPhase("Return")
			return
		end

		self:_PlayFirstAvailable(v2)
		self:StartFlight(_GetWanderTarget, nil, function()
			local v5

			if self.activeMood == "Wander" then
				v5 = self.wanderPhaseGen == wanderPhaseGen
			else
				v5 = false
			end

			if v5 then
				self:EnterWanderPhase("Pause")
			end
		end)
	elseif p == "Pause" then
		self:_PlayFirstAvailable(v4)
		local v5 = 0.6 + math.random() * 1.4
		task.delay(v5, function()
			local v6

			if self.activeMood == "Wander" then
				v6 = self.wanderPhaseGen == wanderPhaseGen
			else
				v6 = false
			end

			if v6 then
				self:EnterWanderPhase("FlyToNext")
			end
		end)
	elseif p == "Return" then
		self.wandering = false
		self:_FlyBackToFollow(stillValid, function()
			self._wanderEnded = true
		end)
	end
end

function Comet:CleanupWander()
	self.wanderPhaseGen += 1
	self.wandering = false
	self.wanderSpots = {}
	self.wanderSpotIndex = 0
	self.wanderLegsLeft = 0
	self.departing = false
	self._wanderEnded = false
	self:StopFlight()
	self:StopMoving()
	self:_PlayFirstAvailable(v2)
	local rootPart = self.companion.RootPart

	if rootPart then
		self.companion.LastPosition = rootPart.Position
	end

	self.companion.PositionVelocity = createVector(0, 0, 0)
	self.companion.AnchorPosition = nil
	self.companion.IsFollowing = false
	self.companion.IdleSettleTime = tick()
	self.companion.MoodPositionOverride = nil
	self.companion.MoodSmoothTime = nil
end

function Comet:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	self:_DetachFromHead()
	CompanionBehavior.Destroy(self)
end

return Comet