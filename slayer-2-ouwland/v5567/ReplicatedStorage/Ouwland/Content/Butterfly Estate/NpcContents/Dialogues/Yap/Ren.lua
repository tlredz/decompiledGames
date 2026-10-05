local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag

local function bladeFound()
	local data = Utility.GetData(Players.LocalPlayer)
	local illlookforyourbladeLv75 = Quests.Holder["Ill look for your blade(Lv 75)"]
	local child

	if data ~= nil then
		child = illlookforyourbladeLv75 ~= nil and data.Quests.Holder:FindFirstChild(illlookforyourbladeLv75.QuestInstance.Name) or nil
	end

	if child == nil then
		return false
	end

	local nichirinBladefound = child.Tasks:FindFirstChild("Nichirin Blade found")
	return nichirinBladefound ~= nil and nichirinBladefound.Value.Value >= nichirinBladefound.Max.Value
end

return {
	Ren = {
		BeforeRun = function(_, _)
			local playerQuestState = Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill look for your blade(Lv 75)")

			if playerQuestState == "Doing" then
				if bladeFound() then
					return "Ren_Return"
				end

				return "Ren_Waiting"
			elseif playerQuestState == "Done" then
				return "Ren_Done"
			end
		end,
		Text = "Ugh...",
		Answers = true,
		IfTrue = "Ren_2"
	},
	Ren_2 = {
		Text = "My head still hurts.",
		Answers = true,
		IfTrue = "Ren_3"
	},
	Ren_3 = {
		Text = "I was returning from a mission when I slipped near the [river]<Color=(1,.85,.3)>.",
		Answers = true,
		IfTrue = "Ren_4"
	},
	Ren_4 = {
		Text = `When I woke up, my {nameTag("Nichirin Blade")} was gone.`,
		Answers = true,
		IfTrue = "Ren_5"
	},
	Ren_5 = {
		Text = "Can you help me find it?",
		Answers = {
			Close = "",
			["Ill look for your blade(Lv 75)"] = "AddQuest",
			["Where exactly did you slip?"] = "Ren_Where"
		}
	},
	Ren_Where = {
		Text = "The road back from a mission runs up the river gorge, [northwest]<Color=(1,.85,.3)> of here. The bank gave under me.",
		Answers = true,
		IfTrue = "Ren_Where2"
	},
	Ren_Where2 = {
		Text = "I came round on the stones with the water at my back and my hand empty.",
		Answers = true,
		IfTrue = "Ren_Where2b"
	},
	Ren_Where2b = {
		Text = "The current only runs one way down there, toward the [falls]<Color=(1,.85,.3)>.",
		Answers = true,
		IfTrue = "Ren_Where3"
	},
	Ren_Where3 = {
		Text = `I'd go myself, but {nameTag("Shiori")} won't have me off the grounds until my head clears.`,
		Answers = true,
		IfTrue = "Ren_Where3b"
	},
	Ren_Where3b = {
		Text = "A slow lap of the lawn is the whole of my day.",
		Answers = true,
		IfTrue = "Ren_5"
	},
	Ren_Waiting = {
		Text = "That blade means everything to a Demon Slayer.",
		Answers = {
			Close = "",
			["Where exactly did you slip?"] = "Ren_WaitingWhere"
		}
	},
	Ren_WaitingWhere = {
		Text = "Go [northwest]<Color=(1,.85,.3)> and keep heading downhill until you meet the river, then follow it to the [falls]<Color=(1,.85,.3)>.",
		Answers = true,
		IfTrue = "Ren_WaitingWhere2"
	},
	Ren_WaitingWhere2 = {
		Text = "It'll be at the foot of them, on the bank.",
		Answers = true
	},
	Ren_Return = {
		Text = "You came back. Please tell me you found it.",
		Answers = {
			Close = "",
			["I found your blade"] = "ReturnNichirinToRen"
		}
	},
	Ren_Thanks = {
		Text = "You found it...",
		Answers = true,
		IfTrue = "Ren_Thanks2"
	},
	Ren_Thanks2 = {
		Text = "Thank goodness.",
		Answers = true,
		IfTrue = "Ren_Thanks3"
	},
	Ren_Thanks3 = {
		Text = "I thought I'd never see it again.",
		Answers = true
	},
	Ren_Done = {
		Text = "Head's still ringing, but I've got my blade back. I won't forget that. The gourds by my post are yours to buy. No slayer should train their breathing dry.",
		Answers = true
	},
	Ren_GourdSuccess = {
		Text = "Fill your lungs with it. That's what it's for.",
		Answers = 1
	},
	Ren_GourdFail = {
		Text = function(_, p)
			return (`No sale yet -- you'll want {p.PurchaseReason}. I'm not going anywhere; Shiori's orders.`)
		end,
		Answers = true
	},
	Ren_NoBlade = {
		Text = "You've come back with nothing. It's still out there, at the foot of the falls.",
		Answers = true
	}
}