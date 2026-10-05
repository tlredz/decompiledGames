local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Types = require(game.ReplicatedStorage.Definitions.Map.Types)

local function copy(data)
	local v = {
		_Current = {
			Index = table.clone(data._Current.Index),
			Reward = table.clone(data._Current.Reward),
			IslandComplete = table.clone(data._Current.IslandComplete),
			Rumor = table.clone(data._Current.Rumor),
			RaidHint = table.clone(data._Current.RaidHint),
			Tags = table.clone(data._Current.Tags)
		},
		setRewardDialogue = data.setRewardDialogue,
		setIslandCompleteDialogue = data.setIslandCompleteDialogue,
		setRumorDialogue = data.setRumorDialogue,
		setRaidHint = data.setRaidHint,
		insertTag = data.insertTag,
		build = data.build
	}
	table.freeze(v)
	return v
end

local BonusMomentBuilder = {
	Builder = {}
}

function BonusMomentBuilder.Builder.new(p: string, island, map)
	assert(p ~= "", "bonus moment needs a non-empty key")
	assert(island, (`bonus moment "{p}" needs a non-empty island key`))
	return {
		_Current = {
			Index = {
				Key = p,
				Island = island,
				Map = map
			},
			Reward = {},
			IslandComplete = {},
			Rumor = {},
			RaidHint = {},
			Tags = {}
		},
		setRewardDialogue = function(p4, value)
			local v = copy(p4)
			v._Current.Reward = type(value) == "string" and { value } or table.clone(value)
			TableUtil.deepFreeze(v)
			return v
		end,
		setIslandCompleteDialogue = function(p4, value)
			local v = copy(p4)
			v._Current.IslandComplete = type(value) == "string" and { value } or table.clone(value)
			TableUtil.deepFreeze(v)
			return v
		end,
		setRumorDialogue = function(p4, value)
			local v = copy(p4)
			v._Current.Rumor = type(value) == "string" and { value } or table.clone(value)
			TableUtil.deepFreeze(v)
			return v
		end,
		setRaidHint = function(p4, value)
			local v = copy(p4)
			v._Current.RaidHint = type(value) == "string" and { value } or table.clone(value)
			TableUtil.deepFreeze(v)
			return v
		end,
		insertTag = function(p4, p5)
			local bonusMomentTag, v = Types.BonusMomentTag(p5)
			assert(bonusMomentTag, (`expected a bonus moment tag, received an invalid value: {v}`))
			local v2 = copy(p4)

			for _, tag in v2._Current.Tags do
				assert(tag ~= p5, (`bonus moment "{v2._Current.Index.Key}" already has the "{p5}" tag assigned`))
			end

			table.insert(v2._Current.Tags, p5)
			TableUtil.deepFreeze(v2)
			return v2
		end,
		build = function(p4)
			local _Current = p4._Current
			local v = {
				_AddressType = "BonusMoment",
				Index = {
					Key = _Current.Index.Key,
					Island = _Current.Index.Island,
					Map = _Current.Index.Map
				},
				Dialogue = 0,
				Tags = 0
			}
			local reward

			if #_Current.Reward > 0 then
				reward = table.clone(_Current.Reward)
			end

			local islandComplete

			if #_Current.IslandComplete > 0 then
				islandComplete = table.clone(_Current.IslandComplete)
			end

			local rumor

			if #_Current.Rumor > 0 then
				rumor = table.clone(_Current.Rumor)
			end

			local raidHint

			if #_Current.RaidHint > 0 then
				raidHint = table.clone(_Current.RaidHint)
			end

			v.Dialogue = {
				Reward = reward,
				IslandComplete = islandComplete,
				Rumor = rumor,
				RaidHint = raidHint
			}
			v.Tags = table.clone(_Current.Tags)
			setmetatable(v, {
				__tostring = function(...)
					return (`BonusMoment({_Current.Index.Key})`)
				end
			})
			TableUtil.deepFreeze(v)
			local bonusMomentDefinition, v7 = Types.BonusMomentDefinition(v)
			assert(
				bonusMomentDefinition,
				(`bonus moment "{_Current.Index.Key}" built into an invalid bonusMoment: {v7}`)
			)
			return v
		end
	}
end

return BonusMomentBuilder