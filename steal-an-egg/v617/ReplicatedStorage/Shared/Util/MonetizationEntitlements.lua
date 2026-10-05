local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gamepassBenefits = require(ReplicatedStorage.Shared.Flags.GameplayBalance).GamepassBenefits
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Gamepasses = require(ReplicatedStorage2.Data.Gamepasses)
require(ReplicatedStorage2.Shared.Types.Monetization)
local Marketplace = require(ReplicatedStorage2.Shared.Utils.Marketplace)
local Products = require(ReplicatedStorage2.Data.Products)
local price = Marketplace.Price
local t = require(ReplicatedStorage2.Packages.t)
local x2Money = Gamepasses.Directory.X2Money
local x2Growth = Gamepasses.Directory.X2Growth
local lucky = Gamepasses.Directory.Lucky
local frozen = table.freeze({
	[x2Money.Name] = true
})
local frozen2 = table.freeze({
	[lucky.Name] = true
})
local frozen3 = table.freeze({
	[x2Money.Name] = true,
	[lucky.Name] = true
})
local strict = t.strict(t.number)
local strict2 = t.strict(t.instanceIsA("Player"))
local strict3 = t.strict(t.string)
local MonetizationEntitlements = {
	PROFILES = table.freeze({
		NON_SPENDER = "NonSpender",
		AVATAR_VALUE_ONLY = "AvatarValueOnly",
		SPENT_ROBUX = "SpentRobux"
	})
}

-- equivalent calls inferred from this helper; original call sites unknown
local function wholeRobux(value: number?)
	if typeof(value) == "number" then
		return (math.max(math.floor(value), 0))
	end

	return 0
end

local function countedAttribute(instance, attributeName: string)
	strict2(instance)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) ~= "number" then
		attribute = nil
	end

	if typeof(attribute) == "number" then
		return (math.max(math.floor(attribute), 0))
	end

	return 0
end

local function switchedAttribute(instance, attributeName: string)
	strict2(instance)
	strict3(attributeName)
	return instance:GetAttribute(attributeName) == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function passHeld(p, p2: string)
	return typeof(p) == "table" and p[p2] == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function productHeld(p, p2: number)
	return typeof(p) == "table" and p[tostring(p2)] == true
end

function MonetizationEntitlements.NormalizeRobuxSpend(value: number?)
	if typeof(value) == "number" then
		return (math.max(math.floor(value), 0))
	end

	return 0
end

function MonetizationEntitlements.ProductPrice(p: number)
	strict(p)
	local v4 = price(p, Enum.InfoType.Product)

	if v4 == nil then
		return 0
	end

	if typeof(v4) == "number" then
		return (math.max(math.floor(v4), 0))
	end

	return 0
end

function MonetizationEntitlements.GamepassPrice(p: number)
	strict(p)
	local v4 = price(p, Enum.InfoType.GamePass)

	if v4 == nil then
		return 0
	end

	if typeof(v4) == "number" then
		return (math.max(math.floor(v4), 0))
	end

	return 0
end

function MonetizationEntitlements.MarketplacePrice(p: number, p2)
	strict(p)
	local current = Marketplace.Current(p, p2)

	if typeof(current) ~= "table" then
		return 0
	end

	local priceInRobux = current.PriceInRobux

	if typeof(priceInRobux) == "number" then
		return (math.max(math.floor(priceInRobux), 0))
	end

	return 0
end

function MonetizationEntitlements.AvatarAssetPrice(p: number)
	return MonetizationEntitlements.MarketplacePrice(p, Enum.InfoType.Asset)
end

function MonetizationEntitlements.AvatarBundlePrice(p: number)
	return MonetizationEntitlements.MarketplacePrice(p, Enum.InfoType.Bundle)
end

function MonetizationEntitlements.HasX2Money(p)
	return passHeld(p, x2Money.Name)
end

function MonetizationEntitlements.HasX2Growth(p)
	return passHeld(p, x2Growth.Name)
end

function MonetizationEntitlements.HasLucky(p)
	return passHeld(p, lucky.Name)
end

function MonetizationEntitlements.HasVipProduct(_)
	return false
end

function MonetizationEntitlements.PlayerHasX2Money(instance)
	strict2(instance)
	strict3("MonetizationX2MoneyGamepassOwned")
	return instance:GetAttribute("MonetizationX2MoneyGamepassOwned") == true
end

function MonetizationEntitlements.PlayerHasLucky(instance)
	strict2(instance)
	strict3("MonetizationLuckyGamepassOwned")
	return instance:GetAttribute("MonetizationLuckyGamepassOwned") == true
end

function MonetizationEntitlements.PlayerHasVipProduct(_)
	return false
end

function MonetizationEntitlements.SumOwnedRobuxSpend(p, p2, p3)
	local total = 0

	if typeof(p) == "table" then
		for _, v4 in pairs(Gamepasses.Directory) do
			if not (p3 and p3[`Pass:{v4.Name}`]) then
				total += not passHeld(p, v4.Name) and 0 or MonetizationEntitlements.GamepassPrice(v4.ProductId)
			end
		end
	end

	if typeof(p2) ~= "table" then
		return total
	end

	for _, v4 in pairs(Products.Directory) do
		if not (p3 and p3[`Product:{v4.ProductId}`]) then
			total += not productHeld(p2, v4.ProductId) and 0 or MonetizationEntitlements.ProductPrice(v4.ProductId)
		end
	end

	return total
end

function MonetizationEntitlements.EffectiveRobuxSpend(p, p2, value: number?, p3)
	local selected = wholeRobux(value) -- equivalent call inferred; original call site unknown

	if selected > 0 then
		return selected
	end

	return (MonetizationEntitlements.SumOwnedRobuxSpend(p, p2, p3))
end

function MonetizationEntitlements.IsSpender(value: number?)
	return wholeRobux(value) > 0
end

function MonetizationEntitlements.PlayerRobuxSpend(instance)
	strict2(instance)
	local monetizationRobuxSpentTotal = instance:GetAttribute("MonetizationRobuxSpentTotal")

	if typeof(monetizationRobuxSpentTotal) ~= "number" then
		monetizationRobuxSpentTotal = nil
	end

	if typeof(monetizationRobuxSpentTotal) == "number" then
		return (math.max(math.floor(monetizationRobuxSpentTotal), 0))
	end

	return 0
end

function MonetizationEntitlements.IsPlayerSpender(p)
	return MonetizationEntitlements.PlayerRobuxSpend(p) > 0
end

function MonetizationEntitlements.PlayerAvatarValue(instance)
	strict2(instance)
	local monetizationAvatarMarketplaceValue = instance:GetAttribute("MonetizationAvatarMarketplaceValue")

	if typeof(monetizationAvatarMarketplaceValue) ~= "number" then
		monetizationAvatarMarketplaceValue = nil
	end

	if typeof(monetizationAvatarMarketplaceValue) == "number" then
		return (math.max(math.floor(monetizationAvatarMarketplaceValue), 0))
	end

	return 0
end

function MonetizationEntitlements.PlayerHasAvatarValue(p)
	return MonetizationEntitlements.PlayerAvatarValue(p) > 0
end

function MonetizationEntitlements.SyncPlayerFlags(instance, p, p2, p3: number?, p4)
	strict2(instance)
	instance:SetAttribute("MonetizationX2MoneyGamepassOwned", passHeld(p, x2Money.Name))
	instance:SetAttribute("MonetizationLuckyGamepassOwned", passHeld(p, lucky.Name))
	instance:SetAttribute("MonetizationRobuxSpentTotal", MonetizationEntitlements.EffectiveRobuxSpend(p, p2, p3, p4))
end

function MonetizationEntitlements.SyncPlayerAvatarValue(instance, value: number?)
	strict2(instance)
	instance:SetAttribute("MonetizationAvatarMarketplaceValue", wholeRobux(value))
end

function MonetizationEntitlements.ProfileFor(value: number?, value2: number?)
	local PROFILES = MonetizationEntitlements.PROFILES

	if wholeRobux(value2) > 0 then
		return PROFILES.SPENT_ROBUX
	end

	if wholeRobux(value) > 0 then
		return PROFILES.AVATAR_VALUE_ONLY
	end

	return PROFILES.NON_SPENDER
end

function MonetizationEntitlements.PlayerProfile(p)
	strict2(p)
	local playerAvatarValue = MonetizationEntitlements.PlayerAvatarValue(p)
	return MonetizationEntitlements.ProfileFor(playerAvatarValue, MonetizationEntitlements.PlayerRobuxSpend(p))
end

function MonetizationEntitlements.PlayerMayTakeBackSteal(p)
	return MonetizationEntitlements.PlayerProfile(p) ~= MonetizationEntitlements.PROFILES.NON_SPENDER
end

function MonetizationEntitlements.AssetMoneyAdditiveBonus(p, _)
	if MonetizationEntitlements.HasX2Money(p) then
		return gamepassBenefits.X2_MONEY_BONUS
	end

	return 0
end

function MonetizationEntitlements.PlayerAssetMoneyAdditiveBonus(p)
	if MonetizationEntitlements.PlayerHasX2Money(p) then
		return gamepassBenefits.X2_MONEY_BONUS
	end

	return 0
end

function MonetizationEntitlements.GameplayBlockLuckPercent(p)
	if MonetizationEntitlements.HasLucky(p) then
		return gamepassBenefits.LUCKY_BLOCK_LUCK_PERCENT
	end

	return 0
end

function MonetizationEntitlements.PlayerGameplayBlockLuckPercent(p)
	if MonetizationEntitlements.PlayerHasLucky(p) then
		return gamepassBenefits.LUCKY_BLOCK_LUCK_PERCENT
	end

	return 0
end

function MonetizationEntitlements.FuseRarestWeightMultiplier(p)
	if MonetizationEntitlements.HasLucky(p) then
		return gamepassBenefits.LUCKY_FUSE_WEIGHT_BOOST
	end

	return 1
end

function MonetizationEntitlements.PlayerFuseRarestWeightMultiplier(p)
	if MonetizationEntitlements.PlayerHasLucky(p) then
		return gamepassBenefits.LUCKY_FUSE_WEIGHT_BOOST
	end

	return 1
end

function MonetizationEntitlements.OwnedGamepassesForPlayer(p)
	strict2(p)
	local playerHasX2Money = MonetizationEntitlements.PlayerHasX2Money(p)
	local playerHasLucky = MonetizationEntitlements.PlayerHasLucky(p)

	if playerHasX2Money and playerHasLucky then
		return frozen3
	end

	if playerHasX2Money then
		return frozen
	end

	if playerHasLucky then
		return frozen2
	end

	return nil
end

function MonetizationEntitlements.OwnedProductsForPlayer(p)
	strict2(p)
	return nil
end

return MonetizationEntitlements