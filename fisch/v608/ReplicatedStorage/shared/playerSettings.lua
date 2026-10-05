require("@self/Types")
local module = require("./modules/library/rarities")
local group = nil
local count = 0

local function setGroup(p: string)
	group = p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _sett(p)
	return function(p2)
		p2.Group = group
		count += 1
		p2.Order = count
		p2.Type = p
		return p2
	end
end

local v3 = _sett("toggle") -- equivalent call inferred; original call site unknown
local v5 = _sett("slider") -- equivalent call inferred; original call site unknown
local v7 = _sett("checkbox") -- equivalent call inferred; original call site unknown
local v9 = _sett("dropdown") -- equivalent call inferred; original call site unknown
local v11 = _sett("color") -- equivalent call inferred; original call site unknown
local v13 = _sett("dumb") -- equivalent call inferred; original call site unknown
local v15 = _sett("quickAccessSlot") -- equivalent call inferred; original call site unknown
group = "Audio"
local PlayerSettings = {
	_ = nil,
	musicVolume = v5({
		Name = "Music Volume",
		MinValue = 0,
		MaxValue = 200
	}),
	ambienceVolume = v5({
		Name = "Ambience Volume",
		MinValue = 0,
		MaxValue = 200
	}),
	weatherVolume = v5({
		Name = "Weather Volume",
		MinValue = 0,
		MaxValue = 200
	}),
	radioVolume = v5({
		Name = "Boombox Volume (Others)",
		MinValue = 0,
		MaxValue = 200
	}),
	fishingVolumeOthers = v5({
		Name = "Fishing Volume (Others)",
		Description = "Adjusts the volume for sounds related to fishing from other players.",
		MinValue = 0,
		MaxValue = 200
	}),
	fishingVolumeSelf = v5({
		Name = "Fishing Volume (Myself)",
		Description = "Adjusts the volume for sounds related to fishing from yourself.",
		MinValue = 0,
		MaxValue = 200
	}),
	rodVolumeOthers = v5({
		Name = "Rod Music Volume (Others)",
		Description = "Adjusts the volume of music emitted by fishing rods equipped by other players.",
		MinValue = 0,
		MaxValue = 200
	}),
	rodVolumeSelf = v5({
		Name = "Rod Music Volume (Myself)",
		Description = "Adjusts the volume of music emitted by your equipped fishing rod.",
		MinValue = 0,
		MaxValue = 200
	}),
	bobberVolume = v5({
		Name = "Bobber Volume",
		Description = "Adjusts the volume for other players' cosmetic bobbers.",
		MinValue = 0,
		MaxValue = 200
	}),
	emoteVolumeOthers = v5({
		Name = "Emote Volume (Others)",
		Description = "Adjusts the volume of other players' emotes.",
		MinValue = 0,
		MaxValue = 200
	}),
	emoteVolumeSelf = v5({
		Name = "Emote Volume (Myself)",
		Description = "Adjusts the volume of your own emotes.",
		MinValue = 0,
		MaxValue = 200
	})
}
group = "Appearance"
PlayerSettings._ = nil
PlayerSettings.brightness = v5({
	Name = "Extra Brightness",
	MinValue = 0,
	MaxValue = 0.2
})
PlayerSettings.saturation = v5({
	Name = "Extra Saturation",
	MinValue = 0,
	MaxValue = 0.4
})
PlayerSettings.enableTints = v3({
	Name = "Enable Environment Tints",
	Description = "Toggles the tinted environments from certain events, such as Blue Moon"
})
PlayerSettings.photosensitiveMode = v3({
	Name = "Photosensitive Mode",
	Description = [[
Reduces the frequency or intensity of certain bright/flashing effects.
When <i>disabling</i> this setting, you may need to rejoin the game to fully restore the effects.]]
})
PlayerSettings.shownVfx = v9({
	Name = "VFX Visibility",
	Aliases = { "Performance Mode", "Optimization" },
	Options = {
		All = {
			Name = "Show All",
			Order = 1
		},
		LocalOnly = {
			Name = "Hide Others",
			Order = 2
		},
		HideAll = {
			Name = "Hide All",
			Order = 3
		}
	}
})
PlayerSettings.shadowsEnabled = v3({
	Name = "Shadows Enabled",
	Aliases = { "Performance Mode", "Optimization" }
})
PlayerSettings.cloudsEnabled = v3({
	Name = "Clouds Enabled",
	Aliases = { "Performance Mode", "Optimization" }
})
PlayerSettings.autoPerformance = v3({
	Name = "Auto-Toggle Performance Settings",
	Aliases = { "Performance Mode", "Automatic", "Optimization" },
	Description = "When enabled, performance settings will be automatically adjusted when the game detects low FPS."
})
PlayerSettings.showRoamers = v3({
	Name = "Show Roaming Fish",
	Aliases = { "Show Fish In Water Enabled", "Show Swimming Fish Enabled", "Roaming Fish Enabled" },
	Description = [[
When disabled, roaming fish will be hidden unless holding a Harpoon Gun, Spear, or Fish Radar.
<b>This will not affect gameplay, you will just be unable to see them.</b>]]
})
PlayerSettings.showHeldFish = v3({
	Name = "Show Others' Held Fish",
	Description = "Toggles the visibility of fish that other players are holding"
})
PlayerSettings.showFishWater = v3({
	Name = "Show Others' Fish In Water",
	Description = "Toggles the visibility of fish that other players are currently catching"
})
PlayerSettings.showLanterns = v3({
	Name = "Show Others' Lanterns",
	Description = "Toggles the visibility of other players' lanterns, including the light they emit"
})
PlayerSettings.showCatchFlags = v3({
	Name = "Show Catch Flags",
	Description = "Toggles the visibility of catch flags placed on the ground when rare fish are caught."
})
PlayerSettings.disableCutscenes = v3({
	Name = "Disable Fish Cutscenes",
	Description = "Skips the cutscenes when catching certain fish after they have been seen at least once"
})
PlayerSettings.windShake = v3({
	Name = "Wind Shake",
	Description = "Toggles a subtle shake effect on foliage. [Requires Rejoin]"
})
PlayerSettings.cameraShake = v3({
	Name = "Camera Shake",
	Description = "Toggles whether the camera should shake during the fishing minigame and from nearby lightning strikes"
})
PlayerSettings.minigameShake = v5({
	Name = "Fishing Minigame Shake",
	Aliases = { "Reeling" },
	Description = "Adjusts the intensity of the effects that shake the fishing minigame.",
	MinValue = 0,
	MaxValue = 1
})
PlayerSettings.showRain = v3({
	Name = "Show Rain",
	Aliases = { "Hide Rain", "Performance Mode" }
})
PlayerSettings.statusScale = v5({
	Name = "Status Effects Scale",
	Aliases = { "Buffs", "Debuffs" },
	Description = "Adjusts the scale of the list of Status Effects in the bottom left corner.",
	MinValue = 0,
	MaxValue = 2
})
PlayerSettings.seeOwnName = v3({
	Name = "See My Own Nametag",
	Description = "Toggles the visibility of the player nametag above your head"
})
PlayerSettings.showServerInfo = v3({
	Name = "Server Info UI Enabled",
	Description = "Displays the uptime, location, and version of your current server"
})
PlayerSettings.poiHeaders = v3({
	Name = "Show Island Markers",
	Aliases = { "Points of Interest", "Island Names", "POI Headers" },
	Description = "Toggles the visibility of the location markers above major islands and points of interest"
})
PlayerSettings.showRodAccessories = v3({
	Name = "Show Rod Accessories",
	Aliases = { "Rod Skin", "Aura", "Avatar" },
	Description = "Toggles the visibility of any accessories added to the character while a rod is equipped"
})
PlayerSettings.questIndicators = v9({
	Name = "Shown Quest Indicators",
	Description = "Toggles the visibility of indicators for available quests",
	Options = {
		All = {
			Name = "All"
		},
		Major = {
			Name = "Major Only"
		},
		None = {
			Name = "None"
		}
	}
})
PlayerSettings.newEquipment = v3({
	Name = "New Equipment Tab Style",
	Description = "If enabled, use the new tab style in the equipment bag"
})
PlayerSettings.rodStatDisplay = v9({
	Name = "Equipment Stat Display",
	Aliases = { "Rod Stat Display" },
	Description = "Determines the style of stats in the equipment bag",
	Options = {
		Names = {
			Name = "Names"
		},
		Icons = {
			Name = "Icons"
		},
		Disabled = {
			Name = "Disabled"
		}
	}
})
PlayerSettings.rodSkinImage = v3({
	Name = "Rod Skin Images",
	Description = "Toggles the main rod image in the equipment bag changing with the equipped skin"
})
PlayerSettings.newBestiary = v3({
	Name = "New Bestiary",
	Description = "If enabled, use the new bestiary UI. (Rejoining after toggle is recommended but not mandatory)"
})
PlayerSettings.fishChancesMode = v9({
	Name = "Fish Chance Display",
	Options = {
		Fraction = {
			Name = "Fraction"
		},
		Percentage = {
			Name = "Percentage"
		},
		Disabled = {
			Name = "Disabled"
		}
	}
})
PlayerSettings.adminEventVfx = v3({
	Name = "Admin Event Lighting",
	Description = "Toggles the visiblity of the VFX and lighting during Admin Events."
})
group = "Gameplay"
PlayerSettings._ = nil
PlayerSettings.tradeRequests = v9({
	Name = "Allow Trade Requests",
	Aliases = { "Trading", "Offer" },
	Description = "Determines who can request to trade with you",
	Options = {
		Anyone = {
			Name = "From Anyone"
		},
		Friends = {
			Name = "From Friends"
		},
		Nobody = {
			Name = "Disabled"
		}
	}
})
PlayerSettings.crewInvites = v9({
	Name = "Allow Crew Invites",
	Aliases = { "Crews", "Invite" },
	Description = "Determines who can invite you to their crew",
	Options = {
		Anyone = {
			Name = "From Anyone"
		},
		Friends = {
			Name = "From Friends"
		},
		Nobody = {
			Name = "Disabled"
		}
	}
})
local options = {
	Crates = {
		Name = "Crates",
		DefaultValue = false,
		Order = 0
	}
}
local v17 = {
	Name = "Auto-sell Preferences",
	Aliases = { "Sell Inventory", "Sell Storage", "Merchant" },
	Description = "What should be auto-sold at merchants? (Favorited items will never auto-sell)",
	Options = 0,
	VisibleFilter = 0
}

for _, orderedRarity in module.OrderedRarities do
	if not orderedRarity.NonFish then
		options[orderedRarity.Name] = {
			Name = orderedRarity.Name,
			DefaultValue = orderedRarity.AutoSellMode == "always",
			Order = orderedRarity.Order,
			Color = orderedRarity.ColorGradient or orderedRarity.Color
		}
	end
end

v17.Options = options

function v17.VisibleFilter(_, _)
	return true
end

PlayerSettings.autosell = v7(v17)
PlayerSettings.questAutoFavorite = v3({
	Name = "Auto-Favorite Quest Fish",
	Description = "Automatically favorites fish for active \"Catch and Return\" quests. <b>Not yet supported by all quests.</b>"
})
PlayerSettings.steeringMode = v9({
	Name = "Boat Steering Mode",
	Description = "Change how boat steering works.",
	Options = {
		standard = {
			Name = "Standard",
			Order = 1
		},
		simple = {
			Name = "Simplified",
			Order = 2
		}
	}
})
PlayerSettings.steeringSensitivity = v5({
	Name = "Boat Steering Sensitivity",
	Aliases = { "Steering Speed", "Boat Handling", "Boat Turning Speed" },
	Description = "Adjusts how quickly boats turn. (Only applies in Standard steering mode)",
	MinValue = 0.25,
	MaxValue = 2
})
PlayerSettings.boatPrivacy = v9({
	Name = "Boat Seating Privacy",
	Description = "Control who can sit in the passenger seats of your boats.",
	Options = {
		anyone = {
			Name = "Anyone",
			Order = 1
		},
		friendsAndCrew = {
			Name = "Friends & Crew",
			Order = 2
		},
		friends = {
			Name = "Friends Only",
			Order = 3
		},
		crew = {
			Name = "Crew Only",
			Order = 4
		},
		nobody = {
			Name = "Nobody",
			Order = 5
		}
	}
})
PlayerSettings.heldFishInfo = v3({
	Name = "Show Held Fish Info"
})
PlayerSettings.toggleShakeChat = v3({
	Name = "Hide Chat While Shaking",
	Description = "Automatically hides the chat during the Shake minigame."
})
PlayerSettings.gliderDeployMode = v9({
	Name = "Glider Auto-Deploy",
	Description = "Determine which glider is deployed when tapping Jump in the air.",
	Options = {
		hotbar = {
			Name = "Hotbar Only (Default)",
			Order = 1
		},
		favorited = {
			Name = "Favorited First",
			Order = 2
		},
		randomFavorited = {
			Name = "Random Favorited",
			Order = 3
		},
		inventory = {
			Name = "Inventory",
			Order = 4
		},
		disabled = {
			Name = "Disabled",
			Order = 5
		}
	}
})
PlayerSettings.consoleHotkeys = v3({
	Name = "Controller Hotkeys Enabled",
	Aliases = { "dpad", "d-pad", "glider auto-deploy" },
	Description = "Toggles controller-specific hotkeys (d-pad up to equip rod, d-pad left to select topbar, etc)",
	IsVisible = function()
		local UserInputService = game:GetService("UserInputService")
		return UserInputService.GamepadEnabled
	end
})
PlayerSettings.consoleJumpProtection = v3({
	Name = "Controller Jump Protection",
	Aliases = { "a button", "spam jump", "glider" },
	Description = "Prevents jumping and deploying glider with the A button for a few seconds after fishing",
	IsVisible = function()
		local UserInputService = game:GetService("UserInputService")
		return UserInputService.GamepadEnabled
	end
})
PlayerSettings.consoleDeadzoneLeft = v5({
	Name = "Left Thumbstick Deadzone",
	Aliases = {
		"thumbpad",
		"stick drift",
		"left thumbpad",
		"gamepad",
		"console",
		"controller"
	},
	Description = "Adjusts the threshold of the deadzone for the left thumbstick.",
	MinValue = 0,
	MaxValue = 0.9,
	IsVisible = function()
		local UserInputService = game:GetService("UserInputService")
		return UserInputService.GamepadEnabled
	end
})
PlayerSettings.consoleDeadzoneRight = v5({
	Name = "Right Thumbstick Deadzone",
	Aliases = {
		"thumbpad",
		"stick drift",
		"right thumbpad",
		"gamepad",
		"console",
		"controller"
	},
	Description = "Adjusts the threshold of the deadzone for the right thumbstick.",
	MinValue = 0,
	MaxValue = 0.9,
	IsVisible = function()
		local UserInputService = game:GetService("UserInputService")
		return UserInputService.GamepadEnabled
	end
})
PlayerSettings.mobileCastButton = v3({
	Name = "Cast Button Enabled",
	Description = "When enabled, adds an on-screen button to cast the fishing rod, rather than tapping anywhere.",
	IsVisible = function()
		local UserInputService = game:GetService("UserInputService")
		return UserInputService.TouchEnabled
	end
})
PlayerSettings.showEnchantInfo = v3({
	Name = "Show Enchant Info",
	Description = "When enabled, displays details for your active enchantments while your rod is equipped."
})
PlayerSettings.shakeMisclick = v3({
	Name = "Allow Shake Button Misclicking",
	Description = "When enabled, misclicking during the Shake minigame will <b>not</b> cancel fishing.",
	IsVisible = function()
		local UserInputService = game:GetService("UserInputService")
		local mouseEnabled = UserInputService.MouseEnabled

		if not mouseEnabled then
			local UserInputService2 = game:GetService("UserInputService")
			mouseEnabled = UserInputService2.TouchEnabled
		end

		return mouseEnabled
	end
})
PlayerSettings.rhythmKeybinds = v9({
	Name = "Rhythm Game Keybinds",
	Aliases = { "Tranquility Rod", "FNF", "DFJK" },
	Description = "Choose which keys to use for the Tranquility Rod rhythm minigame",
	IsVisible = function(p)
		local rods = p.Rods
		local keyboardEnabled

		if rods == nil or rods["Tranquility Rod"] == nil then
			keyboardEnabled = false
		else
			local UserInputService = game:GetService("UserInputService")
			keyboardEnabled = UserInputService.KeyboardEnabled
		end

		return keyboardEnabled
	end,
	Options = {
		DFJK = {
			Name = "D F J K",
			Order = 1
		},
		ASDF = {
			Name = "A S D F",
			Order = 2
		},
		QWOP = {
			Name = "Q W O P",
			Order = 3
		},
		ZXCP = {
			Name = "Z X , .",
			Order = 4
		},
		Arrows = {
			Name = "Arrow Keys",
			Order = 5
		},
		WASD = {
			Name = "W A S D",
			Order = 6
		}
	}
})
PlayerSettings.rhythmGamepadKeybinds = v9({
	Name = "Rhythm Game Gamepad Buttons",
	Aliases = {
		"Tranquility Rod",
		"controller",
		"gamepad",
		"console"
	},
	Description = "Choose which buttons to use for the Tranquility Rod rhythm minigame on controller",
	IsVisible = function(p)
		local rods = p.Rods
		local gamepadEnabled

		if rods == nil or rods["Tranquility Rod"] == nil then
			gamepadEnabled = false
		else
			local UserInputService = game:GetService("UserInputService")
			gamepadEnabled = UserInputService.GamepadEnabled
		end

		return gamepadEnabled
	end,
	Options = {
		FaceButtons = {
			Name = "Face Buttons (X A Y B / □ × △ ○)",
			Order = 1
		},
		DpadFace = {
			Name = "D-Pad + Face (← → Y B / ← → △ ○)",
			Order = 2
		},
		DpadOnly = {
			Name = "D-Pad Only (← ↓ ↑ →)",
			Order = 3
		},
		Triggers = {
			Name = "Triggers + Bumpers (LT LB RB RT / L2 L1 R1 R2)",
			Order = 4
		},
		DpadAB = {
			Name = "D-Pad + A B (← ↑ A B / ← ↑ × ○)",
			Order = 5
		},
		DpadYB = {
			Name = "D-Pad + Y B (← ↓ Y B / ← ↓ △ ○)",
			Order = 6
		}
	}
})
PlayerSettings.rhythmScrollDirection = v9({
	Name = "Rhythm Game Scroll Direction",
	Aliases = {
		"Tranquility Rod",
		"FNF",
		"upscroll",
		"downscroll"
	},
	Description = "Choose whether notes scroll down or up in the Tranquility Rod rhythm minigame",
	IsVisible = function(p)
		local rods = p.Rods
		return rods ~= nil and rods["Tranquility Rod"] ~= nil
	end,
	Options = {
		Downscroll = {
			Name = "Downscroll",
			Order = 1
		},
		Upscroll = {
			Name = "Upscroll",
			Order = 2
		}
	}
})
PlayerSettings.miguRodMasteryKeybind = v9({
	Name = "MiguRod Counter-Attack Keybind",
	Aliases = { "MiguRod Mastery", "Shift" },
	Description = "Choose which key to press to launch a Retaliatory Counterattack",
	IsVisible = function(p)
		local keyboardEnabled

		if p.RodEnhancements.MiguRod == nil or p.RodEnhancements.MiguRod.Mastery1 == nil then
			keyboardEnabled = false
		else
			local UserInputService = game:GetService("UserInputService")
			keyboardEnabled = UserInputService.KeyboardEnabled
		end

		return keyboardEnabled
	end,
	Options = {
		Shift = {
			Name = "Shift (Default)",
			Order = 1
		},
		Ctrl = {
			Name = "Ctrl",
			Order = 2
		},
		Alt = {
			Name = "Alt",
			Order = 3
		},
		Space = {
			Name = "Space",
			Order = 4
		},
		Meta = {
			Name = "Command (⌘)",
			Order = 5
		}
	}
})
PlayerSettings.haloEnabled = v3({
	Name = "Supporter Halo Enabled",
	Description = `Must own the supporter gamepass ({utf8.char(57346)} 299)`
})
PlayerSettings.haloOffset = v5({
	Name = "Halo Offset (Up/Down)",
	Aliases = { "Y-Offset", "Y-Position", "Halo Position" },
	Description = "Determines the Y-position of your halo.",
	MinValue = -1,
	MaxValue = 1
})
PlayerSettings.haloOffsetX = v5({
	Name = "Halo Offset (Left/Right)",
	Aliases = { "X-Offset", "X-Position", "Halo Position" },
	Description = "Determines the X-position of your halo.",
	MinValue = -1,
	MaxValue = 1
})
PlayerSettings.haloOffsetZ = v5({
	Name = "Halo Offset (Front/Back)",
	Aliases = { "Z-Offset", "Z-Position", "Halo Position" },
	Description = "Determines the Z-position of your halo.",
	MinValue = -1,
	MaxValue = 1
})
PlayerSettings.haloColor = v11({
	Name = "Halo Color"
})
group = "Notifications"
PlayerSettings._ = nil
PlayerSettings.catchNotifications = v3({
	Name = "Show Catch Popups",
	Aliases = { "Catch Notifications", "Announces Bottom" },
	Description = "Toggles the popups at the bottom of the screen after catching a fish."
})
PlayerSettings.chatEvent = v3({
	Name = "System Chat Messages: Events",
	Description = "Toggles chat messages for server events in the General tab"
})
PlayerSettings.chatCatch = v3({
	Name = "System Chat Messages: Catches",
	Description = "Toggles chat messages for catches in the General tab"
})
PlayerSettings.chatEnchant = v3({
	Name = "System Chat Messages: Enchants",
	Description = "Toggles chat messages for enchanting in the General tab"
})
PlayerSettings.chatOther = v3({
	Name = "System Chat Messages: Other",
	Description = "Toggles chat messages from miscellaneous sources in the General tab"
})
PlayerSettings.chatCatchGlobal = v3({
	Name = "System Chat Messages: Global Catches",
	Description = "Toggles chat messages for <b>global</b> catches in all tabs"
})
PlayerSettings.splitTabs = v3({
	Name = "Chat Tabs Enabled",
	Description = "Toggles separate chat tabs for system messages"
})
PlayerSettings.systemMessages = v3({
	Name = "System Messages",
	Description = "Toggles ALL system messages in the General chat tab"
})
PlayerSettings.bountyShowdownNotif = v3({
	Name = "Bounty Showdown Reminders",
	Description = "Toggles announcements/reminders for Bounty Showdown events.",
	IsVisible = function(p)
		return p.Crews.CrewId and p.Crews.CrewId ~= ""
	end
})
PlayerSettings.announcesTop = v3({
	Name = "Show Event Notifications",
	Aliases = { "Announces Top" },
	Description = "Toggles all server announcements at the top of the screen"
})
PlayerSettings.announcesTopScale = v5({
	Name = "Event Notification Scale",
	Aliases = { "Announces Top" },
	Description = "Adjusts the scale of all server announcements at the top of the screen",
	MinValue = 0,
	MaxValue = 2
})
PlayerSettings.announcesBottom = v3({
	Name = "Show Local Notifications",
	Aliases = { "Announces Bottom" },
	Description = "Toggles all local announcements and notifications at the bottom of the screen"
})
PlayerSettings.announcesBottomScale = v5({
	Name = "Local Notification Scale",
	Aliases = { "Announces Bottom" },
	Description = "Adjusts the scale of all local announcements and notifications at the bottom of the screen",
	MinValue = 0,
	MaxValue = 2
})
group = "Quick Access"
PlayerSettings._ = nil
PlayerSettings.quickAccessEnabled = v3({
	Name = "Quick Access Enabled",
	Description = "Press R or D-Pad Left to quickly navigate different menus or items in the game."
})
PlayerSettings.qaSlot1 = v15({
	Name = "Quick Access: Slot 1"
})
PlayerSettings.qaSlot2 = v15({
	Name = "Quick Access: Slot 2"
})
PlayerSettings.qaSlot3 = v15({
	Name = "Quick Access: Slot 3"
})
PlayerSettings.qaSlot4 = v15({
	Name = "Quick Access: Slot 4"
})
PlayerSettings.qaSlot5 = v15({
	Name = "Quick Access: Slot 5"
})
PlayerSettings.qaSlot6 = v15({
	Name = "Quick Access: Slot 6"
})
PlayerSettings.qaSlot7 = v15({
	Name = "Quick Access: Slot 7"
})
PlayerSettings.qaSlot8 = v15({
	Name = "Quick Access: Slot 8"
})
group = "Codes"
PlayerSettings._ = nil
PlayerSettings.codes = v13({
	Name = "[ Codes @Woozynate ]"
})
PlayerSettings.groupReward = v13({
	Name = "LIKE AND JOIN THE GROUP TO CLAIM"
})

for k, v18 in PlayerSettings do
	v18.Id = k

	if not (v18.Type == "checkbox" or v18.Type == "dropdown") then
		continue
	end

	for k2, option in v18.Options do
		option.Id = k2
	end
end

return PlayerSettings