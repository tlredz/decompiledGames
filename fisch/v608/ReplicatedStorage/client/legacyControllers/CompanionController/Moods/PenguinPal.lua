local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local v = {
	Happy = {
		Chance = 40,
		Interval = 12
	},
	Wander = {
		Chance = 25,
		Interval = 18
	}
}
local cframe = CFrame.Angles(1.5707963267948966, 0, 0)
local v2 = {
	[Enum.Material.Glacier] = true,
	[Enum.Material.Ice] = true,
	[Enum.Material.Snow] = true
}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true
local PenguinPal = {}
PenguinPal.__index = PenguinPal
setmetatable(PenguinPal, CompanionBehavior)

function PenguinPal.new(p)
	local v3 = CompanionBehavior.new(p)
	setmetatable(v3, PenguinPal)
	v3:RegisterMoods(v)
	v3.happyPhaseGen = 0
	v3._happyEnded = false
	v3.roamPhaseGen = 0
	v3.roamSpots = {}
	v3.roamSpotIndex = 0
	v3._roamEnded = false
	v3.freezingPhaseGen = 0
	v3.freezingOrigin = createVector(0, 0, 0)
	v3._freezingEnded = false
	v3._circlingBobber = false
	v3._circleAngle = 0
	v3._isSliding = false
	v3._slideCheckAccumulator = 0
	v3.trove:Add(RunService.Heartbeat:Connect(function(dt: number)
		v3._slideCheckAccumulator += dt

		if v3._slideCheckAccumulator < 0.2 then
			return
		end

		v3._slideCheckAccumulator = 0
		v3:_UpdateIceSlide()
	end))
	return v3
end

function PenguinPal:_GetBobberPosition()
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

function PenguinPal:_UpdateIceSlide()
	if self.activeMood then
		return
	end

	local companion = self.companion

	if companion.State == "Walking" then
		local animations = companion.Animations

		if not animations.Slide then
			return
		end

		local rootPart = companion.RootPart

		if not rootPart then
			return
		end

		raycastParams.FilterDescendantsInstances = { companion.Model, companion.Owner.Character }
		local v3 = rootPart.Position + createVector(0, 4, 0)
		local raycastResult = workspace:Raycast(v3, createVector(0, -10, 0), raycastParams)
		local v4

		if raycastResult == nil then
			v4 = false
		else
			v4 = v2[raycastResult.Material] == true
		end

		if v4 and not self._isSliding then
			self._isSliding = true
			companion.MoodRotationTilt = cframe
			companion.MoodModelOffset = createVector(0, 0.5, 0)
			self:PlayAnimation("Slide")
		elseif not v4 and self._isSliding then
			self._isSliding = false
			companion.MoodRotationTilt = nil
			companion.MoodModelOffset = nil
			local walkAnimation = self:GetWalkAnimation()

			if animations[walkAnimation] then
				self:PlayAnimation(walkAnimation)
			end
		end
	elseif self._isSliding then
		self._isSliding = false
		companion.MoodRotationTilt = nil
		companion.MoodModelOffset = nil
	end
end

function PenguinPal:GetWalkAnimation()
	if self.companion.Animations.Walk then
		return "Walk"
	end

	return "Run"
end

function PenguinPal.Update(object, p: number)
	if object.activeMood then
		return nil
	end

	local state = object.companion.State

	if state == "Walking" or state == "Jumping" then
		return nil
	end

	return object:RollMoods(p)
end

function PenguinPal:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self._happyEnded = false
	self._roamEnded = false
	self._freezingEnded = false

	if activeMood == "Happy" then
		self:StartHappy()
	elseif activeMood == "Wander" then
		self:StartRoam(p)
	elseif activeMood == "Freezing" then
		self:StartFreezing()
	end
end

function PenguinPal:UpdateMood(p: number)
	self:_TickMovement(p)

	if self._circlingBobber then
		local circleAngle = (self._circleAngle + p * 1.5707963267948966) % 6.283185307179586
		self._circleAngle = circleAngle
		local _GetBobberPosition = self:_GetBobberPosition()

		if _GetBobberPosition then
			self.freezingBobberPos = _GetBobberPosition
		end

		local freezingBobberPos = self.freezingBobberPos or self.freezingOrigin
		local companion = self.companion
		companion.MoodPositionOverride = Vector3.new(
			freezingBobberPos.X + math.cos(circleAngle) * 2.5,
			freezingBobberPos.Y + 2,
			freezingBobberPos.Z + math.sin(circleAngle) * 2.5
		)
		companion.MoodSmoothTime = 0.18
	end

	if self._happyEnded or self._roamEnded or self._freezingEnded then
		return true
	end

	return false
end

function PenguinPal:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Happy" then
		self:CleanupHappy()
	elseif self.activeMood == "Wander" then
		self:CleanupRoam()
	elseif self.activeMood == "Freezing" then
		self:CleanupFreezing()
	end

	self.activeMood = nil
end

function PenguinPal:StartHappy()
	self:SetState("MoodAction")
	self:SetFaceOwner(true)
	self:EnterHappyPhase()
end

function PenguinPal:EnterHappyPhase()
	self.happyPhaseGen += 1
	local happyPhaseGen = self.happyPhaseGen

	local function stillValid()
		return self.activeMood == "Happy" and self.happyPhaseGen == happyPhaseGen
	end

	local v3 = math.random() < 0.08 and self.companion.Animations.RareDive and "RareDive" or "Happy"

	if self.companion.Animations[v3] then
		self:PlayAnimation(v3)
	else
		self:PlayAnimation("Idle")
	end

	local v4 = 1.5 + math.random() * 1.5
	task.delay(v4, function()
		local v5

		if self.activeMood == "Happy" then
			v5 = self.happyPhaseGen == happyPhaseGen
		else
			v5 = false
		end

		if v5 then
			self._happyEnded = true
		end
	end)
end

function PenguinPal:CleanupHappy()
	self:SetFaceOwner(false)
end

function PenguinPal:StartRoam(p)
	self:SetState("MoodAction")
	self.roamSpots = p.WanderSpots or {}
	self.roamSpotIndex = 0

	if #self.roamSpots == 0 then
		self._roamEnded = true
	else
		self:EnterRoamPhase("WalkToNextSpot")
	end
end

function PenguinPal:EnterRoamPhase(p: string)
	self.roamPhaseGen += 1
	local roamPhaseGen = self.roamPhaseGen

	local function stillValid()
		return self.activeMood == "Wander" and self.roamPhaseGen == roamPhaseGen
	end

	if p == "WalkToNextSpot" then
		self.roamSpotIndex += 1

		if self.roamSpotIndex > #self.roamSpots then
			self._roamEnded = true
		else
			self:MoveTo(self.roamSpots[self.roamSpotIndex], {
				speed = 5,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v3

					if self.activeMood == "Wander" then
						v3 = self.roamPhaseGen == roamPhaseGen
					else
						v3 = false
					end

					if v3 then
						self:EnterRoamPhase("PauseAtSpot")
					end
				end
			})
		end
	elseif p == "PauseAtSpot" then
		self:StopMoving()
		self:PlayAnimation("Idle")
		local v3 = 0.6 + math.random() * 1.4
		task.delay(v3, function()
			local v4

			if self.activeMood == "Wander" then
				v4 = self.roamPhaseGen == roamPhaseGen
			else
				v4 = false
			end

			if v4 then
				if math.random() < 0.35 then
					self:EnterRoamPhase("OrbitPlayer")
				else
					self:EnterRoamPhase("WalkToNextSpot")
				end
			end
		end)
	elseif p == "OrbitPlayer" then
		local character = self.companion.Owner.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			self:EnterRoamPhase("WalkToNextSpot")
			return
		end

		local v3 = math.random() * 3.141592653589793 * 2
		local v4 = 3 + math.random() * 3
		self:MoveTo(
			Vector3.new(
				humanoidRootPart.Position.X + math.cos(v3) * v4,
				humanoidRootPart.Position.Y,
				humanoidRootPart.Position.Z + math.sin(v3) * v4
			),
			{
				speed = 5,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v5

					if self.activeMood == "Wander" then
						v5 = self.roamPhaseGen == roamPhaseGen
					else
						v5 = false
					end

					if v5 then
						self:EnterRoamPhase("WalkToNextSpot")
					end
				end
			}
		)
	end
end

function PenguinPal:CleanupRoam()
	self:StopMoving()
	self.roamSpots = {}
	self.roamSpotIndex = 0
end

function PenguinPal:StartFreezing()
	self:SetState("MoodAction")
	self.freezingOrigin = self.companion.RootPart.Position
	self.freezingBobberPos = self:_GetBobberPosition()
	self.companion.MoodIgnoreGroundClamp = true
	self.companion.MoodUninterruptible = true
	self:EnterFreezingPhase("JumpUp")
end

function PenguinPal:EnterFreezingPhase(p: string)
	self.freezingPhaseGen += 1
	local freezingPhaseGen = self.freezingPhaseGen

	local function stillValid()
		return self.activeMood == "Freezing" and self.freezingPhaseGen == freezingPhaseGen
	end

	local companion = self.companion

	if p == "JumpUp" then
		companion.MoodRotationTilt = nil
		self:PlayAnimation("Jump")
		self:SetFreezingY(3, 0.18)
		self:PlaySound("Jump", true)
		task.delay(0.5, function()
			local v3

			if self.activeMood == "Freezing" then
				v3 = self.freezingPhaseGen == freezingPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterFreezingPhase("Swim")
			end
		end)
	elseif p == "Swim" then
		self._circlingBobber = true
		self._circleAngle = math.random() * 3.141592653589793 * 2
		companion.MoodRotationTilt = cframe
		self:PlayAnimation("Swim")
		self:PlaySound("Dive", false)
		task.delay(0.15, function()
			local v3

			if self.activeMood == "Freezing" then
				v3 = self.freezingPhaseGen == freezingPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EmitSplash()
			end
		end)
		task.delay(3, function()
			local v3

			if self.activeMood == "Freezing" then
				v3 = self.freezingPhaseGen == freezingPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterFreezingPhase("Surface")
			end
		end)
	elseif p == "Surface" then
		self._circlingBobber = false
		companion.MoodRotationTilt = nil
		self:PlayAnimation("Jump")
		self:SetFreezingY(3, 0.18)
		task.delay(0.5, function()
			local v3

			if self.activeMood == "Freezing" then
				v3 = self.freezingPhaseGen == freezingPhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterFreezingPhase("Settle")
			end
		end)
	elseif p == "Settle" then
		self.companion.MoodIgnoreGroundClamp = false
		self.companion.MoodPositionOverride = self.freezingOrigin
		self.companion.MoodSmoothTime = 0.18
		task.delay(0.8, function()
			local v3

			if self.activeMood == "Freezing" then
				v3 = self.freezingPhaseGen == freezingPhaseGen
			else
				v3 = false
			end

			if v3 then
				self._freezingEnded = true
			end
		end)
	end
end

function PenguinPal:CleanupFreezing()
	self:StopMoving()
	self._circlingBobber = false
	local companion = self.companion
	companion.MoodIgnoreGroundClamp = false
	companion.MoodUninterruptible = false
	companion.MoodRotationTilt = nil
	self:FadeModel(0, 0.1)
end

function PenguinPal:SetFreezingY(p2: number, moodSmoothTime: number)
	local moodPositionOverride = self.freezingOrigin + Vector3.new(0, p2, 0)
	self.companion.MoodPositionOverride = moodPositionOverride
	self.companion.MoodSmoothTime = moodSmoothTime
end

function PenguinPal:FadeModel(transparency: number, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, part in self.companion.Model:GetDescendants() do
		if part:IsA("BasePart") and part.Name ~= "RootPart" then
			TweenService:Create(part, tweenInfo, {
				Transparency = transparency
			}):Play()
		end
	end
end

function PenguinPal:EmitSplash() end

function PenguinPal:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return PenguinPal