local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local v = { "rbxassetid://86455916528830", "rbxassetid://77410998873674" }
local v2 = { "rbxassetid://82716325456331", "rbxassetid://107195183557466" }
local v3 = { "rbxassetid://127982647406101" }
local v4 = { "rbxassetid://102634183778416", "rbxassetid://88051888873164" }
local v5 = { "rbxassetid://84754768305647", "rbxassetid://76749618491578" }
local v6 = nil

local function pickSound(list)
	if #list == 0 then
		return nil
	end

	if #list == 1 then
		return list[1]
	end

	local v7

	repeat
		v7 = list[math.random(1, #list)]
	until v7 ~= v6

	v6 = v7
	return v7
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pitch()
	return 0.94 + math.random() * 0.12
end

local v7 = nil

local function stopBark(instance)
	if not (instance and instance.Parent) then
		return
	end

	local tween = TweenService:Create(instance, TweenInfo.new(0.05), {
		Volume = 0
	})
	tween.Completed:Once(function()
		instance:Destroy()
	end)
	tween:Play()
end

return function(data)
	local v8, v9, volume

	if data.Alert then
		v8 = v4
		v9 = v5
		volume = 0.6
	elseif data.Angry then
		v8 = v2
		v9 = v3
		volume = 0.85
	else
		v8 = v
		v9 = v3
		volume = 0.6
	end

	if data.Long and #v9 > 0 then
		v8 = v9
	end

	local soundId = pickSound(v8)

	if not soundId then
		return
	end

	stopBark(v7)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume
	sound.PlaybackSpeed = pitch()
	sound.Parent = SoundService
	sound:Play()
	v7 = sound
	sound.Ended:Once(function()
		if v7 == sound then
			v7 = nil
		end

		sound:Destroy()
	end)
	Debris:AddItem(sound, 5)
end