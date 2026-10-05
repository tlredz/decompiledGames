local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(script.Config)
local DefaultYearMap = require(script.Parent.DefaultYearMap)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local YearCollectibles = require(script.Parent.YearCollectibles)
require(script.Parent.Parent.Types)

local function checkGameplayReady(p, p2: number)
	local zones = YearCollectibles.findZones(p, Config.orbSpawnZoneName)

	if #zones > 0 then
		return true, zones, nil
	end

	return false, nil, string.format("20th Anniversary year %d is missing its OrbSpawnZone", p2)
end

return {
	create = function(p: number)
		local logger = LoggerManager.createLogger(`Year{p}`, {
			feature = `{script:GetFullName()}.{p}`
		})
		local remotes = YearCollectibles.createRemotes((`year{p}`))
		local award = {
			source = string.format(Config.awardSourceTemplate, p),
			multiplier = 0.5
		}
		local winOrbsForYear = Config.winOrbsForYear(p)

		local function startGameplay(loaded)
			local map = loaded.map
			local v2 = p
			local zones = YearCollectibles.findZones(map, Config.orbSpawnZoneName)
			local flag, v3

			if #zones > 0 then
				flag = true
			else
				v3 = string.format("20th Anniversary year %d is missing its OrbSpawnZone", v2)
				flag = false
				zones = nil
			end

			if flag then
				return YearCollectibles.startServer(loaded, {
					remotes = remotes,
					zones = zones,
					config = winOrbsForYear,
					award = award,
					logger = logger
				})
			end

			logger:warn(v3)
			return loaded
		end

		return {
			load = function(p2, _: number)
				local loaded, v2 = DefaultYearMap.load(p2, p)

				if loaded then
					return startGameplay(loaded), nil
				end

				return nil, v2
			end,
			loadClient = function(_, _: number)
				return YearCollectibles.startClient({
					remotes = remotes,
					config = winOrbsForYear,
					logger = logger
				})
			end
		}
	end
}