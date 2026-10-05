local RunService = game:GetService("RunService")
local v = {
	EventActive = true
}

if RunService:IsStudio() then
	v.EventActive = true
end

v.TokenEnum = table.freeze({
	StandardToken = "Rune Tier",
	EliteToken = "Key Tier"
})
v.CollectionServiceEnum = table.freeze({
	SpotlightPumpkin = "SpotlightPumpkin",
	CarvingStation = "CarvingStation",
	SpotlightNpc = "SpotlightNpc"
})
v.CacheEnum = table.freeze({
	CollectedPumpkins = "CollectedPumpkins",
	CarvedPumpkins = "CarvedPumpkins",
	GivenPumpkins = "GivenPumpkins",
	ObtainedSpookyRod = "ObtainedSpookyRod",
	MutatedFishCatches = "MutatedFishCatches"
})
v.Rewards = table.freeze({
	[v.TokenEnum.StandardToken] = {
		{
			ItemName = "Classic Pumpkin",
			ItemType = "Boat"
		},
		{
			ItemName = "Jack's Treads",
			ItemType = "Item"
		},
		{
			ItemName = "Pumpkin Gatherer",
			ItemType = "Title"
		}
	},
	[v.TokenEnum.EliteToken] = {
		{
			ItemName = "Ghosdeeri",
			ItemType = "Boat"
		},
		{
			ItemName = "Bat Glider",
			ItemType = "Item"
		},
		{
			ItemName = "Hollowmaker",
			ItemType = "Title"
		}
	}
})
v.CacheInfo = table.freeze({
	CarvedPumpkins = {
		StartValue = 0,
		GoalValue = 3
	},
	GivenPumpkins = {
		StartValue = 0,
		GoalValue = 3
	},
	CollectedPumpkins = {
		StartValue = 0,
		GoalValue = 3
	},
	ObtainedSpookyRod = {
		StartValue = false,
		GoalValue = true
	},
	MutatedFishCatches = {
		StartValue = 0,
		GoalValue = 5
	}
})
v.TokenToCache = table.freeze({
	[v.TokenEnum.StandardToken] = { "CollectedPumpkins", "CarvedPumpkins", "GivenPumpkins" },
	[v.TokenEnum.EliteToken] = { "MutatedFishCatches" }
})
return table.freeze(v)