local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
require(script.Parent.Types)
return {
	WINDOW_ID = "CC Panel",
	WINDOW_WIDTH = 420,
	INVITE_WINDOW_ID = "CC Worlds Invite",
	INVITE_WINDOW_WIDTH = 300,
	INVITE_WINDOW_TOP = 90,
	PICKER_WINDOW_ID = "CC Panel Players",
	PICKER_WINDOW_WIDTH = 240,
	PICKER_GAP = 8,
	ICON_NAME = "CCPanel",
	ICON_LABEL = "CC Panel",
	TROLL_COOLDOWN = 10,
	TROLL_SERVER_THROTTLE = 9,
	MAX_SET_WINS = 100000000000000,
	MAX_SET_LEVEL = 2000,
	MAX_WORLD_INDEX = 10,
	MAX_GIVE_AMOUNT = 100,
	MAX_ITEM_TIER = Items.MAX_TIER,
	MAX_CUSTOM_MULTIPLIER = 1000000,
	MULTIPLIER_KINDS = { "speed", "wins" },
	KEY_CHAR_PATTERN = "^" .. string.rep("[%w%p]?", 12) .. "$",
	KEY_SCALE_MIN = 0.5,
	KEY_SCALE_MAX = 5,
	KEY_SCALE_STEP = 0.25,
	MAX_ASSET_ID = 1000000000000000,
	MAX_EVENT_MINUTES = 120,
	USERNAME_PATTERN = "^" .. string.rep("[%w_]", 3) .. string.rep("[%w_]?", 17) .. "$",
	INVITE_ID_PATTERN = "^" .. string.rep("%x", 8) .. "%-" .. string.rep("%x", 4) .. "%-" .. string.rep("%x", 4) .. "%-" .. string.rep(
		"%x",
		4
	) .. "%-" .. string.rep("%x", 12) .. "$",
	FREECAM_DEFAULT_SPEED = 20,
	FREECAM_MIN_SPEED = 5,
	FREECAM_MAX_SPEED = 200,
	FREECAM_SPEED_STEP = 5,
	FREECAM_BOOST = 3,
	FREECAM_LOOK_SENSITIVITY = 0.003,
	FREECAM_FOCUS_DISTANCE = 10,
	STATUS_DURATION = 3,
	TICK_INTERVAL = 0.25,
	PLAYER_LIST_HEIGHT = 170,
	CATALOG_LIST_HEIGHT = 150,
	EVENT_LIST_HEIGHT = 110,
	LIST_ROW_HEIGHT = 22,
	STATUS_COLOR = Color3.fromRGB(220, 220, 230),
	SUCCESS_COLOR = Color3.fromRGB(90, 200, 120),
	ERROR_COLOR = Color3.fromRGB(230, 90, 90),
	SELECTED_COLOR = Color3.fromRGB(40, 80, 140),
	DANGER_COLOR = Color3.fromRGB(150, 50, 50),
	TOAST_SUCCESS_COLOR = Color3.fromRGB(0, 220, 110),
	TOAST_ERROR_COLOR = Color3.fromRGB(255, 60, 60),
	WORLD_CATEGORY_IDS = {
		"auras",
		"trails",
		"items",
		"treadmills"
	},
	WORLD_CATEGORY_LABELS = {
		auras = {
			giveAll = "Give all Auras",
			tab = "Auras"
		},
		trails = {
			giveAll = "Give all Trails",
			tab = "Trails"
		},
		items = {
			giveAll = "Give all Items",
			tab = "Items"
		},
		treadmills = {
			giveAll = "Give all Treadmills + Skins",
			tab = "Treadmills"
		}
	}
}