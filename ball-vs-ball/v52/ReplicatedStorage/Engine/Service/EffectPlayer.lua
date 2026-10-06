local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelAudioController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelAudioController"))
local Debris = game:GetService("Debris")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local EffectLifetime = require(script:WaitForChild("EffectLifetime"))

local function getNumberAttribute(instance, attributeName: string, p: number)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) == "number" then
		return attribute
	end

	return p
end

local function playParticleEmitterForDuration(instance, duration: number)
	local rate = instance.Rate

	if rate <= 0 then
		task.wait(duration)
		return
	end

	local v = 1 / rate
	local total = 0
	local v2 = 0

	while total < duration and instance.Parent and not EffectLifetime.isVisualHidden(instance) do
		local v3 = RunService.Heartbeat:Wait()
		total += v3
		v2 += v3
		local count = 0

		while v <= v2 do
			v2 -= v
			instance:Emit(1)
			count += 1

			if count >= 25 then
				break
			end
		end
	end
end

local function playParticleEmitter(instance)
	local emitDelay = instance:GetAttribute("EmitDelay")
	local v = typeof(emitDelay) ~= "number" and 0 or emitDelay
	local emitDuration = instance:GetAttribute("EmitDuration")
	local v2 = typeof(emitDuration) ~= "number" and 0 or emitDuration

	if v > 0 then
		task.wait(v)
	end

	if v2 > 0 then
		playParticleEmitterForDuration(instance, v2)
	elseif instance.Parent and not EffectLifetime.isVisualHidden(instance) then
		local emitCount = instance:GetAttribute("EmitCount")
		instance:Emit(typeof(emitCount) ~= "number" and 10 or emitCount)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(instance)
	DuelAudioController.prepare(instance)

	if instance.RollOffMaxDistance > 1000 then
		warn(string.format(
			"[EffectPlayer] Sound '%s' 的 RollOffMaxDistance (%d) 超过 1000，请检查衰减范围设置是否正常",
			instance:GetFullName(),
			instance.RollOffMaxDistance
		))
	end

	instance:Play()
end

local function collectSoundsByName(folder)
	local soundsByName = {}

	for _, sound in ipairs(folder:GetDescendants()) do
		if sound:IsA("Sound") and soundsByName[sound.Name] == nil then
			soundsByName[sound.Name] = sound
		end
	end

	return soundsByName
end

-- equivalent calls inferred from this helper; original call sites unknown
local function connectAnimationEventSounds(p, track)
	track:GetMarkerReachedSignal("播放音效"):Connect(function(p2: string)
		local v = p[p2]

		if v then
			playSound(v) -- equivalent call inferred; original call site unknown
		end
	end)
end

local function loadAnimationTracks(folder)
	local v = collectSoundsByName(folder)
	local tracks = {}

	for _, animationController in ipairs(folder:GetDescendants()) do
		if not animationController:IsA("AnimationController") then
			continue
		end

		local animator = animationController:FindFirstChildOfClass("Animator")
		local animation = folder:FindFirstChildWhichIsA("Animation", true)

		if not (animator and animation and animation:IsA("Animation")) then
			continue
		end

		local track = animator:LoadAnimation(animation)
		connectAnimationEventSounds(v, track) -- equivalent call inferred; original call site unknown
		table.insert(tracks, track)
	end

	return tracks
end

local function computeCleanupDuration(p, p2)
	return (EffectLifetime.prepare(p, p2))
end

local function repositionIfNeeded(model, p)
	if p and model:IsA("Model") then
		if typeof(p) == "CFrame" then
			model:PivotTo(p)
		else
			local pivot = model:GetPivot()
			model:PivotTo(CFrame.new(p) * (pivot - pivot.Position))
		end
	end
end

local function triggerEffects(folder, p, p2: number?)
	local v = p or loadAnimationTracks(folder)
	local v2 = #v > 0

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			task.spawn(playParticleEmitter, descendant)
		elseif descendant:IsA("Sound") and not v2 then
			task.spawn(playSound, descendant)
		end
	end

	for _, v3 in ipairs(v) do
		if p2 == nil then
			v3:Play()
		else
			v3:Play(p2)
		end
	end

	return v
end

if RunService:IsClient() then
	task.spawn(function()
		local v = ReplicatedStorage2:WaitForChild("美术素材"):WaitForChild("爆炸特效")
		EffectLifetime.preload(v)
	end)
end

local EffectPlayer = {}

function EffectPlayer.play(p, p2)
	repositionIfNeeded(p, p2)
	local v = EffectLifetime.begin(p)
	task.spawn(function()
		local v2 = loadAnimationTracks(p)
		EffectLifetime.suspendVisuals(p, v)
		local v3, v4 = EffectLifetime.prepare(p, v2)

		if p.Parent and EffectLifetime.isCurrent(p, v) then
			v = EffectLifetime.begin(p)

			for _, v5 in v2 do
				v5.Looped = false
			end

			triggerEffects(p, v2)
			EffectLifetime.scheduleVisualCleanup(p, v, v4)
			Debris:AddItem(p, v3)
		else
			for _, v5 in v2 do
				v5:Destroy()
			end
		end
	end)
end

function EffectPlayer.playLive(p, p2)
	repositionIfNeeded(p, p2)
	local v = EffectLifetime.begin(p)
	local v2 = loadAnimationTracks(p)
	EffectLifetime.suspendVisuals(p, v)
	local v3, v4 = EffectLifetime.prepare(p, v2)

	if p.Parent and EffectLifetime.isCurrent(p, v) then
		local v5 = EffectLifetime.begin(p)

		for _, v6 in v2 do
			v6.Looped = false
		end

		triggerEffects(p, v2)
		EffectLifetime.scheduleVisualCleanup(p, v5, v4)
		return v3
	else
		for _, v5 in v2 do
			v5:Destroy()
		end

		return 0
	end
end

function EffectPlayer.playAndHold(instance, p, value: number, callback)
	local v

	if typeof(value) == "number" and value > 0 then
		v = value < 1
	else
		v = false
	end

	assert(v, "holdRatio 必须在 0 与 1 之间")
	repositionIfNeeded(instance, p)
	local v2 = loadAnimationTracks(instance)
	local flag = false
	local preAnimationConnection = nil
	local v3 = {
		destroy = function(_)
			if flag then
				return
			end

			flag = true

			if preAnimationConnection then
				preAnimationConnection:Disconnect()
				preAnimationConnection = nil
			end

			for _, v4 in ipairs(v2) do
				v4:Destroy()
			end

			instance:Destroy()
		end
	}
	task.spawn(function()
		local v4 = os.clock() + 5
		local flag2

		if #v2 == 0 then
			flag2 = true
		else
			flag2 = false
		end

		while not flag and #v2 > 0 do
			flag2 = true

			for _, v6 in ipairs(v2) do
				if not (v6.Length <= 0) then
					continue
				end

				flag2 = false
				break
			end

			if flag2 or v4 <= os.clock() then
				break
			else
				RunService.Heartbeat:Wait()
			end
		end

		if flag then
			return
		end

		if flag2 then
			for _, v5 in ipairs(v2) do
				v5.Looped = false
			end

			triggerEffects(instance, v2, 0)

			if #v2 == 0 then
				if callback then
					task.delay(EffectLifetime.prepare(instance, {}), function()
						if not flag then
							callback()
						end
					end)
				end
			else
				local v5 = {}
				preAnimationConnection = RunService.PreAnimation:Connect(function(dt: number)
					if flag then
						return
					end

					local v6 = true

					for _, v7 in ipairs(v2) do
						if v5[v7] then
							continue
						end

						if v7.IsPlaying and v7.Length > 0 then
							local timePosition = v7.Length * value

							if timePosition <= v7.TimePosition + dt * math.max(v7.Speed, 0) then
								v7:AdjustSpeed(0)
								v7.TimePosition = timePosition
								v5[v7] = true
							else
								v6 = false
							end
						else
							v6 = false
						end
					end

					if v6 and preAnimationConnection then
						preAnimationConnection:Disconnect()
						preAnimationConnection = nil

						if callback and not flag then
							task.spawn(callback)
						end
					end
				end)
			end
		else
			warn(string.format("[EffectPlayer] 常驻特效动画加载超时，无法定格在 %.0f%%: %s", value * 100, instance:GetFullName()))

			for _, v5 in ipairs(v2) do
				v5:Destroy()
			end

			triggerEffects(instance, {})

			if callback then
				task.delay(EffectLifetime.prepare(instance, {}), function()
					if not flag then
						callback()
					end
				end)
			end
		end
	end)
	return v3
end

function EffectPlayer.playEmbeddedSounds(folder)
	for _, sound in ipairs(folder:GetDescendants()) do
		if not sound:IsA("Sound") then
			continue
		end

		local v = sound
		task.spawn(function()
			v.TimePosition = 0
			playSound(v) -- equivalent call inferred; original call site unknown
		end)
	end
end

function EffectPlayer.playModule(childName: string, ...)
	local moduleScript = ReplicatedStorage2:WaitForChild("美术素材"):WaitForChild("模块特效"):FindFirstChild(childName)
	assert(moduleScript and moduleScript:IsA("ModuleScript"), string.format("[EffectPlayer] 模块特效缺失：%s", childName))
	local module = require(moduleScript)
	assert(type(module) == "function", string.format("[EffectPlayer] 模块特效 '%s' 必须 return 一个 function", childName))
	return module(...)
end

return EffectPlayer