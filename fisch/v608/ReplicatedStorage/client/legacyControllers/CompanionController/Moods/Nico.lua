local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local assets = require(ReplicatedStorage.shared.utils.assets)
local v = {
	Tug = {
		Chance = 2,
		Interval = 10
	},
	Wander = {
		Chance = 40,
		Interval = 15
	},
	Sleep = {
		Chance = 30,
		Interval = 18
	}
}
local Nico = {}
Nico.__index = Nico
setmetatable(Nico, CompanionBehavior)

function Nico.new(p)
	local v2 = CompanionBehavior.new(p)
	setmetatable(v2, Nico)
	v2:RegisterMoods(v)
	v2.moodStartTime = 0
	v2.idleTimer = 0
	v2.tugPhaseGen = 0
	v2._tugEnded = false
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

function Nico:GetWalkAnimation()
	if self.companion.Animations.Walk then
		return "Walk"
	end

	return "Run"
end

function Nico:GetFrontOfCharacterPosition()
	local character = self.companion.Owner.Character

	if not character then
		return nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 3.5
	end

	return nil
end

function Nico:Update(p: number)
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

function Nico:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self.moodStartTime = tick()
	self._tugEnded = false
	self._roamEnded = false
	self._diveEnded = false

	if activeMood == "Tug" then
		self:StartTug()
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

function Nico:UpdateMood(p: number)
	self:_TickMovement(p)

	if self._tugEnded or self._roamEnded or self._diveEnded then
		return true
	end

	return false
end

function Nico:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Tug" then
		self:CleanupTug()
	elseif self.activeMood == "Wander" or self.activeMood == "Sleep" then
		self:CleanupRoam()
	elseif self.activeMood == "IdleSleep" then
		self:CleanupIdleSleep()
	elseif self.activeMood == "Dive" then
		self:CleanupDive()
	end

	self.activeMood = nil
end

function Nico:RequestInterrupt()
	self.idleTimer = 0
	CompanionBehavior.RequestInterrupt(self)
end

function Nico:StartTug()
	self:SetState("MoodAction")
	self:EnterTugPhase("RunToPlayer")
	self.companion.MoodUninterruptible = true
end

function Nico:EnterTugPhase(p: string)
	self.tugPhaseGen += 1
	local tugPhaseGen = self.tugPhaseGen

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stillValid()
		return self.activeMood == "Tug" and self.tugPhaseGen == tugPhaseGen
	end

	if p == "RunToPlayer" then
		self:MoveTo(createVector(0, 0, 0), {
			speed = 10,
			animation = "Run",
			arriveRadius = 2.5,
			trackFn = function()
				return self:GetFrontOfCharacterPosition()
			end,
			onArrive = function()
				local v2

				if self.activeMood == "Tug" then
					v2 = self.tugPhaseGen == tugPhaseGen
				else
					v2 = false
				end

				if v2 then
					self:EnterTugPhase("PlayTugAnim")
				end
			end
		})
	elseif p == "PlayTugAnim" then
		self:SetFaceOwner(true)
		self:PlaySound("Angry")
		local v2 = true
		local v3 = nil
		local character = nil
		local jumpRequestConnection = nil

		local function stopTug()
			if not v2 then
				return
			end

			v2 = false

			if v3 then
				v3:Destroy()
			end

			if jumpRequestConnection then
				jumpRequestConnection:Disconnect()
			end

			if character then
				character:SetAttribute("NicoTug", nil)
			end

			local v4

			if self.activeMood == "Tug" then
				v4 = self.tugPhaseGen == tugPhaseGen
			else
				v4 = false
			end

			if v4 then
				self:EnterTugPhase("Sit")
			end
		end

		local v4 = 2

		if self.companion.SkinName == "Large Sleepy" then
			v4 *= 100
		end

		if self.companion.IsOwner then
			character = self.companion.Owner.Character

			if not character then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and character:FindFirstChildOfClass("Humanoid")) then
				return
			end

			character:SetAttribute("NicoTug", 0)
			local linearVelocity = Instance.new("LinearVelocity")
			linearVelocity.VectorVelocity = humanoidRootPart.CFrame.LookVector * 10
			linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
			linearVelocity.MaxAxesForce = Vector3.new(
				humanoidRootPart.AssemblyMass * 1000,
				0,
				humanoidRootPart.AssemblyMass * 1000
			)

			if self.companion.SkinName == "Large Sleepy" then
				linearVelocity.VectorVelocity *= 5
				linearVelocity.MaxAxesForce *= 5
			end

			linearVelocity.Attachment0 = humanoidRootPart:FindFirstChild("GliderAttach")
			linearVelocity.Parent = humanoidRootPart
			v3 = linearVelocity
			local count = 0
			local v5 = self.companion.SkinName == "Large Sleepy" and 1 or math.random(5, 20)
			local UserInputService = game:GetService("UserInputService")
			jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
				count += 1

				if v5 <= count then
					stopTug()
				end
			end)
		end

		self:MoveTo(createVector(0, 0, 0), {
			speed = 100,
			animation = "Dive",
			arriveRadius = 100,
			arriveCondition = function()
				local v5 = not v2
				return v5 or not stillValid()
			end,
			trackFn = function()
				return self:GetFrontOfCharacterPosition()
			end,
			onArrive = function()
				self:StopMoving()
			end
		})
		task.delay(v4, stopTug)
	elseif p == "Sit" then
		self:SetFaceOwner(true)
		self:PlayAnimation("SitIdle")
		task.delay(3, function()
			local v2

			if self.activeMood == "Tug" then
				v2 = self.tugPhaseGen == tugPhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterTugPhase("WalkAway")
			end
		end)
	elseif p == "WalkAway" then
		self:SetFaceOwner(false)
		local character = self.companion.Owner.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local v2 = humanoidRootPart.CFrame.RightVector * (math.random() > 0.5 and 1 or -1)
			self:MoveTo(self.companion.RootPart.Position + v2 * 5, {
				speed = 5,
				animation = "Run",
				arriveRadius = 1.5,
				onArrive = function()
					local v3

					if self.activeMood == "Tug" then
						v3 = self.tugPhaseGen == tugPhaseGen
					else
						v3 = false
					end

					if v3 then
						self._tugEnded = true
					end
				end
			})
		else
			self._tugEnded = true
		end
	end
end

function Nico:CleanupTug()
	self:StopMoving()
	self:SetFaceOwner(false)
	self.companion.MoodUninterruptible = false
end

function Nico:StartIdleSleep()
	self:SetState("Sleeping")
	self:PlayAnimation("SleepIdle")
	self:SetParticles("Sleep/Particle", true)
	self:PlaySound("Snore")
end

function Nico:CleanupIdleSleep()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self:PlaySound("Meow", true)
end

function Nico:StartRoam(p, roamShouldNap: boolean)
	self:SetState("MoodAction")
	self.roamSpots = p.WanderSpots or {}
	self.roamNapSpot = p.NapSpot
	self.roamSpotIndex = 0
	self.roamShouldNap = roamShouldNap
	self:EnterRoamPhase("WalkToNextSpot")
end

function Nico:EnterRoamPhase(p: string)
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

function Nico:CleanupRoam()
	self:StopMoving()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self.roamSpots = {}
	self.roamNapSpot = nil
	self.roamSpotIndex = 0
	self.roamShouldNap = false
	self._roamEnded = false
end

function Nico:StartDive(p)
	self:SetState("MoodAction")
	self.diveOrigin = self.companion.RootPart.Position
	self.diveFishName = p.FishName
	self.diveMutation = p.Mutation
	self.companion.MoodIgnoreGroundClamp = true
	self.companion.MoodUninterruptible = true
	self:EnterDivePhase("JumpUp")
end

function Nico:EnterDivePhase(p: string)
	self.divePhaseGen += 1
	local divePhaseGen = self.divePhaseGen

	local function stillValid()
		return self.activeMood == "Dive" and self.divePhaseGen == divePhaseGen
	end

	if p == "JumpUp" then
		self:PlayAnimation("Jump")
		self:SetMoodPositionY(3, 0.18)
		task.delay(0.7, function()
			local v2

			if self.activeMood == "Dive" then
				v2 = self.divePhaseGen == divePhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterDivePhase("Sink")
			end
		end)
	elseif p == "Sink" then
		self:SetMoodPositionY(-3, 0.18)
		self:PlaySound("Dive")
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
		task.delay(7.3, function()
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
		self:PlayAnimation("Jump")
		self:SetMoodPositionY(3, 0.18)
		self:FadeModel(0, 1)
		self:SpawnFishVisual()
		task.delay(0.5, function()
			local v2

			if self.activeMood == "Dive" then
				v2 = self.divePhaseGen == divePhaseGen
			else
				v2 = false
			end

			if v2 then
				self:EnterDivePhase("Settle")
			end
		end)
	elseif p == "Settle" then
		self.companion.MoodIgnoreGroundClamp = false
		self.companion.MoodPositionOverride = self.diveOrigin
		self.companion.MoodSmoothTime = 0.18
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

function Nico:CleanupDive()
	self:StopMoving()
	self.companion.MoodIgnoreGroundClamp = false
	self.companion.MoodUninterruptible = false
	self:FadeModel(0, 0.1)
	self.diveFishName = nil
	self.diveMutation = nil
	self._diveEnded = false
end

function Nico:SetMoodPositionY(p2: number, moodSmoothTime: number)
	local moodPositionOverride = self.diveOrigin + Vector3.new(0, p2, 0)
	self.companion.MoodPositionOverride = moodPositionOverride
	self.companion.MoodSmoothTime = moodSmoothTime
end

function Nico:FadeModel(localTransparencyModifier: number, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, part in self.companion.Model:GetDescendants() do
		if part:IsA("BasePart") then
			TweenService:Create(part, tweenInfo, {
				LocalTransparencyModifier = localTransparencyModifier
			}):Play()
		end
	end
end

function Nico:EmitSplash()
	local part = Instance.new("Part")
	part.Name = "NicoSplashAnchor"
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

function Nico:SpawnFishVisual()
	if not self.diveFishName then
		return
	end

	local mouth = self.companion.RootPart:FindFirstChild("Mouth")

	if not mouth then
		return
	end

	local v2 = self.companion.RootPart.CFrame * mouth.CFrame + createVector(0, 1, 0)
	local character = self.companion.Owner.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local v3

	if humanoidRootPart then
		v3 = humanoidRootPart.CFrame * CFrame.new(0, math.random(1, 3), math.random(7, 10))
	else
		v3 = nil
	end

	local diveFishName = self.diveFishName
	task.spawn(function()
		local async = assets.getAsync("fish", diveFishName)

		if not async then
			return
		end

		local clone = async:Clone()
		clone.Name = "NicoFishVisual"
		clone.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		local center = clone:FindFirstChild("Center") or clone:FindFirstChildWhichIsA("BasePart")

		if not center then
			clone:Destroy()
			return
		end

		clone.PrimaryPart = center
		clone:PivotTo(v2)

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = false
			part.CanCollide = false
		end

		clone.Parent = workspace

		if v3 then
			center:ApplyImpulse((-(center.Position - v3.Position) + Vector3.new(0, workspace.Gravity * 0.4, 0)) * center.AssemblyMass)
		end

		task.delay(5, function()
			if clone and clone.Parent then
				clone:Destroy()
			end
		end)
	end)
end

function Nico:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return Nico