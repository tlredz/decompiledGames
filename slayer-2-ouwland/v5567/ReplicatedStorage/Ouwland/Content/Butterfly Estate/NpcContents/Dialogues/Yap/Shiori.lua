local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
local v = { "Rare Fishing Rod", "Legendary Fishing Rod" }

local function crated(p: string)
	local data = Utility.GetData(Players.LocalPlayer)
	local v2 = Quests.Holder[p]
	local child

	if not (data == nil or v2 == nil) then
		child = data.Quests.Holder:FindFirstChild(v2.QuestInstance.Name) or nil
	end

	if child == nil then
		return false
	end

	for childName, taskSpec in v2.TaskSpecs do
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

local function holdsRod(p)
	if p == nil then
		return false
	end

	for _, childName in v do
		if p.Inventory.Inventory:FindFirstChild(childName) ~= nil then
			return true
		end
	end

	return false
end

local function rumourOpen()
	local data = Utility.GetData(Players.LocalPlayer)
	local worldEvents

	if data ~= nil then
		worldEvents = data:FindFirstChild("WorldEvents")
	end

	return worldEvents ~= nil and worldEvents:FindFirstChild("WarFansClue_2") == nil
end

local function exit()
	local data = Utility.GetData(Players.LocalPlayer)
	local worldEvents

	if data ~= nil then
		worldEvents = data:FindFirstChild("WorldEvents")
	end

	local v2

	if worldEvents == nil then
		v2 = false
	else
		v2 = worldEvents:FindFirstChild("WarFansClue_2") == nil
	end

	if v2 then
		return "Shiori_Rumour"
	end

	return nil
end

return {
	Shiori = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill deliver the supply box(Lv 70)") == "Doing" then
				local data = Utility.GetData(Players.LocalPlayer)

				if data ~= nil and data.Inventory.Inventory:FindFirstChild("Supply Box") ~= nil then
					return "Shiori_Box"
				end
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill stock the reserves(Lv 75)") == "Doing" then
				if crated("Ill stock the reserves(Lv 75)") then
					return "Shiori_FoodReturn"
				end

				return "Shiori_FoodWaiting"
			else
				local playerQuestState = Quests.GetPlayerQuestState(
					Players.LocalPlayer,
					"Ill restock the infirmary(Lv 70)"
				)

				if playerQuestState == "Doing" then
					if crated("Ill restock the infirmary(Lv 70)") then
						return "Shiori_Return"
					end

					return "Shiori_Waiting"
				else
					if playerQuestState ~= "Done" then
						return
					end

					if holdsRod(Utility.GetData(Players.LocalPlayer)) then
						return "Shiori_Food"
					end

					return "Shiori_FoodNoRod"
				end
			end
		end,
		Text = "We're running dangerously low on medical supplies.",
		Answers = true,
		IfTrue = "Shiori_2"
	},
	Shiori_2 = {
		Text = "Every day injured slayers arrive seeking treatment.",
		Answers = true,
		IfTrue = "Shiori_3"
	},
	Shiori_3 = {
		Text = "Without medicine, I [won't be able to help them]<Color=(1,.3,.3)>.",
		Answers = true,
		IfTrue = "Shiori_4"
	},
	Shiori_4 = {
		Text = "Bring me elixirs. Ten of each kind.",
		Answers = true,
		IfTrue = "Shiori_5"
	},
	Shiori_5 = {
		Text = `{nameTag("Health Elixir")}, {nameTag("Health Regen Elixir")} and {nameTag("Stamina Regen Elixir")}.`,
		Answers = true,
		IfTrue = "Shiori_6"
	},
	Shiori_6 = {
		Text = `{nameTag("Alchemist Meku")} in {nameTag("Mistfall Harbor")} sells them all.`,
		Answers = true,
		IfTrue = "Shiori_7"
	},
	Shiori_7 = {
		Text = "Load them into the [infirmary crates]<Color=(1,.85,.3)>, and we can keep treating people.",
		Answers = {
			Close = exit,
			["Ill restock the infirmary(Lv 70)"] = "AddQuest"
		}
	},
	Shiori_Waiting = {
		Text = "The crates are still standing empty. Load whatever you bring straight in.",
		Answers = true,
		IfTrue = exit
	},
	Shiori_Return = {
		Text = "The crates are full again. [All thirty]<Color=(1,.85,.3)>.",
		Answers = {
			Close = exit,
			["The infirmary is stocked"] = "DeliverElixirsToShiori"
		}
	},
	Shiori_Thanks = {
		Text = "Perfect.",
		Answers = true,
		IfTrue = "Shiori_Thanks2"
	},
	Shiori_Thanks2 = {
		Text = "This should keep the infirmary running for a while longer. Thank you.",
		Answers = true,
		IfTrue = "Shiori_Thanks3"
	},
	Shiori_Thanks3 = {
		Text = "Word of what you did here has already reached the bait dealer.",
		Answers = true,
		IfTrue = "Shiori_Thanks4"
	},
	Shiori_Thanks4 = {
		Text = `{nameTag("Baitmonger Nori")}, up in {nameTag("Hidden Mist Village")}. He'll trade with you now.`,
		Answers = true,
		AutoNext = 1,
		IfTrue = exit
	},
	Shiori_Food = {
		Text = "The shelves are full again, thanks to you. Now it's the food stores I'm worried about.",
		Answers = true,
		IfTrue = "Shiori_Food2"
	},
	Shiori_Food2 = {
		Text = "The ones recovering here need more than medicine. They need proper food.",
		Answers = true,
		IfTrue = "Shiori_Food3"
	},
	Shiori_Food3 = {
		Text = "Without it, they [stay in those beds twice as long]<Color=(1,.3,.3)>.",
		Answers = true,
		IfTrue = "Shiori_Food4"
	},
	Shiori_Food4 = {
		Text = "Bring me fish. Nine of each kind.",
		Answers = true,
		IfTrue = "Shiori_Food5"
	},
	Shiori_Food5 = {
		Text = `{nameTag("Golden Fish")}, {nameTag("Clown Fish")} and {nameTag("Zebra Fish")}.`,
		Answers = true,
		IfTrue = "Shiori_Food6"
	},
	Shiori_Food6 = {
		Text = `They run deep, so you'll want {nameTag("Baitmonger Nori")}'s bait for them, up in {nameTag("Hidden Mist Village")}.`,
		Answers = true,
		IfTrue = "Shiori_Food7"
	},
	Shiori_Food7 = {
		Text = "Load them into the same [crates]<Color=(1,.85,.3)>, and we can get people back on their feet.",
		Answers = {
			Close = exit,
			["Ill stock the reserves(Lv 75)"] = "AddQuest",
			["Why not the everyday fish?"] = "Shiori_FoodCommon"
		}
	},
	Shiori_FoodCommon = {
		Text = "The common catch is thin. It won't put weight back on anyone.",
		Answers = true,
		IfTrue = "Shiori_FoodCommon2"
	},
	Shiori_FoodCommon2 = {
		Text = `{nameTag("Angler Runo")} takes those for the village. My patients need better.`,
		Answers = true,
		IfTrue = "Shiori_Food7"
	},
	Shiori_FoodNoRod = {
		Text = "The shelves are full again, thanks to you. I'd ask one more thing, but you'd need a better fishing rod for it.",
		Answers = true,
		IfTrue = "Shiori_FoodNoRod2"
	},
	Shiori_FoodNoRod2 = {
		Text = `{nameTag("Fisherman Jeso")} sells the rod, down on the Mistfall dock, and {nameTag("Baitmonger Nori")} the bait.`,
		Answers = true,
		IfTrue = "Shiori_FoodNoRod3"
	},
	Shiori_FoodNoRod3 = {
		Text = "Come back when you're equipped for it.",
		Answers = true,
		IfTrue = exit
	},
	Shiori_FoodWaiting = {
		Text = "The crates are still short. Load whatever you bring straight in.",
		Answers = true,
		IfTrue = exit
	},
	Shiori_FoodReturn = {
		Text = "The crates are full again. [All 27]<Color=(1,.85,.3)>.",
		Answers = {
			Close = exit,
			["The stores are stocked"] = "DeliverReservesToShiori"
		}
	},
	Shiori_FoodThanks = {
		Text = "Good.",
		Answers = true,
		IfTrue = "Shiori_FoodThanks2"
	},
	Shiori_FoodThanks2 = {
		Text = "They'll eat properly this week. That does more for them than half of what's on my shelves.",
		Answers = true,
		IfTrue = "Shiori_FoodThanks3"
	},
	Shiori_FoodThanks3 = {
		Text = "Come find me when the stores run low again.",
		Answers = true,
		IfTrue = exit
	},
	Shiori_Box = {
		Text = "That's the crate off the harbour boat. I'd almost given up on it.",
		Answers = {
			Close = exit,
			["Niko sent it up"] = "DeliverSupplyBoxToShiori"
		}
	},
	Shiori_BoxThanks = {
		Text = "Finally.",
		Answers = true,
		IfTrue = "Shiori_BoxThanks2"
	},
	Shiori_BoxThanks2 = {
		Text = `Half of what's in there I've been rationing for a week. Tell {nameTag("Estate Worker Niko")} I said thank you.`,
		Answers = true,
		IfTrue = exit
	},
	Shiori_NoBox = {
		Text = `You've come back with nothing. {nameTag("Estate Worker Niko")} still has the crate, up at the harbour.`,
		Answers = true,
		IfTrue = exit
	},
	Shiori_Short = {
		Text = "The crates aren't full yet.",
		Answers = true,
		IfTrue = exit
	},
	Shiori_Rumour = {
		Text = "Before you go. A woman came through last month with both hands bandaged to the wrist. Frostbite.",
		Answers = {
			Close = "",
			["What happened to her?"] = "WarFansClue1"
		}
	},
	Shiori_Rumour2 = {
		Text = "She would not say. Only that she had left something in the snow up north and meant to go back for it, hands or no hands.",
		Answers = true,
		IfTrue = "Shiori_Rumour3"
	},
	Shiori_Rumour3 = {
		Text = "She took the harbour road. Nobody leaves that town without someone writing it down.",
		Answers = true
	}
}