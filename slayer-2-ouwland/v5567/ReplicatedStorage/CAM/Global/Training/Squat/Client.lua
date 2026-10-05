local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local BarKeepup = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.Minigames.BarKeepup)
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local maid = nil
local v = nil
local track = nil
local clone = nil
local humanoidRootPart = nil

local function playSquatSound(childName: string, script2)
	local child = script.Parent:FindFirstChild(childName)

	if child == nil then
		return
	end

	local clone2 = child:Clone()

	if not script2 or script2.Parent == nil or not script2 then
		script2 = script
	end

	clone2.Parent = script2
	clone2:Play()
	clone2.Ended:Once(function()
		clone2:Destroy()
	end)
end

local function teardown()
	local v2 = maid
	local v3 = v
	local v4 = track
	local v5 = clone
	local v6 = humanoidRootPart
	maid = nil
	v = nil
	track = nil
	clone = nil
	humanoidRootPart = nil

	if v2 then
		playSquatSound("PS2trainingWEIGHTSputdown", v6)
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

local Squat = {}

function Squat.Do(p, instance, _, _)
	teardown()
	maid = faye.new()
	maid:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still"))
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay"))
	maid:Add(Utility.AddValue(getvaluesfolder, "NR"))
	track = instance.Humanoid.Animator:LoadAnimation(script.Squat)
	track:Play()
	humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
	playSquatSound("PS2trainingWEIGHTSpickup", humanoidRootPart)

	if humanoidRootPart then
		clone = script.Parent.PS2trainingWEIGHTSloop:Clone()
		clone.Looped = true
		clone.Parent = humanoidRootPart
		clone:Play()
	end

	local flag = false
	v = BarKeepup(p.PlayerGui:WaitForChild("Misc"), {
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

function Squat:Stop(_, _)
	teardown()
end

return Squat