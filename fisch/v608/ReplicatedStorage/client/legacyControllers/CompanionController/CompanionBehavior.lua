local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local remoteEvent = Net:RemoteEvent("Companion/RequestMoodPhase")
local CompanionBehavior = {}
CompanionBehavior.__index = CompanionBehavior

function CompanionBehavior.new(companion)
	local self = setmetatable({}, CompanionBehavior)
	self.companion = companion
	self.trove = Trove.new()
	self.activeMood = nil
	self._movement = nil
	self._moodConfigs = nil
	self._moodTimers = {}
	self._moodWeights = {}
	return self
end

function CompanionBehavior.Update(_, _: number)
	return nil
end

function CompanionBehavior:RequestInterrupt()
	for k in self._moodTimers do
		self._moodTimers[k] = 0
	end
end

function CompanionBehavior:StartMood(activeMood: string, _)
	self.activeMood = activeMood
end

function CompanionBehavior:StopMood()
	self.activeMood = nil
end

function CompanionBehavior.UpdateMood(_, _: number)
	return false
end

function CompanionBehavior.OnPhase(_, _: string, _) end

function CompanionBehavior.SetStateData(_, _) end

function CompanionBehavior.RequestPhase(_, p: string)
	remoteEvent:FireServer(p)
end

function CompanionBehavior:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	self._movement = nil
	self.trove:Destroy()
end

function CompanionBehavior:RegisterMoods(moodConfigs)
	self._moodConfigs = moodConfigs
	self._moodTimers = {}
	self._moodWeights = {}

	for k in moodConfigs do
		self._moodTimers[k] = 0
		self._moodWeights[k] = 1
	end
end

function CompanionBehavior:RollMoods(p: number)
	local _moodConfigs = self._moodConfigs

	if not _moodConfigs then
		return nil
	end

	for k, _moodConfig in pairs(_moodConfigs) do
		if not (self._moodWeights[k] < 1) then
			continue
		end

		local recoveryRate = _moodConfig.RecoveryRate or 0.03
		self._moodWeights[k] = math.min(1, self._moodWeights[k] + recoveryRate * p)
	end

	for k, _moodConfig in pairs(_moodConfigs) do
		self._moodTimers[k] += p

		if not (self._moodTimers[k] >= _moodConfig.Interval) then
			continue
		end

		self._moodTimers[k] = 0

		if not (_moodConfig.Chance * self._moodWeights[k] >= math.random() * 100) then
			continue
		end

		local playPenalty = _moodConfig.PlayPenalty or 0.2
		self._moodWeights[k] *= playPenalty
		return k
	end

	return nil
end

function CompanionBehavior:GetMoodWeight(p2: string)
	return self._moodWeights[p2] or 1
end

function CompanionBehavior:ResetMoodWeight(p2: string)
	if self._moodWeights[p2] then
		self._moodWeights[p2] = 1
	end
end

function CompanionBehavior:MoveTo(vector2: Vector3, options)
	local v = options or {}
	local position = self.companion.RootPart.Position
	self._movement = {
		target = vector2,
		speed = v.speed or 12,
		trackFn = v.trackFn,
		onArrive = v.onArrive,
		arriveRadius = v.arriveRadius or 1.5,
		arriveCondition = v.arriveCondition or function()
			return true
		end,
		arrived = false,
		freeYMovement = v.freeYMovement or false
	}

	if v.animation then
		self:PlayAnimation(v.animation)
	end

	self.companion.MoodPositionOverride = position
	self.companion.MoodSmoothTime = v.smoothTime or 0.1
end

function CompanionBehavior:StopMoving()
	self._movement = nil
	self.companion.MoodPositionOverride = nil
	self.companion.MoodSmoothTime = nil
end

function CompanionBehavior:_TickMovement(p2: number)
	local _movement = self._movement

	if not _movement then
		return
	end

	local target = _movement.trackFn and _movement.trackFn()

	if target then
		_movement.target = target
	end

	if not _movement.target then
		return
	end

	if _movement.arrived then
		self.companion.MoodPositionOverride = _movement.target
		return
	end

	local moodPositionOverride = self.companion.MoodPositionOverride or self.companion.RootPart.Position
	local v2 = _movement.target - moodPositionOverride

	if not _movement.freeYMovement then
		v2 *= createVector(1, 0, 1)
	end

	local magnitude = v2.Magnitude
	local v3 = _movement.speed * p2

	if magnitude <= v3 then
		local companion = self.companion
		local X = _movement.target.X
		local v4

		if _movement.freeYMovement then
			v4 = _movement.target.Y
		else
			v4 = moodPositionOverride.Y
		end

		companion.MoodPositionOverride = Vector3.new(X, v4, _movement.target.Z)
	else
		local unit = v2.Unit
		self.companion.MoodPositionOverride = moodPositionOverride + unit * v3
	end

	if ((_movement.target - self.companion.RootPart.Position) * createVector(1, 0, 1)).Magnitude <= _movement.arriveRadius and _movement.arriveCondition(self.companion.RootPart.Position) and not _movement.arrived then
		_movement.arrived = true

		if _movement.onArrive then
			task.spawn(_movement.onArrive)
		end
	end
end

function CompanionBehavior:PlayAnimation(p2: string)
	local companion = self.companion

	if companion.CurrentAnimation then
		companion.CurrentAnimation:Stop()
	end

	local animation = companion.Animations[p2]

	if animation then
		animation:Play()
		companion.CurrentAnimation = animation
	end
end

function CompanionBehavior.PlaySound(p, childName: string, flag: boolean?)
	local sound = p.companion.RootPart:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		if flag then
			sound.PlaybackSpeed = math.random(8, 12) / 10
		end

		sound:Play()
	end
end

function CompanionBehavior.StopSound(p, childName: string)
	local sound = p.companion.RootPart:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		sound:Stop()
	end
end

function CompanionBehavior.SetParticles(p, value: string, enabled: boolean)
	local rootPart = p.companion.RootPart

	for _, childName in value:split("/") do
		rootPart = rootPart:FindFirstChild(childName)

		if not rootPart then
			return
		end
	end

	if rootPart:IsA("ParticleEmitter") then
		rootPart.Enabled = enabled
	end
end

function CompanionBehavior.SetState(p, state: string)
	p.companion.State = state
end

function CompanionBehavior.SetPositionOverride(p, moodPositionOverride: Vector3?)
	p.companion.MoodPositionOverride = moodPositionOverride
end

function CompanionBehavior.SetFaceOwner(p, moodFaceOwner: boolean)
	p.companion.MoodFaceOwner = moodFaceOwner
end

function CompanionBehavior.GetOwnerBodyPart(p, childName: string)
	local character = p.companion.Owner.Character

	if character then
		return (character:FindFirstChild(childName))
	end

	return nil
end

function CompanionBehavior.GetShoulderPosition(p, p2: string?)
	local character = p.companion.Owner.Character

	if not character then
		return nil
	end

	local torso = character:FindFirstChild("Torso")

	if torso and torso:IsA("BasePart") then
		local v = p2 == "left" and -1 or 1
		return torso.Position + torso.CFrame.RightVector * (v * 1.2) + createVector(0, 1.5, 0)
	else
		return nil
	end
end

return CompanionBehavior