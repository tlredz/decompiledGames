local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CCPermissionsTemplate = require(ReplicatedStorage.CCPanel.CCPermissionsTemplate)
local ConfigWorld1 = {
	WORLD = 1
}

function ConfigWorld1.IsWorld(_, p: number)
	return ConfigWorld1.WORLD == p
end

ConfigWorld1.SECURITY = {
	MAX_SPEED_ALLOWED = 250,
	DISTANCE_MARGIN = 2,
	TELEPORT_COOLDOWN = 0.5,
	STATION_MARGIN = 20
}
ConfigWorld1.STEP_AWARDS = {
	Award1 = {
		Bonus = 1,
		ReqWins = 0
	},
	Award2 = {
		Bonus = 2,
		ReqWins = 3
	},
	Award3 = {
		Bonus = 5,
		ReqWins = 15
	},
	Award4 = {
		Bonus = 25,
		ReqWins = 100
	},
	Award5 = {
		Bonus = 50,
		ReqWins = 500
	},
	Award6 = {
		Bonus = 100,
		ReqWins = 2500
	},
	Award7 = {
		Bonus = 250,
		ReqWins = 15000
	},
	Award8 = {
		Bonus = 500,
		ReqWins = 50000
	}
}
ConfigWorld1.TRAILS = {
	GreenTrail = {
		Multiplier = 1.5,
		Price = 500,
		Gamepass = 1705638621,
		Color = ColorSequence.new(Color3.fromRGB(4, 182, 10))
	},
	BlueTrail = {
		Multiplier = 2,
		Price = 1500,
		Gamepass = 1705790528,
		Color = ColorSequence.new(Color3.fromRGB(0, 73, 190))
	},
	PurpleTrail = {
		Multiplier = 3,
		Price = 5000,
		Gamepass = 1705766445,
		Color = ColorSequence.new(Color3.fromRGB(136, 0, 190))
	},
	RedTrail = {
		Multiplier = 4,
		Price = 25000,
		Gamepass = 1705880432,
		Color = ColorSequence.new(Color3.fromRGB(186, 0, 3))
	},
	RainbowTrail = {
		Multiplier = 5,
		Price = 100000,
		Gamepass = 1705872346,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
		})
	},
	GalaxyTrail = {
		Multiplier = 10,
		Price = 0,
		Gamepass = 1705684677,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 50)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 150))
		})
	},
	CosmicTrail = {
		Multiplier = 100,
		Price = 5000000,
		Gamepass = 1826883825,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 100, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
		})
	},
	VoidTrail = {
		Multiplier = 1000,
		Price = 50000000,
		Gamepass = 1829431034,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 0, 100)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
		})
	},
	SupernovaTrail = {
		Multiplier = 10000,
		Price = 500000000,
		Gamepass = 1828536440,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 100)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 200))
		})
	},
	GodlikeTrail = {
		Multiplier = 100000,
		Price = 5000000000,
		Gamepass = 1825327908,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(200, 0, 30)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 215, 0)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 200))
		})
	},
	InfinityTrail = {
		Multiplier = 5000000,
		Price = 0,
		Gamepass = 1829496998,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 220, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 180, 255))
		})
	}
}
ConfigWorld1.DEFAULT_TRAIL = "None"
ConfigWorld1.GROUP_ID = 1074557114
ConfigWorld1.GIFT_REWARD = 15000
ConfigWorld1.BADGE_IDS = {
	WELCOME = 1420201693079850,
	REBIRTH = 2153967300203954
}
ConfigWorld1.USE_DEVPRODUCT_SPEED = false
ConfigWorld1.SPEED_UPGRADES = {
	{
		Tier = 1,
		Multiplier = 2,
		ID = 1674499710,
		Price = 3,
		DevProductId = 0
	},
	{
		Tier = 2,
		Multiplier = 4,
		ID = 1675776515,
		Price = 9,
		DevProductId = 0
	},
	{
		Tier = 3,
		Multiplier = 8,
		ID = 1681102268,
		Price = 24,
		DevProductId = 0
	},
	{
		Tier = 4,
		Multiplier = 16,
		ID = 1684020325,
		Price = 39,
		DevProductId = 0
	},
	{
		Tier = 5,
		Multiplier = 32,
		ID = 1683754343,
		Price = 79,
		DevProductId = 0
	},
	{
		Tier = 6,
		Multiplier = 64,
		ID = 1684176331,
		Price = 129,
		DevProductId = 0
	},
	{
		Tier = 7,
		Multiplier = 128,
		ID = 1683446348,
		Price = 199,
		DevProductId = 0
	},
	{
		Tier = 8,
		Multiplier = 256,
		ID = 1683918331,
		Price = 299,
		DevProductId = 0
	},
	{
		Tier = 9,
		Multiplier = 512,
		ID = 1683374348,
		Price = 449,
		DevProductId = 0
	},
	{
		Tier = 10,
		Multiplier = 1024,
		ID = 1682706361,
		Price = 649,
		DevProductId = 0
	},
	{
		Tier = 11,
		Multiplier = 2048,
		ID = 1825333938,
		Price = 949,
		DevProductId = 0
	},
	{
		Tier = 12,
		Multiplier = 4096,
		ID = 1827574761,
		Price = 1375,
		DevProductId = 0
	}
}
ConfigWorld1.GAMEPASS_IDS = {
	WINS_X2 = 1675021026,
	GOLD_ACCESS = 1674743386,
	DIAMOND_ACCESS = 1724758929,
	CANDY_ACCESS = 1799448573,
	ADMIN_ACCESS = 1799430547,
	SOUNDPACK_ACCESS = 1724877043
}
ConfigWorld1.DEV_PRODUCTS = {
	SPEED_150K = 3516546135,
	SPEED_1M = 3516546329,
	SPEED_10M = 3516546512,
	SPEED_50M = 3549331385,
	SPEED_500M = 3549331706,
	SPEED_1B = 3549331820,
	INSTANT_REBIRTH_T1 = 3523582310,
	INSTANT_REBIRTH_T2 = 3588524269,
	INSTANT_REBIRTH_T3 = 3588524394,
	REVIVE = RunService:IsStudio() and 3591855647 or 3583707964
}
ConfigWorld1.PERCENTAGE_SPEED_BOOSTS = {
	{
		Key = "Boost150K",
		Percent = 0.02,
		MinAmount = 150000,
		ProductId = ConfigWorld1.DEV_PRODUCTS.SPEED_150K
	},
	{
		Key = "Boost1M",
		Percent = 0.05,
		MinAmount = 1000000,
		ProductId = ConfigWorld1.DEV_PRODUCTS.SPEED_1M
	},
	{
		Key = "Boost10M",
		Percent = 0.12,
		MinAmount = 10000000,
		ProductId = ConfigWorld1.DEV_PRODUCTS.SPEED_10M
	},
	{
		Key = "Boost50M",
		Percent = 0.25,
		MinAmount = 50000000,
		ProductId = ConfigWorld1.DEV_PRODUCTS.SPEED_50M
	},
	{
		Key = "Boost500M",
		Percent = 0.6,
		MinAmount = 500000000,
		ProductId = ConfigWorld1.DEV_PRODUCTS.SPEED_500M
	},
	{
		Key = "Boost1B",
		Percent = 1.2,
		MinAmount = 1000000000,
		ProductId = ConfigWorld1.DEV_PRODUCTS.SPEED_1B
	}
}
ConfigWorld1.STEP_DISTANCE = 3
ConfigWorld1.DEFAULT_WALKSPEED = 10
ConfigWorld1.MAX_LEVEL_SPEED_CAP = 300
ConfigWorld1.SPAWN_OFFSET = vector.create(0, 5, 0)
ConfigWorld1.SPEED_GAIN_PER_LEVEL = 2
ConfigWorld1.TREADMILL_CHECK_INTERVAL = 0.15
ConfigWorld1.TREADMILL_CHECK_RANGE = 2
ConfigWorld1.TREADMILL_HEIGHT_RANGE = 5
ConfigWorld1.BASE_XP = 100
ConfigWorld1.XP_GROWTH = 1.15
ConfigWorld1.XP_EXPONENT = 1.15

function ConfigWorld1.GetXPRequired(p: number)
	if p <= 0 then
		return 0
	end

	return (math.round(ConfigWorld1.BASE_XP * ConfigWorld1.XP_GROWTH ^ (p - 1)))
end

ConfigWorld1.DEFAULT_DATA = {
	TotalXP = 0,
	Level = 1,
	XP = 0,
	Wins = 0,
	Rebirths = 0,
	Multiplier = 1,
	StepBonus = 1,
	CustomWalkSpeed = 0,
	GiftClaimed = false,
	ManualGoldAccess = false,
	ManualDiamondAccess = false,
	ManualCandyAccess = false,
	ManualAdminAccess = false,
	GamepassReceived = {},
	GiftSent = {},
	GiftReceived = {},
	OwnedTrails = {},
	EquippedTrail = "None",
	OwnedAuras = {},
	EquippedAura = "None",
	Items = {},
	EquippedItems = {},
	firstJoin = 0,
	timePlayed = 0,
	Checkpoint = 0,
	PurchaseHistory = {},
	TikfinityBinds = {},
	SpeedBoostTier = 0,
	EventRsvpClaimed = {},
	SocialCodeClaimed = false,
	SocialResetAppliedAt = 0,
	CheatHistory = {},
	CheatHistory2 = {},
	VIP_ID = false,
	X2Boost = false,
	CCPermissions = CCPermissionsTemplate,
	RefundedItems = false,
	MedalRewardClaimed = false,
	AfkPosition = false,
	CheckInfinityTrailGlitch = false
}
ConfigWorld1.REBIRTH_TIERS = {
	{
		level = 15,
		multiplier = 1.5
	},
	{
		level = 25,
		multiplier = 2
	},
	{
		level = 40,
		multiplier = 2.5
	},
	{
		level = 60,
		multiplier = 3
	},
	{
		level = 75,
		multiplier = 3.5
	},
	{
		level = 100,
		multiplier = 4
	},
	{
		level = 125,
		multiplier = 5
	},
	{
		level = 150,
		multiplier = 6
	},
	{
		level = 175,
		multiplier = 7.5
	},
	{
		level = 200,
		multiplier = 10
	},
	{
		level = 225,
		multiplier = 100
	},
	{
		level = 260,
		multiplier = 1000
	},
	{
		level = 300,
		multiplier = 10000
	},
	{
		level = 340,
		multiplier = 100000
	},
	{
		level = 380,
		multiplier = 1000000
	},
	{
		level = 420,
		multiplier = 10000000
	},
	{
		level = 465,
		multiplier = 100000000
	},
	{
		level = 510,
		multiplier = 1000000000
	},
	{
		level = 560,
		multiplier = 10000000000
	},
	{
		level = 600,
		multiplier = 100000000000
	}
}
ConfigWorld1.WIN_AMOUNTS = {
	WinBlock = 1,
	WinBlock2 = 3,
	WinBlock3 = 10,
	WinBlock4 = 20,
	WinBlock5 = 50,
	WinBlock6 = 100,
	WinBlock7 = 150,
	WinBlock8 = 300,
	WinBlock9 = 500,
	WinBlock10 = 1000,
	WinBlock11 = 2500,
	WinBlock12 = 10000,
	WinBlock13 = 25000,
	WinBlock14 = 50000,
	WinBlock15 = 150000
}
ConfigWorld1.WIN_MIN_TIMES = {
	WinBlock2 = 0,
	WinBlock3 = 0,
	WinBlock4 = 0,
	WinBlock5 = 0,
	WinBlock6 = 8,
	WinBlock7 = 10,
	WinBlock8 = 12,
	WinBlock9 = 25,
	WinBlock10 = 30,
	WinBlock11 = 45,
	WinBlock12 = 50,
	WinBlock13 = 55,
	WinBlock14 = 60,
	WinBlock15 = 70
}
ConfigWorld1.BOSS_WIN_TIERS = {
	{
		maxLevel = 10,
		wins = 1
	},
	{
		maxLevel = 20,
		wins = 10
	},
	{
		maxLevel = 35,
		wins = 50
	},
	{
		maxLevel = 55,
		wins = 500
	},
	{
		maxLevel = 80,
		wins = 1000
	},
	{
		maxLevel = 90,
		wins = 10000
	},
	{
		maxLevel = 140,
		wins = 25000
	},
	{
		maxLevel = 160,
		wins = 100000
	},
	{
		maxLevel = 180,
		wins = 150000
	},
	{
		maxLevel = 200,
		wins = 200000
	},
	{
		maxLevel = 230,
		wins = 350000
	},
	{
		maxLevel = 260,
		wins = 600000
	},
	{
		maxLevel = 290,
		wins = 1000000
	},
	{
		maxLevel = 320,
		wins = 1500000
	},
	{
		maxLevel = 350,
		wins = 2000000
	},
	{
		maxLevel = 380,
		wins = 3000000
	},
	{
		maxLevel = 410,
		wins = 5000000
	},
	{
		maxLevel = 1e999,
		wins = 8000000
	}
}
ConfigWorld1.AUTO_SAVE_INTERVAL = 60
ConfigWorld1.WIN_DEBOUNCE_DELAY = 3
ConfigWorld1.SPECIAL_KEY = {
	NORMAL_INTERVAL = 300,
	EVENT_INTERVAL = 30,
	KEY_LIFETIME = 600,
	MAX_TOUCH_DISTANCE = 20,
	COLLECT_DEBOUNCE = 2
}
ConfigWorld1.ANIMATION_IDS = {
	RUN = "rbxassetid://180426354"
}
ConfigWorld1.SOUNDS = {
	WIN = {
		ID = "rbxassetid://136993031050456",
		Volume = 0.5
	},
	REBIRTH = {
		ID = "rbxassetid://112485797063762",
		Volume = 0.6
	},
	COLLECT = {
		ID = "rbxassetid://1289263994",
		Volume = 0.5
	},
	LEVEL_UP = {
		ID = "rbxassetid://3120909354",
		Volume = 0.3
	},
	HOVER = {
		ID = "rbxassetid://73982862253547",
		Volume = 0.6
	},
	CLICK = {
		ID = "rbxassetid://17481582653",
		Volume = 0.4
	},
	DEV_REBIRTH = {
		ID = "rbxassetid://3601621507",
		Volume = 0.7
	},
	BUY = {
		ID = "rbxassetid://133292918309565",
		Volume = 0.5
	},
	ERROR = {
		ID = "rbxassetid://87437544236708",
		Volume = 0.6
	},
	SUCCESS = {
		ID = "rbxassetid://136993031050456",
		Volume = 0.6
	},
	ERROR7 = {
		ID = "rbxassetid://133843340754810",
		Volume = 0.6
	},
	EFFECT1 = {
		ID = "rbxassetid://126805498637586",
		Volume = 0.6
	},
	NOTIF1 = {
		ID = "rbxassetid://122954374321453",
		Volume = 0.6
	},
	EFFECT2 = {
		ID = "rbxassetid://112124748378177",
		Volume = 0.6
	},
	BOSS_HIT = {
		ID = "rbxassetid://140462043853173",
		Volume = 0.7
	},
	SPECIAL_KEY_NOTIF = {
		ID = "rbxassetid://9125644905",
		Volume = 0.3
	}
}
ConfigWorld1.DURATIONS = {
	LEVEL_UP = 1,
	MESSAGE = 2,
	WIN = 1,
	MODAL_OPEN = 0.3,
	MODAL_CLOSE = 0.2,
	NOTIFICATION = 0.3,
	FADE_OUT = 0.5
}
ConfigWorld1.COLORS = {
	AWARD_EQUIPPED = BrickColor.new("New Yeller"),
	AWARD_DEFAULT = BrickColor.new("Lime green"),
	AWARD_LOCKED = BrickColor.new("Smoky grey")
}
ConfigWorld1.XP_TIME_BASED = {
	MIN_SPEED = 10,
	MAX_SPEED = 100,
	MIN_COOLDOWN = 0.1,
	MAX_COOLDOWN = 0.25
}

function ConfigWorld1.CalculateMaxSpeed(p)
	return (math.min(
		ConfigWorld1.DEFAULT_WALKSPEED + p * ConfigWorld1.SPEED_GAIN_PER_LEVEL,
		ConfigWorld1.MAX_LEVEL_SPEED_CAP
	))
end

ConfigWorld1.CHECKPOINTS = {
	{
		Name = "Stage2",
		WinPrice = 2,
		RobuxPrice = 3,
		RobuxProductId = 3548700311
	},
	{
		Name = "Stage3",
		WinPrice = 6,
		RobuxPrice = 5,
		RobuxProductId = 3548700421
	},
	{
		Name = "Stage4",
		WinPrice = 20,
		RobuxPrice = 10,
		RobuxProductId = 3548700537
	},
	{
		Name = "Stage5",
		WinPrice = 40,
		RobuxPrice = 15,
		RobuxProductId = 3548700704
	},
	{
		Name = "Stage6",
		WinPrice = 100,
		RobuxPrice = 20,
		RobuxProductId = 3548700852
	},
	{
		Name = "Stage7",
		WinPrice = 200,
		RobuxPrice = 25,
		RobuxProductId = 3548700954
	},
	{
		Name = "Stage8",
		WinPrice = 300,
		RobuxPrice = 30,
		RobuxProductId = 3548701203
	},
	{
		Name = "Stage9",
		WinPrice = 600,
		RobuxPrice = 40,
		RobuxProductId = 3548701309
	},
	{
		Name = "Stage10",
		WinPrice = 1000,
		RobuxPrice = 50,
		RobuxProductId = 3548701403
	},
	{
		Name = "Stage11",
		WinPrice = 2000,
		RobuxPrice = 65,
		RobuxProductId = 3548701601
	},
	{
		Name = "Stage12",
		WinPrice = 5000,
		RobuxPrice = 79,
		RobuxProductId = 3548701840
	},
	{
		Name = "Stage13",
		WinPrice = 20000,
		RobuxPrice = 99,
		RobuxProductId = 3548702409
	},
	{
		Name = "Stage14",
		WinPrice = 50000,
		RobuxPrice = 119,
		RobuxProductId = 3584695362
	}
}
ConfigWorld1.SkipCheckpoints = {
	{
		Name = "Stage2",
		RobuxPrice = 2,
		RobuxProductId = 3549060027
	},
	{
		Name = "Stage3",
		RobuxPrice = 3,
		RobuxProductId = 3549060116
	},
	{
		Name = "Stage4",
		RobuxPrice = 5,
		RobuxProductId = 3549060232
	},
	{
		Name = "Stage5",
		RobuxPrice = 8,
		RobuxProductId = 3549060326
	},
	{
		Name = "Stage6",
		RobuxPrice = 10,
		RobuxProductId = 3549060424
	},
	{
		Name = "Stage7",
		RobuxPrice = 13,
		RobuxProductId = 3549060516
	},
	{
		Name = "Stage8",
		RobuxPrice = 15,
		RobuxProductId = 3549060646
	},
	{
		Name = "Stage9",
		RobuxPrice = 20,
		RobuxProductId = 3549060740
	},
	{
		Name = "Stage10",
		RobuxPrice = 25,
		RobuxProductId = 3549060838
	},
	{
		Name = "Stage11",
		RobuxPrice = 30,
		RobuxProductId = 3549060917
	},
	{
		Name = "Stage12",
		RobuxPrice = 35,
		RobuxProductId = 3549061014
	},
	{
		Name = "Stage13",
		RobuxPrice = 40,
		RobuxProductId = 3549061168
	},
	{
		Name = "Stage14",
		RobuxPrice = 50,
		RobuxProductId = 3584695879
	}
}

function ConfigWorld1.GetRebirthProductId(value)
	local v = (value or 0) + 1

	if v <= 7 then
		return ConfigWorld1.DEV_PRODUCTS.INSTANT_REBIRTH_T1
	end

	if v <= 13 then
		return ConfigWorld1.DEV_PRODUCTS.INSTANT_REBIRTH_T2
	end

	return ConfigWorld1.DEV_PRODUCTS.INSTANT_REBIRTH_T3
end

return ConfigWorld1