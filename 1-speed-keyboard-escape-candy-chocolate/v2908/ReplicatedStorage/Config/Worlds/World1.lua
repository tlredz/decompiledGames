return {
	WORLD = 1,
	GALAXY_INDEX = 1,
	GALAXY_WORLD_INDEX = 1,
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
		CHECKPOINTS = true
	},
	DISPLAY = {
		COLOR = Color3.fromRGB(70, 130, 255)
	},
	PROGRESSION = {
		WIN_BLOCK_FIRST = 1,
		WIN_BLOCK_LAST = 15,
		CHECKPOINT_SEGMENT_START = 1
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
		[14] = 110,
		[15] = 120
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
	CHECKPOINTS = {
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
	},
	SkipCheckpoints = {
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
}