local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
return {
	["Angler Runo"] = {
		BeforeRun = function(_, _)
			local data = Utility.GetData(Players.LocalPlayer)

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill fill your crates(Lv 45)") == "Doing" then
				local illfillyourcratesLv45 = Quests.Holder["Ill fill your crates(Lv 45)"]
				local child

				if not (data == nil or illfillyourcratesLv45 == nil) then
					child = data.Quests.Holder:FindFirstChild(illfillyourcratesLv45.QuestInstance.Name) or nil
				end

				if child == nil then
					return "Runo_Waiting"
				end

				for childName, taskSpec in illfillyourcratesLv45.TaskSpecs do
					if taskSpec.Type ~= "Deposit" then
						continue
					end

					local child2 = child.Tasks:FindFirstChild(childName)

					if child2 == nil or child2.Value.Value < child2.Max.Value then
						return "Runo_Waiting"
					end
				end

				return "Runo_Return"
			elseif Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill land the good catch(Lv 60)") == "Doing" then
				local illlandthegoodcatchLv60 = Quests.Holder["Ill land the good catch(Lv 60)"]
				local child

				if not (data == nil or illlandthegoodcatchLv60 == nil) then
					child = data.Quests.Holder:FindFirstChild(illlandthegoodcatchLv60.QuestInstance.Name) or nil
				end

				if child == nil then
					return "Runo_CatchWaiting"
				end

				for childName, taskSpec in illlandthegoodcatchLv60.TaskSpecs do
					if taskSpec.Type ~= "Deposit" then
						continue
					end

					local child2 = child.Tasks:FindFirstChild(childName)

					if child2 == nil or child2.Value.Value < child2.Max.Value then
						return "Runo_CatchWaiting"
					end
				end

				return "Runo_CatchReturn"
			else
				if data ~= nil and data.Inventory.Inventory:FindFirstChild("Legendary Fishing Rod") ~= nil then
					return "Runo_Successor"
				end

				if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill find the permit stamp(Lv 45)") == "Done" then
					return nil
				end

				return "Runo_NoPermit"
			end
		end,
		Text = "Ah. A fresh face on my dock.",
		Answers = true,
		IfTrue = "Runo_2"
	},
	Runo_2 = {
		Text = "Forty years I've pulled this harbor's supper out of the water.",
		Answers = true,
		IfTrue = "Runo_3"
	},
	Runo_3 = {
		Text = "My hands have gone stiff on me. The crate still wants filling.",
		Answers = true,
		IfTrue = "Runo_4"
	},
	Runo_4 = {
		Text = "Two of each thing that bites out there. Think you've the patience?",
		Answers = {
			Close = "",
			["Ill fill your crates(Lv 45)"] = "AddQuest",
			["Anything bigger?"] = "Runo_Bigger"
		}
	},
	Runo_Bigger = {
		Text = "There is, once you've fished these waters a while.",
		Answers = true,
		IfTrue = "Runo_Bigger2"
	},
	Runo_Bigger2 = {
		Text = "A proper crate. Same everyday fish, more of them, and two of the pretty ones.",
		Answers = true,
		IfTrue = "Runo_Bigger3"
	},
	Runo_Bigger3 = {
		Text = `A {nameTag("Clown Fish")} and a {nameTag("Zebra Fish")}.`,
		Answers = true,
		IfTrue = "Runo_Bigger3b"
	},
	Runo_Bigger3b = {
		Text = "They come up rare on that line of yours, so don't go hunting them. Just keep what surfaces.",
		Answers = true,
		IfTrue = "Runo_Bigger4"
	},
	Runo_Bigger4 = {
		Text = `Hold onto any {nameTag("Golden Fish")} though. {nameTag("Fisherman Jeso")} trades those for the better rod. Don't waste one on me.`,
		Answers = {
			Close = "",
			["Ill land the good catch(Lv 60)"] = "AddQuest",
			["And bigger than that?"] = "Runo_Deep"
		}
	},
	Runo_Deep = {
		Text = "There's things down there I've no crate for.",
		Answers = true,
		IfTrue = "Runo_Deep2"
	},
	Runo_Deep2 = {
		Text = `{nameTag("Crustadon")}. {nameTag("Krathulon")}. The water gives one up when it feels like it, and not before.`,
		Answers = true,
		IfTrue = "Runo_Deep3"
	},
	Runo_Deep3 = {
		Text = `Don't sell them. Not to {nameTag("Ginzo")}, not to anyone.`,
		Answers = true,
		IfTrue = "Runo_Deep4"
	},
	Runo_Deep4 = {
		Text = "You'll know why, or you won't. Keep them either way.",
		Answers = true
	},
	Runo_Successor = {
		Text = "That's his rod.",
		Answers = true,
		IfTrue = "Runo_Successor2"
	},
	Runo_Successor2 = {
		Text = "Twenty years I fished beside that man, and never once out-caught him.",
		Answers = true,
		IfTrue = "Runo_Successor3"
	},
	Runo_Successor3 = {
		Text = "Now it's back on my dock in somebody else's hands. Crate still wants filling.",
		Answers = true,
		IfTrue = "Runo_4"
	},
	Runo_NoPermit = {
		Text = "No permit, no rod, and the fish don't care either way.",
		Answers = true,
		IfTrue = "Runo_NoPermit2"
	},
	Runo_NoPermit2 = {
		Text = `See the {nameTag("Dock Master Sofen")} first. Then {nameTag("Fisherman Jeso")}, for the rod.`,
		Answers = true,
		IfTrue = "Runo_NoPermit3"
	},
	Runo_NoPermit3 = {
		Text = "Come back with a line in your hand and we'll talk.",
		Answers = true
	},
	Runo_Waiting = {
		Text = "The sea keeps its own hours. Load whatever you land straight into the crate.",
		Answers = true
	},
	Runo_Return = {
		Text = "Crate's full. [All eight]<Color=(1,.85,.3)>, and not one gone soft.",
		Answers = {
			Close = "",
			["The crate is loaded"] = "DeliverHaulToRuno"
		}
	},
	Runo_Thanks = {
		Text = "Not bad.",
		Answers = true,
		IfTrue = "Runo_Thanks2"
	},
	Runo_Thanks2 = {
		Text = "You've got more patience than most fishermen I know.",
		Answers = true,
		IfTrue = "Runo_Thanks3"
	},
	Runo_Thanks3 = {
		Text = "The village eats tonight. Come find me when the water's calm again.",
		Answers = true
	},
	Runo_Short = {
		Text = "Crate's not full yet. Two of each, and I'll know if you're short.",
		Answers = true
	},
	Runo_CatchWaiting = {
		Text = "Still short. The pretty ones surface when they feel like it. Keep the line out.",
		Answers = true
	},
	Runo_CatchReturn = {
		Text = "Now that's a crate. [Twelve and the two]<Color=(1,.85,.3)>.",
		Answers = {
			Close = "",
			["The crate is loaded"] = "DeliverGoodCatchToRuno"
		}
	},
	Runo_CatchThanks = {
		Text = "The market'll talk about this one.",
		Answers = true,
		IfTrue = "Runo_CatchThanks2"
	},
	Runo_CatchThanks2 = {
		Text = "Forty years and I still can't tell you why they bite some days and not others.",
		Answers = true,
		IfTrue = "Runo_CatchThanks3"
	},
	Runo_CatchThanks3 = {
		Text = "And you still brought them in. That's the whole trade.",
		Answers = true
	},
	Runo_CatchShort = {
		Text = "Twelve of the everyday, and one each of the pretty pair. I'll know if you're short.",
		Answers = true
	}
}