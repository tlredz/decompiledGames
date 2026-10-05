local createVector = vector.create
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishModel = require(ReplicatedStorage.shared.modules.FishModel)
local v = {
	Sleep = {
		Chance = 30,
		Interval = 18
	},
	Angry = {
		Chance = 25,
		Interval = 15
	},
	Wander = {
		Chance = 40,
		Interval = 12
	}
}
local BeakBill = {}
BeakBill.__index = BeakBill
setmetatable(BeakBill, CompanionBehavior)

function BeakBill.new(p)
	local v2 = CompanionBehavior.new(p)
	setmetatable(v2, BeakBill)
	v2:RegisterMoods(v)
	v2.moodStartTime = 0
	v2.idleTimer = 0
	v2.angryPhaseGen = 0
	v2._angryEnded = false
	v2.roamPhaseGen = 0
	v2.roamSpots = {}
	v2.roamSpotIndex = 0
	v2.roamNapSpot = nil
	v2.roamShouldNap = false
	v2._roamEnded = false
	v2.divePhaseGen = 0
	v2.diveOrigin = createVector(0, 0, 0)
	v2.diveWaterTarget = createVector(0, 0, 0)
	v2.diveFishData = nil
	v2.diveGrantTime = nil
	v2._diveEnded = false
	v2.heldFishModel = nil
	v2.arcStart = createVector(0, 0, 0)
	v2.arcEnd = createVector(0, 0, 0)
	v2.arcHeight = 0
	v2.arcProgress = 0
	v2.arcSpeed = 0
	v2.arcActive = false
	return v2
end

function BeakBill:GetWalkAnimation()
	if self.companion.Animations.Walk then
		return "Walk"
	end

	return "Run"
end

function BeakBill:GetFrontOfCharacterPosition()
	local character = self.companion.Owner.Character

	if not character then
		return nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 5.5
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function evalArc(vector2: Vector3, vector3: Vector3, p: number, p2: number)
	return vector2:Lerp(vector3, p2) + Vector3.new(0, p * 4 * p2 * (1 - p2), 0)
end

function BeakBill:Update(p: number)
	if self.activeMood then
		return nil
	end

	local state = self.companion.State

	if state == "Walking" or state == "Jumping" then
		self.idleTimer = 0
		return nil
	end

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

function BeakBill:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self.moodStartTime = tick()
	self._angryEnded = false
	self._roamEnded = false
	self._diveEnded = false

	if activeMood == "Angry" then
		self:StartAngry()
	elseif activeMood == "Wander" then
		self:StartRoam(p, false)
	elseif activeMood == "Sleep" then
		self:StartRoam(p, true)
	elseif activeMood == "IdleSleep" then
		self:StartIdleSleep()
	elseif activeMood == "Dive" then
		self:StartDive(p)
	end
end

function BeakBill:UpdateMood(p: number)
	self:_TickMovement(p)

	if self.arcActive then
		self.arcProgress += p * self.arcSpeed
		local v2 = math.clamp(self.arcProgress, 0, 1)
		local companion = self.companion
		companion.MoodPositionOverride = evalArc(self.arcStart, self.arcEnd, self.arcHeight, v2)

		if v2 >= 1 then
			self.arcActive = false

			if self._onArcArrive then
				self._onArcArrive()
			end
		end
	end

	if self._angryEnded or self._roamEnded or self._diveEnded then
		return true
	end

	return false
end

function BeakBill:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Angry" then
		self:CleanupAngry()
	elseif self.activeMood == "Wander" or self.activeMood == "Sleep" then
		self:CleanupRoam()
	elseif self.activeMood == "IdleSleep" then
		self:CleanupIdleSleep()
	elseif self.activeMood == "Dive" then
		self:CleanupDive()
	end

	self.activeMood = nil
end

function BeakBill:RequestInterrupt()
	self.idleTimer = 0
	CompanionBehavior.RequestInterrupt(self)
end

function BeakBill:StartArc(arcStart: Vector3, arcEnd: Vector3, arcHeight: number, arcSpeed: number, onArcArrive)
	self.arcStart = arcStart
	self.arcEnd = arcEnd
	self.arcHeight = arcHeight
	self.arcProgress = 0
	self.arcSpeed = arcSpeed
	self.arcActive = true
	self._onArcArrive = onArcArrive
end

function BeakBill:StopArc()
	self.arcActive = false
	self._onArcArrive = nil
end

function BeakBill:StartAngry()
	self:SetState("MoodAction")
	self:EnterAngryPhase("RunToPlayer")
end

function BeakBill:EnterAngryPhase(p: string)
	self.angryPhaseGen += 1
	local angryPhaseGen = self.angryPhaseGen

	local function stillValid()
		return self.activeMood == "Angry" and self.angryPhaseGen == angryPhaseGen
	end

	if p == "RunToPlayer" then
		self:MoveTo(createVector(0, 0, 0), {
			speed = 12,
			animation = "Run",
			arriveRadius = 3.5,
			trackFn = function()
				return self:GetFrontOfCharacterPosition()
			end,
			onArrive = function()
				local v2

				if self.activeMood == "Angry" then
					v2 = self.angryPhaseGen == angryPhaseGen
				else
					v2 = false
				end

				if v2 then
					self:EnterAngryPhase("Squawk")
				end
			end
		})
	elseif p == "Squawk" then
		self:SetFaceOwner(true)
		self:PlayAnimation("Angry")
		self:PlaySound("Angry")
		task.delay(2, function()
			local v2

			if self.activeMood == "Angry" then
				v2 = self.angryPhaseGen == angryPhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterAngryPhase("Sit")
			end
		end)
	elseif p == "Sit" then
		self:SetFaceOwner(true)
		self:PlayAnimation("SitIdle")
		task.delay(1.5, function()
			local v2

			if self.activeMood == "Angry" then
				v2 = self.angryPhaseGen == angryPhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterAngryPhase("WalkAway")
			end
		end)
	elseif p == "WalkAway" then
		self:SetFaceOwner(false)
		local character = self.companion.Owner.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local v2 = humanoidRootPart.CFrame.RightVector * (math.random() > 0.5 and 1 or -1)
			self:MoveTo(self.companion.RootPart.Position + v2 * 6, {
				speed = 5,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v3

					if self.activeMood == "Angry" then
						v3 = self.angryPhaseGen == angryPhaseGen
					else
						v3 = false
					end

					if v3 then
						self._angryEnded = true
					end
				end
			})
		else
			self._angryEnded = true
		end
	end
end

function BeakBill:CleanupAngry()
	self:StopMoving()
	self:SetFaceOwner(false)
end

function BeakBill:StartIdleSleep()
	self:SetState("Sleeping")
	self:PlayAnimation("Sleep")
	self:SetParticles("Sleep/Particle", true)
	self:PlaySound("Snore")
end

function BeakBill:CleanupIdleSleep()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
end

function BeakBill:StartDive(data)
	self:SetState("MoodAction")
	self.diveOrigin = self.companion.RootPart.Position
	self.diveWaterTarget = data.WaterTarget or self.diveOrigin
	self.diveFishData = data.FishData
	self.diveGrantTime = data.GrantTime
	self.companion.MoodIgnoreGroundClamp = true
	self.companion.MoodUninterruptible = true
	self:EnterDivePhase("ArcToWater")
end

function BeakBill:EnterDivePhase(p: string)
	self.divePhaseGen += 1
	local divePhaseGen = self.divePhaseGen

	local function stillValid()
		return self.activeMood == "Dive" and self.divePhaseGen == divePhaseGen
	end

	if p == "ArcToWater" then
		self:PlayAnimation("Fly")
		self:StartArc(
			self.companion.RootPart.Position,
			self.diveWaterTarget + createVector(0, 2, 0),
			18,
			0.4,
			function()
				local v2

				if self.activeMood == "Dive" then
					v2 = self.divePhaseGen == divePhaseGen
				else
					v2 = false
				end

				if v2 then
					self:EnterDivePhase("DiveIn")
				end
			end
		)
	elseif p == "DiveIn" then
		self:PlayAnimation("Dive")
		self:PlaySound("Dive")
		self.companion.MoodPositionOverride = self.diveWaterTarget + createVector(0, -4, 0)
		self.companion.MoodSmoothTime = 0.18
		task.delay(0.15, function()
			local v2

			if self.activeMood == "Dive" then
				v2 = self.divePhaseGen == divePhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EmitSplash()
			end
		end)
		task.delay(0.25, function()
			local v2

			if self.activeMood == "Dive" then
				v2 = self.divePhaseGen == divePhaseGen
			else
				v2 = false
			end

			if v2 then
				self:FadeModel(1, 0.3)
			end
		end)
		task.delay(5, function()
			local v2

			if self.activeMood == "Dive" then
				v2 = self.divePhaseGen == divePhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterDivePhase("Surface")
			end
		end)
	elseif p == "Surface" then
		self.companion.MoodPositionOverride = self.diveWaterTarget + createVector(0, 2, 0)
		self.companion.MoodSmoothTime = 0.18
		self:FadeModel(0, 0.5)
		self:EmitSplash()
		self:PlayAnimation("Fly")
		self:SpawnHeldFish()
		task.delay(0.5, function()
			local v2

			if self.activeMood == "Dive" then
				v2 = self.divePhaseGen == divePhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterDivePhase("ArcBack")
			end
		end)
	elseif p == "ArcBack" then
		local character = self.companion.Owner.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local v2

		if humanoidRootPart then
			v2 = humanoidRootPart.Position
		else
			v2 = self.diveOrigin
		end

		self:StartArc(self.companion.RootPart.Position, v2, 14, 0.5, function()
			local v3

			if self.activeMood == "Dive" then
				v3 = self.divePhaseGen == divePhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterDivePhase("Land")
			end
		end)
	elseif p == "Land" then
		self.companion.MoodIgnoreGroundClamp = false
		self.companion.MoodUninterruptible = false
		self:PlayAnimation("SitIdle")
		task.delay(1, function()
			local v2

			if self.activeMood == "Dive" then
				v2 = self.divePhaseGen == divePhaseGen
			else
				v2 = false
			end

			if v2 then
				self._diveEnded = true
			end
		end)
	end
end

function BeakBill:CleanupDive()
	self:StopArc()
	self.companion.MoodIgnoreGroundClamp = false
	self.companion.MoodUninterruptible = false
	self:FadeModel(0, 0.1)
	self.diveFishData = nil
	self.diveGrantTime = nil
	self._diveEnded = false
end

function BeakBill:SpawnHeldFish()
	if not self.diveFishData then
		return
	end

	local v2 = nil

	for _, attachment in ipairs(self.companion.Model:GetDescendants()) do
		if not (attachment:IsA("Attachment") and attachment.Name == "Mouth") then
			continue
		end

		v2 = attachment
		break
	end

	if not v2 then
		return
	end

	task.spawn(function()
		local heldFishModel = FishModel.Create({
			Name = self.diveFishData.Name,
			ItemData = self.diveFishData,
			ResizeArgs = {
				MaxSize = 5
			},
			RemoveScripts = true,
			CastShadow = false
		})

		if not heldFishModel then
			return
		end

		self:RemoveHeldFish()
		local parent = v2.Parent
		heldFishModel:PivotTo(v2.WorldCFrame * CFrame.Angles(0, 1.5707963267948966, 0))
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = parent
		weldConstraint.Part1 = heldFishModel.PrimaryPart
		weldConstraint.Parent = heldFishModel.PrimaryPart
		heldFishModel.Name = "BeakBillHeldFish"
		heldFishModel.Parent = self.companion.Model
		self.heldFishModel = heldFishModel
		local v5 = not self.diveGrantTime and 30 or math.max(self.diveGrantTime - workspace:GetServerTimeNow(), 0)
		task.delay(v5, function()
			self:RemoveHeldFish()
		end)
	end)
end

function BeakBill:RemoveHeldFish()
	if self.heldFishModel and self.heldFishModel.Parent then
		self.heldFishModel:Destroy()
	end

	self.heldFishModel = nil
end

function BeakBill:FadeModel(transparency: number, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, part in ipairs(self.companion.Model:GetDescendants()) do
		if not part:IsA("BasePart") or part == self.companion.RootPart or self.heldFishModel and part:IsDescendantOf(self.heldFishModel) then
			continue
		end

		TweenService:Create(part, tweenInfo, {
			Transparency = transparency
		}):Play()
	end
end

function BeakBill:EmitSplash()
	local part = Instance.new("Part")
	part.Name = "BeakBillSplash"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Position = self.companion.RootPart.Position
	part.Parent = workspace
	local flag = false

	for _, emitter in ipairs(self.companion.Model:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and string.find(string.lower(emitter.Name), "splash")) then
			continue
		end

		local clone = emitter:Clone()
		clone.Parent = part
		clone:Emit(5)
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

function BeakBill:StartRoam(p, roamShouldNap: boolean)
	self:SetState("MoodAction")
	self.roamSpots = p.WanderSpots or {}
	self.roamNapSpot = p.NapSpot
	self.roamSpotIndex = 0
	self.roamShouldNap = roamShouldNap
	self:EnterRoamPhase("WalkToNextSpot")
end

function BeakBill:EnterRoamPhase(p: string)
	self.roamPhaseGen += 1
	local roamPhaseGen = self.roamPhaseGen

	local function stillValid()
		return (self.activeMood == "Wander" or self.activeMood == "Sleep") and self.roamPhaseGen == roamPhaseGen
	end

	if p == "WalkToNextSpot" then
		self.roamSpotIndex += 1

		if not (self.roamSpotIndex > #self.roamSpots) then
			self:MoveTo(self.roamSpots[self.roamSpotIndex], {
				speed = 5,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v2

					if self.activeMood == "Wander" or self.activeMood == "Sleep" then
						v2 = self.roamPhaseGen == roamPhaseGen
					else
						v2 = false
					end

					if v2 then
						self:EnterRoamPhase("PauseAtSpot")
					end
				end
			})
		elseif self.roamShouldNap then
			self:EnterRoamPhase("WalkToNapSpot")
		else
			self._roamEnded = true
		end
	elseif p == "PauseAtSpot" then
		self:StopMoving()
		self:PlayAnimation("SitIdle")
		task.delay(0.6 + math.random() * 1.6, function()
			local v2

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v2 = self.roamPhaseGen == roamPhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterRoamPhase("WalkToNextSpot")
			end
		end)
	elseif p == "WalkToNapSpot" then
		if self.roamNapSpot then
			self:MoveTo(self.roamNapSpot, {
				speed = 5,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v2

					if self.activeMood == "Wander" or self.activeMood == "Sleep" then
						v2 = self.roamPhaseGen == roamPhaseGen
					else
						v2 = false
					end

					if v2 then
						self:EnterRoamPhase("SitAtNapSpot")
					end
				end
			})
		else
			self._roamEnded = true
		end
	elseif p == "SitAtNapSpot" then
		self:StopMoving()
		self:PlayAnimation("SitIdle")
		task.delay(1.2 + math.random() * 1.3, function()
			local v2

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v2 = self.roamPhaseGen == roamPhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterRoamPhase("Nap")
			end
		end)
	elseif p == "Nap" then
		self:StopMoving()
		self:SetState("Sleeping")
		self:PlayAnimation("Sleep")
		self:SetParticles("Sleep/Particle", true)
		self:PlaySound("Snore")
		task.delay(45, function()
			local v2

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v2 = self.roamPhaseGen == roamPhaseGen
			else
				v2 = false
			end

			if v2 then
				self._roamEnded = true
			end
		end)
	end
end

function BeakBill:CleanupRoam()
	self:StopMoving()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self.roamSpots = {}
	self.roamNapSpot = nil
	self.roamSpotIndex = 0
	self.roamShouldNap = false
	self._roamEnded = false
end

function BeakBill:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	self:RemoveHeldFish()
	CompanionBehavior.Destroy(self)
end

return BeakBill