local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local BossMasteryFlags = require(ReplicatedStorage.Shared.Flags.BossMasteryFlags)
require(ReplicatedStorage.Shared.Types.BossMastery)
local Currency = require(ReplicatedStorage.Data.Currency)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local Rift = require(ReplicatedStorage.Data.Rift)
local milestones = {
	{
		Id = "Mastery3",
		Kills = 3,
		RewardId = "RiftbornEgg"
	},
	{
		Id = "Mastery5",
		Kills = 5,
		RewardId = "TokenBoost"
	},
	{
		Id = "Mastery10",
		Kills = 10,
		RewardId = "RiftbeastsEgg"
	},
	{
		Id = "Mastery15",
		Kills = 15,
		RewardId = "MutatedRiftbornEgg"
	},
	{
		Id = "Mastery20",
		Kills = 20,
		RewardId = "RotationMutatedEgg"
	},
	{
		Id = "Mastery30",
		Kills = 30,
		RewardId = "RotationMutatedEgg"
	}
}
local v2 = {}
local v3 = {
	RiftbornEgg = {
		Id = "RiftbornEgg",
		DisplayName = "Riftborn Egg",
		Reward = {
			Kind = "RiftEgg",
			BannerId = "Verdant",
			Mutated = false
		}
	},
	RiftbeastsEgg = {
		Id = "RiftbeastsEgg",
		DisplayName = "Riftbeasts Egg",
		Reward = {
			Kind = "RiftEgg",
			BannerId = "Umbral",
			Mutated = false
		}
	},
	MutatedRiftbornEgg = {
		Id = "MutatedRiftbornEgg",
		DisplayName = "Mutated Riftborn Egg",
		Reward = {
			Kind = "RiftEgg",
			BannerId = "Verdant",
			Mutated = true
		}
	},
	RotationMutatedEgg = {
		Id = "RotationMutatedEgg",
		DisplayName = "Mutated Egg",
		Reward = {
			Kind = "RiftRotationEgg",
			Mutated = true
		}
	},
	TokenBoost = {
		Id = "TokenBoost",
		DisplayName = "Permanent Boss Token Boost",
		Reward = {
			Kind = "TokenBoost",
			Percent = 50
		}
	}
}

for _, v4 in milestones do
	v2[v4.Id] = v4
end

local shopProducts = {
	{
		Id = "CashBooster",
		DisplayName = "2x Cash Booster",
		Icon = "rbxassetid://119640363267627",
		Price = 175,
		Reward = {
			Kind = "CashBooster"
		}
	},
	{
		Id = "SpeedBoost",
		DisplayName = "1.25x Speed",
		Icon = "rbxassetid://78137530993637",
		Price = 225,
		Reward = {
			Kind = "SpeedBoost"
		}
	},
	{
		Id = "TreadmillBooster",
		DisplayName = "2x Treadmill Booster",
		Icon = "rbxassetid://107126944152347",
		Price = 200,
		Reward = {
			Kind = "TreadmillBoost"
		}
	},
	{
		Id = "MutationConsumable",
		DisplayName = "Mutation Consumable",
		Icon = "rbxassetid://74755693699202",
		Price = 400,
		Reward = {
			Kind = "MutationConsumable"
		}
	}
}
local v5 = {}

for _, v6 in shopProducts do
	v5[v6.Id] = v6
end

local v6 = {
	Verdant = 55,
	Umbral = 40,
	Radiant = 5
}
local v7 = {
	MutationId = "Boss",
	InfiniteMilestoneId = "Infinite",
	Milestones = milestones,
	ShopProducts = shopProducts
}

local function getRewardSpec(p: string)
	return v3[p]
end

function v7.GetMilestone(p: string)
	return v2[p]
end

function v7.FinalMilestone()
	return milestones[#milestones]
end

function v7.GetMilestoneKills(p)
	local v8 = BossMasteryFlags.MilestoneKillOverrides:Get()[p.Id]

	if v8 == nil then
		return p.Kills
	end

	return v8
end

function v7.GetMilestoneRewardId(p)
	local v8 = BossMasteryFlags.MilestoneRewardIdOverrides:Get()[p.Id]

	if v8 == nil or v3[v8] == nil then
		return p.RewardId
	end

	return v8
end

function v7.GetMilestoneReward(p)
	local v8 = v3[v7.GetMilestoneRewardId(p)]

	if not v8 then
		v8 = v3[p.RewardId]
	end

	assert(v8 ~= nil, (`Unknown Boss Mastery reward for {p.Id}`))
	return v8.Reward
end

function v7.GetInfiniteRewardId()
	local v8 = BossMasteryFlags.InfiniteRewardId:Get()
	local v9 = v3[v8]

	if v9 == nil or v9.Reward.Kind ~= "RiftEgg" and v9.Reward.Kind ~= "RiftRotationEgg" then
		return "RotationMutatedEgg"
	end

	return v8
end

function v7.GetInfiniteReward()
	local infiniteRewardId = v7.GetInfiniteRewardId()
	return assert(v3[infiniteRewardId], "Infinite Boss Mastery reward spec is missing").Reward
end

function v7.InfiniteRevealKey(p: number)
	return (`{v7.InfiniteMilestoneId}:{p}`)
end

function v7.GetTokenBoostPercent(p)
	local milestoneReward = v7.GetMilestoneReward(p)

	if milestoneReward.Kind ~= "TokenBoost" then
		return 0
	end

	local v8 = BossMasteryFlags.TokenBoostPercentOverrides:Get()[p.Id]

	if v8 == nil then
		return milestoneReward.Percent
	end

	return v8
end

function v7.GetShopProduct(p: string)
	return v5[p]
end

function v7.GetShopProducts()
	local v8 = {}
	local result = {}

	for _, v9 in BossMasteryFlags.ShopProductIds:Get() do
		local v10 = v5[v9]

		if v10 == nil or v8[v9] then
			continue
		end

		v8[v9] = true
		table.insert(result, v10)
	end

	return result
end

function v7.IsShopProductListed(p: string)
	for _, v8 in v7.GetShopProducts() do
		if v8.Id == p then
			return true
		end
	end

	return false
end

function v7.GetShopPrice(p)
	local v8 = BossMasteryFlags.ShopPriceOverrides:Get()[p.Id]

	if v8 == nil then
		return p.Price
	end

	return v8
end

function v7.GetShopDisplayName(p)
	local reward = p.Reward

	if reward.Kind == "CashBooster" then
		return (`{BossMasteryFlags.CashBoosterMultiplier:Get()}x Cash Booster`)
	end

	if reward.Kind == "SpeedBoost" then
		return (`{BossMasteryFlags.SpeedBoostMultiplier:Get()}x Speed`)
	end

	if reward.Kind == "TreadmillBoost" then
		return (`{BossMasteryFlags.TreadmillBoostMultiplier:Get()}x Treadmill Booster`)
	end

	return p.DisplayName
end

function v7.GetShopQuantity(p)
	if p.Reward.Kind == "Traps" then
		return BossMasteryFlags.TrapsPerPurchase:Get()
	end

	return 1
end

function v7.GetShopQuantityText(p)
	local reward = p.Reward

	if reward.Kind == "CashBooster" then
		return (`{math.max(math.floor(BossMasteryFlags.CashBoosterDurationSeconds:Get() / 60), 0)}m`)
	end

	if reward.Kind == "SpeedBoost" then
		return (`{math.max(math.floor(BossMasteryFlags.SpeedBoostDurationSeconds:Get() / 60), 0)}m`)
	end

	if reward.Kind == "TreadmillBoost" then
		return (`{math.max(math.floor(BossMasteryFlags.TreadmillBoostDurationSeconds:Get() / 60), 0)}m`)
	end

	if reward.Kind == "MutationConsumable" then
		return (`{BossMasteryFlags.MutationConsumableSuccessPercent:Get()}%`)
	end

	return (`x{v7.GetShopQuantity(p)}`)
end

function v7.RewardNeedsReveal(p)
	return p.Kind == "RiftEgg" or p.Kind == "RiftRotationEgg"
end

function v7.GetRotationBannerWeights()
	local v8 = BossMasteryFlags.InfiniteBannerWeights:Get()
	local clone = table.clone(v6)

	for k, v9 in v8 do
		if Rift.GetBanner(k) ~= nil then
			clone[k] = v9
		end
	end

	return clone
end

function v7.RollBannerId(object)
	local rotationBannerWeights = v7.GetRotationBannerWeights()
	local total = 0

	for _, rotationBannerWeight in rotationBannerWeights do
		if rotationBannerWeight > 0 then
			total += rotationBannerWeight
		end
	end

	if total <= 0 then
		return nil
	end

	local v8 = object:NextNumber() * total
	local total2 = 0
	local v9 = nil

	for k, rotationBannerWeight in rotationBannerWeights do
		if rotationBannerWeight <= 0 then
			continue
		end

		total2 += rotationBannerWeight

		if v8 <= total2 then
			return k
		else
			v9 = k
		end
	end

	return v9
end

function v7.RollReveal(p, p2)
	local bannerId

	if p.Kind == "RiftEgg" then
		bannerId = p.BannerId
	else
		if p.Kind ~= "RiftRotationEgg" then
			return nil
		end

		bannerId = v7.RollBannerId(p2)

		if bannerId == nil then
			return nil
		end
	end

	local rollPet = Rift.RollPet(bannerId, p2)

	if rollPet == nil then
		return nil
	end

	return {
		BannerId = bannerId,
		AssetId = rollPet
	}
end

function v7.FillMissingReveals(data, p)
	local clone = table.clone(data.RevealedRewards or {})
	local v8 = false

	local function ensure(p2: string, p3)
		local v9 = clone[p2]

		if v9 ~= nil then
			if (p3.Kind ~= "RiftEgg" or v9.BannerId == p3.BannerId) and Assets.Directory[v9.AssetId] ~= nil and Rift.BannerContainsPet(
				v9.BannerId,
				v9.AssetId
			) then
				return
			end

			clone[p2] = nil
			v8 = true
		end

		local rollReveal = v7.RollReveal(p3, p)

		if rollReveal == nil then
			return
		end

		clone[p2] = rollReveal
		v8 = true
	end

	for _, v9 in milestones do
		if not data.ClaimedMilestoneIds[v9.Id] then
			ensure(v9.Id, v7.GetMilestoneReward(v9))
		end
	end

	local claimableInfiniteCount = v7.ClaimableInfiniteCount(data)
	local infiniteReward = v7.GetInfiniteReward()

	if data.ClaimedMilestoneIds[v7.FinalMilestone().Id] then
		local v9 = math.max(claimableInfiniteCount, 1)

		for i = data.InfiniteRewardsClaimed + 1, data.InfiniteRewardsClaimed + v9 do
			ensure(v7.InfiniteRevealKey(i), infiniteReward)
		end
	end

	if not v8 then
		return data
	end

	local clone2 = table.clone(data)
	clone2.RevealedRewards = clone
	return clone2
end

function v7.TokenBoostMultiplierFor(items)
	local total = 0

	for k, item in items do
		local v8 = BossMasteryFlags.TokenBoostPercentOverrides:Get()[k]

		if v8 ~= nil then
			item = v8
		end

		total += item
	end

	return total / 100 + 1
end

function v7.NextMilestoneFor(p: number)
	for _, v8 in milestones do
		if p < v7.GetMilestoneKills(v8) then
			return v8
		end
	end

	return nil
end

function v7.ClaimableInfiniteCount(data)
	local finalMilestone = v7.FinalMilestone()

	if not data.ClaimedMilestoneIds[finalMilestone.Id] then
		return 0
	end

	local v8 = BossMasteryFlags.InfiniteRewardEveryKills:Get()
	return (math.max(
		math.max((data.Mastery - v7.GetMilestoneKills(finalMilestone)) // v8, 0) - data.InfiniteRewardsClaimed,
		0
	))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bossEggIcon()
	local boss = Mutations.Get("Boss")

	if boss == nil or boss.EggIcon == nil then
		return "rbxassetid://121553987798547"
	end

	return boss.EggIcon
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tokenBoostPresentation(p: number)
	return {
		Title = "Permanent Token Boost",
		Icon = assert(Currency.Directory.BossTokens.Icon, "Boss Tokens icon is missing"),
		Amount = `+{p}%`,
		HoverTitle = "BOSS TOKEN BOOST",
		HoverDescription = `Earn +{p}% Boss Tokens from boss kills`
	}
end

local function rotationEggIcons()
	local rotationBannerWeights = v7.GetRotationBannerWeights()
	local bannerEggIcons = {}

	for _, banner in Rift.Banners do
		if (rotationBannerWeights[banner.Id] or 0) <= 0 then
			continue
		end

		local bannerEggIcon = Rift.GetBannerEggIcon(banner.Id)

		if bannerEggIcon ~= nil then
			table.insert(bannerEggIcons, bannerEggIcon)
		end
	end

	return bannerEggIcons
end

function v7.GetRewardPresentation(data, _, value: number?)
	if data.Kind == "TokenBoost" then
		return tokenBoostPresentation(data.Percent)
	end

	local formatted = `x{value or 1}`

	if data.Kind == "RiftEgg" then
		local bannerDisplayName = Rift.GetBannerDisplayName(data.BannerId)
		local title

		if data.Mutated then
			title = `Mutated {bannerDisplayName} Egg`
		else
			title = `{bannerDisplayName} Egg`
		end

		local bannerEggIcon = Rift.GetBannerEggIcon(data.BannerId)

		if not bannerEggIcon then
			bannerEggIcon = bossEggIcon()
		end

		local v10

		if data.Mutated then
			v10 = `MUTATED {bannerDisplayName} EGG`
		else
			v10 = `{bannerDisplayName} EGG`
		end

		local v8 = {
			Title = title,
			Icon = bannerEggIcon,
			Amount = formatted,
			HoverTitle = string.upper(v10),
			HoverDescription = 0
		}
		local hoverDescription

		if data.Mutated then
			hoverDescription = `Awards a {bannerDisplayName} Egg with the Fractured mutation`
		else
			hoverDescription = `Awards a {bannerDisplayName} Egg`
		end

		v8.HoverDescription = hoverDescription
		return v8
	elseif data.Kind == "RiftRotationEgg" then
		local cycleIcons = rotationEggIcons()
		local icon = cycleIcons[1]

		if not icon then
			icon = bossEggIcon()
		end

		return {
			Title = "Random Mutated Egg",
			Icon = icon,
			CycleIcons = cycleIcons,
			Amount = formatted,
			HoverTitle = "MUTATED EGG",
			HoverDescription = "Awards a random egg with the Fractured mutation"
		}
	else
		local v8 = v5[data.Kind == "CashBooster" and "CashBooster" or data.Kind == "SpeedBoost" and "SpeedBoost" or data.Kind == "TreadmillBoost" and "TreadmillBooster" or "MutationConsumable"]
		local v9 = {
			Title = not v8 and "Reward" or v7.GetShopDisplayName(v8),
			Icon = 0,
			Amount = 0
		}
		local icon

		if v8 then
			icon = v8.Icon
		else
			icon = bossEggIcon()
		end

		v9.Icon = icon
		v9.Amount = formatted
		return v9
	end
end

function v7.GetMilestonePresentation(p, p2, p3: number?)
	local milestoneReward = v7.GetMilestoneReward(p)

	if milestoneReward.Kind ~= "TokenBoost" then
		return v7.GetRewardPresentation(milestoneReward, p2, p3)
	end

	return tokenBoostPresentation(v7.GetTokenBoostPercent(p))
end

return table.freeze(v7)