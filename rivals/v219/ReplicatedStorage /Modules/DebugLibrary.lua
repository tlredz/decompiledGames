local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local PermissionsLibrary = require(ReplicatedStorage.Modules.PermissionsLibrary)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local SettingsInfo = require(ReplicatedStorage.Modules.SettingsInfo)
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local v = {
	permission_testing_publiccommands_safe = { "GetMatchmakingData", "ExportServerLogs" },
	permission_testing_publiccommands_bugrewards = { "SendBugRewards" },
	permission_funcommands = {
		"OctoMode",
		"InfiniteAmmo",
		"InfiniteAmmoReserve",
		"Invincibility",
		"InfiniteDamage",
		"ExplosiveDamage",
		"ChangeMoveSpeed",
		"SetHandicapsEnabled",
		"EquipWeaponNow",
		"DeleteWeapons",
		"LeaveDuelNow"
	}
}
local DebugLibrary = {
	MAX_NET_WRAPS_PER_CYCLE = 100,
	MAX_NET_WRAPS_PER_PLAYER = 10,
	MAX_BUG_NET_SKINS_PER_CYCLE = 20,
	MAX_BUG_NET_SKINS_PER_PLAYER = 3,
	Order = {},
	Info = {},
	IsAuthorizedToUseCommand = function(self, p, items)
		if PermissionsLibrary.ALWAYS_AUTHORIZED_TO_USE_COMMANDS or PermissionsLibrary:IsAdministrator(items) then
			return true
		end

		for _, item in pairs(items) do
			local role = PermissionsLibrary.Roles[item]

			for _, v2 in pairs(role and role.PermissionNames or {}) do
				local v3 = v[v2]

				if v3 and table.find(v3, p) then
					return true
				end
			end
		end

		return false
	end,
	GetAuthorizedCommands = function(self, p)
		local names = {}

		for _, v2 in pairs(self.Order) do
			if self:IsAuthorizedToUseCommand(v2.Name, p) then
				table.insert(names, v2.Name)
			end
		end

		return names
	end,
	CanViewDebugPage = function(self, p)
		return #self:GetAuthorizedCommands(p) > 0
	end
}

local function add_setting(...)
	local v2 = SettingsInfo.new(...)
	DebugLibrary.Info[v2.Name] = v2
	table.insert(DebugLibrary.Order, v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function add_divider(p, p2)
	local v2 = SettingsInfo.new(p, p2, "", "", "", "Divider")
	table.insert(DebugLibrary.Order, v2)
end

add_divider("Debug", "Fun") -- equivalent call inferred; original call site unknown
add_setting(
	"Debug",
	"OctoMode",
	"Octo Mode",
	"rbxassetid://18223601855",
	"Allows you to equip multiple weapons at once",
	"SliderConfirm",
	4,
	1,
	4,
	1
)
add_setting(
	"Debug",
	"OctoMode2",
	"Octo Mode 2",
	"rbxassetid://18223601855",
	"Equips ALL weapons at once",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"OctoMode3",
	"Octo Mode 3",
	"rbxassetid://18223601855",
	"Equips ALL weapons + SKINS at once (very laggy)",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"InfiniteAmmo",
	"Infinite Ammo",
	"rbxassetid://18223601855",
	"No need to worry about ammo anymore",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"InfiniteAmmoReserve",
	"Infinite Ammo Reserve",
	"rbxassetid://18223601855",
	"Reloads for days",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"Invincibility",
	"Invincibility",
	"rbxassetid://18223601855",
	"You can no longer die",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"MaxInvincibility",
	"Max Invincibility",
	"rbxassetid://18223601855",
	"You can no longer die or be frozen or be affected by anything",
	"ToggleConfirm",
	false
)
add_setting("Debug", "InfiniteDamage", "OHKO", "rbxassetid://18223601855", "Easy mode", "ToggleConfirm", false)
add_setting(
	"Debug",
	"ExplosiveDamage",
	"Explosive Hands",
	"rbxassetid://18223601855",
	"Everything blows up",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"ChangeMoveSpeed",
	"Move Speed Boost",
	"rbxassetid://18223601855",
	"Change how fast you run",
	"SliderConfirm",
	0,
	0,
	10,
	10
)
add_setting(
	"Debug",
	"SetHandicapsEnabled",
	"Handicaps",
	"rbxassetid://18223601855",
	"Enable/disable aim assist + autoshoot + third person",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"EquipWeaponNow",
	"Equip Weapon Now",
	"rbxassetid://18223601855",
	"Equips a specific weapon, including unobtainable ones",
	"DropdownConfirm",
	"Assault Rifle",
	ItemLibrary.ItemsAlphabetized
)
add_setting(
	"Debug",
	"EquipSkinsNow",
	"Equip Skins Now",
	"rbxassetid://18223601855",
	"Equips a specific weapon & all of its skins",
	"DropdownConfirm",
	"Assault Rifle",
	ItemLibrary.ItemsAlphabetized
)
add_setting(
	"Debug",
	"DeleteWeapons",
	"Delete My Weapons",
	"rbxassetid://18223601855",
	"Clears your hotbar of weapons",
	"Confirm"
)
add_setting(
	"Debug",
	"LeaveDuelNow",
	"Leave Current Duel",
	"rbxassetid://18223601855",
	"So that you don't have to rejoin the server",
	"Confirm"
)
add_divider("Debug", "Numbers") -- equivalent call inferred; original call site unknown
add_setting(
	"Debug",
	"SetLevel",
	"Level",
	"rbxassetid://18223601855",
	"Change your level",
	"SliderConfirm",
	0,
	0,
	9999,
	1
)
add_setting(
	"Debug",
	"SetXPPercent",
	"XP %",
	"rbxassetid://18223601855",
	"Change your XP %",
	"SliderConfirm",
	0,
	0,
	1,
	100
)
add_setting(
	"Debug",
	"SetKeys",
	"Keys",
	"rbxassetid://18223601855",
	"Change how many keys you have",
	"SliderConfirm",
	0,
	0,
	9999,
	1
)
add_setting(
	"Debug",
	"SetUnlockTokens",
	"Unlock Tokens",
	"rbxassetid://18223601855",
	"Change how many unlock tokens you have",
	"SliderConfirm",
	0,
	0,
	9999,
	1
)
add_setting(
	"Debug",
	"SetEventCurrency",
	EventLibrary.EVENT_DETAILS.CURRENCY_NAME_PLURAL,
	"rbxassetid://18223601855",
	"Change how much event currency you have",
	"SliderConfirm",
	0,
	0,
	9999,
	1
)
add_setting(
	"Debug",
	"SetDailyTaskStreak",
	"Daily Task Streak",
	"rbxassetid://18223601855",
	"Changes your daily task streak",
	"SliderConfirm",
	0,
	0,
	100,
	1
)
add_setting(
	"Debug",
	"SetGlory",
	"Glory",
	"rbxassetid://18223601855",
	"Change how much glory you have (ranked reward currency)",
	"SliderConfirm",
	0,
	0,
	9999,
	1
)
add_setting(
	"Debug",
	"SetSkinTickets",
	"Skin Tickets",
	"rbxassetid://18223601855",
	"Change how much skin tickets you have (free skin cases)",
	"SliderConfirm",
	0,
	0,
	9999,
	1
)
add_setting(
	"Debug",
	"SetWinStreak",
	"Win Streak",
	"rbxassetid://18223601855",
	"Change your current win streak",
	"SliderConfirm",
	0,
	0,
	9999,
	1
)
add_setting(
	"Debug",
	"SetDuelsPlayed",
	"Duels Played",
	"rbxassetid://18223601855",
	"To test out beginner notifications/features",
	"SliderConfirm",
	0,
	0,
	100,
	1
)
add_setting(
	"Debug",
	"SetDuelsWon",
	"Duels Won",
	"rbxassetid://18223601855",
	"To test out beginner notifications/features",
	"SliderConfirm",
	0,
	0,
	100,
	1
)
add_setting(
	"Debug",
	"SetDuelsLost",
	"Duels Lost",
	"rbxassetid://18223601855",
	"To test out beginner notifications/features",
	"SliderConfirm",
	0,
	0,
	100,
	1
)
add_setting(
	"Debug",
	"SetHealth",
	"Health",
	"rbxassetid://18223601855",
	"Changes your current health",
	"SliderConfirm",
	0,
	0,
	150,
	1
)
add_setting(
	"Debug",
	"SetGiftTickets",
	"Set Random Gift Tickets",
	"rbxassetid://18223601855",
	"Gives you a random amount of gift tickets",
	"Confirm",
	false
)
add_divider("Debug", "Unlocks") -- equivalent call inferred; original call site unknown
add_setting(
	"Debug",
	"LockWeapons",
	"Lock All Weapons",
	"rbxassetid://18223601855",
	"Locks all weapons",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"UnlockWeapons",
	"Unlock All Weapons",
	"rbxassetid://18223601855",
	"Unlocks all weapons",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"UnlockSkins",
	"Unlock All Skins",
	"rbxassetid://18223601855",
	"Unlocks all skins",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"UnlockWraps",
	"Unlock All Wraps",
	"rbxassetid://18223601855",
	"Unlocks all wraps for all weapons",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"UnlockCharms",
	"Unlock All Charms",
	"rbxassetid://18223601855",
	"Unlocks all charms for all weapons",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"UnlockFinishers",
	"Unlock All Finishers",
	"rbxassetid://18223601855",
	"Unlocks all finishers for all weapons",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"UnlockEmotes",
	"Unlock All Emotes",
	"rbxassetid://18223601855",
	"Unlocks all emotes",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"UnlockCosmeticsPartially",
	"Unlock All Cosmetics Partially",
	"rbxassetid://18223601855",
	"Randomly unlock half of all cosmetics (to test UI)",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"UnlockAllCosmeticsForUnlockedWeapons",
	"Unlock Cosmetics (Owned Weapons)",
	"rbxassetid://18223601855",
	"For unlocked weapons only (to test out lootbox bug)",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"EquipSkinsFromCase",
	"Equip Skins From Case",
	"rbxassetid://18223601855",
	"Quickly equip all skins from a specific case",
	"DropdownConfirm",
	"Skin Case",
	CosmeticLibrary.LootboxOrder
)
add_setting(
	"Debug",
	"EquipCosmetics",
	"Equip Cosmetics",
	"rbxassetid://18223601855",
	"Quickly equip cosmetics in all slots for all weapons",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"LockCosmetics",
	"Lock All Cosmetics",
	"rbxassetid://18223601855",
	"Lock all cosmetics for all weapons",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"SetWeaponXP",
	"Weapon XP %",
	"rbxassetid://18223601855",
	"To test weapon XP bars & level up costs",
	"SliderConfirm",
	0.5,
	0,
	1,
	10
)
add_divider("Debug", "Loot") -- equivalent call inferred; original call site unknown
add_setting(
	"Debug",
	"OpenLootboxes",
	"Open All Lootboxes",
	"rbxassetid://18223601855",
	"Opens 1 of every lootbox at the same time",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"GiveLootboxes",
	"Give Lootboxes",
	"rbxassetid://18223601855",
	"Gives you 1 of every lootbox",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"GiveGamepasses",
	"Give Gamepasses",
	"rbxassetid://18223601855",
	"Simulates purchasing all gamepasses",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"GiveExpirableItem",
	"Give Expirable Item",
	"rbxassetid://18223601855",
	"Gives you a weapon crate that will expire in 30 seconds",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"ClearBackpack",
	"Clear Backpack",
	"rbxassetid://18223601855",
	"Deletes any of your extra lootboxes, cosmetics, etc.",
	"Confirm",
	false
)
add_divider("Debug", "Season") -- equivalent call inferred; original call site unknown
add_setting(
	"Debug",
	"SetELO",
	"ELO",
	"rbxassetid://18223601855",
	"Change your current ELO (placements have to be done)",
	"SliderConfirm",
	0,
	0,
	9999,
	1
)
add_setting(
	"Debug",
	"SetRankedDuelsWon",
	"Ranked Duels Won",
	"rbxassetid://18223601855",
	"Edit your # of ranked duels won (to test ranked contract)",
	"SliderConfirm",
	0,
	0,
	9999,
	1
)
add_setting(
	"Debug",
	"SetPlacements",
	"Ranked Placements Status",
	"rbxassetid://18223601855",
	"Will either clear your placements or place you at 1,000 ELO",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"RemoveRankedTimeout",
	"Remove Ranked Timeout",
	"rbxassetid://18223601855",
	"Remove the ranked timeout you get from dodging",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"SetBattlePassLevel",
	"Season Pass Level",
	"rbxassetid://18223601855",
	"Change your season pass level",
	"SliderConfirm",
	0,
	0,
	100,
	1
)
add_setting(
	"Debug",
	"SetBattlePassPrime",
	"Prime Season Pass",
	"rbxassetid://18223601855",
	"Upgrade/downgrade your season pass status",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"ResetSeasonData",
	"Reset Season Data",
	"rbxassetid://18223601855",
	"Deletes your current season's ranked and season pass data",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"SimulateELOForSeasonalCharm",
	"Simulate Last Season's ELO",
	"rbxassetid://18223601855",
	"To look at the different ranks for the Seasonal Charm",
	"SliderConfirm",
	0,
	0,
	9999,
	1
)
add_setting(
	"Debug",
	"SimulateTopRankForSeasonalCharm",
	"Simulate Last Season LB Spot",
	"rbxassetid://18223601855",
	"Turn this on to simulate you being #1 last season (archnem charm)",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"SimulateRankedWin",
	"Simulate Ranked Win",
	"rbxassetid://18223601855",
	"Simulates a Ranked win, no end game screen animations tho",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"SimulateRankedLoss",
	"Simulate Ranked Loss",
	"rbxassetid://18223601855",
	"Simulates a Ranked loss, no end game screen animations tho",
	"Confirm",
	false
)
add_divider("Debug", "Actions") -- equivalent call inferred; original call site unknown
add_setting(
	"Debug",
	"LevelUp",
	"Level Up",
	"rbxassetid://18223601855",
	"Levels your career level up by 1",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"IncrementTasks",
	"Increment Tasks",
	"rbxassetid://18223601855",
	"Adds +1 progress to every task",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"RefreshDailyTasks",
	"Refresh Daily Tasks",
	"rbxassetid://18223601855",
	"Refreshes your Daily Tasks",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"CompleteNextWeaponContracts",
	"Complete Next Weapon Contracts",
	"rbxassetid://18223601855",
	"Completes the next contract milestone on all weapons",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"RestartSpecialChallenges",
	"Restart Special Challenges",
	"rbxassetid://18223601855",
	"Clears your special challenges progress (if possible)",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"EndWinStreak",
	"End Win Streak",
	"rbxassetid://18223601855",
	"Simulates you losing a win streak (for testing recoveries)",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"TeleportRandomly",
	"Teleport To Random Player",
	"rbxassetid://18223601855",
	"Useful for seeing if the anticheat stops you from griefing",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"EndDuelNow",
	"End Your Current Duel",
	"rbxassetid://18223601855",
	"To test out the end game win screen",
	"Confirm",
	false
)
add_divider("Debug", "Advanced") -- equivalent call inferred; original call site unknown
add_setting(
	"Debug",
	"ShutdownServer",
	"Shutdown Server",
	"rbxassetid://18223601855",
	"Kicks everyone in this server from the game",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"SetHitboxesVisible",
	"Player Hitboxes Visible",
	"rbxassetid://18223601855",
	"Enables player hitboxes",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"SetMapSpawnsVisible",
	"Set Map Spawns Visible",
	"rbxassetid://18223601855",
	"Shows where all the spawns are in maps",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"SetOOBVisible",
	"Set OOB Parts Visible",
	"rbxassetid://18223601855",
	"Shows all out-of-bounds parts",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"SetMapBarriersVisible",
	"Set Map Barriers Visible",
	"rbxassetid://18223601855",
	"Shows all invisible barriers in maps",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"RevealShadyChickenRoom",
	"Reveal Shady Chicken Room",
	"rbxassetid://18223601855",
	"In the Shooting Range",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"DisableTransparentHats",
	"Disable Transparent Hats",
	"rbxassetid://18223601855",
	"Turns off the transparent big hats restriction",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"SetMaxDuelPadWinsToday",
	"Max Duel Pad Wins Today",
	"rbxassetid://18223601855",
	"If turned on, you will no longer be able to grind duel pads",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"TestFreeWeaponTrialsAll",
	"Free Weapon Trials",
	"rbxassetid://18223601855",
	"Simulates the PWR Video Ad Reward (Standard weapons only)",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"TestFreeWeaponTrials",
	"Free Weapon Trial",
	"rbxassetid://18223601855",
	"Sets your free trials for this weapon to 1 (next duel only)",
	"DropdownConfirm",
	"Assault Rifle",
	ItemLibrary.ItemsAlphabetized
)
add_divider("Debug", "Internal") -- equivalent call inferred; original call site unknown
add_setting(
	"Debug",
	"ResetTheHunt",
	"Reset The Hunt Progress",
	"rbxassetid://18223601855",
	"Internal use only (rejoin after use)",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"DisableDeviceAutoSwitch",
	"Disable Device Auto Switch",
	"rbxassetid://18223601855",
	"Switching control schemes wont be recognized once this is on",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"EndCurrentArcadeDuel",
	"End Arcade Duel (TDM/FFA/etc)",
	"rbxassetid://18223601855",
	"This won't work for any normal duels/limited time modes",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"SpectateNilDuel",
	"Unspectate Current Duel",
	"rbxassetid://18223601855",
	"Attempts to cause the \"map not loading\" bug",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"DisableAntiNetLimiter",
	"Disable Anti-Net-Limiter",
	"rbxassetid://18223601855",
	"Allows you to use a net limiter without getting kicked",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"GetMatchmakingData",
	"Get Matchmaking Data",
	"rbxassetid://18223601855",
	"Fetches getMatchData + country codes + latencies",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"ShowClientEnvironment",
	"Show Client Environment",
	"rbxassetid://18223601855",
	"Internal use only",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"RTEFlush",
	"Flush RTE Requests",
	"rbxassetid://18223601855",
	"Internal use only",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"HighestELOLeaderboardELODecay",
	"Flush ELO Decayers",
	"rbxassetid://18223601855",
	"Kicks people off the ELO leaderboard if they've decayed",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"ExportServerLogs",
	"Export Server Logs",
	"rbxassetid://18223601855",
	"Sends hidden errors / useful info about this server to devs",
	"Confirm",
	false
)
add_divider("Debug", "FFlags") -- equivalent call inferred; original call site unknown
add_setting(
	"Debug",
	"SetSpecialChallengesEnabled",
	"Special Challenges Enabled",
	"rbxassetid://18223601855",
	"Enable/disable the special challenges feature real-time",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"SetEventEndTime",
	"Event End Time (-1 = Disabled)",
	"rbxassetid://18223601855",
	"Starts the event countdown, uses epoch time",
	"SliderConfirm",
	-1,
	-1,
	1e999,
	1
)
add_setting(
	"Debug",
	"SetSeasonEndTime",
	"Season End Time (-1 = Disabled)",
	"rbxassetid://18223601855",
	"Starts the season countdown, uses epoch time",
	"SliderConfirm",
	-1,
	-1,
	1e999,
	1
)
add_setting(
	"Debug",
	"SetFreeToUseStandardWeapons",
	"FREE Standard Weapons",
	"rbxassetid://18223601855",
	"Allows all players to use locked Standard weapons",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"SetFreeToUsePrimeWeapons",
	"FREE Prime Weapons",
	"rbxassetid://18223601855",
	"Allows all players to use locked Prime weapons",
	"ToggleConfirm",
	false
)
add_setting(
	"Debug",
	"SetFreeToUseContrabandWeapons",
	"FREE Contraband Weapons",
	"rbxassetid://18223601855",
	"Allows all players to use locked Contraband weapons",
	"ToggleConfirm",
	false
)
add_divider("Debug", "Last") -- equivalent call inferred; original call site unknown
add_setting(
	"Debug",
	"SendOfflineGiftRewards",
	"Send Offline Gift Rewards",
	"rbxassetid://18223601855",
	"To easily give out Net wraps and Bug Net skins",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"SendBugRewards",
	"Send Bug Report Rewards",
	"rbxassetid://18223601855",
	"Hand out Bug Net skins & Net wraps",
	"Confirm",
	false
)
add_setting(
	"Debug",
	"InternalViewRewardSlot",
	"Preview Reward Slot UI",
	"rbxassetid://18223601855",
	"For wiki purposes",
	"Confirm",
	false
)
return DebugLibrary