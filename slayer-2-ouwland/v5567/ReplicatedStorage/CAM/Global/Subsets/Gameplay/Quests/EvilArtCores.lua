local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parentModule = require(script.Parent)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local EvilArtCores = {
	MIZUNOTO_TASK = "Defeat Mizunotos",
	MIZUNOTO_COUNT = 5,
	POWERUP_TIME = 1.6666666666666667
}
local v = {
	Meditate = "Meditation",
	["Push ups"] = "Pushups",
	["Aim Training"] = "Target Shooting",
	["Cup Training"] = "Cup Game",
	["Barbell squats"] = "Squat",
	["Boulder Push"] = "Boulder Push",
	["Boulder Split"] = "Boulder Split"
}
EvilArtCores.Trainings = {
	Arrow = { "Meditate", "Aim Training", "Boulder Push" },
	Reaper = { "Cup Training", "Aim Training", "Boulder Split" },
	Cryokinesis = { "Meditate", "Boulder Split", "Underwater Rocks" },
	Shockwave = {
		"Push ups",
		"Barbell squats",
		"Boulder Push",
		"Boulder Split"
	},
	["Blood Manipulation"] = { "Cup Training", "Push ups", "Aim Training" },
	Tamari = { "Cup Training", "Push ups", "Boulder Split" },
	["Obi Manipulation"] = { "Barbell squats", "Boulder Push", "Boulder Split" },
	Dream = { "Meditate", "Cup Training", "Aim Training" },
	Pyrokenesis = { "Push ups", "Boulder Push", "Aim Training" }
}

function EvilArtCores.QuestName(p: string)
	return (`{p} Core Training`)
end

function EvilArtCores.Key(p: string)
	return (`I will train my {p} core`)
end

function EvilArtCores.Definitions()
	local underwaterRockSpot = gameSettings.UnderwaterRockSpots[game.PlaceId]
	local result = {}

	for k, training in EvilArtCores.Trainings do
		local v2 = {}
		local v3 = nil
		local taskSpecs = {}

		for _, v5 in training do
			if v5 == "Underwater Rocks" then
				if underwaterRockSpot == nil then
					warn((`EvilArtCores: this place has no UnderwaterRockSpots, "{"Underwater Rocks"}" skipped for {k}`))
					continue
				else
					table.insert(v2, parentModule.QuestTask("Underwater Rocks", #underwaterRockSpot, nil, v3))
					taskSpecs["Underwater Rocks"] = {
						Type = "Pickup",
						Positions = underwaterRockSpot
					}
				end
			else
				local v6 = v[v5]

				if v6 == nil then
					warn((`EvilArtCores: "{v5}" is not a training station, skipped for {k}`))
					continue
				else
					table.insert(v2, parentModule.QuestTask(v5, 1, v6, v3))
				end
			end

			v3 = v5
		end

		table.insert(
			v2,
			parentModule.QuestTask(
				EvilArtCores.MIZUNOTO_TASK,
				EvilArtCores.MIZUNOTO_COUNT,
				"Mizunoto_MistfallHarbor",
				v3
			)
		)
		local key = EvilArtCores.Key(k)
		result[key] = {
			OfferNpc = false,
			QuestInstance = parentModule.Quest(EvilArtCores.QuestName(k), v2),
			Rewards = {
				Exp = 900,
				Wen = 405,
				Power = k
			},
			Requirements = {
				Race = { "Demon", "Hybrid" }
			},
			Category = "Muzan",
			CompletionNotify = {
				Icon = BunchaIcons.MuzanIcon,
				Text = "You've proven yourself."
			},
			TaskSpecs = taskSpecs,
			Markers = {
				[EvilArtCores.MIZUNOTO_TASK] = {
					Npc = "Mizunoto"
				}
			}
		}
	end

	return result
end

return EvilArtCores