return {
	WORLD = 4,
	GALAXY_INDEX = 2,
	GALAXY_WORLD_INDEX = 1,
	WORLD_MULTIPLIER = 0.2,
	ShopNotification = false,
	DEPRECATED_BOSS_WIN_TIERS = {
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
			wins = 5000000
		}
	},
	SECURITY = {
		MAX_SPEED_ALLOWED = 300,
		DISTANCE_MARGIN = 2,
		TELEPORT_COOLDOWN = 0.5,
		STATION_MARGIN = 20
	},
	DEFAULT_WALKSPEED = 10,
	SPEED_GAIN_PER_LEVEL = 2,
	SPEED_FORMULA = {
		FLAT_BELOW_LEVEL = nil
	},
	ENTRY = {
		LEVEL = 0,
		REDIRECT_WORLD_INDEX = nil
	},
	FEATURES = {
		CHECKPOINTS = false
	},
	DISPLAY = {
		COLOR = Color3.fromRGB(7, 125, 92)
	},
	PROGRESSION = {
		WIN_BLOCK_FIRST = 1,
		WIN_BLOCK_LAST = 20,
		CHECKPOINT_SEGMENT_START = 1,
		WIN_BLOCK_REVEAL_LOCKS = {
			WinBlock19 = "G2_Stage19",
			WinBlock20 = "G2_Stage19"
		}
	},
	STAGE_RECOMMENDED_LEVELS = {
		[2] = 8,
		[3] = 10,
		[4] = 15,
		[5] = 20,
		[6] = 30,
		[7] = 35,
		[8] = 45,
		[9] = 55,
		[10] = 70,
		[11] = 80,
		[12] = 90,
		[13] = 100,
		[14] = 115,
		[15] = 120,
		[16] = 125,
		[17] = 135,
		[18] = 145,
		[19] = 150,
		[20] = 155
	},
	SERVER_BOOSTS = {
		ADD_TIME = true,
		PRODUCTS = {
			{
				ProductId = 3609127180,
				Duration = 900,
				Multiplier = 2
			},
			{
				ProductId = 3609127243,
				Duration = 900,
				Multiplier = 4
			}
		}
	},
	CHECKPOINTS = {},
	SkipCheckpoints = {}
}