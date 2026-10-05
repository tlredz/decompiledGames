local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local clientEffects = ReplicatedStorage.Communication.CnC.ClientEffects
local Slider = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.Minigames.Slider)
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local maid = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function teardown()
	local v = maid
	maid = nil

	if v then
		v:Destroy()
	end
end

local BoulderSplit = {}

function BoulderSplit.Do(p, instance, _, _)
	teardown() -- equivalent call inferred; original call site unknown
	maid = faye.new()
	maid:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still"))
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay"))
	maid:Add(Utility.AddValue(getvaluesfolder, "NR"))
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local idle = script.Parent:FindFirstChild("Idle")
	local slash = script.Parent:FindFirstChild("Slash")
	local track

	if animator and idle then
		track = animator:LoadAnimation(idle) or nil
	else
		track = nil
	end

	local track2 = animator and slash and animator:LoadAnimation(slash) or nil

	if track then
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Idle
		track:Play(0.1)
	end

	if track2 then
		track2.Looped = false
		track2.Priority = Enum.AnimationPriority.Action
	end

	maid:Add(function()
		if track then
			track:Stop(0.1)
		end

		if track2 then
			track2:Stop(0.1)
		end
	end)
	local flag = false

	local function playSlash()
		if track2 == nil or flag then
			return
		end

		flag = true
		track2:Play(0.1)
		clientEffects:Fire("BoulderSlashFailed", instance)
		SignalEvent.ToServer("training_signaler", "StateChanged")
	end

	if track2 then
		maid:Connect(track2.Stopped, function()
			flag = false
		end)
	end

	local flag2 = false
	Slider(p.PlayerGui:WaitForChild("Misc"), {
		Thread = maid,
		OnComplete = function(_: boolean)
			if track2 ~= nil then
				if flag then
					return
				end

				flag = true
				track2:Play(0.1)
				clientEffects:Fire("BoulderSlashFailed", instance)
				SignalEvent.ToServer("training_signaler", "StateChanged")
			end
		end,
		Stop = function(self: boolean)
			if flag2 then
				return
			end

			flag2 = true
			SignalEvent.ToServer("training_signaler", "Stop", self == true)
		end
	})
end

function BoulderSplit:Stop(_, _)
	teardown() -- equivalent call inferred; original call site unknown
end

return BoulderSplit