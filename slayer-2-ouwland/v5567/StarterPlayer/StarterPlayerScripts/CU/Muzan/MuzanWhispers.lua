local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local global = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global")
local Utility = require(global:WaitForChild("Utility"))
local MuzanSettings = require(global:WaitForChild("MuzanSettings"))
local BunchaIcons = require(global:WaitForChild("BunchaIcons"))
local centerLeft = ReplicatedStorage:WaitForChild("Communication"):WaitForChild("CnC"):WaitForChild("Notifications"):WaitForChild("CenterLeft")
local v = {}
local changedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function shout(pool)
	centerLeft:Fire("Npc", {
		Icon = BunchaIcons.MuzanShoutIcon,
		Text = pool[math.random(#pool)],
		Duration = MuzanSettings.WhisperDuration
	})
end

local function canHearWhispers(instance)
	local race = instance ~= nil and instance:FindFirstChild("Race") or nil
	return race ~= nil and race.Value == "Human"
end

local function bind()
	local data = Utility.GetData(Players.LocalPlayer, true)

	if changedConnection ~= nil then
		changedConnection:Disconnect()
		changedConnection = nil
	end

	local reputation = data:WaitForChild("Reputation", 10)

	if reputation == nil then
		return
	end

	local value = reputation.Value
	changedConnection = reputation.Changed:Connect(function(p)
		local v2 = value
		value = p

		if v2 <= p then
			return
		end

		local v3 = data
		local race

		if v3 ~= nil then
			race = v3:FindFirstChild("Race") or nil
		end

		local v4

		if race == nil then
			v4 = false
		else
			v4 = race.Value == "Human"
		end

		if not v4 then
			return
		end

		local v5 = nil

		for _, whisper in MuzanSettings.Whispers do
			if not (whisper.Threshold < v2) or not (p <= whisper.Threshold) or v[whisper.Threshold] then
				continue
			end

			v[whisper.Threshold] = true
			v5 = whisper
		end

		if v5 ~= nil then
			shout(v5.Pool) -- equivalent call inferred; original call site unknown
		end
	end)
end

task.spawn(function()
	bind()
	local _, _, v2 = Utility.GetData(Players.LocalPlayer, true)
	v2.Changed:Connect(bind)
	task.wait(MuzanSettings.JoinReminderDelay)
	local data = Utility.GetData(Players.LocalPlayer)

	if data ~= nil then
		local race

		if data ~= nil then
			race = data:FindFirstChild("Race") or nil
		end

		local v3

		if race == nil then
			v3 = false
		else
			v3 = race.Value == "Human"
		end

		if v3 then
			local reputation = data:FindFirstChild("Reputation")
			local whisper = MuzanSettings.Whispers[#MuzanSettings.Whispers]

			if reputation ~= nil and reputation.Value <= whisper.Threshold and not v[whisper.Threshold] then
				v[whisper.Threshold] = true
				shout(whisper.Pool) -- equivalent call inferred; original call site unknown
			end
		end
	end
end)