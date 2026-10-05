local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Shrinking = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.Minigames.Shrinking)
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local thread = nil
local v2 = nil
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseFreeze()
	if v3 == nil then
		return
	end

	local v4 = v3
	v3 = nil

	for _, v5 in v4 do
		if v5 and v5.Parent then
			v5:Destroy()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teardown()
	releaseFreeze() -- equivalent call inferred; original call site unknown
	local v4 = thread
	local v5 = v2
	thread = nil
	v2 = nil

	if v5 then
		v5()
	end

	if v4 then
		task.spawn(function()
			task.wait(0.5)
			v4:Destroy()
		end)
	end
end

local Horse = {}

function Horse.Do(p, _, _, _)
	teardown() -- equivalent call inferred; original call site unknown
	thread = faye.new()
	v3 = {
		Utility.AddValue(getvaluesfolder, "skill_stand_still"),
		Utility.AddValue(getvaluesfolder, "pause_gameplay"),
		Utility.AddValue(getvaluesfolder, "NR")
	}
	local flag = false
	v2 = Shrinking(p.PlayerGui:WaitForChild("Misc"), {
		Thread = thread,
		Stop = function(flag2: boolean)
			if flag then
				return
			end

			flag = true

			if flag2 ~= true and v3 ~= nil then
				local v4 = v3
				v3 = nil

				for _, v5 in v4 do
					if v5 and v5.Parent then
						v5:Destroy()
					end
				end
			end

			SignalEvent.ToServer("training_signaler", "Stop", flag2 == true)
		end
	})
end

function Horse.Stop(_, _, _)
	teardown() -- equivalent call inferred; original call site unknown
end

return Horse