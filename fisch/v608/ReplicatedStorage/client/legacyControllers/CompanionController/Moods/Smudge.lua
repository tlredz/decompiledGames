local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
require(ReplicatedStorage.shared.utils.assets)
local v = {
	Spin = {
		Chance = 2,
		Interval = 50
	},
	Sleep = {
		Chance = 30,
		Interval = 18
	}
}
local Smudge = {}
Smudge.__index = Smudge
setmetatable(Smudge, CompanionBehavior)

function Smudge.new(p)
	local v2 = CompanionBehavior.new(p)
	setmetatable(v2, Smudge)
	v2:RegisterMoods(v)
	v2.moodStartTime = 0
	v2.idleTimer = 0
	v2._spinEnded = false
	v2.roamPhaseGen = 0
	v2.roamSpots = {}
	v2.roamSpotIndex = 0
	v2.roamNapSpot = nil
	v2.roamShouldNap = false
	v2._roamEnded = false
	v2.divePhaseGen = 0
	v2.diveOrigin = createVector(0, 0, 0)
	v2.diveFishName = nil
	v2.diveMutation = nil
	v2._diveEnded = false
	return v2
end

function Smudge:GetWalkAnimation()
	if self.companion.Animations.Walk then
		return "Walk"
	end

	return "Run"
end

function Smudge:Update(p: number)
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

function Smudge:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self.moodStartTime = tick()
	self._spinEnded = false
	self._roamEnded = false
	self._diveEnded = false

	if activeMood == "Spin" then
		self:StartSpin()
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

function Smudge:UpdateMood(p: number)
	self:_TickMovement(p)

	if self._spinEnded or self._roamEnded or self._diveEnded then
		return true
	end

	return false
end

function Smudge:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Spin" then
		self:CleanupSpin()
	elseif self.activeMood == "Wander" or self.activeMood == "Sleep" then
		self:CleanupRoam()
	elseif self.activeMood == "IdleSleep" then
		self:CleanupIdleSleep()
	elseif self.activeMood == "Dive" then
		self:CleanupDive()
	end

	self.activeMood = nil
end

function Smudge:RequestInterrupt()
	self.idleTimer = 0
	CompanionBehavior.RequestInterrupt(self)
end

function Smudge:StartSpin()
	self:SetState("MoodAction")
	self:PlayAnimation("Spin")
	task.delay(3, function()
		if self.activeMood == "Spin" then
			self._spinEnded = true
		end
	end)
end

function Smudge:CleanupSpin()
	self:StopMoving()
	self:SetFaceOwner(false)
	self.companion.MoodUninterruptible = false
end

function Smudge:StartIdleSleep()
	self:SetState("Sleeping")
	self:PlayAnimation("SleepIdle")
	self:SetParticles("Sleep/Particle", true)
	self:PlaySound("Snore")
end

function Smudge:CleanupIdleSleep()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self:PlaySound("Meow", true)
end

function Smudge:StartRoam(p, roamShouldNap: boolean)
	self:SetState("MoodAction")
	self.roamSpots = p.WanderSpots or {}
	self.roamNapSpot = p.NapSpot
	self.roamSpotIndex = 0
	self.roamShouldNap = roamShouldNap
	self:EnterRoamPhase("WalkToNextSpot")
end

function Smudge:EnterRoamPhase(p: string)
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

function Smudge:CleanupRoam()
	self:StopMoving()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self.roamSpots = {}
	self.roamNapSpot = nil
	self.roamSpotIndex = 0
	self.roamShouldNap = false
	self._roamEnded = false
end

function Smudge:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return Smudge