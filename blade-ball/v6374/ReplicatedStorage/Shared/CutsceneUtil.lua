local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local v = require3(ReplicatedStorage2.Common.Utils)

local function preloadAnimation(animator, animation)
	if animation.AnimationId == "rbxassetid://0" or animation.AnimationId == "rbxassetid://" or animation.AnimationId == "" then
		return animator:LoadAnimation(animation)
	end

	local track = animator:LoadAnimation(animation)
	track:Play(0, 0, 0)
	local thread = coroutine.running()
	local flag = true
	local thread2 = task.delay(7, v.Thread.SafeResume, thread)
	local thread3 = task.defer(function()
		while flag do
			if track.Length > 0 then
				v.Thread.SafeResume(thread)
				break
			else
				task.wait()
			end
		end
	end)
	coroutine.yield()
	flag = false
	v.Thread.SafeCancel(thread3)
	v.Thread.SafeCancel(thread2)
	track:Stop(0)
	track.TimePosition = 0
	return track
end

local function preloadSound(object)
	if object.SoundId == "rbxassetid://0" or object.SoundId == "rbxassetid://" or object.SoundId == "" then
		return object
	end

	local volume = object.Volume
	object.Volume = 0
	object:Play()
	local thread = coroutine.running()
	local flag = true
	local thread2 = task.delay(7, v.Thread.SafeResume, thread)
	local thread3 = task.defer(function()
		while flag do
			if object.TimeLength > 0 or object.IsLoaded then
				v.Thread.SafeResume(thread)
				break
			else
				task.wait()
			end
		end
	end)
	coroutine.yield()
	flag = false
	v.Thread.SafeCancel(thread3)
	v.Thread.SafeCancel(thread2)
	object:Stop()
	object.Volume = volume
	return object
end

local CutsceneUtil = {}
CutsceneUtil.preloadAnimation = preloadAnimation

function CutsceneUtil.preloadAnimations(items)
	local count = 0
	local v2 = {}
	local count2 = 0

	for _ in items do
		count += 1
	end

	local thread = coroutine.running()

	for k, item in items do
		local v3 = k
		local v4 = item
		task.defer(function()
			v2[v3] = preloadAnimation(v3, v4)
			count2 += 1
			v.Thread.SafeResume(thread)
		end)
	end

	while count2 ~= count do
		coroutine.yield()
	end

	return v2
end

CutsceneUtil.preloadSound = preloadSound

function CutsceneUtil.preloadSounds(items)
	local count = 0
	local v2 = {}
	local count2 = 0

	for _ in items do
		count += 1
	end

	local thread = coroutine.running()

	for k, item in items do
		local v3 = k
		local v4 = item
		task.defer(function()
			v2[v3] = preloadSound(v4)
			count2 += 1
			v.Thread.SafeResume(thread)
		end)
	end

	while count2 ~= count do
		coroutine.yield()
	end

	return v2
end

function CutsceneUtil.cloneSound(instance, object)
	local clone = instance:Clone()
	clone.Name = HttpService:GenerateGUID(false)
	clone.Ended:Once(function()
		clone:Destroy()
	end)

	if object then
		object:Add(clone)
	end

	clone.Parent = SoundService
	return clone
end

function CutsceneUtil.playAndWaitAnimations(items)
	local count = 0
	local count2 = 0

	for _ in items do
		count += 1
	end

	local thread = coroutine.running()

	for _, item in items do
		local v2 = item
		task.defer(function()
			v2:Play()
			v2.Stopped:Wait()
			count2 += 1
			v.Thread.SafeResume(thread)
		end)
	end

	while count2 ~= count do
		coroutine.yield()
	end
end

return CutsceneUtil