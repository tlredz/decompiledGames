local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local FootstepMixer = {}
local footsteps = {}
setmetatable(footsteps, {
	__mode = "k"
})
local activeCount = 0
local v3 = {}
local v4 = {
	PebbleMonster = 0.6,
	DyleMonster = 0.7,
	GourdyMonster = 0.5,
	BobetteMonster = 0.8,
	SproutMonster = 0.9,
	DandyMonster = 1
}
local v5 = {
	globalVolumeMultiplier = 1.2,
	minVolumeMultiplier = 0.3,
	maxActiveForScaling = 8,
	distanceWeight = 0.3,
	cleanupInterval = 0.5,
	maxFootstepDuration = 2
}

local function calculateVolumeMultiplier()
	local v6 = math.min(activeCount, 8)

	if v6 <= 1 then
		return 1
	end

	return (math.max(1 / math.sqrt(v6), 0.3))
end

local function getDistancePriority(p)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return 1
	end

	local character = localPlayer.Character

	if not character then
		return 1
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return 1 - 0.3 * (1 - math.clamp(1 - (p - humanoidRootPart.Position).Magnitude / 100, 0.2, 1))
	end

	return 1
end

function FootstepMixer:RegisterFootstep(monster, position)
	if not (self and self:IsA("Sound")) then
		return
	end

	if footsteps[self] then
		return footsteps[self].finalVolume
	end

	local now = tick()

	if v3[monster] and now - v3[monster] < 0.001 then
		return nil
	end

	v3[monster] = now
	local volume = self.Volume
	local v6 = v4[monster] or 1
	local v7

	if position then
		local localPlayer = Players.LocalPlayer
		local v8

		if localPlayer then
			local character = localPlayer.Character

			if character then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local v9 = math.clamp(1 - (position - humanoidRootPart.Position).Magnitude / 100, 0.2, 1)
					v8 = 1 - v5.distanceWeight * (1 - v9)
				else
					v8 = 1
				end
			else
				v8 = 1
			end
		else
			v8 = 1
		end

		v7 = v8 or 1
	else
		v7 = 1
	end

	activeCount += 1
	local v8 = math.min(activeCount, v5.maxActiveForScaling)
	local v9 = v8 <= 1 and 1 or math.max(1 / math.sqrt(v8), v5.minVolumeMultiplier)
	local v10 = volume * 1.2 * v9 * v6 * v7
	footsteps[self] = {
		monster = monster,
		startTime = now,
		position = position,
		baseVolume = volume,
		finalVolume = v10
	}
	self.Volume = v10
	self.Ended:Once(function()
		FootstepMixer.UnregisterFootstep(self)
	end)
	return v10
end

function FootstepMixer.UnregisterFootstep(p)
	if footsteps[p] then
		footsteps[p] = nil
		activeCount = math.max(0, activeCount - 1)
	end
end

function FootstepMixer.UpdateVolumes()
	local v6 = math.min(activeCount, v5.maxActiveForScaling)
	local v7 = v6 <= 1 and 1 or math.max(1 / math.sqrt(v6), v5.minVolumeMultiplier)

	for k, v8 in pairs(footsteps) do
		if not (k and k.Parent and k.IsPlaying) then
			continue
		end

		local v9 = v4[v8.monster] or 1
		local v10

		if v8.position then
			local position = v8.position
			local localPlayer = Players.LocalPlayer
			local v11

			if localPlayer then
				local character = localPlayer.Character

				if character then
					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						local v12 = math.clamp(1 - (position - humanoidRootPart.Position).Magnitude / 100, 0.2, 1)
						v11 = 1 - v5.distanceWeight * (1 - v12)
					else
						v11 = 1
					end
				else
					v11 = 1
				end
			else
				v11 = 1
			end

			v10 = v11 or 1
		else
			v10 = 1
		end

		local v11 = v8.baseVolume * 1.2 * v7 * v9 * v10
		k.Volume = v11
		v8.finalVolume = v11
	end
end

local function cleanupStaleFootsteps()
	local now = tick()
	local v6 = {}

	for k, v7 in pairs(footsteps) do
		if not (not k or typeof(k) ~= "Instance" or not k.Parent or not k.IsPlaying or now - v7.startTime > 2) then
			continue
		end

		table.insert(v6, k)
	end

	for _, v7 in ipairs(v6) do
		footsteps[v7] = nil
		activeCount = math.max(0, activeCount - 1)
	end

	for k, v7 in pairs(v3) do
		if now - v7 > 60 then
			v3[k] = nil
		end
	end
end

function FootstepMixer.GetStats()
	local v6 = {
		activeCount = activeCount,
		volumeMultiplier = 0,
		footsteps = 0
	}
	local v7 = math.min(activeCount, v5.maxActiveForScaling)
	v6.volumeMultiplier = v7 <= 1 and 1 or math.max(1 / math.sqrt(v7), v5.minVolumeMultiplier)
	v6.footsteps = footsteps
	return v6
end

function FootstepMixer.GetMonsterMultiplier(p)
	return v4[p] or 1
end

function FootstepMixer.SetMonsterMultiplier(p, value)
	v4[p] = math.clamp(value, 0, 2)
end

local heartbeatConnection = nil
local now = 0

function FootstepMixer.Start()
	if heartbeatConnection then
		return
	end

	now = tick()
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local now2 = tick()

		if now2 - now >= 0.5 then
			now = now2
			cleanupStaleFootsteps()
		end
	end)
end

function FootstepMixer.Stop()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

FootstepMixer.Start()
return FootstepMixer