local LaserSweep = {}
LaserSweep.__index = LaserSweep
local v = {
	Sweep = {}
}

function v.Sweep:init(p2)
	self.phase = math.random()
	self.direction = math.random() > 0.5 and 1 or -1
	self.speedMult = p2.speedVariationMin + math.random() * (p2.speedVariationMax - p2.speedVariationMin)
	self.burst = 1
end

function v.Sweep:update(p, p2, p3, data)
	if p3 then
		self.burst = data.beatBurstMultiplier

		if math.random() > 0.5 then
			self.direction = -self.direction
		end
	end

	local v2 = math.exp(-data.beatBurstDecayRate * p)
	self.burst = 1 + (self.burst - 1) * v2
	local v3 = not (p2 > 0.01) and 0 or (data.baseSpeed + (data.maxSpeed - data.baseSpeed) * p2) * self.speedMult * self.burst

	if v3 > 0 then
		self.phase += self.direction * v3 * p
	end

	if self.phase >= 1 then
		self.phase = 2 - self.phase
		self.direction = -1
	elseif self.phase <= 0 then
		self.phase = -self.phase
		self.direction = 1
	end

	self.phase = math.clamp(self.phase, 0, 1)
	local v4 = data.maxAngleDeg - data.minAngleDeg
	local v5 = data.minAngleDeg + self.phase * v4
	self.baseModel:PivotTo(self.baseCFrame * CFrame.Angles(0, math.rad(v5), 0))
end

v.Blackout = {}

function v.Blackout.init(_, _) end

function v.Blackout.update(p, _, _, _, _)
	p.baseModel:PivotTo(p.baseCFrame * CFrame.Angles(-1.5707963267948966, 0, 0))
end

local v2 = {
	pattern = "Sweep",
	minAngleDeg = 90,
	maxAngleDeg = -90,
	baseSpeed = 0.1,
	maxSpeed = 0.55,
	peakSmoothRate = 8,
	beatAvgRate = 1.5,
	beatThreshold = 1.8,
	beatCooldown = 0.3,
	beatBurstMultiplier = 2.2,
	beatBurstDecayRate = 4,
	speedVariationMin = 0.82,
	speedVariationMax = 1.18,
	colorCycle = false,
	colorPalette = {},
	colorCycleMinSec = 3,
	colorCycleMaxSec = 8
}

-- equivalent calls inferred from this helper; original call sites unknown
local function ema(p: number, p2: number, p3: number, p4: number)
	return p + (1 - math.exp(-p3 * p4)) * (p2 - p)
end

local function pickRandomColor(colorPalette, lastColor: Color3?)
	local v3 = colorPalette[math.random(1, #colorPalette)]

	if v3 == lastColor and #colorPalette > 1 then
		for _, v4 in colorPalette do
			if v4 ~= lastColor then
				return v4
			end
		end
	end

	return v3
end

function LaserSweep.new(items)
	local config = {}

	for k, v4 in v2 do
		config[k] = v4
	end

	if items then
		for k, item in items do
			config[k] = item
		end
	end

	local self = setmetatable({}, LaserSweep)
	self._config = config
	self._lasers = {}
	self._pattern = v[config.pattern]
	self._smoothedPeak = 0
	self._beatAvg = 0
	self._beatCooldownTimer = 0

	if not self._pattern then
		warn(string.format("[LaserSweep] Pattern '%s' inconnu, aucune animation.", (tostring(config.pattern))))
	end

	return self
end

function LaserSweep:setPattern(pattern: string)
	self._config.pattern = pattern

	if v[pattern] then
		self._pattern = v[pattern]
	else
		self._pattern = v.Sweep
	end

	if self._pattern and self._pattern.init then
		for _, _laser in self._lasers do
			self._pattern.init(_laser, self._config)
		end
	end
end

function LaserSweep:scan(folder)
	table.clear(self._lasers)

	if not folder then
		return
	end

	local _config = self._config
	local _pattern = self._pattern

	for _, model in folder:GetDescendants() do
		if not (model.Name == "LaserSpot" and model:IsA("Model")) then
			continue
		end

		local base = model:FindFirstChild("Base")

		if not (base and base:IsA("Model")) then
			continue
		end

		local v3 = {
			baseModel = base,
			baseCFrame = base:GetPivot()
		}

		if _pattern and _pattern.init then
			_pattern.init(v3, _config)
		end

		if _config.colorCycle then
			v3.colorPart = base:FindFirstChild("Part")
			v3.colorBeamParts = {}
			local BEAM = base:FindFirstChild("BEAM")

			if BEAM then
				for _, part in BEAM:GetDescendants() do
					if part:IsA("BasePart") then
						table.insert(v3.colorBeamParts, part)
					end
				end
			end

			v3.colorCycleTimer = math.random() * _config.colorCycleMaxSec
			v3.lastColor = nil
		end

		table.insert(self._lasers, v3)
	end

	warn(string.format("[LaserSweep] %d LaserSpot(s) détecté(s) et mis en cache", #self._lasers))
end

function LaserSweep:update(p: number, value: number)
	if #self._lasers == 0 then
		return
	end

	local _config = self._config
	local _pattern = self._pattern

	if not _pattern then
		return
	end

	local v3 = value or 0
	self._smoothedPeak = ema(self._smoothedPeak, v3, _config.peakSmoothRate, p)
	local v4 = math.clamp(self._smoothedPeak, 0, 1)
	self._beatAvg = ema(self._beatAvg, v3, _config.beatAvgRate, p)
	self._beatCooldownTimer = math.max(0, self._beatCooldownTimer - p)
	local v5

	if self._beatCooldownTimer <= 0 and self._beatAvg > 0.02 and self._beatAvg * _config.beatThreshold < v3 then
		self._beatCooldownTimer = _config.beatCooldown
		v5 = true
	else
		v5 = false
	end

	local v6 = _config.pattern == "Blackout"
	local v7

	if v4 > 0.01 then
		v7 = not v6
	else
		v7 = false
	end

	for _, _laser in self._lasers do
		if not (_laser.baseModel and _laser.baseModel.Parent) then
			continue
		end

		_pattern.update(_laser, p, v4, v5, _config)

		if _laser.wasPlaying ~= v7 then
			_laser.wasPlaying = v7

			for _, descendant in _laser.baseModel:GetDescendants() do
				if not (descendant:IsA("Beam") or descendant:IsA("Light") or descendant:IsA("ParticleEmitter")) then
					continue
				end

				descendant.Enabled = v7
			end
		end

		for _, part in _laser.baseModel:GetDescendants() do
			if not (part:IsA("BasePart") and part.Parent and part.Parent.Name == "BEAM") then
				continue
			end

			local origTrans = part:GetAttribute("OrigTrans")

			if not origTrans then
				origTrans = part.Transparency
				part:SetAttribute("OrigTrans", origTrans)
			end

			local v8 = 1 - math.exp(p * -15)
			part.Transparency += ((v7 and origTrans or 1) - part.Transparency) * v8
		end

		if not (_config.colorCycle and #_config.colorPalette > 0) then
			continue
		end

		_laser.colorCycleTimer -= p

		if not (_laser.colorCycleTimer <= 0) then
			continue
		end

		_laser.colorCycleTimer = _config.colorCycleMinSec + math.random() * (_config.colorCycleMaxSec - _config.colorCycleMinSec)
		local v8 = pickRandomColor(_config.colorPalette, _laser.lastColor)
		_laser.lastColor = v8

		if _laser.colorPart then
			_laser.colorPart.Color = v8
		end

		for _, colorBeamPart in _laser.colorBeamParts do
			colorBeamPart.Color = v8
		end
	end
end

function LaserSweep:destroy()
	for _, _laser in self._lasers do
		if not (_laser.baseModel and _laser.baseModel.Parent) then
			continue
		end

		local v3 = _laser
		pcall(function()
			v3.baseModel:PivotTo(v3.baseCFrame)
		end)
	end

	table.clear(self._lasers)
end

return LaserSweep