local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
require(ReplicatedStorage.shared.utils.assets)
require(ReplicatedStorage.packages.Trove)
local v = {
	Spin = {
		Chance = 10,
		Interval = 10
	},
	Wander = {
		Chance = 15,
		Interval = 15
	},
	Sleep = {
		Chance = 12,
		Interval = 18
	}
}
local MutatedSharky = {}
MutatedSharky.__index = MutatedSharky
setmetatable(MutatedSharky, CompanionBehavior)

function MutatedSharky.new(p)
	local v2 = CompanionBehavior.new(p)
	setmetatable(v2, MutatedSharky)
	v2:RegisterMoods(v)
	v2.moodStartTime = 0
	v2.idleTimer = 0
	v2.roamPhaseGen = 0
	v2.roamSpots = {}
	v2.roamSpotIndex = 0
	v2.roamNapSpot = nil
	v2.roamShouldNap = false
	v2._roamEnded = false
	v2.companion.AllowWater = true
	return v2
end

function MutatedSharky:GetWalkAnimation()
	if self.companion.Animations.Walk then
		return "Walk"
	end

	return "Run"
end

function MutatedSharky:Update(p: number)
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

function MutatedSharky:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self.moodStartTime = tick()
	self._ramEnded = false
	self._roamEnded = false
	self._whirlpoolEnded = false

	if activeMood == "Wander" then
		self:StartRoam(p, false)
	elseif activeMood == "Sleep" then
		self:StartRoam(p, true)
	elseif activeMood == "IdleSleep" then
		self:StartIdleSleep()
	elseif activeMood == "Whirlpool" then
		self:StartWhirlpool(p)
	end
end

function MutatedSharky:UpdateMood(p: number)
	if self.activeMood == "Whirlpool" then
		self:_TickWhirlpool(p)
	else
		self:_TickMovement(p)
	end

	if self._roamEnded or self._whirlpoolEnded then
		return true
	end

	return false
end

function MutatedSharky:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Wander" or self.activeMood == "Sleep" then
		self:CleanupRoam()
	elseif self.activeMood == "IdleSleep" then
		self:CleanupIdleSleep()
	elseif self.activeMood == "Whirlpool" then
		self:CleanupWhirlpool()
	end

	self.activeMood = nil
end

function MutatedSharky:RequestInterrupt()
	self.idleTimer = 0
	CompanionBehavior.RequestInterrupt(self)
end

function MutatedSharky:StartIdleSleep()
	self:SetState("Sleeping")
	self:PlayAnimation("SleepIdle")
	self:SetParticles("Sleep/Particle", true)
	self:PlaySound("Snore")
end

function MutatedSharky:CleanupIdleSleep()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self:PlaySound("Meow", true)
end

function MutatedSharky:StartRoam(p, roamShouldNap: boolean)
	self:SetState("MoodAction")
	self.roamSpots = p.WanderSpots or {}
	self.roamNapSpot = p.NapSpot
	self.roamSpotIndex = 0
	self.roamShouldNap = roamShouldNap
	self:EnterRoamPhase("WalkToNextSpot")
end

function MutatedSharky:EnterRoamPhase(p: string)
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

function MutatedSharky:CleanupRoam()
	self:StopMoving()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self.roamSpots = {}
	self.roamNapSpot = nil
	self.roamSpotIndex = 0
	self.roamShouldNap = false
	self._roamEnded = false
end

function MutatedSharky:StartWhirlpool(p)
	self:SetState("MoodAction")
	self.whirlpoolCenter = p.Center
	self.companion.MoodIgnoreGroundClamp = true
	self.companion.MoodUninterruptible = true
	self.companion.MoodSmoothTime = 0.1
	self.whirlpoolElapsed = 0
end

function MutatedSharky:_TickWhirlpool(p: number)
	if not self.whirlpoolCenter or self.whirlpoolElapsed > 60 then
		self._whirlpoolEnded = true
		return
	end

	self.whirlpoolElapsed += p
	local v2 = CFrame.new(self.whirlpoolCenter) * CFrame.fromOrientation(0, math.rad(self.whirlpoolElapsed * -90), 0)
	self.companion.MoodPositionOverride = (v2 * CFrame.new(0, 0, 10)).Position
	self.companion.MoodSmoothTime = 0.1
end

function MutatedSharky:CleanupWhirlpool()
	self:StopMoving()
	self.whirlpoolCenter = nil
	self._whirlpoolEnded = false
	self.companion.MoodIgnoreGroundClamp = false
	self.companion.MoodUninterruptible = false
end

function MutatedSharky:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return MutatedSharky