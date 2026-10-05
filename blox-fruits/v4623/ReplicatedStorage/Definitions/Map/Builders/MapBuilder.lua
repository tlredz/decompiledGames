local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local IslandBuilder = require(game.ReplicatedStorage.Definitions.Map.Builders.IslandBuilder)
local Types = require(game.ReplicatedStorage.Definitions.Map.Types)

local function copy(data)
	local v = {
		_Current = {
			Key = data._Current.Key,
			Islands = table.clone(data._Current.Islands)
		},
		setKey = data.setKey,
		insertIsland = data.insertIsland,
		build = data.build
	}
	table.freeze(v)
	return v
end

local MapBuilder = {
	Island = IslandBuilder,
	BonusMoment = IslandBuilder.BonusMoment,
	Display = IslandBuilder.Display,
	Requirement = IslandBuilder.Requirement,
	TeleportPoint = IslandBuilder.TeleportPoint,
	World = IslandBuilder.World,
	Builder = {}
}

function MapBuilder.Builder.new(p)
	return {
		_Current = {
			Key = p,
			Islands = {}
		},
		setKey = function(p2, p3)
			local v = copy(p2)
			v._Current.Key = p3
			TableUtil.deepFreeze(v)
			return v
		end,
		insertIsland = function(self, p3)
			local islandDefinition, v = Types.IslandDefinition(p3)
			assert(islandDefinition, (`expected a built island definition, received an invalid value: {v}`))
			assert(
				p3.Index.Map == `{self._Current.Key}`,
				(`expected map to be "{self._Current.Key}", received "{p3.Index.Map}"`)
			)
			local v2 = copy(self)

			for _, island in v2._Current.Islands do
				assert(island.Index.Key ~= p3.Index.Key, (`already assigned an island at key "{p3.Index.Key}"`))
			end

			table.insert(v2._Current.Islands, p3)
			TableUtil.deepFreeze(v2)
			return v2
		end,
		build = function(p2)
			local key = p2._Current.Key
			assert(key ~= nil, "need to assign key before build")
			assert(#p2._Current.Islands > 0, (`map "{key}" needs at least one island assigned before build`))

			for _, island in p2._Current.Islands do
				assert(
					island.Index.Map == key,
					(`island "{island.Index.Key}" is indexed to map "{island.Index.Map}" but was assigned to map "{key}"`)
				)
			end

			local v = {
				_AddressType = "Map",
				Key = key,
				Islands = table.clone(p2._Current.Islands)
			}
			setmetatable(v, {
				__tostring = function(...)
					return (`MapDef({key})`)
				end
			})
			TableUtil.deepFreeze(v)
			return v
		end
	}
end

function MapBuilder.Builder.fromDefinition(p)
	local builder = MapBuilder.Builder.new(p.Key)

	for _, island in p.Islands do
		builder = builder:insertIsland(island)
	end

	return builder
end

return MapBuilder