local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local BossEventFlags = require(ReplicatedStorage.Shared.Flags.BossEventFlags)
local bossEventSounds = ReplicatedStorage.Assets.Sounds:WaitForChild("BossEventSounds")
local soundsByChildName = {}
local v = nil
local v2 = {
	IntervalSeconds = 1800,
	BossName = "Abyss Overlord",
	CurrentPeriod = function()
		return Workspace:GetServerTimeNow() // 1800
	end,
	PeriodStart = function(p: number)
		return p * 1800
	end,
	ClampDuration = function(value: number)
		return (math.clamp(value, 1, 1740))
	end,
	HealthMultiplier = function(p: number)
		local v3 = math.max(math.floor(p), 1)
		local v4 = -1e999
		local v5 = 1e999
		local v6 = nil
		local v7 = nil

		for k, v8 in BossEventFlags.HealthScalesWithPlayers:Get() do
			local v9 = tonumber(k)

			if v9 == nil then
				continue
			end

			if v9 <= v3 and v4 < v9 then
				v6 = v8
				v4 = v9
			end

			if not (v9 < v5) then
				continue
			end

			v7 = v8
			v5 = v9
		end

		return v6 or v7 or 1
	end
}

local function soundNamed(childName: string)
	local v3 = soundsByChildName[childName]

	if v3 ~= nil then
		return v3
	end

	local sound = bossEventSounds:FindFirstChild(childName)
	local v4

	if sound == nil then
		v4 = false
	else
		v4 = sound:IsA("Sound")
	end

	assert(v4, (`BossEventSounds needs the Sound {childName}`))
	soundsByChildName[childName] = sound
	return sound
end

function v2.PlaySound(childName: string, p, p2)
	local sound = soundsByChildName[childName]

	if sound == nil then
		sound = bossEventSounds:FindFirstChild(childName)
		local v3

		if sound == nil then
			v3 = false
		else
			v3 = sound:IsA("Sound")
		end

		assert(v3, (`BossEventSounds needs the Sound {childName}`))
		soundsByChildName[childName] = sound
	end

	local v3 = p2 == nil and {} or table.clone(p2)
	v3.MaxDistance = v3.MaxDistance or sound.RollOffMaxDistance
	v3.SoundGroup = v3.SoundGroup or "SFX"
	local v4 = v

	if not RunService:IsServer() or v4 == nil or v3.Recipient ~= nil then
		return Audio.Play(sound, p, v3)
	end

	for _, recipient in v4() do
		local clone = table.clone(v3)
		clone.Recipient = recipient
		Audio.Play(sound, p, clone)
	end

	return nil
end

function v2.SetAudience(callback)
	v = callback
end

function v2.PlaySoundEverywhere(p: string, p2)
	return v2.PlaySound(p, bossEventSounds, p2)
end

function v2.CurrentWindow(p: number)
	local clampDuration = v2.ClampDuration(p)
	local serverTimeNow = Workspace:GetServerTimeNow()
	local periodStart = v2.PeriodStart(serverTimeNow // 1800)

	if serverTimeNow - periodStart < clampDuration then
		return {
			Open = true,
			OpensAt = periodStart,
			ClosesAt = periodStart + clampDuration
		}
	end

	local opensAt = periodStart + 1800
	return {
		Open = false,
		OpensAt = opensAt,
		ClosesAt = opensAt + clampDuration
	}
end

function v2.SecondsUntilNextOpen()
	return 1800 - Workspace:GetServerTimeNow() % 1800
end

return table.freeze(v2)