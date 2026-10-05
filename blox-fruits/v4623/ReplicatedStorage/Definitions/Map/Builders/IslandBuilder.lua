local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local BonusMomentBuilder = require(game.ReplicatedStorage.Definitions.Map.Builders.BonusMomentBuilder)
local DisplayBuilder = require(game.ReplicatedStorage.Definitions.Map.Builders.DisplayBuilder)
local ReferenceBuilder = require(game.ReplicatedStorage.Definitions.Map.Builders.ReferenceBuilder)
local RequirementBuilder = require(game.ReplicatedStorage.Definitions.Map.Builders.RequirementBuilder)
local TeleportPointBuilder = require(game.ReplicatedStorage.Definitions.Map.Builders.TeleportPointBuilder)
local WorldBuilder = require(game.ReplicatedStorage.Definitions.Map.Builders.WorldBuilder)
local Types = require(game.ReplicatedStorage.Definitions.Map.Types)

local function copy(data)
	local v = {
		_Current = {
			Index = table.clone(data._Current.Index),
			Display = data._Current.Display,
			Reference = data._Current.Reference,
			World = data._Current.World,
			Tags = table.clone(data._Current.Tags),
			Requirements = table.clone(data._Current.Requirements),
			TeleportPoints = table.clone(data._Current.TeleportPoints),
			BonusMoments = table.clone(data._Current.BonusMoments)
		},
		setKey = data.setKey,
		setMap = data.setMap,
		setDisplay = data.setDisplay,
		setReference = data.setReference,
		setWorld = data.setWorld,
		insertTag = data.insertTag,
		insertRequirement = data.insertRequirement,
		insertTeleportPoint = data.insertTeleportPoint,
		insertBonusMoment = data.insertBonusMoment,
		build = data.build
	}
	table.freeze(v)
	return v
end

local IslandBuilder = {
	BonusMoment = BonusMomentBuilder,
	Display = DisplayBuilder,
	Reference = ReferenceBuilder,
	Requirement = RequirementBuilder,
	TeleportPoint = TeleportPointBuilder,
	World = WorldBuilder,
	Builder = {}
}

function IslandBuilder.Builder.new(p, map2)
	return {
		_Current = {
			Index = {
				Key = p,
				Map = map2
			},
			Tags = {},
			Requirements = {},
			TeleportPoints = {},
			BonusMoments = {}
		},
		setKey = function(p3, p4)
			local v = copy(p3)
			v._Current.Index.Key = p4
			TableUtil.deepFreeze(v)
			return v
		end,
		setMap = function(p3, map)
			local v = copy(p3)
			v._Current.Index.Map = map
			TableUtil.deepFreeze(v)
			return v
		end,
		setDisplay = function(self, display)
			local islandDisplayDefinition, v = Types.IslandDisplayDefinition(display)
			assert(islandDisplayDefinition, (`expected a built display definition, received an invalid value: {v}`))
			local v2 = copy(self)
			v2._Current.Display = display
			TableUtil.deepFreeze(v2)
			return v2
		end,
		setReference = function(self, reference)
			local islandReferenceDefinition, v = Types.IslandReferenceDefinition(reference)
			assert(islandReferenceDefinition, (`expected a built reference definition, received an invalid value: {v}`))
			local v2 = copy(self)
			v2._Current.Reference = reference
			TableUtil.deepFreeze(v2)
			return v2
		end,
		setWorld = function(self, world)
			local islandWorldDefinition, v = Types.IslandWorldDefinition(world)
			assert(islandWorldDefinition, (`expected a built world definition, received an invalid value: {v}`))
			local v2 = copy(self)
			v2._Current.World = world
			TableUtil.deepFreeze(v2)
			return v2
		end,
		insertTag = function(p3, p4)
			local islandTag, v = Types.IslandTag(p4)
			assert(islandTag, (`expected an island tag, received an invalid value: {v}`))
			local v2 = copy(p3)

			for _, tag in v2._Current.Tags do
				assert(tag ~= p4, (`island "{v2._Current.Index.Key}" already has the "{p4}" tag assigned`))
			end

			table.insert(v2._Current.Tags, p4)
			TableUtil.deepFreeze(v2)
			return v2
		end,
		insertRequirement = function(self, p4)
			local requirement, v = Types.Requirement(p4)
			assert(requirement, (`expected a built requirement, received an invalid value: {v}`))
			local v2 = copy(self)

			for _, requirement2 in v2._Current.Requirements do
				assert(
					requirement2.Type ~= p4.Type,
					(`island "{v2._Current.Index.Key}" already has a "{p4.Type}" requirement assigned`)
				)
			end

			table.insert(v2._Current.Requirements, p4)
			TableUtil.deepFreeze(v2)
			return v2
		end,
		insertTeleportPoint = function(self, p4)
			local pendingTeleportPoint, v = TeleportPointBuilder.PendingTeleportPoint(p4)
			assert(pendingTeleportPoint, (`expected a built teleport point, received an invalid value: {v}`))
			local v2 = copy(self)
			table.insert(v2._Current.TeleportPoints, p4)
			TableUtil.deepFreeze(v2)
			return v2
		end,
		insertBonusMoment = function(self, p4)
			local bonusMomentDefinition, v = Types.BonusMomentDefinition(p4)
			assert(bonusMomentDefinition, (`expected a built bonusMoment, received an invalid value: {v}`))
			local v2 = copy(self)
			assert(
				p4.Index.Island == v2._Current.Index.Key,
				(`bonusMoment "{p4.Index.Key}" is indexed to island "{p4.Index.Island}" but was assigned to island "{v2._Current.Index.Key}"`)
			)
			assert(
				p4.Index.Map == v2._Current.Index.Map,
				(`bonusMoment "{p4.Index.Key}" is indexed to map "{p4.Index.Map}" but was assigned to map "{v2._Current.Index.Map}"`)
			)

			for _, bonusMoment in v2._Current.BonusMoments do
				assert(
					bonusMoment.Index.Key ~= p4.Index.Key,
					(`island "{v2._Current.Index.Key}" already has an bonusMoment at key "{p4.Index.Key}"`)
				)
			end

			table.insert(v2._Current.BonusMoments, p4)
			TableUtil.deepFreeze(v2)
			return v2
		end,
		build = function(p3)
			local _Current = p3._Current
			local key = _Current.Index.Key
			assert(key, "need to assign a key before build")
			local display = _Current.Display
			local reference = _Current.Reference
			local world = _Current.World
			local tags = _Current.Tags
			assert(display ~= nil, (`need to assign a display definition to island "{key}" before build`))
			assert(reference ~= nil, (`need to assign a reference definition to island "{key}" before build`))
			assert(world ~= nil, (`need to assign a world definition to island "{key}" before build`))
			local values = {}

			for _, teleportPoint in _Current.TeleportPoints do
				table.insert(values, TeleportPointBuilder.resolve(teleportPoint, display.Icon))
			end

			local v = {
				_AddressType = "Island",
				Index = {
					Key = key,
					Map = _Current.Index.Map
				},
				Tags = table.clone(tags),
				Display = display,
				Reference = reference,
				Requirements = 0,
				World = 0,
				TeleportPoints = 0,
				BonusMoments = 0
			}
			local requirements

			if #_Current.Requirements > 0 then
				requirements = table.clone(_Current.Requirements)
			end

			v.Requirements = requirements
			v.World = world

			if not (#values > 0) then
				values = nil
			end

			v.TeleportPoints = values
			local bonusMoments

			if #_Current.BonusMoments > 0 then
				bonusMoments = table.clone(_Current.BonusMoments)
			end

			v.BonusMoments = bonusMoments
			setmetatable(v, {
				__tostring = function(...)
					return (`IslandDef({key})`)
				end
			})
			TableUtil.deepFreeze(v)
			local islandDefinition, v4 = Types.IslandDefinition(v)
			assert(islandDefinition, (`island "{key}" built into an invalid definition: {v4}`))
			return v
		end
	}
end

function IslandBuilder.Builder.fromDefinition(data)
	local v = IslandBuilder.Builder.new(data.Index.Key, data.Index.Map):setDisplay(data.Display):setReference(data.Reference):setWorld(data.World)

	if data.Requirements then
		for _, requirement in data.Requirements do
			v = v:insertRequirement(requirement)
		end
	end

	if data.BonusMoments then
		for _, bonusMoment in data.BonusMoments do
			v = v:insertBonusMoment(bonusMoment)
		end
	end

	if data.TeleportPoints then
		for _, teleportPoint in data.TeleportPoints do
			v = v:insertTeleportPoint(TeleportPointBuilder.new(teleportPoint.Position, teleportPoint.Sprite))
		end
	end

	return v
end

return IslandBuilder