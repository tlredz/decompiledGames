local AccessoriesShared = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ItemConfig = require(script.Parent.ItemConfig)
local ItemId = require(ReplicatedStorage.Economy.ItemId)
require(ReplicatedStorage.Modules.Asset.RarityUtil.RarityData)
local Realm = require(ReplicatedStorage.Util.Realm)
local FormatUtil = require(ReplicatedStorage.React.FormatUtil)
local Type = require(ReplicatedStorage.Packages.Type)
local ItemReplicationService = require(ReplicatedStorage.ItemReplicationService)
require(script.Types)
local KEYS = require(ReplicatedStorage.ItemReplicationService.KEYS)
local v = {
	"Punchy",
	"Brutal",
	"Sharp",
	"Executioner",
	"Fruity",
	"Overcharged",
	"Precise",
	"Deadeye",
	"Piercing",
	"Element Slayer",
	"Beast Slayer",
	"Beast Hunter",
	"Ruthless",
	"Vampiric",
	"Sanguine",
	"Tanky",
	"Immortal",
	"Blunted",
	"Anti-Fruity",
	"Rocky",
	"Armored",
	"Hasty",
	"Windstep",
	"Levitating",
	"Airborne",
	"Focused",
	"Greedy",
	"Timebender",
	"Cracked",
	"Dull",
	"Broken",
	"Blunt",
	"Rusty",
	"Unstable",
	"Heavy",
	"Foggy",
	"Clumsy",
	"Wild"
}
table.freeze(v)
local literal = Type.literal(unpack(v))
local literal2 = Type.literal(
	"MeleePoints",
	"SwordPoints",
	"FruitPoints",
	"GunPoints",
	"IgnoreDefense",
	"ElementalDamage",
	"BeastDamage",
	"NPCDamage",
	"LifeSteal",
	"DefensePoints",
	"ReduceSwordDamage",
	"ReduceFruitDamage",
	"ReduceMeleeDamage",
	"ReduceAllPhysicalDamage",
	"WalkSpeed",
	"DashSpeed",
	"DashDistanceInAir",
	"JumpCount",
	"KenCapacity",
	"MoneyGain",
	"AllCooldownReduction"
)
local literal3 = Type.literal("Super", "Trinket")
local strictInterface = Type.strictInterface({
	Name = Type.string,
	Equipped = Type.boolean,
	Type = literal3,
	Grade = Type.intersection(Type.integer, Type.numberConstrained(0, 10)),
	Modifiers = Type.strict(literal)
})
local v2 = {
	[0] = 0,
	[1] = 0,
	[2] = 1500,
	[3] = 2250,
	[4] = 2800
}
local v3 = {
	[0] = 0,
	[1] = 160,
	[2] = 480,
	[3] = 1440,
	[4] = 4320
}
local v4 = {
	MeleeATK = "Melee",
	FruitATK = "Demon Fruit",
	SwordATK = "Sword",
	GunATK = "Gun",
	Defense = "Defense",
	HealthRegeneration = "HealthRegen"
}
local v5 = {
	MeleePoints = "Melee",
	SwordPoints = "Sword",
	FruitPoints = "Demon Fruit",
	GunPoints = "Gun",
	IgnoreDefense = "DefenseIgnore",
	ElementalDamage = "LogiaDamage>All",
	BeastDamage = "ZoanDamage>All",
	NPCDamage = "PveDamage>All",
	LifeSteal = "PveLeech>All",
	FruitPercent = "AllDamage>Fruit",
	DefensePoints = "Defense",
	ReduceSwordDamage = "AllResist>Sword",
	ReduceFruitDamage = "AllResist>Fruit",
	ReduceMeleeDamage = "AllResist>Melee",
	ReduceAllPhysicalDamage = "AllResist>Sword,AllResist>Melee,AllResist>Gun",
	WalkSpeed = "SpeedMultiplier",
	DashSpeed = "DashSpeed",
	DashDistanceInAir = "DashLengthAir",
	JumpCount = "SkyjumpBoost",
	KenCapacity = "DodgeBoost",
	MoneyGain = "MoneyRate",
	AllCooldownReduction = "AllCooldown"
}
local v6 = {
	"Ring of Might",
	"Ring of Spirit",
	"Ring of Twin Blades",
	"Ring of the Outlaw",
	"Ring of Steelheart",
	"Ring of the Arcanist"
}
local v7 = {
	"Punchy",
	"Brutal",
	"Sharp",
	"Executioner",
	"Fruity",
	"Overcharged",
	"Precise",
	"Deadeye",
	"Piercing",
	"Element Slayer",
	"Beast Hunter",
	"Beast Slayer",
	"Ruthless",
	"Vampiric",
	"Sanguine"
}
local v8 = {
	Damage = Color3.fromHex("882121"),
	Defense = Color3.fromHex("113A6F"),
	Utility = Color3.fromHex("277D5A"),
	Misc = Color3.fromHex("835F32")
}
local v9 = {}
local v10 = {}

local function addModifier(p, effects, category)
	if v10[p] ~= nil then
		error((`MODIFIER NAME DUPLICATION, "{p}" ALREADY EXISTS`))
	end

	v10[p] = {
		Effects = effects,
		Category = category
	}
end

local function addTrinket(p: string, stats)
	if v9[p] ~= nil then
		error((`TRINKET NAME DUPLICATION, "{p}" ALREADY EXISTS`))
	end

	v9[p] = {
		Stats = stats
	}
end

function _accessoryItemEq(data, data2)
	if not (data.Name == data2.Name and data.Equipped == data2.Equipped and data.Type == data2.Type and data.Grade == data2.Grade) then
		return false
	end

	if #data.Modifiers ~= #data2.Modifiers then
		return false
	end

	for i = 1, #data.Modifiers do
		if data.Modifiers[i] ~= data2.Modifiers[i] then
			return false
		end
	end

	return true
end

AccessoriesShared.EFFECT_MAPPINGS = v5
AccessoriesShared.STAT_MAPPINGS = v4
AccessoriesShared.MODIFIER_LIST = v
AccessoriesShared.Types = {
	AccessoryItem = strictInterface,
	AccessoryEffect = literal2,
	AccessoryType = literal3
}

function AccessoriesShared.GetCategoryColor(p)
	return v8[p]
end

function AccessoriesShared.GetReforgeCost()
	return 2000
end

function AccessoriesShared.GetAllModifiers()
	local modifierDatas = {}

	for _, v11 in v7 do
		local modifierData = AccessoriesShared.GetModifierData(v11)

		if modifierData then
			modifierDatas[v11] = modifierData
		end
	end

	return modifierDatas
end

function AccessoriesShared.GetAllTrinkets()
	local trinketDatas = {}

	for _, v11 in v6 do
		local trinketData = AccessoriesShared.GetTrinketData(v11)

		if trinketData then
			trinketDatas[v11] = trinketData
		end
	end

	return trinketDatas
end

function AccessoriesShared.GetAllTrinketNames()
	local result = {}

	for k in v9 do
		table.insert(result, k)
	end

	table.sort(result)
	return result
end

function AccessoriesShared.GetLevelRequirementFromGrade(p: number)
	local v11 = v2[p]
	assert(v11, (`unspecified level requirement for grade "{p}"`))
	return v11
end

function AccessoriesShared.GetTrinketData(p: string)
	return v9[p]
end

function AccessoriesShared.GetModifierData(p)
	return v10[p]
end

function AccessoriesShared.GetGradeSuffix(p: number)
	return FormatUtil.romanNumeral(p)
end

function AccessoriesShared.GetDataReward(items)
	local total = 0

	for _, item in items do
		local v11 = v3[item.Grade]

		if v11 then
			total += v11
		end

		total += #item.Modifiers * 80
	end

	return total
end

function AccessoriesShared.GetBuffsForItem(data, flag: boolean?)
	local result = {}
	local trinketData = AccessoriesShared.GetTrinketData(data.Name)

	if not trinketData then
		return result
	end

	local stat = trinketData.Stats[data.Grade]

	if stat then
		for k, v11 in stat do
			local v12 = v4[k]

			if not v12 then
				continue
			end

			for _, v13 in string.split(v12, ",") do
				local v14, v15 = unpack(string.split(v13, ">"))

				if v15 == nil or flag == true then
					local v16 = result[v14]
					assert(typeof(v16) ~= "table", "bad retValue")
					result[v12] = (v16 or 0) + v11
				else
					if result[v14] == nil then
						result[v14] = {}
					end

					local v16 = result[v14]
					assert(typeof(v16) == "table", "bad retValue")
					v16[v15] = (v16[v15] or 0) + v11
				end
			end
		end
	end

	local currentSeaAsync = Realm.getCurrentSeaAsync()

	for _, modifier in data.Modifiers do
		local modifierData = AccessoriesShared.GetModifierData(modifier)

		if not modifierData then
			continue
		end

		for k, effect in modifierData.Effects do
			local v11 = effect[currentSeaAsync] or effect.Sea3
			local v12 = v5[k]

			if not v12 then
				continue
			end

			for _, v13 in string.split(v12, ",") do
				local v14, v15 = unpack(string.split(v13, ">"))

				if v15 == nil or flag == true then
					local v16 = result[v14]
					assert(typeof(v16) ~= "table", "bad retValue")
					result[v12] = (v16 or 0) + v11
				else
					if result[v14] == nil then
						result[v14] = {}
					end

					local v16 = result[v14]
					assert(typeof(v16) == "table", "bad retValue")
					v16[v15] = (v16[v15] or 0) + v11
				end
			end
		end
	end

	return result
end

function AccessoriesShared.getItemId(p: string, p2: number)
	if p2 > 0 then
		p ..= " " .. FormatUtil.romanNumeral(p2)
	end

	return (ItemId.getId(p, "Accessory"):asNullable())
end

function AccessoriesShared.getBaseTrinketName(p: number, p2: number)
	local unwrapped = ItemConfig.match(p):unwrap()
	local v11 = " " .. FormatUtil.romanNumeral(p2)
	local v12 = unwrapped.Index.StorageKey:sub(1, unwrapped.Index.StorageKey:len() - v11:len())
	local v13 = unwrapped.Index.StorageKey:sub(unwrapped.Index.StorageKey:len() - v11:len() + 1)

	if v11 ~= v13 then
		return nil
	end

	assert(v13 == v11, (`suffix mismatch, target="{v11}", actual="{v13}"`))
	return v12
end

function AccessoriesShared.getReplicatedAccessoryItem(p: number, p2: string)
	assert(RunService:IsClient(), "getReplicatedAccessoryItem can only be called from the client")
	assert(
		ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT,
		"ItemReplicationService isn't initialized"
	)
	local item = ItemReplicationService:ReadItem(KEYS.ACCESSORY_TYPE, p, p2)

	if not item then
		return
	end

	local unwrapped = ItemConfig.match(p):unwrap()
	local equipped = ItemReplicationService:ReadItem(KEYS.IS_EQUIPPED, p, p2) == true

	if item == "Trinket" then
		local item2 = ItemReplicationService:ReadItem(KEYS.ACCESSORY_GRADE, p, p2)

		if not item2 then
			return
		end

		local item3 = ItemReplicationService:ReadItem(KEYS.ACCESSORY_MODIFIERS, p, p2)

		if not item3 then
			return
		end

		local v12 = " " .. FormatUtil.romanNumeral(item2)
		local name = unwrapped.Index.StorageKey:sub(1, unwrapped.Index.StorageKey:len() - v12:len())
		local v14 = unwrapped.Index.StorageKey:sub(unwrapped.Index.StorageKey:len() - v12:len() + 1)
		assert(v14 == v12, (`suffix mismatch, target="{v12}", actual="{v14}"`))
		local v15 = {
			Name = name,
			Type = item,
			Grade = item2,
			Modifiers = item3 == "" and {} or item3:split(","),
			Equipped = equipped
		}
		table.freeze(v15.Modifiers)
		table.freeze(v15)
		return v15
	else
		if item ~= "Super" then
			error((`unknown accessory type: {item}`))
			return
		end

		local v12 = {
			Name = unwrapped.Index.StorageKey,
			Type = item,
			Grade = 0,
			Modifiers = {},
			Equipped = equipped
		}
		table.freeze(v12.Modifiers)
		table.freeze(v12)
		return v12
	end
end

function AccessoriesShared.ReplicateItem(p, p2: number, p3: string, data, flag: boolean?, flag2: boolean?)
	assert(RunService:IsServer(), "ReplicateItem can only be called from the server")
	assert(
		ItemReplicationService.IsInitialized and ItemReplicationService.IS_SERVER,
		"ItemReplicationService isn't initialized"
	)
	local fn

	if flag2 then
		fn = function(...)
			ItemReplicationService:CommitItem(...)
		end
	elseif flag then
		fn = function(...)
			ItemReplicationService:ReplicateItemAsync(...)
		end
	else
		fn = function(...)
			ItemReplicationService:ReplicateItem(...)
		end
	end

	local ACCESSORY_GRADE = KEYS.ACCESSORY_GRADE
	local v11

	if data and data.Type == "Trinket" then
		v11 = data.Grade or nil
	end

	fn(p, ACCESSORY_GRADE, p2, p3, v11)
	local ACCESSORY_TYPE = KEYS.ACCESSORY_TYPE
	local v12

	if data then
		v12 = data.Type or nil
	end

	fn(p, ACCESSORY_TYPE, p2, p3, v12)
	fn(p, KEYS.ACCESSORY_MODIFIERS, p2, p3, data and table.concat(data.Modifiers, ",") or nil)
end

function AccessoriesShared.Replicate(p, items, flag: boolean?, flag2: boolean?)
	assert(RunService:IsServer(), "Replicate can only be called from the server")
	assert(
		ItemReplicationService.IsInitialized and ItemReplicationService.IS_SERVER,
		"ItemReplicationService isn't initialized"
	)

	if items then
		for k, item in items do
			local itemId = AccessoriesShared.getItemId(item.Name, item.Grade)

			if itemId then
				AccessoriesShared.ReplicateItem(p, itemId, k, item, flag, flag2)
			else
				warn((`Could not find item ID for accessory {item.Name} grade {item.Grade}`))
			end
		end
	end

	local itemIdsByNetworkedUID = {}
	local items2 = ItemReplicationService:GetItems(p.UserId, ItemReplicationService.KEYS.ACCESSORY_TYPE)

	if items2 then
		for _, item in items2 do
			local networkedUID = item.NetworkedUID
			assert(networkedUID, (`bad UID in accessories: {item.ItemId}`))

			if items == nil or items[networkedUID] == nil then
				itemIdsByNetworkedUID[networkedUID] = item.ItemId
			end
		end
	end

	for k, v11 in itemIdsByNetworkedUID do
		AccessoriesShared.ReplicateItem(p, v11, k, nil, flag, flag2)
	end
end

function AccessoriesShared.GetItemRarity(p: string, p2: number)
	local nullable = ItemId.getId(`{p} {AccessoriesShared.GetGradeSuffix(p2)}`, "Accessory"):asNullable()

	if nullable == nil then
		return nil
	end

	local v11 = ItemConfig.tryGet(nullable)

	if v11 == nil then
		return nil
	end

	return v11.Quality.Rarity
end

if v9["Ring of Striking"] ~= nil then
	error("TRINKET NAME DUPLICATION, \"Ring of Striking\" ALREADY EXISTS")
end

v9["Ring of Striking"] = {
	Stats = {
		{
			MeleeATK = 25
		},
		{
			MeleeATK = 45
		},
		{
			MeleeATK = 75
		},
		{
			MeleeATK = 75
		}
	}
}

if v9["Ring of Carving"] ~= nil then
	error("TRINKET NAME DUPLICATION, \"Ring of Carving\" ALREADY EXISTS")
end

v9["Ring of Carving"] = {
	Stats = {
		{
			SwordATK = 25
		},
		{
			SwordATK = 45
		},
		{
			SwordATK = 75
		},
		{
			SwordATK = 75
		}
	}
}

if v9["Ring of the Outlaw"] ~= nil then
	error("TRINKET NAME DUPLICATION, \"Ring of the Outlaw\" ALREADY EXISTS")
end

v9["Ring of the Outlaw"] = {
	Stats = {
		{
			GunATK = 25,
			SwordATK = 25
		},
		{
			GunATK = 50,
			SwordATK = 50
		},
		{
			GunATK = 75,
			SwordATK = 75
		},
		{
			GunATK = 75,
			SwordATK = 75
		}
	}
}

if v9["Ring of Essence"] ~= nil then
	error("TRINKET NAME DUPLICATION, \"Ring of Essence\" ALREADY EXISTS")
end

v9["Ring of Essence"] = {
	Stats = {
		{
			FruitATK = 25
		},
		{
			FruitATK = 45
		},
		{
			FruitATK = 75
		},
		{
			FruitATK = 75
		}
	}
}

if v9["Ring of Spirit"] ~= nil then
	error("TRINKET NAME DUPLICATION, \"Ring of Spirit\" ALREADY EXISTS")
end

v9["Ring of Spirit"] = {
	Stats = {
		{
			FruitATK = 10,
			MeleeATK = 20
		},
		{
			FruitATK = 20,
			MeleeATK = 40
		},
		{
			FruitATK = 35,
			MeleeATK = 60
		},
		{
			FruitATK = 35,
			MeleeATK = 60
		}
	}
}

if v9["Ring of Might"] ~= nil then
	error("TRINKET NAME DUPLICATION, \"Ring of Might\" ALREADY EXISTS")
end

v9["Ring of Might"] = {
	Stats = {
		{
			MeleeATK = 10,
			SwordATK = 20
		},
		{
			MeleeATK = 20,
			SwordATK = 40
		},
		{
			MeleeATK = 35,
			SwordATK = 60
		},
		{
			MeleeATK = 35,
			SwordATK = 60
		}
	}
}

if v9["Ring of the Vanguard"] ~= nil then
	error("TRINKET NAME DUPLICATION, \"Ring of the Vanguard\" ALREADY EXISTS")
end

v9["Ring of the Vanguard"] = {
	Stats = {
		{
			Defense = 20,
			MeleeATK = 30
		},
		{
			Defense = 40,
			MeleeATK = 60
		},
		{
			Defense = 60,
			MeleeATK = 90
		},
		{
			Defense = 60,
			MeleeATK = 90
		}
	}
}

if v9["Ring of Renewal"] ~= nil then
	error("TRINKET NAME DUPLICATION, \"Ring of Renewal\" ALREADY EXISTS")
end

v9["Ring of Renewal"] = {
	Stats = {
		{
			HealthRegeneration = 0.1
		},
		{
			HealthRegeneration = 0.2
		},
		{
			HealthRegeneration = 0.35
		},
		{
			HealthRegeneration = 0.35
		}
	}
}

if v9["Ring of the Arcanist"] ~= nil then
	error("TRINKET NAME DUPLICATION, \"Ring of the Arcanist\" ALREADY EXISTS")
end

v9["Ring of the Arcanist"] = {
	Stats = {
		{
			FruitATK = 30,
			Defense = 20
		},
		{
			FruitATK = 60,
			Defense = 40
		},
		{
			FruitATK = 90,
			Defense = 60
		},
		{
			FruitATK = 90,
			Defense = 60
		}
	}
}

if v9["Ring of Twin Blades"] ~= nil then
	error("TRINKET NAME DUPLICATION, \"Ring of Twin Blades\" ALREADY EXISTS")
end

v9["Ring of Twin Blades"] = {
	Stats = {
		{
			FruitATK = 25,
			SwordATK = 25
		},
		{
			FruitATK = 50,
			SwordATK = 50
		},
		{
			FruitATK = 75,
			SwordATK = 75
		},
		{
			FruitATK = 75,
			SwordATK = 75
		}
	}
}

if v9["Ring of Steelheart"] ~= nil then
	error("TRINKET NAME DUPLICATION, \"Ring of Steelheart\" ALREADY EXISTS")
end

v9["Ring of Steelheart"] = {
	Stats = {
		{
			GunATK = 30,
			FruitATK = 20
		},
		{
			GunATK = 60,
			FruitATK = 40
		},
		{
			GunATK = 90,
			FruitATK = 60
		},
		{
			GunATK = 90,
			FruitATK = 60
		}
	}
}

if v10.Punchy ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Punchy\" ALREADY EXISTS")
end

v10.Punchy = {
	Effects = {
		MeleePoints = {
			Sea1 = 60,
			Sea2 = 60,
			Sea3 = 60
		}
	},
	Category = "Damage"
}

if v10.Brutal ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Brutal\" ALREADY EXISTS")
end

v10.Brutal = {
	Effects = {
		MeleePoints = {
			Sea1 = 120,
			Sea2 = 120,
			Sea3 = 120
		}
	},
	Category = "Damage"
}

if v10.Sharp ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Sharp\" ALREADY EXISTS")
end

v10.Sharp = {
	Effects = {
		SwordPoints = {
			Sea1 = 60,
			Sea2 = 60,
			Sea3 = 60
		}
	},
	Category = "Damage"
}

if v10.Executioner ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Executioner\" ALREADY EXISTS")
end

v10.Executioner = {
	Effects = {
		SwordPoints = {
			Sea1 = 120,
			Sea2 = 120,
			Sea3 = 120
		}
	},
	Category = "Damage"
}

if v10.Precise ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Precise\" ALREADY EXISTS")
end

v10.Precise = {
	Effects = {
		GunPoints = {
			Sea1 = 60,
			Sea2 = 60,
			Sea3 = 60
		}
	},
	Category = "Damage"
}

if v10.Deadeye ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Deadeye\" ALREADY EXISTS")
end

v10.Deadeye = {
	Effects = {
		GunPoints = {
			Sea1 = 120,
			Sea2 = 120,
			Sea3 = 120
		}
	},
	Category = "Damage"
}

if v10.Tanky ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Tanky\" ALREADY EXISTS")
end

v10.Tanky = {
	Effects = {
		DefensePoints = {
			Sea1 = 150,
			Sea2 = 150,
			Sea3 = 150
		}
	},
	Category = "Defense"
}

if v10.Immortal ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Immortal\" ALREADY EXISTS")
end

v10.Immortal = {
	Effects = {
		DefensePoints = {
			Sea1 = 200,
			Sea2 = 200,
			Sea3 = 200
		}
	},
	Category = "Defense"
}

if v10.Fruity ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Fruity\" ALREADY EXISTS")
end

v10.Fruity = {
	Effects = {
		FruitPercent = {
			Sea1 = 0.04,
			Sea2 = 0.04,
			Sea3 = 0.04
		}
	},
	Category = "Damage"
}

if v10.Overcharged ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Overcharged\" ALREADY EXISTS")
end

v10.Overcharged = {
	Effects = {
		FruitPercent = {
			Sea1 = 0.06,
			Sea2 = 0.06,
			Sea3 = 0.06
		}
	},
	Category = "Damage"
}

if v10.Piercing ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Piercing\" ALREADY EXISTS")
end

v10.Piercing = {
	Effects = {
		IgnoreDefense = {
			Sea1 = 0.1,
			Sea2 = 0.1,
			Sea3 = 0.1
		}
	},
	Category = "Damage"
}

if v10["Element Slayer"] ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Element Slayer\" ALREADY EXISTS")
end

v10["Element Slayer"] = {
	Effects = {
		ElementalDamage = {
			Sea1 = 0.05,
			Sea2 = 0.05,
			Sea3 = 0.05
		}
	},
	Category = "Damage"
}

if v10["Beast Slayer"] ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Beast Slayer\" ALREADY EXISTS")
end

v10["Beast Slayer"] = {
	Effects = {
		BeastDamage = {
			Sea1 = 0.07,
			Sea2 = 0.07,
			Sea3 = 0.07
		}
	},
	Category = "Damage"
}

if v10["Beast Hunter"] ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Beast Hunter\" ALREADY EXISTS")
end

v10["Beast Hunter"] = {
	Effects = {
		BeastDamage = {
			Sea1 = 0.1,
			Sea2 = 0.1,
			Sea3 = 0.1
		}
	},
	Category = "Damage"
}

if v10.Ruthless ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Ruthless\" ALREADY EXISTS")
end

v10.Ruthless = {
	Effects = {
		NPCDamage = {
			Sea1 = 0.07,
			Sea2 = 0.07,
			Sea3 = 0.07
		}
	},
	Category = "Damage"
}

if v10.Vampiric ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Vampiric\" ALREADY EXISTS")
end

v10.Vampiric = {
	Effects = {
		LifeSteal = {
			Sea1 = 0.02,
			Sea2 = 0.02,
			Sea3 = 0.02
		}
	},
	Category = "Misc"
}

if v10.Sanguine ~= nil then
	error("MODIFIER NAME DUPLICATION, \"Sanguine\" ALREADY EXISTS")
end

v10.Sanguine = {
	Effects = {
		LifeSteal = {
			Sea1 = 0.04,
			Sea2 = 0.04,
			Sea3 = 0.04
		}
	},
	Category = "Misc"
}
return AccessoriesShared