game:GetService("RunService")
local module = require("./PassiveHandler")
local color = Color3.fromRGB(0, 0, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function smoothstep(value: number)
	local v = math.clamp(value, 0, 1)
	return v * v * (3 - v * 2)
end

local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local CuskPurger = {
	_CacheOriginals = function(self)
		if self.originalBarColor then
			return
		end

		local reel_playerbar = self.current and self.current.reel_playerbar

		if not reel_playerbar then
			return
		end

		self.originalBarColor = reel_playerbar.BackgroundColor3
	end,
	_ApplyDarkness = function(self, p2: number)
		local reel_playerbar = self.current and self.current.reel_playerbar

		if reel_playerbar and self.originalBarColor then
			reel_playerbar.BackgroundColor3 = self.originalBarColor:Lerp(color, p2 * 1)
		end
	end,
	_SetBehaviorEnabled = function(self, movementBehaviorEnabled: boolean)
		if self.behaviorDisabled == not movementBehaviorEnabled then
			return
		end

		self.current.core.fish.MovementBehaviorEnabled = movementBehaviorEnabled
		self.behaviorDisabled = not movementBehaviorEnabled
	end,
	_ApplySuction = function(self, p: number)
		local current = self.current
		local fish = current.core.fish
		local config = self.config

		if fish.CurrentTarget ~= self.lastTarget then
			self.behaviorTarget = fish.CurrentTarget
			self.behaviorMoveTime = fish.CurrentMoveTime
		end

		if p <= 0 then
			self:_SetBehaviorEnabled(true)
			self.lastTarget = nil
		else
			self:_SetBehaviorEnabled(p < 0.9)
			local v = math.clamp(p * config.PullStrength, 0, 1)
			local v2 = 0.08 * current.movementfactor
			local behaviorTarget = self.behaviorTarget
			local v3 = behaviorTarget + (current.barPosition - behaviorTarget) * v
			local behaviorMoveTime = self.behaviorMoveTime
			local currentMoveTime = math.max(behaviorMoveTime + (v2 - behaviorMoveTime) * v, v2)
			fish.CurrentTarget = v3
			fish.CurrentMoveTime = currentMoveTime
			self.lastTarget = v3
		end
	end,
	_ScheduleNext = function(self)
		local config = self.config
		self.phase = "idle"
		self.phaseTime = 0
		self.nextTrigger = self.random:NextNumber(config.MinInterval, config.MaxInterval)
	end,
	_Advance = function(self, p: number)
		local config = self.config
		self.phaseTime += p

		if self.phase == "idle" then
			if self.phaseTime >= self.nextTrigger then
				self.phase = "ramp"
				self.phaseTime = 0
			end

			return 0
		elseif self.phase == "ramp" then
			if self.phaseTime >= 2.5 then
				self.phase = "hold"
				self.phaseTime = 0
				return 1
			else
				return smoothstep(self.phaseTime / 2.5)
			end
		elseif self.phase == "hold" then
			if self.phaseTime >= config.HoldTime then
				self.phase = "release"
				self.phaseTime = 0
			end

			return 1
		elseif self.phaseTime >= 1.5 then
			self:_ScheduleNext()
			return 0
		else
			return 1 - smoothstep(self.phaseTime / 1.5)
		end
	end,
	Morph = function(self, _, object2)
		self.reelTrove:Add(task.spawn(function()
			object2:WaitUntilReady()
			local fish = object2.core.fish
			self.random = object2:GetRandom(991)
			self.behaviorDisabled = false
			self.behaviorTarget = fish.CurrentTarget
			self.behaviorMoveTime = fish.CurrentMoveTime
			self.lastTarget = nil
			self:_CacheOriginals()
			self:_ScheduleNext()
			self.reelTrove:Add(object2.OnLogicStep:Connect(function(p)
				if not object2.active then
					return
				end

				local _Advance = self:_Advance(p)
				self:_ApplyDarkness(_Advance)
				self:_ApplySuction(_Advance)
			end))
			self.reelTrove:Add(function()
				if self.behaviorDisabled and object2.core and object2.core.fish then
					object2.core.fish.MovementBehaviorEnabled = true
				end

				self:_ApplyDarkness(0)
				self.originalBarColor = nil
			end)
		end))
	end
}
setmetatable(CuskPurger, module)
return CuskPurger