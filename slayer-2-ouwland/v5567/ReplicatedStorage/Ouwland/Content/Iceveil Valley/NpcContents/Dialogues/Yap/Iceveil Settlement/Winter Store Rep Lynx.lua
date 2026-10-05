local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag

local function rumourOpen()
	local data = Utility.GetData(Players.LocalPlayer)
	local worldEvents

	if data ~= nil then
		worldEvents = data:FindFirstChild("WorldEvents")
	end

	return worldEvents ~= nil and worldEvents:FindFirstChild("WarFansClue_3") ~= nil and worldEvents:FindFirstChild("ChestMound_Firstlight War Fans Schematic") == nil
end

local function exit()
	if rumourOpen() then
		return "Lynx_Rumour"
	end

	return nil
end

return {
	["Winter Store Rep Lynx"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill help you survive the winter(Lv 100)") == "Done" then
				return
			else
				return "Lynx_Locked"
			end
		end,
		Text = "Ah, a traveler. Not many make it this far through the snow.",
		Answers = true,
		IfTrue = "Lynx_2"
	},
	Lynx_2 = {
		Text = `If you are looking to survive {nameTag("Iceveil Valley")}'s winters, browse the racks. They turn over every hour, so what you see now will not keep.`,
		Answers = true,
		AutoNext = 1,
		IfTrue = exit
	},
	Lynx_Locked = {
		Text = "These racks are settlement stock. I cannot sell off them to someone the gate has not let in.",
		Answers = true,
		IfTrue = "Lynx_Locked2"
	},
	Lynx_Locked2 = {
		Text = `Help {nameTag("Iceveil Guard Shiro")} see us through the winter first. Then come and warm up.`,
		Answers = true
	},
	Lynx_PurchaseSuccess = {
		Text = "A wise purchase. Out here, warmth can mean the difference between life and death.",
		Answers = true,
		AutoNext = 1,
		IfTrue = exit
	},
	Lynx_PurchaseFail = {
		Text = "Not enough on you, I am afraid. Come back with a heavier purse -- and mind the racks, they turn over every hour.",
		Answers = true,
		IfTrue = exit
	},
	Lynx_Rumour = {
		Text = "The woman with the wrapped hands? She bought the heaviest coat on the rack and went straight back out into the snow.",
		Answers = {
			Close = "",
			["Where did she go?"] = "WarFansClue4"
		}
	},
	Lynx_Rumour2 = {
		Text = "She said she had buried a pair of fans out there and would not leave the valley without them.",
		Answers = true,
		IfTrue = "Lynx_Rumour3"
	},
	Lynx_Rumour3 = {
		Text = "Toward the drop, past the last houses. She came back without her shovel and would not say why. If it is still out there, the snow has it.",
		Answers = true
	}
}