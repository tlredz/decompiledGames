local July14thAdminAbuseConfig = require(script.Parent.July14thAdminAbuseConfig)
local July14thAdminAbuseLightsDirector = {}
July14thAdminAbuseLightsDirector.__index = July14thAdminAbuseLightsDirector

local function pickRandomPattern(p: string?)
	local STAGE_LIGHT_PATTERNS = July14thAdminAbuseConfig.STAGE_LIGHT_PATTERNS
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

function July14thAdminAbuseLightsDirector.new(stageLights, laserSweep)
	local self = setmetatable({}, July14thAdminAbuseLightsDirector)
	self._stageLights = stageLights
	self._laserSweep = laserSweep
	self._currentPattern = pickRandomPattern(nil)
	self._timeSinceLastChange = 0
	self._nextChangeDuration = math.random(
		July14thAdminAbuseConfig.STAGE_LIGHT_PATTERN_MIN_SEC,
		July14thAdminAbuseConfig.STAGE_LIGHT_PATTERN_MAX_SEC
	)

	if self._stageLights then
		self._stageLights:setPattern(self._currentPattern)
	end

	if self._laserSweep then
		self._laserSweep:setPattern(July14thAdminAbuseConfig.LASER_PATTERN)
	end

	return self
end

function July14thAdminAbuseLightsDirector:update(p: number, p2: number)
	self._timeSinceLastChange += p

	if self._timeSinceLastChange >= self._nextChangeDuration then
		self._timeSinceLastChange = 0
		self._nextChangeDuration = math.random(
			July14thAdminAbuseConfig.STAGE_LIGHT_PATTERN_MIN_SEC,
			July14thAdminAbuseConfig.STAGE_LIGHT_PATTERN_MAX_SEC
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

return July14thAdminAbuseLightsDirector