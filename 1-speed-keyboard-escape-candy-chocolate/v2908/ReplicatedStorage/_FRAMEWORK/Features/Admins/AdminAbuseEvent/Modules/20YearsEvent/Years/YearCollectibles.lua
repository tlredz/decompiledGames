local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AAEventWinAward = require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
local floatingOrbWins = require(ReplicatedStorage._FRAMEWORK.Libraries.floatingOrbWins)
require(ReplicatedStorage._FRAMEWORK.Libraries.floatingOrbWins.Types)
local SpacialQuery = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.SpacialQuery)
require(script.Parent.Parent.Types)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local YearCollectibles = {}

function YearCollectibles.createRemotes(p: string)
	return remo.createRemotes({
		[p] = remo.namespace({
			spawn = remo.remote(),
			despawn = remo.remote(),
			collect = remo.remote(t.string)
		})
	})[p]
end

function YearCollectibles.findZones(folder, p: string)
	local parts = {}

	for _, part in folder:GetDescendants() do
		if part.Name == p and part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	return parts
end

function YearCollectibles.startServer(data, data2)
	local remotes = data2.remotes
	local boundingBox, v = data.map:GetBoundingBox()
	local v2 = floatingOrbWins.startServer({
		config = data2.config,
		getSpawnZones = function()
			return data2.zones
		end,
		isPlayerEligible = function(player)
			local character = player.Character
			return character ~= nil and SpacialQuery.isPointInVolume(character:GetPivot().Position, boundingBox, v)
		end,
		awardWin = AAEventWinAward.create(data2.award),
		sendSpawn = function(p, p2: string, vector: Vector3)
			remotes.spawn:fire(p, p2, vector)
		end,
		sendDespawn = function(p, p2: string)
			remotes.despawn:fire(p, p2)
		end,
		logger = data2.logger
	})
	local collectConnection = remotes.collect:connect(v2.handleCollect)
	local cleanup = data.cleanup
	return {
		map = data.map,
		spawn = data.spawn,
		stopTools = data.stopTools,
		cleanup = function()
			collectConnection()
			v2.stop()
			cleanup()
		end
	}
end

function YearCollectibles.startClient(data)
	local remotes = data.remotes
	local v = floatingOrbWins.startClient({
		config = data.config,
		requestCollect = function(p: string)
			remotes.collect:fire(p)
		end,
		logger = data.logger
	})
	local spawnConnection = remotes.spawn:connect(v.handleSpawn)
	local despawnConnection = remotes.despawn:connect(v.handleDespawn)
	return function()
		spawnConnection()
		despawnConnection()
		v.stop()
	end
end

return YearCollectibles