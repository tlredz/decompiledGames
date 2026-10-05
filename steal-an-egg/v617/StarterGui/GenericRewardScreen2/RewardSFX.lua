local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local v = {
	Reward = "129831855124668"
}

local function normalise(value)
	return (value:gsub("%W", ""):lower():gsub("sfx$", ""))
end

local v2 = {}
local v4 = {
	Reward = {
		Volume = 0.65,
		Throttle = 0.3,
		NoRetrigger = true
	}
}
local RewardSFX = {}

for k in pairs(v) do
	v2[k:gsub("%W", ""):lower():gsub("sfx$", "")] = k
end

for k, v5 in pairs({
	keyreward = "Reward",
	rewardsfx = "Reward"
}) do
	v2[k] = v5
end

local SFX = script.Parent and script.Parent:FindFirstChild("SFX")
local v5 = SoundService:FindFirstChild("RewardScreen")

if not v5 then
	v5 = Instance.new("SoundGroup")
	v5.Name = "RewardScreen"
	v5.Volume = 1
	v5.Parent = SoundService
end

local function resolveSource(name)
	if SFX then
		for _, sound in ipairs(SFX:GetChildren()) do
			if sound:IsA("Sound") and v2[sound.Name:gsub("%W", ""):lower():gsub("sfx$", "")] == name then
				return sound.SoundId
			end
		end
	end

	local v6 = v[name]

	if not v6 or v6 == "" then
		return nil
	end

	if tonumber(v6) then
		return "rbxassetid://" .. v6
	end

	return v6
end

local function buildSound(name)
	local source = resolveSource(name)

	if not source or source == "" then
		return nil
	end

	local v6 = v4[name] or {}
	local child = v5:FindFirstChild(name)

	if child then
		child:Destroy()
	end

	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = source
	sound.Volume = v6.Volume or 0.5
	sound.PlaybackSpeed = v6.PlaybackSpeed or 1
	sound.SoundGroup = v5
	sound.Parent = v5
	return sound
end

local v6 = {}
local nows = {}

for k in pairs(v) do
	v6[k] = buildSound(k)
end

function RewardSFX.play(p)
	local v7 = v6[p]

	if not v7 then
		return
	end

	local v8 = v4[p] or {}

	if v8.NoRetrigger and v7.IsPlaying then
		return
	end

	local throttle = v8.Throttle or 0.05
	local now = os.clock()

	if nows[p] and now - nows[p] < throttle then
		return
	end

	nows[p] = now
	v7.TimePosition = 0
	v7:Play()
end

function RewardSFX.stop(p)
	local v7 = v6[p]

	if v7 then
		v7:Stop()
	end
end

function RewardSFX.setVolume(value)
	v5.Volume = math.clamp(value, 0, 1)
end

function RewardSFX.refresh()
	SFX = script.Parent and script.Parent:FindFirstChild("SFX")

	for k, v7 in pairs(v6) do
		if v7 then
			v7:Destroy()
		end

		v6[k] = nil
	end

	for k in pairs(v) do
		v6[k] = buildSound(k)
	end
end

function RewardSFX.preload()
	task.spawn(function()
		local v7 = {}

		for _, v8 in pairs(v6) do
			if v8 then
				v7[#v7 + 1] = v8
			end
		end

		if #v7 > 0 then
			pcall(function()
				ContentProvider:PreloadAsync(v7)
			end)
		end
	end)
end

return RewardSFX