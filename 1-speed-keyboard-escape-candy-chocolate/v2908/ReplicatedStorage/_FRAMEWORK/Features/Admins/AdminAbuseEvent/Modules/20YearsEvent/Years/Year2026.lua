local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local WinOrbYear = require(script.Parent.WinOrbYear)
require(script.Parent.Parent.Types)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = WinOrbYear.create(2026)

local function startKeycaps(p)
	local _2026Keycaps = p.yearMaps:FindFirstChild("2026Keycaps")

	if not _2026Keycaps then
		logger:warn("20th Anniversary year 2026 is missing its 2026Keycaps folder")
		return function() end
	end

	local KeycapMapLoader = require(ServerScriptService._FRAMEWORK.ServerLibraries.KeycapMapLoader)
	local loaded = KeycapMapLoader.load({
		id = "20Anniversary_2026_Keycaps",
		source = _2026Keycaps:Clone()
	})
	return function()
		if loaded then
			loaded.unload()
		end
	end
end

return {
	load = function(p, p2: number)
		local loaded, v2 = v.load(p, p2)

		if not loaded then
			return nil, v2
		end

		local v3 = startKeycaps(p)
		return {
			map = loaded.map,
			spawn = loaded.spawn,
			cleanup = function()
				v3()
				loaded.cleanup()
			end
		}, nil
	end,
	loadClient = v.loadClient
}