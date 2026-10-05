local Builders = require(script.Builders)
local DEFINITIONS = require(script.DEFINITIONS)
local Realm = require(game.ReplicatedStorage.Util.Realm)
local FunctionCache = require(game.ReplicatedStorage.Util.FunctionCache)
local Map = {
	Types = require(script.Types),
	Builders = Builders,
	DEFINITIONS = DEFINITIONS,
	findMap = function(p)
		return DEFINITIONS[p]
	end
}

function Map.getMap(p)
	local map = Map.findMap(p)
	assert(map, (`bad map at key: {p}`))
	return map
end

function Map.findCurrentMap()
	local safeGetCurrentSeaAsync = Realm.safeGetCurrentSeaAsync()
	return Map.findMap(safeGetCurrentSeaAsync)
end

function Map.getCurrentMap()
	local currentMap = Map.findCurrentMap()
	assert(currentMap, "bad current map")
	return currentMap
end

local v = FunctionCache.new(function(p, p2: string)
	for _, island in p.Islands do
		if island.Index.Key == p2 then
			return island
		end
	end

	return nil
end, function(p, p2: string)
	return (`{p.Key}_{p2}`)
end)

function Map.findIsland(p, p2: string)
	return v:call(p, p2)
end

function Map.findClosestIsland(p, vector: Vector3, flag: boolean?)
	local v2 = 1e999
	local v3 = nil

	for _, island in p.Islands do
		local magnitude = (island.World.Position - vector).Magnitude

		if flag ~= true then
			magnitude = math.min(
				magnitude,
				((island.World.BackendPosition or island.World.Position) - vector).Magnitude
			)
		end

		if not (magnitude < v2) then
			continue
		end

		v3 = island
		v2 = magnitude
	end

	return v3
end

function Map.getIsland(p, p2: string)
	local island = Map.findIsland(p, p2)
	assert(island, (`bad island for map "{p.Key}" at key "{p2}"`))
	return island
end

local v2 = FunctionCache.new(function(p, p2: number)
	if not p.Requirements then
		return true
	end

	for _, requirement in p.Requirements do
		if requirement.Type == "Level" and p2 < requirement.MinimumLevel then
			return false
		end
	end

	return true
end, function(p, p2: number)
	return (`{p.Index.Key}_{p2}`)
end)

function Map.getIfRequirementsPass(p, p2: number)
	return v2:call(p, p2)
end

function Map.getMinimumLevel(p)
	if p.Requirements then
		for _, requirement in p.Requirements do
			if requirement.Type == "Level" then
				return requirement.MinimumLevel
			end
		end
	end

	return 0
end

function Map.getRequiredUnlockables(p)
	local result = {}

	if p.Requirements then
		for _, requirement in p.Requirements do
			if requirement.Type == "Unlockable" then
				table.insert(result, requirement.Key)
			end
		end
	end

	return result
end

function Map.getIfIslandComplete(p, callback)
	if not p.BonusMoments then
		return true
	end

	for _, bonusMoment in p.BonusMoments do
		if not callback(bonusMoment) then
			return false
		end
	end

	return true
end

local v3 = FunctionCache.new(function(p, p2: string)
	if p.BonusMoments then
		for _, bonusMoment in p.BonusMoments do
			if bonusMoment.Index.Key == p2 then
				return bonusMoment
			end
		end
	end

	return nil
end, function(p, p2: string)
	return (`{p.Index.Key}_{p2}`)
end)

function Map.findBonusMoment(p, p2: string)
	return v3:call(p, p2)
end

function Map.getBonusMoment(p, p2: string)
	local bonusMoment = Map.findBonusMoment(p, p2)
	assert(bonusMoment, (`bad bonus moment "{p2}"`))
	return bonusMoment
end

local v4 = FunctionCache.new(function(p, p2: string, p3: string)
	local islands = {}

	if p2 == "Location" then
		for _, island in p.Islands do
			if island.Reference.Location == p3 then
				table.insert(islands, island)
			end
		end
	elseif p2 == "PlayerSpawn" then
		for _, island in p.Islands do
			if island.Reference.PlayerSpawn == p3 then
				table.insert(islands, island)
			end
		end
	elseif p2 == "Map" then
		for _, island in p.Islands do
			if island.Reference.Map == p3 then
				table.insert(islands, island)
			end
		end
	elseif p2 == "LOD" then
		for _, island in p.Islands do
			if island.Reference.LOD == p3 then
				table.insert(islands, island)
			end
		end
	elseif p2 == "Any" then
		for _, island in p.Islands do
			if not (island.Reference.Location == p3 or island.Reference.PlayerSpawn == p3 or island.Reference.Map == p3 or island.Reference.LOD == p3) then
				continue
			end

			table.insert(islands, island)
		end
	else
		warn((`unsupported location: "{p2}"`))
	end

	table.freeze(islands)
	return islands
end, function(p, p2: string, p3: string)
	return (`{p.Key}_{p2}_{p3}`)
end)

function Map.getIslandsByReference(p, p2: string, p3: string)
	return table.clone(v4:call(p, p2, p3))
end

local v5 = FunctionCache.new(function(p, p2: string)
	for _, island in p.Islands do
		local bonusMoment = Map.findBonusMoment(island, p2)

		if bonusMoment then
			return bonusMoment
		end
	end

	return nil
end, function(p, p2: string)
	return (`{p.Key}_{p2}`)
end)

function Map.findBonusMomentFromMap(p, p2: string)
	return v5:call(p, p2)
end

function Map.getBonusMomentFromMap(p, p2: string)
	local bonusMomentFromMap = Map.findBonusMomentFromMap(p, p2)
	assert(bonusMomentFromMap, (`bad bonusMoment "{p2}"`))
	return bonusMomentFromMap
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toSegment(key: string)
	assert(not string.find(key, "/", 1, true), (`key "{key}" contains the reserved address separator "/"`))
	return key
end

function Map:getAddress()
	if self._AddressType == "Map" then
		return toSegment(self.Key)
	elseif self._AddressType == "Island" then
		local map = self.Index.Map
		assert(not string.find(map, "/", 1, true), (`key "{map}" contains the reserved address separator "/"`))
		return map .. "/" .. toSegment(self.Index.Key)
	else
		if self._AddressType ~= "BonusMoment" then
			error((`unknown definition "{self}" with address type: {self._AddressType}`))
			return
		end

		local map = self.Index.Map
		assert(not string.find(map, "/", 1, true), (`key "{map}" contains the reserved address separator "/"`))
		local island = self.Index.Island
		assert(not string.find(island, "/", 1, true), (`key "{island}" contains the reserved address separator "/"`))
		return map .. "/" .. island .. "/" .. toSegment(self.Index.Key)
	end
end

local v6 = FunctionCache.new(function(value)
	local v7 = string.split(value, "/")
	assert(#v7 <= 3, (`bad address "{value}"`))
	local map = Map.getMap(v7[1])

	if #v7 == 1 then
		return table.freeze({
			Type = "Map",
			Definition = map
		})
	end

	local island = Map.getIsland(map, v7[2])

	if #v7 == 2 then
		return table.freeze({
			Type = "Island",
			Definition = island
		})
	end

	return table.freeze({
		Type = "BonusMoment",
		Definition = Map.getBonusMoment(island, v7[3])
	})
end, function(p)
	return p
end)

function Map.fromAddress(p)
	return v6:call(p)
end

return Map