local Realm = require(game.ReplicatedStorage.Util.Realm)
require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local IdMap = require(game.ReplicatedStorage.IdMap)
local effectTypes = {
	Money = {
		Stackable = true
	},
	Fragments = {
		Stackable = true
	},
	Material = {
		Stackable = true
	},
	Treasure = {
		Stackable = true
	},
	Enemy = {
		Stackable = true
	},
	["Lava Immunity"] = {
		Stackable = true
	},
	["Enemy Aggro"] = {
		Stackable = true
	},
	["PvE Damage"] = {
		Stackable = true
	},
	["PVP Disable"] = {
		Stackable = false
	},
	Teleport = {
		Stackable = false
	},
	Special = {
		Stackable = false
	}
}
local potions = {}

for k, v3 in pairs({
	["Fortune Elixir"] = {
		EffectType = "Money",
		Duration = 120,
		Stats = function(_)
			return {
				MoneyRate = {
					All = 0.2
				}
			}
		end
	},
	["Loot Seeker"] = {
		EffectType = "Treasure",
		Duration = 120
	},
	["Lava Potion"] = {
		EffectType = "Lava Immunity",
		Duration = 120,
		Stats = function(_)
			return {
				LavaImmunity = true
			}
		end
	},
	["Aggro Elixir"] = {
		EffectType = "Enemy Aggro",
		Duration = 120,
		Stats = function(_)
			return {
				EnemyAggro = true
			}
		end
	},
	["Berserkers Elixir"] = {
		EffectType = "PvE Damage",
		Duration = 120,
		Stats = function(_)
			return {
				PveDamage = {
					All = 0.1
				}
			}
		end
	},
	["Oni Soul"] = {
		EffectType = "PvE Damage",
		Duration = 120,
		Stats = function(_)
			return {
				OniSoul = true
			}
		end
	},
	["Monk Potion"] = {
		EffectType = "PVP Disable",
		Duration = 0.01,
		Stats = function(_)
			return {
				PVPTimerReset = true
			}
		end,
		Description = function(_)
			return (`Increases your PVP timer to {Realm.getCurrentRealmDifficultyAsync() == 1 and 15 or 10} minutes`)
		end
	},
	["Invisibility Potion"] = {
		EffectType = "Special",
		Duration = 120,
		Stats = function(_)
			return {
				InvisiblityPotion = true
			}
		end
	},
	["Gate Potion"] = {
		SaveToData = false,
		EffectType = "Teleport"
	},
	["Fragments Elixir"] = {
		EffectType = "Fragments",
		Duration = 600,
		Stats = function(_)
			return {
				FragmentRate = {
					All = 0.2
				}
			}
		end
	},
	["Materials Elixir"] = {
		EffectType = "Material",
		Duration = 600,
		Description = function(_)
			return (`Increases chances of an NPC dropping a material by {15}%`)
		end,
		Stats = function(_)
			return {
				DropRate = `{0.15}`
			}
		end
	},
	["Big Head Elixir"] = {
		EffectType = "Special",
		Duration = 0.01,
		IsThrowable = true
	},
	["Pumpkin Potion"] = {
		EffectType = "Special",
		Duration = 0.01,
		IsThrowable = true
	},
	["Disguise Elixir"] = {
		EffectType = "Special",
		Duration = 0.01,
		IsThrowable = true
	},
	["Lava Bomb Elixir"] = {
		EffectType = "Special",
		Duration = 0.01,
		IsThrowable = true
	},
	["Suspicious Growth Potion"] = {
		EffectType = "Special",
		Duration = 0.01,
		IsThrowable = true
	},
	["Monster Mash Elixir"] = {
		EffectType = "Special",
		Duration = 0.01,
		IsThrowable = true
	},
	["Candy Concoction"] = {
		EffectType = "Special",
		Duration = 0.01,
		StorableStack = 5,
		IsThrowable = true
	}
}) do
	assert(v3.EffectType, (`{k} is missing an effect type`))
	assert(effectTypes[v3.EffectType], (`{k} is missing an effect type in effectTypes`))
	local v4 = IdMap.Potion[k]
	local unwrapped = ItemConfig.match(v4):unwrap()
	local rarityValue = unwrapped.Quality.RarityValue
	assert(rarityValue, (`{k} is missing rarity`))
	local title = unwrapped.Display.Title or unwrapped.Display.Name or unwrapped.Index.StorageKey
	assert(title, (`{k} is missing DisplayName`))
	local maxStack = unwrapped.Inventory.MaxStack
	assert(maxStack, (`no maxStack configured for "{unwrapped.Index.DebugLabel}"`))
	local fn = unwrapped.Display.Description and function()
		return unwrapped.Display.Description
	end or v3.Description
	assert(fn, (`bad description for {k}`))
	local v6 = {
		StorageName = k,
		DisplayName = title,
		ToolName = v3.ToolName or k,
		Type = "Potion",
		EffectType = v3.EffectType,
		Description = fn,
		Rarity = rarityValue,
		Duration = v3.Duration,
		Cost = v3.Cost,
		Stats = v3.Stats,
		MaxStack = maxStack,
		StorableStack = v3.StorableStack or maxStack,
		SaveToData = true,
		IsThrowable = v3.IsThrowable
	}

	if v3.SaveToData ~= nil then
		v6.SaveToData = v3.SaveToData
	end

	potions[k] = v6
end

table.freeze(potions)
local Potions = {
	EffectTypes = effectTypes,
	Potions = potions,
	tryGetPotionFromStorageName = function(p: string)
		return potions[p]
	end,
	getPotionFromStorageName = function(p: string)
		return assert(potions[p])
	end
}
table.freeze(Potions)
return Potions