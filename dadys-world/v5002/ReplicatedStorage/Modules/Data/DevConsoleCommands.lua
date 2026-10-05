local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
game:GetService("CollectionService")
local DevConsoleCommands = {
	Categories = {
		{
			id = "game",
			name = "Game",
			icon = "🎮",
			color = Color3.fromRGB(80, 180, 120)
		},
		{
			id = "spawn",
			name = "Spawn",
			icon = "👾",
			color = Color3.fromRGB(200, 120, 120)
		},
		{
			id = "debug",
			name = "Debug",
			icon = "🔧",
			color = Color3.fromRGB(120, 180, 255)
		},
		{
			id = "minigame",
			name = "Minigame",
			icon = "🎯",
			color = Color3.fromRGB(255, 200, 100)
		},
		{
			id = "lighting",
			name = "Lighting",
			icon = "💡",
			color = Color3.fromRGB(255, 255, 150)
		},
		{
			id = "cards",
			name = "Cards",
			icon = "🃏",
			color = Color3.fromRGB(200, 150, 255)
		},
		{
			id = "utility",
			name = "Utility",
			icon = "⚙️",
			color = Color3.fromRGB(180, 180, 180)
		},
		{
			id = "ice",
			name = "Ice Skating",
			icon = "❄️",
			color = Color3.fromRGB(100, 200, 255)
		},
		{
			id = "haptics",
			name = "Haptics",
			icon = "📳",
			color = Color3.fromRGB(200, 130, 255)
		}
	}
}

local function getMonsterNames()
	local names = {}
	local monsterData = ReplicatedStorage:FindFirstChild("MonsterData")

	if monsterData then
		for _, child in pairs(monsterData:GetChildren()) do
			table.insert(names, child.Name)
		end
	end

	table.sort(names)
	return names
end

local function getItemNames()
	local names = {}
	local items = ReplicatedStorage:FindFirstChild("Items")

	if items then
		for _, child in pairs(items:GetChildren()) do
			table.insert(names, child.Name)
		end
	end

	table.sort(names)
	return names
end

local function getCardNames()
	local names = {}
	local cardModules = ReplicatedStorage:FindFirstChild("CardModules")

	if cardModules then
		for _, moduleScript in pairs(cardModules:GetChildren()) do
			if moduleScript:IsA("ModuleScript") then
				table.insert(names, moduleScript.Name)
			end
		end
	end

	table.sort(names)
	return names
end

local function getLevelNames()
	local result = {}
	local levelNames = ReplicatedStorage:FindFirstChild("LevelNames")

	if levelNames then
		for _, folder in pairs(levelNames:GetChildren()) do
			if not folder:IsA("Folder") then
				continue
			end

			for _, stringValue in pairs(folder:GetChildren()) do
				if stringValue:IsA("StringValue") then
					table.insert(result, stringValue.Value)
				end
			end
		end
	end

	table.sort(result)
	return result
end

local function getHapticEffectNames()
	return {
		"SubtlePulse",
		"CrispClick",
		"SubtleHover",
		"WarningRumble",
		"ImpactBurst",
		"HeavyExplosion",
		"RhythmicProgress",
		"SlowRumble"
	}
end

local function getIcePresets()
	return {
		"Simple",
		"Polished",
		"Crazy",
		"Enhanced",
		"VectorForce",
		"BodyVelocity",
		"Off"
	}
end

DevConsoleCommands.Commands = {
	{
		name = "floor",
		aliases = { "nextfloor", "level", "map" },
		category = "game",
		description = "Set next floor/level to load",
		usage = "floor <levelName>",
		serverCommand = "NextFloor",
		params = {
			{
				name = "level",
				type = "string",
				required = true,
				autocomplete = getLevelNames
			}
		}
	},
	{
		name = "machines",
		aliases = { "allmachines", "complete", "generators" },
		category = "game",
		description = "Complete all generators instantly",
		usage = "machines",
		serverCommand = "AllMachines",
		params = {}
	},
	{
		name = "destroy",
		aliases = { "killmonsters", "clearmonsters" },
		category = "game",
		description = "Destroy all monsters in current room",
		usage = "destroy",
		serverCommand = "DestroyMonsters",
		params = {}
	},
	{
		name = "godmode",
		aliases = { "invincible", "god", "infinitehealth" },
		category = "game",
		description = "Make player invincible (99999 HP)",
		usage = "godmode [playerName]",
		serverCommand = "InfiniteHealth",
		params = {
			{
				name = "player",
				type = "player",
				required = false,
				default = "self"
			}
		}
	},
	{
		name = "allgens",
		aliases = { "spawnallgens", "allgenerators" },
		category = "game",
		description = "Enable spawning all generators on floor",
		usage = "allgens",
		serverCommand = "AllGenerators",
		params = {}
	},
	{
		name = "blackout",
		aliases = { "dark", "lights" },
		category = "game",
		description = "Trigger blackout event",
		usage = "blackout",
		serverCommand = "Blackout",
		params = {}
	},
	{
		name = "speed",
		aliases = { "speedboost", "devspeed" },
		category = "game",
		description = "Toggle dev speed boost (1.5, 2 or 3; 0 = reset; repeat to toggle off)",
		usage = "speed [multiplier]",
		serverCommand = "DevSpeedBoost",
		params = {
			{
				name = "multiplier",
				type = "number",
				required = false,
				default = "2"
			}
		}
	},
	{
		name = "spawn",
		aliases = { "enemy", "monster", "mob" },
		category = "spawn",
		description = "Spawn a monster at your location",
		usage = "spawn <monsterName>",
		serverCommand = "Enemy",
		params = {
			{
				name = "monster",
				type = "string",
				required = true,
				autocomplete = getMonsterNames
			}
		}
	},
	{
		name = "item",
		aliases = { "give", "spawnitem" },
		category = "spawn",
		description = "Spawn an item at your location",
		usage = "item <itemName>",
		serverCommand = "Item",
		params = {
			{
				name = "item",
				type = "string",
				required = true,
				autocomplete = getItemNames
			}
		}
	},
	{
		name = "puddles",
		aliases = { "icepuddles", "ice", "ichor" },
		category = "spawn",
		description = "Spawn ice puddles on current floor",
		usage = "puddles",
		serverCommand = "IchorPuddles",
		params = {}
	},
	{
		name = "spawnpuddles",
		aliases = { "directpuddles" },
		category = "spawn",
		description = "Directly spawn ice puddles immediately",
		usage = "spawnpuddles",
		serverCommand = "SpawnPuddles",
		params = {}
	},
	{
		name = "clearpuddles",
		aliases = { "removepuddles", "nopuddles" },
		category = "spawn",
		description = "Remove all ice puddles",
		usage = "clearpuddles",
		serverCommand = "ClearPuddles",
		params = {}
	},
	{
		name = "forceichor",
		aliases = { "forceichorevent", "ichorevent" },
		category = "spawn",
		description = "Force ichor event on next floor",
		usage = "forceichor",
		serverCommand = "ForceIchorEvent",
		params = {}
	},
	{
		name = "icicles",
		aliases = { "iciclepuddles", "skating" },
		category = "spawn",
		description = "Spawn icicle skating zones",
		usage = "icicles",
		serverCommand = "IciclePuddles",
		params = {}
	},
	{
		name = "fulldebug",
		aliases = { "debugall", "alldebug" },
		category = "debug",
		description = "Enable Monster GUI + LOS debug",
		usage = "fulldebug",
		serverCommand = "FullDebug",
		params = {}
	},
	{
		name = "debugoff",
		aliases = { "nodebug", "cleardebug" },
		category = "debug",
		description = "Disable all debug modes",
		usage = "debugoff",
		serverCommand = "DebugOff",
		params = {}
	},
	{
		name = "losdebug",
		aliases = { "dylelos", "visiondebug" },
		category = "debug",
		description = "Enable LOS debug: visual rays + verbose console",
		usage = "losdebug",
		serverCommand = "LOSDebugVisual",
		params = {}
	},
	{
		name = "losoff",
		aliases = { "nolos" },
		category = "debug",
		description = "Disable LOS debug mode",
		usage = "losoff",
		serverCommand = "LOSDebugOff",
		params = {}
	},
	{
		name = "visiontagged",
		aliases = { "taggedonly" },
		category = "debug",
		description = "Vision mode: only tagged geometry blocks LOS",
		usage = "visiontagged",
		serverCommand = "VisionModeTagged",
		params = {}
	},
	{
		name = "visionall",
		aliases = { "allblocks" },
		category = "debug",
		description = "Vision mode: everything blocks LOS (default)",
		usage = "visionall",
		serverCommand = "VisionModeAll",
		params = {}
	},
	{
		name = "monsterdebug",
		aliases = { "twisteddebug", "mobdebug" },
		category = "debug",
		description = "Toggle monster debug GUI display",
		usage = "monsterdebug",
		serverCommand = "ToggleTwistedDebug",
		params = {}
	},
	{
		name = "showmonsters",
		aliases = { "highlightmonsters" },
		category = "debug",
		description = "Highlight all monsters (red)",
		usage = "showmonsters",
		clientOnly = true,
		params = {}
	},
	{
		name = "showgens",
		aliases = { "highlightgens", "showgenerators" },
		category = "debug",
		description = "Highlight all generators (blue)",
		usage = "showgens",
		clientOnly = true,
		params = {}
	},
	{
		name = "showzones",
		aliases = { "highlightzones", "triggerzones" },
		category = "debug",
		description = "Highlight all trigger zones (yellow)",
		usage = "showzones",
		clientOnly = true,
		params = {}
	},
	{
		name = "squirm_eyes",
		aliases = { "squirmeyes", "glowingeyes" },
		category = "debug",
		description = "Toggle Squirm glowing eyes (on/off)",
		usage = "squirm_eyes [enabled]",
		serverCommand = "SquirmGlowingEyes",
		params = {
			{
				name = "enabled",
				type = "boolean",
				required = false
			}
		}
	},
	{
		name = "squirm_brightness",
		aliases = { "eyebrightness" },
		category = "debug",
		description = "Set Squirm eye brightness",
		usage = "squirm_brightness <value>",
		serverCommand = "SquirmEyeBrightness",
		params = {
			{
				name = "brightness",
				type = "number",
				required = true
			}
		}
	},
	{
		name = "squirm_range",
		aliases = { "eyerange" },
		category = "debug",
		description = "Set Squirm eye light range",
		usage = "squirm_range <value>",
		serverCommand = "SquirmEyeRange",
		params = {
			{
				name = "range",
				type = "number",
				required = true
			}
		}
	},
	{
		name = "squirm_color",
		aliases = { "eyecolor" },
		category = "debug",
		description = "Set Squirm eye color (RGB 0-255)",
		usage = "squirm_color <r> <g> <b>",
		serverCommand = "SquirmEyeColor",
		params = {
			{
				name = "r",
				type = "number",
				required = true
			},
			{
				name = "g",
				type = "number",
				required = true
			},
			{
				name = "b",
				type = "number",
				required = true
			}
		}
	},
	{
		name = "squirm_distance_tween",
		aliases = { "eyedistance", "distancetween" },
		category = "debug",
		description = "Toggle distance-based eye brightness tweening",
		usage = "squirm_distance_tween [enabled]",
		serverCommand = "SquirmDistanceTween",
		params = {
			{
				name = "enabled",
				type = "boolean",
				required = false
			}
		}
	},
	{
		name = "squirm_tween_distances",
		aliases = { "tweendist" },
		category = "debug",
		description = "Set distance range for eye glow (min max)",
		usage = "squirm_tween_distances <min> <max>",
		serverCommand = "SquirmTweenDistances",
		params = {
			{
				name = "min",
				type = "number",
				required = true
			},
			{
				name = "max",
				type = "number",
				required = true
			}
		}
	},
	{
		name = "squirm_edit_mode",
		aliases = { "squirmedit", "ik_test" },
		category = "debug",
		description = "Toggle Squirm IK tuning mode (freezes in HOLDING, infinite grab, no escape)",
		usage = "squirm_edit_mode [enabled]",
		serverCommand = "SquirmEditMode",
		params = {
			{
				name = "enabled",
				type = "boolean",
				required = false
			}
		}
	},
	{
		name = "squirm_force_grab",
		aliases = { "forcegrab", "grab_test" },
		category = "debug",
		description = "Force Squirm to grab you immediately for IK testing",
		usage = "squirm_force_grab",
		serverCommand = "SquirmForceGrab",
		params = {}
	},
	{
		name = "circlegame",
		aliases = { "forcecircle" },
		category = "minigame",
		description = "Force Circle minigame for all generators",
		usage = "circlegame",
		serverCommand = "ForceCircleMinigame",
		params = {}
	},
	{
		name = "originalgame",
		aliases = { "forceoriginal", "classicgame" },
		category = "minigame",
		description = "Force Original minigame for all generators",
		usage = "originalgame",
		serverCommand = "OriginalMinigame",
		params = {}
	},
	{
		name = "randomgame",
		aliases = { "mixedgame" },
		category = "minigame",
		description = "Random minigame distribution",
		usage = "randomgame",
		serverCommand = "RandomMinigame",
		params = {}
	},
	{
		name = "treadmill",
		aliases = { "forcetreadmill", "movementtreadmill" },
		category = "minigame",
		description = "Force Movement Treadmill for all generators",
		usage = "treadmill",
		serverCommand = "MovementTreadmill",
		params = {}
	},
	{
		name = "mixedgames",
		aliases = { "testminigames" },
		category = "minigame",
		description = "Mixed minigame types for testing",
		usage = "mixedgames",
		serverCommand = "CircleMinigame",
		params = {}
	},
	{
		name = "devlight",
		aliases = { "devlighting", "maxlight" },
		category = "lighting",
		description = "Maximum visibility lighting",
		usage = "devlight",
		serverCommand = "DevLighting",
		params = {}
	},
	{
		name = "bright",
		aliases = { "lightbright" },
		category = "lighting",
		description = "Set bright lighting",
		usage = "bright",
		serverCommand = "ToggleLighting",
		serverParam = "Bright",
		params = {}
	},
	{
		name = "dark",
		aliases = { "lightdark" },
		category = "lighting",
		description = "Set dark lighting",
		usage = "dark",
		serverCommand = "ToggleLighting",
		serverParam = "Dark",
		params = {}
	},
	{
		name = "foggy",
		aliases = { "lightfoggy", "fog" },
		category = "lighting",
		description = "Set foggy lighting",
		usage = "foggy",
		serverCommand = "ToggleLighting",
		serverParam = "Foggy",
		params = {}
	},
	{
		name = "normallight",
		aliases = { "lightnormal", "resetlight" },
		category = "lighting",
		description = "Restore lighting captured before any dev-lighting change",
		usage = "normallight",
		serverCommand = "ToggleLighting",
		serverParam = "Normal",
		params = {}
	},
	{
		name = "restorelight",
		aliases = { "restorelighting" },
		category = "lighting",
		description = "Restore lighting captured before any dev-lighting change",
		usage = "restorelight",
		serverCommand = "RestoreLighting",
		params = {}
	},
	{
		name = "forcevote",
		aliases = { "cardvote", "vote" },
		category = "cards",
		description = "Force card voting phase",
		usage = "forcevote [cardName]",
		serverCommand = "ForceCardVote",
		params = {
			{
				name = "card",
				type = "string",
				required = false,
				autocomplete = getCardNames
			}
		}
	},
	{
		name = "applycard",
		aliases = { "usecard", "card" },
		category = "cards",
		description = "Apply a card effect immediately",
		usage = "applycard <cardName>",
		serverCommand = "ApplyCard",
		params = {
			{
				name = "card",
				type = "string",
				required = true,
				autocomplete = getCardNames
			}
		}
	},
	{
		name = "shop",
		aliases = { "dandyshop", "forceshop" },
		category = "cards",
		description = "Force Dandy's shop to appear",
		usage = "shop",
		serverCommand = "ForceDandyShop",
		params = {}
	},
	{
		name = "dyle",
		aliases = { "dylemap", "forcedyle" },
		category = "cards",
		description = "Force Dyle floor (25 machines, no Dandy)",
		usage = "dyle",
		serverCommand = "ForceDyleMap",
		params = {}
	},
	{
		name = "tokens",
		aliases = { "givetokens", "money" },
		category = "utility",
		description = "Give tokens to player",
		usage = "tokens [amount]",
		serverCommand = "Tokens",
		params = {
			{
				name = "amount",
				type = "number",
				required = false,
				default = 10
			}
		}
	},
	{
		name = "cooldown",
		aliases = { "resetcooldown", "cd" },
		category = "utility",
		description = "Reset ability cooldowns",
		usage = "cooldown",
		serverCommand = "ResetCooldown",
		params = {}
	},
	{
		name = "nametags",
		aliases = { "hidetags", "notags" },
		category = "utility",
		description = "Hide all name tags",
		usage = "nametags",
		serverCommand = "NameTag",
		params = {}
	},
	{
		name = "hidegui",
		aliases = { "nogui", "hideui" },
		category = "utility",
		description = "Hide all player GUIs",
		usage = "hidegui",
		serverCommand = "HideGui",
		params = {}
	},
	{
		name = "2xweekend",
		aliases = { "multiplier", "2x", "doublexp" },
		category = "utility",
		description = "Toggle 2x holiday currency multiplier",
		usage = "2xweekend [multiplier]",
		serverCommand = "Set2xWeekend",
		params = {
			{
				name = "multiplier",
				type = "number",
				required = false
			}
		}
	},
	{
		name = "quickdev",
		aliases = { "devsetup", "testsetup" },
		category = "utility",
		description = "Quick dev setup (clear monsters + infinite health + Barnaby gen + TP)",
		usage = "quickdev",
		serverCommand = "QuickDev",
		params = {}
	},
	{
		name = "respawn",
		aliases = { "revive", "undead", "comeback" },
		category = "utility",
		description = "Respawn after death (removes death screen)",
		usage = "respawn",
		serverCommand = "Respawn",
		params = {}
	},
	{
		name = "iceskate",
		aliases = { "skating", "iceeffects" },
		category = "ice",
		description = "Activate ice skating preset",
		usage = "iceskate <preset>",
		clientOnly = true,
		params = {
			{
				name = "preset",
				type = "string",
				required = true,
				autocomplete = getIcePresets
			}
		}
	},
	{
		name = "iceoff",
		aliases = { "stopskating", "noice" },
		category = "ice",
		description = "Deactivate ice skating effects",
		usage = "iceoff",
		clientOnly = true,
		params = {}
	},
	{
		name = "icepanel",
		aliases = { "icemixer", "iceui" },
		category = "ice",
		description = "Open Ice Skating mix-match panel",
		usage = "icepanel",
		clientOnly = true,
		params = {}
	},
	{
		name = "hapticplay",
		aliases = { "playhaptic", "testhaptic", "vibrate" },
		category = "haptics",
		description = "Play a haptic effect by name",
		usage = "hapticplay <effectName> [strength]",
		serverCommand = "HapticPlay",
		params = {
			{
				name = "effect",
				type = "string",
				required = true,
				autocomplete = getHapticEffectNames
			},
			{
				name = "strength",
				type = "number",
				required = false,
				default = 1
			}
		}
	},
	{
		name = "hapticintensity",
		aliases = { "hapticstrength", "hapticoverride" },
		category = "haptics",
		description = "Override haptic intensity (0-100)",
		usage = "hapticintensity <value>",
		serverCommand = "HapticIntensity",
		params = {
			{
				name = "intensity",
				type = "number",
				required = true
			}
		}
	},
	{
		name = "haptictoggle",
		aliases = { "hapticoff", "hapticon", "nohaptics" },
		category = "haptics",
		description = "Toggle haptics on/off globally",
		usage = "haptictoggle [enabled]",
		serverCommand = "HapticToggle",
		params = {
			{
				name = "enabled",
				type = "boolean",
				required = false
			}
		}
	},
	{
		name = "hapticstress",
		aliases = { "hapticspam", "hapticburst" },
		category = "haptics",
		description = "Stress test: rapid-fire multiple haptic effects",
		usage = "hapticstress [count]",
		serverCommand = "HapticStress",
		params = {
			{
				name = "count",
				type = "number",
				required = false,
				default = 5
			}
		}
	},
	{
		name = "hapticspatial",
		aliases = { "hapticpos", "hapticposition" },
		category = "haptics",
		description = "Play positional haptic at your location",
		usage = "hapticspatial [radius]",
		serverCommand = "HapticSpatial",
		params = {
			{
				name = "radius",
				type = "number",
				required = false,
				default = 130
			}
		}
	}
}
DevConsoleCommands.CommandsByName = {}
DevConsoleCommands.CommandsByAlias = {}

for _, command in ipairs(DevConsoleCommands.Commands) do
	DevConsoleCommands.CommandsByName[command.name:lower()] = command

	for _, v in ipairs(command.aliases or {}) do
		DevConsoleCommands.CommandsByAlias[v:lower()] = command
	end
end

function DevConsoleCommands.FindCommand(value)
	local lower = value:lower()
	return DevConsoleCommands.CommandsByName[lower] or DevConsoleCommands.CommandsByAlias[lower]
end

function DevConsoleCommands.GetCommandsByCategory(p)
	local commands = {}

	for _, command in ipairs(DevConsoleCommands.Commands) do
		if command.category == p then
			table.insert(commands, command)
		end
	end

	return commands
end

function DevConsoleCommands.GetAutocompleteSuggestions(value)
	local lower = value:lower()
	local result = {}

	for _, command in ipairs(DevConsoleCommands.Commands) do
		if command.name:lower():find(lower, 1, true) == 1 then
			table.insert(result, {
				text = command.name,
				description = command.description
			})
		end
	end

	for _, command in ipairs(DevConsoleCommands.Commands) do
		for _, text in ipairs(command.aliases or {}) do
			if not (text:lower():find(lower, 1, true) == 1 and text ~= command.name) then
				continue
			end

			table.insert(result, {
				text = text,
				description = command.description .. " (alias)"
			})
		end
	end

	return result
end

return DevConsoleCommands