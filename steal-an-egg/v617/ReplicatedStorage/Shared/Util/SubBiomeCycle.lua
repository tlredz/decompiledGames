local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
local Areas = require(ReplicatedStorage.Data.Areas)
require(ReplicatedStorage.Data.Areas.Types)
local LiveEventFlags = require(ReplicatedStorage.Shared.Flags.LiveEventFlags)
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.string)
local strict2 = t.strict(t.number)
local v = {}
local v2 = {}

local function hash(value: string)
	local v3 = 2166136261

	for i = 1, #value do
		v3 = bit32.bxor(v3, string.byte(value, i)) * 16777619 % 4294967296
	end

	return v3
end

local function variantsOf(p: string)
	local v3 = Areas.Directory[p]

	if v3 == nil then
		return nil
	end

	local subBiomes = v3.SubBiomes

	if subBiomes == nil or #subBiomes == 0 then
		return nil
	end

	return subBiomes
end

function v2.OverrideAttributeName(value: string)
	strict(value)
	return "SubBiomeOverride_" .. value:gsub("[^%w]", "_")
end

function v2.LocalRevealAttributeName(value: string)
	strict(value)
	return "SubBiomeLocalReveal_" .. value:gsub("[^%w]", "_")
end

function v2.IsRotating(p: string)
	strict(p)
	local v3 = Areas.Directory[p]
	local subBiomes

	if v3 ~= nil then
		subBiomes = v3.SubBiomes

		if subBiomes == nil or #subBiomes == 0 then
			subBiomes = nil
		end
	end

	return subBiomes ~= nil
end

function v2.Variants(p: string)
	strict(p)
	local v3 = Areas.Directory[p]
	local subBiomes

	if v3 ~= nil then
		subBiomes = v3.SubBiomes

		if subBiomes == nil or #subBiomes == 0 then
			subBiomes = nil
		end
	end

	return subBiomes or {}
end

function v2.ById(p: string, p2: string)
	strict(p)
	strict(p2)

	for _, v3 in v2.Variants(p) do
		if v3.Id == p2 then
			return v3
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function localRevealOf(p: string)
	local attribute = Workspace:GetAttribute(v2.LocalRevealAttributeName(p))

	if type(attribute) == "string" then
		return (v2.ById(p, attribute))
	end

	return nil
end

local function revealStateOf(p: string)
	local v3 = Areas.Directory[p]
	local reveal

	if v3 ~= nil then
		reveal = v3.Reveal
	end

	if reveal == nil then
		return nil, nil
	end

	local v4 = LiveEventFlags.Get(reveal.Flag):Get()

	if type(v4) == "table" then
		return reveal, v4
	end

	return reveal, nil
end

function v2.RevealPhaseAt(p: string, p2: number)
	strict(p)
	strict2(p2)
	local v3 = Areas.Directory[p]
	local reveal

	if v3 ~= nil then
		reveal = v3.Reveal
	end

	local v4

	if reveal == nil then
		reveal = nil
	else
		v4 = LiveEventFlags.Get(reveal.Flag):Get()

		if type(v4) ~= "table" then
			v4 = nil
		end
	end

	if reveal == nil then
		return nil
	end

	if v4 == nil then
		local v5 = localRevealOf(p) -- equivalent call inferred; original call site unknown

		if v5 == nil then
			return "Sealed"
		end

		return "RevealNight"
	elseif AreaEggCycle.ActivePeriodIndexAt(p2) <= v4.RevealPeriod then
		return "RevealNight"
	else
		return "Open"
	end
end

function v2.RolledForPeriod(p: string, p2: number)
	strict(p)
	strict2(p2)
	local v3 = Areas.Directory[p]
	local subBiomes

	if v3 ~= nil then
		subBiomes = v3.SubBiomes

		if subBiomes == nil or #subBiomes == 0 then
			subBiomes = nil
		end
	end

	if subBiomes == nil then
		return nil
	end

	local total = 0

	for _, subBiome in subBiomes do
		total += subBiome.Weight
	end

	if total <= 0 then
		return subBiomes[1]
	end

	local formatted = `{p}:{p2}`
	local v4 = 2166136261

	for i = 1, #formatted do
		v4 = bit32.bxor(v4, string.byte(formatted, i)) * 16777619 % 4294967296
	end

	local v5 = Random.new(v4 % 2147483647):NextNumber() * total

	for _, subBiome in subBiomes do
		v5 -= subBiome.Weight

		if v5 <= 0 then
			return subBiome
		end
	end

	return subBiomes[#subBiomes]
end

function v2.ForPeriod(p: string, p2: number)
	strict(p)
	strict2(p2)
	local attribute = Workspace:GetAttribute(v2.OverrideAttributeName(p))

	if type(attribute) == "string" then
		local v3 = v2.ById(p, attribute)

		if v3 ~= nil then
			return v3
		end
	end

	local selected = localRevealOf(p) -- equivalent call inferred; original call site unknown

	if selected ~= nil then
		return selected
	end

	local v4 = Areas.Directory[p]
	local reveal

	if v4 ~= nil then
		reveal = v4.Reveal
	end

	local v5

	if reveal == nil then
		reveal = nil
	else
		v5 = LiveEventFlags.Get(reveal.Flag):Get()

		if type(v5) ~= "table" then
			v5 = nil
		end
	end

	if reveal == nil then
		return v2.RolledForPeriod(p, p2)
	end

	if v5 == nil then
		local v6 = v2.ById(p, reveal.RevealSubBiome)

		if v6 ~= nil then
			return v6
		end
	elseif p2 <= (v5.WinnerPeriod or v5.RevealPeriod) + 1 then
		local v6 = v2.ById(p, v5.Winner)

		if v6 ~= nil then
			return v6
		end
	end

	return v2.RolledForPeriod(p, p2)
end

function v2.ActiveAt(p: string, p2: number)
	strict(p)
	strict2(p2)
	return v2.ForPeriod(p, AreaEggCycle.ActivePeriodIndexAt(p2))
end

function v2.Active(p: string)
	strict(p)
	return v2.ActiveAt(p, Workspace:GetServerTimeNow())
end

function v2.PoolDropTable(p: string, data)
	strict(p)
	local formatted = `{p}|{data.Id}`
	local v3 = v[formatted]

	if v3 ~= nil then
		return v3
	end

	local dropTable = data.DropTable

	if dropTable ~= nil then
		v[formatted] = dropTable
		return dropTable
	end

	local v4 = {}

	for _, v5 in data.Pool do
		v4[v5] = true
	end

	local result = {}

	for _, v5 in Areas.Directory[p].DropTable do
		if v4[v5[1]] then
			table.insert(result, v5)
		end
	end

	assert(#result > 0, (`Sub-biome "{data.Id}" of area "{p}" has no pool entry in the area drop table`))
	v[formatted] = result
	return result
end

function v2.SetOverride(p: string, p2: string?)
	assert(RunService:IsServer(), "Only the server may force a sub-biome")
	strict(p)

	if p2 ~= nil then
		assert(v2.ById(p, p2) ~= nil, (`Area "{p}" has no sub-biome "{p2}"`))
	end

	Workspace:SetAttribute(v2.OverrideAttributeName(p), p2)
end

function v2.SetLocalReveal(p: string, p2: string?)
	assert(RunService:IsServer(), "Only the server may set a local reveal")
	strict(p)

	if p2 ~= nil then
		assert(v2.ById(p, p2) ~= nil, (`Area "{p}" has no sub-biome "{p2}"`))
	end

	Workspace:SetAttribute(v2.LocalRevealAttributeName(p), p2)
end

function v2.IsOverridden(p: string)
	strict(p)
	return type(Workspace:GetAttribute(v2.OverrideAttributeName(p))) == "string"
end

return table.freeze(v2)