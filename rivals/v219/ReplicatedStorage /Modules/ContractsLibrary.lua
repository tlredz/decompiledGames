local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatisticsLibrary = require(ReplicatedStorage.Modules.StatisticsLibrary)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
require(ReplicatedStorage.Modules.DuelLibrary)
require(ReplicatedStorage.Modules.ItemLibrary)
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local v = {
	["Assault Rifle"] = { "Blue", "Desert Camo", "Chibi Assault Rifle" },
	Bow = { "Red", "Forest Camo", "Chibi Bow" },
	["Burst Rifle"] = { "Orange", "Arctic Camo", "Chibi Burst Rifle" },
	Flamethrower = { "Maize", "Scorched", "Chibi Flamethrower" },
	["Grenade Launcher"] = { "Surge", "Glass", "Chibi Grenade Launcher" },
	Minigun = { "Spartan", "Malevolent", "Chibi Minigun" },
	["Paintball Gun"] = { "Medium stone grey", "Omnisand", "Chibi Paintball Gun" },
	RPG = { "Teal", "Swirls", "Chibi RPG" },
	Shotgun = { "Purple", "Reptile", "Chibi Shotgun" },
	Sniper = { "Blush", "Patriot", "Chibi Sniper" },
	["Flare Gun"] = { "Green", "PB & J", "Chibi Flare Gun" },
	Handgun = { "Yellow", "Digital Camo", "Chibi Handgun" },
	Exogun = { "Vile", "Quasar", "Chibi Exogun" },
	Revolver = { "Mint", "Street Camo", "Chibi Revolver" },
	Shorty = { "Sky", "Steel", "Chibi Shorty" },
	Slingshot = { "Studs", "Hesper", "Chibi Slingshot" },
	Uzi = { "Lemon", "Ocean Camo", "Chibi Uzi" },
	Chainsaw = { "Olive", "Circuit", "Chibi Chainsaw" },
	Fists = { "Salmon", "Rug", "Chibi Fists" },
	Katana = { "Crimson", "Clouds", "Chibi Katana" },
	Knife = { "Highlighter", "Urban Camo", "Chibi Knife" },
	Scythe = { "Navy", "Frosted", "Chibi Scythe" },
	Trowel = { "Inlets", "Slime", "Chibi Trowel" },
	Flashbang = { "Maroon", "Carpet", "Chibi Flashbang" },
	Grenade = { "Beige", "Brain", "Chibi Grenade" },
	Medkit = { "OranGG", "Water", "Chibi Medkit" },
	Molotov = { "Pink", "Mainframe", "Chibi Molotov" },
	["Smoke Grenade"] = { "Brown", "Honeycomb", "Chibi Smoke Grenade" },
	["Subspace Tripmine"] = { "Universal", "Black Opal", "Chibi Subspace Tripmine" },
	["Freeze Ray"] = { "Cool", "Crossed", "Chibi Freeze Ray" },
	["Energy Rifle"] = { "Termination", ".exe", "Chibi Energy Rifle" },
	["Energy Pistols"] = { "Eco", "Sunset", "Chibi Energy Pistols" },
	Crossbow = { "Lumber", "Spellslinger", "Chibi Crossbow" },
	Daggers = { "Venom", "Fiery", "Chibi Daggers" },
	["Battle Axe"] = { "MaGGenta", "Carmine", "Chibi Battle Axe" },
	["War Horn"] = { "Ornate", "Voltaic", "Chibi War Horn" },
	Satchel = { "Cheese", "Money", "Chibi Satchel" },
	["Riot Shield"] = { "Bluesteel", "Portal", "Chibi Riot Shield" },
	Spray = { "Stained", "Igneous", "Chibi Spray" },
	Gunblade = { "Gunmetal", "Celtic", "Chibi Gunblade" },
	["Jump Pad"] = { "Olo", "Dawn", "Chibi Jump Pad" },
	Distortion = { "Bee", "Aegis", "Chibi Distortion" },
	Warper = { "Mint Choco Chip", "Fracture", "Chibi Warper" },
	Warpstone = { "Bliss", "Devourer", "Chibi Warpstone" },
	Maul = { "Cold Metal", "Plaid Pajama", "Chibi Maul" },
	Permafrost = { "Luxe", "Blizzard", "Chibi Permafrost" },
	Spear = { "Galvanized", "Mossy Stone", "Chibi Spear" },
	Grappler = { "Quartz", "Orichalcum", "Chibi Grappler" },
	Wildcat = { "Toxin", "Rafflesia", "Chibi Wildcat" }
}
local ContractsLibrary = {
	Types = {},
	Contracts = {},
	WeaponContracts = {},
	MapContracts = {},
	GetWeaponContracts = function(p, p2)
		return p.WeaponContracts[p2] or {}
	end,
	GetMapContracts = function(p, p2)
		return p.MapContracts[p2] or {}
	end,
	GetContractNamesByStatistic = function(p, p2, p3, p4)
		local result = {}

		for k, contract in pairs(p.Contracts) do
			if not (contract.Type == p2 and contract.Identifier == p3 and (contract.StatisticName == p4 or table.find(
				contract.ExtraStatisticNames,
				p4
			))) then
				continue
			end

			table.insert(result, k)
		end

		return result
	end,
	GetWeaponContractNamesByStatistic = function(object, p, p2)
		return object:GetContractNameByStatistic("Weapon", p, p2)
	end,
	GetMapContractNamesByStatistic = function(object, p, p2)
		return object:GetContractNameByStatistic("Map", p, p2)
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function add_type(p)
	ContractsLibrary.Types[p] = {}
end

add_type("Weapon") -- equivalent call inferred; original call site unknown
add_type("Map") -- equivalent call inferred; original call site unknown

local function add_contract(p, name, identifier, statisticName, milestones, options, items2)
	assert(ContractsLibrary.Types[p])
	assert(not ContractsLibrary.Contracts[name])

	for _, item in pairs(milestones) do
		item[1] = math.ceil(item[1])
	end

	local result = {
		Type = p,
		Name = name,
		Identifier = identifier,
		StatisticName = statisticName,
		Milestones = milestones,
		ExtraStatisticNames = options or {},
		FullDisplayName = ""
	}

	for _, v2 in pairs({
		{ result.StatisticName },
		result.ExtraStatisticNames
	}) do
		for _, v3 in pairs(v2) do
			result.FullDisplayName ..= (result.FullDisplayName == "" and "" or " + ") .. StatisticsLibrary.Info[v3].FullDisplayName
		end
	end

	for k, item in pairs(items2) do
		result[k] = item
	end

	ContractsLibrary.Contracts[name] = result
	return result
end

local function add_weapon_contract(identifier, name, statisticName, milestones, p5)
	local v2 = identifier == "MISSING_WEAPON" and identifier or ShopLibrary:IsWeaponReleased(identifier) and identifier or "unreleased weapon"
	local v3 = string.format("Earned from %s %s weapon contract", Utility:GetProperArticle(v2), v2)

	for _, v4 in pairs(v[identifier]) do
		CosmeticLibrary:ExternallySetCosmeticDescription(v4, v3)
	end

	add_contract("Weapon", name, identifier, statisticName, milestones, p5, {})
	ContractsLibrary.WeaponContracts[identifier] = ContractsLibrary.WeaponContracts[identifier] or {}
	table.insert(ContractsLibrary.WeaponContracts[identifier], name)
end

local function get_weapon_contract_reward(p, p2, weapon)
	if p == "Performance" then
		return ({
			{
				Name = "Key",
				Quantity = 1
			},
			{
				Name = "Charm Capsule",
				Weapon = weapon,
				Quantity = 1
			},
			{
				Name = "Charm Capsule",
				Weapon = weapon,
				Quantity = 1
			},
			{
				Name = "Wrap Box",
				Weapon = weapon,
				Quantity = 1
			},
			{
				Name = "Gold",
				Weapon = weapon
			},
			{
				Name = "Diamond",
				Weapon = weapon
			},
			{
				Name = "Midas Touch",
				Weapon = weapon
			},
			{
				Name = "Diamond Hands",
				Weapon = weapon
			},
			{
				Name = "Dark Matter",
				Weapon = weapon
			}
		})[p2]
	elseif p == "Playtime" then
		return ({
			{
				Name = "Key",
				Quantity = 1
			},
			{
				Name = "Charm Capsule",
				Weapon = weapon,
				Quantity = 1
			},
			{
				Name = v[weapon][1],
				Weapon = "IsUniversal"
			},
			{
				Name = "Charm Capsule",
				Weapon = weapon,
				Quantity = 1
			},
			{
				Name = "Wrap Box",
				Weapon = weapon,
				Quantity = 1
			},
			{
				Name = v[weapon][2],
				Weapon = "IsUniversal"
			},
			{
				Name = "Wrap Box 2",
				Weapon = weapon,
				Quantity = 1
			},
			{
				Name = v[weapon][3],
				Weapon = "IsUniversal"
			}
		})[p2]
	end

	assert(false, "???")
end

local function add_weapon_playtime_contract(weapon)
	add_weapon_contract(weapon, weapon .. " Playtime", "StatisticPlaytime", {
		{ 300, get_weapon_contract_reward("Playtime", 1, weapon) },
		{ 1200, get_weapon_contract_reward("Playtime", 2, weapon) },
		{ 3600, get_weapon_contract_reward("Playtime", 3, weapon) },
		{ 21600, get_weapon_contract_reward("Playtime", 4, weapon) },
		{ 43200, get_weapon_contract_reward("Playtime", 5, weapon) },
		{ 86400, get_weapon_contract_reward("Playtime", 6, weapon) },
		{ 172800, get_weapon_contract_reward("Playtime", 7, weapon) },
		{ 259200, get_weapon_contract_reward("Playtime", 8, weapon) }
	})
end

local function add_weapon_elimination_contract(weapon, p2)
	add_weapon_contract(weapon, weapon .. " Eliminations", "StatisticEliminations", {
		{ 5 * p2, get_weapon_contract_reward("Performance", 1, weapon) },
		{ 20 * p2, get_weapon_contract_reward("Performance", 2, weapon) },
		{ 100 * p2, get_weapon_contract_reward("Performance", 3, weapon) },
		{ 500 * p2, get_weapon_contract_reward("Performance", 4, weapon) },
		{ 2000 * p2, get_weapon_contract_reward("Performance", 5, weapon) },
		{ 10000 * p2, get_weapon_contract_reward("Performance", 6, weapon) },
		{ 20000 * p2, get_weapon_contract_reward("Performance", 7, weapon) },
		{ 30000 * p2, get_weapon_contract_reward("Performance", 8, weapon) },
		{ 40000 * p2, get_weapon_contract_reward("Performance", 9, weapon) }
	})
end

local v3 = {
	Arena = { "Diorama Arena" },
	["Big Graveyard"] = { "Diorama Big Graveyard" },
	Docks = { "Diorama Docks" },
	Splash = { "Diorama Splash" },
	Bridge = { "Diorama Bridge" },
	Crossroads = { "Diorama Crossroads" },
	["Big Crossroads"] = { "Diorama Big Crossroads" },
	["Shooting Range"] = { "Diorama Shooting Range" },
	["Big Backrooms"] = { "Diorama Big Backrooms" },
	Battleground = { "Diorama Battleground" },
	["Big Arena"] = { "Diorama Big Arena" },
	Construction = { "Diorama Construction" },
	Playground = { "Diorama Playground" },
	Onyx = { "Diorama Onyx" },
	Graveyard = { "Diorama Graveyard" },
	["Big Splash"] = { "Diorama Big Splash" },
	["Big Onyx"] = { "Diorama Big Onyx" },
	Backrooms = { "Diorama Backrooms" },
	Station = { "Diorama Station" },
	Dimension = { "Diorama Dimension" },
	Iceberg = { "Diorama Iceberg" },
	Village = { "Diorama Village" },
	Chess = { "Diorama Chess" },
	["Big Station"] = { "Diorama Big Station" },
	Westown = { "Diorama Westown" },
	Studio = { "Diorama Studio" },
	Museum = { "Diorama Museum" },
	Sandbox = { "Diorama Sandbox" }
}

for _, v6 in pairs({
	"Assault Rifle",
	"Handgun",
	"Burst Rifle",
	"Sniper",
	"RPG",
	"Shorty",
	"Shotgun",
	"Bow",
	"Uzi",
	"Revolver",
	"Paintball Gun",
	"Slingshot",
	"Grenade Launcher",
	"Minigun",
	"Exogun",
	"Flamethrower",
	"Daggers",
	"Energy Pistols",
	"Energy Rifle",
	"Spray",
	"Crossbow",
	"Gunblade",
	"Distortion",
	"Permafrost",
	"Wildcat"
}) do
	add_weapon_elimination_contract(v6, 1)
	add_weapon_playtime_contract(v6)
end

for _, v6 in pairs({
	"Fists",
	"Knife",
	"Chainsaw",
	"Katana",
	"Scythe",
	"Trowel",
	"Battle Axe",
	"Maul",
	"Spear"
}) do
	add_weapon_elimination_contract(v6, 0.5)
	add_weapon_playtime_contract(v6)
end

add_weapon_contract("Smoke Grenade", "Smoke Grenade Smokeds", "StatisticSmokedsEnemies", {
	{ 1, get_weapon_contract_reward("Performance", 1, "Smoke Grenade") },
	{ 5, get_weapon_contract_reward("Performance", 2, "Smoke Grenade") },
	{ 20, get_weapon_contract_reward("Performance", 3, "Smoke Grenade") },
	{ 75, get_weapon_contract_reward("Performance", 4, "Smoke Grenade") },
	{ 200, get_weapon_contract_reward("Performance", 5, "Smoke Grenade") },
	{ 1000, get_weapon_contract_reward("Performance", 6, "Smoke Grenade") },
	{ 4000, get_weapon_contract_reward("Performance", 9, "Smoke Grenade") }
})
add_weapon_playtime_contract("Smoke Grenade")
add_weapon_contract("Flashbang", "Flashbang Blinds", "StatisticBlindsEnemies", {
	{ 1, get_weapon_contract_reward("Performance", 1, "Flashbang") },
	{ 10, get_weapon_contract_reward("Performance", 2, "Flashbang") },
	{ 50, get_weapon_contract_reward("Performance", 3, "Flashbang") },
	{ 200, get_weapon_contract_reward("Performance", 4, "Flashbang") },
	{ 500, get_weapon_contract_reward("Performance", 5, "Flashbang") },
	{ 2500, get_weapon_contract_reward("Performance", 6, "Flashbang") },
	{ 10000, get_weapon_contract_reward("Performance", 9, "Flashbang") }
})
add_weapon_playtime_contract("Flashbang")
add_weapon_contract("Medkit", "Medkit Heals", "StatisticHealsGiven", {
	{ 150, get_weapon_contract_reward("Performance", 1, "Medkit") },
	{ 500, get_weapon_contract_reward("Performance", 2, "Medkit") },
	{ 2500, get_weapon_contract_reward("Performance", 3, "Medkit") },
	{ 12000, get_weapon_contract_reward("Performance", 4, "Medkit") },
	{ 50000, get_weapon_contract_reward("Performance", 5, "Medkit") },
	{ 140000, get_weapon_contract_reward("Performance", 6, "Medkit") },
	{ 560000, get_weapon_contract_reward("Performance", 9, "Medkit") }
})
add_weapon_playtime_contract("Medkit")
add_weapon_contract("Freeze Ray", "Freeze Ray Freezes", "StatisticFreezesEnemies", {
	{ 1, get_weapon_contract_reward("Performance", 1, "Freeze Ray") },
	{ 10, get_weapon_contract_reward("Performance", 2, "Freeze Ray") },
	{ 50, get_weapon_contract_reward("Performance", 3, "Freeze Ray") },
	{ 200, get_weapon_contract_reward("Performance", 4, "Freeze Ray") },
	{ 500, get_weapon_contract_reward("Performance", 5, "Freeze Ray") },
	{ 2500, get_weapon_contract_reward("Performance", 6, "Freeze Ray") },
	{ 10000, get_weapon_contract_reward("Performance", 9, "Freeze Ray") }
})
add_weapon_playtime_contract("Freeze Ray")
add_weapon_contract("Flare Gun", "Flare Gun Damage Dealt", "StatisticDamageDealt", {
	{ 100, get_weapon_contract_reward("Performance", 1, "Flare Gun") },
	{ 500, get_weapon_contract_reward("Performance", 2, "Flare Gun") },
	{ 2500, get_weapon_contract_reward("Performance", 3, "Flare Gun") },
	{ 12000, get_weapon_contract_reward("Performance", 4, "Flare Gun") },
	{ 50000, get_weapon_contract_reward("Performance", 5, "Flare Gun") },
	{ 140000, get_weapon_contract_reward("Performance", 6, "Flare Gun") },
	{ 280000, get_weapon_contract_reward("Performance", 7, "Flare Gun") },
	{ 420000, get_weapon_contract_reward("Performance", 8, "Flare Gun") },
	{ 560000, get_weapon_contract_reward("Performance", 9, "Flare Gun") }
})
add_weapon_playtime_contract("Flare Gun")
add_weapon_contract("Grenade", "Grenade Damage Dealt", "StatisticDamageDealt", {
	{ 100, get_weapon_contract_reward("Performance", 1, "Grenade") },
	{ 500, get_weapon_contract_reward("Performance", 2, "Grenade") },
	{ 2500, get_weapon_contract_reward("Performance", 3, "Grenade") },
	{ 12000, get_weapon_contract_reward("Performance", 4, "Grenade") },
	{ 50000, get_weapon_contract_reward("Performance", 5, "Grenade") },
	{ 140000, get_weapon_contract_reward("Performance", 6, "Grenade") },
	{ 280000, get_weapon_contract_reward("Performance", 7, "Grenade") },
	{ 420000, get_weapon_contract_reward("Performance", 8, "Grenade") },
	{ 560000, get_weapon_contract_reward("Performance", 9, "Grenade") }
})
add_weapon_playtime_contract("Grenade")
add_weapon_contract("Molotov", "Molotov Damage Dealt", "StatisticDamageDealt", {
	{ 100, get_weapon_contract_reward("Performance", 1, "Molotov") },
	{ 500, get_weapon_contract_reward("Performance", 2, "Molotov") },
	{ 2500, get_weapon_contract_reward("Performance", 3, "Molotov") },
	{ 12000, get_weapon_contract_reward("Performance", 4, "Molotov") },
	{ 50000, get_weapon_contract_reward("Performance", 5, "Molotov") },
	{ 140000, get_weapon_contract_reward("Performance", 6, "Molotov") },
	{ 280000, get_weapon_contract_reward("Performance", 7, "Molotov") },
	{ 420000, get_weapon_contract_reward("Performance", 8, "Molotov") },
	{ 560000, get_weapon_contract_reward("Performance", 9, "Molotov") }
})
add_weapon_playtime_contract("Molotov")
add_weapon_contract("Subspace Tripmine", "Subspace Tripmine Damage Dealt", "StatisticDamageDealt", {
	{ 100, get_weapon_contract_reward("Performance", 1, "Subspace Tripmine") },
	{ 500, get_weapon_contract_reward("Performance", 2, "Subspace Tripmine") },
	{ 2500, get_weapon_contract_reward("Performance", 3, "Subspace Tripmine") },
	{ 12000, get_weapon_contract_reward("Performance", 4, "Subspace Tripmine") },
	{ 50000, get_weapon_contract_reward("Performance", 5, "Subspace Tripmine") },
	{ 140000, get_weapon_contract_reward("Performance", 6, "Subspace Tripmine") },
	{ 280000, get_weapon_contract_reward("Performance", 7, "Subspace Tripmine") },
	{ 420000, get_weapon_contract_reward("Performance", 8, "Subspace Tripmine") },
	{ 560000, get_weapon_contract_reward("Performance", 9, "Subspace Tripmine") }
})
add_weapon_playtime_contract("Subspace Tripmine")
add_weapon_contract("War Horn", "War Horn Empowers", "StatisticEmpowers", {
	{ 3, get_weapon_contract_reward("Performance", 1, "War Horn") },
	{ 50, get_weapon_contract_reward("Performance", 2, "War Horn") },
	{ 250, get_weapon_contract_reward("Performance", 3, "War Horn") },
	{ 1250, get_weapon_contract_reward("Performance", 4, "War Horn") },
	{ 5000, get_weapon_contract_reward("Performance", 5, "War Horn") },
	{ 10000, get_weapon_contract_reward("Performance", 6, "War Horn") },
	{ 40000, get_weapon_contract_reward("Performance", 9, "War Horn") }
})
add_weapon_playtime_contract("War Horn")
add_weapon_contract("Satchel", "Satchel Damage Dealt", "StatisticDamageDealt", {
	{ 100, get_weapon_contract_reward("Performance", 1, "Satchel") },
	{ 500, get_weapon_contract_reward("Performance", 2, "Satchel") },
	{ 2500, get_weapon_contract_reward("Performance", 3, "Satchel") },
	{ 12000, get_weapon_contract_reward("Performance", 4, "Satchel") },
	{ 50000, get_weapon_contract_reward("Performance", 5, "Satchel") },
	{ 140000, get_weapon_contract_reward("Performance", 6, "Satchel") },
	{ 280000, get_weapon_contract_reward("Performance", 7, "Satchel") },
	{ 420000, get_weapon_contract_reward("Performance", 8, "Satchel") },
	{ 560000, get_weapon_contract_reward("Performance", 9, "Satchel") }
})
add_weapon_playtime_contract("Satchel")
add_weapon_contract("Riot Shield", "Riot Shield Heals", "StatisticAbsorbs", {
	{ 300, get_weapon_contract_reward("Performance", 1, "Riot Shield") },
	{ 1000, get_weapon_contract_reward("Performance", 2, "Riot Shield") },
	{ 5000, get_weapon_contract_reward("Performance", 3, "Riot Shield") },
	{ 24000, get_weapon_contract_reward("Performance", 4, "Riot Shield") },
	{ 100000, get_weapon_contract_reward("Performance", 5, "Riot Shield") },
	{ 280000, get_weapon_contract_reward("Performance", 6, "Riot Shield") },
	{ 560000, get_weapon_contract_reward("Performance", 7, "Riot Shield") },
	{ 840000, get_weapon_contract_reward("Performance", 8, "Riot Shield") },
	{ 1120000, get_weapon_contract_reward("Performance", 9, "Riot Shield") }
})
add_weapon_playtime_contract("Riot Shield")
add_weapon_contract("Jump Pad", "Jump Pad Bounces", "StatisticBounces", {
	{ 1, get_weapon_contract_reward("Performance", 1, "Jump Pad") },
	{ 25, get_weapon_contract_reward("Performance", 2, "Jump Pad") },
	{ 120, get_weapon_contract_reward("Performance", 3, "Jump Pad") },
	{ 500, get_weapon_contract_reward("Performance", 4, "Jump Pad") },
	{ 1500, get_weapon_contract_reward("Performance", 5, "Jump Pad") },
	{ 4500, get_weapon_contract_reward("Performance", 6, "Jump Pad") },
	{ 18000, get_weapon_contract_reward("Performance", 9, "Jump Pad") }
})
add_weapon_playtime_contract("Jump Pad")
add_weapon_contract("Warper", "Warper Portals Spawned", "StatisticPortalsSpawned", {
	{ 1, get_weapon_contract_reward("Performance", 1, "Warper") },
	{ 10, get_weapon_contract_reward("Performance", 2, "Warper") },
	{ 50, get_weapon_contract_reward("Performance", 3, "Warper") },
	{ 200, get_weapon_contract_reward("Performance", 4, "Warper") },
	{ 500, get_weapon_contract_reward("Performance", 5, "Warper") },
	{ 2500, get_weapon_contract_reward("Performance", 6, "Warper") },
	{ 10000, get_weapon_contract_reward("Performance", 9, "Warper") }
})
add_weapon_playtime_contract("Warper")
add_weapon_contract("Warpstone", "Warpstone Warps", "StatisticWarps", {
	{ 1, get_weapon_contract_reward("Performance", 1, "Warpstone") },
	{ 10, get_weapon_contract_reward("Performance", 2, "Warpstone") },
	{ 50, get_weapon_contract_reward("Performance", 3, "Warpstone") },
	{ 200, get_weapon_contract_reward("Performance", 4, "Warpstone") },
	{ 500, get_weapon_contract_reward("Performance", 5, "Warpstone") },
	{ 2500, get_weapon_contract_reward("Performance", 6, "Warpstone") },
	{ 10000, get_weapon_contract_reward("Performance", 9, "Warpstone") }
})
add_weapon_playtime_contract("Warpstone")
add_weapon_contract("Grappler", "Grappler Hooks", "StatisticHooksEnemies", {
	{ 1, get_weapon_contract_reward("Performance", 1, "Grappler") },
	{ 10, get_weapon_contract_reward("Performance", 2, "Grappler") },
	{ 50, get_weapon_contract_reward("Performance", 3, "Grappler") },
	{ 200, get_weapon_contract_reward("Performance", 4, "Grappler") },
	{ 500, get_weapon_contract_reward("Performance", 5, "Grappler") },
	{ 2500, get_weapon_contract_reward("Performance", 6, "Grappler") },
	{ 10000, get_weapon_contract_reward("Performance", 9, "Grappler") }
})
add_weapon_playtime_contract("Grappler")

local function add_map_contract(identifier, name, statisticName, milestones, p5)
	add_contract("Map", name, identifier, statisticName, milestones, p5, {})
	ContractsLibrary.MapContracts[identifier] = ContractsLibrary.MapContracts[identifier] or {}
	table.insert(ContractsLibrary.MapContracts[identifier], name)
end

local function get_map_contract_reward(p, p2, p3)
	if p == "Performance" then
		return ({
			{
				Name = "Key",
				Quantity = 1
			},
			{
				Name = "Charm Capsule",
				Weapon = "IsRandom",
				Quantity = 1
			},
			{
				Name = "Wrap Box",
				Weapon = "IsRandom",
				Quantity = 1
			},
			{
				Name = "Finisher Pack",
				Weapon = "IsRandom",
				Quantity = 1
			},
			{
				Name = "Key",
				Quantity = 4
			},
			{
				Name = v3[p3][1],
				Weapon = "IsUniversal"
			}
		})[p2]
	end

	if p == "Playtime" then
		assert(false, "Not implemented yet")
	else
		assert(false, "???")
	end
end

local function add_map_playtime_contract(p)
	add_map_contract(p, p .. " Playtime", "StatisticPlaytime", {
		{ 300, get_map_contract_reward("Playtime", 1, p) },
		{ 1200, get_map_contract_reward("Playtime", 2, p) },
		{ 3600, get_map_contract_reward("Playtime", 3, p) },
		{ 21600, get_map_contract_reward("Playtime", 4, p) },
		{ 43200, get_map_contract_reward("Playtime", 5, p) },
		{ 86400, get_map_contract_reward("Playtime", 6, p) }
	})
end

local function add_map_roundswon_contract(identifier, p2)
	CosmeticLibrary:ExternallySetCosmeticDescription(
		v3[identifier][1],
		string.format("Earned from %s %s map contract", Utility:GetProperArticle(identifier), identifier)
	)
	add_map_contract(identifier, identifier .. " Rounds Won", "StatisticRoundsWon", {
		{ 10 * p2, get_map_contract_reward("Performance", 1, identifier) },
		{ 40 * p2, get_map_contract_reward("Performance", 2, identifier) },
		{ 100 * p2, get_map_contract_reward("Performance", 3, identifier) },
		{ 300 * p2, get_map_contract_reward("Performance", 4, identifier) },
		{ 600 * p2, get_map_contract_reward("Performance", 5, identifier) },
		{ 1000 * p2, get_map_contract_reward("Performance", 6, identifier) }
	}, { "StatisticRankedRoundsWon" })
end

for _, v6 in pairs({
	"Arena",
	"Big Graveyard",
	"Docks",
	"Splash",
	"Bridge",
	"Crossroads",
	"Big Crossroads",
	"Shooting Range",
	"Big Backrooms",
	"Battleground",
	"Big Arena",
	"Construction",
	"Playground",
	"Onyx",
	"Graveyard",
	"Big Splash",
	"Big Onyx",
	"Backrooms",
	"Station",
	"Dimension",
	"Iceberg",
	"Village",
	"Chess",
	"Big Station",
	"Westown",
	"Studio",
	"Museum",
	"Sandbox"
}) do
	add_map_roundswon_contract(v6, 1)
end

for _, v6 in pairs({}) do
	add_map_roundswon_contract(v6, 0.5)
end

local function assert_weapon_contracts()
	for _, ownableWeapon in pairs(ShopLibrary.OwnableWeapons) do
		local v6 = false

		for _, contract in pairs(ContractsLibrary.Contracts) do
			if contract.Identifier ~= ownableWeapon then
				continue
			end

			v6 = true
			break
		end

		assert(v6, ownableWeapon)
	end
end

assert_weapon_contracts()
return ContractsLibrary