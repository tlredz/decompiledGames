local Debris = game:GetService("Debris")
local AnimationIDs = require(script.Parent.AnimationIDs)
local MaskedManColorManiaConfig = require(script.Parent.MaskedManColorManiaConfig)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local thread = nil
local BossAnimationClient = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function loadTrack(animator, animationId: string)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = animator:LoadAnimation(animation)
	track.Looped = true
	return track
end

local function applyState(bossAnimState)
	if bossAnimState == "Walk" then
		if v3 then
			v3:Stop(0.2)
		end

		if v2 and not v2.IsPlaying then
			v2:Play(0.2)
		end
	else
		if v2 then
			v2:Stop(0.2)
		end

		if v3 and not v3.IsPlaying then
			v3:Play(0.2)
		end
	end
end

function BossAnimationClient.start(object, p: string, _)
	BossAnimationClient.stop()
	v = object
	thread = task.spawn(function()
		local humanoid = nil
		local v7 = nil

		while v == object do
			local adminAbuse = workspace:FindFirstChild("AdminAbuse")
			local map = adminAbuse and adminAbuse:FindFirstChild("Map")
			local child = map and map:FindFirstChild(p .. "_Live")
			local scriptables = child and child:FindFirstChild("Scriptables")
			local bossRig = scriptables and scriptables:FindFirstChild("BossRig")
			humanoid = bossRig and bossRig:FindFirstChildOfClass("Humanoid")

			if humanoid then
				v7 = bossRig
				break
			else
				task.wait(0.5)
			end
		end

		if not humanoid or v ~= object then
			return
		end

		local v8 = humanoid:FindFirstChildOfClass("Animator")

		if not v8 then
			v8 = Instance.new("Animator")
			v8.Parent = humanoid
		end

		v5 = v8
		v6 = v7
		v2 = loadTrack(v8, AnimationIDs.WalkAnimId)
		v3 = loadTrack(v8, AnimationIDs.IdleAnimId)
		applyState(object:get("BossAnimState"))
		object:onChange("BossAnimState", applyState)
		thread = nil
	end)
end

local function waitSfxEnded(sound, laughWaitCapSec: number)
	local v7 = false
	local endedConnection = sound.Ended:Connect(function()
		v7 = true
	end)
	local total = 0

	while not v7 and total < laughWaitCapSec do
		task.wait(0.1)
		total += 0.1
	end

	endedConnection:Disconnect()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveSoundParent()
	local v7 = v6
	return v7.PrimaryPart or v7:FindFirstChild("HumanoidRootPart") or v7
end

local function playSfx(soundId: string, volume: number, p: number)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume
	sound.Parent = resolveSoundParent()
	sound:Play()
	Debris:AddItem(sound, p)
	return sound
end

function BossAnimationClient.playRoar()
	if not (v5 and v6) or v4 and v4.IsPlaying then
		return
	end

	local track = loadTrack(v5, AnimationIDs.Roar) -- equivalent call inferred; original call site unknown
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = false
	track:Play(0.3)
	v4 = track
	local roar2 = MaskedManColorManiaConfig.TauntSFX.Roar
	local sound = Instance.new("Sound")
	sound.SoundId = roar2
	sound.Volume = 2.2
	sound.Parent = resolveSoundParent()
	sound:Play()
	Debris:AddItem(sound, 8)
	local idleTaunts = MaskedManColorManiaConfig.IdleTaunts
	task.spawn(function()
		task.wait(idleTaunts.roarWaitSec)
		sound:Stop()

		if v4 == track then
			track:Stop(idleTaunts.roarStopSec)
			v4 = nil
		end
	end)
end

function BossAnimationClient.playLaugh()
	if not (v5 and v6) or v4 and v4.IsPlaying then
		return
	end

	local track = loadTrack(v5, AnimationIDs.Laugh) -- equivalent call inferred; original call site unknown
	track.Priority = Enum.AnimationPriority.Action
	track:Play(0.3)
	v4 = track
	local laugh2 = MaskedManColorManiaConfig.TauntSFX.Laugh
	local sound = Instance.new("Sound")
	sound.SoundId = laugh2
	sound.Volume = 1.5
	sound.Parent = resolveSoundParent()
	sound:Play()
	Debris:AddItem(sound, 20)
	local idleTaunts = MaskedManColorManiaConfig.IdleTaunts
	task.spawn(function()
		waitSfxEnded(sound, idleTaunts.laughWaitCapSec)
		sound:Stop()

		if v4 == track then
			track:Stop(idleTaunts.laughStopSec)
			v4 = nil
		end
	end)
end

function BossAnimationClient.stop()
	if thread then
		pcall(task.cancel, thread)
		thread = nil
	end

	if v then
		pcall(function()
			v:off("BossAnimState")
		end)
	end

	if v2 then
		v2:Stop(0)
		v2 = nil
	end

	if v3 then
		v3:Stop(0)
		v3 = nil
	end

	if v4 then
		v4:Stop(0)
		v4 = nil
	end

	v5 = nil
	v6 = nil
	v = nil
end

return BossAnimationClient