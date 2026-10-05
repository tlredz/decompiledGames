local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local nameTag = Utility.NameTag

local function hasNote()
	local data = Utility.GetData(Players.LocalPlayer)
	return data ~= nil and data.Inventory.Inventory:FindFirstChild("Suspicious Note") ~= nil
end

return {
	Noote = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill bring him the notes") == "Doing" then
				SignalEvent.ToServer("QuestProgress", "Ill bring him the notes", "Speak with Noote")
			end

			local playerQuestState = Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill get this letter delivered")

			if playerQuestState == "Doing" then
				return "Noote_Doing"
			elseif playerQuestState == "Done" then
				return "Noote_Done"
			end

			local data = Utility.GetData(Players.LocalPlayer)
			local v

			if data == nil then
				v = false
			else
				v = data.Inventory.Inventory:FindFirstChild("Suspicious Note") ~= nil
			end

			if v then
				return
			else
				return "Noote_Idle"
			end
		end,
		Text = "Oh... what's that you've got there? ...A note? Let me see that.",
		Answers = true,
		IfTrue = "Noote_2"
	},
	Noote_2 = {
		Text = "Oh wow... this isn't random scribbles. This is [coded]<Color=(1,.85,.3)>.",
		Answers = true,
		IfTrue = "Noote_3"
	},
	Noote_3 = {
		Text = "These spies are taking orders from a [bandit group]<Color=(1,.3,.3)> outside the village.",
		Answers = true,
		IfTrue = "Noote_4"
	},
	Noote_4 = {
		Text = "And this part here... [\"Move when the beasts scatter.\"]<Style=Fade,Color=(.8,.7,1)>",
		Answers = true,
		IfTrue = "Noote_5"
	},
	Noote_5 = {
		Text = "...they're using the wildlife. This is bigger than a few spies.",
		Answers = true,
		IfTrue = "Noote_6"
	},
	Noote_6 = {
		Text = `Take this letter to Windy Peak's escort {nameTag("Chaka")}.`,
		Answers = true,
		IfTrue = "Noote_7"
	},
	Noote_7 = {
		Text = "And next time, don't get [Stains]<Color=(1,.3,.3)> all over the evidence. Makes my job harder.",
		Answers = {
			Close = "",
			["Ill get this letter delivered"] = "AddQuest"
		}
	},
	Noote_Idle = {
		Text = "My uncle runs this village. I just do the thinking.",
		Answers = true,
		IfTrue = "Noote_Idle2"
	},
	Noote_Idle2 = {
		Text = "My uncle says a good mask doesn't hide your face. It shows you where everything else is weak.",
		Answers = true
	},
	Noote_Doing = {
		Text = "Hurry up, this is important.",
		Answers = true
	},
	Noote_Done = {
		Text = `{nameTag("Chaka")} has the letter? Good. Now we wait and see who moves first.`,
		Answers = true,
		IfTrue = "Noote_Idle2"
	}
}