local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local ISAAC = require(ReplicatedStorage.UserGenerated.Randoms.ISAAC)
local unique = ISAAC.Unique()
local table2 = Asserts.Table({
	Weight = Asserts.FinitePositive,
	Value = Asserts.Any
})
local table3 = Asserts.Table({
	Weight = Asserts.FinitePositive,
	Chance = Asserts.Range(0, 1),
	Value = Asserts.Any
})

local function Search(uppers, p: number)
	local count = #uppers
	local v2 = 1

	while v2 < count do
		local v3 = v2 + (count - v2) // 2

		if p < uppers[v3] then
			count = v3
		else
			v2 = v3 + 1
		end
	end

	return v2
end

local frozen = table.freeze({
	__index = table.freeze({
		Next = function(data)
			local double = unique:NextDouble()
			local search = Search(data.Uppers, data.TotalWeight * double)
			local entry = data.Entries[search]
			return entry.Value, entry
		end,
		Pick = function(data, p)
			local v2

			if p >= 0 then
				v2 = p <= 1
			else
				v2 = false
			end

			assert(v2)
			local search = Search(data.Uppers, data.TotalWeight * p)
			local entry = data.Entries[search]
			return entry.Value, entry
		end
	})
})

local function CompareOrderedEntry(p, p2)
	if p.Weight == p2.Weight then
		return p.Index < p2.Index
	end

	return p.Weight < p2.Weight
end

local function new(entries)
	Asserts.Array(table2)(entries)
	local count = #entries
	assert(count > 0)
	local v2 = {}

	for i, v3 in ipairs(entries) do
		table.insert(v2, {
			Index = i,
			Weight = v3.Weight
		})
	end

	table.sort(v2, CompareOrderedEntry)
	local uppers = table.create(count, 0)
	local total = 0
	local entries2 = {}

	for i, v5 in ipairs(v2) do
		local v6 = entries[v5.Index]
		local weight = v6.Weight
		total += weight
		uppers[i] = total
		table.insert(entries2, {
			Weight = weight,
			Chance = 0,
			Value = v6.Value
		})
	end

	table.freeze(uppers)

	for _, list in ipairs(entries2) do
		list.Chance = list.Weight / total
		table.freeze(list)
	end

	table.freeze(entries2)
	local self = setmetatable({
		TotalWeight = total,
		Entries = entries2,
		Uppers = uppers
	}, frozen)
	table.freeze(self)
	return self
end

local frozen2 = table.freeze({
	__index = table.freeze({
		Add = function(p, weight, p3)
			Asserts.FinitePositive(weight)
			p.AssertValue(p3)
			table.insert(p.Entries, {
				Weight = weight,
				Value = p3
			})
			return p
		end,
		Build = function(p)
			return (new(p.Entries))
		end
	})
})
return table.freeze({
	new = new,
	IsA = function(p)
		return type(p) == "table" and getmetatable(p) == frozen
	end,
	Assert = function(p)
		if type(p) ~= "table" then
			error("table", 2)
		end

		if getmetatable(p) ~= frozen then
			error("DropTable", 2)
		end

		return p
	end,
	AssertEntry = table3,
	Builder = function(assertValue)
		Asserts.Function(assertValue)
		local self = setmetatable({
			AssertValue = assertValue,
			Entries = {}
		}, frozen2)
		table.freeze(self)
		return self
	end,
	IsABuilder = function(p)
		return type(p) == "table" and getmetatable(p) == frozen2
	end,
	AssertBuilder = function(p)
		if type(p) ~= "table" then
			error("table", 2)
		end

		if getmetatable(p) ~= frozen2 then
			error("table", 2)
		end

		return p
	end,
	AssertBuilderEntry = table2
})