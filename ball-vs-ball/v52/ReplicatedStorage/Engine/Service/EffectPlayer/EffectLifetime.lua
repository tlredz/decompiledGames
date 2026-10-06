local ContentProvider = game:GetService("ContentProvider")
local AnimationClipProvider = game:GetService("AnimationClipProvider")
local EffectLifetime = {}
local v = {}
local v2 = {}
local v3 = {}
local object = setmetatable({}, {
	__mode = "k"
})

function EffectLifetime.extractEvents(folder)
	local result = {}

	if folder:IsA("KeyframeSequence") then
		for _, v4 in folder:GetKeyframes() do
			for _, v5 in v4:GetMarkers() do
				table.insert(result, {
					time = v4.Time,
					name = v5.Name,
					value = v5.Value
				})
			end
		end
	elseif folder:IsA("CurveAnimation") then
		for _, markerCurve in folder:GetDescendants() do
			if not markerCurve:IsA("MarkerCurve") then
				continue
			end

			for _, v4 in markerCurve:GetMarkers() do
				table.insert(result, {
					time = v4.Time,
					name = markerCurve.Name,
					value = v4.Value
				})
			end
		end
	else
		error("Unsupported animation clip: " .. folder.ClassName)
	end

	table.sort(result, function(a, b)
		return a.time < b.time
	end)
	return result
end

function EffectLifetime.getEvents(p: string)
	if v[p] then
		return v[p]
	end

	if not v2[p] then
		v2[p] = true
		task.spawn(function()
			local success, result = pcall(function()
				local animationClipAsync = AnimationClipProvider:GetAnimationClipAsync(p)
				return EffectLifetime.extractEvents(animationClipAsync)
			end)

			if success then
				v[p] = result
			else
				warn("[EffectLifetime] Cannot read animation events: " .. p .. ": " .. tostring(result))
			end

			v2[p] = nil
		end)
	end

	local v4 = os.clock() + 5

	while v2[p] and os.clock() < v4 do
		task.wait()
	end

	return v[p]
end

local function preloadSound(p)
	if p.TimeLength > 0 or p.SoundId == "" then
		return
	end

	local soundId = p.SoundId

	if not v3[soundId] then
		v3[soundId] = true
		task.spawn(function()
			local success, result = pcall(function()
				ContentProvider:PreloadAsync({ p })
			end)

			if not success then
				warn("[EffectLifetime] Sound preload failed: " .. soundId .. ": " .. tostring(result))
			end

			v3[soundId] = nil
		end)
	end
end

function EffectLifetime.soundDuration(p)
	return (not (p.TimeLength > 0) and 3 or p.TimeLength) / math.max(p.PlaybackSpeed, 0.01)
end

function EffectLifetime.isVisualHidden(parent)
	while parent do
		local v4 = object[parent]

		if v4 and v4.hidden then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

function EffectLifetime.begin(p)
	local v4 = object[p]

	if v4 then
		for _, v5 in v4.saved do
			if v5.object.Parent then
				v5.object[v5.property] = v5.value
			end
		end
	end

	local v5 = {
		hidden = false,
		saved = {}
	}
	object[p] = v5
	return v5
end

local function hideVisuals(folder, p)
	p.hidden = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function set(instance, property: string, p3)
		table.insert(p.saved, {
			object = instance,
			property = property,
			value = instance[property]
		})
		instance[property] = p3
	end

	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)

	for _, instance in descendants do
		if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
			set(instance, "Transparency", 1) -- equivalent call inferred; original call site unknown
		elseif instance:IsA("ParticleEmitter") then
			set(instance, "Enabled", false) -- equivalent call inferred; original call site unknown
			instance:Clear()
		elseif instance:IsA("Trail") then
			set(instance, "Enabled", false) -- equivalent call inferred; original call site unknown
			instance:Clear()
		elseif instance:IsA("Beam") or instance:IsA("Light") or instance:IsA("BillboardGui") or instance:IsA("SurfaceGui") then
			set(instance, "Enabled", false) -- equivalent call inferred; original call site unknown
		elseif instance:IsA("Highlight") then
			set(instance, "Enabled", false) -- equivalent call inferred; original call site unknown
		end
	end
end

function EffectLifetime.isCurrent(p, p2)
	return object[p] == p2
end

function EffectLifetime.suspendVisuals(p, p2)
	hideVisuals(p, p2)
end

function EffectLifetime.scheduleVisualCleanup(p, p2, duration: number?)
	if duration == nil then
		return
	end

	task.delay(duration, function()
		if p.Parent and object[p] == p2 then
			hideVisuals(p, p2)
		end
	end)
end

function EffectLifetime.prepare(folder, list, options)
	local sounds = {}
	local soundsByName = {}
	local v4 = options or {}

	for _, sound in folder:GetDescendants() do
		if not sound:IsA("Sound") then
			continue
		end

		table.insert(sounds, sound)

		if soundsByName[sound.Name] == nil then
			soundsByName[sound.Name] = sound
		end

		if v4.durationOfSound or sound.TimeLength > 0 or sound.SoundId == "" then
			continue
		end

		local soundId = sound.SoundId

		if v3[soundId] then
			continue
		end

		v3[soundId] = true
		local v5 = sound
		local soundId2 = soundId
		task.spawn(function()
			local success, result = pcall(function()
				ContentProvider:PreloadAsync({ v5 })
			end)

			if not success then
				warn("[EffectLifetime] Sound preload failed: " .. soundId2 .. ": " .. tostring(result))
			end

			v3[soundId2] = nil
		end)
	end

	local v5 = os.clock() + 5

	while folder.Parent do
		local v6 = true

		for _, v7 in list do
			if v7.Length <= 0 then
				v6 = false
			end
		end

		if not v4.durationOfSound then
			for _, v7 in sounds do
				if v7.SoundId ~= "" and v7.TimeLength <= 0 and v3[v7.SoundId] then
					v6 = false
				end
			end
		end

		if not v6 and os.clock() < v5 then
			task.wait()

			if not v6 then
				continue
			end
		end

		if not v6 then
			warn("[EffectLifetime] Preparation timed out; using conservative duration: " .. folder:GetFullName())
		end

		if not folder.Parent then
			return 0, nil
		end

		local durationOfSound = v4.durationOfSound or EffectLifetime.soundDuration
		local resolveSound = v4.resolveSound or function(p: string)
			return soundsByName[p]
		end
		local eventNames = v4.eventNames or {
			["播放音效"] = true
		}
		local v7 = 0
		local v8 = 0

		for _, emitter in folder:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local emitDelay = emitter:GetAttribute("EmitDelay")
			local emitDuration = emitter:GetAttribute("EmitDuration")
			v7 = math.max(
				v7,
				(typeof(emitDelay) ~= "number" and 0 or emitDelay) + (typeof(emitDuration) ~= "number" and 0 or emitDuration) + emitter.Lifetime.Max
			)
		end

		for _, v9 in list do
			local v10 = not (v9.Length > 0) and 3 or v9.Length
			v8 = math.max(v8, v10)
			v7 = math.max(v7, v10)
			local v11 = nil

			if v4.localClip then
				v11 = EffectLifetime.extractEvents(v4.localClip)
			elseif v9.Length > 0 then
				v11 = EffectLifetime.getEvents(v9.Animation.AnimationId)
			end

			if v11 then
				for _, v12 in v11 do
					if not eventNames[v12.name] then
						continue
					end

					local sound = resolveSound(v12.value)

					if sound then
						v7 = math.max(v7, v12.time + durationOfSound(sound))
					end
				end
			else
				local v12 = 0

				for _, v13 in sounds do
					v12 = math.max(v12, durationOfSound(v13))
				end

				v7 = math.max(v7, v10 + v12)
				warn("[EffectLifetime] Missing event metadata; using animation + sound fallback: " .. folder:GetFullName())
			end
		end

		if #list == 0 then
			for _, v9 in sounds do
				v7 = math.max(v7, durationOfSound(v9))
			end
		end

		if #list > 0 then
			return v7, v8 * 0.98
		end

		return v7, nil
	end

	return 0, nil
end

function EffectLifetime.preload(folder)
	local descendants = {}
	local v4 = {}

	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("Sound") or descendant:IsA("Animation")) then
			continue
		end

		table.insert(descendants, descendant)

		if descendant:IsA("Animation") and descendant.AnimationId ~= "" then
			v4[descendant.AnimationId] = true
		end
	end

	local success, result = pcall(function()
		ContentProvider:PreloadAsync(descendants)
	end)

	if not success then
		warn("[EffectLifetime] Background preload failed: " .. tostring(result))
	end

	for k in v4 do
		EffectLifetime.getEvents(k)
	end
end

return EffectLifetime