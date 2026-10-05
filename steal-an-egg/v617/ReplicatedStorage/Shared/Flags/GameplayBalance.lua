local BalanceConfig = require(script.Parent.BalanceConfig)
local v = {
	Earnings = BalanceConfig.Bind("Game.Balance.Earnings", {
		STEEP_SCALE_POWER = 1.85,
		TAPER_KNEE_SCALE = 5,
		TAPERED_SCALE_POWER = 1.2,
		MINIMUM_RATE = 1
	}, true, false, function(p)
		assert(p.TAPER_KNEE_SCALE > 0)
	end),
	SellRewards = BalanceConfig.Bind("Game.Balance.SellRewards", {
		INDEX_REWARD_SECONDS = 100,
		SALE_SECONDS_OF_INCOME = 100,
		WEIGHT_SCALE_POWER = 3
	}, true, false),
	Eggs = BalanceConfig.Bind("Game.Balance.Eggs", {
		SCALE_BANDS = {
			{
				min = 0.85,
				max = 1.05,
				weight = 2000
			},
			{
				min = 1.45,
				max = 1.55,
				weight = 250
			},
			{
				min = 1.9,
				max = 2.1,
				weight = 125
			},
			{
				min = 2.85,
				max = 3.15,
				weight = 62.5
			},
			{
				min = 3.8,
				max = 4.2,
				weight = 31.25
			},
			{
				min = 0.3,
				max = 0.45,
				weight = 18
			},
			{
				min = 0.1,
				max = 0.2,
				weight = 5
			},
			{
				min = 5.8,
				max = 6.2,
				weight = 15.625
			},
			{
				min = 9.5,
				max = 12.5,
				weight = 3
			},
			{
				min = 12,
				max = 17,
				weight = 0.05
			},
			{
				min = 20,
				max = 35,
				weight = 0.0001
			}
		},
		SCALE_HARD_CAP = 150,
		SCALE_DOUBLING_ODDS = 0.01,
		SELL_PRICE_SHARE = 0.8,
		ADMIN_GROWS_BANDS_FROM = 1.45,
		ADMIN_SHRINKS_BANDS_UNTIL = 0.45,
		FLAT_GROWTH_MAX_SCALE = 2,
		STEEP_GROWTH_MAX_SCALE = 6,
		STEEP_GROWTH_POWER = 1.389,
		TAIL_GROWTH_COEFFICIENT = 4.6,
		TAIL_GROWTH_POWER = 0.72,
		TAIL_GROWTH_CAP = 20,
		X2_GROWTH_BONUS = 1
	}, true, false, function(data)
		local v2

		if data.SCALE_HARD_CAP > 0 then
			v2 = data.SCALE_DOUBLING_ODDS < 1
		else
			v2 = false
		end

		assert(v2)
		assert(data.STEEP_GROWTH_MAX_SCALE >= data.FLAT_GROWTH_MAX_SCALE)
		local total = 0

		for _, v3 in data.SCALE_BANDS do
			local v4

			if v3.min > 0 then
				v4 = v3.max >= v3.min
			else
				v4 = false
			end

			assert(v4)
			total += v3.weight
		end

		assert(total > 0)
	end),
	TreadmillProgression = BalanceConfig.Bind("Game.Balance.TreadmillProgression", {
		CURVE_REFERENCE_BASE_WALK_SPEED = 10,
		DEFAULT_BASE_SPEED_POWER_PER_STEP = 1,
		DEFAULT_SPEED_STEP_MULTIPLIER = 1,
		SPEED_BOOST_MULTIPLIERS_BY_TIER = {
			2,
			4,
			8,
			16,
			32,
			64,
			128,
			256,
			512,
			1024,
			2048,
			4096
		},
		CURVE_BASE_XP = 100,
		CURVE_XP_GROWTH = 1.15,
		CURVE_SPEED_GAIN_PER_LEVEL = 2,
		CURVE_REFERENCE_MAX_WALK_SPEED = 300,
		TREADMILL_SPEED_GAIN_INTERVAL = 1,
		WALK_GAIN_INTERVAL_MIN_SPEED = 10,
		WALK_GAIN_INTERVAL_MAX_SPEED = 100,
		WALK_GAIN_INTERVAL_FASTEST = 0.1,
		WALK_GAIN_INTERVAL_SLOWEST = 0.25
	}, true, false, function(data)
		local v2

		if data.CURVE_BASE_XP > 0 then
			v2 = data.CURVE_XP_GROWTH > 1
		else
			v2 = false
		end

		assert(v2)
		assert(data.CURVE_REFERENCE_MAX_WALK_SPEED > math.max(data.CURVE_REFERENCE_BASE_WALK_SPEED, 16))
		assert(data.CURVE_SPEED_GAIN_PER_LEVEL > 0)
		assert(data.TREADMILL_SPEED_GAIN_INTERVAL > 0)
		assert(data.WALK_GAIN_INTERVAL_MAX_SPEED > data.WALK_GAIN_INTERVAL_MIN_SPEED)
		local v3

		if data.WALK_GAIN_INTERVAL_FASTEST > 0 then
			v3 = data.WALK_GAIN_INTERVAL_SLOWEST >= data.WALK_GAIN_INTERVAL_FASTEST
		else
			v3 = false
		end

		assert(v3)

		for _, v4 in data.SPEED_BOOST_MULTIPLIERS_BY_TIER do
			assert(v4 > 0)
		end
	end),
	Fusion = BalanceConfig.Bind("Game.Balance.Fusion", {
		INPUT_COUNT = 3,
		PRICED_MINUTES_OF_INCOME = 3,
		ONE_MUTATION_SURCHARGE = 2,
		MANY_MUTATION_SURCHARGE = 3,
		BIAS_STRENGTH = 0.6
	}, true, false, function(p)
		local v2

		if p.INPUT_COUNT >= 1 and p.INPUT_COUNT <= 3 then
			v2 = p.INPUT_COUNT % 1 == 0
		else
			v2 = false
		end

		assert(v2)
	end),
	ServerLuck = BalanceConfig.Bind("Game.Balance.ServerLuck", {
		BOOST_DURATION = 900,
		MAX_MULTIPLIER = 8
	}, true, false),
	NewPlayer = BalanceConfig.Bind("Game.Balance.NewPlayer", {
		GRADUATED_SPEED_MULTIPLIER = 2.5
	}, true, false),
	Lottery = BalanceConfig.Bind("Game.Balance.Lottery", {
		SHIFT_DAMPING = 0.49,
		SECOND_MUTATION_ODDS = 0.5,
		UPGRADE_BAND_ODDS = 10
	}, true, false, function(data)
		local v2

		if data.SHIFT_DAMPING <= 1 and data.SECOND_MUTATION_ODDS <= 1 then
			v2 = data.UPGRADE_BAND_ODDS <= 100
		else
			v2 = false
		end

		assert(v2)
	end),
	GamepassBenefits = BalanceConfig.Bind("Game.Balance.GamepassBenefits", {
		X2_MONEY_BONUS = 1,
		LUCKY_BLOCK_LUCK_PERCENT = 10,
		LUCKY_FUSE_WEIGHT_BOOST = 1.1
	}, true, false),
	GuardRequirements = BalanceConfig.Bind("Game.Balance.GuardRequirements", {
		CARRY_SPEED_RATIO = 0.9,
		REQUIREMENT_MARGIN = 1.05
	}, true, false),
	GuardChase = BalanceConfig.Bind("Game.Balance.GuardChase", {
		DEFAULT_HIT_DISTANCE = 10,
		DISTANCE_MULTIPLIER_STRENGTH = 0.5,
		MAX_DISTANCE_MULTIPLIER = 4,
		WAKING_DURATION = 0.63
	}, true, false),
	GuardReturn = BalanceConfig.Bind("Game.Balance.GuardReturn", {
		DEFAULT_RETURN_HOME_DISTANCE = 3,
		RETURN_HOME_DISTANCE_BY_AREA_ID = {
			["Abyss Ocean"] = 15,
			Cosmic = 15,
			Prehistoric = 15
		}
	}, true, false),
	GuardMovement = BalanceConfig.Bind("Game.Balance.GuardMovement", {
		RETURN_WALK_SPEED_MULTIPLIER = 1.5,
		ATTACK_MIN_INTERVAL = 0.75,
		MIN_REFERENCE_WALK_SPEED = 16,
		MAX_REFERENCE_WALK_SPEED = 231
	}, true, false, function(p)
		assert(p.MAX_REFERENCE_WALK_SPEED > p.MIN_REFERENCE_WALK_SPEED)
	end),
	GuardPrediction = BalanceConfig.Bind("Game.Balance.GuardPrediction", {
		FULL_GREEN_EGG_CARRY_SPEED_RATIO = 0.6
	}, true, false),
	BatServer = BalanceConfig.Bind("Game.Balance.BatServer", {
		PLAYER_COOLDOWN = 0.7
	}, true, false),
	BatClient = BalanceConfig.Bind("Game.Balance.BatClient", {
		CLIENT_COOLDOWN = 0.6
	}, true, false),
	Ragdoll = BalanceConfig.Bind("Game.Balance.Ragdoll", {
		PLAYER_RAGDOLL_SECONDS = 5
	}, true, false),
	GuardKnockback = BalanceConfig.Bind("Game.Balance.GuardKnockback", {
		BASE_HORIZONTAL_SPEED = 20,
		UPWARD_SPEED = 60,
		RANDOM_YAW_DEGREES = 12,
		HOME_HORIZONTAL_MULTIPLIER = 5
	}, true, false),
	GuardAttack = BalanceConfig.Bind("Game.Balance.GuardAttack", {
		RAGDOLL_TIME = 2.5
	}, true, false),
	GuardImpulse = BalanceConfig.Bind("Game.Balance.GuardImpulse", {
		MAX_AREA_IMPULSE_MULTIPLIER = 5
	}, true, false),
	CarryPenalty = BalanceConfig.Bind("Game.Balance.CarryPenalty", {
		MIN_MALUS_RATIO = 0.04,
		MAX_MALUS_RATIO = 0.33,
		CURVE_POWER = 1.2,
		MAX_CARRY_SLOWDOWN = 0.33,
		MAX_CARRY_SLOWDOWN_BY_BIOME = {
			Jungle = 0.223,
			Snow = 0.221,
			Volcano = 0.224,
			["Abyss Ocean"] = 0.204,
			Prehistoric = 0.201,
			Cosmic = 0.175,
			["Cherry Blossom"] = 0.147,
			["Titan Temple"] = 0.164,
			["Light Dark"] = 0.154,
			["Enchanted Forest"] = 0.168
		}
	}, true, false, function(data)
		local v2

		if data.MAX_MALUS_RATIO < 1 and data.MAX_MALUS_RATIO >= data.MIN_MALUS_RATIO then
			v2 = data.CURVE_POWER > 0
		else
			v2 = false
		end

		assert(v2)
		local v3

		if data.MAX_CARRY_SLOWDOWN >= 0 then
			v3 = data.MAX_CARRY_SLOWDOWN < 1
		else
			v3 = false
		end

		assert(v3)

		for _, v4 in data.MAX_CARRY_SLOWDOWN_BY_BIOME do
			local v5

			if v4 >= 0 then
				v5 = v4 < 1
			else
				v5 = false
			end

			assert(v5)
		end
	end),
	DroppedEggs = BalanceConfig.Bind("Game.Balance.DroppedEggs", {
		ABANDONED_DISTANCE_XZ = 200,
		ABANDONED_SECONDS = 75,
		OUTSIDE_GAMEPLAY_SECONDS = 15
	}, true, false),
	Traps = BalanceConfig.Bind("Game.Balance.Traps", {
		MAX_ACTIVE_TRAPS = 3,
		MAX_PLACE_DISTANCE = 10,
		TRAP_COOLDOWN_SECONDS = 1
	}, true, false, function(p)
		assert(p.MAX_ACTIVE_TRAPS % 1 == 0)
	end),
	StarterGear = BalanceConfig.Bind("Game.Balance.StarterGear", {
		STARTER_BAT_COUNT = 1,
		STARTER_TRAP_COUNT = 3
	}, true, false, function(p)
		local v2

		if p.STARTER_BAT_COUNT % 1 == 0 then
			v2 = p.STARTER_TRAP_COUNT % 1 == 0
		else
			v2 = false
		end

		assert(v2)
	end),
	EggInventory = BalanceConfig.Bind("Game.Balance.EggInventory", {
		MAX_PLACED_EGGS = 30,
		FIRST_EGG_PLACEMENT_GROWTH_DURATION = 3
	}, true, false, function(p)
		local v2

		if p.MAX_PLACED_EGGS % 1 == 0 then
			v2 = p.FIRST_EGG_PLACEMENT_GROWTH_DURATION > 0
		else
			v2 = false
		end

		assert(v2)
	end),
	AreaLuck = BalanceConfig.Bind("Game.Balance.AreaLuck", {
		CAPPED_LUCK_MULTIPLIER = 1.5
	}, true, false),
	DragonEvent = BalanceConfig.Bind("Game.Balance.DragonEvent", {
		DRAGON_FLY_BASE_SPEED = 120,
		DRAGON_FLY_SPEED_CAP = 450,
		DRAGON_FLY_INIT_DELAY_SECONDS = 5,
		DRAGON_LAP_PAUSE_SECONDS = 0,
		DRAGON_LAP_SPEED_INCREASE = 30,
		DRAGON_TURN_SECONDS = 1.5,
		DRAGON_TURN_SETTLE_SECONDS = 7,
		TUTORIAL_SECONDS = 30,
		PAYOUT_SECONDS = 8,
		DOWNTIME_SECONDS = 10,
		RACE_WAIT_SECONDS = 10,
		LAIR_EGG_COUNT = 10,
		RACE_EGG_SCALE = 3,
		RACE_EGG_SPEED_MALUS = -0.3
	}, true, false, function(data)
		local v2

		if data.LAIR_EGG_COUNT % 1 == 0 and data.RACE_EGG_SCALE > 0 and data.RACE_EGG_SPEED_MALUS > -1 then
			v2 = data.RACE_EGG_SPEED_MALUS <= 0
		else
			v2 = false
		end

		assert(v2)
	end),
	DemonicEvent = BalanceConfig.Bind("Game.Balance.DemonicEvent", {
		PRE_EVENT_SECONDS = 3600,
		PREPARATION_SECONDS = 60,
		FIGHT_SECONDS = 600,
		EQUALISED_SPEED_POWER = 1000000000,
		PRE_EVENT_BUFFS = {
			EggSpawnLuck = 2,
			EggGrowth = 2
		}
	}, true, false),
	CaptureEvent = BalanceConfig.Bind("Game.Balance.CaptureEvent", {
		EGG_SPEED_MALUS = -0.7
	}, true, false, function(p)
		local v2

		if p.EGG_SPEED_MALUS > -1 then
			v2 = p.EGG_SPEED_MALUS <= 0
		else
			v2 = false
		end

		assert(v2)
	end),
	RecoveryEvent = BalanceConfig.Bind("Game.Balance.RecoveryEvent", {
		LUCK_PERIOD_SECONDS = 300
	}, true, false),
	GroupRewardEligibility = BalanceConfig.Bind("Game.Balance.GroupRewardEligibility", {
		YOUNG_ACCOUNT_AGE_DAYS = 5
	}, true, false),
	SakuraInteraction = BalanceConfig.Bind("Game.Balance.SakuraInteraction", {
		INCUBATOR_INTERACT_RANGE = 30
	}, true, false),
	AreaEggCycle = BalanceConfig.Bind("Game.Balance.AreaEggCycle", {
		NIGHT_SECONDS_DEFAULT = 10,
		NIGHT_SECONDS_FLOOR = 1,
		NIGHT_SKIP_SECONDS = 300,
		PERIOD_SECONDS = 300
	}, true, false, function(data)
		local v2

		if data.PERIOD_SECONDS > 0 and data.NIGHT_SECONDS_FLOOR > 0 and data.NIGHT_SECONDS_DEFAULT >= data.NIGHT_SECONDS_FLOOR then
			v2 = data.NIGHT_SECONDS_DEFAULT <= data.PERIOD_SECONDS
		else
			v2 = false
		end

		assert(v2)
	end),
	AdRewards = BalanceConfig.Bind("Game.Balance.AdRewards", {
		FALLBACK_DURATION = 30
	}, true, false),
	EggProducts = BalanceConfig.Bind("Game.Balance.EggProducts", {
		MIN_SKIP_SECONDS = 300
	}, true, false),
	SlapTool = BalanceConfig.Bind("Game.Balance.SlapTool", {
		RANGE = 15,
		DEFAULT_PLAYER_COOLDOWN = 1,
		MAX_PLAYER_TARGETS = 2
	}, true, false, function(p)
		assert(p.MAX_PLAYER_TARGETS % 1 == 0)
	end),
	SlapImpulse = BalanceConfig.Bind("Game.Balance.SlapImpulse", {
		TRAJECTORY_DURATION_MULTIPLIER = 1.5,
		RAGDOLL_GROUNDING_MARGIN = 0.5,
		DURATION_JITTER = 0.2,
		FORCE_JITTER = 0.2,
		MIN_DURATION = 0.1,
		MIN_TRAJECTORY_DURATION = 0.05
	}, true, false),
	TrapClient = BalanceConfig.Bind("Game.Balance.TrapClient", {
		CLIENT_COOLDOWN = 1
	}, true, false),
	TrapEffect = BalanceConfig.Bind("Game.Balance.TrapEffect", {
		FREEZE_DURATION = 7
	}, true, false),
	BeeLauncher = BalanceConfig.Bind("Game.Balance.BeeLauncher", {
		COOLDOWN_TIME = 58,
		HIT_RADIUS = 45,
		EFFECT_DURATION_SECONDS = 5
	}, true, false),
	AdminBoostLimits = BalanceConfig.Bind("Game.Balance.AdminBoostLimits", {
		MIN_MULTIPLIER = 1,
		MAX_MULTIPLIER = 100
	}, true, false, function(p)
		local v2

		if p.MIN_MULTIPLIER > 0 then
			v2 = p.MAX_MULTIPLIER >= p.MIN_MULTIPLIER
		else
			v2 = false
		end

		assert(v2)
	end),
	GuardRetrieval = BalanceConfig.Bind("Game.Balance.GuardRetrieval", {
		DEPOSIT_DISTANCE_XZ = 20
	}, true, false),
	GuardRecovery = BalanceConfig.Bind("Game.Balance.GuardRecovery", {
		FALL_RECOVERY_DEPTH = 5,
		STUCK_TIMEOUT = 10,
		MINIMUM_HORIZONTAL_PROGRESS = 3,
		RETURN_HOME_TIMEOUT = 20
	}, true, false)
}
return table.freeze(v)