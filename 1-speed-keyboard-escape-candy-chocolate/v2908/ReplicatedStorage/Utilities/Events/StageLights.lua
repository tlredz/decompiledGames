local CollectionService = game:GetService("CollectionService")
local StageLights = {}
StageLights.__index = StageLights

-- equivalent calls inferred from this helper; original call sites unknown
local function ema(p: number, p2: number, p3: number, p4: number)
	return p + (1 - math.exp(-p3 * p4)) * (p2 - p)
end

local function getRandomPointInBox(_zone)
	local size = _zone.Size
	local cFrame = _zone.CFrame
	local v = (math.random() - 0.5) * size.X
	local v2 = (math.random() - 0.5) * size.Y
	local v3 = (math.random() - 0.5) * size.Z
	return (cFrame * CFrame.new(v, v2, v3)).Position
end

local function pickRandomColor(colorPalette, lastColor: Color3?)
	local v = colorPalette[math.random(1, #colorPalette)]

	if v == lastColor and #colorPalette > 1 then
		for _, v2 in colorPalette do
			if v2 ~= lastColor then
				return v2
			end
		end
	end

	return v
end

local v = {
	ConcertScan = {}
}

function v.ConcertScan:init(data, _)
	self.currentCFrame = self.baseCFrame
	self.targetCFrame = self.baseCFrame
	self.speedMult = data.speedVariationMin + math.random() * (data.speedVariationMax - data.speedVariationMin)
	self.beatReactionDelay = math.random() * data.maxReactionDelay
	self.delayTimer = 0
	self.hasPendingTarget = true
	self.timeSinceLastTarget = 0
end

function v.ConcertScan:pickNewTarget(p2, p3)
	local _zone = p3._zones[p2.activeZone]

	if not _zone then
		return
	end

	local randomPointInBox = getRandomPointInBox(_zone)
	local cframe = CFrame.lookAt(self.baseCFrame.Position, randomPointInBox)
	local orientation, v2, v3 = self.baseCFrame:ToObjectSpace(cframe):ToOrientation()
	local minX = math.rad(p2.limits.minX)
	local maxX = math.rad(p2.limits.maxX)
	local minY = math.rad(p2.limits.minY)
	local maxY = math.rad(p2.limits.maxY)
	local minZ = math.rad(p2.limits.minZ)
	local maxZ = math.rad(p2.limits.maxZ)
	local v4 = math.clamp(orientation, minX, maxX)
	local v5 = math.clamp(v2, minY, maxY)
	local v6 = math.clamp(v3, minZ, maxZ)
	self.targetCFrame = self.baseCFrame * CFrame.fromOrientation(v4, v5, v6)
	self.timeSinceLastTarget = 0
end

function v.ConcertScan:update(p, p2, p3, data, p4)
	self.timeSinceLastTarget += p

	if p3 or self.timeSinceLastTarget >= data.autoTargetChangeSec then
		self.hasPendingTarget = true
		self.delayTimer = self.beatReactionDelay

		if not p3 then
			self.timeSinceLastTarget = math.random() * -0.5
		end
	end

	if self.hasPendingTarget then
		self.delayTimer = math.max(0, self.delayTimer - p)

		if self.delayTimer <= 0 then
			v.ConcertScan.pickNewTarget(self, data, p4)
			self.hasPendingTarget = false
		end
	end

	local v2 = not (p2 > 0.01) and 0 or (data.baseSpeed + (data.maxSpeed - data.baseSpeed) * p2) * self.speedMult

	if v2 > 0 then
		local v3 = 1 - math.exp(-v2 * p)
		self.currentCFrame = self.currentCFrame:Lerp(self.targetCFrame, v3)
		self.baseModel:PivotTo(self.currentCFrame)
	end
end

v.SkyRise = {}

function v.SkyRise:init(_, _)
	self.currentCFrame = self.baseModel:GetPivot()
	self.sweepPhase = math.random() * 3.141592653589793 * 2
	self.speedMult = 1
end

function v.SkyRise:update(p, p2, _, p3, _)
	local v2 = 0.5 + p2 * 2
	self.sweepPhase += p * v2
	local v3 = math.sin(self.sweepPhase) * 0.2617993877991494
	self.targetCFrame = self.baseCFrame * CFrame.fromOrientation(0.7853981633974483, v3, 0)
	local v4

	if p2 > 0.01 then
		if p2 > 0.7 then
			p2 = p2 * 2 or p2
		end

		v4 = (p3.baseSpeed + (p3.maxSpeed - p3.baseSpeed) * p2) * self.speedMult
	else
		v4 = 0
	end

	if v4 > 0 then
		local v5 = 1 - math.exp(-v4 * p)
		self.currentCFrame = self.currentCFrame:Lerp(self.targetCFrame, v5)
		self.baseModel:PivotTo(self.currentCFrame)
	end
end

v.Fan = {}

function v.Fan:init(_, _)
	self.currentCFrame = self.baseModel:GetPivot()
	self.sweepPhase = math.random() * 3.141592653589793 * 2
	self.speedMult = 1
end

function v.Fan:update(p, p2, _, p3, p4)
	local v2 = 0.5 + p2 * 2
	self.sweepPhase += p * v2
	local count = #p4._lights
	local v3 = count <= 1 and 2 or count
	local v4 = math.rad(-60 + 120 * (((table.find(p4._lights, self) or 1) - 1) / (v3 - 1))) + math.sin(self.sweepPhase) * 0.17453292519943295
	local v5 = math.cos(self.sweepPhase) * 0.17453292519943295 + 0.5235987755982988
	self.targetCFrame = self.baseCFrame * CFrame.fromOrientation(v5, v4, 0)
	local v6

	if p2 > 0.01 then
		if p2 > 0.7 then
			p2 = p2 * 2 or p2
		end

		v6 = (p3.baseSpeed + (p3.maxSpeed - p3.baseSpeed) * p2) * self.speedMult
	else
		v6 = 0
	end

	if v6 > 0 then
		local v7 = 1 - math.exp(-v6 * p)
		self.currentCFrame = self.currentCFrame:Lerp(self.targetCFrame, v7)
		self.baseModel:PivotTo(self.currentCFrame)
	end
end

v.Cross = {}

function v.Cross:init(_, _)
	self.currentCFrame = self.baseModel:GetPivot()
	self.sweepPhase = 0
	self.speedMult = 1
end

function v.Cross:update(p, p2, _, p3, p4)
	local v2 = 1 + p2 * 3
	self.sweepPhase += p * v2
	local v3 = #p4._lights
	local index = table.find(p4._lights, self) or 1
	local v4 = index <= v3 / 2 and 0.7853981633974483 or -0.7853981633974483
	local v5 = math.sin(self.sweepPhase + index) * 0.3490658503988659 + 0.2617993877991494
	self.targetCFrame = self.baseCFrame * CFrame.fromOrientation(v5, v4, 0)
	local v6

	if p2 > 0.01 then
		if p2 > 0.7 then
			p2 = p2 * 2 or p2
		end

		v6 = (p3.baseSpeed + (p3.maxSpeed - p3.baseSpeed) * p2) * self.speedMult
	else
		v6 = 0
	end

	if v6 > 0 then
		local v7 = 1 - math.exp(-v6 * p)
		self.currentCFrame = self.currentCFrame:Lerp(self.targetCFrame, v7)
		self.baseModel:PivotTo(self.currentCFrame)
	end
end

v.Blackout = {}

function v.Blackout:init(_, _)
	self.currentCFrame = self.baseModel:GetPivot()
	self.speedMult = 1
end

function v.Blackout:update(p, _, _, p2, _)
	self.targetCFrame = self.baseCFrame * CFrame.fromOrientation(-1.5707963267948966, 0, 0)
	local v2 = 1 - math.exp(-(p2.maxSpeed * 3 * self.speedMult) * p)
	self.currentCFrame = self.currentCFrame:Lerp(self.targetCFrame, v2)
	self.baseModel:PivotTo(self.currentCFrame)
end

v.AudienceSweep = {}

function v.AudienceSweep:init(_, _)
	self.currentCFrame = self.baseModel:GetPivot()
	self.sweepPhase = 0
	self.speedMult = 1
end

function v.AudienceSweep:update(p, p2, _, p3, _)
	local v2 = 0.5 + p2 * 2
	self.sweepPhase += p * v2
	local v3 = math.sin(self.sweepPhase) * 1.0471975511965976
	local v4 = math.cos(self.sweepPhase * 2) * 0.2617993877991494 + -0.2617993877991494
	self.targetCFrame = self.baseCFrame * CFrame.fromOrientation(v4, v3, 0)
	local v5

	if p2 > 0.01 then
		if p2 > 0.7 then
			p2 = p2 * 2 or p2
		end

		v5 = (p3.baseSpeed + (p3.maxSpeed - p3.baseSpeed) * p2) * self.speedMult
	else
		v5 = 0
	end

	if v5 > 0 then
		local v6 = 1 - math.exp(-v5 * p)
		self.currentCFrame = self.currentCFrame:Lerp(self.targetCFrame, v6)
		self.baseModel:PivotTo(self.currentCFrame)
	end
end

v.Mirror = {}

function v.Mirror:init(_, p2)
	self.currentCFrame = self.baseModel:GetPivot()
	self.sweepPhase = 0
	local v2 = #p2._lights
	local index = table.find(p2._lights, self) or 1
	local midpoint = (v2 + 1) / 2
	self.mirrorSign = index < midpoint and 1 or midpoint < index and -1 or 0
	self.speedMult = 1
end

function v.Mirror:update(p, p2, _, p3, _)
	local v2 = 0.5 + p2 * 2.5
	self.sweepPhase += p * v2
	local v3 = math.sin(self.sweepPhase) * 1.0471975511965976 * self.mirrorSign
	local v4 = self.mirrorSign == 0 and 0 or v3
	self.targetCFrame = self.baseCFrame * CFrame.fromOrientation(0.3490658503988659, v4, 0)
	local v5

	if p2 > 0.01 then
		if p2 > 0.7 then
			p2 = p2 * 2 or p2
		end

		v5 = (p3.baseSpeed + (p3.maxSpeed - p3.baseSpeed) * p2) * self.speedMult
	else
		v5 = 0
	end

	if v5 > 0 then
		local v6 = 1 - math.exp(-v5 * p)
		self.currentCFrame = self.currentCFrame:Lerp(self.targetCFrame, v6)
		self.baseModel:PivotTo(self.currentCFrame)
	end
end

v.Wave = {}

function v.Wave:init(_, p2)
	self.currentCFrame = self.baseModel:GetPivot()
	self.sweepPhase = (table.find(p2._lights, self) or 1) * 0.5
	self.speedMult = 1
end

function v.Wave:update(p, p2, _, p3, _)
	local v2 = 0.5 + p2 * 2
	self.sweepPhase += p * v2
	local v3 = math.sin(self.sweepPhase) * 1.0471975511965976
	local v4 = math.cos(self.sweepPhase) * 0.5235987755982988 + -0.2617993877991494
	self.targetCFrame = self.baseCFrame * CFrame.fromOrientation(v4, v3, 0)
	local v5

	if p2 > 0.01 then
		if p2 > 0.7 then
			p2 = p2 * 2 or p2
		end

		v5 = (p3.baseSpeed + (p3.maxSpeed - p3.baseSpeed) * p2) * self.speedMult
	else
		v5 = 0
	end

	if v5 > 0 then
		local v6 = 1 - math.exp(-v5 * p)
		self.currentCFrame = self.currentCFrame:Lerp(self.targetCFrame, v6)
		self.baseModel:PivotTo(self.currentCFrame)
	end
end

v.Alternating = {}

function v.Alternating:init(_, p2)
	self.currentCFrame = self.baseModel:GetPivot()
	self.isOdd = (table.find(p2._lights, self) or 1) % 2 ~= 0
	self.state = true
	self.speedMult = 1
	self.sweepPhase = 0
end

function v.Alternating:update(p, p2, p3, p4, _)
	if p3 then
		self.state = not self.state
	end

	local v2 = 0.5 + p2 * 2
	self.sweepPhase += p * v2
	local v3

	if self.isOdd then
		v3 = self.state and -0.7853981633974483 or 0.7853981633974483
	else
		v3 = self.state and 0.7853981633974483 or -0.7853981633974483
	end

	local v4 = math.sin(self.sweepPhase) * 0.17453292519943295
	self.targetCFrame = self.baseCFrame * CFrame.fromOrientation(v4 + 0.2617993877991494, v3, 0)
	local v5

	if p2 > 0.01 then
		if p2 > 0.7 then
			p2 = p2 * 2 or p2
		end

		v5 = (p4.baseSpeed + (p4.maxSpeed - p4.baseSpeed) * p2) * self.speedMult
	else
		v5 = 0
	end

	if v5 > 0 then
		local v6 = 1 - math.exp(-v5 * p)
		self.currentCFrame = self.currentCFrame:Lerp(self.targetCFrame, v6)
		self.baseModel:PivotTo(self.currentCFrame)
	end
end

local v2 = {
	pattern = "ConcertScan",
	activeZone = "PublicZone",
	limits = {
		minX = -45,
		maxX = 45,
		minY = -120,
		maxY = 120,
		minZ = -20,
		maxZ = 20
	},
	baseSpeed = 2.5,
	maxSpeed = 14,
	maxReactionDelay = 0.15,
	autoTargetChangeSec = 1.2,
	peakSmoothRate = 15,
	beatAvgRate = 1,
	beatThreshold = 1.4,
	beatCooldown = 0.3,
	speedVariationMin = 0.85,
	speedVariationMax = 1.15,
	colorCycle = false,
	colorPalette = {},
	colorCycleMinSec = 3,
	colorCycleMaxSec = 8
}

function StageLights.new(items)
	local config = {}

	for k, v4 in v2 do
		if type(v4) == "table" then
			config[k] = {}

			for k2, v5 in v4 do
				config[k][k2] = v5
			end
		else
			config[k] = v4
		end
	end

	if items then
		for k, item in items do
			if type(item) == "table" and type(config[k]) == "table" then
				for k2, v4 in item do
					config[k][k2] = v4
				end
			else
				config[k] = item
			end
		end
	end

	local self = setmetatable({}, StageLights)
	self._config = config
	self._lights = {}
	self._zones = {}
	self._pattern = v[config.pattern]
	self._smoothedPeak = 0
	self._beatAvg = 0
	self._beatCooldownTimer = 0

	if not self._pattern then
		warn(string.format("[StageLights] Pattern '%s' inconnu, aucune animation.", (tostring(config.pattern))))
	end

	return self
end

function StageLights:setPattern(pattern: string)
	if v[pattern] then
		self._config.pattern = pattern
		self._pattern = v[pattern]

		if self._pattern.init then
			for _, _light in self._lights do
				self._pattern.init(_light, self._config, self)
			end
		end
	else
		warn("[StageLights] Pattern inconnu lors de setPattern: " .. tostring(pattern))
	end
end

function StageLights:scan(instance)
	table.clear(self._lights)
	table.clear(self._zones)

	if not instance then
		return
	end

	local _config = self._config
	local _pattern = self._pattern

	for _, childName in ipairs({ "PublicZone", "SkyZone", "StageCenter" }) do
		local part = instance:FindFirstChild(childName)

		if part and part:IsA("BasePart") then
			self._zones[childName] = part
		end
	end

	for _, model in CollectionService:GetTagged("StageLight") do
		if not (model:IsDescendantOf(instance) and model:IsA("Model")) then
			continue
		end

		local base = model:FindFirstChild("Base")

		if not (base and base:IsA("Model")) then
			continue
		end

		local v3 = {
			baseModel = base,
			baseCFrame = base:GetPivot(),
			index = tonumber(model.Name) or tonumber(model.Parent.Name) or 999
		}

		if _config.colorCycle then
			v3.colorPart = base:FindFirstChild("ColorPart")
			local ceiling_Light = base:FindFirstChild("Ceiling_Light")
			local beamBase = ceiling_Light and ceiling_Light:FindFirstChild("BeamBase")
			v3.colorBeam = beamBase and beamBase:FindFirstChild("Beam")
			v3.Spotlight = beamBase and beamBase:FindFirstChildOfClass("SpotLight")
			v3.colorCycleTimer = math.random() * _config.colorCycleMaxSec
			v3.lastColor = nil
		end

		table.insert(self._lights, v3)
	end

	table.sort(self._lights, function(a, b)
		return a.index < b.index
	end)

	if _pattern and _pattern.init then
		for _, _light in self._lights do
			_pattern.init(_light, _config, self)
		end
	end

	warn(string.format("[StageLights] %d StageLight(s) (triés numériquement) et zones détectés", #self._lights))
end

function StageLights:update(p: number, value: number)
	if #self._lights == 0 then
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

	for _, _light in self._lights do
		if not (_light.baseModel and _light.baseModel.Parent) then
			continue
		end

		_pattern.update(_light, p, v4, v5, _config, self)
		local v6 = _config.pattern == "Blackout"
		local v7

		if v4 > 0.01 then
			v7 = not v6
		else
			v7 = false
		end

		if _light.wasPlaying ~= v7 then
			_light.wasPlaying = v7

			for _, descendant in _light.baseModel:GetDescendants() do
				if not (descendant:IsA("Beam") or descendant:IsA("Light") or descendant:IsA("ParticleEmitter")) then
					continue
				end

				descendant.Enabled = v7
			end
		end

		for _, part in _light.baseModel:GetDescendants() do
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

		_light.colorCycleTimer -= p

		if not (_light.colorCycleTimer <= 0) then
			continue
		end

		_light.colorCycleTimer = _config.colorCycleMinSec + math.random() * (_config.colorCycleMaxSec - _config.colorCycleMinSec)
		local v8 = pickRandomColor(_config.colorPalette, _light.lastColor)
		_light.lastColor = v8

		if _light.colorPart then
			_light.colorPart.Color = v8
		end

		if _light.colorBeam then
			_light.colorBeam.Color = ColorSequence.new(v8)
		end

		if _light.Spotlight then
			_light.Spotlight.Color = v8
		end
	end
end

function StageLights:destroy()
	for _, _light in self._lights do
		if not (_light.baseModel and _light.baseModel.Parent) then
			continue
		end

		local v3 = _light
		pcall(function()
			v3.baseModel:PivotTo(v3.baseCFrame)
		end)
	end

	table.clear(self._lights)
	table.clear(self._zones)
end

return StageLights