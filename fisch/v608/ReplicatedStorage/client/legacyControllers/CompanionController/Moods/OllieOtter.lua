local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local FishModel = require(ReplicatedStorage.shared.modules.FishModel)
local assets = require(ReplicatedStorage.shared.utils.assets)
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("Companion/OllieOtter/EvilBite")
local v = {
	Wander = {
		Chance = 30,
		Interval = 12
	},
	Sleep = {
		Chance = 30,
		Interval = 18
	}
}
local v2 = { "Quack", "Squeak" }
local v3 = { "Anchovy" }
local OllieOtter = {}
OllieOtter.__index = OllieOtter
setmetatable(OllieOtter, CompanionBehavior)

function OllieOtter.new(p)
	local v4 = CompanionBehavior.new(p)
	setmetatable(v4, OllieOtter)
	v4:RegisterMoods(v)
	v4.moodStartTime = 0
	v4.idleTimer = 0
	v4.chatterTimer = 0
	v4.chatterNext = math.random(60, 120)
	v4.wanderPhaseGen = 0
	v4.wanderSpots = {}
	v4.wanderSpotIndex = 0
	v4.wanderNapSpot = nil
	v4.wanderShouldNap = false
	v4._wanderEnded = false
	v4.sillySitPhaseGen = 0
	v4._sillySitEnded = false
	v4.snapPhaseGen = 0
	v4.snapHoldCFrame = nil
	v4._snapEnded = false
	v4.reelSwimPhaseGen = 0
	v4.reelSwimCircling = false
	v4.reelSwimBobberPos = createVector(0, 0, 0)
	v4.reelSwimAngle = 0
	v4.reelSwimDir = 1
	v4.reelSwimBobberMissingSince = nil
	v4.reelReturnPos = nil
	v4._reelSwimEnded = false
	v4.settleState = nil
	v4.waterSwim = nil
	v4.fetchBobberMissingSince = nil
	v4.arcActive = false
	v4.arcStart = createVector(0, 0, 0)
	v4.arcTarget = createVector(0, 0, 0)
	v4.arcHeight = 5
	v4.arcLandSound = "Dive"
	v4.arcDuration = 0
	v4.arcElapsed = 0
	v4.arcOnComplete = nil
	v4.attackPhaseGen = 0
	v4.attackTarget = nil
	v4._attackEnded = false
	v4.fetchPhaseGen = 0
	v4.fetchItem = nil
	v4.fetchBobberPos = createVector(0, 0, 0)
	v4.fetchHoldCFrame = nil
	v4._fetchEnded = false
	v4.heldFishModel = nil
	return v4
end

function OllieOtter:GetWalkAnimation()
	if self.companion.Animations.Walk then
		return "Walk"
	end

	return "Run"
end

function OllieOtter:GetSwimAnimation()
	if self.companion.Animations.Swim then
		return "Swim"
	end

	return (self:GetWalkAnimation())
end

function OllieOtter:_GetBobberPosition()
	local character = self.companion.Owner.Character

	if not character then
		return nil
	end

	local tool = character:FindFirstChildWhichIsA("Tool")
	local bobber = tool and tool:FindFirstChild("bobber")

	if bobber and bobber:IsA("BasePart") then
		return bobber.Position + createVector(0, -0.5, 0)
	end

	return nil
end

function OllieOtter:_GetTargetRootPart()
	local attackTarget = self.attackTarget

	if not (attackTarget and attackTarget.Parent) then
		return nil
	end

	local character = attackTarget.Character

	if character then
		return (character:FindFirstChild("HumanoidRootPart"))
	end

	return nil
end

function OllieOtter:_FindMouthAttachment()
	for _, attachment in self.companion.Model:GetDescendants() do
		if attachment:IsA("Attachment") and attachment.Name == "Mouth" then
			return attachment
		end
	end

	return nil
end

function OllieOtter:_StartSettleToOwner(onComplete)
	local rootPart = self.companion.RootPart
	local cFrame = rootPart.CFrame
	local character = self.companion.Owner.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local targetCF

	if humanoidRootPart then
		local v5 = (humanoidRootPart.Position - rootPart.Position) * createVector(1, 0, 1)

		if v5.Magnitude > 0.001 then
			targetCF = CFrame.lookAt(rootPart.Position, rootPart.Position + v5.Unit) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			)
		else
			targetCF = cFrame
		end
	else
		targetCF = cFrame
	end

	self.settleState = {
		elapsed = 0,
		startCF = cFrame,
		targetCF = targetCF,
		onComplete = onComplete
	}
end

function OllieOtter:StartArc(arcTarget: Vector3, arcOnComplete, value: number?, value2: string?)
	self:StopMoving()
	local position = self.companion.RootPart.Position
	local magnitude = (arcTarget - position).Magnitude
	self.arcActive = true
	self.arcStart = position
	self.arcTarget = arcTarget
	self.arcHeight = value or 5
	self.arcLandSound = value2 or "Dive"
	self.arcDuration = math.max(magnitude / 22, 0.2)
	self.arcElapsed = 0
	self.arcOnComplete = arcOnComplete
	self:PlayAnimation(self.companion.Animations.Jump and "Jump" or self:GetWalkAnimation())
	self:PlaySound("Jump", true)
	self:EmitParticles("jump", 5)
end

function OllieOtter:StopArc()
	self.arcActive = false
	self.arcOnComplete = nil
end

function OllieOtter:_TickArc(p: number)
	if not self.arcActive then
		return
	end

	self.arcElapsed += p
	local v4 = math.min(self.arcElapsed / self.arcDuration, 1)
	local v5 = self.arcStart:Lerp(self.arcTarget, v4) + Vector3.new(0, 4 * self.arcHeight * v4 * (1 - v4), 0)
	local v6 = (self.arcTarget - self.arcStart) * createVector(1, 0, 1)

	if v6.Magnitude > 0.001 then
		self.companion.RootPart.CFrame = CFrame.lookAt(v5, v5 + v6.Unit) * CFrame.Angles(0, 3.141592653589793, 0)
	else
		self.companion.RootPart.CFrame = CFrame.new(v5)
	end

	if v4 >= 1 then
		local arcOnComplete = self.arcOnComplete
		self:StopArc()
		self:PlaySound(self.arcLandSound, true)

		if self.arcLandSound == "Dive" then
			self:EmitParticles("splash", 5)
		end

		if arcOnComplete then
			arcOnComplete()
		end
	end
end

function OllieOtter:StartWaterSwim(vector2: Vector3, p: number, onArrive)
	self:StopMoving()
	local position = self.companion.RootPart.Position
	self.waterSwim = {
		start = position,
		target = vector2,
		duration = math.max((vector2 - position).Magnitude / p, 0.05),
		elapsed = 0,
		onArrive = onArrive
	}
	self:PlayAnimation(self:GetSwimAnimation())
end

function OllieOtter:StopWaterSwim()
	self.waterSwim = nil
end

function OllieOtter:_TickWaterSwim(p: number)
	local waterSwim = self.waterSwim

	if not waterSwim then
		return
	end

	waterSwim.elapsed += p
	local v4 = math.min(waterSwim.elapsed / waterSwim.duration, 1)
	local lerped = waterSwim.start:Lerp(waterSwim.target, v4)
	local v5 = (waterSwim.target - waterSwim.start) * createVector(1, 0, 1)

	if v5.Magnitude > 0.001 then
		self.companion.RootPart.CFrame = CFrame.lookAt(lerped, lerped + v5.Unit) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)
	else
		self.companion.RootPart.CFrame = CFrame.new(lerped) * self.companion.RootPart.CFrame.Rotation
	end

	if v4 >= 1 then
		local onArrive = waterSwim.onArrive
		self.waterSwim = nil

		if onArrive then
			onArrive()
		end
	end
end

function OllieOtter:EmitParticles(p2: string, p3: number)
	local part = Instance.new("Part")
	part.Name = "OllieFXAnchor"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Position = self.companion.RootPart.Position
	part.Parent = workspace
	local flag = false

	for _, emitter in self.companion.Model:GetDescendants() do
		if not (emitter:IsA("ParticleEmitter") and string.find(string.lower(emitter.Name), p2)) then
			continue
		end

		local clone = emitter:Clone()
		clone.Parent = part
		clone:Emit(p3)
		flag = true
	end

	if flag then
		task.delay(3, function()
			if part and part.Parent then
				part:Destroy()
			end
		end)
	else
		part:Destroy()
	end
end

function OllieOtter:PlayCuteSound()
	self:PlaySound(v2[math.random(1, #v2)], true)
end

function OllieOtter:SpawnHeldFish()
	self:SpawnHeldItem(v3[math.random(1, #v3)], 25)
end

function OllieOtter:_CreateItemModel(p: string)
	local async = assets.getAsync("item", p)

	if not async then
		return nil
	end

	local clone = async:Clone()
	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")

	if not primaryPart then
		clone:Destroy()
		return nil
	end

	clone.PrimaryPart = primaryPart

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CastShadow = false
		end
	end

	return clone
end

function OllieOtter:SpawnHeldItem(name: string, duration: number)
	local _FindMouthAttachment = self:_FindMouthAttachment()

	if not _FindMouthAttachment then
		return
	end

	task.spawn(function()
		local heldFishModel = FishModel.Create({
			Name = name,
			ItemData = {
				Name = name
			},
			ResizeArgs = {
				MaxSize = 3
			},
			RemoveScripts = true,
			CastShadow = false
		}) or self:_CreateItemModel(name)

		if not (heldFishModel and heldFishModel.PrimaryPart) then
			return
		end

		self:RemoveHeldFish()
		local parent = _FindMouthAttachment.Parent
		heldFishModel:PivotTo(_FindMouthAttachment.WorldCFrame * CFrame.Angles(0, 1.5707963267948966, 0))
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = parent
		weldConstraint.Part1 = heldFishModel.PrimaryPart
		weldConstraint.Parent = heldFishModel.PrimaryPart
		heldFishModel.Name = "OllieHeldFish"
		heldFishModel.Parent = self.companion.Model
		self.heldFishModel = heldFishModel
		task.delay(duration, function()
			if self.heldFishModel == heldFishModel then
				self:RemoveHeldFish()
			end
		end)
	end)
end

function OllieOtter:RemoveHeldFish()
	if self.heldFishModel and self.heldFishModel.Parent then
		self.heldFishModel:Destroy()
	end

	self.heldFishModel = nil
end

function OllieOtter:Update(p: number)
	if self.activeMood then
		return nil
	end

	self.chatterTimer += p

	if self.chatterTimer >= self.chatterNext then
		self.chatterTimer = 0
		self.chatterNext = math.random(60, 120)
		self:PlayCuteSound()
	end

	local state = self.companion.State

	if state == "Walking" or state == "Jumping" then
		self.idleTimer = 0

		if self.heldFishModel then
			self:RemoveHeldFish()
		end

		return nil
	else
		self.idleTimer += p

		if self.idleTimer >= 300 then
			self.idleTimer = 0
			return "IdleSleep"
		end

		local rollMoods = self:RollMoods(p)

		if not rollMoods then
			return nil
		end

		self.idleTimer = 0
		return rollMoods
	end
end

function OllieOtter:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self.moodStartTime = tick()
	self._wanderEnded = false
	self._sillySitEnded = false
	self._snapEnded = false
	self._reelSwimEnded = false
	self._attackEnded = false
	self._fetchEnded = false

	if activeMood == "Wander" then
		self:StartWander(p, false)
	elseif activeMood == "Sleep" then
		self:StartWander(p, true)
	elseif activeMood == "IdleSleep" then
		self:StartIdleSleep()
	elseif activeMood == "SillySit" then
		self:StartSillySit()
	elseif activeMood == "Snap" then
		self:StartSnap()
	elseif activeMood == "ReelSwim" then
		self:StartReelSwim()
	elseif activeMood == "PlayerAttack" then
		self:StartPlayerAttack(p)
	elseif activeMood == "Fetch" then
		self:StartFetch(p)
	end
end

function OllieOtter:UpdateMood(p: number)
	if not self.arcActive and not self.reelSwimCircling and self.waterSwim == nil and self.snapHoldCFrame == nil and self.fetchHoldCFrame == nil and self.settleState == nil then
		self:_TickMovement(p)
	end

	self:_TickArc(p)
	self:_TickWaterSwim(p)
	self:_TickReelSwim(p)

	if self.activeMood == "Fetch" and not (self.arcActive or self.reelSwimCircling or self.settleState) then
		if self:_GetBobberPosition() then
			self.fetchBobberMissingSince = nil
		elseif self.fetchBobberMissingSince then
			if tick() - self.fetchBobberMissingSince > 0.5 then
				self.fetchBobberMissingSince = nil
				self.fetchPhaseGen += 1
				self.fetchHoldCFrame = nil
				self:_ResumeReelPresence()
			end
		else
			self.fetchBobberMissingSince = tick()
		end
	end

	if self.activeMood == "Snap" and self.snapHoldCFrame and not self.arcActive then
		self.companion.RootPart.CFrame = self.snapHoldCFrame
	end

	if self.activeMood == "Fetch" and self.fetchHoldCFrame and not self.arcActive then
		self.companion.RootPart.CFrame = self.fetchHoldCFrame
	end

	local settleState = self.settleState

	if settleState then
		settleState.elapsed += p
		local v4 = math.min(settleState.elapsed / 0.25, 1)
		self.companion.RootPart.CFrame = settleState.startCF:Lerp(settleState.targetCF, v4)

		if v4 >= 1 then
			local onComplete = settleState.onComplete
			self.settleState = nil

			if onComplete then
				onComplete()
			end
		end
	end

	if self.activeMood == "PlayerAttack" and tick() - self.moodStartTime > 8 or self.activeMood == "Fetch" and not self.reelSwimCircling and tick() - self.moodStartTime > 60 then
		return true
	end

	if self._wanderEnded or self._sillySitEnded or self._snapEnded or self._reelSwimEnded or self._attackEnded or self._fetchEnded then
		return true
	end

	return false
end

function OllieOtter:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Wander" or self.activeMood == "Sleep" then
		self:CleanupWander()
	elseif self.activeMood == "IdleSleep" then
		self:CleanupIdleSleep()
	elseif self.activeMood == "SillySit" then
		self:CleanupSillySit()
	elseif self.activeMood == "Snap" then
		self:CleanupSnap()
	elseif self.activeMood == "ReelSwim" then
		self:CleanupReelSwim()
	elseif self.activeMood == "PlayerAttack" then
		self:CleanupPlayerAttack()
	elseif self.activeMood == "Fetch" then
		self:CleanupFetch()
	end

	self.activeMood = nil
end

function OllieOtter:RequestInterrupt()
	self.idleTimer = 0
	CompanionBehavior.RequestInterrupt(self)
end

function OllieOtter:OnPhase(p: string, _)
	if p == "Grab" and self.activeMood == "Fetch" then
		self:EnterFetchPhase("Grab")
	end
end

function OllieOtter:StartWander(p, wanderShouldNap: boolean)
	self:SetState("MoodAction")
	self.wanderSpots = p.WanderSpots or {}
	self.wanderNapSpot = p.NapSpot
	self.wanderSpotIndex = 0
	self.wanderShouldNap = wanderShouldNap

	if #self.wanderSpots == 0 then
		self._wanderEnded = true
		return
	end

	if not self.heldFishModel and math.random(1, 100) <= 20 then
		self:SpawnHeldFish()
	end

	self:EnterWanderPhase("WalkToNextSpot")
end

function OllieOtter:EnterWanderPhase(p: string)
	self.wanderPhaseGen += 1
	local wanderPhaseGen = self.wanderPhaseGen

	local function stillValid()
		return (self.activeMood == "Wander" or self.activeMood == "Sleep") and self.wanderPhaseGen == wanderPhaseGen
	end

	if p == "WalkToNextSpot" then
		self.wanderSpotIndex += 1

		if not (self.wanderSpotIndex > #self.wanderSpots) then
			self:MoveTo(self.wanderSpots[self.wanderSpotIndex], {
				speed = 7,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v4

					if self.activeMood == "Wander" or self.activeMood == "Sleep" then
						v4 = self.wanderPhaseGen == wanderPhaseGen
					else
						v4 = false
					end

					if v4 then
						self:EnterWanderPhase("PauseAtSpot")
					end
				end
			})
		elseif self.wanderShouldNap then
			self:EnterWanderPhase("WalkToNapSpot")
		else
			self._wanderEnded = true
		end
	elseif p == "PauseAtSpot" then
		self:StopMoving()
		self:PlayAnimation("SitIdle")

		if math.random(1, 100) <= 15 then
			self:PlayCuteSound()
		end

		local v4 = 0.4 + math.random() * 0.9999999999999999
		task.delay(v4, function()
			local v5

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v5 = self.wanderPhaseGen == wanderPhaseGen
			else
				v5 = false
			end

			if v5 then
				self:EnterWanderPhase("WalkToNextSpot")
			end
		end)
	elseif p == "WalkToNapSpot" then
		if self.wanderNapSpot then
			self:MoveTo(self.wanderNapSpot, {
				speed = 7,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v4

					if self.activeMood == "Wander" or self.activeMood == "Sleep" then
						v4 = self.wanderPhaseGen == wanderPhaseGen
					else
						v4 = false
					end

					if v4 then
						self:EnterWanderPhase("SitBeforeNap")
					end
				end
			})
		else
			self._wanderEnded = true
		end
	elseif p == "SitBeforeNap" then
		self:StopMoving()
		self:PlayAnimation("SitIdle")
		local v4 = 1.2 + math.random() * 1.3
		task.delay(v4, function()
			local v5

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v5 = self.wanderPhaseGen == wanderPhaseGen
			else
				v5 = false
			end

			if v5 then
				self:EnterWanderPhase("Nap")
			end
		end)
	elseif p == "Nap" then
		self:StopMoving()
		self:SetState("Sleeping")
		self:PlayAnimation("Sleep")
		self:SetParticles("Sleep/Particle", true)
		self:PlaySound("Snore")
		task.delay(45, function()
			local v4

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v4 = self.wanderPhaseGen == wanderPhaseGen
			else
				v4 = false
			end

			if v4 then
				self._wanderEnded = true
			end
		end)
	end
end

function OllieOtter:CleanupWander()
	self:StopMoving()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self:RemoveHeldFish()
	self.wanderSpots = {}
	self.wanderNapSpot = nil
	self.wanderSpotIndex = 0
	self.wanderShouldNap = false
	self._wanderEnded = false
end

function OllieOtter:StartIdleSleep()
	self:SetState("Sleeping")
	self:PlayAnimation("Sleep")
	self:SetParticles("Sleep/Particle", true)
	self:PlaySound("Snore")
end

function OllieOtter:CleanupIdleSleep()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
end

function OllieOtter:StartSillySit()
	self:SetState("MoodAction")
	self:StopMoving()
	self:PlayAnimation("SillySit")
	self:PlayCuteSound()
	self.sillySitPhaseGen += 1
	local sillySitPhaseGen = self.sillySitPhaseGen
	local v4 = 3 + math.random() * 3
	task.delay(v4, function()
		if self.activeMood == "SillySit" and self.sillySitPhaseGen == sillySitPhaseGen then
			self._sillySitEnded = true
		end
	end)
end

function OllieOtter:CleanupSillySit()
	self:StopMoving()
	self._sillySitEnded = false
end

function OllieOtter:_IsReelPresenceMood()
	return self.activeMood == "ReelSwim" or self.activeMood == "Snap" or self.activeMood == "Fetch"
end

function OllieOtter:_GetCircleAngleFromPosition()
	local v4 = self.companion.RootPart.Position - self.reelSwimBobberPos

	if math.abs(v4.X) < 0.001 and math.abs(v4.Z) < 0.001 then
		return math.random() * 3.141592653589793 * 2
	end

	return (math.atan2(v4.Z, v4.X))
end

function OllieOtter:_ResumeReelPresence()
	self:StopWaterSwim()
	self.companion.MoodUninterruptible = false
	local _GetBobberPosition = self:_GetBobberPosition()

	if not _GetBobberPosition then
		self:EnterReelSwimPhase("ArcOut")
		return
	end

	self.reelSwimBobberPos = _GetBobberPosition

	if math.abs(((self.companion.RootPart.Position - _GetBobberPosition) * createVector(1, 0, 1)).Magnitude - 6) > 1.5 then
		self:EnterReelSwimPhase("SwimToCircle")
	else
		self:EnterReelSwimPhase("Circle")
	end
end

function OllieOtter:StartReelSwim()
	local _GetBobberPosition = self:_GetBobberPosition()

	if not _GetBobberPosition then
		self._reelSwimEnded = true
		return
	end

	self:SetState("MoodAction")
	self.reelSwimBobberPos = _GetBobberPosition
	self.reelSwimDir = math.random() > 0.5 and 1 or -1
	local position = self.companion.RootPart.Position

	if (position - _GetBobberPosition).Magnitude > 10 then
		self.reelReturnPos = position
		self:EnterReelSwimPhase("ArcIn")
	else
		self:_ResumeReelPresence()
	end
end

function OllieOtter:EnterReelSwimPhase(p: string)
	self.reelSwimPhaseGen += 1
	local reelSwimPhaseGen = self.reelSwimPhaseGen

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stillValid()
		return self:_IsReelPresenceMood() and self.reelSwimPhaseGen == reelSwimPhaseGen
	end

	if p == "ArcIn" then
		local _GetCircleAngleFromPosition = self:_GetCircleAngleFromPosition()
		self:StartArc(
			self.reelSwimBobberPos + Vector3.new(
				math.cos(_GetCircleAngleFromPosition) * 6,
				0,
				math.sin(_GetCircleAngleFromPosition) * 6
			),
			function()
				if stillValid() then
					self:EnterReelSwimPhase("Circle")
				end
			end
		)
	elseif p == "SwimToCircle" then
		local _GetCircleAngleFromPosition = self:_GetCircleAngleFromPosition()
		self:StartWaterSwim(
			self.reelSwimBobberPos + Vector3.new(
				math.cos(_GetCircleAngleFromPosition) * 6,
				0,
				math.sin(_GetCircleAngleFromPosition) * 6
			),
			9,
			function()
				if stillValid() then
					self:EnterReelSwimPhase("Circle")
				end
			end
		)
	elseif p == "Circle" then
		self:StopMoving()
		self.reelSwimAngle = self:_GetCircleAngleFromPosition()
		self.reelSwimBobberMissingSince = nil
		self.reelSwimCircling = true
		self:PlayAnimation(self:GetSwimAnimation())
	elseif p == "ArcOut" then
		self.reelSwimCircling = false
		self:StopMoving()
		local character = self.companion.Owner.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local reelReturnPos = self.reelReturnPos or humanoidRootPart and humanoidRootPart.Position

		if reelReturnPos then
			self:StartArc(reelReturnPos, function()
				if stillValid() then
					self:EnterReelSwimPhase("Settle")
				end
			end, nil, "Land")
		else
			self._reelSwimEnded = true
		end
	elseif p == "Settle" then
		self:_StartSettleToOwner(function()
			if stillValid() then
				self._reelSwimEnded = true
			end
		end)
	end
end

function OllieOtter:_TickReelSwim(p: number)
	if not self.reelSwimCircling then
		return
	end

	local _GetBobberPosition = self:_GetBobberPosition()

	if _GetBobberPosition then
		if self.reelSwimBobberMissingSince then
			self.reelSwimBobberMissingSince = nil
			self.reelSwimBobberPos = _GetBobberPosition
			self.reelSwimAngle = self:_GetCircleAngleFromPosition()
		end
	elseif self.reelSwimBobberMissingSince then
		if tick() - self.reelSwimBobberMissingSince > 0.5 then
			self.reelSwimBobberMissingSince = nil
			self:EnterReelSwimPhase("ArcOut")
			return
		end
	else
		self.reelSwimBobberMissingSince = tick()
	end

	self.reelSwimAngle += p * 1.5 * self.reelSwimDir
	local reelSwimAngle = self.reelSwimAngle
	local v4 = self.reelSwimBobberPos + Vector3.new(math.cos(reelSwimAngle) * 6, 0, math.sin(reelSwimAngle) * 6)
	local v5 = Vector3.new(-math.sin(reelSwimAngle), 0, (math.cos(reelSwimAngle))) * self.reelSwimDir
	self.companion.RootPart.CFrame = CFrame.lookAt(v4, v4 + v5) * CFrame.Angles(0, 3.141592653589793, 0)
end

function OllieOtter:_CleanupReelPresence()
	self:StopWaterSwim()
	self.reelSwimCircling = false
	self.reelSwimBobberMissingSince = nil
	self.settleState = nil
	self._reelSwimEnded = false
end

function OllieOtter:CleanupReelSwim()
	self:StopArc()
	self:StopMoving()
	self:_CleanupReelPresence()
end

function OllieOtter:StartSnap()
	self:SetState("MoodAction")
	self:EnterSnapPhase("Dash")
end

function OllieOtter:EnterSnapPhase(p: string)
	self.snapPhaseGen += 1
	local snapPhaseGen = self.snapPhaseGen

	local function stillValid()
		return self.activeMood == "Snap" and self.snapPhaseGen == snapPhaseGen
	end

	if p == "Dash" then
		local _GetBobberPosition = self:_GetBobberPosition()

		if not _GetBobberPosition then
			self._snapEnded = true
			return
		end

		self.reelSwimCircling = false
		self.reelSwimBobberPos = _GetBobberPosition
		self:StartWaterSwim(_GetBobberPosition, 14, function()
			local v4

			if self.activeMood == "Snap" then
				v4 = self.snapPhaseGen == snapPhaseGen
			else
				v4 = false
			end

			if v4 then
				self.snapHoldCFrame = self.companion.RootPart.CFrame
				self:EnterSnapPhase("Bite")
			end
		end)
	elseif p == "Bite" then
		task.delay(0.3, function()
			local v4

			if self.activeMood == "Snap" then
				v4 = self.snapPhaseGen == snapPhaseGen
			else
				v4 = false
			end

			if not v4 then
				return
			end

			self:PlayAnimation("Bite")
			self:PlaySound("Angry", true)
			task.delay(0.8, function()
				local v5

				if self.activeMood == "Snap" then
					v5 = self.snapPhaseGen == snapPhaseGen
				else
					v5 = false
				end

				if v5 then
					self.snapHoldCFrame = nil
					self:_ResumeReelPresence()
				end
			end)
		end)
	end
end

function OllieOtter:CleanupSnap()
	self:StopArc()
	self:StopMoving()
	self.snapHoldCFrame = nil
	self:_CleanupReelPresence()
end

function OllieOtter:StartPlayerAttack(p)
	local targetUserId = p.TargetUserId

	if typeof(targetUserId) ~= "number" then
		self._attackEnded = true
		return
	end

	self.attackTarget = Players:GetPlayerByUserId(targetUserId)

	if self:_GetTargetRootPart() then
		self:SetState("MoodAction")
		self.companion.MoodUninterruptible = true
		self:EnterAttackPhase("Lunge")
	else
		self.attackTarget = nil
		self._attackEnded = true
	end
end

function OllieOtter:EnterAttackPhase(p: string)
	self.attackPhaseGen += 1
	local attackPhaseGen = self.attackPhaseGen

	local function stillValid()
		return self.activeMood == "PlayerAttack" and self.attackPhaseGen == attackPhaseGen
	end

	if p == "Lunge" then
		local _GetTargetRootPart = self:_GetTargetRootPart()

		if _GetTargetRootPart then
			self:MoveTo(_GetTargetRootPart.Position, {
				speed = 16,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.2,
				trackFn = function()
					local _GetTargetRootPart2 = self:_GetTargetRootPart()
					return _GetTargetRootPart2 and _GetTargetRootPart2.Position
				end,
				onArrive = function()
					local v4

					if self.activeMood == "PlayerAttack" then
						v4 = self.attackPhaseGen == attackPhaseGen
					else
						v4 = false
					end

					if v4 then
						self:EnterAttackPhase("Bite")
					end
				end
			})
		else
			self._attackEnded = true
		end
	elseif p == "Bite" then
		self:StopMoving()
		self:PlayAnimation("Bite")
		self:PlaySound("Angry", true)

		if Players.LocalPlayer == self.companion.Owner then
			remoteEvent:FireServer()
		end

		task.delay(0.6, function()
			local v4

			if self.activeMood == "PlayerAttack" then
				v4 = self.attackPhaseGen == attackPhaseGen
			else
				v4 = false
			end

			if v4 then
				self:EnterAttackPhase("ReturnToOwner")
			end
		end)
	elseif p == "ReturnToOwner" then
		local character = self.companion.Owner.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			self:MoveTo(humanoidRootPart.Position, {
				speed = 8,
				animation = self:GetWalkAnimation(),
				arriveRadius = 4,
				trackFn = function()
					local character2 = self.companion.Owner.Character
					local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")
					return humanoidRootPart2 and humanoidRootPart2.Position
				end,
				onArrive = function()
					local v4

					if self.activeMood == "PlayerAttack" then
						v4 = self.attackPhaseGen == attackPhaseGen
					else
						v4 = false
					end

					if v4 then
						self._attackEnded = true
					end
				end
			})
		else
			self._attackEnded = true
		end
	end
end

function OllieOtter:CleanupPlayerAttack()
	self:StopMoving()
	self.attackTarget = nil
	self.companion.MoodUninterruptible = false
	self._attackEnded = false
end

function OllieOtter:StartFetch(p)
	local item = p.Item

	if typeof(item) ~= "string" then
		self._fetchEnded = true
		return
	end

	local _GetBobberPosition = self:_GetBobberPosition()

	if not _GetBobberPosition then
		self._fetchEnded = true
		return
	end

	self:SetState("MoodAction")
	self.companion.MoodUninterruptible = true
	self.fetchItem = item
	self.fetchBobberPos = _GetBobberPosition
	self.reelSwimCircling = false
	self.reelSwimBobberPos = _GetBobberPosition

	if (self.companion.RootPart.Position - _GetBobberPosition).Magnitude > 10 then
		self:EnterFetchPhase("ArcIn")
	else
		self:EnterFetchPhase("SearchSwim")
	end
end

function OllieOtter:_RollSearchPoint()
	local v4 = math.random() * 3.141592653589793 * 2
	local v5 = 4 + math.random() * 10
	return self.fetchBobberPos + Vector3.new(math.cos(v4) * v5, 0, math.sin(v4) * v5)
end

function OllieOtter:EnterFetchPhase(p: string)
	self.fetchPhaseGen += 1
	local fetchPhaseGen = self.fetchPhaseGen

	local function stillValid()
		return self.activeMood == "Fetch" and self.fetchPhaseGen == fetchPhaseGen
	end

	if p == "ArcIn" then
		self:StartArc(self:_RollSearchPoint(), function()
			local v4

			if self.activeMood == "Fetch" then
				v4 = self.fetchPhaseGen == fetchPhaseGen
			else
				v4 = false
			end

			if v4 then
				self:EnterFetchPhase("SearchSwim")
			end
		end)
	elseif p == "SearchSwim" then
		self:StartWaterSwim(self:_RollSearchPoint(), 5, function()
			local v4

			if self.activeMood == "Fetch" then
				v4 = self.fetchPhaseGen == fetchPhaseGen
			else
				v4 = false
			end

			if not v4 then
				return
			end

			self.fetchHoldCFrame = self.companion.RootPart.CFrame
			local v5 = 0.5 + math.random() * 0.7
			task.delay(v5, function()
				local v6

				if self.activeMood == "Fetch" then
					v6 = self.fetchPhaseGen == fetchPhaseGen
				else
					v6 = false
				end

				if v6 then
					self.fetchHoldCFrame = nil
					self:EnterFetchPhase("SearchSwim")
				end
			end)
		end)
	elseif p == "Grab" then
		self:StopArc()
		self:StopWaterSwim()
		self:StopMoving()
		self.fetchHoldCFrame = self.companion.RootPart.CFrame
		self:PlayAnimation("Happy")
		self:PlayCuteSound()
		task.delay(1.2, function()
			local v4

			if self.activeMood == "Fetch" then
				v4 = self.fetchPhaseGen == fetchPhaseGen
			else
				v4 = false
			end

			if v4 then
				if self.fetchItem then
					self:SpawnHeldItem(self.fetchItem, 90)
				end

				self.fetchHoldCFrame = nil
				self:EnterFetchPhase("Deliver")
			end
		end)
	elseif p == "Deliver" then
		self:StartWaterSwim(self.fetchBobberPos, 5, function()
			local v4

			if self.activeMood == "Fetch" then
				v4 = self.fetchPhaseGen == fetchPhaseGen
			else
				v4 = false
			end

			if v4 then
				self:RemoveHeldFish()
				self:PlaySound("Dive", true)
				self:EmitParticles("splash", 5)
				self:_ResumeReelPresence()
			end
		end)
	end
end

function OllieOtter:CleanupFetch()
	self:StopArc()
	self:StopMoving()
	self:RemoveHeldFish()
	self.fetchItem = nil
	self.fetchHoldCFrame = nil
	self.fetchBobberMissingSince = nil
	self.companion.MoodUninterruptible = false
	self:_CleanupReelPresence()
end

function OllieOtter:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	self:RemoveHeldFish()
	CompanionBehavior.Destroy(self)
end

return OllieOtter