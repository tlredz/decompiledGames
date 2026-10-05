local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag

local function carriesThePair(instance)
	return instance:FindFirstChild("Crustadon") ~= nil and instance:FindFirstChild("Krathulon") ~= nil
end

local function rumourOpen(instance)
	local worldEvents

	if instance ~= nil then
		worldEvents = instance:FindFirstChild("WorldEvents")
	end

	return worldEvents ~= nil and worldEvents:FindFirstChild("WarFansClue_1") ~= nil and worldEvents:FindFirstChild("WarFansClue_3") == nil
end

local function exit()
	local data = Utility.GetData(Players.LocalPlayer)
	local worldEvents

	if data ~= nil then
		worldEvents = data:FindFirstChild("WorldEvents")
	end

	local v

	if worldEvents == nil or worldEvents:FindFirstChild("WarFansClue_1") == nil then
		v = false
	else
		v = worldEvents:FindFirstChild("WarFansClue_3") == nil
	end

	if v then
		return "Sofen_Rumour"
	end

	return nil
end

return {
	["Dock Master Sofen"] = {
		BeforeRun = function(_, _)
			local data = Utility.GetData(Players.LocalPlayer)
			local playerQuestState = Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill find the permit stamp(Lv 45)")

			if playerQuestState == "Doing" then
				if data == nil or data.Inventory.Inventory:FindFirstChild("Permit Stamp") == nil then
					return "Sofen_Waiting"
				end

				return "Sofen_Return"
			else
				if playerQuestState ~= "Done" then
					return
				end

				if data == nil then
					return "Sofen_Done"
				end

				local inventory = data.Inventory.Inventory

				if inventory:FindFirstChild("Legendary Fishing Rod") ~= nil then
					return "Sofen_Closed"
				end

				local v

				if inventory:FindFirstChild("Crustadon") == nil then
					v = false
				else
					v = inventory:FindFirstChild("Krathulon") ~= nil
				end

				if v then
					return "Sofen_Ledger"
				end

				return "Sofen_Done"
			end
		end,
		Text = "A fishing permit?",
		Answers = true,
		IfTrue = "Sofen_Offer"
	},
	Sofen_Offer = {
		Text = "I can issue one, but not for free.",
		Answers = true,
		IfTrue = "Sofen_Offer2"
	},
	Sofen_Offer2 = {
		Text = "Too many people take rods out onto the water and leave broken lines, lost hooks and damaged nets behind.",
		Answers = true,
		IfTrue = "Sofen_Offer3"
	},
	Sofen_Offer3 = {
		Text = "If you want a permit, you'll have to show you're willing to help maintain the docks.",
		Answers = true,
		IfTrue = "Sofen_Offer4"
	},
	Sofen_Offer4 = {
		Text = `Pay me [5,000]<Color=(1,1,1)> [#]<img={BunchaIcons.WenRaw}> and find the ["Lost Permit Stamp"]<Color=(1,.85,.3)>.`,
		Answers = true,
		IfTrue = "Sofen_Offer5"
	},
	Sofen_Offer5 = {
		Text = "Last I heard, it was left somewhere around the docks.",
		Answers = {
			Close = exit,
			["Ill find the permit stamp(Lv 45)"] = "AddQuest"
		}
	},
	Sofen_Waiting = {
		Text = "Still no stamp? The docks aren't going to fix themselves.",
		Answers = true,
		IfTrue = exit
	},
	Sofen_Return = {
		Text = "Ah, my stamp!",
		Answers = {
			Close = exit,
			["Hand over the permit stamp"] = "DeliverPermitStampToSofen"
		}
	},
	Sofen_Thanks = {
		Text = "Good work.",
		Answers = true,
		IfTrue = "Sofen_Thanks2"
	},
	Sofen_Thanks2 = {
		Text = "Here is your [\"Fishing Permit\"]<Color=(1,.85,.3)>.",
		Answers = true,
		IfTrue = "Sofen_Thanks3"
	},
	Sofen_Thanks3 = {
		Text = "Show it to the fisherman, and he'll know you're approved.",
		Answers = true,
		AutoNext = 1,
		IfTrue = exit
	},
	Sofen_NoStamp = {
		Text = "You're not carrying my stamp.",
		Answers = true,
		IfTrue = exit
	},
	Sofen_Done = {
		Text = "Your permit's in order. Keep the water clean and we'll have no trouble.",
		Answers = true,
		AutoNext = 1,
		IfTrue = exit
	},
	Sofen_Ledger = {
		Text = "Hold there. Those two you're carrying.",
		Answers = true,
		IfTrue = "Sofen_Ledger2"
	},
	Sofen_Ledger2 = {
		Text = "One other man ever brought a pair like that onto my dock.",
		Answers = true,
		IfTrue = "Sofen_Ledger2b"
	},
	Sofen_Ledger2b = {
		Text = "He went out again that same week, and I never stamped him back in.",
		Answers = {
			Close = exit,
			["What happened to him?"] = "Sofen_Ledger3"
		}
	},
	Sofen_Ledger3 = {
		Text = "Nobody ever told me. So his permit sits open in my ledger. Twenty years of a drawer I can't close.",
		Answers = true,
		IfTrue = "Sofen_Ledger4"
	},
	Sofen_Ledger4 = {
		Text = `[2,500]<Color=(1,1,1)> [#]<img={BunchaIcons.WenRaw}> and I'll read you what's on his file. Records cost the same whether the man's alive or not.`,
		Answers = {
			Close = exit,
			["Pay to hear it"] = "SofenPullLedger"
		}
	},
	Sofen_LedgerDone = {
		Text = "Isao. That's the name on it, for what it's worth to you.",
		Answers = true,
		IfTrue = "Sofen_LedgerDone2"
	},
	Sofen_LedgerDone2 = {
		Text = "He fished the same stretch every night of his life. Up the gorge beside the red bridge.",
		Answers = true,
		IfTrue = "Sofen_LedgerDone3"
	},
	Sofen_LedgerDone3 = {
		Text = "On the rock ledge across from the water spout. That's where you'd have found him, any night you cared to look.",
		Answers = true,
		IfTrue = "Sofen_LedgerDone4"
	},
	Sofen_LedgerDone4 = {
		Text = "What you want with a dead man's fishing spot is your business. I only keep the ledger.",
		Answers = true,
		AutoNext = 1,
		IfTrue = exit
	},
	Sofen_Closed = {
		Text = "You found it, then.",
		Answers = true,
		IfTrue = "Sofen_Closed2"
	},
	Sofen_Closed2 = {
		Text = "His permit's struck. Closed the file, and wrote your name under his.",
		Answers = true,
		IfTrue = "Sofen_Closed3"
	},
	Sofen_Closed3 = {
		Text = "Means nothing to the water. Means a great deal to my ledger.",
		Answers = true,
		AutoNext = 1,
		IfTrue = exit
	},
	Sofen_LedgerBroke = {
		Text = "Coin first. The drawer's waited this long, it can wait on you.",
		Answers = true,
		IfTrue = exit
	},
	Sofen_Rumour = {
		Text = "The woman with the bandaged hands? You are not the first to ask. I stamped her out.",
		Answers = {
			Close = "",
			["Where did she go?"] = "WarFansClue2"
		}
	},
	Sofen_Rumour2 = {
		Text = `North, to {nameTag("Iceveil Valley")}. Paid the carter twice over. She was shaking too badly to count.`,
		Answers = true,
		IfTrue = "Sofen_Rumour3"
	},
	Sofen_Rumour3 = {
		Text = "Said someone up there had dug her out of a drift once already. A man who makes his living off what he catches in the snow.",
		Answers = true
	}
}