local Workspace = game:GetService("Workspace")
local DJAnimationController = {}
DJAnimationController.__index = DJAnimationController
local v = {
	IdleAnimationId = "rbxassetid://139817601640585",
	VibeAnimationId = "rbxassetid://109376391805132",
	VibeEnterThreshold = 0.65,
	VibeExitThreshold = 0.35,
	MinimumVibeDuration = 5,
	RequiredLowEnergyDuration = 5,
	EnergySmoothRate = 2
}

local function ema(p: number, p2: number, p3: number, p4: number)
	return p + (1 - math.exp(-p3 * p4)) * (p2 - p)
end

function DJAnimationController.new(items)
	local config = {}

	for k, v3 in pairs(v) do
		config[k] = v3
	end

	if items then
		for k, item in pairs(items) do
			config[k] = item
		end
	end

	local self = setmetatable({}, DJAnimationController)
	self._config = config
	self._mode = "Automatic"
	self._currentState = "Idle"
	self._energyAvg = 0
	self._timeInCurrentState = 0
	self._lowEnergyContinuousTimer = 0
	self._tracks = {}
	self._isInitialized = false
	self._initAttempts = 0
	return self
end

function DJAnimationController:_initNPC()
	if self._isInitialized then
		return true
	end

	local aAX3LL3N_Live = Workspace:FindFirstChild("AAX3LL3N_Live")

	if not aAX3LL3N_Live then
		return false
	end

	local x3ll3nScene = aAX3LL3N_Live:FindFirstChild("X3ll3nScene")

	if not x3ll3nScene then
		return false
	end

	local x3ll3n = x3ll3nScene:FindFirstChild("X3ll3n")

	if not x3ll3n then
		return false
	end

	local humanoid = x3ll3n:FindFirstChild("Humanoid")

	if not humanoid then
		return false
	end

	local v2 = humanoid:FindFirstChild("Animator")

	if not v2 then
		v2 = Instance.new("Animator")
		v2.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = self._config.IdleAnimationId
	self._tracks.Idle = v2:LoadAnimation(animation)
	self._tracks.Idle.Priority = Enum.AnimationPriority.Movement
	self._tracks.Idle.Looped = true
	local animation2 = Instance.new("Animation")
	animation2.AnimationId = self._config.VibeAnimationId
	self._tracks.Vibe = v2:LoadAnimation(animation2)
	self._tracks.Vibe.Priority = Enum.AnimationPriority.Action
	self._tracks.Vibe.Looped = true
	self._tracks.Idle:Play(0.5)
	self._isInitialized = true
	return true
end

function DJAnimationController:setMode(mode: string)
	if mode == "Automatic" or mode == "ForcedIdle" or mode == "ForcedVibe" then
		self._mode = mode
	else
		warn("[DJAnimationController] Mode invalide : " .. tostring(mode))
	end
end

function DJAnimationController:_transitionTo(currentState: string)
	if self._currentState == currentState then
		return
	end

	self._currentState = currentState
	self._timeInCurrentState = 0

	if not self._isInitialized then
		return
	end

	if currentState == "Idle" then
		if self._tracks.Vibe.IsPlaying then
			self._tracks.Vibe:Stop(0.5)
		end

		if not self._tracks.Idle.IsPlaying then
			self._tracks.Idle:Play(0.5)
		end
	elseif currentState == "Vibe" and not self._tracks.Vibe.IsPlaying then
		self._tracks.Vibe:Play(0.5)
	end
end

function DJAnimationController:update(p: number, value: number)
	if not self._isInitialized then
		self._initAttempts += p

		if self._initAttempts > 0.5 then
			self._initAttempts = 0
			self:_initNPC()
		end

		if not self._isInitialized then
			return
		end
	end

	self._timeInCurrentState += p

	if self._mode == "ForcedIdle" then
		self:_transitionTo("Idle")
		return
	end

	if self._mode == "ForcedVibe" then
		self:_transitionTo("Vibe")
		return
	end

	local _config = self._config
	local _energyAvg = self._energyAvg
	self._energyAvg = _energyAvg + (1 - math.exp(-_config.EnergySmoothRate * p)) * ((value or 0) - _energyAvg)

	if self._currentState == "Idle" then
		if self._energyAvg > _config.VibeEnterThreshold then
			self:_transitionTo("Vibe")
			self._lowEnergyContinuousTimer = 0
		end
	elseif self._currentState == "Vibe" then
		if self._timeInCurrentState < _config.MinimumVibeDuration then
			self._lowEnergyContinuousTimer = 0
		elseif self._energyAvg < _config.VibeExitThreshold then
			self._lowEnergyContinuousTimer += p

			if self._lowEnergyContinuousTimer >= _config.RequiredLowEnergyDuration then
				self:_transitionTo("Idle")
			end
		else
			self._lowEnergyContinuousTimer = 0
		end
	end
end

function DJAnimationController:destroy()
	for _, _track in pairs(self._tracks) do
		_track:Stop()
		_track:Destroy()
	end

	table.clear(self._tracks)
end

return DJAnimationController