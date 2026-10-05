local LoggingConfig = {
	ENABLED = true,
	DEV_MODE = false,
	Levels = {
		ERROR = 1,
		WARN = 2,
		INFO = 3,
		DEBUG = 4,
		VERBOSE = 5
	}
}
LoggingConfig.CurrentLevel = LoggingConfig.Levels.INFO
LoggingConfig.Modules = {
	GMM = {
		enabled = true,
		level = LoggingConfig.Levels.WARN,
		categories = {
			toonSelection = false,
			trinketCatalog = false,
			teamFrame = false,
			readySystem = false,
			shopUpdates = false,
			initialization = true,
			errors = true
		}
	},
	Floor0ShopClient = {
		enabled = true,
		level = LoggingConfig.Levels.WARN,
		categories = {
			itemSetup = false,
			ichorDisplay = false,
			purchases = false,
			initialization = true,
			errors = true
		}
	},
	Round = {
		enabled = true,
		level = LoggingConfig.Levels.INFO,
		categories = {
			generatorSetup = false,
			minigameDetails = false,
			treadmillChecks = false,
			monsterSpawning = true,
			floorProgression = true,
			errors = true
		}
	},
	GeneratorFillScript = {
		enabled = true,
		level = LoggingConfig.Levels.WARN,
		categories = {
			teleportPositions = false,
			skillChecks = false,
			playerMovement = true,
			errors = true
		}
	},
	AdminCommands = {
		enabled = true,
		level = LoggingConfig.Levels.INFO,
		categories = {
			commandExecution = true,
			levelNames = false,
			errors = true
		}
	},
	Floor0ShopHandler = {
		enabled = true,
		level = LoggingConfig.Levels.INFO,
		categories = {
			readyStates = false,
			purchases = true,
			cleanup = true,
			errors = true
		}
	}
}

function LoggingConfig.ShouldLog(p, p2, p3)
	if not LoggingConfig.ENABLED then
		return false
	end

	local module = LoggingConfig.Modules[p]

	if not (module and module.enabled) or (p3 or LoggingConfig.Levels.INFO) > module.level then
		return false
	end

	return not (p2 and module.categories) or module.categories[p2] == true
end

function LoggingConfig.CreateLogger(p)
	return {
		error = function(p2, value)
			if LoggingConfig.ShouldLog(p, value or "errors", LoggingConfig.Levels.ERROR) then
				warn("[" .. p .. " ERROR] " .. p2)
			end
		end,
		warn = function(p2, p3)
			if LoggingConfig.ShouldLog(p, p3, LoggingConfig.Levels.WARN) then
				warn("[" .. p .. "] " .. p2)
			end
		end,
		info = function(p2, p3)
			if LoggingConfig.ShouldLog(p, p3, LoggingConfig.Levels.INFO) then
				print("[" .. p .. "] " .. p2)
			end
		end,
		debug = function(p2, p3)
			if LoggingConfig.ShouldLog(p, p3, LoggingConfig.Levels.DEBUG) then
				print("[" .. p .. " DEBUG] " .. p2)
			end
		end,
		verbose = function(p2, p3)
			if LoggingConfig.ShouldLog(p, p3, LoggingConfig.Levels.VERBOSE) then
				print("[" .. p .. " VERBOSE] " .. p2)
			end
		end
	}
end

function LoggingConfig.EnableDevMode()
	LoggingConfig.DEV_MODE = true
	LoggingConfig.CurrentLevel = LoggingConfig.Levels.DEBUG
	print("[LoggingConfig] Development mode enabled - verbose logging active")
end

function LoggingConfig.DisableDevMode()
	LoggingConfig.DEV_MODE = false
	LoggingConfig.CurrentLevel = LoggingConfig.Levels.INFO
	print("[LoggingConfig] Development mode disabled - normal logging active")
end

function LoggingConfig.SetModuleEnabled(p, enabled)
	if LoggingConfig.Modules[p] then
		LoggingConfig.Modules[p].enabled = enabled
		print("[LoggingConfig] Module", p, "logging", enabled and "enabled" or "disabled")
	end
end

function LoggingConfig.SetCategoryEnabled(p, p2, p3)
	if LoggingConfig.Modules[p] and LoggingConfig.Modules[p].categories then
		LoggingConfig.Modules[p].categories[p2] = p3
		print("[LoggingConfig] Module", p, "category", p2, p3 and "enabled" or "disabled")
	end
end

return LoggingConfig