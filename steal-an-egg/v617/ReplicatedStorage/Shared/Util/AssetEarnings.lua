local ReplicatedStorage = game:GetService("ReplicatedStorage")
local earnings = require(ReplicatedStorage.Shared.Flags.GameplayBalance).Earnings
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local AdminBoosts = require(ReplicatedStorage2.Shared.Util.AdminBoosts)
local Assets = require(ReplicatedStorage2.Data.Assets)
local AssetItem = require(ReplicatedStorage2.Shared.Types.AssetItem)
local MonetizationEntitlements = require(ReplicatedStorage2.Shared.Util.MonetizationEntitlements)
require(ReplicatedStorage2.Shared.Types.Monetization)
local Mutations = require(ReplicatedStorage2.Shared.Modules.Mutations)
local PlayerEarningsBoost = require(ReplicatedStorage2.Shared.Util.PlayerEarningsBoost)
local t = require(ReplicatedStorage2.Packages.t)
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))
local strict = t.strict(intersection)

-- equivalent calls inferred from this helper; original call sites unknown
local function scalePayoutFactor(scale: number)
	strict(scale)
	assert(scale > 0, "Payout factor is undefined for a non-positive asset scale")

	if scale <= earnings.TAPER_KNEE_SCALE then
		return scale ^ earnings.STEEP_SCALE_POWER
	end

	return earnings.TAPER_KNEE_SCALE ^ earnings.STEEP_SCALE_POWER * (scale / earnings.TAPER_KNEE_SCALE) ^ earnings.TAPERED_SCALE_POWER
end

-- equivalent calls inferred from this helper; original call sites unknown
local function catalogEarningRate(p)
	local v = Assets.Directory[p.Category]
	return v and tonumber(v.EarningRate) or 0
end

local function entitledRate(p, p2, p3)
	assert(AssetItem.AssetItemData(p))
	local v = catalogEarningRate(p) -- equivalent call inferred; original call site unknown
	local v2 = scalePayoutFactor(p.Scale) -- equivalent call inferred; original call site unknown
	local v3 = v * v2
	local earningsFor = Mutations.EarningsFor(p.Mutations)
	local v4 = 1 + MonetizationEntitlements.AssetMoneyAdditiveBonus(p2, p3)
	return (math.max(math.round(v3 * earningsFor * v4), earnings.MINIMUM_RATE))
end

local AssetEarnings = {}

function AssetEarnings.RatePerSecond(p, p2, p3)
	assert(AssetItem.AssetItemData(p))
	return (entitledRate(p, p2, p3))
end

function AssetEarnings.LiveRatePerSecond(p, p2, p3, p4)
	return (math.round(entitledRate(p, p2, p3) * AdminBoosts.ReadMultiplier(AdminBoosts.EARNINGS) * PlayerEarningsBoost.GetMultiplier(p4)))
end

function AssetEarnings.MutationOnlyRatePerSecond(p)
	assert(AssetItem.AssetItemData(p))
	return (entitledRate(p))
end

function AssetEarnings.CatalogRatePerSecond(p)
	assert(AssetItem.AssetItemData(p))
	local v = catalogEarningRate(p) -- equivalent call inferred; original call site unknown
	local v2 = scalePayoutFactor(p.Scale) -- equivalent call inferred; original call site unknown
	return v * v2
end

return AssetEarnings