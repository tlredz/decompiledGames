local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
local v = { "Axe and Mace", "Seismic Axe and Mace", "Nightfall Axe and Mace" }

local function holdsWeapon(data)
	local inventory = data ~= nil and data:FindFirstChild("Inventory") or nil
	local inventory2 = inventory ~= nil and inventory:FindFirstChild("Inventory") or nil

	if inventory2 == nil then
		return false
	end

	for _, childName in ipairs(v) do
		if inventory2:FindFirstChild(childName) ~= nil then
			return true
		end
	end

	return false
end

return {
	["Stone Trainer Gyorei"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill learn Stone Breathing(Lv 25)") == "Doing" then
				return "StoneTrainer_Doing"
			end

			local data = Utility.GetData(Players.LocalPlayer)
			local v2 = data == nil and "" or data.Powers.Breathing.Value or ""

			if v2 == "Stone" then
				return "StoneTrainer_Done"
			end

			if v2 ~= "" then
				return "StoneTrainer_HasStyle"
			end

			if not Character_info_provider.HasPowerAccess(Players.LocalPlayer, "Stone") then
				return "StoneTrainer_NoAccess"
			end

			if holdsWeapon(data) then
				return
			else
				return "StoneTrainer_NoWeapon"
			end
		end,
		Text = "You have come to train Stone Breathing.",
		Answers = true,
		IfTrue = "StoneTrainer_2"
	},
	StoneTrainer_2 = {
		Text = "Even the hardest stone is shaped slowly, by water and time. Breathe with me a moment first.",
		Answers = {
			["Not yet"] = "",
			["Ill learn Stone Breathing(Lv 25)"] = "AddQuest"
		}
	},
	StoneTrainer_Doing = {
		Text = "Pain is only stone being shaped. Do not mistake it for failure.",
		Answers = true
	},
	StoneTrainer_Done = {
		Text = `You stood against my student and did not waver. [That stillness is the true weight.]<Style=Rainbow> That is {nameTag("Stone Breathing")}.`,
		Answers = true,
		IfTrue = "StoneTrainer_Done2"
	},
	StoneTrainer_Done2 = {
		Text = "Carry it gently. A weight swung carelessly breaks the one holding it.",
		Answers = true
	},
	StoneTrainer_NoAccess = {
		Text = "Breathing is not in you. Seek a different kind of teacher.",
		Answers = true
	},
	StoneTrainer_HasStyle = {
		Text = "You already carry a Breathing. I will not teach over it.",
		Answers = true
	},
	StoneTrainer_NoWeapon = {
		Text = `Stone is not taught to empty hands. Find yourself an {nameTag("Axe and Mace")} first, then we will speak.`,
		Answers = true
	}
}