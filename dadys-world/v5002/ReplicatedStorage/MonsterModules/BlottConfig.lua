local createVector = vector.create
local BlottConfig = {
	DEBUG = {
		HAND_STATE = false,
		TRIGGER_ZONE_TRANSPARENCY = 0.9
	},
	STATS = {
		NAME = "Twisted Blot",
		RARITY = "Rare",
		ICON = "rbxassetid://95105136839962",
		VISION_RADIUS = 0,
		INSTANT_RADIUS = 0,
		WALK_SPEED = 0,
		RUN_SPEED = 0,
		INTEREST_TIME = 0,
		HEARING_RADIUS = 0,
		DAMAGE = 1,
		WAIT_TIME = 1,
		LINE_OF_SIGHT = 0,
		KILL_RADIUS = 4,
		HIT_COOLDOWN = 2,
		RESEARCH_RADIUS = 20,
		LOST_INTEREST_ANIMATION_TIME = 0
	},
	PROPERTIES = {
		HOLIDAY = false
	},
	TEXTURES = {
		BLINK = "rbxassetid://94533343995296",
		NORMAL = "rbxassetid://88467880715704",
		ATTACK = "rbxassetid://137066710753963"
	},
	HANDS = {
		COUNT = 2,
		SIZE = createVector(12, 5, 12),
		GROUND_OFFSET = 0,
		TIMING = {
			EMERGE_TIME = 1.5,
			IDLE_TIME = 5,
			ATTACK_TIME = 0.5,
			COOLDOWN_TIME = 3,
			RETURN_TIME = 1,
			SEARCH_TIME = 2,
			AGGRO_CYCLE = 60,
			IDLE_CYCLE = 20
		},
		ANIMATIONS = {
			EMERGE = "rbxassetid://18436322051847",
			ATTACK = "rbxassetid://89779659652969",
			IDLE = "rbxassetid://18431031142537",
			RETURN = "rbxassetid://86993134095419"
		},
		STATES = {
			EMERGING = "Emerging",
			IDLE = "Idle",
			ATTACKING = "Attacking",
			COOLDOWN = "Cooldown",
			RETURNING = "Returning",
			SEARCHING = "Searching"
		},
		POSITIONING = {
			MIN_DISTANCE_FROM_PLAYERS = 15,
			MAX_DISTANCE_FROM_BLOT = 50,
			MIN_DISTANCE_BETWEEN_HANDS = 10,
			OBSTACLE_AVOIDANCE_RADIUS = 5,
			GROUND_CHECK_RADIUS = 3
		}
	},
	ZONES = {
		TYPE = "BlotHandZone",
		TRANSPARENCY = 0.9,
		MATERIAL = Enum.Material.ForceField,
		COLOR = Color3.fromRGB(255, 0, 0)
	},
	PERFORMANCE = {
		UPDATE_INTERVAL = 0.1,
		CLEANUP_INTERVAL = 5,
		MAX_HANDS_PER_INSTANCE = 10,
		CACHE_DURATION = 1
	},
	ICHOR = {
		SIZE = createVector(6, 1, 6),
		DURATION = 30,
		SPAWN_CHANCE = 0.3,
		Y_OFFSET = 0.5
	},
	SOUNDS = {
		HAND_EMERGE = {
			ID = "rbxassetid://example1",
			VOLUME = 0.5,
			PITCH = 1
		},
		HAND_ATTACK = {
			ID = "rbxassetid://example2",
			VOLUME = 0.7,
			PITCH = 1.2
		},
		HAND_RETURN = {
			ID = "rbxassetid://example3",
			VOLUME = 0.4,
			PITCH = 0.8
		}
	}
}

function BlottConfig.Validate()
	assert(BlottConfig.HANDS.COUNT > 0, "Hand count must be positive")
	assert(BlottConfig.HANDS.SIZE.X > 0, "Hand zone size must be positive")
	assert(BlottConfig.HANDS.TIMING.EMERGE_TIME > 0, "Emerge time must be positive")
	return true
end

return BlottConfig