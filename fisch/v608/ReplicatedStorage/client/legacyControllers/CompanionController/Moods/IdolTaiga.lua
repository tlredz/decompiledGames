local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local v = {
	Wander = {
		Chance = 20,
		Interval = 20
	}
}
local IdolTaiga = {}
IdolTaiga.__index = IdolTaiga
setmetatable(IdolTaiga, CompanionBehavior)

function IdolTaiga.new(p)
	local v2 = CompanionBehavior.new(p)
	setmetatable(v2, IdolTaiga)
	v2:RegisterMoods(v)
	v2.moodStartTime = 0
	v2.wanderPhaseGen = 0
	v2.wanderSpots = {}
	v2.wanderSpotIndex = 0
	v2._wanderEnded = false
	return v2
end

function IdolTaiga:GetWalkAnimation()
	if self.companion.Animations.Walk then
		return "Walk"
	end

	return "Run"
end

function IdolTaiga:GetPauseAnimation()
	if self.companion.Animations.SitIdle then
		return "SitIdle"
	end

	return "Idle"
end

function IdolTaiga.Update(object, p: number)
	if object.activeMood then
		return nil
	end

	local state = object.companion.State

	if state == "Walking" or state == "Jumping" then
		return nil
	end

	return object:RollMoods(p)
end

function IdolTaiga:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self.moodStartTime = tick()
	self._wanderEnded = false

	if activeMood == "Wander" then
		self:StartWander(p)
	end
end

function IdolTaiga:UpdateMood(p: number)
	self:_TickMovement(p)

	if self._wanderEnded then
		return true
	end

	return false
end

function IdolTaiga:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Wander" then
		self:CleanupWander()
	end

	self.activeMood = nil
end

function IdolTaiga.RequestInterrupt(p)
	CompanionBehavior.RequestInterrupt(p)
end

function IdolTaiga:StartWander(p)
	self:SetState("MoodAction")
	self.wanderSpots = p.WanderSpots or {}
	self.wanderSpotIndex = 0

	if #self.wanderSpots == 0 then
		self._wanderEnded = true
	else
		self:EnterWanderPhase("WalkToNextSpot")
	end
end

function IdolTaiga:EnterWanderPhase(p: string)
	self.wanderPhaseGen += 1
	local wanderPhaseGen = self.wanderPhaseGen

	local function stillValid()
		return self.activeMood == "Wander" and self.wanderPhaseGen == wanderPhaseGen
	end

	if p == "WalkToNextSpot" then
		self.wanderSpotIndex += 1

		if self.wanderSpotIndex > #self.wanderSpots then
			self._wanderEnded = true
		else
			self:MoveTo(self.wanderSpots[self.wanderSpotIndex], {
				speed = 4,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v2

					if self.activeMood == "Wander" then
						v2 = self.wanderPhaseGen == wanderPhaseGen
					else
						v2 = false
					end

					if v2 then
						self:EnterWanderPhase("PauseAtSpot")
					end
				end
			})
		end
	elseif p == "PauseAtSpot" then
		self:StopMoving()
		self:PlayAnimation(self:GetPauseAnimation())
		local v2 = 1 + math.random() * 1.5
		task.delay(v2, function()
			local v3

			if self.activeMood == "Wander" then
				v3 = self.wanderPhaseGen == wanderPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterWanderPhase("WalkToNextSpot")
			end
		end)
	end
end

function IdolTaiga:CleanupWander()
	self:StopMoving()
	self.wanderSpots = {}
	self.wanderSpotIndex = 0
	self._wanderEnded = false
end

function IdolTaiga:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return IdolTaiga