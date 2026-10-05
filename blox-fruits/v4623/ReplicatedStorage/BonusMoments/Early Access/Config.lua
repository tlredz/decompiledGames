local createVector = vector.create
local cframe = CFrame.new(-1090.3401, 11.6863, 1805.7358, -0.258821, 0, 0.965927, 0, 1, 0, -0.965927, 0, -0.258821)
local cframe2 = CFrame.new(
	-1082.731,
	27.94423,
	1657.7845,
	-0.9659271,
	0.00012207031,
	-0.25881958,
	0.00012207031,
	1,
	0,
	0.25881958,
	-0.000030517578,
	-0.9659271
)
local v = {
	ISLAND = "Middle Town",
	MAP_MODEL_NAME = "Town",
	HIDEOUT_MODEL_NAME = "JanusHideout",
	WINDOW_MODEL_NAME = "Tree",
	WINDOW_ATTRIBUTE = "IsWindow",
	HIDEOUT_WAIT_TIMEOUT = 120,
	HIDEOUT_POLL_INTERVAL = 1,
	LOCATIONS_FOLDER_NAME = "BonusMoment_Locations",
	MOMENT_FOLDER_NAME = "EarlyAccess",
	REAR_DOOR_MARKER = "RobotmegaRearDoor",
	TESTER_DOOR_MARKER = "EarlyAccessDoor",
	QUEST_GIVER_MARKER = "QuestGiver",
	QUEST_GIVER_NPC_NAME = "robotmega superfan",
	QUEST_GIVER_TITLE = "Janus",
	REAR_DOOR_DISPLAY_NAME = "Locked Door",
	KEY_MARKER = "KeySpot",
	DEVELOPER_DOOR_MARKER = "DeveloperDoor",
	TESTER_SIGN_MARKER = "TesterSign",
	NOTE_TITLE = "Note",
	DEVELOPER_DOOR_PEEK_CFRAME = CFrame.new(
		-1068.40979,
		30.7348671,
		1705.72168,
		-0.983773708,
		-0.0157700572,
		0.178719431,
		9.31322464e-10,
		0.996129572,
		0.0878976658,
		-0.17941384,
		0.0864714161,
		-0.979966044
	),
	DEVELOPER_DOOR_PEEK_DAMPING = 1,
	DEVELOPER_DOOR_PEEK_FREQUENCY = 2.2,
	DEVELOPER_DOOR_PEEK_FADE = 0.25,
	KEY_TOOL_TEMPLATE_NAME = "Key",
	KEY_TOOL_NAME = "Rear Door Key",
	KEY_TOOL_TAG = "EarlyAccessMansionKey",
	KEY_TOOL_ATTRIBUTE = "EarlyAccessMansionKey",
	CHILLING_MODEL_NAME = "DevBrosChilling",
	CUTSCENE_ASSET_NAME = "EarlyAccessBonusMomentAssets",
	CUTSCENE_HIDDEN_NPC_NAMES = { "Aura Editor", "Robotmega" },
	CUTSCENE_ASSET_PARTS = {
		PLAYER_ENTRANCE = "PlayerEntrance",
		PLAYER_AT_LAPTOP = "PlayerAtLaptop",
		LAPTOP = "BriefcaseLaptop",
		LAPTOP_ROOT = "RootPart",
		LAPTOP_HINGE = "Hinge1"
	},
	CUTSCENE_ANIMATIONS = {
		LOOK = "NPC_Idle",
		WALK = "NPC_Walk",
		KEYBOARD = "FistBarrage",
		RUN = "NPC_Run"
	},
	TOWN_INSTANCE_MARKERS = {
		RobotmegaRearDoor = true,
		EarlyAccessDoor = true,
		DeveloperDoor = true,
		TesterSign = true
	},
	NPC_INSTANCE_MARKERS = {
		QuestGiver = "robotmega superfan"
	},
	CUTSCENE_INSTANCE_MARKERS = {
		KeySpot = true
	},
	SERVER_INTERACTION_DISTANCE = 18,
	INFILTRATION_MIN_DURATION = 8,
	PROMPT_DISTANCE = 12,
	KEY_AURA_SOUND = "MiddleTownSFX.Key_Nearby_Indicator_Aura_01",
	KEY_AURA_FADE = 0.35,
	HACK_SOUND = "MiddleTownSFX.UnlockDoor_Hack_Computer_Cutscene_01",
	PROMOTION_SOUND = "MiddleTownSFX.BF_MidTown_Promoted_To_Tester_01",
	STAGES = {
		UNSTARTED = 0,
		FIND_KEY = 1,
		HAS_KEY = 2,
		INFILTRATION = 3,
		RETURN_TO_DEVELOPER = 4,
		TESTER = 5
	},
	CUTSCENE = {
		ENTRANCE_CAMERA_SETTLE_TIME = 0.25,
		LOOK_TURN_TIME = 0.35,
		LOOK_CROSS_TIME = 0.55,
		LOOK_RETURN_TIME = 0.35,
		LOOK_HOLD_TIME = 0.12,
		LOOK_YAW = 35,
		WALK_DURATION = 3.2,
		WALK_SPEED = 1.15,
		LAPTOP_CAMERA_SETTLE_TIME = 0.65,
		HINGE_OPEN_ANGLE = 105,
		HINGE_OPEN_TIME = 0.65,
		KEYBOARD_TIME = 1.35,
		KEYBOARD_SPEED = 1.7,
		KEYBOARD_WEIGHT = 0.5,
		UPLOAD_DIALOGUE_ADVANCE_DELAY = 0.7,
		HINGE_CLOSE_TIME = 0.5,
		EXIT_CAMERA_SETTLE_TIME = 0.2,
		RUN_CAMERA_SETTLE_TIME = 0.15,
		RUN_DURATION = 1.45,
		RUN_SPEED = 1.25,
		EXIT_HOLD_TIME = 0.1,
		FIELD_OF_VIEW = 60,
		CAMERA_WALL_PADDING = 0.75,
		ENTRANCE_CAMERA_CFRAME = CFrame.new(
			-1040.55505,
			27.7271137,
			1816.05652,
			0.869529247,
			0.304862231,
			-0.388558805,
			-1.4901163e-8,
			0.786745071,
			0.617278039,
			0.493881524,
			-0.536741316,
			0.684097826
		),
		PATH_CAMERA_POSITION_OFFSET = createVector(7, 4, 0),
		PATH_CAMERA_FOCUS_OFFSET = createVector(0, 1.8, 0),
		EXIT_CAMERA_POSITION_OFFSET = createVector(6, 3.5, -2),
		EXIT_CAMERA_FOCUS_OFFSET = createVector(0, 1.6, 0),
		RUN_CAMERA_POSITION_OFFSET = createVector(14, 4, 0),
		RUN_CAMERA_FOCUS_OFFSET = createVector(0, 1.7, 0),
		LAPTOP_CAMERA_POSITION_OFFSET = createVector(-7, 6.5, -14),
		LAPTOP_CAMERA_FOCUS_HEIGHT = 1.5
	},
	INTERACTIONS = {
		MansionKey = {
			MarkerName = "KeySpot",
			TemplateName = "MansionKey",
			ActionText = "Pick Up",
			ObjectText = "Rear Door Key",
			HoldDuration = 0.35
		},
		MansionDoor = {
			MarkerName = "RobotmegaRearDoor",
			UseMarkerVisual = true,
			ActionText = "Open",
			ObjectText = "Locked Door",
			HoldDuration = 0.25
		},
		TesterDoor = {
			MarkerName = "EarlyAccessDoor",
			UseMarkerVisual = true,
			ActionText = "Enter",
			ObjectText = "Tester Only",
			HoldDuration = 0
		},
		DeveloperDoor = {
			MarkerName = "DeveloperDoor",
			UseMarkerVisual = true,
			ActionText = "Open",
			ObjectText = "Break Room",
			HoldDuration = 0
		},
		TesterSign = {
			MarkerName = "TesterSign",
			UseMarkerVisual = true,
			ActionText = "Read",
			ObjectText = "Note",
			HoldDuration = 0
		}
	},
	FALLBACK_CFRAMES = {
		RobotmegaRearDoor = cframe,
		EarlyAccessDoor = cframe2
	},
	PLACEHOLDER_COLORS = {
		MansionKey = Color3.fromRGB(255, 214, 72),
		MansionDoor = Color3.fromRGB(121, 84, 56)
	},
	TESTER_DOOR_REASONS = {
		"can't let u in yet. the build is compiling.",
		"not today bro. the lead builder's replacement fish has an appointment.",
		"roblox updated a button. we gotta rewrite the whole game again.",
		"one of the devs just said 'that would be fire.' we're waiting for him to actually make it.",
		"the tester room is being tested by the pre-testers.",
		"christmas. hopefully.",
		"can't let u in. we're adding a disease system where u can get other players sick by coughing on them. very advanced stuff.",
		"not yet bro. i'm busy working on cooking v5. the last dev burnt the last cooking system, so i gotta cook a new cooking system."
	}
}
return table.freeze(v)