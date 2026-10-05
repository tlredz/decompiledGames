local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("Companion/RequestMood")
local bindable_reel_finished = ReplicatedStorage.events.bindable_reel_finished
local v = {
	Wander = {
		Chance = 40,
		Interval = 12
	},
	Sleep = {
		Chance = 25,
		Interval = 18
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function evalArc(vector2: Vector3, vector3: Vector3, p: number, p2: number)
	return vector2:Lerp(vector3, p2) + Vector3.new(0, p * 4 * p2 * (1 - p2), 0)
end

local Mosswaddler = {}
Mosswaddler.__index = Mosswaddler
setmetatable(Mosswaddler, CompanionBehavior)

function Mosswaddler.new(p)
	local v2 = CompanionBehavior.new(p)
	setmetatable(v2, Mosswaddler)
	v2:RegisterMoods(v)
	v2.moodStartTime = 0
	v2.idleTimer = 0
	v2.wanderPhaseGen = 0
	v2.wanderSpots = {}
	v2.wanderSpotIndex = 0
	v2.wanderNapSpot = nil
	v2.wanderShouldNap = false
	v2._wanderEnded = false
	v2.distractPhaseGen = 0
	v2.distractOrigin = createVector(0, 0, 0)
	v2.distractBobberPos = nil
	v2.distractStandoff = nil
	v2._distractEnded = false
	v2._flopping = false
	v2._flopElapsed = 0
	v2.bouncePhaseGen = 0
	v2._bounceEnded = false
	v2.arcStart = createVector(0, 0, 0)
	v2.arcEnd = createVector(0, 0, 0)
	v2.arcHeight = 0
	v2.arcProgress = 0
	v2.arcSpeed = 0
	v2.arcActive = false
	v2._onArcArrive = nil

	if v2.companion.IsOwner then
		v2.trove:Add(bindable_reel_finished.Event:Connect(function(flag: boolean)
			if not flag or v2.activeMood or math.random(1, 100) > 30 then
				return
			end

			remoteEvent:FireServer("Bounce")
		end))
	end

	return v2
end

function Mosswaddler:GetWalkAnimation()
	if self.companion.Animations.Walk then
		return "Walk"
	end

	return "Run"
end

function Mosswaddler:_PlayHop()
	self:PlayAnimation("Jump")
end

function Mosswaddler:_PlayDive()
	self:PlayAnimation("Dive")
end

function Mosswaddler:_PlayFlop()
	self:PlayAnimation("Distract")
end

function Mosswaddler:_PlayBounce()
	self:PlayAnimation("Happy")
	self:PlaySound("Happy", true)
end

function Mosswaddler:_GetBobberPosition()
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

function Mosswaddler:_ComputeStandoff(vector2: Vector3)
	local v2 = math.random() * 3.141592653589793 * 2
	local v3 = vector2.Y + -1
	local v4 = math.cos(v2) * 6.5
	local v5 = math.sin(v2) * 6.5
	return (Vector3.new(vector2.X + v4, v3, vector2.Z + v5))
end

function Mosswaddler:StartArc(arcStart: Vector3, arcEnd: Vector3, arcHeight: number, arcSpeed: number, onArcArrive)
	self.arcStart = arcStart
	self.arcEnd = arcEnd
	self.arcHeight = arcHeight
	self.arcProgress = 0
	self.arcSpeed = arcSpeed
	self.arcActive = true
	self._onArcArrive = onArcArrive
end

function Mosswaddler:StopArc()
	self.arcActive = false
	self._onArcArrive = nil
end

function Mosswaddler:Update(p: number)
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

function Mosswaddler:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self.moodStartTime = tick()
	self._wanderEnded = false
	self._distractEnded = false
	self._bounceEnded = false

	if activeMood == "Wander" then
		self:StartWander(p, false)
	elseif activeMood == "Sleep" then
		self:StartWander(p, true)
	elseif activeMood == "IdleSleep" then
		self:StartIdleSleep()
	elseif activeMood == "Distraction" then
		self:StartDistraction()
	elseif activeMood == "Bounce" then
		self:StartBounce()
	end
end

function Mosswaddler:UpdateMood(p: number)
	self:_TickMovement(p)

	if self.arcActive then
		self.arcProgress += p * self.arcSpeed
		local v2 = math.clamp(self.arcProgress, 0, 1)
		local companion = self.companion
		companion.MoodPositionOverride = evalArc(self.arcStart, self.arcEnd, self.arcHeight, v2)
		self.companion.MoodSmoothTime = 0.07

		if v2 >= 1 then
			self.arcActive = false
			local _onArcArrive = self._onArcArrive
			self._onArcArrive = nil

			if _onArcArrive then
				_onArcArrive()
			end
		end
	elseif self._flopping then
		self._flopElapsed += p
		local distractStandoff = self.distractStandoff or self.distractOrigin
		local v2 = math.abs((math.sin(self._flopElapsed * 14))) * 0.55
		local vector2 = Vector3.new(math.sin(self._flopElapsed * 13) * 0.35, 0, math.cos(self._flopElapsed * 11) * 0.35)
		self.companion.MoodPositionOverride = distractStandoff + vector2 + Vector3.new(0, v2, 0)
		self.companion.MoodSmoothTime = 0.12
	end

	if self._wanderEnded or self._distractEnded or self._bounceEnded then
		return true
	end

	return false
end

function Mosswaddler:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Wander" or self.activeMood == "Sleep" then
		self:CleanupWander()
	elseif self.activeMood == "IdleSleep" then
		self:CleanupIdleSleep()
	elseif self.activeMood == "Distraction" then
		self:CleanupDistraction()
	elseif self.activeMood == "Bounce" then
		self:CleanupBounce()
	end

	self.activeMood = nil
end

function Mosswaddler:RequestInterrupt()
	self.idleTimer = 0
	CompanionBehavior.RequestInterrupt(self)
end

function Mosswaddler:StartWander(p, wanderShouldNap: boolean)
	self:SetState("MoodAction")
	self.wanderSpots = p.WanderSpots or {}
	self.wanderNapSpot = p.NapSpot
	self.wanderSpotIndex = 0
	self.wanderShouldNap = wanderShouldNap

	if #self.wanderSpots ~= 0 then
		self:EnterWanderPhase("WalkToNextSpot")
	elseif wanderShouldNap then
		self:EnterWanderPhase("Nap")
	else
		self._wanderEnded = true
	end
end

function Mosswaddler:EnterWanderPhase(p: string)
	self.wanderPhaseGen += 1
	local wanderPhaseGen = self.wanderPhaseGen

	local function stillValid()
		return (self.activeMood == "Wander" or self.activeMood == "Sleep") and self.wanderPhaseGen == wanderPhaseGen
	end

	if p == "WalkToNextSpot" then
		self.wanderSpotIndex += 1

		if not (self.wanderSpotIndex > #self.wanderSpots) then
			self:MoveTo(self.wanderSpots[self.wanderSpotIndex], {
				speed = 5,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v2

					if self.activeMood == "Wander" or self.activeMood == "Sleep" then
						v2 = self.wanderPhaseGen == wanderPhaseGen
					else
						v2 = false
					end

					if v2 then
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
		local v2 = 0.6 + math.random() * 1.4
		task.delay(v2, function()
			local v3

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v3 = self.wanderPhaseGen == wanderPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterWanderPhase("WalkToNextSpot")
			end
		end)
	elseif p == "WalkToNapSpot" then
		if self.wanderNapSpot then
			self:MoveTo(self.wanderNapSpot, {
				speed = 5,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v2

					if self.activeMood == "Wander" or self.activeMood == "Sleep" then
						v2 = self.wanderPhaseGen == wanderPhaseGen
					else
						v2 = false
					end

					if v2 then
						self:EnterWanderPhase("SitBeforeNap")
					end
				end
			})
		else
			self:EnterWanderPhase("Nap")
		end
	elseif p == "SitBeforeNap" then
		self:StopMoving()
		self:PlayAnimation("SitIdle")
		local v2 = 1 + math.random() * 1
		task.delay(v2, function()
			local v3

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v3 = self.wanderPhaseGen == wanderPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterWanderPhase("Nap")
			end
		end)
	elseif p == "Nap" then
		self:StopMoving()
		self:SetState("Sleeping")
		self:PlayAnimation("SleepIdle")
		self:SetParticles("Sleep/Particle", true)
		self:PlaySound("Snore")
		task.delay(12, function()
			local v2

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v2 = self.wanderPhaseGen == wanderPhaseGen
			else
				v2 = false
			end

			if v2 then
				self._wanderEnded = true
			end
		end)
	end
end

function Mosswaddler:CleanupWander()
	self:StopMoving()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self.wanderSpots = {}
	self.wanderNapSpot = nil
	self.wanderSpotIndex = 0
	self.wanderShouldNap = false
	self._wanderEnded = false
end

function Mosswaddler:StartIdleSleep()
	self:SetState("Sleeping")
	self:PlayAnimation("SleepIdle")
	self:SetParticles("Sleep/Particle", true)
	self:PlaySound("Snore")
end

function Mosswaddler:CleanupIdleSleep()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
end

function Mosswaddler:StartDistraction()
	self:SetState("MoodAction")
	self.distractOrigin = self.companion.RootPart.Position
	self.distractBobberPos = self:_GetBobberPosition()
	self._flopElapsed = 0
	self.companion.MoodIgnoreGroundClamp = true
	self.companion.MoodUninterruptible = true
	self:EnterDistractionPhase("HopToWater")
end

function Mosswaddler:EnterDistractionPhase(p: string)
	self.distractPhaseGen += 1
	local distractPhaseGen = self.distractPhaseGen

	local function stillValid()
		return self.activeMood == "Distraction" and self.distractPhaseGen == distractPhaseGen
	end

	local companion = self.companion

	if p == "HopToWater" then
		self.distractStandoff = self:_ComputeStandoff(self.distractBobberPos or self.distractOrigin)
		self:_PlayDive()
		self:PlaySound("Jump", true)
		self:StartArc(companion.RootPart.Position, self.distractStandoff, 2.5, 1.6, function()
			local v2

			if self.activeMood == "Distraction" then
				v2 = self.distractPhaseGen == distractPhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterDistractionPhase("Flop")
			end
		end)
	elseif p == "Flop" then
		self._flopping = true
		self._flopElapsed = 0
		self:_PlayFlop()
		self:PlaySound("Dive", false)
		self:EmitSplash()
		task.delay(3, function()
			local v2

			if self.activeMood == "Distraction" then
				v2 = self.distractPhaseGen == distractPhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterDistractionPhase("HopBack")
			end
		end)
	elseif p == "HopBack" then
		self._flopping = false
		self:_PlayHop()
		self:PlaySound("Jump", true)
		self:StartArc(companion.RootPart.Position, self.distractOrigin, 2.5, 1.6, function()
			local v2

			if self.activeMood == "Distraction" then
				v2 = self.distractPhaseGen == distractPhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterDistractionPhase("Settle")
			end
		end)
	elseif p == "Settle" then
		companion.MoodIgnoreGroundClamp = false
		companion.MoodPositionOverride = self.distractOrigin
		companion.MoodSmoothTime = 0.12
		task.delay(1, function()
			local v2

			if self.activeMood == "Distraction" then
				v2 = self.distractPhaseGen == distractPhaseGen
			else
				v2 = false
			end

			if v2 then
				self._distractEnded = true
			end
		end)
	end
end

function Mosswaddler:CleanupDistraction()
	self:StopArc()
	self:StopMoving()
	self._flopping = false
	self._flopElapsed = 0
	self.distractStandoff = nil
	local companion = self.companion
	companion.MoodIgnoreGroundClamp = false
	companion.MoodUninterruptible = false
	self._distractEnded = false
end

function Mosswaddler:StartBounce()
	self:SetState("MoodAction")
	self:StopMoving()
	self:_PlayBounce()
	self.bouncePhaseGen += 1
	local bouncePhaseGen = self.bouncePhaseGen
	task.delay(1.5, function()
		if self.activeMood == "Bounce" and self.bouncePhaseGen == bouncePhaseGen then
			self._bounceEnded = true
		end
	end)
end

function Mosswaddler:CleanupBounce()
	self:StopMoving()
	self._bounceEnded = false
end

function Mosswaddler:EmitSplash()
	local part = Instance.new("Part")
	part.Name = "MosswaddlerSplashAnchor"
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

function Mosswaddler:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return Mosswaddler