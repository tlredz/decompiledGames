local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local isServer = RunService:IsServer()
local isStudio = RunService:IsStudio()
local v = not isServer and UserInputService.PreferredInput == Enum.PreferredInput.Touch
local STREAMING = {
	TARGET_RADIUS = 300,
	DELETE_COUNT_BUFFER = 50,
	DELETE_COUNT_BUFFER_FAST = 75,
	INSERT_DELETE_COUNT_BUFFER = 550,
	CREATE_INSTANCE_COUNT_BUFFER = 550,
	STREAM_DIR_STACKING_WEIGHT_BUFFER = 950,
	STREAM_DIR_REPLICATION_WEIGHT_BUFFER = 950
}
local normalMode = STREAMING.TARGET_RADIUS * 2.4
STREAMING.COLLECTABLES_RANGE_BY_TYPE = {
	Star = {
		NormalMode = normalMode * 2,
		PerfMode = normalMode * 2
	},
	Default = {
		NormalMode = normalMode,
		PerfMode = normalMode * 0.85
	}
}
local v4 = {
	IS_SERVER = isServer,
	IS_CLIENT = not isServer,
	IS_STUDIO = isStudio,
	IS_MOBILE = v,
	IS_PRIVATE_SERVER = isServer and game.PrivateServerId ~= "",
	TAGS_MAP = {
		Traps = {
			PLACED_TRAP = "PlacedTrap",
			UNPLACE_PROMPT = "TrapUnplacePrompt"
		},
		GravityDisruptors = {
			PLACED_DISRUPTOR = "PlacedGravityDisruptor",
			UNPLACE_PROMPT = "GravityDisruptorUnplacePrompt"
		},
		Gameplay = {
			COLLISION_PART = "CollisionPart",
			SAFE_ZONE = "SafeZone"
		}
	},
	STREAMING = STREAMING,
	BUTTON_FX = {
		BUTTON_MOUSE_DOWN_SOUND = "rbxassetid://100671636189844"
	},
	BACKPACK = {
		LIMIT = 250,
		HARD_LIMIT = 250,
		MAX_POWDERS = 120
	},
	OFFLINE_ASSETS = {
		MAX_DURATION_SECONDS = 36000,
		MONEY_RATE_MULTIPLIER = 0.1,
		MIN_CLAIM_MONEY = 5
	},
	BASE_FRAME_RATE = 60,
	STUDIO_YIELD_TIMEOUT = isStudio and 60 or 9999999,
	STUDIO_RESET_PLAYER_DATA_ON_UNLOAD = false,
	GROUP_ID = 825735094,
	MAIN_DEV_ID = 4035869470,
	OWNER_ID = 1065906907,
	TEST_PLACE_ID = 98345564489939,
	JOIN_BADGE = 2590480615884365,
	MIN_PLACE_GRID_SIZE = 3,
	CLIENT_OVERLAP_MARGIN = 0.95,
	SERVER_REDUCTION_FACTOR = 0.75,
	SERVER_MIN_GRID_SIZE = 2.25,
	MAX_PET_EXTRA_SLOTS = 5,
	MAX_INVENTORY_SLOTS_PURCHASE = 5,
	INVENTORY_SLOT_PURCHASE_INCREMENT = 5,
	BRAINROT_MAX_HATCH_PER_REQUEST = 24,
	ASSET_BALANCING_PROGRESS_INCREMENT_PERCENT = 13,
	ASSET_BALANCING_GIGA_MULTIPLIER = 1,
	BLOODLIT_EVENT_WEIGHT_REQ = 5,
	BLOODLIT_BACKPACK_BONUS = 50,
	BASE_ASSETS_WALK_SPEED = 13,
	BASE_WALK_SPEED = 16,
	BASE_JUMP_HEIGHT = 7,
	BASE_CARRY_POWER = 1,
	DEFAULT_BASE_LOCK_DURATION = 120,
	LUCKY_BLOCK_TOOL_NAME = "LuckyBlockTool",
	ROBUX_ICON_STR = ""
}
local v5

if RunService:IsStudio() then
	v5 = os.time() - 500
else
	v5 = game.PlaceId == 121856883734174 and 1790344800 or 1790434800
end

v4.UPDATE_LIVE_AT = v5
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return require(ReplicatedStorage.Shared.Flags.BalanceConfig).Bind("Game.Balance.Player", v4, {
	BACKPACK = true,
	OFFLINE_ASSETS = true,
	BASE_WALK_SPEED = true,
	BASE_JUMP_HEIGHT = true
}, false, function(p)
	local v6

	if p.BASE_WALK_SPEED > 0 then
		v6 = p.BASE_WALK_SPEED < 300
	else
		v6 = false
	end

	assert(v6)

	for _, v7 in p.BACKPACK do
		assert(v7 % 1 == 0)
	end
end)