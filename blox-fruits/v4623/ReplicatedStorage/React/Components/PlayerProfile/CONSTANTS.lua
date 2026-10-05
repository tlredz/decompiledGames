local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextUtil = require(ReplicatedStorage.Modules.Util.TextUtil)
local Spritesheets = require(ReplicatedStorage.Spritesheets)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
require(script.Parent.Types)
require(game.ReplicatedStorage.Modules.SerData.PlayerProfile)
local GlobalUtil = require(ReplicatedStorage.GlobalUtil)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local v = {
	{
		FunctionalEmoji = "⚖️",
		Text = "Trades",
		Options = {},
		Color = Color3.fromHex("#e8d936")
	},
	{
		FunctionalEmoji = "⚔️",
		Text = "PvP",
		Options = {},
		Color = Color3.fromHex("#ff9898")
	},
	{
		FunctionalEmoji = "🏴‍☠️",
		Text = "Crew to Join",
		Options = {},
		Color = Color3.fromHex("#cacaca")
	},
	{
		FunctionalEmoji = "🏴‍☠️",
		Text = "Crew Members",
		Options = {},
		Color = Color3.fromHex("#cacaca")
	},
	{
		FunctionalEmoji = "🛡️",
		Text = "Race Trials",
		Options = { "Awakening", "V4", "Draco" },
		Color = Color3.fromHex("#35aeff")
	},
	{
		FunctionalEmoji = "🛡️",
		Text = "Raids",
		Options = { "Fruit Awakening", "Boss Hunting", "Raid Boss" },
		Color = Color3.fromHex("#35aeff")
	},
	{
		FunctionalEmoji = "🌊",
		Text = "Sea Events",
		Options = {
			"Sea Beast",
			"Terrorshark",
			"Kitsune Island",
			"Prehistoric Island",
			"Leviathan",
			"Mirage Island"
		},
		Color = Color3.fromHex("#35aeff")
	},
	{
		FunctionalEmoji = "🤝",
		Text = "Players to Help",
		Options = {},
		Color = Color3.fromHex("#b4ff77")
	},
	{
		Text = "I <3 Blox Fruits!",
		Options = {}
	},
	{
		Text = "Red Legion forever!",
		Options = {}
	},
	{
		Text = "Rip Family forever!",
		Options = {}
	},
	{
		Text = "Seeking Adventure!",
		Options = {}
	},
	{
		Text = "Playing Blox Fruits!",
		Options = {}
	},
	{
		Text = "W update!",
		Options = {}
	},
	{
		Text = "Boss Hunter",
		Options = {}
	},
	{
		Text = "RNG Hates Me",
		Options = {}
	},
	{
		Text = "On my grind",
		Options = {}
	},
	{
		Text = "W Player",
		Options = {}
	},
	{
		Text = "L Player",
		Options = {}
	},
	{
		Text = "Spammer",
		Options = {}
	},
	{
		Text = "Indra-Chan's Favorite",
		Options = {}
	},
	{
		Text = "Oops, wrong stats...",
		Options = {}
	},
	{
		Text = "Fell in the water",
		Options = {}
	},
	{
		Text = "Farming all day",
		Options = {}
	},
	{
		Text = "EXP Hungry",
		Options = {}
	},
	{
		Text = "Mastery grinding, once again!",
		Options = {}
	},
	{
		Text = "EZ Clap",
		Options = {}
	},
	{
		Text = "Skill Issue certified",
		Options = {}
	},
	{
		Text = "Fruit Detected, Fruit Detected!",
		Options = {}
	},
	{
		Text = "Waiting for invites",
		Options = {}
	},
	{
		Text = "I'm on mobile, go easy!",
		Options = {}
	},
	{
		Text = "You're lucky I can't type on console!",
		Options = {}
	},
	{
		Text = "Top of the leaderboard!",
		Options = {}
	},
	{
		Text = "Bottom of the leaderboard!",
		Options = {}
	},
	{
		Text = "I am the update",
		Options = {}
	},
	{
		Text = "Just keep swimming...",
		Options = {}
	},
	{
		Text = "Wasted my stat reset",
		Options = {}
	},
	{
		Text = "Grinding, but no drops...",
		Options = {}
	},
	{
		Text = "Max level but still broke",
		Options = {}
	},
	{
		Text = "Where am I?",
		Options = {}
	},
	{
		Text = "Training Claw",
		Options = {}
	},
	{
		Text = "Death Step Enjoyer",
		Options = {}
	},
	{
		Text = "Karate Comboing",
		Options = {}
	},
	{
		Text = "Superhuman Tryhard",
		Options = {}
	},
	{
		Text = "Talon Training Arc",
		Options = {}
	},
	{
		Text = "Electric Fighter",
		Options = {}
	},
	{
		Text = "Death Step Demon",
		Options = {}
	},
	{
		Text = "Sharkman Main",
		Options = {}
	},
	{
		Text = "Lightning Hands",
		Options = {}
	},
	{
		Text = "God Mode On",
		Options = {}
	},
	{
		Text = "Life Drain Spammer",
		Options = {}
	},
	{
		Text = "The Best Dragon",
		Options = {}
	},
	{
		Text = "Kitsune Runner",
		Options = {}
	},
	{
		Text = "Fruit rework when?",
		Options = {}
	},
	{
		Text = "Gas is just an upgraded Buddha Fruit!",
		Options = {}
	},
	{
		Text = "Creation Builder Man",
		Options = {}
	},
	{
		Text = "Prehistoric Time Traveller",
		Options = {}
	},
	{
		Text = "Lurking in the Shadows",
		Options = {}
	},
	{
		Text = "It's a Bird, It's A Plane.. No! It's a Meteor!",
		Options = {}
	},
	{
		Text = "Time to roll a Spin Fruit",
		Options = {}
	},
	{
		Text = "Scammed by Zioles",
		Options = {}
	},
	{
		Text = "Please Dragon 🙏",
		Options = {}
	},
	{
		Text = "Two Spikes in a Row",
		Options = {}
	},
	{
		Text = "Storage Full",
		Options = {}
	},
	{
		Text = "Accidentally Ate Smoke...",
		Options = {}
	}
}
local v2 = {
	CrewName = "",
	IsInCrew = false,
	Online = false,
	StatusId = 0,
	SubStatusId = 0,
	TitleText = "",
	TitleColor = CONSTANTS.COLOR.PALETTE.BLACK,
	Verified = false,
	IsStarCreator = false,
	IsDeveloper = false,
	Level = 0,
	EquippedAccessory = 0,
	EquippedFightingStyle = 0,
	EquippedFruit = 0,
	EquippedGun = 0,
	EquippedSword = 0,
	EquippedTrinket1 = 0,
	EquippedTrinket2 = 0,
	ShowcaseSlot1Id = 0,
	ShowcaseSlot2Id = 0,
	ShowcaseSlot3Id = 0,
	ShowcaseSlot4Id = 0,
	ShowcaseSlot5Id = 0,
	ShowcaseSlot6Id = 0,
	ShowcaseSlot1Rarity = 0,
	ShowcaseSlot2Rarity = 0,
	ShowcaseSlot3Rarity = 0,
	ShowcaseSlot4Rarity = 0,
	ShowcaseSlot5Rarity = 0,
	ShowcaseSlot6Rarity = 0,
	ShowcaseSlot1Quantity = 0,
	ShowcaseSlot2Quantity = 0,
	ShowcaseSlot3Quantity = 0,
	ShowcaseSlot4Quantity = 0,
	ShowcaseSlot5Quantity = 0,
	ShowcaseSlot6Quantity = 0,
	LastLocation = 0,
	BackgroundIndex = 0,
	StanceOverrideId = 0,
	Race = "Human",
	RaceLevel = 1,
	Settings = {
		AccessoriesVisible = "Nobody",
		CombatToolsVisible = "Nobody",
		CrewVisible = "Nobody",
		LocationVisible = "Nobody",
		JoinServer = "Nobody",
		LevelVisible = "Nobody",
		RaceVisible = "Nobody",
		ShowcaseVisible = "Nobody",
		FindInRecent = "Nobody",
		CanReceiveGifts = "Nobody"
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function restore(p: number, p2: number)
	return (bit32.bor(bit32.lshift(p2, 16), p))
end

local function restoreFormat(p: number, p2: number)
	return TextUtil.commaValue((bit32.bor(bit32.lshift(p2, 16), p)))
end

local v3 = {
	Human = Spritesheets.MAP.Human,
	Mink = Spritesheets.MAP.Rabbit,
	Fishman = Spritesheets.MAP.Shark,
	Skypiea = Spritesheets.MAP.Angel,
	Ghoul = Spritesheets.MAP.Ghoul,
	Cyborg = Spritesheets.MAP.Cyborg,
	Draco = Spritesheets.MAP.Draco
}
local v4 = {
	FightingStyles = Spritesheets.MAP["Fighting Styles Unlocked"],
	Mastery = Spritesheets.MAP.Mastery,
	TimePlayed = Spritesheets.MAP["Time Played"],
	TotalFishCaught = Spritesheets.MAP["Total Fish Caught"],
	FishTypesCaught = Spritesheets.MAP["Fish Types Caught"],
	FruitsUnlocked = Spritesheets.MAP["Fruits Unlocked"],
	SwordsUnlocked = Spritesheets.MAP["Swords Unlocked"],
	GunsUnlocked = Spritesheets.MAP["Guns Unlocked"],
	GiftsSent = Spritesheets.MAP["Gifts Sent"],
	Money = Spritesheets.MAP.Money,
	Fragments = Spritesheets.MAP.Fragments,
	Bounty = Spritesheets.MAP.Bounty,
	Honor = Spritesheets.MAP.Honor,
	PermFruitsOwned = Spritesheets.MAP["Permanent Fruit Owned"],
	FruitsMastered = Spritesheets.MAP["Fruits Mastered"],
	FightingStylesMastered = Spritesheets.MAP["Fighting Styles Mastered"],
	RacesAwakened = Spritesheets.MAP["Races Awakened"],
	RacesEvolved = Spritesheets.MAP["Races Evolved"]
}
local v5 = {}

local function isFriendsWith(p: number)
	local v6 = v5[p]

	if v6 ~= nil then
		return v6
	end

	local success, result = pcall(Players.LocalPlayer.IsFriendsWith, Players.LocalPlayer, p)

	if not success then
		return false
	end

	v5[p] = result
	return result
end

local CONSTANTS2 = {
	CLEAR = table.freeze({}),
	DEFAULT_PROFILE_DATA = v2,
	DEFAULT_LOADED_PLAYER = {
		UserId = 0,
		IsLocalPlayer = false,
		IsPreviewMode = false,
		OwnedBackgrounds = {},
		NewBackgrounds = {},
		ProfileData = TableUtil.deepCopy(v2)
	},
	SPECIAL_STAT_FORMATTING = {
		["First Joined"] = function(p: number, p2: number)
			local localeId = "en-us"
			pcall(function()
				localeId = Players.LocalPlayer.LocaleId
			end)
			local v6 = restore(p, p2) -- equivalent call inferred; original call site unknown
			return DateTime.fromUnixTimestamp(v6):FormatUniversalTime("LL", localeId)
		end,
		Money = restoreFormat,
		Fragments = restoreFormat,
		Bounty = restoreFormat,
		Honor = restoreFormat
	},
	RACE_SPRITES = v3,
	STAT_SPRITES = v4,
	STAT_SPRITE_LOOKUP = {
		["Sea Events Cleared"] = "Mastery",
		["Fighting Styles Unlocked"] = "FightingStyles",
		["First Joined"] = "TimePlayed",
		["Total Fish Caught"] = "TotalFishCaught",
		["Fish Types Caught"] = "FishTypesCaught",
		["Gifts Sent"] = "GiftsSent",
		Money = "Money",
		Fragments = "Fragments",
		Bounty = "Bounty",
		Honor = "Honor",
		["Permanent Fruits Owned"] = "PermFruitsOwned",
		["Fruits Mastered"] = "FruitsMastered",
		["Fighting Styles Mastered"] = "FightingStylesMastered",
		["Races Evolved"] = "RacesEvolved",
		["Races Fully Awakened"] = "RacesAwakened",
		["Guns Unlocked"] = "GunsUnlocked",
		["Swords Unlocked"] = "SwordsUnlocked"
	},
	STATUS_LIST = v,
	isPermissionLevelMet = function(p: number, p2)
		if Players.LocalPlayer == nil then
			return true
		end

		if GlobalUtil.FFlags.IsUnitTest then
			return false
		end

		if p == Players.LocalPlayer.UserId then
			return true
		end

		if p2 == "Everyone" then
			return true
		elseif p2 == "Nobody" then
			return false
		end

		if p2 ~= "FriendsOnly" then
			error((`Unknown permission level -> {p2}`))
			return
		end

		local v6 = v5[p]

		if v6 ~= nil then
			return v6
		end

		local success, result = pcall(Players.LocalPlayer.IsFriendsWith, Players.LocalPlayer, p)

		if not success then
			return false
		end

		v5[p] = result
		return result
	end
}
TableUtil.deepFreeze(CONSTANTS2)
return CONSTANTS2