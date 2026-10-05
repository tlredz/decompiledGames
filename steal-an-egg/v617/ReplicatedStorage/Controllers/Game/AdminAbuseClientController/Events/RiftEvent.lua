game:GetService("Debris")
game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
game:GetService("ServerStorage")
game:GetService("Workspace")
local BossEventFlags = require(ReplicatedStorage.Shared.Flags.BossEventFlags)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = Trove.new()
local v2 = false
local v3 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayCutscene1Async()
	local Cutscene1 = require(script.Cutscene1)
	Cutscene1(v).Run()
end

local function PlayCutscene2Async()
	Players.LocalPlayer:SetAttribute("RiftCutscene2Seen", true)
	local Cutscene2 = require(script.Cutscene2)
	Cutscene2(v).Run()
end

local RiftEvent = {
	StartEvent = function(_, _: number)
		if not BossEventFlags.ContentEnabled:Get() then
			return
		end

		v:Clean()
		v2 = true
		v3 = false
		v:Connect(Remotes.BossEvent.HealthShifted.OnClientEvent, function(p: number)
			if v3 or p > 0 then
				return
			end

			v3 = true
			task.wait(4)
			task.spawn(PlayCutscene2Async)
		end)
		PlayCutscene1Async() -- equivalent call inferred; original call site unknown
	end,
	StopEvent = function(self)
		v:Clean()
		v2 = false
	end
}
BossEventFlags.ContentEnabled.Changed:Connect(function()
	if not BossEventFlags.ContentEnabled:Get() and v2 then
		RiftEvent:StopEvent()
	end
end)
return RiftEvent