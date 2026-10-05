local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local Catalog = require(script.Catalog)
local Log = require(ReplicatedStorage.Packages.Log)
local v = Log.new()
local Types = require(script.Types)
local t = require(ReplicatedStorage.Packages.t)
local Visuals = require(script.Visuals)
local idSet = {}
local result = {}
local total = 0
local values = {}

for k, v3 in Catalog do
	assert(k == v3.Id, (`Mutations | Catalog key "{k}" does not match its Id "{v3.Id}"`))

	if Constants.IS_STUDIO then
		local mutationSpec, v4 = Types.MutationSpec(v3)
		assert(mutationSpec, (`Mutations | "{k}" does not match the MutationSpec schema: {v4}`))
	end

	idSet[k] = true
	result[k] = k
	total += v3.RollWeight
	table.insert(values, table.freeze({ k, v3.RollWeight }))
end

local v3 = math.max(0, 100 - total)

if Constants.IS_STUDIO then
	assert(v3 > 0, (`Mutations | Roll weights total {total}, which leaves no room for "None"`))
end

table.insert(values, table.freeze({ "None", v3 }))
table.freeze(idSet)
table.freeze(result)
table.freeze(values)
local Mutations = {
	NO_MUTATION = "None",
	TOTAL_ROLL_WEIGHT = 100,
	IdSet = idSet,
	All = function()
		return Catalog
	end,
	Ids = function()
		return result
	end,
	IsKnown = function(p: string)
		t.strict(t.string)(p)
		return idSet[p] == true
	end,
	Get = function(p: string)
		local v4 = Catalog[p]

		if v4 then
			return v4
		end

		v:AtWarning():Log((`Mutations.Get | Unknown mutation "{tostring(p)}"`))
		return nil
	end,
	LabelOf = function(p: string)
		t.strict(t.string)(p)
		local v4 = Catalog[p]

		if v4 then
			return v4.Label
		end

		return p
	end,
	RollTable = function()
		local total2 = 0
		local result2 = {}

		for k, v4 in Catalog do
			total2 += v4.RollWeight
			table.insert(result2, { k, v4.RollWeight })
		end

		table.insert(result2, { "None", (math.max(0, 100 - total2)) })
		return result2
	end,
	RollChanceOf = function(p: string)
		local v4 = Catalog[p]

		if v4 and not (v4.RollWeight <= 0) then
			return v4.RollWeight / 100
		end

		return 0
	end,
	Sanitize = function(list, value: string?)
		local result2 = {}
		local v4 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function include(value2: string?)
			if typeof(value2) ~= "string" or v4[value2] or not idSet[value2] then
				return
			end

			v4[value2] = true
			table.insert(result2, value2)
		end

		include(value) -- equivalent call inferred; original call site unknown

		if typeof(list) ~= "table" then
			return result2
		end

		for _, v5 in ipairs(list) do
			if typeof(v5) ~= "string" or v4[v5] or not idSet[v5] then
				continue
			end

			v4[v5] = true
			table.insert(result2, v5)
		end

		return result2
	end
}

function Mutations.EggModelName(p, p2: string?)
	for _, v4 in Mutations.Sanitize(p, p2) do
		local v5 = Catalog[v4]

		if v5 and v5.EggModelName then
			return v5.EggModelName
		end
	end

	return nil
end

function Mutations.EggDisplayName(p, p2: string?)
	for _, v4 in Mutations.Sanitize(p, p2) do
		local v5 = Catalog[v4]

		if v5 and v5.EggDisplayName then
			return v5.EggDisplayName
		end
	end

	return nil
end

function Mutations.EggIcon(p, p2: string?)
	for _, v4 in Mutations.Sanitize(p, p2) do
		local v5 = Catalog[v4]

		if v5 and v5.EggIcon then
			return v5.EggIcon
		end
	end

	return nil
end

function Mutations.EarningsFor(items)
	local total2 = 1

	for _, item in items do
		local v4 = Catalog[item]

		if v4 then
			total2 += math.max(0, v4.EarningsScalar - 1)
		else
			v:AtError():Log((`Mutations.EarningsFor | Unknown mutation "{tostring(item)}"`))
		end
	end

	return (math.max(1, total2))
end

function Mutations.RarityFactorFor(p, p2: string?)
	local v4 = 1

	for _, v5 in Mutations.Sanitize(p, p2) do
		local rollChance = Mutations.RollChanceOf(v5)

		if rollChance > 0 then
			v4 *= 1 / rollChance
		end
	end

	return v4
end

function Mutations.ApplyTo(p, p2: string, p3: number?)
	t.strict(t.Instance)(p)
	t.strict(t.string)(p2)
	t.strict(t.optional(t.number))(p3)
	local v4 = assert(Catalog[p2], (`Mutations.ApplyTo | Unknown mutation "{p2}"`))
	local fXPart = Visuals.GetFXPart(p)

	if not fXPart then
		return
	end

	local shouldApplyMetalCombo = Visuals.ShouldApplyMetalCombo(p, p2)
	local v5

	if p3 ~= nil then
		v5 = Random.new(Visuals.SeedFor(p3, p2))
	end

	Visuals.WithVisualRandom(v5, function()
		v4:Apply(p, fXPart)

		if shouldApplyMetalCombo then
			local v6 = assert(p3, "A Golden and Silver combination requires a visual seed")
			Visuals.ApplyMetalCombo(p, v6)
		end
	end)
end

function Mutations.ClearFrom(p, p2: string)
	t.strict(t.Instance)(p)
	t.strict(t.string)(p2)
	local v4 = assert(Catalog[p2], (`Mutations.ClearFrom | Unknown mutation "{p2}"`))
	local fXPart = Visuals.GetFXPart(p)

	if not fXPart then
		return
	end

	v4:Clear(p, fXPart)
end

function Mutations.ClearAllFrom(p)
	t.strict(t.Instance)(p)
	local fXPart = Visuals.GetFXPart(p)

	if not fXPart then
		return
	end

	for _, v4 in Catalog do
		local v5 = v4
		task.spawn(function()
			v5:Clear(p, fXPart)
		end)
	end
end

return Mutations