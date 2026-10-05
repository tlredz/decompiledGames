local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AAEventWinAward = require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
local Axe = require(script.Axe)
local Config = require(script.Config)
local DefaultYearMap = require(script.Parent.DefaultYearMap)
local GoldenTrees = require(script.GoldenTrees)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local TreePhysics = require(script.TreePhysics)
local YearCollectibles = require(script.Parent.YearCollectibles)
require(script.Parent.Parent.Types)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local remotes = YearCollectibles.createRemotes("year2015")

local function checkGameplayReady(p, map)
	local yearAssets = p.yearAssets
	local _2015

	if yearAssets then
		_2015 = yearAssets:FindFirstChild("2015")
	end

	local tool

	if _2015 then
		tool = _2015:FindFirstChild(Config.axeAssetName)
	end

	local model

	if _2015 then
		model = _2015:FindFirstChild(Config.treeAssetName)
	end

	local zones = YearCollectibles.findZones(map, Config.treeSpawnZoneName)
	local v

	if tool == nil then
		v = false
	else
		v = tool:IsA("Tool")
	end

	local v2

	if model == nil then
		v2 = false
	else
		v2 = model:IsA("Model") and model.PrimaryPart ~= nil
	end

	if v and v2 and #zones > 0 then
		return true, {
			axe = tool,
			tree = model,
			zones = zones
		}, nil
	end

	return false, nil, "20th Anniversary year 2015 is missing its Axe, GoldenTree or TreeSpawnZone"
end

local function buildGameplayHandle(data, data2)
	local v = GoldenTrees.start({
		template = data2.tree,
		zones = data2.zones,
		mapParent = data.map,
		awardChop = AAEventWinAward.create(Config.chopAward),
		awardFell = AAEventWinAward.create(Config.fellAward),
		logger = logger
	})
	local v2 = Axe.start({
		template = data2.axe,
		onSwing = v.chop,
		logger = logger
	})
	local cleanup = data.cleanup
	return {
		map = data.map,
		spawn = data.spawn,
		stopTools = v2.stop,
		cleanup = function()
			v2.stop()
			v.stop()
			cleanup()
		end
	}
end

local function startTrees(p, p2)
	local v, v2, v3 = checkGameplayReady(p, p2.map)

	if v then
		return (buildGameplayHandle(p2, v2))
	end

	logger:warn(v3)
	return p2
end

local function startOrbs(p)
	local zones = YearCollectibles.findZones(p.map, Config.orbSpawnZoneName)

	if #zones > 0 then
		return YearCollectibles.startServer(p, {
			remotes = remotes,
			zones = zones,
			config = Config.winOrbs,
			award = Config.winOrbAward,
			logger = logger
		})
	end

	logger:warn("20th Anniversary year 2015 has no OrbSpawnZone")
	return p
end

local function startGameplay(p, p2)
	local v2, v3, v4 = checkGameplayReady(p, p2.map)

	if v2 then
		p2 = buildGameplayHandle(p2, v3)
	else
		logger:warn(v4)
	end

	return startOrbs(p2)
end

local Year2015 = {}

function Year2015.load(p, _: number)
	local loaded, v = DefaultYearMap.load(p, 2015)

	if not loaded then
		return nil, v
	end

	local v3, v4, v5 = checkGameplayReady(p, loaded.map)

	if v3 then
		loaded = buildGameplayHandle(loaded, v4)
	else
		logger:warn(v5)
	end

	return startOrbs(loaded), nil
end

function Year2015.loadClient(p, p2: number)
	local v = TreePhysics.start(p, p2)
	local v2 = YearCollectibles.startClient({
		remotes = remotes,
		config = Config.winOrbs,
		logger = logger
	})
	return function()
		v2()
		v()
	end
end

return Year2015