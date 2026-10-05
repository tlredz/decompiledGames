local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
require(ReplicatedStorage.shared.utils.assets)
local v = {
	Wander = {
		Chance = 40,
		Interval = 15
	},
	Sleep = {
		Chance = 2,
		Interval = 18
	}
}
local LittleMeg = {}
LittleMeg.__index = LittleMeg
setmetatable(LittleMeg, CompanionBehavior)

function LittleMeg.new(p)
	local v2 = CompanionBehavior.new(p)
	setmetatable(v2, LittleMeg)
	v2:RegisterMoods(v)
	v2.moodStartTime = 0
	v2.idleTimer = 0
	v2.ramPhaseGen = 0
	v2._ramEnded = false
	v2.roamPhaseGen = 0
	v2.roamSpots = {}
	v2.roamSpotIndex = 0
	v2.roamNapSpot = nil
	v2.roamShouldNap = false
	v2._roamEnded = false
	v2.scarePhaseGen = 0
	v2.scareOrigin = createVector(0, 0, 0)
	v2.scareFishName = nil
	v2.scareMutation = nil
	v2._scareEnded = false
	v2.companion.AllowWater = true
	v2:UpdateModel()
	return v2
end

function LittleMeg:GetWalkAnimation()
	if self.companion.Animations.Walk then
		return "Walk"
	end

	return "Run"
end

function LittleMeg:Update(p: number)
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

function LittleMeg:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self.moodStartTime = tick()
	self._ramEnded = false
	self._roamEnded = false
	self._scareEnded = false

	if activeMood == "Ram" then
		self:StartRam(p)
	elseif activeMood == "Wander" then
		self:StartRoam(p, false)
	elseif activeMood == "Sleep" then
		self:StartRoam(p, true)
	elseif activeMood == "IdleSleep" then
		self:StartIdleSleep()
	elseif activeMood == "Scare" then
		self:StartScare(p)
	end
end

function LittleMeg:UpdateMood(p: number)
	self:_TickMovement(p)

	if self._ramEnded or self._roamEnded or self._scareEnded then
		return true
	end

	return false
end

function LittleMeg:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Ram" then
		self:CleanupRam()
	elseif self.activeMood == "Wander" or self.activeMood == "Sleep" then
		self:CleanupRoam()
	elseif self.activeMood == "IdleSleep" then
		self:CleanupIdleSleep()
	elseif self.activeMood == "Scare" then
		self:CleanupScare()
	end

	self.activeMood = nil
end

function LittleMeg:RequestInterrupt()
	self.idleTimer = 0
	CompanionBehavior.RequestInterrupt(self)
end

function LittleMeg:UpdateModel()
	if not self.companion.Model then
		print("cant update whit no model!!!!!!!")
		return
	end

	local ancient = self.companion.StateData and self.companion.StateData.Ancient

	for _, instance in self.companion.Model:QueryDescendants(".MegDefaultDetail") do
		if instance:IsA("BasePart") then
			instance.Transparency = ancient and 1 or 0
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") then
			instance.Transparency = ancient and NumberSequence.new(1) or instance:GetAttribute("OriginalTransparency") or NumberSequence.new(0)
		end
	end

	for _, instance in self.companion.Model:QueryDescendants(".AncientPowerDetail") do
		if instance:IsA("BasePart") then
			instance.Transparency = ancient and 0 or 1
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") then
			instance.Transparency = ancient and (instance:GetAttribute("OriginalTransparency") or NumberSequence.new(0)) or NumberSequence.new(1)
		end
	end
end

function LittleMeg:SetStateData(_)
	self:UpdateModel()
end

function LittleMeg:StartRam(p)
	self:SetState("MoodAction")
	self.companion.MoodUninterruptible = true
	self:EnterRamPhase("RunToPlayer", p)
end

function LittleMeg:EnterRamPhase(p: string, p2)
	self.ramPhaseGen += 1
	local ramPhaseGen = self.ramPhaseGen

	local function stillValid()
		return self.activeMood == "Ram" and self.ramPhaseGen == ramPhaseGen
	end

	local character = self.companion.Owner.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		self._ramEnded = true
		return
	end

	local v2 = (p2.TargetWater - humanoidRootPart.Position) * createVector(1, 0, 1)

	if p == "RunToPlayer" then
		self:MoveTo(createVector(0, 0, 0), {
			speed = 10,
			animation = "Run",
			arriveRadius = 2.5,
			trackFn = function()
				return humanoidRootPart.Position + v2.Unit * -3.5
			end,
			onArrive = function()
				local v3

				if self.activeMood == "Ram" then
					v3 = self.ramPhaseGen == ramPhaseGen
				else
					v3 = false
				end

				if v3 then
					self:EnterRamPhase("PlayRamAnim", p2)
				end
			end
		})
	elseif p == "PlayRamAnim" then
		self:SetFaceOwner(true)
		self:PlayAnimation("Ram")

		if self.companion.IsOwner then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if not humanoid then
				self._ramEnded = true
				return
			end

			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			humanoidRootPart:ApplyImpulse(v2 * humanoidRootPart.AssemblyMass * 2 + Vector3.new(
				0,
				25 * humanoidRootPart.AssemblyMass,
				0
			))
			task.delay(1.2, function()
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end)
		end

		task.delay(1.2, function()
			local v3

			if self.activeMood == "Ram" then
				v3 = self.ramPhaseGen == ramPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterRamPhase("Sit", p2)
			end
		end)
	elseif p == "Sit" then
		self:SetFaceOwner(true)
		self:PlayAnimation("SitIdle")
		task.delay(3, function()
			local v3

			if self.activeMood == "Ram" then
				v3 = self.ramPhaseGen == ramPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterRamPhase("WalkAway", p2)
			end
		end)
	elseif p == "WalkAway" then
		self:SetFaceOwner(false)
		local character2 = self.companion.Owner.Character
		local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 then
			local v3 = humanoidRootPart2.CFrame.RightVector * (math.random() > 0.5 and 1 or -1)
			self:MoveTo(self.companion.RootPart.Position + v3 * 5, {
				speed = 5,
				animation = "Run",
				arriveRadius = 1.5,
				onArrive = function()
					local v4

					if self.activeMood == "Ram" then
						v4 = self.ramPhaseGen == ramPhaseGen
					else
						v4 = false
					end

					if v4 then
						self._ramEnded = true
					end
				end
			})
		else
			self._ramEnded = true
		end
	end
end

function LittleMeg:CleanupRam()
	self.companion.MoodUninterruptible = false
	self:StopMoving()
	self:SetFaceOwner(false)
end

function LittleMeg:StartIdleSleep()
	self:SetState("Sleeping")
	self:PlayAnimation("SleepIdle")
	self:SetParticles("Sleep/Particle", true)
	self:PlaySound("Snore")
end

function LittleMeg:CleanupIdleSleep()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self:PlaySound("Meow", true)
end

function LittleMeg:StartRoam(p, roamShouldNap: boolean)
	self:SetState("MoodAction")
	self.roamSpots = p.WanderSpots or {}
	self.roamNapSpot = p.NapSpot
	self.roamSpotIndex = 0
	self.roamShouldNap = roamShouldNap
	self:EnterRoamPhase("WalkToNextSpot")
end

function LittleMeg:EnterRoamPhase(p: string)
	self.roamPhaseGen += 1
	local roamPhaseGen = self.roamPhaseGen

	local function stillValid()
		return (self.activeMood == "Wander" or self.activeMood == "Sleep") and self.roamPhaseGen == roamPhaseGen
	end

	if p == "WalkToNextSpot" then
		self.roamSpotIndex += 1

		if not (self.roamSpotIndex > #self.roamSpots) then
			self:MoveTo(self.roamSpots[self.roamSpotIndex], {
				speed = 10,
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
		local v2 = 0.6 + math.random() * 1.6
		task.delay(v2, function()
			local v3

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v3 = self.roamPhaseGen == roamPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterRoamPhase("WalkToNextSpot")
			end
		end)
	elseif p == "WalkToNapSpot" then
		if self.roamNapSpot then
			self:MoveTo(self.roamNapSpot, {
				speed = 10,
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
		local v2 = 1.2 + math.random() * 1.3
		task.delay(v2, function()
			local v3

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v3 = self.roamPhaseGen == roamPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterRoamPhase("Nap")
			end
		end)
	elseif p == "Nap" then
		self:StopMoving()
		self:SetState("Sleeping")
		self:PlayAnimation("SleepIdle")
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

function LittleMeg:CleanupRoam()
	self:StopMoving()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self.roamSpots = {}
	self.roamNapSpot = nil
	self.roamSpotIndex = 0
	self.roamShouldNap = false
	self._roamEnded = false
end

function LittleMeg:StartScare(p)
	self:SetState("MoodAction")
	self.swimSpots = p.MovePoints or {}
	self.swimStartSpot = p.StartPoint
	self.swimSpotIndex = 0
	self.companion.MoodIgnoreGroundClamp = true
	self.companion.MoodUninterruptible = true
	self:EnterScarePhase("WalkToFirstSpot")
end

function LittleMeg:EnterScarePhase(p: string)
	self.scarePhaseGen += 1
	local swimPhaseGen = self.swimPhaseGen

	local function stillValid()
		return self.activeMood == "Scare" and self.swimPhaseGen == swimPhaseGen
	end

	if p == "WalkToFirstSpot" then
		self:MoveTo(self.swimStartSpot, {
			speed = 24,
			animation = "Dive",
			arriveRadius = 1.5,
			freeYMovement = true,
			onArrive = function()
				local v2

				if self.activeMood == "Scare" then
					v2 = self.swimPhaseGen == swimPhaseGen
				else
					v2 = false
				end

				if v2 then
					self:EnterScarePhase("WalkToNextSpot")
				end
			end
		})
	elseif p == "WalkToNextSpot" then
		self.swimSpotIndex += 1

		if self.swimSpotIndex > #self.swimSpots then
			self._scareEnded = true
		else
			self:MoveTo(self.swimSpots[self.swimSpotIndex].Position, {
				speed = 6,
				animation = "Swim",
				arriveRadius = 1.5,
				freeYMovement = true,
				onArrive = function()
					local v2

					if self.activeMood == "Scare" then
						v2 = self.swimPhaseGen == swimPhaseGen
					else
						v2 = false
					end

					if v2 then
						self:EnterScarePhase("WalkToNextSpot")
					end
				end
			})
		end
	end
end

function LittleMeg:CleanupScare()
	self:StopMoving()
	self.swimSpots = {}
	self.swimSpotIndex = 0
	self._scareEnded = false
	self.companion.MoodIgnoreGroundClamp = false
	self.companion.MoodUninterruptible = false
end

function LittleMeg:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return LittleMeg