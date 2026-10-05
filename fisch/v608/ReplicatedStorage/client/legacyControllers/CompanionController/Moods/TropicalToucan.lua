local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.packages.Net)
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local remoteEvent = Net:RemoteEvent("Companion/RequestMood")
local v = {
	PerchSurface = {
		Chance = 100,
		Interval = 2
	}
}
local TropicalToucan = {}
TropicalToucan.__index = TropicalToucan
setmetatable(TropicalToucan, CompanionBehavior)

function TropicalToucan:new()
	local v2 = CompanionBehavior.new(self)
	setmetatable(v2, TropicalToucan)
	v2:RegisterMoods(v)
	v2.perchPhaseGen = 0
	v2._perchEnded = false
	v2.divePhaseGen = 0
	v2._diveEnded = false

	for _, part in self.Model:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanTouch = false
		part.Massless = true
	end

	v2._trailBlend = 0
	v2._lastOwnerPos = nil
	v2._flightMovement = nil
	v2._postFlightUntil = 0
	v2._circleAngle = math.random() * 3.141592653589793 * 2
	v2._currentBank = 0
	v2._lastFlatDir = nil
	self.MoodIgnoreGroundClamp = true
	v2.trove:Add(RunService.Heartbeat:Connect(function(dt: number)
		if v2.activeMood then
			return
		end

		local character = v2.companion.Owner.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local _GetBobberPosition = v2:_GetBobberPosition()

		if _GetBobberPosition then
			v2._circleAngle += dt * 1.2217304763960306
			local moodPositionOverride = _GetBobberPosition + Vector3.new(
				math.cos(v2._circleAngle) * 7,
				14,
				math.sin(v2._circleAngle) * 7
			)
			local moodSmoothTime = 0.18

			if tick() < v2._postFlightUntil then
				moodSmoothTime = math.max(moodSmoothTime, 0.6)
			end

			v2.companion.MoodPositionOverride = moodPositionOverride
			v2.companion.MoodSmoothTime = moodSmoothTime
			v2:_ApplyFlightRotation(Vector3.new(-math.sin(v2._circleAngle), 0, (math.cos(v2._circleAngle))), dt)
		else
			local v3 = not v2._lastOwnerPos and 0 or ((humanoidRootPart.Position - v2._lastOwnerPos) * createVector(
				1,
				0,
				1
			)).Magnitude / math.max(dt, 0.001)
			v2._lastOwnerPos = humanoidRootPart.Position
			local v4 = v3 > 1.5 and 1 or 0
			v2._trailBlend += (v4 - v2._trailBlend) * math.min(dt * 2.5, 1)
			local lerped = (createVector(-1.6, 2.2, 0)):Lerp(createVector(-2, 3.5, 6), v2._trailBlend)
			local moodSmoothTime = 0.05 + 0.2 * v2._trailBlend

			if tick() < v2._postFlightUntil then
				moodSmoothTime = math.max(moodSmoothTime, 0.6)
			end

			v2.companion.MoodPositionOverride = (humanoidRootPart.CFrame * CFrame.new(lerped)).Position
			v2.companion.MoodSmoothTime = moodSmoothTime
			v2.companion.MoodRotationTilt = nil
			v2._currentBank = 0
			v2._lastFlatDir = nil
			local v7 = v2.companion.IsOwner and v2:RollMoods(dt)

			if v7 then
				remoteEvent:FireServer(v7)
			end
		end
	end))
	return v2
end

function TropicalToucan:_GetOwnerPosition()
	local character = self.companion.Owner.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart and humanoidRootPart.Position
end

function TropicalToucan:_FindPerchSurface()
	local _GetOwnerPosition = self:_GetOwnerPosition()

	if not _GetOwnerPosition then
		return nil
	end

	local companion = self.companion
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { companion.Model, self.companion.Owner.Character }
	overlapParams.MaxParts = 100
	overlapParams.RespectCanCollide = true
	local partBoundsInRadius = workspace:GetPartBoundsInRadius(_GetOwnerPosition, 22, overlapParams)
	local v2 = _GetOwnerPosition.Y + 3
	local v3 = _GetOwnerPosition.Y + 35
	local v4 = {}

	for _, instance in partBoundsInRadius do
		if not (instance:IsA("Part") and instance.Shape == Enum.PartType.Block or instance:IsA("TriangleMeshPart") and instance.CollisionFidelity == Enum.CollisionFidelity.Box) then
			continue
		end

		if instance.CFrame.UpVector.Y < 0.6 then
			continue
		end

		local position = (instance.CFrame * CFrame.new(0, instance.Size.Y / 2, 0)).Position

		if position.Y < v2 or v3 < position.Y or (Vector2.new(position.X, position.Z) - Vector2.new(
			_GetOwnerPosition.X,
			_GetOwnerPosition.Z
		)).Magnitude < 6 then
			continue
		end

		table.insert(v4, {
			pos = position + createVector(0, 0.3, 0),
			topY = position.Y
		})
	end

	if #v4 == 0 then
		return nil
	end

	table.sort(v4, function(a, b)
		return a.topY > b.topY
	end)
	local v5 = math.max(1, (math.ceil(#v4 * 0.3)))
	return v4[math.random(1, v5)].pos
end

function TropicalToucan:_GetBobberPosition()
	local character = self.companion.Owner.Character

	if not character then
		return nil
	end

	local tool = character:FindFirstChildWhichIsA("Tool")
	local bobber = tool and tool:FindFirstChild("bobber")

	if bobber and bobber:IsA("BasePart") then
		return bobber.Position
	end

	return nil
end

function TropicalToucan:_GetShoulderPos()
	local character = self.companion.Owner.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return (humanoidRootPart.CFrame * CFrame.new(createVector(-1.6, 2.2, 0))).Position
	end

	return nil
end

function TropicalToucan:_StartFlight(data)
	self._flightMovement = {
		startPos = self.companion.RootPart.Position,
		targetPos = data.target,
		startTime = tick(),
		duration = data.duration,
		peakBonus = data.peakBonus,
		onArrive = data.onArrive,
		dynamicTarget = data.dynamicTarget
	}
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function smoothstep(p: number)
	return p * p * (3 - p * 2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function evalArc(startPos: Vector3, targetPos: Vector3, peakBonus: number, p: number)
	local lerped = startPos:Lerp(targetPos, p)
	local v2 = math.max(startPos.Y, targetPos.Y)
	local v3 = math.sin(p * 3.141592653589793) * (v2 + peakBonus - lerped.Y)
	local v4 = v3 < 0 and 0 or v3
	return (Vector3.new(lerped.X, lerped.Y + v4, lerped.Z))
end

function TropicalToucan:_ApplyFlightRotation(vector2: Vector3, p: number)
	if vector2.Magnitude < 0.001 then
		return
	end

	local lazyOwnerRotation = self.companion.LazyOwnerRotation

	if not lazyOwnerRotation then
		return
	end

	local vector3 = Vector3.new(vector2.X, 0, vector2.Z)
	local lastFlatDir = vector3.Magnitude < 0.001 and createVector(0, 0, 1) or vector3.Unit
	local _lastFlatDir = self._lastFlatDir
	local v3 = not (_lastFlatDir and p > 0) and 0 or math.clamp(
		-(math.asin((math.clamp(_lastFlatDir:Cross(lastFlatDir).Y, -1, 1))) / p) * 0.18,
		-0.6108652381980153,
		0.6108652381980153
	)
	self._lastFlatDir = lastFlatDir
	self._currentBank = (self._currentBank or 0) + (v3 - (self._currentBank or 0)) * math.min(p * 5, 1)
	local cframe = CFrame.lookAt(createVector(0, 0, 0), vector2.Unit)
	local cframe2 = CFrame.Angles(0, 0, self._currentBank)
	self.companion.MoodRotationTilt = lazyOwnerRotation:Inverse() * cframe * cframe2
end

function TropicalToucan:_TickFlight(p: number)
	local _flightMovement = self._flightMovement

	if not _flightMovement then
		return
	end

	local targetPos = _flightMovement.dynamicTarget and _flightMovement.dynamicTarget()

	if targetPos then
		_flightMovement.targetPos = targetPos
	end

	local v3 = math.min((tick() - _flightMovement.startTime) / _flightMovement.duration, 1)
	local v4 = smoothstep(v3)
	local moodPositionOverride = evalArc(
		_flightMovement.startPos,
		_flightMovement.targetPos,
		_flightMovement.peakBonus,
		v4
	) -- equivalent call inferred; original call site unknown
	local v7 = smoothstep(math.min(v3 + 0.05, 1))
	local v8 = evalArc(_flightMovement.startPos, _flightMovement.targetPos, _flightMovement.peakBonus, v7) - moodPositionOverride
	self.companion.MoodPositionOverride = moodPositionOverride
	self.companion.MoodSmoothTime = 0.02
	self:_ApplyFlightRotation(v8, p)

	if v3 >= 1 then
		local onArrive = _flightMovement.onArrive
		self._flightMovement = nil

		if onArrive then
			onArrive()
		end
	end
end

function TropicalToucan.Update(object, p: number)
	if object.activeMood then
		return nil
	end

	return object:RollMoods(p)
end

function TropicalToucan:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self._perchEnded = false
	self._diveEnded = false

	if activeMood == "PerchSurface" then
		self:StartPerchSurface()
	elseif activeMood == "Dive" then
		self:StartDive(p)
	end
end

function TropicalToucan:UpdateMood(p: number)
	self:_TickMovement(p)
	self:_TickFlight(p)

	if self._perchEnded or self._diveEnded then
		return true
	end

	return false
end

function TropicalToucan:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "PerchSurface" then
		self:CleanupPerchSurface()
	elseif self.activeMood == "Dive" then
		self:CleanupDive()
	end

	self.activeMood = nil
end

function TropicalToucan:StartPerchSurface()
	local _FindPerchSurface = self:_FindPerchSurface()

	if not _FindPerchSurface then
		self._perchEnded = true
		return
	end

	self:SetState("MoodAction")
	self:EnterPerchPhase("FlyTo", _FindPerchSurface)
end

function TropicalToucan:EnterPerchPhase(p: string, moodPositionOverride: Vector3?)
	self.perchPhaseGen += 1
	local perchPhaseGen = self.perchPhaseGen

	local function stillValid()
		return self.activeMood == "PerchSurface" and self.perchPhaseGen == perchPhaseGen
	end

	local companion = self.companion

	if p == "FlyTo" and moodPositionOverride then
		self:PlayAnimation("Fly")
		self:_StartFlight({
			target = moodPositionOverride,
			duration = 1.8,
			peakBonus = 4,
			onArrive = function()
				local v2

				if self.activeMood == "PerchSurface" then
					v2 = self.perchPhaseGen == perchPhaseGen
				else
					v2 = false
				end

				if v2 then
					self:EnterPerchPhase("Sit", moodPositionOverride)
				end
			end
		})
	elseif p == "Sit" and moodPositionOverride then
		companion.MoodPositionOverride = moodPositionOverride
		companion.MoodSmoothTime = 0.02
		companion.MoodRotationTilt = nil
		self:PlayAnimation("Perch")

		if math.random() < 0.5 then
			self:PlaySound("Squawk", true)
		end

		local v2 = 3 + math.random() * 4
		task.delay(v2, function()
			local v3

			if self.activeMood == "PerchSurface" then
				v3 = self.perchPhaseGen == perchPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterPerchPhase("Return")
			end
		end)
	elseif p == "Return" then
		self:PlayAnimation("Fly")
		self:_StartFlight({
			target = self:_GetShoulderPos() or companion.RootPart.Position,
			duration = 4.5,
			peakBonus = 6,
			onArrive = function()
				local v2

				if self.activeMood == "PerchSurface" then
					v2 = self.perchPhaseGen == perchPhaseGen
				else
					v2 = false
				end

				if v2 then
					self._perchEnded = true
				end
			end
		})
	end
end

function TropicalToucan:CleanupPerchSurface()
	local companion = self.companion
	companion.MoodPositionOverride = nil
	companion.MoodSmoothTime = nil
	companion.MoodRotationTilt = nil
	self._flightMovement = nil
	self._postFlightUntil = tick() + 1.5
end

function TropicalToucan:StartDive(_)
	local _GetBobberPosition = self:_GetBobberPosition()

	if not _GetBobberPosition then
		self._diveEnded = true
		return
	end

	self:SetState("MoodAction")
	self.companion.MoodUninterruptible = true
	self:EnterDivePhase("Down", _GetBobberPosition)
end

function TropicalToucan:EnterDivePhase(p: string, vector2: Vector3?)
	local divePhaseGen = self.divePhaseGen + 1
	self.divePhaseGen = divePhaseGen

	local function stillValid()
		return self.activeMood == "Dive" and self.divePhaseGen == divePhaseGen
	end

	local companion = self.companion

	if p == "Down" and vector2 then
		self:PlayAnimation("Fly")
		self:_StartFlight({
			target = vector2 + createVector(0, 2, 0),
			duration = 1.1,
			peakBonus = 1,
			onArrive = function()
				local v3

				if self.activeMood == "Dive" then
					v3 = self.divePhaseGen == divePhaseGen
				else
					v3 = false
				end

				if v3 then
					self:EnterDivePhase("Pickup", vector2)
				end
			end
		})
	elseif p == "Pickup" and vector2 then
		companion.MoodPositionOverride = vector2 + createVector(0, 2, 0)
		companion.MoodSmoothTime = 0.02
		self:PlayAnimation("Squawk")
		self:PlaySound("Squawk", true)
		task.delay(0.35, function()
			local v3

			if self.activeMood == "Dive" then
				v3 = self.divePhaseGen == divePhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterDivePhase("Return", vector2)
			end
		end)
	elseif p == "Return" then
		self:PlayAnimation("Fly")
		self:_StartFlight({
			target = self:_GetShoulderPos() or companion.RootPart.Position,
			duration = 1.6,
			peakBonus = 5,
			onArrive = function()
				local v3

				if self.activeMood == "Dive" then
					v3 = self.divePhaseGen == divePhaseGen
				else
					v3 = false
				end

				if v3 then
					self:EnterDivePhase("Deliver", nil)
				end
			end
		})
	elseif p == "Deliver" then
		self:PlayAnimation("Squawk")
		self:PlaySound("Squawk", true)
		task.delay(0.55, function()
			local v3

			if self.activeMood == "Dive" then
				v3 = self.divePhaseGen == divePhaseGen
			else
				v3 = false
			end

			if v3 then
				self._diveEnded = true
			end
		end)
	end
end

function TropicalToucan:CleanupDive()
	local companion = self.companion
	companion.MoodPositionOverride = nil
	companion.MoodSmoothTime = nil
	companion.MoodRotationTilt = nil
	companion.MoodUninterruptible = false
	self._flightMovement = nil
	self._postFlightUntil = tick() + 1.5
end

function TropicalToucan:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return TropicalToucan