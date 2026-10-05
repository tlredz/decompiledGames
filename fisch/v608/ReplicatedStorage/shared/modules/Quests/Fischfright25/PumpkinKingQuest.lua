local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FischfrightSpotlight = require(ReplicatedStorage.shared.modules.FischfrightSpotlight)
local module = require("../../EventConfig/FischFright25")
return {
	PumpkinKing1 = {
		DisplayName = "Spotlight 1: Rune Tier (Pumpkin King)",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(209, 139, 55),
		QuestType = "Major",
		ExpiresAt = module.ExpiresAt,
		Description = `Harvest, carve, and give {FischfrightSpotlight.CacheInfo.GivenPumpkins.GoalValue} pumpkins away.`,
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.PumpkinKing1",
				true,
				(`Harvest, carve, and give {FischfrightSpotlight.CacheInfo.GivenPumpkins.GoalValue} pumpkins away.`)
			}
		},
		Rewards = {}
	},
	PumpkinKing2 = {
		DisplayName = "Spotlight 2: Key Tier (Pumpkin King)",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(209, 139, 55),
		QuestType = "Major",
		ExpiresAt = module.ExpiresAt,
		Description = `Catch {FischfrightSpotlight.CacheInfo.MutatedFishCatches.GoalValue} Spooky, Eerie, or Frightful, mutated Fischfright fish.`,
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.PumpkinKing2",
				true,
				(`Catch {FischfrightSpotlight.CacheInfo.MutatedFishCatches.GoalValue} Spooky, Eerie, or Frightful, mutated Fischfright fish.`)
			}
		},
		Rewards = {}
	}
}