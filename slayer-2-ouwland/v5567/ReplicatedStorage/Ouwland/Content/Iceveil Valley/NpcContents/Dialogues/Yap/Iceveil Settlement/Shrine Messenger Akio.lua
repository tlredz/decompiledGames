local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag

local function stocked(p: string)
	local data = Utility.GetData(Players.LocalPlayer)
	local v = Quests.Holder[p]
	local child

	if not (data == nil or v == nil) then
		child = data.Quests.Holder:FindFirstChild(v.QuestInstance.Name) or nil
	end

	if child == nil then
		return false
	end

	for childName, taskSpec in v.TaskSpecs do
		if taskSpec.Type ~= "Deposit" then
			continue
		end

		local child2 = child.Tasks:FindFirstChild(childName)

		if child2 == nil or child2.Value.Value < child2.Max.Value then
			return false
		end
	end

	return true
end

return {
	["Shrine Messenger Akio"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill help you survive the winter(Lv 100)") ~= "Done" then
				return "Akio_Locked"
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill haul in the deep catch(Lv 125)") == "Doing" then
				if stocked("Ill haul in the deep catch(Lv 125)") then
					return "Akio_FishReturn"
				end

				return "Akio_FishWaiting"
			elseif Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill see you to Windy Peak(Lv 105)") == "Doing" then
				return "Akio_Doing"
			end
		end,
		Text = "Forgive me. You look like someone who travels armed.",
		Answers = true,
		IfTrue = "Akio_2"
	},
	Akio_2 = {
		Text = `{nameTag("Iceveil Settlement")} cannot survive the winter alone. We trade with {nameTag("Windy Peak")}.`,
		Answers = true,
		IfTrue = "Akio_3"
	},
	Akio_3 = {
		Text = `I carry timber down to {nameTag("Village Chief Krue")}. He sends food back.`,
		Answers = true,
		IfTrue = "Akio_4"
	},
	Akio_4 = {
		Text = "[Bandits work that road]<Color=(1,.3,.3)>. The last man they sent down did not return.",
		Answers = true,
		IfTrue = "Akio_5"
	},
	Akio_5 = {
		Text = "Stay at my side and [keep them off the load]<Color=(1,.85,.3)>. Will you see me down?",
		Answers = {
			["Not yet"] = "",
			["Ill see you to Windy Peak(Lv 105)"] = "AddQuest",
			["What else needs doing?"] = "Akio_Fish"
		}
	},
	Akio_Locked = {
		Text = "Forgive me. Settlement business stays inside the walls.",
		Answers = true,
		IfTrue = "Akio_Locked2"
	},
	Akio_Locked2 = {
		Text = `Speak to {nameTag("Iceveil Guard Shiro")} at the gate. Then we can talk.`,
		Answers = true
	},
	Akio_Doing = {
		Text = "The road is waiting on us. Keep close, and I will keep walking.",
		Answers = true
	},
	Akio_Fish = {
		Text = "There is. The road is one way in, and it should not be the only one.",
		Answers = true,
		IfTrue = "Akio_Fish2"
	},
	Akio_Fish2 = {
		Text = "The water keeps giving when the road does not. We could salt what you bring.",
		Answers = true,
		IfTrue = "Akio_Fish3"
	},
	Akio_Fish3 = {
		Text = `[Five]<Color=(1,.85,.3)> {nameTag("Crustadon")}, [five]<Color=(1,.85,.3)> {nameTag("Krathulon")}, and a [dozen]<Color=(1,.85,.3)> {nameTag("Clown Fish")} to salt beside them.`,
		Answers = true,
		IfTrue = "Akio_Fish4"
	},
	Akio_Fish4 = {
		Text = "I am told [only the finest rod ever made]<Color=(1,.3,.3)> brings one of those up. I would not know.",
		Answers = true,
		IfTrue = "Akio_Fish5"
	},
	Akio_Fish5 = {
		Text = "Put them in the [gate stores]<Color=(1,.85,.3)>, with the winter supplies. Then find me.",
		Answers = {
			Close = "",
			["Ill haul in the deep catch(Lv 125)"] = "AddQuest"
		}
	},
	Akio_FishWaiting = {
		Text = "The stores are by the gate. I will be here when they are full.",
		Answers = {
			Close = "",
			["About the road"] = "Akio_2"
		}
	},
	Akio_FishReturn = {
		Text = "You found them. I did not expect you to.",
		Answers = {
			Close = "",
			["The stores are full"] = "DeliverDeepCatchToAkio"
		}
	},
	Akio_FishThanks = {
		Text = "That is more than the road has brought us all winter.",
		Answers = true,
		IfTrue = "Akio_FishThanks2"
	},
	Akio_FishThanks2 = {
		Text = "Go back out when you can. I will keep the stores open for you.",
		Answers = true
	},
	Akio_FishShort = {
		Text = "The stores are not full yet.",
		Answers = true
	}
}