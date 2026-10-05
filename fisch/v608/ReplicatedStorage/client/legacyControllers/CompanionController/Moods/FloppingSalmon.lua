local createVector = vector.create
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local v = {
	Wander = {
		Chance = 60,
		Interval = 6
	},
	FlopBurst = {
		Chance = 50,
		Interval = 4
	},
	HopInWater = {
		Chance = 0,
		Interval = 1e999
	}
}
local FloppingSalmon = {}
FloppingSalmon.__index = FloppingSalmon
setmetatable(FloppingSalmon, CompanionBehavior)

function FloppingSalmon.new(p)
	local v2 = CompanionBehavior.new(p)
	setmetatable(v2, FloppingSalmon)
	v2:RegisterMoods(v)
	v2.moodStartTime = 0
	v2.wanderPhaseGen = 0
	v2.wanderSpots = {}
	v2.wanderSpotIndex = 0
	v2._wanderEnded = false
	v2.flopPhaseGen = 0
	v2._flopEnded = false
	v2.hopPhaseGen = 0
	v2.hopCenter = nil
	v2.hopElapsed = 0
	v2.hopPhase = "Idle"
	v2._hopEnded = false
	return v2
end

function FloppingSalmon:GetWalkAnimation()
	if self.companion.Animations.Walk then
		return "Walk"
	end

	return "Run"
end

function FloppingSalmon:EmitParticle(value: string, value2: number?)
	local part = Instance.new("Part")
	part.Name = "FloppingSalmonFX"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Position = self.companion.RootPart.Position
	part.Parent = workspace
	local v2 = string.split(value, "/")
	local model = self.companion.Model
	local flag = false

	for _, childName in ipairs(v2) do
		if not model then
			break
		end

		model = model:FindFirstChild(childName, true)
	end

	if model and model:IsA("ParticleEmitter") then
		local clone = model:Clone()
		clone.Parent = part
		clone:Emit(value2 or 5)
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

function FloppingSalmon.Update(object, p: number)
	if object.activeMood then
		return nil
	end

	local state = object.companion.State

	if state == "Walking" or state == "Jumping" then
		return nil
	end

	local rollMoods = object:RollMoods(p)
	return rollMoods or nil
end

function FloppingSalmon:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self.moodStartTime = tick()
	self._wanderEnded = false
	self._flopEnded = false
	self._hopEnded = false

	if activeMood == "Wander" then
		self:StartWander(p)
	elseif activeMood == "FlopBurst" then
		self:StartFlopBurst()
	elseif activeMood == "HopInWater" then
		self:StartHopInWater(p)
	end
end

function FloppingSalmon:UpdateMood(p: number)
	if self.activeMood == "HopInWater" and self.hopPhase == "Swimming" then
		self:_TickHopSwim(p)
	else
		self:_TickMovement(p)
	end

	if self._wanderEnded or self._flopEnded or self._hopEnded then
		return true
	end

	return false
end

function FloppingSalmon:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Wander" then
		self:CleanupWander()
	elseif self.activeMood == "FlopBurst" then
		self:CleanupFlopBurst()
	elseif self.activeMood == "HopInWater" then
		self:CleanupHopInWater()
	end

	self.activeMood = nil
end

function FloppingSalmon.RequestInterrupt(p)
	CompanionBehavior.RequestInterrupt(p)
end

function FloppingSalmon:StartWander(p)
	self:SetState("MoodAction")
	self.wanderSpots = p.WanderSpots or {}
	self.wanderSpotIndex = 0
	self:EnterWanderPhase("WalkToNextSpot")
end

function FloppingSalmon:EnterWanderPhase(p: string)
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
				speed = 6,
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
		self:PlayAnimation("SitIdle")
		task.delay(0.4 + math.random() * 0.7999999999999999, function()
			local v2

			if self.activeMood == "Wander" then
				v2 = self.wanderPhaseGen == wanderPhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterWanderPhase("WalkToNextSpot")
			end
		end)
	end
end

function FloppingSalmon:CleanupWander()
	self:StopMoving()
	self.wanderSpots = {}
	self.wanderSpotIndex = 0
	self._wanderEnded = false
end

function FloppingSalmon:StartFlopBurst()
	self:SetState("MoodAction")
	self:StopMoving()
	self:PlayAnimation("HappyHops")
	self:PlaySound("Jump")
	self:EmitParticle("JumpFX/Particle")
	self.flopPhaseGen += 1
	local flopPhaseGen = self.flopPhaseGen
	task.delay(1.5, function()
		if self.activeMood == "FlopBurst" and self.flopPhaseGen == flopPhaseGen then
			self._flopEnded = true
		end
	end)
end

function FloppingSalmon:CleanupFlopBurst()
	self:PlaySound("Land")
	self._flopEnded = false
end

function FloppingSalmon:StartHopInWater(p)
	self:SetState("MoodAction")
	local center = p.Center

	if not center then
		self._hopEnded = true
		return
	end

	self.hopCenter = center
	self.hopElapsed = 0
	self.hopPhase = "Idle"
	self.companion.MoodIgnoreGroundClamp = true
	self.companion.MoodUninterruptible = true
	self.companion.AllowWater = true
	self:EnterHopPhase("HopToWater")
end

function FloppingSalmon:EnterHopPhase(p: string)
	self.hopPhaseGen += 1
	local hopPhaseGen = self.hopPhaseGen

	local function stillValid()
		return self.activeMood == "HopInWater" and self.hopPhaseGen == hopPhaseGen
	end

	if p == "HopToWater" then
		if not self.hopCenter then
			self._hopEnded = true
			return
		end

		self.hopPhase = "Hopping"
		self:PlaySound("Jump")
		self:EmitParticle("JumpFX/Particle")
		self:MoveTo(self.hopCenter + createVector(6, 0, 0), {
			speed = 20,
			animation = "Dive",
			arriveRadius = 2,
			freeYMovement = true,
			onArrive = function()
				local v2

				if self.activeMood == "HopInWater" then
					v2 = self.hopPhaseGen == hopPhaseGen
				else
					v2 = false
				end

				if v2 then
					self:EnterHopPhase("Swimming")
				end
			end
		})
	elseif p == "Swimming" then
		self:StopMoving()
		self:PlayAnimation("Swim")
		self.hopPhase = "Swimming"
		self.companion.MoodSmoothTime = 0.1
		self:PlaySound("Dive")
		self:EmitParticle("Splash")
	end
end

function FloppingSalmon:_TickHopSwim(p: number)
	if not self.hopCenter then
		self._hopEnded = true
		return
	end

	self.hopElapsed += p
	local position = (CFrame.new(self.hopCenter) * CFrame.fromOrientation(0, math.rad(self.hopElapsed * -90), 0) * CFrame.new(
		0,
		0,
		6
	)).Position
	self.companion.MoodPositionOverride = position
	self.companion.MoodSmoothTime = 0.1
end

function FloppingSalmon:CleanupHopInWater()
	self:StopMoving()
	self.hopCenter = nil
	self.hopElapsed = 0
	self.hopPhase = "Idle"
	self._hopEnded = false
	self.companion.MoodIgnoreGroundClamp = false
	self.companion.MoodUninterruptible = false
	self.companion.AllowWater = false
	self.companion.MoodPositionOverride = nil
end

function FloppingSalmon:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return FloppingSalmon