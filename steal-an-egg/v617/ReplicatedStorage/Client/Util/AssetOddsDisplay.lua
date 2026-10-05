local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetItem = require(ReplicatedStorage.Shared.Types.AssetItem)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local t = require(ReplicatedStorage.Packages.t)
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))
local strict = t.strict(t.table)
local strict2 = t.strict(intersection)
local AssetOddsDisplay = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function skeletonFor(p: number)
	if p < 1000 then
		return "."
	end

	local v = p / 1000 ^ math.floor(math.log10(p) / 3)

	if v < 10 then
		return ".##"
	end

	if v < 100 then
		return ".#"
	end

	return "."
end

local function compactOdds(p: number)
	local v = math.max(1, p)
	local v2 = 10 ^ (math.floor((math.log10(v))) - 3 + 1)
	local v3 = math.floor(v / v2) * v2
	local formatCompact = Simple.FormatCompact
	local v4 = skeletonFor(v3) -- equivalent call inferred; original call site unknown
	return string.lower(formatCompact(v3, v4))
end

function AssetOddsDisplay.Resolve(p, p2)
	strict(p)
	local v = nil
	local visualOdds = p.VisualOdds

	if typeof(visualOdds) == "number" and visualOdds > 0 then
		v = visualOdds
	else
		local dropWeight = p.DropWeight

		if typeof(dropWeight) == "number" and dropWeight > 0 then
			v = 1 / dropWeight
		end
	end

	if v == nil or p2 == nil then
		return v
	end

	return v * Mutations.RarityFactorFor(p2.Mutations, p2.BaseMutation)
end

function AssetOddsDisplay.Describe(p, flag: boolean?, p2)
	strict(p)
	local resolved = AssetOddsDisplay.Resolve(p, p2)

	if resolved == nil then
		return "1/?"
	end

	local v3 = math.max(1, resolved)
	local v4 = 10 ^ (math.floor((math.log10(v3))) - 3 + 1)
	local v5 = math.floor(v3 / v4) * v4
	local formatCompact = Simple.FormatCompact
	local v6 = skeletonFor(v5) -- equivalent call inferred; original call site unknown
	return (`{flag and "1 in " or "1/"}{string.lower(formatCompact(v5, v6))}`)
end

function AssetOddsDisplay.DescribeItem(p, p2, flag: boolean?)
	assert(AssetItem.AssetItemData(p2))
	local v = {
		Mutations = p2.Mutations,
		BaseMutation = p2.BaseMutation
	}
	return AssetOddsDisplay.Describe(p, flag, v)
end

function AssetOddsDisplay.Compact(p: number)
	strict2(p)
	return compactOdds(p)
end

return AssetOddsDisplay