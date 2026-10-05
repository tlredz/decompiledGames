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
	["Iceveil Guard Shiro"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill fill the winter stores(Lv 105)") == "Doing" then
				if stocked("Ill fill the winter stores(Lv 105)") then
					return "Shiro_CatchReturn"
				end

				return "Shiro_CatchWaiting"
			else
				local playerQuestState = Quests.GetPlayerQuestState(
					Players.LocalPlayer,
					"Ill help you survive the winter(Lv 100)"
				)

				if playerQuestState == "Doing" then
					if stocked("Ill help you survive the winter(Lv 100)") then
						return "Shiro_Return"
					end

					return "Shiro_Waiting"
				elseif playerQuestState == "Done" then
					return "Shiro_Catch"
				end
			end
		end,
		Text = "Hold it.",
		Answers = true,
		IfTrue = "Shiro_2"
	},
	Shiro_2 = {
		Text = "Before you go through that gate, there's something you should know.",
		Answers = true,
		IfTrue = "Shiro_3"
	},
	Shiro_3 = {
		Text = `{nameTag("Iceveil Settlement")} is running [dangerously low on supplies]<Color=(1,.3,.3)>.`,
		Answers = true,
		IfTrue = "Shiro_3b"
	},
	Shiro_3b = {
		Text = `We trade timber down to {nameTag("Windy Peak")} for food. [Bandits work that road]<Color=(1,.3,.3)>.`,
		Answers = true,
		IfTrue = "Shiro_4"
	},
	Shiro_4 = {
		Text = "We're doing everything we can to keep the people behind these walls alive.",
		Answers = true,
		IfTrue = "Shiro_5"
	},
	Shiro_5 = {
		Text = "You want in, you help us survive the winter.",
		Answers = true,
		IfTrue = "Shiro_6"
	},
	Shiro_6 = {
		Text = `[Nine]<Color=(1,.85,.3)> {nameTag("Cooked Bear Meat")}, to feed the families.`,
		Answers = true,
		IfTrue = "Shiro_7"
	},
	Shiro_7 = {
		Text = `[25]<Color=(1,.85,.3)> {nameTag("Health Elixir")}, for the wounded.`,
		Answers = true,
		IfTrue = "Shiro_8"
	},
	Shiro_8 = {
		Text = `{nameTag("Lucy")} in {nameTag("Windy Peak")} cooks the meat. Her pantry run earns it.`,
		Answers = true,
		IfTrue = "Shiro_9"
	},
	Shiro_9 = {
		Text = `{nameTag("Alchemist Meku")} brews the elixirs in {nameTag("Mistfall Harbor")}. He'll want {nameTag("Demon Horns")}.`,
		Answers = true,
		IfTrue = "Shiro_10"
	},
	Shiro_10 = {
		Text = "Fetch it first. I'm not going anywhere, and the [stores]<Color=(1,.85,.3)> are right behind me when you are.",
		Answers = {
			Close = "",
			["Ill help you survive the winter(Lv 100)"] = "AddQuest"
		}
	},
	Shiro_Waiting = {
		Text = `{nameTag("Lucy")}'s pantry, {nameTag("Alchemist Meku")}'s shop. Load the stores behind me and come tell me.`,
		Answers = true
	},
	Shiro_Return = {
		Text = "That's the stores loaded, then.",
		Answers = {
			Close = "",
			["The settlement is stocked"] = "DeliverSuppliesToShiro"
		}
	},
	Shiro_Thanks = {
		Text = "You actually brought everything.",
		Answers = true,
		IfTrue = "Shiro_Thanks2"
	},
	Shiro_Thanks2 = {
		Text = "The meat feeds our families. The elixirs keep our wounded alive until the road opens.",
		Answers = true,
		IfTrue = "Shiro_Thanks3"
	},
	Shiro_Thanks3 = {
		Text = "Most travelers would have turned around and left.",
		Answers = true,
		IfTrue = "Shiro_Thanks4"
	},
	Shiro_Thanks4 = {
		Text = "You chose to help.",
		Answers = true,
		IfTrue = "Shiro_Thanks5"
	},
	Shiro_Thanks5 = {
		Text = "[The gates of Iceveil Settlement are open to you.]<Style=Rainbow>",
		Answers = true
	},
	Shiro_Catch = {
		Text = "Gate's yours. If you want steady work, the stores still run dry.",
		Answers = true,
		IfTrue = "Shiro_Catch2"
	},
	Shiro_Catch2 = {
		Text = "The river doesn't care about bandits. Fish it.",
		Answers = true,
		IfTrue = "Shiro_Catch3"
	},
	Shiro_Catch3 = {
		Text = `[Twelve]<Color=(1,.85,.3)> each of {nameTag("Golden Fish")}, {nameTag("Clown Fish")} and {nameTag("Zebra Fish")}.`,
		Answers = true,
		IfTrue = "Shiro_Catch4"
	},
	Shiro_Catch4 = {
		Text = `[Two]<Color=(1,.85,.3)> each of {nameTag("Crustadon")} and {nameTag("Krathulon")}. Those two run deep. [A common line won't reach them]<Color=(1,.3,.3)>.`,
		Answers = true,
		IfTrue = "Shiro_Catch5"
	},
	Shiro_Catch5 = {
		Text = "Stores are behind me. Load them, then tell me.",
		Answers = {
			Close = "",
			["Ill fill the winter stores(Lv 105)"] = "AddQuest"
		}
	},
	Shiro_CatchWaiting = {
		Text = "Stores are behind me. Fill them.",
		Answers = true
	},
	Shiro_CatchReturn = {
		Text = "That's a full load of fish, then.",
		Answers = {
			Close = "",
			["The stores are full"] = "DeliverWinterCatchToShiro"
		}
	},
	Shiro_CatchThanks = {
		Text = "Good. That's the pots full a while longer.",
		Answers = true,
		IfTrue = "Shiro_CatchThanks2"
	},
	Shiro_CatchThanks2 = {
		Text = "Come back when you've fished more. The winter isn't done with us.",
		Answers = true
	},
	Shiro_Short = {
		Text = "The stores aren't full yet.",
		Answers = true
	}
}