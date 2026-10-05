local VolkarisLairAnimation = {}
local v = {}
local SoundService = game:GetService("SoundService")
local random = Random.new()

local function StopSleepSounds(state)
	state.SleepSoundsActive = false

	if state.SleepSoundTask then
		task.cancel(state.SleepSoundTask)
		state.SleepSoundTask = nil
	end

	for _, v2 in state.SleepSounds or {} do
		v2:Stop()
	end
end

local function StartSleepSounds(instance, state)
	StopSleepSounds(state)

	if not state.SleepSounds then
		state.SleepSounds = {}
		local animals = SoundService:FindFirstChild("Animals")
		local volkaris = animals and animals:FindFirstChild("Volkaris")
		local sleep = volkaris and volkaris:FindFirstChild("Sleep")
		local dragon = instance:FindFirstChild("Dragon")

		if not (dragon and dragon:IsA("BasePart") and dragon) then
			dragon = instance.PrimaryPart
		end

		if sleep and dragon then
			for _, sound in sleep:GetChildren() do
				if not sound:IsA("Sound") then
					continue
				end

				local clone = sound:Clone()
				clone.Name = "VolkarisSleep_" .. #state.SleepSounds + 1
				clone.Looped = false
				clone.PlayOnRemove = false
				clone:Stop()
				clone.Parent = dragon
				table.insert(state.SleepSounds, clone)
			end
		end
	end

	if #state.SleepSounds == 0 then
		return
	end

	state.SleepSoundsActive = true
	local Schedule

	Schedule = function()
		state.SleepSoundTask = task.delay(random:NextNumber(3, 7), function()
			state.SleepSoundTask = nil

			if not state.SleepSoundsActive or v[instance] ~= state or not instance:IsDescendantOf(workspace) then
				return
			end

			local guardianState = instance:GetAttribute("GuardianState")

			if (guardianState == nil or guardianState == "Sleeping") and state.Tracks.Sleeping.IsPlaying then
				for _, sleepSound in state.SleepSounds do
					sleepSound:Stop()
				end

				local sleepSound = state.SleepSounds[random:NextInteger(1, #state.SleepSounds)]
				sleepSound.TimePosition = 0
				sleepSound:Play()
			end

			Schedule()
		end)
	end

	state.SleepSoundTask = task.delay(random:NextNumber(3, 7), function()
		state.SleepSoundTask = nil

		if not state.SleepSoundsActive or v[instance] ~= state or not instance:IsDescendantOf(workspace) then
			return
		end

		local guardianState = instance:GetAttribute("GuardianState")

		if (guardianState == nil or guardianState == "Sleeping") and state.Tracks.Sleeping.IsPlaying then
			for _, sleepSound in state.SleepSounds do
				sleepSound:Stop()
			end

			local sleepSound = state.SleepSounds[random:NextInteger(1, #state.SleepSounds)]
			sleepSound.TimePosition = 0
			sleepSound:Play()
		end

		Schedule()
	end)
end

function VolkarisLairAnimation.Remove(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	v[p] = nil
	StopSleepSounds(v2)

	for _, v3 in v2.SleepSounds or {} do
		v3:Destroy()
	end

	v2.Version += 1

	for _, track in pairs(v2.Tracks) do
		track:Stop(0)
		track:Destroy()
	end
end

function VolkarisLairAnimation.Prepare(instance)
	local v2 = v[instance]

	if v2 then
		return v2
	end

	local animator = assert(
		assert(instance:FindFirstChildOfClass("AnimationController"), "Volkaris controller missing"):FindFirstChildOfClass("Animator"),
		"Volkaris animator missing"
	)
	local v3 = assert(instance:FindFirstChild("Animations"), "Volkaris animations missing")
	local v4 = {
		Tracks = {},
		Version = 0
	}
	local success, result = pcall(function()
		for _, childName in {
			"Sleeping",
			"WakeUp",
			"Idle",
			"Walk",
			"Fireball"
		} do
			local track = animator:LoadAnimation(assert(v3:FindFirstChild(childName), childName .. " missing"))
			local v5 = childName == "WakeUp" or childName == "Fireball"
			track.Looped = not v5
			local action

			if v5 then
				action = Enum.AnimationPriority.Action
			elseif childName == "Walk" then
				action = Enum.AnimationPriority.Movement
			else
				action = Enum.AnimationPriority.Idle
			end

			track.Priority = action
			v4.Tracks[childName] = track
		end
	end)

	if not success then
		for _, track in pairs(v4.Tracks) do
			track:Destroy()
		end

		error(result)
	end

	v[instance] = v4
	v4.Tracks.Sleeping:Play(0)
	StartSleepSounds(instance, v4)
	return v4
end

function VolkarisLairAnimation.Sleep(p)
	local v2 = VolkarisLairAnimation.Prepare(p)
	v2.Version += 1
	v2.Tracks.WakeUp:Stop(0)
	v2.Tracks.Idle:Stop(0)
	v2.Tracks.Walk:Stop(0.2)
	v2.Tracks.Fireball:Stop(0.1)
	v2.Tracks.Sleeping:Play(0.1)
	StartSleepSounds(p, v2)
	return v2
end

function VolkarisLairAnimation.Fireball(p)
	local v2 = VolkarisLairAnimation.Prepare(p)
	v2.Tracks.Fireball:Play(0.1)
	return v2
end

function VolkarisLairAnimation.Fly(p)
	local v2 = VolkarisLairAnimation.Prepare(p)
	StopSleepSounds(v2)
	v2.Version += 1
	v2.Tracks.Sleeping:Stop(0.2)
	v2.Tracks.Idle:Stop(0.2)

	if not v2.Tracks.Walk.IsPlaying then
		v2.Tracks.Walk:Play(0.2)
	end

	return v2
end

function VolkarisLairAnimation.Wake(instance)
	local v2 = VolkarisLairAnimation.Prepare(instance)
	assert(v2.Tracks.WakeUp.Length > 0, "WakeUp is not loaded")
	StopSleepSounds(v2)
	v2.Version += 1
	local version = v2.Version
	v2.Tracks.Sleeping:Stop(0.1)
	v2.Tracks.Walk:Stop(0.1)
	v2.Tracks.WakeUp:Play(0.1)
	task.delay(v2.Tracks.WakeUp.Length, function()
		if v[instance] == v2 and v2.Version == version and instance:IsDescendantOf(workspace) then
			v2.Tracks.Idle:Play(0.15)
		end
	end)
end

return VolkarisLairAnimation