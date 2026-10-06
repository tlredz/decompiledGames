game:GetService("ReplicatedStorage")
require("@game/ReplicatedStorage/Omni/Settings")
return {
	Yen = 0,
	MarketplacePurchaseId = 0,
	BanExpiresAt = 0,
	Gamemode = nil,
	GamemodeSession = nil,
	Banned = false,
	ShadowBanned = false,
	Trade = {
		Pending = nil
	},
	Commerce = {
		Revision = 0,
		Generation = "",
		ResetPending = nil,
		GemSequence = 0,
		GemPurchases = {},
		PassOrigins = {},
		RandomBenefitsAllowed = false,
		Purchases = {},
		Receipts = {},
		PendingReceipts = {},
		Intents = {},
		ReleasedIntents = {},
		RewardClaims = {},
		Potions = {},
		PotionOrigins = {},
		ConversionSequence = 0
	},
	Economy = {
		Version = 0,
		Balances = {
			Item = {},
			Currency = {}
		}
	},
	Analytics = {
		Version = 0,
		ActivatedAt = 0,
		OnboardingEligible = false,
		OnboardingStep = 0,
		OnboardingStepAt = 0,
		OnboardingFlags = 0,
		AcquisitionSource = "",
		AcquisitionCampaign = "",
		FirstJoinTime = 0,
		SessionCount = 0,
		LastSessionStart = 0,
		LastSessionEnd = 0,
		TimePlayed = 0,
		DaysPlayed = 0,
		LastPlayDay = 0,
		FirstPurchaseTime = 0,
		FirstGemsPurchaseTime = 0,
		RobuxSpent = 0,
		PurchaseCount = 0,
		RobuxPasses = {},
		RevokedPasses = {},
		VisitedMaps = {}
	},
	Tutorial = {
		Status = "None",
		Step = 0,
		Rewarded = false,
		Eligible = false
	},
	Mounts = {
		Equipped = {},
		List = {}
	},
	SoftPity = {},
	Pity = {},
	Breathings = {
		AutoStop = {}
	},
	Traits = {
		AutoStop = {},
		Pity = {}
	},
	Index = {},
	Gacha = {},
	Accessories = {
		Equipped = {},
		List = {},
		Loadouts = {},
		AutoLock = {},
		AutoDelete = {}
	},
	Quests = {
		Pinned = nil,
		List = {}
	},
	Inbox = {
		List = {}
	},
	Profile = {
		Title = nil,
		Banner = nil,
		Titles = {},
		Banners = {},
		Stats = {},
		Fighters = {},
		ChatTags = {}
	},
	Weapons = {
		Equipped = nil,
		List = {},
		AutoLock = {},
		AutoDelete = {}
	},
	Stars = {
		Settings = {}
	},
	Progression = {
		Auto = {},
		List = {}
	},
	AutoRoll = {},
	Upgrade = {},
	Profession = {},
	Merchant = {},
	Maps = {
		Current = nil,
		List = {}
	},
	DailyRewards = {
		Start = 0,
		Claimed = {}
	},
	TimeRewards = {
		TimePlayed = 0,
		Claimed = {},
		ResetAt = nil
	},
	TimeChamber = {
		Time = 0,
		Role = nil,
		EarlyAccess = false,
		Finished = false,
		Claimed = {},
		Periodic = {},
		Chance = {},
		Random = {
			Progress = 0,
			Rolls = 0,
			Rewards = {}
		}
	},
	RoleRewards = {
		Claimed = {}
	},
	Level = {
		Exp = 0,
		Amount = 1,
		Stats = {},
		Rewards = {}
	},
	Prestige = {
		Amount = 0
	},
	Achievements = {},
	IndexRewards = {
		Fighters = {},
		Accessories = {},
		Weapons = {}
	},
	Fighters = {
		Teams = {},
		Equipped = {},
		List = {}
	},
	Items = {
		List = {
			["Free Gems"] = 0,
			["Paid Gems"] = 0
		}
	},
	Guild = {
		GuildId = nil,
		Rank = nil,
		UpgradeLevels = {},
		Invites = {}
	},
	SavedPositions = {},
	Badges = {},
	Products = {},
	Gamepasses = {},
	MarketplaceHistory = {},
	DropsHistory = {
		StartedAt = 0,
		Sources = {}
	},
	Settings = {}
}