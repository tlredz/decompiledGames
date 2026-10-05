local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
require(ReplicatedStorage.Modules.PermissionsLibrary)
local InputLibrary = require(ReplicatedStorage.Modules.InputLibrary)
local SettingsInfo = require(ReplicatedStorage.Modules.SettingsInfo)
local EnumLibrary = require(ReplicatedStorage.Modules.EnumLibrary)
local v = {
	"Shoot",
	"Aim",
	"Reload",
	"Inspect",
	"QuickMelee",
	"QuickUtility",
	"Divider",
	"WalkForward",
	"WalkBackward",
	"WalkLeftward",
	"WalkRightward",
	"Jump",
	"Sprint",
	"Crouch",
	"Slide",
	"Divider",
	"EquipPrimary",
	"EquipSecondary",
	"EquipMelee",
	"EquipUtility",
	"EquipNext",
	"EquipLast",
	"Divider",
	"UseEmote",
	"Divider",
	"SwitchCameraPOV",
	"Ping",
	"OpenPlayerList",
	"SwitchItems",
	"LeaveDuel",
	"SpectateExit",
	"SpectateNext",
	"SpectateLast",
	"HideHUD"
}
local SettingsLibrary = {
	HOTKEYS_GUIDE = v,
	DEPENDENCIES = {
		["Camera Sensitivity X"] = { "Camera Sensitivity", "any" },
		["Camera Sensitivity Y"] = { "Camera Sensitivity", "any" },
		["Camera Sensitivity ADS"] = { "Camera Sensitivity", "any" },
		["Camera Sensitivity Scoped"] = { "Camera Sensitivity", "any" },
		["Camera Inverted X"] = { "Camera Sensitivity", "any" },
		["Camera Inverted Y"] = { "Camera Sensitivity", "any" },
		["Camera FOV Effects"] = { "Camera FOV", "any" },
		["Camera Zoom Effects"] = { "Camera FOV", "any" },
		["Camera Zoom Effects Scoped"] = { "Camera FOV", "any" },
		["Auto Shoot Reaction Time"] = { "Auto Shoot", "Custom" },
		["Aim Assist Strength"] = { "Aim Assist", "Custom" },
		["Music Volume"] = { "Master Volume", "any" },
		["Other Volume"] = { "Master Volume", "any" },
		["Finisher Volume"] = { "Master Volume", "any" },
		["Emote Volume"] = { "Master Volume", "any" },
		["Mute Finishers From Others"] = { "Finisher Volume", "any" },
		["Mute Emotes From Others"] = { "Emote Volume", "any" },
		["Keep Quick Attack Window"] = { "Keep Quick Attack Enabled", true },
		["Double Tap Shoot Window"] = { "Double Tap Shoot", true },
		["Damage Numbers Color"] = { "Damage Numbers", true },
		["Damage Numbers Critical Color"] = { "Damage Numbers", true },
		["Hotbar Display"] = { "Gameplay HUD Preset", "Custom" },
		["Equipped Weapon Display"] = { "Gameplay HUD Preset", "Custom" },
		["Keybinds Interface"] = { "Gameplay HUD Preset", "Custom" },
		["Health Bar Display"] = { "Gameplay HUD Preset", "Custom" },
		["Spectators Display"] = { "Gameplay HUD Preset", "Custom" },
		["Equipped Weapon Icon"] = {
			"Equipped Weapon Display",
			"Disabled",
			nil,
			true
		},
		["Equipped Weapon Ammo"] = {
			"Equipped Weapon Display",
			"Disabled",
			nil,
			true
		},
		["Hotbar Slot Ammo"] = {
			"Hotbar Display",
			"Disabled",
			nil,
			true
		},
		["Damage Flashing Color Base"] = {
			"Damage Flashing",
			"Disabled",
			nil,
			true
		},
		["Damage Flashing Color Flash"] = {
			"Damage Flashing",
			"Disabled",
			nil,
			true
		}
	},
	STAFF_SETTINGS = {
		"Staff Team Visuals",
		"Staff Team Tools Disabled",
		"Staff Team Server Logs",
		"Staff Team Hidden Spectator",
		"Staff Team Tools Disabled Leads"
	},
	NUM_PROFILES = 3,
	Info = {},
	Order = {},
	OrderBySections = {}
}

function SettingsLibrary.DoesExist(_, p)
	return SettingsLibrary.Info[p] or p == "Audio Visualizers" or p == "Player Hitboxes" or p == "ViewModel Shaking"
end

function SettingsLibrary.GenerateCrosshairAppearance(_, object, data, p)
	local v2 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function get(p2)
		if data and data[p2] ~= nil then
			return data[p2]
		end

		return (object:GetSetting(p2))
	end

	-- equivalent call inferred; original call site unknown
	if get("Crosshair Disabled") then
		v2.IsDisabled = true
	else
		local v3 = get("Crosshair Bars Enabled") -- equivalent call inferred; original call site unknown
		local v4 = not v3
		local v5 = get("Crosshair Dot Enabled") -- equivalent call inferred; original call site unknown
		local v6 = not v5
		local v7 = get("Crosshair Circle Enabled") -- equivalent call inferred; original call site unknown
		local v8 = not v7
		local v9 = get("Crosshair Outline Enabled") -- equivalent call inferred; original call site unknown
		local v10 = not v9
		local _ = get("Crosshair Scoped Red Dot") -- equivalent call inferred; original call site unknown
		v2.IsDisabled = nil
		local v11 = get("Crosshair Static") -- equivalent call inferred; original call site unknown
		v2.IsStatic = v11 or nil
		local rotation = get("Crosshair Rotation") -- equivalent call inferred; original call site unknown
		v2.Rotation = rotation
		local scale = get("Crosshair Scale") -- equivalent call inferred; original call site unknown
		v2.Scale = scale
		local v14 = get("Crosshair Show While Aiming") -- equivalent call inferred; original call site unknown
		v2.ShowWhileAiming = v14 or nil
		local v15 = get("Crosshair Show While Inspecting") -- equivalent call inferred; original call site unknown
		v2.ShowWhileInspecting = v15 or nil
		local v16 = get("Crosshair Override Shotgun") -- equivalent call inferred; original call site unknown
		v2.Override = v16 or nil
		v2.BarsDisabled = v4 or nil
		local barsTopDisabled

		if not v4 then
			local v18 = get("Crosshair Bars Top Enabled") -- equivalent call inferred; original call site unknown
			barsTopDisabled = not v18 or nil
		end

		v2.BarsTopDisabled = barsTopDisabled
		local barsBottomDisabled

		if not v4 then
			local v19 = get("Crosshair Bars Bottom Enabled") -- equivalent call inferred; original call site unknown
			barsBottomDisabled = not v19 or nil
		end

		v2.BarsBottomDisabled = barsBottomDisabled
		local barsRightDisabled

		if not v4 then
			local v20 = get("Crosshair Bars Right Enabled") -- equivalent call inferred; original call site unknown
			barsRightDisabled = not v20 or nil
		end

		v2.BarsRightDisabled = barsRightDisabled
		local barsLeftDisabled

		if not v4 then
			local v21 = get("Crosshair Bars Left Enabled") -- equivalent call inferred; original call site unknown
			barsLeftDisabled = not v21 or nil
		end

		v2.BarsLeftDisabled = barsLeftDisabled
		local crosshairBarsSpacing

		if not v4 then
			if data and data["Crosshair Bars Spacing"] ~= nil then
				crosshairBarsSpacing = data["Crosshair Bars Spacing"]
			else
				crosshairBarsSpacing = object:GetSetting("Crosshair Bars Spacing")
			end
		end

		v2.BarsSpacing = crosshairBarsSpacing
		local crosshairBarsLength

		if not v4 then
			if data and data["Crosshair Bars Length"] ~= nil then
				crosshairBarsLength = data["Crosshair Bars Length"]
			else
				crosshairBarsLength = object:GetSetting("Crosshair Bars Length")
			end
		end

		v2.BarsLength = crosshairBarsLength
		local crosshairBarsThickness

		if not v4 then
			if data and data["Crosshair Bars Thickness"] ~= nil then
				crosshairBarsThickness = data["Crosshair Bars Thickness"]
			else
				crosshairBarsThickness = object:GetSetting("Crosshair Bars Thickness")
			end
		end

		v2.BarsThickness = crosshairBarsThickness
		local crosshairBarsTransparency

		if not v4 then
			if data and data["Crosshair Bars Transparency"] ~= nil then
				crosshairBarsTransparency = data["Crosshair Bars Transparency"]
			else
				crosshairBarsTransparency = object:GetSetting("Crosshair Bars Transparency")
			end
		end

		v2.BarsTransparency = crosshairBarsTransparency
		local crosshairBarsColor

		if not v4 then
			if data and data["Crosshair Bars Color"] ~= nil then
				crosshairBarsColor = data["Crosshair Bars Color"]
			else
				crosshairBarsColor = object:GetSetting("Crosshair Bars Color")
			end
		end

		v2.BarsColor = crosshairBarsColor
		local crosshairBarsShape

		if not v4 then
			if data and data["Crosshair Bars Shape"] ~= nil then
				crosshairBarsShape = data["Crosshair Bars Shape"]
			else
				crosshairBarsShape = object:GetSetting("Crosshair Bars Shape")
			end
		end

		v2.BarsShape = crosshairBarsShape
		v2.DotDisabled = v6 or nil
		local crosshairDotThickness

		if not v6 then
			if data and data["Crosshair Dot Thickness"] ~= nil then
				crosshairDotThickness = data["Crosshair Dot Thickness"]
			else
				crosshairDotThickness = object:GetSetting("Crosshair Dot Thickness")
			end
		end

		v2.DotThickness = crosshairDotThickness
		local crosshairDotTransparency

		if not v6 then
			if data and data["Crosshair Dot Transparency"] ~= nil then
				crosshairDotTransparency = data["Crosshair Dot Transparency"]
			else
				crosshairDotTransparency = object:GetSetting("Crosshair Dot Transparency")
			end
		end

		v2.DotTransparency = crosshairDotTransparency
		local crosshairDotColor

		if not v6 then
			if data and data["Crosshair Dot Color"] ~= nil then
				crosshairDotColor = data["Crosshair Dot Color"]
			else
				crosshairDotColor = object:GetSetting("Crosshair Dot Color")
			end
		end

		v2.DotColor = crosshairDotColor
		local crosshairDotShape

		if not v6 then
			if data and data["Crosshair Dot Shape"] ~= nil then
				crosshairDotShape = data["Crosshair Dot Shape"]
			else
				crosshairDotShape = object:GetSetting("Crosshair Dot Shape")
			end
		end

		v2.DotShape = crosshairDotShape
		v2.CircleDisabled = v8 or nil
		local crosshairCircleColor

		if not v8 then
			if data and data["Crosshair Circle Color"] ~= nil then
				crosshairCircleColor = data["Crosshair Circle Color"]
			else
				crosshairCircleColor = object:GetSetting("Crosshair Circle Color")
			end
		end

		v2.CircleColor = crosshairCircleColor
		local crosshairCircleSize

		if not v8 then
			if data and data["Crosshair Circle Size"] ~= nil then
				crosshairCircleSize = data["Crosshair Circle Size"]
			else
				crosshairCircleSize = object:GetSetting("Crosshair Circle Size")
			end
		end

		v2.CircleSize = crosshairCircleSize
		local crosshairCircleThickness

		if not v8 then
			if data and data["Crosshair Circle Thickness"] ~= nil then
				crosshairCircleThickness = data["Crosshair Circle Thickness"]
			else
				crosshairCircleThickness = object:GetSetting("Crosshair Circle Thickness")
			end
		end

		v2.CircleThickness = crosshairCircleThickness
		local crosshairCircleTransparency

		if not v8 then
			if data and data["Crosshair Circle Transparency"] ~= nil then
				crosshairCircleTransparency = data["Crosshair Circle Transparency"]
			else
				crosshairCircleTransparency = object:GetSetting("Crosshair Circle Transparency")
			end
		end

		v2.CircleTransparency = crosshairCircleTransparency
		local crosshairCircleShape

		if not v8 then
			if data and data["Crosshair Circle Shape"] ~= nil then
				crosshairCircleShape = data["Crosshair Circle Shape"]
			else
				crosshairCircleShape = object:GetSetting("Crosshair Circle Shape")
			end
		end

		v2.CircleShape = crosshairCircleShape
		v2.OutlineDisabled = v10 or nil
		local crosshairOutlineThickness

		if not v10 then
			if data and data["Crosshair Outline Thickness"] ~= nil then
				crosshairOutlineThickness = data["Crosshair Outline Thickness"]
			else
				crosshairOutlineThickness = object:GetSetting("Crosshair Outline Thickness")
			end
		end

		v2.OutlineThickness = crosshairOutlineThickness
		local crosshairOutlineTransparency

		if not v10 then
			if data and data["Crosshair Outline Transparency"] ~= nil then
				crosshairOutlineTransparency = data["Crosshair Outline Transparency"]
			else
				crosshairOutlineTransparency = object:GetSetting("Crosshair Outline Transparency")
			end
		end

		v2.OutlineTransparency = crosshairOutlineTransparency
		local crosshairOutlineColor

		if not v10 then
			if data and data["Crosshair Outline Color"] ~= nil then
				crosshairOutlineColor = data["Crosshair Outline Color"]
			else
				crosshairOutlineColor = object:GetSetting("Crosshair Outline Color")
			end
		end

		v2.OutlineColor = crosshairOutlineColor
		local crosshairOutlineType

		if not v10 then
			if data and data["Crosshair Outline Type"] ~= nil then
				crosshairOutlineType = data["Crosshair Outline Type"]
			else
				crosshairOutlineType = object:GetSetting("Crosshair Outline Type")
			end
		end

		v2.OutlineType = crosshairOutlineType
	end

	-- equivalent call inferred; original call site unknown
	if get("Crosshair Hitmarker Enabled") then
		v2.HitmarkerDisabled = nil
		local hitmarkerScale = get("Crosshair Hitmarker Scale") -- equivalent call inferred; original call site unknown
		v2.HitmarkerScale = hitmarkerScale
		local hitmarkerRotation = get("Crosshair Hitmarker Rotation") -- equivalent call inferred; original call site unknown
		v2.HitmarkerRotation = hitmarkerRotation
		local hitmarkerTransparency = get("Crosshair Hitmarker Transparency") -- equivalent call inferred; original call site unknown
		v2.HitmarkerTransparency = hitmarkerTransparency
		local hitmarkerColor = get("Crosshair Hitmarker Color") -- equivalent call inferred; original call site unknown
		v2.HitmarkerColor = hitmarkerColor
		local hitmarkerTransparencyCrit = get("Crosshair Hitmarker Transparency Crit") -- equivalent call inferred; original call site unknown
		v2.HitmarkerTransparencyCrit = hitmarkerTransparencyCrit
		local hitmarkerColorCrit = get("Crosshair Hitmarker Color Crit") -- equivalent call inferred; original call site unknown
		v2.HitmarkerColorCrit = hitmarkerColorCrit
	else
		v2.HitmarkerDisabled = true
	end

	local v3 = get("Crosshair Scoped Bars") -- equivalent call inferred; original call site unknown
	local v5 = get("Crosshair Scoped Red Dot") -- equivalent call inferred; original call site unknown
	v2.ScopedDisabled = nil
	v2.ScopedBarsDisabled = not v3 or nil
	v2.ScopedRedDotDisabled = not v5 or nil
	local scopedRedDotColor = get("Crosshair Scoped Red Dot Color") -- equivalent call inferred; original call site unknown
	v2.ScopedRedDotColor = scopedRedDotColor

	if not p then
		return v2
	end

	local v7 = {}

	for k, v8 in pairs(v2) do
		v7[EnumLibrary:ToEnum(k)] = v8
	end

	return v7
end

function SettingsLibrary.DecodeCrosshairAppearance(_, items)
	local result = {}

	for k, item in pairs(items) do
		result[EnumLibrary:FromEnum(k)] = item
	end

	return result
end

local function add_setting(...)
	local v2 = SettingsInfo.new(...)
	local info = SettingsLibrary.Info
	local name = v2.Name
	local v3

	if v2.Type ~= "Divider" then
		v3 = v2
	end

	info[name] = v3
	table.insert(SettingsLibrary.Order, v2)
	SettingsLibrary.OrderBySections[v2.Section] = SettingsLibrary.OrderBySections[v2.Section] or {}
	table.insert(SettingsLibrary.OrderBySections[v2.Section], v2)
end

local function add_hotkey_setting(p, _)
	local input = InputLibrary.Inputs[p]

	for k, v2 in pairs(InputLibrary.HOTKEY_FORMATS) do
		for k2, formatString in pairs(v2) do
			local v3 = input.InputEnums[k] and input.InputEnums[k][k2]
			add_setting(
				"Hotkeys",
				string.format(formatString, p),
				input.DisplayName,
				"",
				"",
				"Hotkey",
				v3 and v3.Name or "nil"
			)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function add_divider(p, displayName, image)
	add_setting(p, p .. " - " .. displayName, displayName, image or "", "", "Divider")
end

add_setting("Video", "Video - Performance", "Performance", "", "", "Divider")
add_setting(
	"Video",
	"Shadows Disabled",
	"Optimized Lighting",
	"rbxassetid://17521723349",
	"Disables shadows which may increase performance but causes the game to look brighter. If you turn this off, you will need to restart your game",
	"Toggle",
	false
)
add_setting(
	"Video",
	"Textures Disabled",
	"Optimized Textures",
	"rbxassetid://17521723467",
	"Deletes most textures & materials which may increase performance but causes the game to lack detail. If you turn this off, you will need to restart your game",
	"Toggle",
	false
)
add_setting(
	"Video",
	"Wraps Disabled",
	"Optimized Wraps",
	"rbxassetid://17593458822",
	"Hides weapon wraps which may increase performance. You'll still be able to see your own wraps",
	"Toggle",
	false
)
add_setting("Video", "Video - Camera", "Camera", "", "", "Divider")
add_setting(
	"Video",
	"Camera Sensitivity",
	"Sensitivity",
	"rbxassetid://17548980857",
	"Change how fast your camera rotates",
	"Slider",
	1,
	0.05,
	4,
	20,
	true
)
add_setting(
	"Video",
	"Camera Sensitivity ADS",
	"While Aiming",
	"rbxassetid://17516823433",
	"Multiplies your camera sensitivity while aiming with non-scoped weapons",
	"Slider",
	0.5,
	0.05,
	2,
	20,
	true
)
add_setting(
	"Video",
	"Camera Sensitivity Scoped",
	"While Scoped",
	"rbxassetid://87834608236137",
	"Multiplies your camera sensitivity while aiming with scoped weapons specifically",
	"Slider",
	0.5,
	0.05,
	2,
	20,
	true
)
add_setting(
	"Video",
	"Camera Sensitivity X",
	"Horizontal",
	"rbxassetid://85286504432350",
	"[Advanced] Specifically change your left & right sensitivity",
	"Slider",
	1,
	0.05,
	4,
	20,
	true
)
add_setting(
	"Video",
	"Camera Sensitivity Y",
	"Vertical",
	"rbxassetid://72795034348521",
	"[Advanced] Specifically change your up & down sensitivity",
	"Slider",
	1,
	0.05,
	4,
	20,
	true
)
add_setting(
	"Video",
	"Camera Inverted X",
	"Inverted X",
	"rbxassetid://85286504432350",
	"[Advanced] Inverts your camera's left & right movements",
	"Toggle",
	false
)
add_setting(
	"Video",
	"Camera Inverted Y",
	"Inverted Y",
	"rbxassetid://72795034348521",
	"[Advanced] Inverts your camera's up & down movements",
	"Toggle",
	false
)
add_setting(
	"Video",
	"Camera FOV",
	"Field Of View",
	"rbxassetid://130564359100743",
	"Changes how much of the world your camera is able to see",
	"Slider",
	80,
	30,
	120,
	1
)
add_setting(
	"Video",
	"Camera FOV Effects",
	"Gameplay Effects",
	"rbxassetid://17513821002",
	"Enables gameplay-related field of view effects from things such as sprinting",
	"Toggle",
	true
)
add_setting(
	"Video",
	"Camera Zoom Effects",
	"Non-Scoped Weapons",
	"rbxassetid://17516823433",
	"Changes the strength of field of view effects from things like aiming & charging for non-scoped weapons",
	"Slider",
	1,
	0,
	1,
	20,
	true
)
add_setting(
	"Video",
	"Camera Zoom Effects Scoped",
	"Scoped Weapons",
	"rbxassetid://87834608236137",
	"Changes the strength of field of view effects for aiming with scoped weapons specifically",
	"Slider",
	1,
	0,
	1,
	20,
	true
)
add_setting(
	"Video",
	"Camera Shake",
	"Camera Shake",
	"rbxassetid://18404346057",
	"Enables effects such as recoil, explosions, etc",
	"Toggle",
	true
)
add_setting("Video", "Video - Interface", "Interface", "", "", "Divider")
add_setting(
	"Video",
	"Hide HUD",
	"Hide HUD",
	"rbxassetid://126633805196326",
	"Turns off most user interface elements, possibly allowing you to get cleaner footage. This setting can also be bound to a hotkey for Controller and Mouse & Keyboard",
	"Toggle",
	false
)
add_setting(
	"Video",
	"Hide Tasks In Duels",
	"Hide Side Tasks",
	"rbxassetid://17632205556",
	"Hides your tasks interface on the left side of your screen once the duel's round begins",
	"Toggle",
	false
)
add_setting(
	"Video",
	"Padded HUD",
	"Padded HUD",
	"rbxassetid://118715309480493",
	"Shrinks the HUD to add more space around the edges of your screen. Great for playing on a TV or large monitor",
	"Dropdown",
	"Using Controller",
	{ "Always On", "Using Controller", "Disabled" }
)
add_setting(
	"Video",
	"PlayerList Leaderstat",
	"Lobby Data",
	"rbxassetid://17898066959",
	"Change what kind of data the player list & player nametags display. This setting can also be changed by clicking on the icon in the top right of the player list",
	"Dropdown",
	"Win Streak",
	{ "Win Streak", "Level", "Current ELO" }
)
add_setting("Video", "Video - Graphics", "Graphics", "", "", "Divider")
add_setting(
	"Video",
	"ViewModel Highlight",
	"Weapon Inking",
	"rbxassetid://17611932430",
	"Adds a subtle outline around your weapons. This effect may cause weird artifacts for transparent weapons and/or wraps that have a glass look to them",
	"Toggle",
	true
)
add_setting(
	"Video",
	"Aiming Hides Muzzle Flashes",
	"Hide Muzzle Flashes",
	"rbxassetid://125628882498996",
	"Hides muzzle flash effects while aiming with a weapon. Helps reduce visual obstructions with certain weapon skins",
	"Toggle",
	false
)
add_setting(
	"Video",
	"Equipment Background",
	"Weapons Background",
	"rbxassetid://17898066959",
	"Changes the 3D background of the Weapons page. Great for making thumbnails of certain weapons, skins, wraps, etc",
	"Dropdown",
	"Default",
	{
		"Default",
		"Green Screen",
		"Blue Screen",
		"Pink Screen"
	}
)
add_setting("Video", "Video - Accessibility", "Accessibility", "", "", "Divider")
add_setting(
	"Video",
	"Damage Flashing",
	"Damage Flashing",
	"rbxassetid://107944065079684",
	"Plays a bright flashing effect every time something takes damage. Turn this off if you are sensitive to flashing lights",
	"Dropdown",
	"Enabled",
	{ "Enabled", "Outline", "Disabled" }
)
add_setting(
	"Video",
	"Damage Flashing Color Base",
	"Base Color",
	"rbxassetid://107944065079684",
	"Change the base color of the damage flashing effect",
	"Color",
	"#ff3232"
)
add_setting(
	"Video",
	"Damage Flashing Color Flash",
	"Flash Color",
	"rbxassetid://107944065079684",
	"Change the flash color of the damage flashing effect",
	"Color",
	"#ffffff"
)
add_setting(
	"Video",
	"Accessible Flashes",
	"Dark Blinds",
	"rbxassetid://17814211801",
	"Makes flashbang blinds dark instead of bright. Turn this on if you are sensitive to flashing lights",
	"Toggle",
	false
)
add_setting(
	"Audio",
	"Master Volume",
	"Master Volume",
	"rbxassetid://17506383011",
	"Changes the volume of everything",
	"Slider",
	0.5,
	0,
	2,
	20,
	true
)
add_setting(
	"Audio",
	"Music Volume",
	"Music Volume",
	"rbxassetid://136271678394092",
	"Changes the volume of just the music. Music made by @BSlickMusic",
	"Slider",
	1,
	0,
	2,
	20,
	true
)
add_setting(
	"Audio",
	"Finisher Volume",
	"Finisher Volume",
	"rbxassetid://77965589200390",
	"Changes the volume of just finishers, which are effects that play on elimination",
	"Slider",
	1,
	0,
	2,
	20,
	true
)
add_setting(
	"Audio",
	"Mute Finishers From Others",
	"Mute Other Finishers",
	"rbxassetid://138903494625319",
	"Mutes finishers that are from other players unless you're currently spectating them",
	"Toggle",
	false
)
add_setting(
	"Audio",
	"Emote Volume",
	"Emote Volume",
	"rbxassetid://130882808226687",
	"Changes the volume of just emotes",
	"Slider",
	1,
	0,
	2,
	20,
	true
)
add_setting(
	"Audio",
	"Mute Emotes From Others",
	"Mute Other Emotes",
	"rbxassetid://138903494625319",
	"Mutes emotes that are from other players unless you're currently spectating them",
	"Toggle",
	false
)
add_setting(
	"Audio",
	"Other Volume",
	"SFX Volume",
	"rbxassetid://125628882498996",
	"Changes the volume of basically everything else",
	"Slider",
	1,
	0,
	2,
	20,
	true
)
add_setting("Game", "Game - Gameplay", "Gameplay", "", "", "Divider")
add_setting(
	"Game",
	"Damage Numbers",
	"Damage Numbers",
	"rbxassetid://18404346057",
	"Displays the damage you deal to others",
	"Toggle",
	true
)
add_setting(
	"Game",
	"Damage Numbers Color",
	"Color",
	"rbxassetid://18404346057",
	"Change the color of normal damage",
	"Color",
	"#ffffff"
)
add_setting(
	"Game",
	"Damage Numbers Critical Color",
	"Critical Color",
	"rbxassetid://18404346057",
	"Change the color of critical damage",
	"Color",
	"#ff3232"
)
add_setting(
	"Game",
	"Pings",
	"Signals",
	"rbxassetid://17269776216",
	"Allows you to see signal callouts from teammates. You can signal your teammates using a Controller or Mouse & Keyboard by pressing a specific hotkey. This hotkey can be changed at any time",
	"Toggle",
	true
)
add_setting(
	"Game",
	"Hide Teammate Icons",
	"Hide Teammate Display",
	"rbxassetid://17704137194",
	"Hides teammate icons & health bars in duels",
	"Toggle",
	false
)
add_setting(
	"Game",
	"ViewModel Aiming",
	"Aiming Animation",
	"rbxassetid://17516823433",
	"[Advanced] Turn this off to disable your aiming animations for all non-scoped weapons. This should help remove any negative impact on gameplay from using larger skins",
	"Toggle",
	true
)
add_setting(
	"Game",
	"Projectile Smoothing",
	"Smooth Projectiles",
	"rbxassetid://111780605198345",
	"[Advanced] Smoothens the motion of projectiles to provide a more visually appealing experience. Turn this off for a snappier & more visually accurate experience with projectile weapons",
	"Toggle",
	true
)
add_setting("Game", "Game - Interface", "Interface", "", "", "Divider")
add_setting(
	"Game",
	"Pick Weapons List",
	"Weapon Picker",
	"rbxassetid://17539215512",
	"Changes the look of the weapon picker interface in duels & the shooting range",
	"Dropdown",
	"Grid",
	{ "Grid", "List" }
)
add_setting(
	"Game",
	"Gameplay HUD Preset",
	"Gameplay HUD",
	"rbxassetid://17898066959",
	"An easy way of trying out a new gameplay HUD format! Choose between the default look, a left handed mode, the classic RIVALS layout, or a centered version that works great for vertical content creation",
	"Dropdown",
	"Default",
	{
		"Default",
		"Left Handed",
		"Legacy",
		"Centered",
		"Custom",
		"Disabled"
	}
)
add_setting(
	"Game",
	"Hotbar Display",
	"Hotbar Display",
	"rbxassetid://13188242287",
	"[Advanced] Choose whether you want all of your weapons to be displayed on the bottom right, where they usually go, or in the bottom left, where the health bar usually sits. Not available for touch controls",
	"Dropdown",
	"Bottom Right",
	{
		"Bottom Left",
		"Bottom Right",
		"Bottom Center",
		"Disabled"
	}
)
add_setting(
	"Game",
	"Hotbar Slot Ammo",
	"Show Weapon Ammo",
	"rbxassetid://16539130428",
	"Displays your weapon's ammo on the hotbar to see from a quick glance. Does not affect touch buttons",
	"Toggle",
	true
)
add_setting(
	"Game",
	"Equipped Weapon Display",
	"Equipped Display",
	"rbxassetid://116467133898357",
	"[Advanced] Choose whether you want your equipped weapon's ammo & information to be displayed on the bottom left, where the health bar usually sits, or in the bottom right, where the hotbar usually sits",
	"Dropdown",
	"Bottom Right",
	{
		"Bottom Left",
		"Bottom Right",
		"Legacy",
		"Disabled"
	}
)
add_setting(
	"Game",
	"Equipped Weapon Icon",
	"Show Weapon Icon",
	"rbxassetid://17611932430",
	"[Advanced] Choose whether or not your Equipped Display shows the icon of your weapon. This should probably be turned off if you put your Equipped Display next to your Hotbar",
	"Toggle",
	false
)
add_setting(
	"Game",
	"Equipped Weapon Ammo",
	"Show Weapon Ammo",
	"rbxassetid://16539130428",
	"[Advanced] Choose whether or not your Equipped Display shows the ammo of your weapon",
	"Toggle",
	false
)
add_setting(
	"Game",
	"Keybinds Interface",
	"Keybinds Display",
	"rbxassetid://133555125764102",
	"[Advanced] Choose whether you want situational keybinds to appear on the bottom left, where the health bar usually sits, or in the bottom right, where the hotbar usually sits",
	"Dropdown",
	"Bottom Right",
	{ "Bottom Left", "Bottom Right", "Disabled" }
)
add_setting(
	"Game",
	"Health Bar Display",
	"Health Display",
	"rbxassetid://102193196101741",
	"[Advanced] Choose whether you want your health bar to appear on the bottom left, where it usually goes, or in the bottom right, where the hotbar usually sits",
	"Dropdown",
	"Bottom Left",
	{
		"Bottom Left",
		"Bottom Right",
		"Bottom Center",
		"Disabled"
	}
)
add_setting(
	"Game",
	"Spectators Display",
	"Spectators Display",
	"rbxassetid://77908042044589",
	"[Advanced] Choose whether you want the spectators visual to appear on the bottom left, where it usually goes, or in the bottom right, where the hotbar usually sits",
	"Dropdown",
	"Bottom Left",
	{
		"Bottom Left",
		"Bottom Right",
		"Bottom Center",
		"Disabled"
	}
)
add_setting("Game", "Game - Controls", "Controls", "", "", "Divider")
add_setting(
	"Game",
	"Toggle Aim",
	"Toggle Aim",
	"rbxassetid://17513805525",
	"Doesn't affect Touch Controls",
	"Toggle",
	false
)
add_setting(
	"Game",
	"Toggle Crouch",
	"Toggle Crouch",
	"rbxassetid://17513805623",
	"Doesn't affect Touch Controls",
	"Toggle",
	false
)
add_setting(
	"Game",
	"Toggle Sprint",
	"Toggle Sprint",
	"rbxassetid://17513821002",
	"Doesn't affect Touch Controls",
	"Toggle",
	false
)
add_setting(
	"Game",
	"Auto Sprint",
	"Auto Sprint",
	"rbxassetid://17513821002",
	"Automatically sprint while moving instead of having to use the sprint button. Doesn't affect Touch Controls",
	"Toggle",
	true
)
add_setting(
	"Game",
	"Easy Slide",
	"Easy Slide",
	"rbxassetid://17524267716",
	"While turned on, you can easily slide by sprinting & then crouching. If you turn this off, you should bind a hotkey to your dedicated Slide button. Doesn't affect Touch Controls",
	"Toggle",
	true
)
add_setting(
	"Game",
	"Easy Quick Attack",
	"Easy Quick Attack",
	"rbxassetid://16828140099",
	"Quick melee & quick utility will automatically use abilities if necessary, such as automatically dashing with the Scythe",
	"Toggle",
	true
)
add_setting(
	"Game",
	"Keep Quick Attack Enabled",
	"Quick Attack Keeping",
	"rbxassetid://17225650859",
	"[Advanced] Allows you to keep your weapon after quick attacking by holding down the Quick Attack button",
	"Toggle",
	true
)
add_setting(
	"Game",
	"Keep Quick Attack Window",
	"Keep Window",
	"rbxassetid://17225650859",
	"[Advanced] How long, in seconds, you need to hold the Quick Attack button for you to keep your weapon out. If you set this to 0 seconds, you will always keep your weapon after quick attacking",
	"Slider",
	0.25,
	0,
	1,
	20
)
add_setting(
	"Game",
	"Scroll Equip",
	"Scroll Equip",
	"rbxassetid://88012714630436",
	"Allows you to scroll up & down with your mouse wheel to switch weapons. Only available for Mouse & Keyboard",
	"Toggle",
	true
)
add_setting("Game", "Game - Handicaps", "Handicaps", "", "", "Divider")
add_setting(
	"Game",
	"Aim Assist",
	"Aim Assist",
	"rbxassetid://139269442808394",
	"While aiming with a weapon, your camera will be pulled in the direction of nearby enemies. Only available for Touch Controls & Controller",
	"Dropdown",
	"Custom",
	{ "Custom", "Disabled" }
)
add_setting(
	"Game",
	"Aim Assist Strength",
	"Pull Strength",
	"rbxassetid://139269442808394",
	"Change how strong your aim assist pulls your camera",
	"Slider",
	0.5,
	0,
	1,
	20,
	true
)
add_setting(
	"Game",
	"Auto Shoot",
	"Auto Shoot",
	"rbxassetid://122696559841523",
	"Weapons will automatically attack enemies if your crosshair lines up with their body. In competitive modes, such as Ranked, this setting is forced to be Dynamic. Dynamic mode makes it so that your Auto Shoot's reaction time changes based on the weapon you use to ensure fair gameplay. Only available for Touch Controls & Controller",
	"Dropdown",
	"Custom",
	{ "Custom", "Dynamic", "Disabled" }
)
add_setting(
	"Game",
	"Auto Shoot Reaction Time",
	"Reaction Time",
	"rbxassetid://122696559841523",
	"The delay, in milliseconds, that your auto shoot will trigger after your crosshair lines up with an enemy",
	"Slider",
	25,
	25,
	125,
	1
)
add_setting(
	"Game",
	"Third Person Access",
	"Third Person Camera",
	"rbxassetid://138606382770333",
	"Allows you to change your camera's point of view from first person to third person. Only available for Touch Controls",
	"Dropdown",
	"Touch Controls",
	{ "Touch Controls" }
)
add_setting("Game", "Game - Accessibility", "Accessibility", "", "", "Divider")
add_setting(
	"Game",
	"Gamepad Deadzone",
	"Joystick Deadzone",
	"rbxassetid://110291144710849",
	"[Advanced] Helps fix joystick drifting while playing with a Controller. Gradually increase this number until you no longer experience stick drift",
	"Slider",
	0.25,
	0,
	0.95,
	20,
	true
)
add_setting(
	"Game",
	"Control Scheme",
	"Control Scheme",
	"rbxassetid://81276179444570",
	"[Advanced] Use this setting to force the game to respect your desired control scheme",
	"Dropdown",
	"Automatic",
	{
		"Automatic",
		"Mouse & Keyboard",
		"Touch Buttons",
		"Controller"
	}
)
add_setting("Crosshair", "Crosshair - Crosshair", "Crosshair", "", "", "Divider")
add_setting(
	"Crosshair",
	"Crosshair Disabled",
	"Disabled",
	"rbxassetid://139575687490912",
	"Makes the crosshair invisible",
	"Toggle",
	false
)
add_setting(
	"Crosshair",
	"Crosshair Scale",
	"Scale",
	"rbxassetid://115388073389430",
	"Make your crosshair big or small",
	"Slider",
	1,
	0,
	4,
	20,
	true
)
add_setting(
	"Crosshair",
	"Crosshair Rotation",
	"Rotation",
	"rbxassetid://103847676236765",
	"0 or 45 recommended",
	"Slider",
	0,
	0,
	360,
	1
)
add_setting(
	"Crosshair",
	"Crosshair Static",
	"Static",
	"rbxassetid://17516823433",
	"Turns off all crosshair effects",
	"Toggle",
	false
)
add_setting(
	"Crosshair",
	"Crosshair Show While Aiming",
	"Show While Aiming",
	"rbxassetid://122558543480189",
	"Keeps your crosshair visible while aiming",
	"Toggle",
	false
)
add_setting(
	"Crosshair",
	"Crosshair Show While Inspecting",
	"Show While Inspecting",
	"rbxassetid://17513805400",
	"Keeps your crosshair visible while inspecting",
	"Toggle",
	false
)
add_setting(
	"Crosshair",
	"Crosshair Override Shotgun",
	"Override Specials",
	"rbxassetid://119489313346738",
	"Allows you to use your custom crosshair for Shotgun, Shorty, etc",
	"Toggle",
	false
)
add_setting("Crosshair", "Crosshair Bars Enabled", "Bars Enabled", "rbxassetid://17516823503", "", "Toggle", true)
add_setting("Crosshair", "Crosshair Bars Color", "Color", "rbxassetid://17516823503", "", "Color", "#ffffff")
add_setting("Crosshair", "Crosshair Bars Spacing", "Spacing", "rbxassetid://17516823503", "", "Slider", 16, 0, 64, 1)
add_setting("Crosshair", "Crosshair Bars Length", "Length", "rbxassetid://17516823503", "", "Slider", 6, 0, 32, 1)
add_setting("Crosshair", "Crosshair Bars Thickness", "Thickness", "rbxassetid://17516823503", "", "Slider", 2, 0, 32, 1)
add_setting(
	"Crosshair",
	"Crosshair Bars Transparency",
	"Transparency",
	"rbxassetid://17516823503",
	"",
	"Slider",
	0,
	0,
	1,
	20,
	true
)
add_setting(
	"Crosshair",
	"Crosshair Bars Shape",
	"Shape",
	"rbxassetid://17516823503",
	"",
	"Dropdown",
	"Sharp",
	{ "Sharp", "Round" }
)
add_setting("Crosshair", "Crosshair Bars Top Enabled", "Top Enabled", "rbxassetid://17564352694", "", "Toggle", true)
add_setting(
	"Crosshair",
	"Crosshair Bars Bottom Enabled",
	"Bottom Enabled",
	"rbxassetid://17564352775",
	"",
	"Toggle",
	true
)
add_setting(
	"Crosshair",
	"Crosshair Bars Right Enabled",
	"Right Enabled",
	"rbxassetid://17564352879",
	"",
	"Toggle",
	true
)
add_setting("Crosshair", "Crosshair Bars Left Enabled", "Left Enabled", "rbxassetid://17564353047", "", "Toggle", true)
add_setting("Crosshair", "Crosshair Dot Enabled", "Dot Enabled", "rbxassetid://17516823599", "", "Toggle", true)
add_setting("Crosshair", "Crosshair Dot Color", "Color", "rbxassetid://17516823599", "", "Color", "#ffffff")
add_setting("Crosshair", "Crosshair Dot Thickness", "Thickness", "rbxassetid://17516823599", "", "Slider", 2, 0, 16, 1)
add_setting(
	"Crosshair",
	"Crosshair Dot Transparency",
	"Transparency",
	"rbxassetid://17516823599",
	"",
	"Slider",
	0,
	0,
	1,
	20,
	true
)
add_setting(
	"Crosshair",
	"Crosshair Dot Shape",
	"Shape",
	"rbxassetid://17516823599",
	"",
	"Dropdown",
	"Sharp",
	{ "Sharp", "Round" }
)
add_setting(
	"Crosshair",
	"Crosshair Circle Enabled",
	"Circle Enabled",
	"rbxassetid://96264839713061",
	"",
	"Toggle",
	false
)
add_setting("Crosshair", "Crosshair Circle Color", "Color", "rbxassetid://96264839713061", "", "Color", "#ffffff")
add_setting("Crosshair", "Crosshair Circle Size", "Size", "rbxassetid://96264839713061", "", "Slider", 16, 0, 64, 1)
add_setting(
	"Crosshair",
	"Crosshair Circle Thickness",
	"Thickness",
	"rbxassetid://96264839713061",
	"",
	"Slider",
	2,
	0,
	16,
	1
)
add_setting(
	"Crosshair",
	"Crosshair Circle Transparency",
	"Transparency",
	"rbxassetid://96264839713061",
	"",
	"Slider",
	0,
	0,
	1,
	20,
	true
)
add_setting(
	"Crosshair",
	"Crosshair Circle Shape",
	"Shape",
	"rbxassetid://96264839713061",
	"",
	"Dropdown",
	"Circle",
	{ "Circle", "Round", "Sharp" }
)
add_setting(
	"Crosshair",
	"Crosshair Outline Enabled",
	"Outline Enabled",
	"rbxassetid://17516823683",
	"",
	"Toggle",
	false
)
add_setting("Crosshair", "Crosshair Outline Color", "Color", "rbxassetid://17516823683", "", "Color", "#000000")
add_setting(
	"Crosshair",
	"Crosshair Outline Thickness",
	"Thickness",
	"rbxassetid://17516823683",
	"",
	"Slider",
	1,
	0,
	16,
	1
)
add_setting(
	"Crosshair",
	"Crosshair Outline Transparency",
	"Transparency",
	"rbxassetid://17516823683",
	"",
	"Slider",
	0,
	0,
	1,
	20,
	true
)
add_setting(
	"Crosshair",
	"Crosshair Outline Type",
	"Type",
	"rbxassetid://17516823683",
	"",
	"Dropdown",
	"Miter",
	{ "Miter", "Round", "Bevel" }
)
add_setting("Crosshair", "Crosshair - Hitmarker", "Hitmarker", "", "", "Divider")
add_setting("Crosshair", "Crosshair Hitmarker Enabled", "Enabled", "rbxassetid://93990674888427", "", "Toggle", true)
add_setting(
	"Crosshair",
	"Crosshair Hitmarker Scale",
	"Scale",
	"rbxassetid://115388073389430",
	"Make your hitmarker big or small",
	"Slider",
	1,
	0,
	4,
	20,
	true
)
add_setting(
	"Crosshair",
	"Crosshair Hitmarker Rotation",
	"Rotation",
	"rbxassetid://103847676236765",
	"0 or 45 recommended",
	"Slider",
	0,
	0,
	360,
	1
)
add_setting(
	"Crosshair",
	"Crosshair Hitmarker Transparency",
	"Transparency",
	"rbxassetid://91180498372634",
	"",
	"Slider",
	0,
	0,
	1,
	20,
	true
)
add_setting("Crosshair", "Crosshair Hitmarker Color", "Color", "rbxassetid://93990674888427", "", "Color", "#ffffff")
add_setting(
	"Crosshair",
	"Crosshair Hitmarker Transparency Crit",
	"Critical Transparency",
	"rbxassetid://91180498372634",
	"",
	"Slider",
	0,
	0,
	1,
	20,
	true
)
add_setting(
	"Crosshair",
	"Crosshair Hitmarker Color Crit",
	"Critical Color",
	"rbxassetid://93990674888427",
	"",
	"Color",
	"#ff3232"
)
add_setting("Crosshair", "Crosshair - Scoped", "Scoped", "", "", "Divider")
add_setting(
	"Crosshair",
	"Crosshair Scoped Bars",
	"Bars Enabled",
	"rbxassetid://87834608236137",
	"Turn this off to hide the bars while aiming with a scoped weapon",
	"Toggle",
	true
)
add_setting(
	"Crosshair",
	"Crosshair Scoped Red Dot",
	"Dot Enabled",
	"rbxassetid://87834608236137",
	"Turn this off to hide the red dot while aiming with a scoped weapon",
	"Toggle",
	true
)
add_setting(
	"Crosshair",
	"Crosshair Scoped Red Dot Color",
	"Color",
	"rbxassetid://93990674888427",
	"Change the color of the red dot that scoped weapons display",
	"Color",
	"#ff3232"
)
add_setting(
	"Account",
	"Bounty Rewards Disabled",
	"Disable Bounty Rewards",
	"rbxassetid://133391928250838",
	"Prevents players from farming your charm, wrap, etc. We recommend keeping this setting off as much as possible",
	"Toggle",
	false
)
add_setting(
	"Account",
	"Staff Team Visuals",
	"Hide Team Visuals",
	"rbxassetid://95626460059631",
	"Hides your NG logo from showing up next to your name in the player list",
	"Toggle",
	false
)
add_setting(
	"Account",
	"Staff Team Tools Disabled",
	"Hide Team Tools",
	"rbxassetid://95626460059631",
	"Hides certain team tools that may be available to you from showing up in the topbar UI so that you can screenshare & record your gameplay without leaking anything",
	"Toggle",
	false
)
add_setting(
	"Account",
	"Staff Team Tools Disabled Leads",
	"Hide Team Lead Tools",
	"rbxassetid://95626460059631",
	"Hides team tools that only team leads can see. If you're not a team lead, this setting won't do anything",
	"Toggle",
	false
)
add_setting(
	"Account",
	"Staff Team Server Logs",
	"Hide Error Logs",
	"rbxassetid://95626460059631",
	"Prevents server error logs from showing up in the chat window",
	"Toggle",
	false
)
add_setting(
	"Account",
	"Staff Team Hidden Spectator",
	"Secret Spectator",
	"rbxassetid://95626460059631",
	"Hides you from the total spectators counter while spectating a duel that you're not a part of",
	"Toggle",
	false
)
add_setting("Account", "Account - Notifications", "Notifications", "", "", "Divider")
add_setting(
	"Account",
	"Notifications Delivery",
	"Delivery Mode",
	"rbxassetid://96509180790493",
	"Change the way you receive notifications. Change this to \"Lobby\" if you prefer notifications to wait until you finish a duel. Change this to \"Muted\" if you want notifications to go straight into your Inbox",
	"Dropdown",
	"Instant",
	{ "Instant", "Lobby", "Muted" }
)
add_setting("Account", "Account - Privacy", "Privacy", "", "", "Divider")
add_setting(
	"Account",
	"Challenge Requests",
	"Challenge Requests",
	"rbxassetid://18525954682",
	"Allows players to send you 1v1 requests",
	"Dropdown",
	"Everyone",
	{ "Everyone", "Friends", "Nobody" }
)
add_setting(
	"Account",
	"Party Invites",
	"Party Invites",
	"rbxassetid://118031781381166",
	"Allows players to send you invites to their party",
	"Dropdown",
	"Everyone",
	{ "Everyone", "Friends", "Nobody" }
)
add_setting(
	"Account",
	"Receive Gifts",
	"Receive Gifts",
	"rbxassetid://127400882945494",
	"Allows you to receive gifts from other players",
	"Toggle",
	true
)
add_setting(
	"Touch",
	"Left Handed Touch Controls",
	"Left Handed Mode",
	"rbxassetid://98211826458757",
	"[Advanced] Mirrors the \"Joystick\" & the \"Double Tap To Attack\" hitboxes to better suit left handed players. Does not affect touch buttons",
	"Toggle",
	false
)
add_setting(
	"Touch",
	"Opaque Buttons While Scoped",
	"Opaque Buttons",
	"rbxassetid://87834608236137",
	"Turning this on makes all of your touch buttons opaque while scoped to help with visibility",
	"Toggle",
	true
)
add_setting(
	"Touch",
	"Mobile Buttons Transparency",
	"Buttons Transparency",
	"rbxassetid://129678163029799",
	"Changes the transparency of all of your touch buttons",
	"Slider",
	0.5,
	0,
	1,
	20,
	true
)
add_setting(
	"Touch",
	"Camera Mobile Button Sinking",
	"Buttons Camera Sinking",
	"rbxassetid://96518177763762",
	"[Advanced] While turned on, you can use a touch button and pan your camera at the same time",
	"Toggle",
	true
)
add_setting(
	"Touch",
	"Touch Button Ammo",
	"Show Weapon Ammo",
	"rbxassetid://16539130428",
	"Displays your weapon's ammo on the respective touch buttons to see from a quick glance",
	"Toggle",
	true
)

local function setup_hotkeys()
	for i = CONSTANTS.MAX_EQUIPPABLE_EMOTES, 1, -1 do
		table.insert(
			SettingsLibrary.HOTKEYS_GUIDE,
			table.find(SettingsLibrary.HOTKEYS_GUIDE, "UseEmote") + 1,
			"UseEmote" .. i
		)
	end

	for _, v2 in pairs(SettingsLibrary.HOTKEYS_GUIDE) do
		if v2 ~= "Divider" then
			add_hotkey_setting(v2)
		end
	end
end

setup_hotkeys()

local function setup_touch()
	local v2 = {}

	for k in pairs(InputLibrary.MobileButtons) do
		table.insert(v2, k)
	end

	table.sort(v2, function(a, b)
		return (table.find(v, InputLibrary.MobileButtons[a].InputName) or 1e999) < (table.find(
			v,
			InputLibrary.MobileButtons[b].InputName
		) or 1e999)
	end)

	for _, v3 in pairs(v2) do
		local mobileButton = InputLibrary.MobileButtons[v3]
		local displayName = InputLibrary.Inputs[mobileButton.InputName].DisplayName
		local v4 = "MobileButton " .. v3
		add_divider("Touch", displayName, mobileButton.Image) -- equivalent call inferred; original call site unknown

		if v3 == "mobile_crouch" then
			add_setting(
				"Touch",
				"Easy Slide Mobile",
				"Easy Slide",
				"rbxassetid://17674207175",
				"[Advanced] While turned on, your Crouch button turns into a Slide button while sprinting. If you turn this off, you should enable the dedicated Slide button in your settings. Only available for Touch Controls",
				"Toggle",
				true
			)
		elseif v3 == "mobile_jump" then
			add_setting(
				"Touch",
				"Auto Jump",
				"Auto Jump",
				"rbxassetid://18436038478",
				"Automatically jump near ledges & walls. Only available for Touch Controls",
				"Toggle",
				true
			)
		elseif v3 == "mobile_shoot" then
			add_setting(
				"Touch",
				"Double Tap Shoot",
				"Double Tap To Attack",
				"rbxassetid://101488932151631",
				"While turned on, you can double tap the right half of your screen to attack",
				"Toggle",
				true
			)
			add_setting(
				"Touch",
				"Double Tap Shoot Window",
				"Double Tap Window",
				"rbxassetid://101488932151631",
				"[Advanced] How much time, in seconds, you have to tap again to start shooting",
				"Slider",
				0.25,
				0,
				1,
				20
			)
		end

		add_setting(
			"Touch",
			v4 .. " Enabled",
			"Enabled",
			"rbxassetid://77908042044589",
			"Allows you to turn this specific button on/off" .. (v3 == "mobile_slide" and ". Enabling this dedicated Slide button will override your Crouch button's Easy Slide setting" or ""),
			"Toggle",
			mobileButton.DefaultVisibility
		)
		add_setting(
			"Touch",
			v4 .. " Override",
			"Custom",
			"rbxassetid://14641612286",
			"[Advanced] Turn this on to enable custom settings for this button specifically. This will override any global setting from above",
			"Toggle",
			false
		)
		add_setting(
			"Touch",
			v4 .. " Transparency",
			"Transparency",
			"rbxassetid://129678163029799",
			"[Advanced] Change the transparency of this button specifically",
			"Slider",
			0.5,
			0,
			1,
			20,
			true
		)
		add_setting(
			"Touch",
			v4 .. " Camera Sinking",
			"Camera Sinking",
			"rbxassetid://96518177763762",
			"[Advanced] While turned on, you can use pan your camera while using this button specifically at the same time",
			"Toggle",
			true
		)
	end
end

setup_touch()

local function setup_dependencies()
	for k, _ in pairs(InputLibrary.MobileButtons) do
		local v2 = "MobileButton " .. k
		local _ = v2 .. " Enabled"
		local v3 = v2 .. " Override"

		for _, v4 in pairs({ "Transparency", "Camera Sinking" }) do
			local v5 = v2 .. " " .. v4
			SettingsLibrary.DEPENDENCIES[v5] = { v3, true }
		end
	end

	for _, v2 in pairs({
		"Bars",
		"Dot",
		"Circle",
		"Outline",
		"Hitmarker"
	}) do
		local v3 = "Crosshair " .. v2
		local v4 = v3 .. " Enabled"
		local v5 = #v2 + 10

		for _, v6 in pairs(SettingsLibrary.Order) do
			if v6.Name ~= v4 and string.sub(v6.Name, 1, v5) == v3 then
				SettingsLibrary.DEPENDENCIES[v6.Name] = { v4, true }
			end
		end
	end

	SettingsLibrary.DEPENDENCIES["Crosshair Scoped Red Dot Color"] = { "Crosshair Scoped Red Dot", true }

	for _, v2 in pairs(SettingsLibrary.Order) do
		if SettingsLibrary.DEPENDENCIES[v2.Name] or v2.Name == "Crosshair Disabled" or v2.Name == "Crosshair - Crosshair" or v2.Name == "Crosshair - Hitmarker" then
			continue
		end

		if not (v2.Name ~= "Crosshair - Scoped" and string.sub(v2.Name, 1, 20) ~= "Crosshair Hitmarker " and string.sub(
			v2.Name,
			1,
			17
		) ~= "Crosshair Scoped ") then
			continue
		end

		if string.sub(v2.Name, 1, 10) ~= "Crosshair " then
			continue
		end

		SettingsLibrary.DEPENDENCIES[v2.Name] = { "Crosshair Disabled", false }
	end
end

setup_dependencies()
return SettingsLibrary