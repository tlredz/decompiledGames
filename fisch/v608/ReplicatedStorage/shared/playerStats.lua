require("@self/Types")
local module = require("./modules/library/rarities")
local module2 = require("./modules/library/locations")
local module3 = require("./modules/fishing/mutations")
local module4 = require("./modules/Bestiary")
local module5 = require("./utils/FischUtils/Shared/GradientRichText")
local PlayerStats = {
	bestiariesComplete = {
		Type = "custom",
		Name = "Bestiary Pages Completed",
		Aliases = { "bestiaries completed" },
		GetCustomValue = function(_, p, _)
			local count = 0

			for k, v in module2 do
				if not ((not v.Worlds or v.Worlds[1] ~= "Sea 2") and module4:GetDiscoveryPercentages(p.Bestiary, k) >= 100) then
					continue
				end

				count += 1
			end

			return count
		end
	},
	bestiariesCompletePerm = {
		Type = "custom",
		Name = "Permanent Bestiaries Completed",
		Parent = "bestiariesComplete",
		Aliases = { "bestiaries completed" },
		GetCustomValue = function(_, p, _)
			local count = 0

			for k, v in module2 do
				if v.Limited or not (not v.Worlds or v.Worlds[1] ~= "Sea 2") or not (module4:GetDiscoveryPercentages(
					p.Bestiary,
					k
				) >= 100) then
					continue
				end

				count += 1
			end

			return count
		end
	},
	bestiariesCompleteLimited = {
		Type = "custom",
		Name = "Limited Bestiaries Completed",
		Parent = "bestiariesComplete",
		Aliases = { "bestiaries completed" },
		GetCustomValue = function(_, p, _)
			local count = 0

			for k, v in module2 do
				if not (v.Limited and (not v.Worlds or v.Worlds[1] ~= "Sea 2") and module4:GetDiscoveryPercentages(
					p.Bestiary,
					k
				) >= 100) then
					continue
				end

				count += 1
			end

			return count
		end
	},
	catchStreak = {
		Type = "legacy",
		Name = "Catch Streak",
		Path = { "Stats", "tracker_streak" }
	},
	catchStreakLifetime = {
		Type = "newstat",
		Name = "Highest Catch Streak",
		Path = "CatchStreakLifetime",
		Parent = "catchStreak"
	},
	chestsOpened = {
		Type = "legacy",
		Name = "Treasure Chests Opened",
		Path = { "Stats", "tracker_treasurechests" }
	},
	sunkenChestsOpened = {
		Type = "newstat",
		Name = "Sunken Chests Opened",
		Path = "SunkenChestsOpened",
		Parent = "chestsOpened"
	},
	coins = {
		Type = "legacy",
		Name = "Coins",
		Path = { "Stats", "coins" }
	},
	coinsLifetime = {
		Type = "newstat",
		Name = "Lifetime Coins Earned",
		Path = "LifetimeEarnings",
		Parent = "coins"
	},
	coinsSpent = {
		Type = "newstat",
		Name = "Lifetime Coins Spent",
		Path = "LifetimeSpent",
		Parent = "coins"
	},
	quests = {
		Type = "legacy",
		Name = "Quests Completed",
		Path = { "Stats", "tracker_quests" }
	},
	questsAngler = {
		Type = "legacy",
		Name = "Angler Quests Completed",
		Path = { "Stats", "tracker_anglerquests" },
		Parent = "quests",
		SubstatSort = "AnglerQuestCounts"
	},
	questsAnglerShady = {
		Type = "newstat",
		Name = "Shady Angler Quests Completed",
		Path = "ShadyAnglerCompletions",
		Parent = "quests"
	},
	questsAnglerShadySkip = {
		Type = "newstat",
		Name = "Shady Angler Quests Skipped",
		Path = "ShadyAnglerSkips",
		Parent = "quests"
	},
	questsAnglerHunting = {
		Type = "newstat",
		Name = "Hunting Angler Quests Completed",
		Path = "HuntingAnglerCompletions",
		Parent = "quests"
	},
	questsAnglerHuntingSkip = {
		Type = "newstat",
		Name = "Hunting Angler Quests Skipped",
		Path = "HuntingAnglerSkips",
		Parent = "quests"
	},
	crabCagesOpened = {
		Type = "legacy",
		Name = "Crab Cages Opened",
		Path = { "Stats", "tracker_crabcagesopened" }
	},
	deaths = {
		Type = "legacy",
		Name = "Deaths",
		Path = { "Stats", "tracker_deaths" },
		SubstatKey = "DeathCounts",
		SubstatNameFormat = "Deaths via %s"
	},
	fishCaught = {
		Type = "legacy",
		Name = "Fish Caught",
		Path = { "Stats", "tracker_fishcaught" },
		SubstatSort = "rarity",
		SubstatKey = "CaughtRarities",
		SubstatNameFormat = function(p)
			local rarity = module.Rarities[p]

			if rarity then
				p = module5(rarity.Name, rarity.ColorGradient or rarity.Color) or p
			end

			return (`{p} Fish Caught`)
		end
	},
	shinyCaught = {
		Type = "legacy",
		Name = "Shiny Fish Caught",
		Path = { "Stats", "tracker_shinycaught" }
	},
	sparklingCaught = {
		Type = "legacy",
		Name = "Sparkling Fish Caught",
		Path = { "Stats", "tracker_sparklingcaught" }
	},
	largestCaught = {
		Type = "legacy",
		Name = "Largest Fish Caught",
		Path = { "Stats", "tracker_largest" }
	},
	mutatedCaught = {
		Type = "legacy",
		Name = "Mutated Fish Caught",
		Path = { "Stats", "tracker_mutationcaught" },
		SubstatKey = "MutationCounts",
		SubstatNameFormat = function(p)
			local mutation = module3.Mutations[p]

			if mutation then
				p = module5(mutation.Display, mutation.Color) or p
			end

			return (`{p} Fish Caught`)
		end
	},
	locationsDiscovered = {
		Type = "legacy",
		Name = "Locations Discovered",
		Path = { "Stats", "tracker_locationsdiscovered" }
	},
	perfectCatches = {
		Type = "legacy",
		Name = "Perfect Catches",
		Path = { "Stats", "tracker_perfectcatches" }
	},
	level = {
		Type = "legacy",
		Name = "Player Level",
		Path = { "Stats", "level" }
	},
	xp = {
		Type = "legacy",
		Name = "Player XP",
		Path = { "Stats", "xp" }
	},
	reelsSnapped = {
		Type = "legacy",
		Name = "Reels Snapped",
		Path = { "Stats", "tracker_reelsbroken" }
	},
	rodsEnchanted = {
		Type = "legacy",
		Name = "Rods Enchanted",
		Path = { "Stats", "tracker_enchanted" }
	},
	timePlayed = {
		Type = "legacy",
		Name = "Time Played",
		Path = { "Stats", "tracker_timeplayed" },
		DisplayFormat = "duration",
		SubstatKey = "LocationTimes",
		SubstatValueFormat = "duration_minutes",
		SubstatNameFormat = "Time Spent at %s"
	},
	locationCatches = {
		Type = "newstat",
		Name = "Fish Caught by Location",
		Path = "holder",
		DisplayFormat = "",
		SubstatKey = "LocationCatches"
	},
	timesJoined = {
		Type = "legacy",
		Name = "Times Joined",
		Path = { "Stats", "tracker_timesjoined" }
	},
	totemsUsed = {
		Type = "newstat",
		Name = "Totems Used",
		Path = "TotemsUsedTotal",
		SubstatKey = "TotemsUsed",
		SubstatNameFormat = "%ss Used"
	},
	keeperLevel = {
		Type = "newformat",
		Name = "Keeper Level",
		Path = { "StatuesSecret", "Keeper", "Level" }
	},
	keeperXp = {
		Type = "newformat",
		Name = "Keeper XP",
		Path = { "StatuesSecret", "Keeper", "XP" }
	},
	rarestCatch = {
		Type = "newstat",
		Name = "Lifetime Rarest Catch",
		Path = "RarestCatch",
		DisplayFormat = "1/%s"
	},
	meteorsLooter = {
		Type = "newstat",
		Name = "Meteors Looted",
		Path = "MeteorsLooted"
	},
	lifetimeCrewRating = {
		Type = "newstat",
		Name = "Lifetime Crew Rating",
		Path = "LifetimeCrewRating"
	},
	anomaliesActivated = {
		Type = "newstat",
		Name = "Astral Anomalies Activated",
		Path = "AnomaliesActivated",
		SubstatKey = "SpecificAnomaliesActivated"
	}
}

for k, v in PlayerStats do
	v.Id = k

	if not v.Parent then
		continue
	end

	PlayerStats[v.Parent].Children = PlayerStats[v.Parent].Children or {}
	table.insert(PlayerStats[v.Parent].Children, k)
end

for k, v in PlayerStats do
	if v.Children then
		table.sort(PlayerStats[k].Children)
	end
end

return PlayerStats