local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Shrinking = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.Minigames.Shrinking)
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local maid = nil
local v = nil
local track = nil
local clone = nil

local function teardown()
	local v2 = maid
	local v3 = v
	local v4 = track
	local v5 = clone
	maid = nil
	v = nil
	track = nil
	clone = nil

	if v4 then
		v4:Stop(0.3)
	end

	if v5 then
		local tween = TweenService:Create(v5, TweenInfo.new(0.3), {
			Volume = 0
		})
		tween:Play()
		task.spawn(function()
			tween.Completed:Wait()
			v5:Destroy()
		end)
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

local Pushups = {}

function Pushups.Do(p, instance, _, _)
	teardown()
	maid = faye.new()
	maid:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still"))
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay"))
	maid:Add(Utility.AddValue(getvaluesfolder, "NR"))
	track = instance.Humanoid.Animator:LoadAnimation(script.Pushups)
	track:Play()
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart then
		clone = script.Parent.PS2trainingPUSHUPSloop:Clone()
		clone.Looped = true
		clone.Parent = humanoidRootPart
		clone:Play()
	end

	local flag = false
	v = Shrinking(p.PlayerGui:WaitForChild("Misc"), {
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

function Pushups:Stop(_, _)
	teardown()
end

return Pushups