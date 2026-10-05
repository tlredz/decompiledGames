local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Types = require(game.ReplicatedStorage.Definitions.Map.Types)

local function copy(data)
	local v = {
		_Current = table.clone(data._Current),
		setPosition = data.setPosition,
		setBackendPosition = data.setBackendPosition,
		setDiameter = data.setDiameter,
		build = data.build
	}
	table.freeze(v)
	return v
end

local WorldBuilder = {
	Builder = {}
}

function WorldBuilder.Builder.new()
	return {
		_Current = {},
		setBackendPosition = function(p, backendPosition: Vector3)
			local v = copy(p)
			v._Current.BackendPosition = backendPosition
			TableUtil.deepFreeze(v)
			return v
		end,
		setPosition = function(self, position: Vector3)
			local v = copy(self)
			v._Current.Position = position
			TableUtil.deepFreeze(v)
			return v
		end,
		setDiameter = function(self, diameter: number)
			assert(diameter > 0, (`world diameter must be above 0, received {diameter}`))
			local v = copy(self)
			v._Current.Diameter = diameter
			TableUtil.deepFreeze(v)
			return v
		end,
		build = function(p)
			local _Current = p._Current
			local position = _Current.Position
			local diameter = _Current.Diameter
			local backendPosition = _Current.BackendPosition
			assert(position ~= nil, "need to assign a position to the world definition before build")
			assert(diameter ~= nil, "need to assign a diameter to the world definition before build")
			local v = {
				Position = position,
				BackendPosition = backendPosition,
				Diameter = diameter
			}
			TableUtil.deepFreeze(v)
			local islandWorldDefinition, v2 = Types.IslandWorldDefinition(v)
			assert(islandWorldDefinition, (`built an invalid island world definition: {v2}`))
			return v
		end
	}
end

function WorldBuilder.Builder.fromDefinition(p)
	return WorldBuilder.Builder.new():setPosition(p.Position):setDiameter(p.Diameter)
end

return WorldBuilder