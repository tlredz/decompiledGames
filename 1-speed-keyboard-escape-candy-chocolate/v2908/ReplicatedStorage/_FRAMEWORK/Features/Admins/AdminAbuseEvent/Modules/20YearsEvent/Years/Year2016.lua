local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(script.Config)
local DefaultYearMap = require(script.Parent.DefaultYearMap)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local YearCollectibles = require(script.Parent.YearCollectibles)
require(script.Parent.Parent.Types)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local remotes = YearCollectibles.createRemotes("year2016")

local function checkGameplayReady(p, p2)
	local yearAssets = p.yearAssets
	local _2016

	if yearAssets then
		_2016 = yearAssets:FindFirstChild("2016")
	end

	local child

	if _2016 then
		child = _2016:FindFirstChild(Config.schoolBookAssetName)
	end

	local zones = YearCollectibles.findZones(p2, Config.bookSpawnZoneName)

	if child and #zones > 0 then
		return true, zones, nil
	end

	return false, nil, "20th Anniversary year 2016 is missing its SchoolBook or BookSpawnZone"
end

local function startGameplay(p, loaded)
	local map = loaded.map
	local yearAssets = p.yearAssets
	local _2016

	if yearAssets then
		_2016 = yearAssets:FindFirstChild("2016")
	end

	local child

	if _2016 then
		child = _2016:FindFirstChild(Config.schoolBookAssetName)
	end

	local zones = YearCollectibles.findZones(map, Config.bookSpawnZoneName)
	local flag, v

	if child and #zones > 0 then
		flag = true
	else
		flag = false
		zones = nil
		v = "20th Anniversary year 2016 is missing its SchoolBook or BookSpawnZone"
	end

	if flag then
		return YearCollectibles.startServer(loaded, {
			remotes = remotes,
			zones = zones,
			config = Config.schoolBooks,
			award = Config.schoolBookAward,
			logger = logger
		})
	end

	logger:warn(v)
	return loaded
end

local Year2016 = {}

function Year2016.load(p, _: number)
	local loaded, v = DefaultYearMap.load(p, 2016)

	if loaded then
		return startGameplay(p, loaded), nil
	end

	return nil, v
end

function Year2016.loadClient(_, _: number)
	return YearCollectibles.startClient({
		remotes = remotes,
		config = Config.schoolBooks,
		logger = logger
	})
end

return Year2016