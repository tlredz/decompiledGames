local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local class = {}
class.__index = class

function class.new(sound, value)
	local object = setmetatable({}, class)
	assert(sound and sound:IsA("Sound"), "SoundPool requires a Sound instance as template")
	local poolSize = value or 10
	object.template = sound
	object.poolSize = poolSize
	object.available = {}
	object.inUse = {}
	object.totalCreated = 0

	for _ = 1, poolSize do
		local _createSound = object:_createSound()
		table.insert(object.available, _createSound)
	end

	object.cleanupConnection = RunService.Heartbeat:Connect(function()
		object:_recycleSounds()
	end)
	return object
end

function class:GetSound()
	local v

	if #self.available > 0 then
		v = table.remove(self.available)
	else
		if self.totalCreated >= self.poolSize * 2 then
			warn(string.format(
				"[SoundPool] Pool size exceeded! Created %d sounds (pool size: %d)",
				self.totalCreated,
				self.poolSize
			))
		end

		v = self:_createSound()
	end

	self.inUse[v] = {
		startTime = tick(),
		hasStarted = false
	}
	return v
end

function class:PlaySound(items)
	local sound = self:GetSound()

	if items then
		for k, item in pairs(items) do
			local v = k

			if k == "Parent" then
				continue
			end

			if not pcall(function()
				return sound[v]
			end) then
				continue
			end

			sound[k] = item
		end
	end

	sound:Play()
	sound.Ended:Once(function()
		self:RecycleSound(sound)
	end)
	return sound
end

function class:RecycleSound(instance)
	if not self.inUse[instance] then
		return
	end

	self.inUse[instance] = nil
	instance:Stop()
	instance.TimePosition = 0
	instance.Volume = self.template.Volume
	instance.Pitch = self.template.Pitch or 1
	instance.EmitterSize = self.template.EmitterSize
	instance.RollOffMaxDistance = self.template.RollOffMaxDistance
	instance.RollOffMinDistance = self.template.RollOffMinDistance
	instance.PlaybackSpeed = self.template.PlaybackSpeed or 1

	if #self.available < self.poolSize then
		table.insert(self.available, instance)
		return
	end

	instance:Destroy()
	self.totalCreated -= 1
end

function class:_createSound()
	local clone = self.template:Clone()
	clone.Parent = self.template.Parent or SoundService
	self.totalCreated += 1
	return clone
end

function class:_recycleSounds()
	local now = tick()

	for k, v in pairs(self.inUse) do
		if k.IsPlaying then
			v.hasStarted = true
		end

		if v.hasStarted then
			if not k.IsPlaying and now - v.startTime > 0.1 then
				self:RecycleSound(k)
			end
		elseif now - v.startTime > 5 then
			self:RecycleSound(k)
		end
	end
end

function class:GetStats()
	return {
		available = #self.available,
		inUse = self:_countTable(self.inUse),
		totalCreated = self.totalCreated,
		poolSize = self.poolSize
	}
end

function class:Destroy()
	if self.cleanupConnection then
		self.cleanupConnection:Disconnect()
		self.cleanupConnection = nil
	end

	for _, v in ipairs(self.available) do
		v:Destroy()
	end

	for k, _ in pairs(self.inUse) do
		k:Destroy()
	end

	self.available = {}
	self.inUse = {}
	self.template = nil
end

function class:_countTable(items)
	local count = 0

	for _ in pairs(items) do
		count += 1
	end

	return count
end

return {
	SoundPool = class,
	SoundPoolManager = {
		pools = {},
		GetPool = function(p, p2, p3, p4)
			if not p.pools[p2] and p3 then
				p.pools[p2] = class.new(p3, p4)
			end

			return p.pools[p2]
		end,
		DestroyPool = function(p, p2)
			if p.pools[p2] then
				p.pools[p2]:Destroy()
				p.pools[p2] = nil
			end
		end,
		DestroyAllPools = function(p)
			for _, pool in pairs(p.pools) do
				pool:Destroy()
			end

			p.pools = {}
		end,
		GetAllStats = function(p)
			local stats = {}

			for k, pool in pairs(p.pools) do
				stats[k] = pool:GetStats()
			end

			return stats
		end
	}
}