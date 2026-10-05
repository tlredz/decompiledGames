local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local conch_standalone = require(ReplicatedStorage.packages.conch_standalone)
local fishing = require(ReplicatedStorage.shared.modules.fishing)
local Net = require(ReplicatedStorage.packages.Net)
local Replion = require(ReplicatedStorage.packages.Replion)
local RunService2 = game:GetService("RunService")
local getTpSpots, getFishingDrops

if RunService2:IsServer() then
	local ServerScriptService = game:GetService("ServerScriptService")
	getTpSpots = require(ServerScriptService.server.modules.conchIntegration.getTpSpots)
	local ServerScriptService2 = game:GetService("ServerScriptService")
	getFishingDrops = require(ServerScriptService2.server.modules.conchIntegration.getFishingDrops)
else
	getTpSpots = Net:RemoteFunction("Conch/RequestTpSpots", -1):InvokeServer()
	getFishingDrops = Net:RemoteFunction("Conch/RequestFishingDrops", -1):InvokeServer()
end

getTpSpots.list = "list"

-- equivalent calls inferred from this helper; original call sites unknown
local function addName(p, value: string, p2: string?)
	local v = value:gsub(" ", "_")
	p[v] = p2 or value

	if v:find("’") then
		p[v:gsub("’", "'")] = p2 or value
	end
end

local fish = require(ReplicatedStorage.shared.modules.library.fish)
local v = {}
local v2 = {}

for k, v3 in fish do
	if not (typeof(v3) == "table" and v3.Rarity) then
		continue
	end

	addName(v, k) -- equivalent call inferred; original call site unknown
	addName(v2, k) -- equivalent call inferred; original call site unknown
end

local items = require(ReplicatedStorage.shared.modules.library.items)
local v3 = {}

for k, _ in items.Items do
	addName(v3, k) -- equivalent call inferred; original call site unknown
	addName(v2, k) -- equivalent call inferred; original call site unknown
end

local mutations = require(ReplicatedStorage.shared.modules.fishing.mutations)
local v4 = {}

for k, mutation in mutations.Mutations do
	if k == "Mila's Magic" then
		continue
	end

	addName(v4, k) -- equivalent call inferred; original call site unknown

	if not (mutation.Display and mutation.Display ~= k) then
		continue
	end

	addName(v4, mutation.Display, k) -- equivalent call inferred; original call site unknown
end

v4.Shiny = "Shiny"
v4.Sparkling = "Sparkling"
v4.Glitched = "Glitched"
v4["nil"] = ""
local rods = require(ReplicatedStorage.shared.modules.library.rods)
local v5 = {}

for k, rod in rods do
	if not (typeof(rod) == "table" and rod.Description) then
		continue
	end

	addName(v5, k) -- equivalent call inferred; original call site unknown
end

local spears = require(ReplicatedStorage.shared.modules.library.spears)
local v6 = {}

for k, spear in spears do
	if not (typeof(spear) == "table" and spear.Color) then
		continue
	end

	addName(v6, k) -- equivalent call inferred; original call site unknown
end

local RodSkins = require(ReplicatedStorage.shared.modules.RodSkins)
local v7 = {}

for k, _ in RodSkins.Skins do
	addName(v7, k) -- equivalent call inferred; original call site unknown
end

local titles = require(ReplicatedStorage.shared.modules.character.titles)
local v8 = {}

for k, title in titles do
	if typeof(title) ~= "table" then
		continue
	end

	addName(v8, k) -- equivalent call inferred; original call site unknown

	if title.Text == k then
		continue
	end

	addName(v8, title.Text, k) -- equivalent call inferred; original call site unknown
end

local enchants = require(ReplicatedStorage.shared.modules.library.rods.enchants)
local v9 = {}
local v10 = {}
local v11 = {}

for k, enchant in enchants.Enchants do
	local v12

	if enchant.Keeperbound then
		v12 = v9
	elseif enchant.KeeperboundAffix then
		v12 = v10
	else
		v12 = v11
	end

	addName(v12, k) -- equivalent call inferred; original call site unknown

	if not (enchant.Display and enchant.Display ~= k) then
		continue
	end

	addName(v12, enchant.Display, k) -- equivalent call inferred; original call site unknown
end

v11.None = "none"
local spearEnchants = require(ReplicatedStorage.shared.modules.library.spears.spearEnchants)
local v12 = {}

for k, enchant in spearEnchants.Enchants do
	addName(v12, k) -- equivalent call inferred; original call site unknown

	if not (enchant.Display and enchant.Display ~= k) then
		continue
	end

	addName(v12, enchant.Display, k) -- equivalent call inferred; original call site unknown
end

v12.None = "none"
local harpoonEnchants = require(ReplicatedStorage.shared.modules.library.harpoonGuns.harpoonEnchants)
local v13 = {}

for k, enchant in harpoonEnchants.Enchants do
	addName(v13, k) -- equivalent call inferred; original call site unknown

	if not (enchant.Display and enchant.Display ~= k) then
		continue
	end

	addName(v13, enchant.Display, k) -- equivalent call inferred; original call site unknown
end

v13.None = "none"
local vessels = require(ReplicatedStorage.shared.modules.vessels)
local v14 = {}

for k, _ in vessels.library do
	addName(v14, k) -- equivalent call inferred; original call site unknown
end

local bobbers = require(ReplicatedStorage.shared.modules.fishing.bobbers)
local v15 = {}

for k, bobber in bobbers.Bobbers do
	addName(v15, k) -- equivalent call inferred; original call site unknown

	if bobber.Name == k then
		continue
	end

	addName(v15, bobber.Name, k) -- equivalent call inferred; original call site unknown
end

local lanterns = require(ReplicatedStorage.shared.modules.library.lanterns)
local v16 = {}

for k, lantern in lanterns do
	addName(v16, k) -- equivalent call inferred; original call site unknown

	if lantern.DisplayText == k then
		continue
	end

	addName(v16, lantern.DisplayText, k) -- equivalent call inferred; original call site unknown
end

local halos = require(ReplicatedStorage.shared.modules.library.halos)
local v17 = {}

for k, halo in halos do
	addName(v17, k) -- equivalent call inferred; original call site unknown

	if not (halo.DisplayText and halo.DisplayText ~= k) then
		continue
	end

	addName(v17, halo.DisplayText, k) -- equivalent call inferred; original call site unknown
end

local bait = require(ReplicatedStorage.shared.modules.library.bait)
local v18 = {}

for k, v19 in bait do
	if typeof(v19) ~= "table" then
		continue
	end

	addName(v18, k) -- equivalent call inferred; original call site unknown
end

local SalesBooth = require(ReplicatedStorage.shared.modules.SalesBooth)
local v19 = {}

for k, item in SalesBooth.Items do
	addName(v19, k) -- equivalent call inferred; original call site unknown

	if not (item.DisplayName and item.DisplayName ~= k) then
		continue
	end

	addName(v19, item.DisplayName, k) -- equivalent call inferred; original call site unknown
end

local descendants = ReplicatedStorage.shared.modules:WaitForChild("SharedAdminEvent"):WaitForChild("Events"):GetDescendants()
local v20 = {}

for _, moduleScript in descendants do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)

	if not module.Issueable then
		continue
	end

	addName(v20, module.Identity) -- equivalent call inferred; original call site unknown

	if not (module.Identity ~= module.DisplayName and `{module.Identity} Event` ~= module.DisplayName) then
		continue
	end

	addName(v20, module.DisplayName, module.Identity) -- equivalent call inferred; original call site unknown
end

local LocalCurrencies = require(ReplicatedStorage.shared.modules.LocalCurrencies)
local v21 = {}

for k, localCurrency in LocalCurrencies do
	addName(v21, k) -- equivalent call inferred; original call site unknown

	if not (localCurrency.DisplayName and localCurrency.DisplayName ~= k) then
		continue
	end

	addName(v21, localCurrency.DisplayName, k) -- equivalent call inferred; original call site unknown
end

local CrewGoalQuests = require(ReplicatedStorage.shared.modules.Quests.CrewGoalQuests)
local v22 = {}

for k in pairs(CrewGoalQuests) do
	addName(v22, k) -- equivalent call inferred; original call site unknown
end

local v23 = {}

for _, v24 in {
	"Catches",
	"RarestCatch",
	"CrewRating",
	"BiggestFish"
} do
	addName(v23, v24) -- equivalent call inferred; original call site unknown
end

local weathers = require(ReplicatedStorage.shared.modules.library.weathers)
local v24 = {}

for k, _ in weathers do
	addName(v24, k) -- equivalent call inferred; original call site unknown
end

local v26 = {
	"anglerCooldown",
	"luck_Server",
	"luck_ServerCountdown",
	"luck_ServerSide",
	"totemInUse",
	"xp_Server"
}
local numberValuesByName = {}

for _, numberValue in ReplicatedStorage.world:GetChildren() do
	if not numberValue:IsA("NumberValue") or table.find(v26, numberValue.Name) then
		continue
	end

	numberValuesByName[numberValue.Name] = numberValue
end

local Quests = require(ReplicatedStorage.shared.modules.Quests)
local v27 = {}

for k, quest in Quests do
	addName(v27, k) -- equivalent call inferred; original call site unknown

	if not (quest.DisplayName and quest.DisplayName ~= k) then
		continue
	end

	addName(v27, quest.DisplayName, k) -- equivalent call inferred; original call site unknown
end

local v28 = {
	"Power",
	"Range",
	"Reload",
	"Velocity",
	"Accuracy",
	"Handling",
	"Piercing"
}

for k in fishing:GetStatsTemplate() do
	table.insert(v28, k)
end

local locations = require(ReplicatedStorage.shared.modules.library.locations)
local v29 = {}

for k, location in locations do
	addName(v29, k) -- equivalent call inferred; original call site unknown

	if not (location.Name and location.Name ~= k) then
		continue
	end

	addName(v29, location.Name, k) -- equivalent call inferred; original call site unknown
end

local monetization = require(ReplicatedStorage.shared.modules.library.monetization)
local v30 = {}

for k, gamepassesGiftsProduct in monetization.GamepassesGiftsProducts do
	addName(v30, gamepassesGiftsProduct.name, tostring(k)) -- equivalent call inferred; original call site unknown
end

local v31 = {}

for k in rods["Spirit of the Forest"].FishingPassives.Spirits.Spirits do
	addName(v31, k) -- equivalent call inferred; original call site unknown
end

local companions = require(ReplicatedStorage.shared.modules.library.companions)
local v32 = {}

for k, _ in pairs(companions.Companions or {}) do
	addName(v32, k) -- equivalent call inferred; original call site unknown
end

local skins = require(ReplicatedStorage.shared.modules.library.companions.skins)
local v33 = {}

for k in pairs(skins.Skins) do
	addName(v33, k) -- equivalent call inferred; original call site unknown
end

local v34 = {}
local progressionEvents = ReplicatedStorage.shared:FindFirstChild("progressionEvents")

if progressionEvents then
	for _, moduleScript in progressionEvents:GetChildren() do
		if not (moduleScript:IsA("ModuleScript") and moduleScript.Name:sub(1, 1) ~= "_") then
			continue
		end

		local success, result = pcall(require, moduleScript)

		if not (success and typeof(result) == "table" and result.Name) then
			continue
		end

		addName(v34, result.Name) -- equivalent call inferred; original call site unknown
	end
end

local Dealers = require(ReplicatedStorage.shared.modules.Dealers)
local v35 = {}

for k in Dealers do
	addName(v35, k) -- equivalent call inferred; original call site unknown
end

local WitcherPotions = require(ReplicatedStorage.shared.modules.WitcherPotions)
local v36 = {}

for k, potion in WitcherPotions.Potions do
	addName(v36, k) -- equivalent call inferred; original call site unknown

	if not (potion.DisplayName and potion.DisplayName ~= k) then
		continue
	end

	addName(v36, potion.DisplayName, k) -- equivalent call inferred; original call site unknown
end

local personalAquariumFurniture = require(ReplicatedStorage.shared.modules.library.personalAquariumFurniture)
local v37 = {}

for k, v38 in personalAquariumFurniture do
	addName(v37, k) -- equivalent call inferred; original call site unknown

	if not (v38.DisplayName and v38.DisplayName ~= k) then
		continue
	end

	addName(v37, v38.DisplayName, k) -- equivalent call inferred; original call site unknown
end

local v38 = {}

for _, animation in ReplicatedStorage:WaitForChild("resources"):WaitForChild("animations"):WaitForChild("emotes"):GetChildren() do
	if not animation:IsA("Animation") then
		continue
	end

	addName(v38, animation.Name) -- equivalent call inferred; original call site unknown
end

local SkinCrates = require(ReplicatedStorage.shared.modules.SkinCrates)
local v39 = {}

for k, v40 in SkinCrates.List do
	addName(v39, k) -- equivalent call inferred; original call site unknown

	if not (v40.CrateName and v40.CrateName ~= k) then
		continue
	end

	addName(v39, v40.CrateName, k) -- equivalent call inferred; original call site unknown
end

local harpoonGuns = require(ReplicatedStorage.shared.modules.library.harpoonGuns)
local v40 = {}

for k, harpoonGun in harpoonGuns do
	if not (typeof(harpoonGun) == "table" and harpoonGun.Color) then
		continue
	end

	addName(v40, k) -- equivalent call inferred; original call site unknown
end

local v41 = {}
local HarpoonGunSkins = require(ReplicatedStorage.shared.modules.HarpoonGunSkins)

if HarpoonGunSkins.Skins then
	for k, skin in HarpoonGunSkins.Skins do
		addName(v41, k) -- equivalent call inferred; original call site unknown

		if not (skin.DisplayText and skin.DisplayText ~= k) then
			continue
		end

		addName(v41, skin.DisplayText, k) -- equivalent call inferred; original call site unknown
	end
end

v41.Default = "Default"
local playerStats = require(ReplicatedStorage.shared.playerStats)
local v42 = {}
local v43 = {}

for k, playerStat in playerStats do
	addName(v42, k) -- equivalent call inferred; original call site unknown

	if playerStat.SubstatKey then
		addName(v43, k) -- equivalent call inferred; original call site unknown
	end

	local v44 = playerStat.Name:gsub("%s+%*$", "")

	if v44:lower() == k:lower() then
		continue
	end

	addName(v42, v44, k) -- equivalent call inferred; original call site unknown

	if not playerStat.SubstatKey then
		continue
	end

	addName(v43, v44, k) -- equivalent call inferred; original call site unknown
end

local v44 = {}

for _, v45 in ReplicatedStorage:WaitForChild("client"):WaitForChild("inputs"):QueryDescendants("InputAction") do
	addName(v44, v45.Name) -- equivalent call inferred; original call site unknown
end

local v45 = {}

for _, v46 in Enum.KeyCode:GetEnumItems() do
	v45[v46.Name] = v46
end

local accessoryupgrades = require(ReplicatedStorage.shared.modules.library.items.accessorydata.accessoryupgrades)
local v46 = {}

for _, accessoryupgrade in accessoryupgrades do
	addName(v46, accessoryupgrade.Id) -- equivalent call inferred; original call site unknown

	if accessoryupgrade.DisplayName == accessoryupgrade.Id then
		continue
	end

	addName(v46, accessoryupgrade.DisplayName, accessoryupgrade.Id) -- equivalent call inferred; original call site unknown
end

local charms = require(ReplicatedStorage.shared.modules.library.charms)
local v47 = {}

for _, charm in charms do
	addName(v47, charm.ShortName, charm.Name) -- equivalent call inferred; original call site unknown
end

local function filterSuggestions(value: string, p: string, items2)
	local lower = value:lower()
	local result = {}

	for _, item in items2 do
		if item:lower():sub(1, #lower) == lower then
			table.insert(result, p .. item)
		end
	end

	return result
end

local v48 = {
	convert = tostring,
	analysis = {
		kind = "argument",
		name = "datapath",
		type = "string",
		suggestion_generator = function(value: string)
			local parts = value:split(".")
			local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
			local data = DataController.PlayerDataReplicator.Data
			local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
			local fetched = legacyLocalPlayerData.fetch()

			if parts[2] then
				if parts[1] == "NewFormat" then
					for k, part in parts do
						if typeof(data) ~= "table" then
							return {}, false
						end

						if k == 1 then
							continue
						end

						if k == #parts then
							local v49 = {}

							for k2 in data do
								table.insert(v49, k2)
							end

							return filterSuggestions(part, table.concat(parts, ".", 1, #parts - 1) .. ".", v49), true
						elseif tonumber(part) then
							data = data[tonumber(part)] or data[part]
						else
							data = data[part]
						end
					end
				else
					for k, childName in parts do
						if not fetched then
							return {}, false
						end

						if k == #parts then
							local names = {}

							for _, child in fetched:GetChildren() do
								table.insert(names, child.Name)
							end

							return
								filterSuggestions(childName, table.concat(parts, ".", 1, #parts - 1) .. ".", names),
								true
						else
							fetched = fetched:FindFirstChild(childName)
						end
					end
				end

				return {}, false
			else
				local names = { "NewFormat" }

				for _, child in fetched:GetChildren() do
					if #child:GetChildren() > 0 then
						table.insert(names, child.Name)
					end
				end

				return filterSuggestions(value, "", names), true
			end
		end
	}
}
local ConchTypes = {}
ConchTypes.location = conch_standalone.register_type("location", conch_standalone.args.enum_map(getTpSpots))
ConchTypes.statusEffect = conch_standalone.register_type("statusEffect", conch_standalone.args.enum_new({
	"luck",
	"fire",
	"divine",
	"lure",
	"curse",
	"xp"
}))
ConchTypes.gameEvent = conch_standalone.register_type("gameEvent", conch_standalone.args.enum_new({
	"AbsoluteDarkness",
	"AncientMegalodonHunt",
	"AncientOrcaMigration",
	"Avalanche",
	"Beluga",
	"BlackMarket",
	"Blizzard",
	"BloopFishHunt",
	"BlueMoon",
	"CathulidAbundance",
	"CathulithAbundance",
	"ColossalAncientDragonHunt",
	"ColossalBlueDragonHunt",
	"ColossalEtherealDragonHunt",
	"CursedStorm",
	"Earthquake",
	"ElderMossjawHunt",
	"Eruption",
	"NightFireflies",
	"HumpbackMigration",
	"KrakenHunt",
	"LanternKeeperMoves",
	"LeviathanHunt",
	"LuckyPool",
	"NightLuminous",
	"MagicianNarwhal",
	"MegalodonHunt",
	"Meteor",
	"MobyMigration",
	"MoonlitMirage",
	"MossjawHunt",
	"Mosslurker",
	"MutationSurge",
	"Narwhal",
	"NectarBloom",
	"OrcaMigration",
	"PatriotSharkHunt",
	"PhantomMegalodonHunt",
	"ProfaneLeviathanHunt",
	"PoseidonsWrath",
	"ScyllaHunt",
	"SharkHunt",
	"ShinySurge",
	"TravelingMerchant",
	"Whirlpool",
	"SunkenChests",
	"BlueWhaleMigration",
	"FinWhaleMigration",
	"SeiWhaleHunt",
	"ZeusStorm",
	"BrineStorm",
	"SkeletalLeviathanHunt",
	"WyvernHunt",
	"RotbloomHunt",
	"FlowerGuardianHunt",
	"ToxicBoil",
	"FrostwyrmHunt",
	"DreadfinHunt",
	"WarSurge",
	"LegionnaireLampreyHunt",
	"SpawnSoulPool",
	"StartWispHaunt",
	"StopWispHaunt",
	"MegamouthHunt",
	"SoulScourge",
	"KeraunoWyrmHunt",
	"StyxAnglerHunt",
	"SolarChorus",
	"HeliosSunrayHunt",
	"StormFlood",
	"SpawnPoseidonWhirlpool",
	"TidecrasherArchonHunt",
	"OlympianDevilHunt",
	"MegamouthHunt",
	"LivyatanHunt",
	"RandomMinorEvent",
	"RandomMajorEvent",
	"RandomFishAbundance",
	"GreatWhiteSharkHunt",
	"GreatHammerheadSharkHunt",
	"WhaleSharkHunt",
	"ClearMajorEvent",
	"PowerBurst",
	"DustStorm",
	"MonstrousCuskHunt",
	"GoliathSiphonophoreHunt",
	"AbaiaHunt",
	"AncestralAbaiaHunt",
	"AnniversaryPool",
	"ProfaneAnniversaryPool",
	"StopAnniversaryPool"
}))
ConchTypes.item = conch_standalone.register_type("item", conch_standalone.args.enum_map(v3))
ConchTypes.skinCrate = conch_standalone.register_type("skinCrate", conch_standalone.args.enum_map(v39))
ConchTypes.potion = conch_standalone.register_type("potion", conch_standalone.args.enum_map(v36))
ConchTypes.fish = conch_standalone.register_type("fish", conch_standalone.args.enum_map(v))
ConchTypes.itemAny = conch_standalone.register_type("itemAny", conch_standalone.args.enum_map(v2))
ConchTypes.mutation = conch_standalone.register_type("mutation", conch_standalone.args.enum_map(v4))
ConchTypes.rod = conch_standalone.register_type("rod", conch_standalone.args.enum_map(v5))
ConchTypes.spear = conch_standalone.register_type("spear", conch_standalone.args.enum_map(v6))
ConchTypes.skin = conch_standalone.register_type("skin", conch_standalone.args.enum_map(v7))
ConchTypes.title = conch_standalone.register_type("title", conch_standalone.args.enum_map(v8))
ConchTypes.enchant = conch_standalone.register_type("enchant", conch_standalone.args.enum_map(v11))
ConchTypes.spearEnchant = conch_standalone.register_type("spearEnchant", conch_standalone.args.enum_map(v12))
ConchTypes.harpoonEnchant = conch_standalone.register_type("harpoonEnchant", conch_standalone.args.enum_map(v13))
ConchTypes.keeperEnchant = conch_standalone.register_type("keeperEnchant", conch_standalone.args.enum_map(v9))
ConchTypes.keeperAffix = conch_standalone.register_type("keeperAffix", conch_standalone.args.enum_map(v10))
ConchTypes.boat = conch_standalone.register_type("boat", conch_standalone.args.enum_map(v14))
ConchTypes.bobber = conch_standalone.register_type("bobber", conch_standalone.args.enum_map(v15))
ConchTypes.lantern = conch_standalone.register_type("lantern", conch_standalone.args.enum_map(v16))
ConchTypes.bait = conch_standalone.register_type("bait", conch_standalone.args.enum_map(v18))
ConchTypes.adminEvent = conch_standalone.register_type("adminEvent", conch_standalone.args.enum_map(v20))
ConchTypes.localCurrency = conch_standalone.register_type("localCurrency", conch_standalone.args.enum_map(v21))
ConchTypes.season = conch_standalone.register_type("season", conch_standalone.args.enum_new({
	"Spring",
	"Summer",
	"Autumn",
	"Winter",
	"Reset"
}))
ConchTypes.weather = conch_standalone.register_type("weather", conch_standalone.args.enum_map(v24))
ConchTypes.weatherGroup = conch_standalone.register_type("weatherGroup", conch_standalone.args.enum_new({
	"main",
	"meteorological",
	"sovereign",
	"astral",
	"squall"
}))
ConchTypes.spirit = conch_standalone.register_type("spirit", conch_standalone.args.enum_map(v31))
ConchTypes.worldprop = conch_standalone.register_type("worldprop", conch_standalone.args.enum_map(numberValuesByName))
ConchTypes.tidefallHunt = conch_standalone.register_type("tidefallHunt", conch_standalone.args.enum_new({
	"Plesiosaur",
	"ReefTitan",
	"Omnithal",
	"Pliosaur",
	"Goldwraith"
}))
ConchTypes.progressionEvent = conch_standalone.register_type("progressionEvent", conch_standalone.args.enum_map(v34))
ConchTypes.bestiary = conch_standalone.register_type("bestiary", conch_standalone.args.enum_map(v29))
ConchTypes.god = conch_standalone.register_type("god", conch_standalone.args.enum_new({
	"Bellona",
	"Apollo",
	"Poseidon",
	"Zeus",
	"Hades"
}))
ConchTypes.chapelRod = conch_standalone.register_type("chapelRod", conch_standalone.args.enum_new({
	"Requiem",
	"Fabulous Rod",
	"Ruinous Oath",
	"Poseidon Rod",
	"Masterline Rod",
	"none"
}))
ConchTypes.bestiaryAction = conch_standalone.register_type("bestiaryAction", conch_standalone.args.enum_new({
	"discover",
	"undiscover",
	"clear",
	"complete",
	"completeShiny",
	"completeSparkling"
}))
ConchTypes.bestiaryFishAction = conch_standalone.register_type("bestiaryFishAction", conch_standalone.args.enum_new({
	"discover",
	"discoverShiny",
	"discoverSparkling",
	"undiscover"
}))
ConchTypes.gamepass = conch_standalone.register_type("gamepass", conch_standalone.args.enum_map(v30))
ConchTypes.crabCageAction = conch_standalone.register_type(
	"crabCageAction",
	conch_standalone.args.enum_new({ "clearAll", "skipLure", "claimAll" })
)
ConchTypes.challengerType = conch_standalone.register_type(
	"challengerType",
	conch_standalone.args.enum_new({ "Daily", "Weekly" })
)
ConchTypes.challengerLocation = conch_standalone.register_type("challengerLocation", conch_standalone.args.enum_new({
	"Abyssal_Zenith",
	"Ancient_Archives",
	"Ancient_Isle",
	"Apollo's_Song_of_Light",
	"Atlantis",
	"Bellona's_Frenzy_of_War",
	"Boreal_Pines",
	"Brine_Pool",
	"Calm_Zone",
	"Carrot_Garden",
	"Castaway_Cliffs",
	"Challenger's_Deep",
	"Collapsed_Ruins",
	"Coral_Bastion",
	"Crimson_Cavern",
	"Crowned_Ruins",
	"Cryogenic_Canal",
	"Crystal_Cove",
	"Desolate_Deep",
	"Enchanted_Crevice",
	"Everturn_Forest",
	"Forsaken_Shores",
	"Frigid_Cavern",
	"Glacial_Grotto",
	"Grand_Reef",
	"Hades'_Underworld_of_Indefinite",
	"Inner_Tidefall_Castle",
	"Keepers_Altar",
	"Living_Garden",
	"Lost_Jungle",
	"Luminescent_Cavern",
	"Mineshaft",
	"Moosewood",
	"Mushgrove",
	"Olympian_Fissure",
	"Overgrowth_Caves",
	"Poseidon's_Storm_of_Floods",
	"Roslit",
	"Roslit_Volcano",
	"Scoria_Reach",
	"Snowcap",
	"Sunken_Reliquary",
	"Sunstone",
	"Terrapin",
	"The_Depths",
	"The_Sanctum",
	"Toxic_Grove",
	"Treasure_Island",
	"Veil_of_the_Forsaken",
	"Vertigo",
	"Volcanic_Vents",
	"Zeus's_Thunder_of_Chaos"
}))
ConchTypes.inputAction = conch_standalone.register_type("inputAction", conch_standalone.args.enum_map(v44))
ConchTypes.keyCode = conch_standalone.register_type("keyCode", conch_standalone.args.enum_map(v45))
ConchTypes.cloverVariant = conch_standalone.register_type(
	"cloverVariant",
	conch_standalone.args.enum_new({ "Four_Leaf_Clover", "Five_Leaf_Clover", "One_Leaf_Clover" })
)
ConchTypes.potVariant = conch_standalone.register_type(
	"potVariant",
	conch_standalone.args.enum_new({ "Normal", "Golden" })
)
ConchTypes.weekday = conch_standalone.register_type("weekday", conch_standalone.args.enum_map({
	Sunday = 0,
	Monday = 1,
	Tuesday = 2,
	Wednesday = 3,
	Thursday = 4,
	Friday = 5,
	Saturday = 6
}))
ConchTypes.stat = conch_standalone.register_type("stat", conch_standalone.args.enum_map(v42))
ConchTypes.statWithSubstat = conch_standalone.register_type("statWithSubstat", conch_standalone.args.enum_map(v43))
ConchTypes.questAction = conch_standalone.register_type("questAction", conch_standalone.args.enum_new({
	"give",
	"finish",
	"claimReward",
	"reset",
	"resetObjectives",
	"forceGive",
	"giveSeries"
}))
ConchTypes.crewRewardType = conch_standalone.register_type(
	"crewRewardType",
	conch_standalone.args.enum_new({ "main", "statues", "both" })
)
ConchTypes.quest = conch_standalone.register_type("quests", conch_standalone.args.enum_map(v27))
ConchTypes.boost = conch_standalone.register_type("boost", conch_standalone.args.enum_new(v28))
ConchTypes.halo = conch_standalone.register_type("halo", conch_standalone.args.enum_map(v17))
ConchTypes.boothSkin = conch_standalone.register_type("boothSkin", conch_standalone.args.enum_map(v19))
ConchTypes.fishingDrop = conch_standalone.register_type("fishingDrop", conch_standalone.args.enum_new(getFishingDrops))
ConchTypes.accessoryUpgrade = conch_standalone.register_type("accessoryUpgrade", conch_standalone.args.enum_map(v46))
ConchTypes.charm = conch_standalone.register_type("charm", conch_standalone.args.enum_map(v47))
ConchTypes.logLevel = conch_standalone.register_type("logLevel", conch_standalone.args.enum_map({
	Stop = -1,
	All = 0,
	Warning = 2,
	Error = 3
}))
ConchTypes.playerRestricted = conch_standalone.register_type("playerRestricted", {
	convert = function(value)
		local get_command_context = conch_standalone.get_command_context()

		if get_command_context and get_command_context.executor.player and not get_command_context.executor.player:GetAttribute("FullConchAccess") then
			return get_command_context.executor.player
		end

		if value == "@s" or value == nil or value == "nil" then
			return get_command_context and get_command_context.executor.player or error("not executed by a player")
		end

		if typeof(value) == "number" then
			return (assert(Players:GetPlayerByUserId(value), (`player with id {value} is not in this server`)))
		end

		if typeof(value) == "string" then
			return (assert(Players:FindFirstChild(value), (`player "{value}" is not valid`)))
		end

		error((`unknown arg {value}`))
	end,
	analysis = {
		kind = "argument",
		name = "playerRestricted",
		type = "Player",
		suggestion_generator = function(value: string)
			if Players.LocalPlayer and not Players.LocalPlayer:GetAttribute("FullConchAccess") then
				return { Players.LocalPlayer.Name }
			end

			local lower = value:lower()
			local result = {}

			if string.sub("@s", 1, #lower) == lower then
				table.insert(result, "@s")
			end

			for _, v49 in Players:GetPlayers() do
				if not (string.sub(v49.Name:lower(), 1, #lower) == lower or string.sub(
					v49.DisplayName:lower(),
					1,
					#lower
				) == lower) then
					continue
				end

				table.insert(result, v49.Name)
			end

			return result
		end
	}
})
ConchTypes.playerRestrictedOffline = conch_standalone.register_type("playerRestrictedOffline", {
	convert = function(value)
		local get_command_context = conch_standalone.get_command_context()

		if get_command_context and get_command_context.executor.player and not get_command_context.executor.player:GetAttribute("FullConchAccess") then
			return get_command_context.executor.player.UserId
		end

		if value == "@s" or value == nil or value == "nil" then
			return get_command_context and get_command_context.executor.player.UserId or error("not executed by a player")
		end

		if typeof(value) == "number" then
			return value
		end

		if typeof(value) ~= "string" then
			error((`unknown arg {value}`))
			return
		end

		local child = Players:FindFirstChild(value)

		if child then
			return child.UserId
		end

		local userIdFromNameAsync = nil

		while true do
			local success, result = pcall(function()
				userIdFromNameAsync = Players:GetUserIdFromNameAsync(value)
			end)

			if success or result:find("HTTP 429") then
				if not success then
					conch_standalone.log(
						"warn",
						"stupid leaderboards are still loading user ids so we gotta wait a bit"
					)
					task.wait(15)
				end
			else
				error((`Failed to get User ID for {value}: {result}`))
			end

			if userIdFromNameAsync ~= nil then
				return userIdFromNameAsync
			end
		end
	end,
	analysis = {
		kind = "argument",
		name = "playerRestrictedOffline",
		type = "number",
		suggestion_generator = function(value: string)
			if Players.LocalPlayer and not Players.LocalPlayer:GetAttribute("FullConchAccess") then
				return { Players.LocalPlayer.Name, "@s" }
			end

			local lower = value:lower()
			local result = {}

			if string.sub("@s", 1, #lower) == lower then
				table.insert(result, "@s")
			end

			for _, v49 in Players:GetPlayers() do
				if not (string.sub(v49.Name:lower(), 1, #lower) == lower or string.sub(
					v49.DisplayName:lower(),
					1,
					#lower
				) == lower) then
					continue
				end

				table.insert(result, v49.Name)
			end

			return result
		end
	}
})
ConchTypes.navTarget = conch_standalone.register_type("navTarget", {
	convert = function(value)
		local v49

		if RunService:IsServer() then
			v49 = Replion.Server
		else
			v49 = Replion.Client
		end

		for _, v50 in v49:WaitReplion("QuestNavigationGlobal"):Get("targets") or {} do
			if v50.tag and (v50.tag == value or v50.tag == value:gsub("_", " ")) then
				return v50.tag
			end
		end

		return value
	end,
	analysis = {
		kind = "argument",
		name = "navTarget",
		type = "string",
		suggestion_generator = function(value: string)
			local v49 = {}

			for _, v50 in Replion.Client:WaitReplion("QuestNavigationGlobal"):Get("targets") do
				local v51 = v50.tag and v50.tag:gsub(" ", "_")

				if v51 then
					v49[v51] = true
				end
			end

			local lower = value:lower()
			local result = {}

			for k in v49 do
				if string.sub(k:lower(), 1, #lower) ~= lower then
					continue
				end

				table.insert(result, k)
			end

			return result
		end
	}
})
ConchTypes.datapath = conch_standalone.register_type("datapath", v48)
ConchTypes.companion = conch_standalone.register_type("companion", conch_standalone.args.enum_map(v32))
ConchTypes.companionSkin = conch_standalone.register_type("companionSkin", conch_standalone.args.enum_map(v33))
ConchTypes.dealer = conch_standalone.register_type("dealer", conch_standalone.args.enum_map(v35))

function ConchTypes.permSwitch(p)
	if game.GameId == 5750914919 then
		return { p.main }
	end

	return { p.qa }
end

function ConchTypes.enforcePrivateServer()
	local player = conch_standalone.get_command_context().executor.player

	if player and player:GetAttribute("FullConchAccess") or (game.PrivateServerId ~= "" or not (#Players:GetPlayers() > 1)) then
		return false
	end

	conch_standalone.log("error", "This command can only be used in private servers.")
	return true
end

ConchTypes.crewGoal = conch_standalone.register_type("crewGoal", conch_standalone.args.enum_map(v22))
ConchTypes.crewPodiumType = conch_standalone.register_type("crewPodiumType", conch_standalone.args.enum_map(v23))
ConchTypes.crewRole = conch_standalone.register_type(
	"crewRole",
	conch_standalone.args.enum_new({ "Founder", "Officer", "Member" })
)
ConchTypes.personalAquariumFurniture = conch_standalone.register_type(
	"personalAquariumFurniture",
	conch_standalone.args.enum_map(v37)
)
ConchTypes.emote = conch_standalone.register_type("emote", conch_standalone.args.enum_map(v38))
ConchTypes.harpoonGun = conch_standalone.register_type("harpoonGun", conch_standalone.args.enum_map(v40))
ConchTypes.harpoonGunSkin = conch_standalone.register_type("harpoonGunSkin", conch_standalone.args.enum_map(v41))
return ConchTypes