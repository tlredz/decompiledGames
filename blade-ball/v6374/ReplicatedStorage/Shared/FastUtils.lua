local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local random = Random.new()
local FastUtils = {
	resolveNumber = function(p)
		if typeof(p) == "NumberRange" then
			return (random:NextNumber(p.Min, p.Max))
		end

		return p
	end
}

function FastUtils.fastAudio(soundId: string, parent, p, p2, p3)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.SoundGroup = SoundService:FindFirstChild("SFX")
	sound.Volume = (not p and 1 or FastUtils.resolveNumber(p)) / 0.5
	local v = not p3 and 0 or FastUtils.resolveNumber(p3)
	local playbackSpeed = not p2 and 1 or FastUtils.resolveNumber(p2)
	sound.PlaybackSpeed = playbackSpeed
	sound.TimePosition = v * playbackSpeed
	sound.Parent = parent
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	sound:Play()
	return sound
end

function FastUtils.fastTween(p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)
	tween.Destroying:Once(function()
		tween:Cancel()
		tween = nil
	end)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

function FastUtils.fastScaleToTween(instance, p, p2: number, flag: boolean?, p3: number?)
	local numberPose = Instance.new("NumberPose")
	local tween = TweenService:Create(numberPose, p, {
		Value = p2
	})
	numberPose:GetPropertyChangedSignal("Value"):Connect(function()
		instance:ScaleTo((math.clamp(numberPose.Value, 0.001, 1e999)))
	end)
	numberPose.Value = p3 or instance:GetScale()

	if flag ~= false then
		tween:Play()
	end

	tween.Completed:Connect(function()
		numberPose:Destroy()
		tween:Destroy()
	end)
	tween.Destroying:Connect(function()
		numberPose:Destroy()
	end)
	return tween
end

function FastUtils:flipbook(point: Vector2, point2: Vector2, p2: number, value: number?)
	local v = point2.X * point2.Y
	local vector = Vector2.new(point.X / point2.X, point.Y / point2.Y)
	local v2 = p2 / v
	local lastTime = os.clock()
	self.ImageRectSize = vector
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v3 = os.clock() - lastTime

		if (value or 0) < v3 // p2 then
			heartbeatConnection:Disconnect()
			return
		end

		local v5 = math.floor(v3 / v2) % v
		self.ImageRectOffset = Vector2.new(v5 % point2.Y * vector.X, v5 // point2.X * vector.Y)
	end)
end

local class = {}
class.__index = class

function class.Get(p)
	return table.remove(p.Storage, math.random(1, (math.max(#p.Storage, 1)))) or p.CreateFn()
end

function class.Return(p, p2)
	table.insert(p.Storage, p2)
end

function class:Destroy()
	local storage = self.Storage
	local v = next(storage)

	while v do
		self.DestroyFn(storage[v])
		storage[v] = nil
		v = next(storage)
	end

	table.clear(self)
end

function FastUtils.createCacheBank(createFn, callback2)
	local v = {
		CreateFn = createFn,
		DestroyFn = callback2,
		Storage = {}
	}
	setmetatable(v, class)
	return v
end

function FastUtils.createInstanceBank(instance)
	return FastUtils.createCacheBank(function()
		return instance:Clone()
	end, function(instance2)
		instance2:Destroy()
	end)
end

return FastUtils