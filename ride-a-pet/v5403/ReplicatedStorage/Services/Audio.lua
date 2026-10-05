local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Audio = {}

function Audio.PlayMusic(_, object)
	local volume = object.Volume
	object.Volume = 0
	local tween = TweenService:Create(object, TweenInfo.new(1), {
		Volume = volume
	})
	object:Play()
	tween:Play()
	task.delay(1.1, function()
		object.Volume = volume
	end)
end

function Audio.StopMusic(_, object)
	local volume = object.Volume
	TweenService:Create(object, TweenInfo.new(1), {
		Volume = 0
	}):Play()
	task.delay(1.1, function()
		object:Stop()
		object.Volume = volume
	end)
end

function Audio.PlayOnce(_, instance, parent, options)
	local v = options or {}
	local playbackSpeed = v.PlaybackSpeed
	local variation = v.Variation
	local timePosition = v.TimePosition
	local volume = v.Volume
	local clone = instance:Clone()

	if volume then
		clone.Volume = volume
	end

	clone.Parent = parent

	if playbackSpeed then
		clone.PlaybackSpeed = playbackSpeed
	end

	if timePosition then
		clone.TimePosition = timePosition
	end

	if variation then
		local v2 = clone:FindFirstChildOfClass("PitchShiftSoundEffect")
		local v3 = not v2 and 1 or v2.Octave or 1

		if not v2 then
			v2 = Instance.new("PitchShiftSoundEffect")
			v2.Parent = clone
		end

		v2.Octave = math.random((v3 - variation) * 10, (v3 + variation) * 10) / 10
	end

	clone:Play()

	if clone.Looped == false then
		Debris:AddItem(clone, clone.TimeLength + 5)
	end

	return clone
end

function Audio.PlayAtPosition(_, instance, position: Vector3)
	local part = Instance.new("Part")
	part.Transparency = 1
	part.CanQuery = false
	part.Anchored = true
	part.Massless = true
	part.Position = position
	part.CanCollide = false
	part.Parent = workspace
	local clone = instance:Clone()
	clone.Parent = part
	clone:Play()

	if clone.Looped == false then
		Debris:AddItem(part, clone.TimeLength)
	end

	return clone
end

function Audio.PlayOn(_, instance, parent, options)
	if not (instance and parent and parent.Parent) then
		return nil
	end

	local v = options or {}
	local clone = instance:Clone()
	clone.RollOffMode = Enum.RollOffMode.InverseTapered
	clone.RollOffMinDistance = v.MinDistance or 12
	clone.RollOffMaxDistance = v.MaxDistance or 140

	if v.PlaybackSpeed then
		clone.PlaybackSpeed = v.PlaybackSpeed
	end

	clone.Parent = parent
	clone:Play()

	if clone.Looped == false then
		local lifetime = v.Lifetime or not (clone.TimeLength > 0) and 6 or clone.TimeLength / math.max(
			clone.PlaybackSpeed,
			0.1
		) + 0.5 or 6
		Debris:AddItem(clone, lifetime)
	end

	return clone
end

return Audio