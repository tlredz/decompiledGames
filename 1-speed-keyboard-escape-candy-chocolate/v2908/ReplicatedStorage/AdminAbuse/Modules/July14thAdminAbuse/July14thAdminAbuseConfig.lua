return {
	MAP_TEMPLATE_NAME = "July14thAdminAbuse",
	MAP_LIVE_NAME = "July14thAdminAbuse_Live",
	useDeferredMapLoad = true,
	deferredLoadTimeBudgetSec = 0.006,
	deferredUnloadTimeBudgetSec = 0.0025,
	SSE_CHANNEL = "July14thAdminAbuse",
	SSE_RATE_HZ = 20,
	DisplayName = "July 14th",
	NeedsDuration = false,
	SkipDoorTransition = false,
	IsAdminAbuse = true,
	RequiresRespawnRefire = true,
	HasPrioritySoundtrack = true,
	CAMERA_FOV = 50,
	DEFAULT_FOV = 70,
	FADE_DURATION = 0.5,
	CREDITS_FADE_SEC = 1.5,
	CREDITS_DURATION = 5,
	CLEANUP_SIGNAL_TIMEOUT_SEC = 5,
	POST_ENDING_DURATION_SEC = 11,
	ANIM_IDS = {
		Opening = {
			HumanoidCameraRig = "rbxassetid://108217573670108",
			Jets = "rbxassetid://128173902806370"
		},
		Command = {
			Jets = "rbxassetid://128173902806370"
		},
		NPCDances = {
			"rbxassetid://132258178741688",
			"rbxassetid://115755128157455",
			"rbxassetid://76779535097692",
			"rbxassetid://139990683259703",
			"rbxassetid://134830734343007"
		}
	},
	TRUSTED_COMMAND_USER_IDS = {
		[7614363348] = true,
		[18298071] = true,
		[3845375404] = true,
		[175193570] = true,
		[10580349267] = true,
		[586487285] = true,
		[162206312] = true,
		[435763596] = true
	},
	COMMANDS = {
		RunJetsSequence = {
			DisplayName = "Run Jets Sequence"
		},
		SpawnWinOrbs = {
			DisplayName = "Spawn Win Orbs",
			HasArg = true,
			ArgPlaceholder = "Orb Count",
			ArgDefault = "10"
		},
		LaunchFireworks = {
			DisplayName = "Launch Fireworks",
			HasArg = true,
			ArgPlaceholder = "Firework Count",
			ArgDefault = "10",
			ArgMax = 25,
			HasColorPicker = true
		},
		ToggleCroissantsVFX = {
			DisplayName = "Toggle Croissants VFX",
			StateKey = "CroissantsVFXEnabled"
		}
	},
	COMMAND_MESSAGING_TOPIC = "Secretverse_July14thAdminAbuse_Command_v1",
	COMMAND_COOLDOWN_SEC = 3,
	COMMAND_CAMERA_FOLLOW_SMOOTH_TIME = 0.35,
	COMMAND_CAMERA_FOLLOW_HEIGHT_OFFSET = 10,
	REPORTER_USER_IDS = {
		[1692057] = true
	},
	REPORTER_ACCESS_MAX_UNIX = 1784116800,
	REPORTER_MESSAGE_COOLDOWN_SEC = 3,
	REPORTER_MESSAGE_MAX_LEN = 200,
	WIN_ORB_MAX_COUNT = 100,
	WIN_ORB_DESPAWN_SEC = 60,
	WIN_ORB_COLLECT_COOLDOWN_SEC = 0.25,
	MIN_FIREWORK_HEIGHT = 100,
	MAX_FIREWORK_HEIGHT = 150,
	FIREWORK_ASCEND_DURATION = 1,
	FIREWORK_RESET_DELAY = 0.5,
	FIREWORK_MIN_INTERVAL = 0.25,
	FIREWORK_MAX_INTERVAL = 1,
	FIREWORK_MIN_PER_TICK = 1,
	FIREWORK_MAX_PER_TICK = 5,
	FIREWORK_DEFAULT_EMIT_COUNT = 60,
	FIREWORK_COLORS = {
		White = Color3.fromHex("FFFFFF"),
		Blue = Color3.fromHex("0037FF"),
		Red = Color3.fromHex("FF0000")
	},
	FIREWORK_COLOR_ORDER = { "White", "Blue", "Red" },
	FIREWORK_CURVE1_MIN_OFFSET = 25,
	FIREWORK_CURVE1_MAX_OFFSET = 55,
	FIREWORK_CURVE2_MIN_OFFSET = 60,
	FIREWORK_CURVE2_MAX_OFFSET = 120,
	FIREWORK_END_DRIFT_MIN = 40,
	FIREWORK_END_DRIFT_MAX = 90,
	FIREWORK_CURVE_ANGLE_JITTER_DEG = 25,
	BEAM_STEP_INTERVAL = 0.05,
	BEAM_HOLD_SEC = 3,
	BEAM_LOOP = true,
	NPC_DANCE_SWITCH_MIN_SEC = 6,
	NPC_DANCE_SWITCH_MAX_SEC = 14,
	NPC_DANCE_COLLISION_GROUP = "NPCDanceRigs",
	SOUNDTRACKS = {
		{
			Name = "Reflekt - We've Only Just Begun",
			AssetId = "rbxassetid://81789245198334"
		},
		{
			Name = "Axtasia - Let It Go",
			AssetId = "rbxassetid://104695245037953"
		},
		{
			Name = "Axtasia - The View",
			AssetId = "rbxassetid://94627193867884"
		},
		{
			Name = "TACACHO - Black Swan",
			AssetId = "rbxassetid://120007441962737"
		},
		{
			Name = "Haven - Ding",
			AssetId = "rbxassetid://93970609264491"
		},
		{
			Name = "Echofate & SPOT - Take Me Higher",
			AssetId = "rbxassetid://98090122284200"
		},
		{
			Name = "ROY - Paris Night Walk",
			AssetId = "rbxassetid://81888427712271"
		},
		{
			Name = "ROY - Mily",
			AssetId = "rbxassetid://127176623684925"
		},
		{
			Name = "ROY - Stay",
			AssetId = "rbxassetid://71016572563090"
		},
		{
			Name = "Tobu - Such Fun",
			AssetId = "rbxassetid://100910937626709"
		}
	},
	CROSSFADE_DURATION_SEC = 0.5,
	STAGE_LIGHT_PATTERNS = {
		"SkyRise",
		"Fan",
		"AudienceSweep",
		"Wave"
	},
	STAGE_LIGHT_PATTERN_MIN_SEC = 8,
	STAGE_LIGHT_PATTERN_MAX_SEC = 15,
	LASER_PATTERN = "Sweep",
	LIGHT_COLOR_PALETTE = { Color3.fromRGB(30, 90, 255), Color3.fromRGB(255, 30, 30), Color3.fromRGB(255, 255, 255) },
	LIGHT_COLOR_CYCLE_MIN_SEC = 3,
	LIGHT_COLOR_CYCLE_MAX_SEC = 8
}