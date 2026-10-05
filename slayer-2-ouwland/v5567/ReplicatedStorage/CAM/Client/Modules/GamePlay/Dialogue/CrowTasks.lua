local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local BossHunts = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.BossHunts)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)

local function race()
	local data = Utility.GetData(Players.LocalPlayer)
	return data ~= nil and data.Race.Value or nil
end

local function CancelBoard()
	Utility.ForceUnequip()
	SignalEvent.ToServer("CrowDismiss")
	return ""
end

return {
	CrowTasks = {
		Text = "Here are your current tasks",
		Answers = {
			Cancel = CancelBoard
		},
		Icon = BunchaIcons.CrowIcon,
		Name = "Kasugai Crow",
		Content = function(p, p2, p3, p4)
			local Quests = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Quests)
			return Quests(p, p2, p3, p4, "CrowTasks_Denied")
		end
	},
	CrowTasks_Denied = {
		Text = function(_, p)
			local huntDenial = p ~= nil and p.HuntDenial or {}
			local noun = BossHunts.Noun
			local data = Utility.GetData(Players.LocalPlayer)
			local v

			if data ~= nil then
				v = data.Race.Value or nil
			end

			local v2 = noun(v)

			if huntDenial.Blocking ~= nil and huntDenial.Reason == false then
				return (`Finish {Utility.NameTag(huntDenial.Blocking)} first. One {v2} at a time.`)
			end

			if huntDenial.Reason == true then
				return (`Not yet. Take a breath before the next {v2}.`)
			end

			if huntDenial.Reason == 1 then
				return (`You are already carrying that {v2}.`)
			end

			return (`That {v2} is not yours to take.`)
		end,
		Answers = true,
		IfTrue = "CrowTasks",
		ContinueContent = true,
		ContinueIcon = true
	}
}