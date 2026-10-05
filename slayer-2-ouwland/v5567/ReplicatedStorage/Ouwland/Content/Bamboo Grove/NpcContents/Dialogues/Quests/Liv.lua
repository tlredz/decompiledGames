local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

local function randomCoinSpot(_: number)
	for _ = 1, 10 do
		local v = math.random() * 2 * 3.141592653589793
		local v2 = math.sqrt((math.random())) * 15
		local vector2 = Vector3.new(math.cos(v) * v2 + 675, 1018.7000122070312, math.sin(v) * v2 + 134)
		local raycastResult = workspace:Raycast(
			vector2 + createVector(0, 10, 0),
			createVector(0, -50, 0),
			raycastParams
		)

		if raycastResult ~= nil then
			return raycastResult.Position
		end
	end

	return nil
end

return {
	["Ill look for the penny(Lv 14)"] = {
		QuestInstance = Quests.Quest("Find the Lucky Penny", Quests.QuestTask("Lucky Penny found", 1)),
		Rewards = {
			Exp = 840,
			Wen = 75
		},
		Requirements = {
			Level = 14
		},
		Category = "Dialogue",
		LogCompletion = true,
		CompletionNotify = {
			Npc = "Liv",
			Text = "Ah, you found it! Awesome, thanks kid. Here's a little something for your time.",
			Duration = 4
		},
		TaskSpecs = {
			["Lucky Penny found"] = {
				Type = "Pickup",
				Positions = { createVector(554.5, 1010.55, -214.5) }
			}
		}
	},
	["Ill find the coins(Lv 21)"] = {
		QuestInstance = Quests.Quest("Five Hundred Pennies", Quests.QuestTask("Coins collected", 500)),
		Rewards = {
			Exp = 2280,
			Wen = 270
		},
		Requirements = {
			Level = 21
		},
		Category = "Dialogue",
		LogCompletion = true,
		CompletionNotify = {
			Npc = "Liv",
			Text = "Wow... you actually did it. Alright kid, you've earned yourself a bet. Come talk to me.",
			Duration = 4
		},
		Markers = {
			["Coins collected"] = {
				Icon = BunchaIcons.Coin,
				Position = createVector(675, 1024.7, 134)
			}
		},
		TaskSpecs = {
			["Coins collected"] = {
				Type = "Pickup",
				Positions = randomCoinSpot,
				SpawnCount = 12,
				RespawnTime = 0,
				Anchor = createVector(675, 1018.7, 134),
				Radius = 15
			}
		}
	}
}