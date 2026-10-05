local createVector = vector.create
local TweenService = game:GetService("TweenService")
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local v = {
	Wander = {
		Chance = 40,
		Interval = 14
	},
	Sleep = {
		Chance = 25,
		Interval = 18
	}
}
local color = Color3.fromRGB(82, 153, 223)
local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local Budling = {}
Budling.__index = Budling
setmetatable(Budling, CompanionBehavior)

function Budling.new(p)
	local v2 = CompanionBehavior.new(p)
	setmetatable(v2, Budling)
	v2:RegisterMoods(v)
	v2.moodStartTime = 0
	v2.idleTimer = 0
	v2.roamPhaseGen = 0
	v2.roamSpots = {}
	v2.roamSpotIndex = 0
	v2.roamNapSpot = nil
	v2.roamShouldNap = false
	v2._roamEnded = false
	v2.idleRestPhaseGen = 0
	v2._idleRestEnded = false
	v2.celebrateActive = false
	v2.celebrateAngle = 0
	v2.celebrateRadius = 4.5
	v2.celebrateDirection = 1
	v2.celebrateTravelled = 0
	v2._celebrateEnded = false
	v2.glowParts = nil
	v2.glowCharge = 0
	v2.trove:Add(function()
		v2:_SetGlow(0)
	end)
	v2:SetStateData(v2.companion.StateData)
	return v2
end

function Budling:GetWalkAnimation()
	if self.companion.Animations.Walk then
		return "Walk"
	end

	return "Run"
end

function Budling:PlaySitDown()
	local sitDown = self.companion.Animations.SitDown

	if not sitDown then
		self:PlayAnimation("SitIdle")
		return 0
	end

	sitDown.Looped = false
	self:PlayAnimation("SitDown")

	if sitDown.Length > 0 then
		return sitDown.Length
	end

	return 0.8
end

function Budling:_GetOwnerPosition()
	local ownerBodyPart = self:GetOwnerBodyPart("HumanoidRootPart")

	if ownerBodyPart then
		return ownerBodyPart.Position
	end

	return nil
end

function Budling:_GetGlowParts()
	if self.glowParts then
		return self.glowParts
	end

	local result = {}
	local model = self.companion.Model

	if model then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") and part:GetAttribute("NectarGlow") == true then
				table.insert(result, {
					Part = part,
					Color = part.Color,
					Material = part.Material,
					Transparency = part.Transparency,
					Tween = nil
				})
			end
		end
	end

	self.glowParts = result
	return result
end

function Budling:_SetGlow(value: number)
	local glowCharge = math.clamp(value, 0, 1)

	if math.abs(glowCharge - self.glowCharge) < 0.01 then
		return
	end

	self.glowCharge = glowCharge
	local v3 = glowCharge > 0
	local v4 = glowCharge * -0.5 + 0.5

	for _, v5 in ipairs(self:_GetGlowParts()) do
		if not v5.Part.Parent then
			continue
		end

		if v5.Tween then
			v5.Tween:Cancel()
			v5.Tween = nil
		end

		local part = v5.Part
		local material

		if v3 then
			material = Enum.Material.Neon
		else
			material = v5.Material
		end

		part.Material = material
		local part2 = v5.Part
		local color2

		if v3 then
			color2 = color
		else
			color2 = v5.Color
		end

		local transparency

		if v3 then
			transparency = v4
		else
			transparency = v5.Transparency
		end

		local tween = TweenService:Create(part2, tweenInfo, {
			Color = color2,
			Transparency = transparency
		})
		v5.Tween = tween
		tween:Play()
	end
end

function Budling:SetStateData(p)
	self:_SetGlow((not p or typeof(p.NectarCharge) ~= "number") and 0 or p.NectarCharge)
end

function Budling:Update(p: number)
	if self.activeMood then
		return nil
	end

	local state = self.companion.State

	if state == "Walking" or state == "Jumping" then
		self.idleTimer = 0
		return nil
	end

	self.idleTimer += p

	if self.idleTimer >= 120 then
		self.idleTimer = 0
		return "IdleRest"
	end

	local rollMoods = self:RollMoods(p)

	if not rollMoods then
		return nil
	end

	self.idleTimer = 0
	return rollMoods
end

function Budling:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self.moodStartTime = tick()
	self._roamEnded = false
	self._idleRestEnded = false
	self._celebrateEnded = false

	if activeMood == "Wander" then
		self:StartRoam(p, false)
	elseif activeMood == "Sleep" then
		self:StartRoam(p, true)
	elseif activeMood == "IdleRest" then
		self:StartIdleRest()
	elseif activeMood == "Celebrate" then
		self:StartCelebrate()
	end
end

function Budling:UpdateMood(p: number)
	if not self.celebrateActive then
		self:_TickMovement(p)
	end

	self:_TickCelebrate(p)

	if self._roamEnded or self._idleRestEnded or self._celebrateEnded then
		return true
	end

	return false
end

function Budling:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Wander" or self.activeMood == "Sleep" then
		self:CleanupRoam()
	elseif self.activeMood == "IdleRest" then
		self:CleanupIdleRest()
	elseif self.activeMood == "Celebrate" then
		self:CleanupCelebrate()
	end

	self.activeMood = nil
end

function Budling:RequestInterrupt()
	self.idleTimer = 0
	CompanionBehavior.RequestInterrupt(self)
end

function Budling:StartIdleRest()
	self:SetState("MoodAction")
	self:StopMoving()
	self:EnterIdleRestPhase("Sit")
end

function Budling:EnterIdleRestPhase(p: string)
	self.idleRestPhaseGen += 1
	local idleRestPhaseGen = self.idleRestPhaseGen

	local function stillValid()
		return self.activeMood == "IdleRest" and self.idleRestPhaseGen == idleRestPhaseGen
	end

	if p == "Sit" then
		local v2 = self:PlaySitDown()
		task.delay(v2, function()
			local v3

			if self.activeMood == "IdleRest" then
				v3 = self.idleRestPhaseGen == idleRestPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:PlayAnimation("SitIdle")
			end
		end)
		local v3 = v2 + 8 + math.random() * 7
		task.delay(v3, function()
			local v4

			if self.activeMood == "IdleRest" then
				v4 = self.idleRestPhaseGen == idleRestPhaseGen
			else
				v4 = false
			end

			if v4 then
				self:EnterIdleRestPhase("Doze")
			end
		end)
	elseif p == "Doze" then
		self:SetState("Sleeping")
		self:PlayAnimation("SleepIdle")
		self:SetParticles("Sleep/Particle", true)
		self:PlaySound("Snore")
	end
end

function Budling:CleanupIdleRest()
	self.idleRestPhaseGen += 1
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self._idleRestEnded = false
end

function Budling:StartCelebrate()
	local _GetOwnerPosition = self:_GetOwnerPosition()

	if not _GetOwnerPosition then
		self._celebrateEnded = true
		return
	end

	self:SetState("MoodAction")
	self:StopMoving()
	self.companion.MoodUninterruptible = true
	local v2 = (self.companion.RootPart.Position - _GetOwnerPosition) * createVector(1, 0, 1)

	if v2.Magnitude < 0.1 then
		self.celebrateAngle = math.random() * 3.141592653589793 * 2
		self.celebrateRadius = 4.5
	else
		self.celebrateAngle = math.atan2(v2.Z, v2.X)
		self.celebrateRadius = v2.Magnitude
	end

	self.celebrateDirection = math.random() > 0.5 and 1 or -1
	self.celebrateTravelled = 0
	self.celebrateActive = true
	self:PlayAnimation(self:GetWalkAnimation())
end

function Budling:_TickCelebrate(p: number)
	if not self.celebrateActive then
		return
	end

	local _GetOwnerPosition = self:_GetOwnerPosition()

	if _GetOwnerPosition then
		local v2 = p * 5.585053606381854 * self.celebrateDirection
		self.celebrateAngle += v2
		self.celebrateTravelled += math.abs(v2)
		local v3 = math.min(p * 4, 1)
		self.celebrateRadius += (4.5 - self.celebrateRadius) * v3
		self.companion.MoodPositionOverride = _GetOwnerPosition + Vector3.new(
			math.cos(self.celebrateAngle) * self.celebrateRadius,
			0,
			math.sin(self.celebrateAngle) * self.celebrateRadius
		)
		self.companion.MoodSmoothTime = 0.08

		if self.celebrateTravelled >= 12.566370614359172 then
			self.celebrateActive = false
			self._celebrateEnded = true
		end
	else
		self.celebrateActive = false
		self._celebrateEnded = true
	end
end

function Budling:CleanupCelebrate()
	self:StopMoving()
	self.celebrateActive = false
	self.celebrateTravelled = 0
	self._celebrateEnded = false
	self.companion.MoodUninterruptible = false
	self.companion.MoodPositionOverride = nil
	self.companion.MoodSmoothTime = nil
end

function Budling:StartRoam(p, roamShouldNap: boolean)
	self:SetState("MoodAction")
	self.roamSpots = p.WanderSpots or {}
	self.roamNapSpot = p.NapSpot
	self.roamSpotIndex = 0
	self.roamShouldNap = roamShouldNap

	if #self.roamSpots ~= 0 then
		self:EnterRoamPhase("WalkToNextSpot")
	elseif roamShouldNap then
		self:EnterRoamPhase("Nap")
	else
		self._roamEnded = true
	end
end

function Budling:EnterRoamPhase(p: string)
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
			self:EnterRoamPhase("Nap")
		end
	elseif p == "SitAtNapSpot" then
		self:StopMoving()
		local v2 = self:PlaySitDown()
		task.delay(v2, function()
			local v3

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v3 = self.roamPhaseGen == roamPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:PlayAnimation("SitIdle")
			end
		end)
		local v3 = v2 + 1.2 + math.random() * 1.3
		task.delay(v3, function()
			local v4

			if self.activeMood == "Wander" or self.activeMood == "Sleep" then
				v4 = self.roamPhaseGen == roamPhaseGen
			else
				v4 = false
			end

			if v4 then
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

function Budling:CleanupRoam()
	self.roamPhaseGen += 1
	self:StopMoving()
	self:SetParticles("Sleep/Particle", false)
	self:StopSound("Snore")
	self.roamSpots = {}
	self.roamNapSpot = nil
	self.roamSpotIndex = 0
	self.roamShouldNap = false
	self._roamEnded = false
end

function Budling:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return Budling