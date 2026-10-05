local CollectionService = game:GetService("CollectionService")
local SpeakerShockwaves = {}
SpeakerShockwaves.__index = SpeakerShockwaves
local v = {
	BeatThreshold = 1.2,
	BeatCooldown = 0.2,
	beatAvgRate = 1.5,
	SmallShockwaveEmitCount = 1,
	BigShockwaveEmitCount = 2,
	MaximumShockwaveMultiplier = 3
}

-- equivalent calls inferred from this helper; original call sites unknown
local function ema(p: number, p2: number, p3: number, p4: number)
	return p + (1 - math.exp(-p3 * p4)) * (p2 - p)
end

function SpeakerShockwaves.new(items)
	local config = {}

	for k, v3 in v do
		config[k] = v3
	end

	if items then
		for k, item in items do
			config[k] = item
		end
	end

	local self = setmetatable({}, SpeakerShockwaves)
	self._config = config
	self._speakers = {}
	self._connections = {}
	self._beatAvg = 0
	self._beatCooldownTimer = 0
	self:_initCollectionService()
	return self
end

function SpeakerShockwaves:_cacheSpeaker(model)
	if not model:IsA("Model") then
		return
	end

	local v2 = {
		model = model,
		smallEmitters = {},
		bigEmitters = {}
	}
	local circleBeamSmall = model:FindFirstChild("CircleBeamSmall")

	if circleBeamSmall then
		local main = circleBeamSmall:FindFirstChild("Main")

		if main then
			for _, emitter in ipairs(main:GetChildren()) do
				if emitter:IsA("ParticleEmitter") and emitter.Name == "ShockWave" then
					table.insert(v2.smallEmitters, emitter)
				end
			end
		end
	end

	local circleBeamBig = model:FindFirstChild("CircleBeamBig")

	if circleBeamBig then
		local main = circleBeamBig:FindFirstChild("Main")

		if main then
			for _, emitter in ipairs(main:GetChildren()) do
				if emitter:IsA("ParticleEmitter") and emitter.Name == "ShockWave" then
					table.insert(v2.bigEmitters, emitter)
				end
			end
		end
	end

	if #v2.smallEmitters > 0 or #v2.bigEmitters > 0 then
		self._speakers[model] = v2
	end
end

function SpeakerShockwaves:_initCollectionService()
	for _, tag in ipairs({ "Speaker", "MiniSpeaker" }) do
		for _, v2 in ipairs(CollectionService:GetTagged(tag)) do
			self:_cacheSpeaker(v2)
		end

		local connection = CollectionService:GetInstanceAddedSignal(tag):Connect(function(p)
			self:_cacheSpeaker(p)
		end)
		local connection2 = CollectionService:GetInstanceRemovedSignal(tag):Connect(function(p)
			self._speakers[p] = nil
		end)
		table.insert(self._connections, connection)
		table.insert(self._connections, connection2)
	end
end

function SpeakerShockwaves:update(p: number, value: number)
	local _config = self._config
	local v2 = value or 0
	self._beatAvg = ema(self._beatAvg, v2, _config.beatAvgRate, p)
	self._beatCooldownTimer = math.max(0, self._beatCooldownTimer - p)
	local v3, flag

	if self._beatCooldownTimer <= 0 and self._beatAvg > 0.02 and self._beatAvg * _config.BeatThreshold < v2 then
		self._beatCooldownTimer = _config.BeatCooldown
		v3 = math.clamp(v2 / (self._beatAvg * _config.BeatThreshold), 1, _config.MaximumShockwaveMultiplier)
		flag = true
	else
		flag = false
		v3 = 1
	end

	if flag then
		local v4 = math.floor(_config.SmallShockwaveEmitCount * v3 + 0.5)
		local v5 = math.floor(_config.BigShockwaveEmitCount * v3 + 0.5)

		for _, _speaker in pairs(self._speakers) do
			if v4 > 0 then
				for _, smallEmitter in ipairs(_speaker.smallEmitters) do
					smallEmitter:Emit(v4)
				end
			end

			if not (v5 > 0) then
				continue
			end

			for _, bigEmitter in ipairs(_speaker.bigEmitters) do
				bigEmitter:Emit(v5)
			end
		end
	end
end

function SpeakerShockwaves:destroy()
	for _, _connection in ipairs(self._connections) do
		_connection:Disconnect()
	end

	table.clear(self._connections)
	table.clear(self._speakers)
end

return SpeakerShockwaves