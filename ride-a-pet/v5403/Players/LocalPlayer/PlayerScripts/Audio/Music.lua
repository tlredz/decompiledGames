game.SoundService:WaitForChild("SFX")
local music = game.SoundService:WaitForChild("Music")
local adventure = music:WaitForChild("Adventure")

local function ShuffleSongs(children)
	local clone = table.clone(children)

	for i = #clone, 2, -1 do
		local v = math.random(1, i)
		local v2 = clone[v]
		local v3 = clone[i]
		clone[i] = v2
		clone[v] = v3
	end

	return clone
end

local children = adventure:GetChildren()

if #children == 0 then
	warn("Music: no songs found in", adventure:GetFullName())
	return
end

local v = nil
local flag = true
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Audio"))
local musicOverride = script.Parent:FindFirstChild("MusicOverride") or Instance.new("BindableEvent")
musicOverride.Name = "MusicOverride"
musicOverride.Parent = script.Parent
local v2 = nil
local v3 = nil
local TweenService = game:GetService("TweenService")
local count = 0
local volume = nil
local cutscenePaused = music:GetAttribute("CutscenePaused") == true
local v5 = {}

local function PlayMusic(object, p)
	if cutscenePaused then
		v5[object] = p
	elseif p then
		object:Resume()
	else
		object:Play()
	end
end

music:GetAttributeChangedSignal("CutscenePaused"):Connect(function()
	cutscenePaused = music:GetAttribute("CutscenePaused") == true

	if cutscenePaused then
		for _, v6 in { v, v2 } do
			if not (v6 and v6.IsPlaying) then
				continue
			end

			v5[v6] = true
			v6:Pause()
		end
	else
		local v6 = v2 or v

		if v6 and v5[v6] ~= nil and v6.Parent then
			local v7 = v5[v6]

			if cutscenePaused then
				v5[v6] = v7
			elseif v7 then
				v6:Resume()
			else
				v6:Play()
			end
		end

		table.clear(v5)
	end
end)

local function FadeOverrideIn(object)
	count += 1
	volume = volume or object.Volume

	if not object.IsPlaying then
		object.Volume = 0

		if cutscenePaused then
			v5[object] = false
		else
			object:Play()
		end
	end

	TweenService:Create(object, TweenInfo.new(1), {
		Volume = volume
	}):Play()
end

local function FadeOverrideOut(object)
	count += 1
	local v6 = count
	TweenService:Create(object, TweenInfo.new(1), {
		Volume = 0
	}):Play()
	task.delay(1.1, function()
		if count ~= v6 then
			return
		end

		object:Stop()

		if volume then
			object.Volume = volume
		end
	end)
end

musicOverride.Event:Connect(function(p)
	if p then
		if v2 and v2 ~= p then
			FadeOverrideOut(v2)
			volume = nil
		end

		if not v3 and v and (v.IsPlaying or v5[v] ~= nil) then
			v3 = v
			v3:Pause()
		end

		v2 = p
		p.Looped = true
		FadeOverrideIn(p)
	else
		if v2 then
			FadeOverrideOut(v2)
			v2 = nil
		end

		if v3 then
			local v6 = v3

			if cutscenePaused then
				v5[v6] = true
			else
				v6:Resume()
			end

			v3 = nil
		end
	end
end)

local function PlayNextCycle()
	local shuffleSongs = ShuffleSongs(children)

	if flag then
		local v7 = nil

		for k, v9 in shuffleSongs do
			if v9.Name ~= "Custom1" then
				continue
			end

			v7 = k
			break
		end

		if v7 then
			local v9 = shuffleSongs[v7]
			local v10 = shuffleSongs[1]
			shuffleSongs[1] = v9
			shuffleSongs[v7] = v10
		else
			warn(string.format("Music: PRIORITY_START %q is not in %s", "Custom1", adventure:GetFullName()))
		end
	elseif v and #shuffleSongs > 1 and shuffleSongs[1] == v then
		local v7 = #shuffleSongs
		local v8 = shuffleSongs[#shuffleSongs]
		local v9 = shuffleSongs[1]
		shuffleSongs[1] = v8
		shuffleSongs[v7] = v9
	end

	flag = false

	for _, v7 in shuffleSongs do
		v = v7

		if cutscenePaused then
			v5[v7] = false
		else
			v7:Play()
		end

		v7.Ended:Wait()
	end
end

task.spawn(function()
	while true do
		PlayNextCycle()
	end
end)