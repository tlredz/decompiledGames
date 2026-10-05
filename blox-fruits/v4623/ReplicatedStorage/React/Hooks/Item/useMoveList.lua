local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local FruitSkills = require(game.ReplicatedStorage.FruitSkills)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local useCombatData = require(game.ReplicatedStorage.React.Hooks.Item.useCombatData)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useAwakenings = require(game.ReplicatedStorage.React.Hooks.Item.useAwakenings)
local v = {
	"TAP",
	"Z",
	"X",
	"C",
	"V",
	"F"
}

function getNames(p: string?, list)
	if not p then
		return nil
	end

	local fruitSkill = FruitSkills[p]

	if not fruitSkill then
		return nil
	end

	local result = {}

	for _, v2 in v do
		local v3 = fruitSkill[list and table.find(list, v2) and 2 or 1]

		if not v3 then
			continue
		end

		for _, v5 in ipairs(v3) do
			local v6 = v5[3]

			if v5[1] ~= v2 then
				continue
			end

			result[v2] = v6
			break
		end
	end

	table.freeze(result)
	return result
end

function getCooldowns(p, list)
	if not (p and p.Cooldown) then
		return nil
	end

	local result = {}

	for _, v2 in v do
		if list and table.find(list, v2) then
			local awakening = p.Awakening

			if awakening and awakening.Cooldown then
				result[v2] = awakening.Cooldown[v2]
				continue
			end
		end

		result[v2] = p.Cooldown[v2]
	end

	table.freeze(result)

	for _, _ in result do
		return result
	end

	return nil
end

function getCosts(p, list)
	if not (p and p.Cost) then
		return nil
	end

	local result = {}

	for _, v2 in v do
		if list and table.find(list, v2) then
			local awakening = p.Awakening

			if awakening and awakening.Cost then
				result[v2] = awakening.Cost[v2]
				continue
			end
		end

		result[v2] = p.Cost[v2]
	end

	table.freeze(result)

	for _, _ in result do
		return result
	end

	return nil
end

function getFragments(p, p2)
	if not p then
		return nil
	end

	local clone = nil

	if p2 then
		local awakening = p.Awakening

		if awakening and awakening.Fragments then
			clone = table.clone(awakening.Fragments)
		end
	end

	if clone then
		table.freeze(clone)
	end

	return nil
end

function getMasteries(p)
	if not p then
		return nil
	end

	local clone

	if p.Lvl then
		clone = table.clone(p.Lvl)
	end

	if clone then
		table.freeze(clone)
	end

	return clone
end

function getMoves(p, p2, p3)
	local storageKey = p and p.Index.StorageKey or nil
	local names = getNames(storageKey, p3)
	local cooldowns = getCooldowns(p2, p3)
	local costs = getCosts(p2, p3)
	local masteries = getMasteries(p2)
	local fragments = getFragments(p2, p3)

	if not RunService:IsRunning() then
		cooldowns = {
			Z = 5,
			X = 10,
			C = 15,
			V = 20,
			F = 25
		}
		costs = {
			Z = 10,
			X = 20,
			C = 30,
			V = 40,
			F = 50
		}
		masteries = {
			Z = 50,
			X = 40,
			C = 30,
			V = 20,
			F = 10
		}

		if p3 then
			fragments = {
				Z = 10,
				X = 20,
				C = 30,
				V = 40,
				F = 50
			}
		end
	end

	if not (names and masteries and cooldowns and costs) then
		return nil
	end

	local v2 = {}

	for k, name in names do
		local name2 = name
		local binding = k
		local success, result = pcall(function(...)
			assert(name2, (`bad displayName at "{binding}" for "{storageKey}"`))
			local mastery = masteries[binding]
			assert(mastery, (`bad mastery at "{binding}" for "{storageKey}"`))
			local cost = costs[binding]
			assert(cost, (`bad cost at "{binding}" for "{storageKey}"`))
			local cooldown = cooldowns[binding]
			assert(cooldown, (`bad cooldown at "{binding}" for "{storageKey}"`))
			local fragments2

			if fragments then
				fragments2 = fragments[binding]
			end

			local v6 = {
				Mastery = mastery,
				Name = name2,
				Binding = binding,
				Cooldown = cooldown,
				Fragments = fragments2,
				Cost = cost
			}
			table.freeze(v6)
			table.insert(v2, v6)
		end)

		if not success then
			warn((`useMoveList.getMoves error for "{k}" in "{storageKey}": {result}`))
		end
	end

	table.sort(v2, function(a, b)
		return (table.find(v, a.Binding) or 1e999) < (table.find(v, b.Binding) or 1e999)
	end)
	table.freeze(v2)
	return v2
end

return function(value, p)
	if type(value) == "string" then
		value = ItemId.getId(value, p):asNullable()
	elseif type(value) ~= "number" then
		value = nil
	end

	local v2 = useMatch(value)
	local v3 = React.useMemo(function()
		if not v2 then
			return nil
		end

		if v2.Index.IdType == "PhysicalMoveset" then
			local nullable = ItemConfig.Query.selectOne({
				Index = {
					IdType = "Moveset"
				},
				Moveset = {
					Physical = v2.Index.ItemId
				}
			}):asNullable()

			if not nullable then
				local nullable2 = ItemConfig.Query.selectOne({
					Index = {
						IdType = "Skin"
					},
					Skin = {
						Physical = v2.Index.ItemId
					}
				}):asNullable()

				if nullable2 and nullable2.Skin then
					nullable = ItemConfig.match(nullable2.Skin.Adornee):asNullable()
				end

				if not nullable then
					local nullable3 = ItemConfig.Query.selectOne({
						Index = {
							IdType = "Mutation"
						},
						Mutation = {
							Physical = v2.Index.ItemId
						}
					}):asNullable()

					if nullable3 and nullable3.Mutation then
						nullable = ItemConfig.match(nullable3.Mutation.Adornee):asNullable()
					end
				end
			end

			if not nullable then
				return nil
			end

			if nullable.Moveset and nullable.Moveset.SkillRedirect then
				return nullable.Moveset.SkillRedirect
			end

			return nullable.Index.ItemId
		elseif v2.Index.IdType == "Moveset" then
			return v2.Index.ItemId
		else
			return nil
		end
	end, { v2 })
	local v4 = useCombatData(v3)
	local v5 = useAwakenings(v3)
	local v6 = useMatch(v3)
	return (React.useMemo(function()
		if v6 == nil then
			return nil
		end

		return getMoves(v6, v4, v5)
	end, { v6, v5, v4 }))
end