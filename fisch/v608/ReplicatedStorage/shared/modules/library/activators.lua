local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Signal = require(packages:WaitForChild("Signal"))
local Activators = {
	Hexed = {
		Type = "Client",
		PlaceableItems = { "Enchant Relic" },
		SubValues = {
			Mutation = "Hexed"
		}
	},
	Abyssal = {
		Type = "Client",
		PlaceableItems = { "Enchant Relic" },
		SubValues = {
			Mutation = "Abyssal"
		}
	},
	Chaotic = {
		Type = "Client",
		PlaceableItems = { "Enchant Relic" },
		SubValues = {
			Mutation = "Chaotic"
		}
	},
	Hexed_Exalted = {
		Type = "Client",
		PlaceableItems = { "Enchant Relic" },
		SubValues = {
			Mutation = "Hexed"
		},
		LevelRequirement = 150
	},
	Crystalized_Exalted = {
		Type = "Client",
		PlaceableItems = { "Enchant Relic" },
		SubValues = {
			Mutation = "Crystalized"
		},
		LevelRequirement = 150
	},
	Greedy_Exalted = {
		Type = "Client",
		PlaceableItems = { "Enchant Relic" },
		SubValues = {
			Mutation = "Greedy"
		},
		LevelRequirement = 150
	},
	Translucent_Exalted = {
		Type = "Client",
		PlaceableItems = { "Enchant Relic" },
		SubValues = {
			Mutation = "Translucent"
		},
		LevelRequirement = 150
	},
	Atlantean_Exalted = {
		Type = "Client",
		PlaceableItems = { "Enchant Relic" },
		SubValues = {
			Mutation = "Atlantean"
		},
		LevelRequirement = 150
	},
	Fossilized_Exalted = {
		Type = "Client",
		PlaceableItems = { "Enchant Relic" },
		SubValues = {
			Mutation = "Fossilized"
		},
		LevelRequirement = 150
	},
	Mosaic_Exalted = {
		Type = "Client",
		PlaceableItems = { "Enchant Relic" },
		SubValues = {
			Mutation = "Mosaic"
		},
		LevelRequirement = 150
	}
}

if RunService:IsServer() then
	for _, v in Activators do
		v.OnActivated = Signal.new()
	end
end

return Activators