local function resolve(items)
	local services = {}

	for _, item in items do
		local service = game:GetService(item[1])

		for i = 2, #item do
			service = service and service:FindFirstChild(item[i])
		end

		if service and service:IsA("ModuleScript") then
			table.insert(services, service)
		end
	end

	return services
end

return {
	Version = 2,
	IsolatedModules = resolve({
		{ "ReplicatedStorage", "ClientGameModules", "BinderCache" },
		{ "ReplicatedStorage", "ClientGameModules", "BoatTween" },
		{ "ReplicatedStorage", "ClientGameModules", "CameraShaker" },
		{ "ReplicatedStorage", "ClientGameModules", "Color" },
		{ "ReplicatedStorage", "ClientGameModules", "Confetti" },
		{ "ReplicatedStorage", "ClientGameModules", "CreatePriceLabel" },
		{ "ReplicatedStorage", "ClientGameModules", "Icon" },
		{ "ReplicatedStorage", "ClientGameModules", "TextUtility" },
		{ "ReplicatedStorage", "ClientGameModules", "UIHover" },
		{
			"ReplicatedStorage",
			"Common",
			"ADM_LEGO_CLIENT",
			"ADM_Survey_Client"
		},
		{ "ReplicatedStorage", "Common", "BoostsInfo" },
		{ "ReplicatedStorage", "Common", "ColorsUtil" },
		{ "ReplicatedStorage", "Common", "GeolocationWhitelist" },
		{ "ReplicatedStorage", "Common", "ItemsUtil" },
		{ "ReplicatedStorage", "Common", "ParseRankedValue" },
		{ "ReplicatedStorage", "Common", "ProfileCards" },
		{ "ReplicatedStorage", "Common", "RadialSpriteSheetGenerator" },
		{ "ReplicatedStorage", "Common", "ServerEventBoosts" },
		{ "ReplicatedStorage", "Common", "UpdateGiftRewards" },
		{ "ReplicatedStorage", "Common", "Utils" },
		{
			"ReplicatedStorage",
			"Common",
			"Utils",
			"Utilities",
			"CameraUtils"
		},
		{
			"ReplicatedStorage",
			"Common",
			"Utils",
			"Utilities",
			"Inst"
		},
		{
			"ReplicatedStorage",
			"Common",
			"Utils",
			"Utilities",
			"String"
		},
		{
			"ReplicatedStorage",
			"Common",
			"Utils",
			"Utilities",
			"Table"
		},
		{
			"ReplicatedStorage",
			"Common",
			"Utils",
			"Utilities",
			"Thread"
		},
		{
			"ReplicatedStorage",
			"Common",
			"Utils",
			"Utilities",
			"ValueConvertor"
		},
		{ "ReplicatedStorage", "Packages", "Charm" },
		{ "ReplicatedStorage", "Packages", "Chroma" },
		{ "ReplicatedStorage", "Packages", "Conch" },
		{ "ReplicatedStorage", "Packages", "Cooldown" },
		{ "ReplicatedStorage", "Packages", "Flashcast" },
		{ "ReplicatedStorage", "Packages", "Freeze" },
		{ "ReplicatedStorage", "Common", "SettingsInfo" },
		{ "ReplicatedStorage", "Packages", "GameAnalytics" },
		{ "ReplicatedStorage", "Packages", "JSONDencode" },
		{ "ReplicatedStorage", "Packages", "Loader" },
		{ "ReplicatedStorage", "Packages", "Moonlite" },
		{ "ReplicatedStorage", "Packages", "Net" },
		{ "ReplicatedStorage", "Packages", "Observers" },
		{ "ReplicatedStorage", "Packages", "Promise" },
		{ "ReplicatedStorage", "Packages", "Reliever" },
		{ "ReplicatedStorage", "Packages", "Replion" },
		{ "ReplicatedStorage", "ClientGameModules", "OwnsGamePass" },
		{ "ReplicatedStorage", "Packages", "Signal" },
		{ "ReplicatedStorage", "Packages", "SmartBone" },
		{ "ReplicatedStorage", "Packages", "Spring" },
		{ "ReplicatedStorage", "Packages", "Squash" },
		{ "ReplicatedStorage", "Packages", "Serialization" },
		{ "ReplicatedStorage", "Packages", "TimedCache" },
		{ "ReplicatedStorage", "Packages", "Trove" },
		{
			"ReplicatedStorage",
			"Common",
			"Utils",
			"Utilities",
			"Physics"
		},
		{ "ReplicatedStorage", "Packages", "Vide" },
		{ "ReplicatedStorage", "Shared", "AbilityIcons" },
		{ "ReplicatedStorage", "Shared", "AbilityIds" },
		{
			"ReplicatedStorage",
			"Shared",
			"Analytics",
			"ABTestExperiments"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Analytics",
			"ImpressionTrackingData"
		},
		{ "ReplicatedStorage", "Shared", "AnimationProfiles" },
		{ "ReplicatedStorage", "Shared", "AttrGeneration" },
		{
			"ReplicatedStorage",
			"Shared",
			"Battlepass",
			"BattlepassGachaProducts"
		},
		{ "ReplicatedStorage", "Shared", "BattlepassUIType" },
		{ "ReplicatedStorage", "Shared", "Binder" },
		{ "ReplicatedStorage", "Shared", "CherubVariants" },
		{ "ReplicatedStorage", "Shared", "ClanCrateData" },
		{ "ReplicatedStorage", "Shared", "CountriesToRegions" },
		{ "ReplicatedStorage", "Shared", "CustomModeInfo" },
		{ "ReplicatedStorage", "Shared", "CustomModeUtil" },
		{ "ReplicatedStorage", "Shared", "CutsceneUtil" },
		{ "ReplicatedStorage", "Shared", "DebugFlags" },
		{ "ReplicatedStorage", "Shared", "DeepCopy" },
		{ "ReplicatedStorage", "Shared", "DataViewer" },
		{ "ReplicatedStorage", "Shared", "Diamond" },
		{ "ReplicatedStorage", "Shared", "EmoteIds" },
		{
			"ReplicatedStorage",
			"Shared",
			"EmoteTypes",
			"Emote1272Particles"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"EmoteTypes",
			"Emote1272Events"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"EmoteTypes",
			"Utils",
			"Types"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"EmoteTypes",
			"Utils",
			"Visual"
		},
		{ "ReplicatedStorage", "Shared", "FastUtils" },
		{ "ReplicatedStorage", "Shared", "FrameCap" },
		{ "ReplicatedStorage", "Shared", "FreezeSwordConstraints" },
		{ "ReplicatedStorage", "Shared", "GetCountryFlagEmoji" },
		{ "ReplicatedStorage", "Shared", "Hitbox" },
		{ "ReplicatedStorage", "Shared", "HuntData" },
		{ "ReplicatedStorage", "Shared", "IndexData" },
		{
			"ReplicatedStorage",
			"Shared",
			"InfiniteBattlepass",
			"InfiniteBattlepassData",
			"External"
		},
		{ "ReplicatedStorage", "Common", "RewardInfo" },
		{ "ReplicatedStorage", "Common", "BattlepassFreeNotificationReward" },
		{ "ReplicatedStorage", "Common", "DailyLoginInfo" },
		{ "ReplicatedStorage", "Common", "GlobalTieredCrate" },
		{ "ReplicatedStorage", "Common", "PlaytimeRewardsInfo" },
		{ "ReplicatedStorage", "Common", "ReturningUserRewardsInfo" },
		{ "ReplicatedStorage", "Common", "VIPPlusInfo" },
		{
			"ReplicatedStorage",
			"Shared",
			"Battlepass",
			"BattlepassExplosionCrate"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Battlepass",
			"BattlepassPlaytimeRewardsData"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Battlepass",
			"BattlepassSelectionCrate"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Battlepass",
			"BattlepassShopData"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Battlepass",
			"InfiniteGachaRaceRewards"
		},
		{ "ReplicatedStorage", "Shared", "BattlepassEventData" },
		{ "ReplicatedStorage", "Shared", "BossCrate" },
		{
			"ReplicatedStorage",
			"Shared",
			"CNYEvent",
			"CNYEventCrate"
		},
		{ "ReplicatedStorage", "Shared", "ClanPassesData" },
		{ "ReplicatedStorage", "Shared", "ClansLeagueData" },
		{ "ReplicatedStorage", "Shared", "ClansWarData" },
		{ "ReplicatedStorage", "Shared", "ClansData" },
		{ "ReplicatedStorage", "Shared", "ClansRankData" },
		{ "ReplicatedStorage", "Shared", "ClansSearchUtils" },
		{ "ReplicatedStorage", "Shared", "ClansUpgradeData" },
		{ "ReplicatedStorage", "Shared", "CommerceProducts" },
		{ "ReplicatedStorage", "Shared", "DailyLeaderboards" },
		{ "ReplicatedStorage", "Shared", "DuoPassData" },
		{
			"ReplicatedStorage",
			"Shared",
			"Easter",
			"DailyRewards"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Easter",
			"EasterShop"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Easter",
			"EasterSwordCrate"
		},
		{ "ReplicatedStorage", "Shared", "GenericCoinCrateData" },
		{ "ReplicatedStorage", "Shared", "GenericCrateData" },
		{
			"ReplicatedStorage",
			"Shared",
			"InfiniteBattlepass",
			"InfiniteBattlepassData",
			"Rewards"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"InfiniteBattlepass",
			"InfiniteBattlepassData",
			"Types"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"InfiniteBattlepass",
			"InfiniteBattlepassData"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Battlepass",
			"BattlepassCurrencyShopData"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Battlepass",
			"BattlepassDailyLoginRewards"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"InfiniteBattlepass",
			"InfiniteBattlepassTopTiersRewards"
		},
		{ "ReplicatedStorage", "Shared", "InfinityTrial" },
		{ "ReplicatedStorage", "Shared", "InstanceSerde" },
		{
			"ReplicatedStorage",
			"Shared",
			"Inventory",
			"Internal",
			"DefaultItems"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Inventory",
			"Internal",
			"VirtualInventory"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Inventory",
			"InventoryTypes"
		},
		{ "ReplicatedStorage", "Shared", "AdminPanel" },
		{
			"ReplicatedStorage",
			"Shared",
			"Inventory",
			"Internal",
			"Limits"
		},
		{ "ReplicatedStorage", "Shared", "InviteFriendInfo" },
		{ "ReplicatedStorage", "Shared", "InviteRewards" },
		{ "ReplicatedStorage", "Shared", "LTMLeaderboardRewards" },
		{ "ReplicatedStorage", "Shared", "Lambda" },
		{ "ReplicatedStorage", "Shared", "LimitedSwordEvent" },
		{
			"ReplicatedStorage",
			"Shared",
			"LobbyLimitedSwords",
			"ItemBoardData"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"LobbyTraining",
			"MovingTargets"
		},
		{ "ReplicatedStorage", "Shared", "MedalEventInfo" },
		{
			"ReplicatedStorage",
			"Shared",
			"Merchant",
			"MerchantCrate"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Merchant",
			"MerchantFinisherData"
		},
		{ "ReplicatedStorage", "Shared", "MonthlyLeaderboardRewards" },
		{ "ReplicatedStorage", "Shared", "Nanoid" },
		{ "ReplicatedStorage", "Shared", "NumberSpinner" },
		{ "ReplicatedStorage", "Shared", "Packs" },
		{ "ReplicatedStorage", "ClientGameModules", "ClientPackManager" },
		{
			"ReplicatedStorage",
			"Shared",
			"PeriodEvent",
			"Types"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"PeriodEvent",
			"Relics"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"PeriodEvent",
			"Events"
		},
		{ "ReplicatedStorage", "Shared", "PiggyBanksInfo" },
		{ "ReplicatedStorage", "Shared", "Ping" },
		{ "ReplicatedStorage", "Shared", "PlaceGhost" },
		{ "ReplicatedStorage", "Shared", "PlayerNameUtility" },
		{ "ReplicatedStorage", "Shared", "PlayerProfile" },
		{ "ReplicatedStorage", "Shared", "Policy" },
		{ "ReplicatedStorage", "Shared", "Polls" },
		{ "ReplicatedStorage", "Shared", "Quests" },
		{
			"ReplicatedStorage",
			"Shared",
			"RNG",
			"Emotes",
			"Types"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"RNG",
			"PlaytimeLuck"
		},
		{ "ReplicatedStorage", "Shared", "ReducedAbilityPrices" },
		{ "ReplicatedStorage", "Shared", "RegionIcons" },
		{
			"ReplicatedStorage",
			"Shared",
			"RegionalTournament",
			"RegionalTournamentData"
		},
		{ "ReplicatedStorage", "Shared", "ReplionUtils" },
		{ "ReplicatedStorage", "Shared", "RhythmSongProducts" },
		{ "ReplicatedStorage", "Shared", "SafeTeleport" },
		{
			"ReplicatedStorage",
			"Shared",
			"SantaMarket",
			"SantaMarketData"
		},
		{ "ReplicatedStorage", "Shared", "SeasonPassSkip" },
		{ "ReplicatedStorage", "Shared", "SectionedVirtualScroll" },
		{ "ReplicatedStorage", "Shared", "SharedModifiers" },
		{ "ReplicatedStorage", "Shared", "JumpModifiers" },
		{ "ReplicatedStorage", "Shared", "Signal" },
		{ "ReplicatedStorage", "Shared", "Action" },
		{
			"ReplicatedStorage",
			"Shared",
			"SinglePass",
			"SinglePassCrate"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"SinglePass",
			"SinglePassId"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"SinglePass",
			"SinglePassLeaderboard"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"SinglePass",
			"SinglePassRemotes"
		},
		{ "ReplicatedStorage", "Shared", "SpecialTrainingData" },
		{
			"ReplicatedStorage",
			"Shared",
			"SpecialTrainingEvent",
			"SpecialTrainingEventData"
		},
		{ "ReplicatedStorage", "Shared", "SpinWheelSettings" },
		{ "ReplicatedStorage", "Shared", "Sprinkles.story" },
		{ "ReplicatedStorage", "Shared", "EggShaker.story" },
		{ "ReplicatedStorage", "Shared", "StPatricksDayEventData" },
		{ "ReplicatedStorage", "Shared", "Statable" },
		{ "ReplicatedStorage", "ClientGameModules", "DeviceListener" },
		{ "ReplicatedStorage", "ClientGameModules", "FFlagClient" },
		{ "ReplicatedStorage", "Common", "MarketplaceService" },
		{
			"ReplicatedStorage",
			"Common",
			"Utils",
			"Utilities",
			"FFlag"
		},
		{
			"ReplicatedStorage",
			"Common",
			"Utils",
			"Utilities",
			"RewardInfo"
		},
		{
			"ReplicatedStorage",
			"Common",
			"Utils",
			"Utilities",
			"Statable"
		},
		{ "ReplicatedStorage", "Shared", "DynArgs" },
		{ "ReplicatedStorage", "Shared", "NonGiveableItems" },
		{ "ReplicatedStorage", "Shared", "PlayerUtility" },
		{
			"ReplicatedStorage",
			"Shared",
			"SealCrate",
			"SealCrates"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"SinglePass",
			"SinglePassFFlags"
		},
		{ "ReplicatedStorage", "Shared", "StatableCleaner" },
		{ "ReplicatedStorage", "Shared", "Subscriptions" },
		{
			"ReplicatedStorage",
			"Shared",
			"Summer",
			"SummerEvent"
		},
		{ "ReplicatedStorage", "Shared", "SpinWheelRewards" },
		{ "ReplicatedStorage", "Shared", "TeamData" },
		{ "ReplicatedStorage", "Shared", "ThreadSafeTargetingHelper" },
		{ "ReplicatedStorage", "Shared", "Time" },
		{ "ReplicatedStorage", "Shared", "TournamentData" },
		{
			"ReplicatedStorage",
			"Shared",
			"TournamentEvent",
			"TournamentEventShop"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"TournamentEvent",
			"TournamentEventTopRewards"
		},
		{ "ReplicatedStorage", "Shared", "TrioPassData" },
		{ "ReplicatedStorage", "Shared", "TweenColor" },
		{ "ReplicatedStorage", "Shared", "UGCTracker" },
		{
			"ReplicatedStorage",
			"Shared",
			"ThemedQuests",
			"ThemedQuestsData"
		},
		{ "ReplicatedStorage", "Shared", "UiPresets" },
		{ "ReplicatedStorage", "Shared", "UniverseIds" },
		{ "ReplicatedStorage", "ServerInfo" },
		{ "ReplicatedStorage", "ClientGameModules", "CoreCall" },
		{ "ReplicatedStorage", "ClientGameModules", "GuiHandler" },
		{ "ReplicatedStorage", "Common", "Logger" },
		{ "ReplicatedStorage", "Common", "StudioLogger" },
		{ "ReplicatedStorage", "Shared", "AbilityTimelineHandler" },
		{ "ReplicatedStorage", "Shared", "BlackFridayPackData" },
		{ "ReplicatedStorage", "Shared", "BossPortalData" },
		{
			"ReplicatedStorage",
			"Shared",
			"CNYEvent",
			"CNYEventItemData"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"CustomMode",
			"CustomModeUtils"
		},
		{ "ReplicatedStorage", "Shared", "December2025CalendarInfo" },
		{ "ReplicatedStorage", "Shared", "DeleteItemUtils" },
		{
			"ReplicatedStorage",
			"Shared",
			"Easter",
			"EasterEvent"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Easter",
			"EggHunt"
		},
		{ "ReplicatedStorage", "Shared", "EasterGachaData" },
		{ "ReplicatedStorage", "Shared", "GameModes" },
		{ "ReplicatedStorage", "Shared", "GetAbilityCooldownMultiplier" },
		{ "ReplicatedStorage", "Shared", "GetServerType" },
		{ "ReplicatedStorage", "Shared", "HourlyWheelData" },
		{ "ReplicatedStorage", "Shared", "LTM" },
		{ "ReplicatedStorage", "Shared", "LTMCrateData" },
		{ "ReplicatedStorage", "Shared", "LimitedSwordPacksData" },
		{ "ReplicatedStorage", "Shared", "LimitedTimePackData" },
		{
			"ReplicatedStorage",
			"Shared",
			"LobbyLimitedSwords",
			"ClientSetLimitedsVisible"
		},
		{ "ReplicatedStorage", "Shared", "MapData" },
		{
			"ReplicatedStorage",
			"Shared",
			"Merchant",
			"MerchantShopData"
		},
		{ "ReplicatedStorage", "Shared", "RankedPenaltyData" },
		{ "ReplicatedStorage", "Shared", "RankedSeasonData" },
		{ "ReplicatedStorage", "Shared", "RankData" },
		{ "ReplicatedStorage", "Shared", "PlayerData" },
		{ "ReplicatedStorage", "Shared", "ReplicatedInstances" },
		{ "ReplicatedStorage", "Shared", "ReplicatedInstancesUtils" },
		{
			"ReplicatedStorage",
			"Shared",
			"ReplicatedInstances",
			"Booths"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"ReplicatedInstances",
			"EmoteAccessories"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"ReplicatedInstances",
			"EmoteVFX"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"EmoteTypes",
			"EnableAndEmit"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"EmoteTypes",
			"Passive"
		},
		{ "ReplicatedStorage", "Shared", "Emotes" },
		{
			"ReplicatedStorage",
			"Shared",
			"ReplicatedInstances",
			"Explosions"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"ReplicatedInstances",
			"Finishers"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"ReplicatedInstances",
			"SwordAccessories"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"ReplicatedInstances",
			"SwordFX"
		},
		{ "ReplicatedStorage", "Shared", "SeasonPassData" },
		{
			"ReplicatedStorage",
			"Shared",
			"NewQuests",
			"Quests"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"NewQuests",
			"QuestUtility"
		},
		{ "ReplicatedStorage", "Shared", "SecretAwakenData" },
		{ "ReplicatedStorage", "Shared", "ServerBrowserData" },
		{ "ReplicatedStorage", "Shared", "ServerRanking" },
		{ "ReplicatedStorage", "Shared", "SpeedModifiers" },
		{ "ReplicatedStorage", "Shared", "SummerWheelData" },
		{ "ReplicatedStorage", "Shared", "SwordAPI" },
		{
			"ReplicatedStorage",
			"Shared",
			"ReplicatedInstances",
			"Swords"
		},
		{ "ReplicatedStorage", "Common", "CratesContent" },
		{
			"ReplicatedStorage",
			"Common",
			"Utils",
			"Utilities",
			"SwordUtil"
		},
		{
			"ReplicatedStorage",
			"Common",
			"Utils",
			"Utilities",
			"Icons"
		},
		{ "ReplicatedStorage", "Shared", "NewQuestData" },
		{ "ReplicatedStorage", "Shared", "SynthWheelData" },
		{ "ReplicatedStorage", "Shared", "TitleData" },
		{ "ReplicatedStorage", "Shared", "TournamentCrateData" },
		{
			"ReplicatedStorage",
			"Shared",
			"TournamentEvent",
			"TournamentEventCrate"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"TournamentEvent",
			"TournamentEventData"
		},
		{ "ReplicatedStorage", "Shared", "UntradableItems" },
		{ "ReplicatedStorage", "Shared", "UpdateCrate" },
		{ "ReplicatedStorage", "Shared", "UpdateLogs" },
		{ "ReplicatedStorage", "Shared", "UseBall2" },
		{ "ReplicatedStorage", "Shared", "BotAbilities" },
		{ "ReplicatedStorage", "Shared", "UseMapVoting" },
		{ "ReplicatedStorage", "Shared", "UseNewLobby" },
		{ "ReplicatedStorage", "Shared", "UseNewServerBrowser" },
		{ "ReplicatedStorage", "Shared", "VRService" },
		{ "ReplicatedStorage", "Shared", "ValentinesBundle" },
		{ "ReplicatedStorage", "Shared", "GiftProductsId" },
		{ "ReplicatedStorage", "Shared", "VirtualGridScroll" },
		{ "ReplicatedStorage", "Shared", "WeightRandom" },
		{
			"ReplicatedStorage",
			"Shared",
			"RNG",
			"Emotes"
		},
		{ "ReplicatedStorage", "Shared", "EmotesShared" },
		{ "ReplicatedStorage", "Shared", "ItemInfo" },
		{ "ReplicatedStorage", "Shared", "Abilities" },
		{ "ReplicatedStorage", "Shared", "WelcomeBackCrate" },
		{ "ReplicatedStorage", "Shared", "t" },
		{
			"ReplicatedStorage",
			"Shared",
			"Trading",
			"TradeInfo"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Inventory",
			"Shared"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Inventory",
			"Client"
		},
		{ "ReplicatedStorage", "Shared", "Inventory" },
		{ "ReplicatedStorage", "Common", "GachaItemsData" },
		{ "ReplicatedStorage", "Shared", "AbilityUtils" },
		{ "ReplicatedStorage", "Shared", "AutoDeleteContainers" },
		{ "ReplicatedStorage", "Shared", "ClansActivityData" },
		{
			"ReplicatedStorage",
			"Shared",
			"LobbyLimitedSwords",
			"NPCLobbyAnimation"
		},
		{ "ReplicatedStorage", "Shared", "LootboxData" },
		{ "ReplicatedStorage", "Shared", "ProgressiveRewardsData" },
		{
			"ReplicatedStorage",
			"Shared",
			"Trading",
			"TradeTokensUtils"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"Trading",
			"TradingTokens"
		},
		{
			"ReplicatedStorage",
			"Shared",
			"LobbyLimitedSwords",
			"ClientLimitedHandler"
		},
		{ "ReplicatedStorage", "Shared", "WelcomeBackData" }
	}),
	IsolatedControllers = resolve({
		{ "ReplicatedStorage", "Controllers", "AnimationController" },
		{ "ReplicatedStorage", "Controllers", "CinematicController" },
		{ "ReplicatedStorage", "Controllers", "GamepadIconController" },
		{ "ReplicatedStorage", "Controllers", "HotbarController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Infection",
			"PlayerDamagedController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"LTM",
			"DroneController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"LTM",
			"LobbyCrateController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Lobby",
			"ProximityPromptController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"TooltipController"
		},
		{ "ReplicatedStorage", "Controllers", "DebugController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Easter",
			"EggDropController"
		},
		{ "ReplicatedStorage", "Controllers", "EncryptedAssetController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"FallingPlate",
			"LTMPlateController"
		},
		{ "ReplicatedStorage", "Controllers", "FatesSelectionController" },
		{ "ReplicatedStorage", "Controllers", "LocalPlayerFriendedController" },
		{ "ReplicatedStorage", "Controllers", "LogController" },
		{ "ReplicatedStorage", "Controllers", "TeamsOverheadController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"DeathScreenController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"GlobalMessageController"
		},
		{ "ReplicatedStorage", "Controllers", "ComponentsController" },
		{ "ReplicatedStorage", "Controllers", "LobbyTrainingController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"ExperienceNotifications",
			"ExperienceNotificationController"
		},
		{ "ReplicatedStorage", "Controllers", "KillstreakController" },
		{ "ReplicatedStorage", "Controllers", "SubscriptionController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"TournamentsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"DialogueController"
		},
		{ "ReplicatedStorage", "Controllers", "PurchaseScreenController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Ranked",
			"RankedSignalController"
		},
		{ "ReplicatedStorage", "Controllers", "CoinDropController" },
		{ "ReplicatedStorage", "Controllers", "LiveEventController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Lobby",
			"GravityController"
		},
		{ "ReplicatedStorage", "Controllers", "PromptController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Trading",
			"TradeController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"SoftShutdownController"
		},
		{ "ReplicatedStorage", "Controllers", "VisualizerController" },
		{ "ReplicatedStorage", "Controllers", "ABTestController" },
		{ "ReplicatedStorage", "Controllers", "RedLightGreenLightController" },
		{ "ReplicatedStorage", "Controllers", "TagModeController" },
		{ "ReplicatedStorage", "Controllers", "ReturningUserRewardsController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"LTM",
			"OverdriveLTMController"
		},
		{ "ReplicatedStorage", "Controllers", "CutsceneController" },
		{ "ReplicatedStorage", "Controllers", "CustomModeRulesController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"AdminPanelUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelModerationHistoryUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"UIStateController"
		},
		{ "ReplicatedStorage", "Controllers", "AdminAbuseController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelModerationUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelUserUIController"
		},
		{ "ReplicatedStorage", "Controllers", "DuelController" },
		{ "ReplicatedStorage", "Controllers", "DuelPartyController" },
		{ "ReplicatedStorage", "Controllers", "GenericCoinCrateController" },
		{ "ReplicatedStorage", "Controllers", "InviteFriendsController" },
		{ "ReplicatedStorage", "Controllers", "LeaderboardController" },
		{ "ReplicatedStorage", "Controllers", "NotificationController" },
		{ "ReplicatedStorage", "Controllers", "PeriodEventController" },
		{ "ReplicatedStorage", "Controllers", "PiggyBankController" },
		{ "ReplicatedStorage", "Controllers", "PollController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Ranked",
			"RankedLeaderboardController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"RegionalTournament",
			"RegionalTournamentController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Rhythm",
			"RhythmLTMPlayController"
		},
		{ "ReplicatedStorage", "Controllers", "SecretAwakenController" },
		{ "ReplicatedStorage", "Controllers", "ServerTypeController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"SquadRoyale",
			"SquadRoyaleInviteController"
		},
		{ "ReplicatedStorage", "Controllers", "TokenDropController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"UI",
			"TournamentsUIBracketsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tutorial",
			"TutorialSkipPromptController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"CreatorCodesController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"InviteRewardsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"ModerationHistoryController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"PersonalStatsController"
		},
		{ "ReplicatedStorage", "Controllers", "WelcomeBackController" },
		{ "ReplicatedStorage", "Controllers", "LobbyPortalController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"SinglePass",
			"SinglePassController"
		},
		{ "ReplicatedStorage", "Controllers", "MobileLobbyController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"TopBarController"
		},
		{ "ReplicatedStorage", "Controllers", "ConchController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"CodesController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"PlaytimeRewardsController"
		},
		{ "ReplicatedStorage", "Controllers", "HourlyWheelController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Infection",
			"GameRoleController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Infection",
			"LTMFirstTimeController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"LTM",
			"HovergoalPointsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"LTM",
			"LTMCustomDashController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"LTM",
			"LTMPhaseController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"LTM",
			"RoundPointsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"LTM",
			"SheriffsVsOutlawsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"LTM",
			"StormController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"SpectateController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"VotingController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"LTM",
			"LTMSpinController"
		},
		{ "ReplicatedStorage", "Controllers", "AntiFlingController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Ranked",
			"ChooseMapController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Ranked",
			"MatchFoundController"
		},
		{ "ReplicatedStorage", "Controllers", "TrainingModeController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Ranked",
			"RankedPenaltyController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"UI",
			"TournamentDisconnectController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"LeaderboardRewardsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"RankedDisconnectController"
		},
		{ "ReplicatedStorage", "Controllers", "RankMenuController" },
		{ "ReplicatedStorage", "Controllers", "RankUpAnimationController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Ranked",
			"RankedQueueController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"RankedSelectionController"
		},
		{ "ReplicatedStorage", "Controllers", "VFXController" },
		{ "ReplicatedStorage", "Controllers", "SerpentBreakoutQuestController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"SinglePass",
			"SinglePassGoalsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"SinglePass",
			"SinglePassQuestsController"
		},
		{ "ReplicatedStorage", "Controllers", "OldServerBrowserController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Lobby",
			"ItemBoardController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Rhythm",
			"RhythmLTMController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Rhythm",
			"RhythmLTMSongSelectorController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"Event",
			"TournamentEventBracketsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"UpdateLogController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Lobby",
			"MapVoteController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"GroupCrate",
			"GroupCrateController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tutorial",
			"TutorialController"
		},
		{ "ReplicatedStorage", "Controllers", "ServerBrowserController" },
		{ "ReplicatedStorage", "Controllers", "SettingsController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Trading",
			"TradingSignController"
		},
		{ "ReplicatedStorage", "Controllers", "AnalyticsController" },
		{ "ReplicatedStorage", "Controllers", "BallIndicatorController" },
		{ "ReplicatedStorage", "Controllers", "DynamicSpectatorController" },
		{ "ReplicatedStorage", "Controllers", "GenericCrateAnimationController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Merchant",
			"MerchantCrateAnimationController"
		},
		{ "ReplicatedStorage", "Controllers", "QuestController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"SinglePass",
			"SinglePassAnimationController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"SinglePass",
			"SinglePassCrateController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"DailyLoginController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"EditButtonLayoutController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Clans",
			"ClanController"
		},
		{ "ReplicatedStorage", "Controllers", "ServerSelectionController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Booth",
			"BoothController"
		},
		{ "ReplicatedStorage", "Controllers", "DeleteItemPromptController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"LTM",
			"LTMCurrencyController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"SinglePass",
			"SinglePassShopController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Trading",
			"RAPController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Trading",
			"ExistCounterController"
		},
		{ "ReplicatedStorage", "Controllers", "AbilityController" },
		{ "ReplicatedStorage", "Controllers", "EmoteController" },
		{ "ReplicatedStorage", "Controllers", "SwordsController \f" },
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"ShopControllerAPI"
		},
		{ "ReplicatedStorage", "Controllers", "HoverInfoController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelBoothHistoryUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelDuelsHistoryUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelTradeHistoryUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Booth",
			"UI",
			"BoothHistoryUIController"
		},
		{ "ReplicatedStorage", "Controllers", "MonthlyLeaderboardController" },
		{ "ReplicatedStorage", "Controllers", "StPatricksDayEventController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Trading",
			"InventoryController"
		},
		{ "ReplicatedStorage", "Controllers", "EmoteWheelController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"MonthlyLeaderboardRewardsController"
		},
		{ "ReplicatedStorage", "Controllers", "ViewInventoryController" },
		{ "ReplicatedStorage", "Controllers", "AutoDeleteItemController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Clans",
			"UI",
			"ClanCrateController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Trading",
			"TradeTokensController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Boss",
			"BossUIController"
		},
		{ "ReplicatedStorage", "Controllers", "GiftingController" },
		{ "ReplicatedStorage", "Controllers", "InfinityTrialController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"LTM",
			"LTMPackController"
		},
		{ "ReplicatedStorage", "Controllers", "LimitedTimePackController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Packs",
			"FreezePackController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"SinglePass",
			"SinglePassCurrencyPurchaseController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"SinglePass",
			"SinglePassDailyRewardsController"
		},
		{ "ReplicatedStorage", "Controllers", "TournamentCrateController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"Event",
			"TournamentEventController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"Event",
			"TournamentEventCrateController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"Event",
			"TournamentEventInviteController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"Event",
			"TournamentEventLeaderboardController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"CyberPackController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"GiftInventoryController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"HellfirePackController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"SealCrateController"
		},
		{ "ReplicatedStorage", "Controllers", "ValentinesBundleController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Trading",
			"TradeRequestController"
		},
		{ "ReplicatedStorage", "Controllers", "PlayerProfileController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Trading",
			"TradePINCodeController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Trading",
			"TradePlazaController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Trading",
			"TradeTabController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"HUDController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Clans",
			"ClanPageController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Clans",
			"UI",
			"ClanCrateItemsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Clans",
			"UI",
			"ClanPagesController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Clans",
			"UI",
			"ClanInviteController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Clans",
			"UI",
			"ClanManagerController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Clans",
			"UI",
			"ClanPopupController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Clans",
			"UI",
			"ClanCreateController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Clans",
			"UI",
			"ClanOverviewController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Clans",
			"UI",
			"ClanNoClanController"
		},
		{ "ReplicatedStorage", "Controllers", "DuelQuickPlayController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Easter",
			"EasterPageController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Easter",
			"EasterCrateAnimationController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Easter",
			"Views",
			"EasterButtonController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Easter",
			"Views",
			"EasterDailyRewardsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Easter",
			"Views",
			"EasterEggAdminEventController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Easter",
			"Views",
			"EasterEggHuntController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Easter",
			"Views",
			"EasterEggShopController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Easter",
			"Views",
			"EasterHatchEggController"
		},
		{ "ReplicatedStorage", "Controllers", "KillCamController" },
		{ "ReplicatedStorage", "Controllers", "KillFeedController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Merchant",
			"MerchantShopController"
		},
		{ "ReplicatedStorage", "Controllers", "ShowRoomController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"BattlepassEventController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"BattlepassViewController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"BattlepassController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"BattlepassCurrencyShopController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"BattlepassQuestsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"BattlepassTeamController"
		},
		{ "ReplicatedStorage", "Controllers", "FinishersController" },
		{ "ReplicatedStorage", "Controllers", "HalloweenGachaNPCController" },
		{ "ReplicatedStorage", "Controllers", "InputController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"LavaFloor",
			"ObbyParticipantsController"
		},
		{ "ReplicatedStorage", "Controllers", "SwordForgeController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"UI",
			"TournamentsUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"Event",
			"TournamentEventUIEndController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"UI",
			"TournamentsUICustomController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"UI",
			"TournamentsUIEndController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"UI",
			"TournamentsUIEventController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"UI",
			"TournamentsUIPlayController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"UI",
			"TournamentsUIRoomsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"UI",
			"TournamentsUITopController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Trading",
			"IndexController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelDataUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelExistCountUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelGrantTokensController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelInventoryUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelLeaderboardsUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelPendingChangesUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelTradingUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"AdminPanel",
			"UI",
			"AdminPanelTransactionsUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"BattlepassExplosionCrateController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"BattlepassPlaytimeRewardsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"BattlepassSelectionCrateController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"BattlepassShopController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"BattlepassSpinGachaController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"BattlepassTierController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"GachaRaceController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Battlepass",
			"InfiniteBattlepass",
			"InfiniteBattlepassLeaderboardController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Commerce",
			"PuppyPlushController"
		},
		{ "ReplicatedStorage", "Controllers", "GlobalTieredCrateController" },
		{ "ReplicatedStorage", "Controllers", "ItemDuelsController" },
		{ "ReplicatedStorage", "Controllers", "MerchShopController" },
		{
			"ReplicatedStorage",
			"Controllers",
			"Merchant",
			"MerchantFinisherController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Ranked",
			"RankedRewardListController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"SinglePass",
			"SinglePassTopPrizesController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"Event",
			"TournamentCrateController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Tournaments",
			"Event",
			"TournamentEventShopController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Trading",
			"RAPChartController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Booth",
			"UI",
			"BoothInventoryUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"Booth",
			"UI",
			"BoothUIController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"AFKController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"DuoPassController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"GenericGachaController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"HalloweenGachaLuckIncreaseController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"LimitedSwordPacksController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"NewShowcaseController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"QuestsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"ShopController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"AbilityBanVotingController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"AbilityVotingController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"ShopPurchaseAbilityTutorialController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"ThemedQuestsController"
		},
		{
			"ReplicatedStorage",
			"Controllers",
			"UI",
			"TrioPassController"
		}
	})
}