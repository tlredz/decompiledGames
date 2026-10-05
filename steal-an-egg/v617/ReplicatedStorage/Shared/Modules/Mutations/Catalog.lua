require(script.Parent.Types)
local Visuals = require(script.Parent.Visuals)
local ScrambledVisuals = require(script.Parent.ScrambledVisuals)
local v = {
	Silver = {
		Id = "Silver",
		Label = "Silver",
		Tint = Color3.fromRGB(192, 192, 192),
		EarningsScalar = 1.2,
		RollWeight = 6,
		IconAssetId = 108639493197858,
		Apply = function(_, p, p2)
			Visuals.ApplySilver(p, p2)
		end,
		Clear = function(_, p, p2)
			Visuals.ClearSilver(p, p2)
		end
	},
	Golden = {
		Id = "Golden",
		Label = "Golden",
		Tint = Color3.fromRGB(251, 255, 0),
		EarningsScalar = 2.5,
		RollWeight = 4,
		IconAssetId = 134818382291054,
		Apply = function(_, p, p2)
			Visuals.ApplyGolden(p, p2)
		end,
		Clear = function(_, p, p2)
			Visuals.ClearGolden(p, p2)
		end
	},
	Rainbow = {
		Id = "Rainbow",
		Label = "Rainbow",
		Tint = Color3.fromRGB(255, 0, 255),
		EarningsScalar = 3.5,
		RollWeight = 1,
		IconAssetId = 85288683002868,
		Apply = function(_, p, p2)
			Visuals.ApplyRainbow(p, p2)
		end,
		Clear = function(_, p, p2)
			Visuals.ClearRainbow(p, p2)
		end
	},
	Monstrous = {
		Id = "Monstrous",
		Label = "Parasite",
		Tint = Color3.fromRGB(65, 21, 138),
		EarningsScalar = 3,
		RollWeight = 0,
		EggModelName = "Monstrous Egg",
		EggDisplayName = "Parasite Egg",
		EggIcon = "rbxassetid://121553987798547",
		Apply = function(p, p2, p3)
			Visuals.ApplyBloom(p2, p3, "Monstrous", "Cleanup_Monstrous", p.Tint, 0.5)
		end,
		Clear = function(_, p, p2)
			Visuals.ClearBloom(p, p2, "Cleanup_Monstrous")
		end
	},
	Boss = {
		Id = "Boss",
		Label = "Fractured",
		Tint = Color3.fromRGB(8, 8, 8),
		EarningsScalar = 2.75,
		RollWeight = 0,
		EggDisplayName = "Boss Egg",
		EggIcon = "rbxassetid://112428238095917",
		Apply = function(_, p, p2)
			Visuals.ApplyBlack(p, p2, "Boss", "Cleanup_Fractured")
		end,
		Clear = function(_, p, p2)
			Visuals.ClearBlack(p, p2)
		end
	},
	Scrambled = {
		Id = "Scrambled",
		Label = "Scrambled Mutation",
		Tint = Color3.fromRGB(96, 220, 82),
		EarningsScalar = 2.75,
		RollWeight = 0,
		IconAssetId = 134710848063255,
		Apply = function(p, p2, p3)
			Visuals.ApplyTint(p2, p.Tint, 0.65)
			ScrambledVisuals.Apply(p2, p3)
		end,
		Clear = function(_, p, _)
			Visuals.ClearTint(p)
			ScrambledVisuals.Clear(p)
		end
	},
	Sakura = {
		Id = "Sakura",
		Label = "Bloom",
		Tint = Color3.fromRGB(255, 196, 222),
		EarningsScalar = 1.25,
		RollWeight = 0,
		IconAssetId = 71612969542341,
		Apply = function(p, p2, p3)
			Visuals.ApplyBloom(p2, p3, "Sakura", "Cleanup_Sakura", p.Tint)
		end,
		Clear = function(_, p, p2)
			Visuals.ClearBloom(p, p2, "Cleanup_Sakura")
		end
	},
	GreatBloom = {
		Id = "GreatBloom",
		Label = "Spirit Bloom",
		Tint = Color3.fromRGB(60, 255, 140),
		EarningsScalar = 2.5,
		RollWeight = 0,
		IconAssetId = 70859376044018,
		Apply = function(p, p2, p3)
			Visuals.ApplyBloom(p2, p3, "GreatBloom", "Cleanup_GreatBloom", p.Tint)
		end,
		Clear = function(_, p, p2)
			Visuals.ClearBloom(p, p2, "Cleanup_GreatBloom")
		end
	}
}

for _, list in v do
	table.freeze(list)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
return require(ReplicatedStorage.Shared.Flags.BalanceConfig).Bind("Game.Balance.Mutations", v, {
	EarningsScalar = true,
	RollWeight = true
}, true, function(items)
	local total = 0

	for _, item in items do
		total += item.RollWeight
	end

	assert(total < 100)
end)