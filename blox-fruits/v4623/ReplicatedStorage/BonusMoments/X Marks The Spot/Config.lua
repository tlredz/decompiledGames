local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Textures = require(ReplicatedStorage.Textures)
local v = not Textures.bonus and {} or Textures.bonus["treasure-map"] or {}
local uDim = UDim2.fromScale(0.18, 0.32)
local frozen = table.freeze({
	UDim2.fromScale(0.14, 0.27),
	UDim2.fromScale(0.22, 0.72),
	UDim2.fromScale(0.37, 0.27),
	UDim2.fromScale(0.5, 0.72),
	UDim2.fromScale(0.64, 0.27),
	UDim2.fromScale(0.78, 0.72),
	UDim2.fromScale(0.82, 0.27)
})
local cframe = CFrame.new(
	0,
	0,
	0,
	-0.195874602,
	0.485699594,
	-0.851897418,
	-0,
	0.868725538,
	0.495293945,
	0.980628967,
	0.0970155075,
	-0.170161262
)

local function getTexture(p: string)
	return v[p] or ""
end

local values = {}

for k, v2 in frozen do
	table.insert(values, table.freeze({
		MAP_POSITION = v2,
		MAP_SIZE = uDim,
		IMAGE = v[`MiddleTownMap{k}.png`] or ""
	}))
end

local frozen2 = table.freeze(values)
return table.freeze({
	ISLAND = "Middle Town",
	MAP_MODEL_NAME = "Town",
	PICKUP_ROTATION = cframe,
	MAP_GROUND_RAY_DISTANCE = 2,
	PICKUP_SURFACE_OFFSET = 0.04,
	PICKUP_RANGE = 12,
	CHECKPOINTS = frozen2,
	CHECKPOINT_FOLDER_NAME = "MiddleTownTreasureMapSteps",
	MAP_PIECE_NAME = "Broken Map Piece",
	MAP_PIECE_ROTATION = CFrame.Angles(1.5707963267948966, 0, 0),
	MAP_PIECE_RANGE = 12,
	MAP_PIECE_HOLD_DURATION = 0.4,
	GROUND_RAY_HEIGHT = 128,
	GROUND_MIN_NORMAL_Y = 0.75,
	MAP_TREE_MODEL_NAME = "Tree",
	MAP_TREE_LEAF_NAME = "Grass",
	MAP_PIECE_TREE_EXCLUSION_RADIUS = 40,
	MAP_TREE_REQUIRED_HITS = 3,
	MAP_TREE_RETRY_INTERVAL = 3,
	MAP_TREE_HIT_RANGE = 40,
	MAP_TREE_FX_RANGE = 300,
	MAP_DROP_MIN_RADIUS = 3,
	MAP_DROP_MAX_RADIUS = 7,
	MAP_DROP_ATTEMPTS = 12,
	MAP_DROP_RAY_HEIGHT = 8,
	MAP_DROP_RAY_DEPTH = 24,
	MAP_DROP_CANOPY_DROP_SCALE = 0.25,
	MAP_DROP_FALL_DURATION = 0.85,
	MAP_DROP_TUMBLE = CFrame.Angles(-1.3089969389957472, 2.443460952792061, 0.5235987755982988),
	MAP_TOOL_NAME = "Treasure Map",
	MAP_ITEM_TYPE = "Map",
	ITEM_TAG = "XMarksTheSpotItem",
	ITEM_ATTRIBUTE = "XMarksTheSpotItemType",
	TARGET_OWNER_ATTRIBUTE = "XMarksTheSpotOwner",
	TARGET_NAME = "X Marks The Spot",
	TARGET_TAG = "M1HitRegistry",
	TARGET_SIZE = createVector(4, 0.1, 4),
	TARGET_HIT_RANGE = 30,
	REQUIRED_HITS = 3,
	FINAL_MOUND_REVEAL_DELAY = 0.3,
	CHEST_NAME = "Buried Treasure",
	CHEST_RANGE = 12,
	CHEST_HOLD_DURATION = 0.4,
	SKELETON_NAME = "Desert Skeleton",
	SKELETON_COUNT = 3,
	SKELETON_OFFSETS = table.freeze({ createVector(9, 0, 0), createVector(-4.5, 0, 7.8), createVector(-4.5, 0, -7.8) }),
	SKELETON_GROUND_RAY_DISTANCE = 2,
	SKELETON_FOLLOW_RANGE = 250,
	MAP_LOST_NOTIFICATION = "You have lost your treasure map.",
	MAP_BACKGROUND_IMAGE = v["MapBg.png"] or "",
	MAP_FRAME_SIZE = UDim2.fromScale(0.8, 0.8),
	MAP_MAX_SIZE = Vector2.new(1280, 720),
	MAP_ASPECT_RATIO = 1.7777777777777777,
	ROUTE_COLOR = Color3.fromRGB(215, 38, 32),
	ROUTE_SHINE_COLOR = Color3.new(0, 0, 0),
	ROUTE_OUTLINE_COLOR = Color3.new(0, 0, 0),
	ROUTE_OUTLINE_THICKNESS = 1,
	ROUTE_SEGMENT_SIZE = UDim2.fromScale(0.0153322, 0.00909091),
	ROUTE_SEGMENT_SPACING_SCALE = 0.023,
	ROUTE_CURVE_AMOUNT = 0.22,
	ROUTE_CURVE_COUNT = 2,
	ROUTE_LENGTH_SAMPLES = 64,
	ROUTE_CURVE_SCALES = table.freeze({
		1,
		0.85,
		0.7,
		0.55,
		0.4,
		0.25,
		0
	}),
	ROUTE_INTER_ROUTE_PADDING_SCALE = 0.003,
	ROUTE_SHARED_ENDPOINT_IGNORE_SEGMENTS = 2,
	ROUTE_DRAW_INTERVAL = 0.075,
	ROUTE_SHINE_INTERVAL = 0.055,
	ROUTE_SHINE_DURATION = 0.3,
	ROUTE_SHINE_REPEAT_INTERVAL = 5,
	MARKER_POP_DELAY = 0.05,
	MARKER_POP_START_SCALE = 0.01,
	MARKER_POP_PEAK_SCALE = 1.5,
	MARKER_POP_GROW_DURATION = 0.3,
	MARKER_POP_SETTLE_DURATION = 0.18,
	MARKER_BOUNCE_MAX_SCALE = 1.15,
	MARKER_BOUNCE_MIN_SCALE = 0.9,
	MARKER_BOUNCE_DURATION = 0.2,
	MARKER_BOUNCE_COOLDOWN = 1,
	DIG_SOUNDS = table.freeze({
		"MiddleTownSFX.Punch_Dirt_Treasure_Mound_01",
		"MiddleTownSFX.Punch_Dirt_Treasure_Mound_02",
		"MiddleTownSFX.Punch_Dirt_Treasure_Mound_03",
		"MiddleTownSFX.BF_MidTown_Punch_Dirt_Treasure_Mound_04",
		"MiddleTownSFX.BF_MidTown_Punch_Dirt_Treasure_Mound_05",
		"MiddleTownSFX.BF_MidTown_Punch_Dirt_Treasure_Mound_06"
	}),
	MAP_FALL_SOUND = "MiddleTownSFX.BF_MidTown_Map_Falls_From_Tree_01",
	PIECE_PICKUP_SOUND = "MiddleTownSFX.BF_MidTown_Pickup_New_Map_Piece_01",
	MAP_OPEN_SOUND = "MiddleTownSFX.BF_MidTown_Treasure_Map_Open_01",
	MAP_CLOSE_SOUND = "MiddleTownSFX.BF_MidTown_Treasure_Map_Close_01",
	ROUTE_DRAW_SOUND = "MiddleTownSFX.Map_Draw_Line_To_Next_Location_01",
	MARKER_POP_SOUND = "MiddleTownSFX.Map_Location_Pulsing_Indicator_01"
})