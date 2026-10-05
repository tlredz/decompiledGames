local IndependenceDayConfig = require(script.Parent.IndependenceDayConfig)
local IndependenceDayLightsDirector = {}
IndependenceDayLightsDirector.__index = IndependenceDayLightsDirector

local function pickRandomPattern(p: string?)
	local STAGE_LIGHT_PATTERNS = IndependenceDayConfig.STAGE_LIGHT_PATTERNS
	local v = STAGE_LIGHT_PATTERNS[math.random(1, #STAGE_LIGHT_PATTERNS)]

	if v == p and #STAGE_LIGHT_PATTERNS > 1 then
		for _, v2 in STAGE_LIGHT_PATTERNS do
			if v2 ~= p then
				return v2
			end
		end
	end

	return v
end

function IndependenceDayLightsDirector.new(stageLights, laserSweep)
	local self = setmetatable({}, IndependenceDayLightsDirector)
	self._stageLights = stageLights
	self._laserSweep = laserSweep
	self._currentPattern = pickRandomPattern(nil)
	self._timeSinceLastChange = 0
	self._nextChangeDuration = math.random(
		IndependenceDayConfig.STAGE_LIGHT_PATTERN_MIN_SEC,
		IndependenceDayConfig.STAGE_LIGHT_PATTERN_MAX_SEC
	)

	if self._stageLights then
		self._stageLights:setPattern(self._currentPattern)
	end

	if self._laserSweep then
		self._laserSweep:setPattern(IndependenceDayConfig.LASER_PATTERN)
	end

	return self
end

function IndependenceDayLightsDirector:update(p: number, p2: number)
	self._timeSinceLastChange += p

	if self._timeSinceLastChange >= self._nextChangeDuration then
		self._timeSinceLastChange = 0
		self._nextChangeDuration = math.random(
			IndependenceDayConfig.STAGE_LIGHT_PATTERN_MIN_SEC,
			IndependenceDayConfig.STAGE_LIGHT_PATTERN_MAX_SEC
		)
		self._currentPattern = pickRandomPattern(self._currentPattern)

		if self._stageLights then
			self._stageLights:setPattern(self._currentPattern)
		end
	end

	if self._stageLights then
		self._stageLights:update(p, p2)
	end

	if self._laserSweep then
		self._laserSweep:update(p, p2)
	end
end

return IndependenceDayLightsDirector