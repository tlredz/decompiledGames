local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Types = require(game.ReplicatedStorage.Definitions.Map.Types)

local function copy(data)
	local v = {
		_Current = table.clone(data._Current),
		setLocation = data.setLocation,
		setPlayerSpawn = data.setPlayerSpawn,
		setMap = data.setMap,
		setLOD = data.setLOD,
		build = data.build
	}
	table.freeze(v)
	return v
end

local ReferenceBuilder = {
	Builder = {}
}

function ReferenceBuilder.Builder.new()
	return {
		_Current = {},
		setLocation = function(self, location: string?)
			assert(location == nil or #location > 0, "location reference must not be an empty string")
			local v = copy(self)
			v._Current.Location = location
			TableUtil.deepFreeze(v)
			return v
		end,
		setPlayerSpawn = function(self, playerSpawn: string?)
			assert(playerSpawn == nil or #playerSpawn > 0, "player spawn reference must not be an empty string")
			local v = copy(self)
			v._Current.PlayerSpawn = playerSpawn
			TableUtil.deepFreeze(v)
			return v
		end,
		setMap = function(self, map: string)
			assert(#map > 0, "map reference must not be an empty string")
			local v = copy(self)
			v._Current.Map = map
			TableUtil.deepFreeze(v)
			return v
		end,
		setLOD = function(self, LOD: string?)
			assert(LOD == nil or #LOD > 0, "LOD reference must not be an empty string")
			local v = copy(self)
			v._Current.LOD = LOD
			TableUtil.deepFreeze(v)
			return v
		end,
		build = function(p)
			local _Current = p._Current
			local map = _Current.Map
			assert(map ~= nil, "need to assign a map reference to the reference definition before build")
			local v = {
				Location = _Current.Location,
				PlayerSpawn = _Current.PlayerSpawn,
				Map = map,
				LOD = _Current.LOD
			}
			TableUtil.deepFreeze(v)
			local islandReferenceDefinition, v2 = Types.IslandReferenceDefinition(v)
			assert(islandReferenceDefinition, (`built an invalid island reference definition: {v2}`))
			return v
		end
	}
end

function ReferenceBuilder.Builder.fromDefinition(data)
	return ReferenceBuilder.Builder.new():setLocation(data.Location):setPlayerSpawn(data.PlayerSpawn):setMap(data.Map):setLOD(data.LOD)
end

return ReferenceBuilder