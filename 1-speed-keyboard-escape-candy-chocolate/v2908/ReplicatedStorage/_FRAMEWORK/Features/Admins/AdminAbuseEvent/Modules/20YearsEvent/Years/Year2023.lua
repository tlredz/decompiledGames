local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AAEventWinAward = require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
local Balls = require(script.Balls)
local BallsClient = require(script.BallsClient)
local Config = require(script.Config)
local DefaultYearMap = require(script.Parent.DefaultYearMap)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Sword = require(script.Sword)
require(script.Types)
local YearCollectibles = require(script.Parent.YearCollectibles)
require(script.Parent.Parent.Types)
local remo = require(ReplicatedStorage.Packages.remo)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local year2023 = remo.createRemotes({
	year2023 = remo.namespace({
		ballLaunched = remo.remote(),
		ballEnded = remo.remote()
	})
}).year2023
local remotes = YearCollectibles.createRemotes("year2023Orbs")

local function checkGameplayReady(p)
	local yearAssets = p.yearAssets
	local _2023

	if yearAssets then
		_2023 = yearAssets:FindFirstChild("2023")
	end

	local tool

	if _2023 then
		tool = _2023:FindFirstChild(Config.swordAssetName)
	end

	if tool and tool:IsA("Tool") then
		return true, tool, nil
	end

	return false, nil, "20th Anniversary year 2023 is missing its LinkedSword tool"
end

local function buildGameplayHandle(data, tool)
	local v = Balls.start({
		remotes = year2023,
		awardWin = AAEventWinAward.create(Config.hitAward)
	})
	local v2 = Sword.start({
		template = tool,
		onSwing = v.launch,
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

local function startBalls(p, p2)
	local yearAssets = p.yearAssets
	local _2023

	if yearAssets then
		_2023 = yearAssets:FindFirstChild("2023")
	end

	local tool

	if _2023 then
		tool = _2023:FindFirstChild(Config.swordAssetName)
	end

	local flag, v

	if tool and tool:IsA("Tool") then
		flag = true
	else
		flag = false
		tool = nil
		v = "20th Anniversary year 2023 is missing its LinkedSword tool"
	end

	if flag then
		return (buildGameplayHandle(p2, tool))
	end

	logger:warn(v)
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

	logger:warn("20th Anniversary year 2023 has no OrbSpawnZone")
	return p
end

local function startGameplay(p, p2)
	local yearAssets = p.yearAssets
	local _2023

	if yearAssets then
		_2023 = yearAssets:FindFirstChild("2023")
	end

	local tool

	if _2023 then
		tool = _2023:FindFirstChild(Config.swordAssetName)
	end

	local flag, v2

	if tool and tool:IsA("Tool") then
		flag = true
	else
		flag = false
		tool = nil
		v2 = "20th Anniversary year 2023 is missing its LinkedSword tool"
	end

	if flag then
		p2 = buildGameplayHandle(p2, tool)
	else
		logger:warn(v2)
	end

	return startOrbs(p2)
end

local Year2023 = {}

function Year2023.load(p, _: number)
	local loaded, v = DefaultYearMap.load(p, 2023)

	if not loaded then
		return nil, v
	end

	local yearAssets = p.yearAssets
	local _2023

	if yearAssets then
		_2023 = yearAssets:FindFirstChild("2023")
	end

	local tool

	if _2023 then
		tool = _2023:FindFirstChild(Config.swordAssetName)
	end

	local flag, v3

	if tool and tool:IsA("Tool") then
		flag = true
	else
		flag = false
		tool = nil
		v3 = "20th Anniversary year 2023 is missing its LinkedSword tool"
	end

	if flag then
		loaded = buildGameplayHandle(loaded, tool)
	else
		logger:warn(v3)
	end

	return startOrbs(loaded), nil
end

function Year2023.loadClient(p, _: number)
	local v = BallsClient.start(p, year2023)
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

return Year2023