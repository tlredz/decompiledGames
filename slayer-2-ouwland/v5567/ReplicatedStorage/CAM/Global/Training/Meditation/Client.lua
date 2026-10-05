local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local SlideBubbles = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.Minigames.SlideBubbles)
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local maid = nil
local v = nil
local track = nil
local humanoidRootPart = nil

local function playMeditateSound(childName: string, script2)
	local child = script.Parent:FindFirstChild(childName)

	if child == nil then
		return
	end

	local clone = child:Clone()

	if not script2 or script2.Parent == nil or not script2 then
		script2 = script
	end

	clone.Parent = script2
	clone:Play()
	clone.Ended:Once(function()
		clone:Destroy()
	end)
end

local function teardown()
	local v2 = maid
	local v3 = v
	local v4 = track
	local v5 = humanoidRootPart
	maid = nil
	v = nil
	track = nil
	humanoidRootPart = nil

	if v2 then
		playMeditateSound("PS2trainingPUSHUPSandMEDITATEstop", v5)
	end

	if v4 then
		v4:Stop(0.3)
	end

	if v3 then
		v3()
	end

	if v2 then
		task.spawn(function()
			task.wait(0.5)
			v2:Destroy()
		end)
	end
end

local Meditation = {}

function Meditation.Do(p, instance, _, _)
	teardown()
	maid = faye.new()
	maid:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still"))
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay"))
	maid:Add(Utility.AddValue(getvaluesfolder, "NR"))
	track = instance.Humanoid.Animator:LoadAnimation(script.Meditation)
	track:Play()
	humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
	playMeditateSound("PS2trainingPUSHUPSandMEDITATEstart", humanoidRootPart)
	local flag = false
	v = SlideBubbles(p.PlayerGui:WaitForChild("Misc"), {
		Thread = maid,
		Stop = function(self: boolean)
			if flag then
				return
			end

			flag = true
			SignalEvent.ToServer("training_signaler", "Stop", self == true)
		end
	})
end

function Meditation:Stop(_, _)
	teardown()
end

return Meditation