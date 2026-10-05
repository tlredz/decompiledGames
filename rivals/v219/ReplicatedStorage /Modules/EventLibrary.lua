local v = {
	Summer = {
		CURRENCY_NAME = "Pearl",
		CURRENCY_NAME_PLURAL = "Pearls",
		CURRENCY_IMAGE = "rbxassetid://128587370010060",
		CURRENCY_IMAGE_FLAT = "rbxassetid://93406657709407",
		CURRENCY_IMAGE_FLAT_OUTLINE = "rbxassetid://95350863643200",
		CURRENCY_COLOR = Color3.fromRGB(239, 176, 255),
		CURRENCY_COLOR_GRADIENT = nil,
		BUNDLE_BACKGROUND_IMAGES = {
			[1] = "rbxassetid://120786971461452",
			[4] = "rbxassetid://73561500503723",
			[5] = "rbxassetid://79528672047345"
		},
		OVERVIEW_BANNER_IMAGE = "rbxassetid://117618245635260",
		OVERVIEW_BUTTON_IMAGE = "rbxassetid://92989711430837",
		LOADING_SCREEN_LOGO = "rbxassetid://85313933907097",
		LOBBY_MUSIC = "Tropical",
		LOBBY_MUSIC_MUFFLED = "TropicalMuffled",
		LOBBY_LIGHTING_PROFILE = "LobbyTropical",
		EQUIPMENT_LIGHTING_PROFILE = "LobbyTropical",
		LTM_HEADER_ICON = "rbxassetid://78136793834272",
		GLOWY_BACKGROUND_COLOR_OVERRIDES = {
			Purple = Color3.fromRGB(42, 85, 111),
			Purple2 = Color3.fromRGB(31, 61, 144),
			Yellow = Color3.fromRGB(17, 0, 254)
		}
	},
	Spooky = {
		CURRENCY_NAME = "Candy",
		CURRENCY_NAME_PLURAL = "Candy",
		CURRENCY_IMAGE = "rbxassetid://139984992207621",
		CURRENCY_IMAGE_FLAT = "rbxassetid://105505748492292",
		CURRENCY_IMAGE_FLAT_OUTLINE = "rbxassetid://90825880394324",
		CURRENCY_COLOR = Color3.fromRGB(255, 127, 0),
		CURRENCY_COLOR_GRADIENT = nil,
		BUNDLE_BACKGROUND_IMAGES = {
			[1] = "rbxassetid://140701532981455",
			[5] = "rbxassetid://121767138688269"
		},
		OVERVIEW_BANNER_IMAGE = "rbxassetid://139741589762862",
		OVERVIEW_BUTTON_IMAGE = "rbxassetid://80974689450076",
		LOADING_SCREEN_LOGO = "rbxassetid://120926957566724",
		LOBBY_MUSIC = "Spooky",
		LOBBY_MUSIC_MUFFLED = "SpookyMuffled",
		LOBBY_LIGHTING_PROFILE = "LobbySpooky",
		EQUIPMENT_LIGHTING_PROFILE = "LobbySpooky",
		LTM_HEADER_ICON = "rbxassetid://78136793834272"
	},
	Festive = {
		CURRENCY_NAME = "Crystal",
		CURRENCY_NAME_PLURAL = "Crystals",
		CURRENCY_IMAGE = "rbxassetid://134934134842764",
		CURRENCY_IMAGE_FLAT = "rbxassetid://116178247622565",
		CURRENCY_IMAGE_FLAT_OUTLINE = "rbxassetid://89625231758124",
		CURRENCY_COLOR = Color3.fromRGB(48, 221, 255),
		CURRENCY_COLOR_GRADIENT = nil,
		BUNDLE_BACKGROUND_IMAGES = {
			[1] = "rbxassetid://135222754688862",
			[5] = "rbxassetid://93388902108383"
		},
		OVERVIEW_BANNER_IMAGE = "rbxassetid://109554184678249",
		OVERVIEW_BUTTON_IMAGE = "rbxassetid://134934134842764",
		LOADING_SCREEN_LOGO = "rbxassetid://101362140024495",
		LOBBY_MUSIC = "Festive",
		LOBBY_MUSIC_MUFFLED = "FestiveMuffled",
		LOBBY_LIGHTING_PROFILE = "LobbyFestive",
		EQUIPMENT_LIGHTING_PROFILE = "LobbyFestive",
		LTM_HEADER_ICON = "rbxassetid://78136793834272"
	}
}
local EventLibrary = {
	IS_ACTIVE = false,
	NUM_GAMES_NEEDED_TO_PARTICIPATE = 15,
	RESET_CURRENCY_COUNTER = 8,
	RESET_CURRENCY_COMPENSATION_MILESTONE = 30,
	RESET_CURRENCY_COMPENSATION_REWARDS = {
		{
			Name = "Tropical Chest",
			Quantity = 1,
			Weapon = "IsRandom"
		}
	},
	RESET_CURRENCY_COMPENSATION_REWARDS_CAN_MULTIPLY_QUANTITY = true,
	LAST_EVENT_NAME = "Summer",
	EVENT_NAME = "Summer",
	EVENT_TASK_NAMES = { "EventDuelRoundPlayed", "EventEliminations", "EventDuelWon" },
	CURRENCY_RUSH_DAILY_LIMIT = 200,
	CURRENCY_RUSH_MULTIPLIER = 5,
	LTM_QUEUENAMES = {},
	UNIVERSAL_SHOP_CHARM = "Shark",
	UNIVERSAL_SHOP_WRAP = "Sea Glass",
	UNIVERSAL_SHOP_FINISHER = "Whirlpool",
	UNIVERSAL_SHOP_EMOTE = "Surfing",
	SPECIAL_LOOTBOX_SKINS = "Summer Skin Case",
	SPECIAL_LOOTBOX_VARIETY = "Tropical Chest",
	CURRENCY_BUNDLE_CHARM = "Shiny Pearl",
	CURRENCY_BUNDLE_WRAP = "Pearlescent",
	CURRENCY_BUNDLE_FINISHER = "Clammed",
	CURRENCY_BUNDLE_SKIN = "Riptide Katana",
	EVENT_GIFT_REWARD = nil,
	EVENT_GIFT_COOLDOWN = 3600,
	SHOP_ENTRIES_OVERVIEW = { "loose_palmscythe" }
}
EventLibrary.EVENT_DETAILS = v[EventLibrary.EVENT_NAME]
EventLibrary.LAST_EVENT_DETAILS = v[EventLibrary.LAST_EVENT_NAME]
EventLibrary.LOBBY_VISUALS_PROFILE = not EventLibrary.IS_ACTIVE and "Default" or EventLibrary.EVENT_NAME

local function populate_shop_entries()
	if EventLibrary.SPECIAL_LOOTBOX_SKINS then
		table.insert(EventLibrary.SHOP_ENTRIES_OVERVIEW, "lootbox_" .. EventLibrary.SPECIAL_LOOTBOX_SKINS)
	end

	if EventLibrary.SPECIAL_LOOTBOX_VARIETY then
		table.insert(EventLibrary.SHOP_ENTRIES_OVERVIEW, "lootbox_" .. EventLibrary.SPECIAL_LOOTBOX_VARIETY)
	end

	if EventLibrary.UNIVERSAL_SHOP_CHARM then
		table.insert(EventLibrary.SHOP_ENTRIES_OVERVIEW, "loose_" .. EventLibrary.UNIVERSAL_SHOP_CHARM)
	end

	if EventLibrary.UNIVERSAL_SHOP_WRAP then
		table.insert(EventLibrary.SHOP_ENTRIES_OVERVIEW, "loose_" .. EventLibrary.UNIVERSAL_SHOP_WRAP)
	end

	if EventLibrary.UNIVERSAL_SHOP_FINISHER then
		table.insert(EventLibrary.SHOP_ENTRIES_OVERVIEW, "loose_" .. EventLibrary.UNIVERSAL_SHOP_FINISHER)
	end

	if EventLibrary.UNIVERSAL_SHOP_EMOTE then
		table.insert(EventLibrary.SHOP_ENTRIES_OVERVIEW, "loose_" .. EventLibrary.UNIVERSAL_SHOP_EMOTE)
	end
end

populate_shop_entries()
return EventLibrary