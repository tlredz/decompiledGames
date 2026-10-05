local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local Currency = require(ReplicatedStorage.Data.Currency)
local directory = Currency.Directory
local Gears = require(ReplicatedStorage.Data.Gears)
local directory2 = Gears.Directory
local MonsterParasite = require(ReplicatedStorage.Data.MonsterParasite)
local MonsterParasite2 = require(ReplicatedStorage.Shared.Types.MonsterParasite)
local Rarity = require(ReplicatedStorage.Data.Rarity)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local t = require(ReplicatedStorage.Packages.t)
local intersection = t.intersection(t.string, function(list)
	return #list > 0
end)
local intersection2 = t.intersection(t.integer, t.numberPositive)
local NotificationItem = {
	Schema = t.union(t.strictInterface({
		Kind = t.literal("Currency"),
		Id = intersection,
		Amount = intersection2
	}), t.strictInterface({
		Kind = t.literal("Gear"),
		Id = intersection,
		Amount = intersection2
	}), t.strictInterface({
		Kind = t.literal("SpeedPower"),
		Amount = intersection2
	}), t.strictInterface({
		Kind = t.literal("TemporarySpeedBoost"),
		Amount = intersection2
	}), t.strictInterface({
		Kind = t.literal("MonsterChestReward"),
		Id = intersection,
		Amount = intersection2
	}), t.strictInterface({
		Kind = t.literal("Egg"),
		Id = intersection,
		Amount = intersection2,
		Mutation = t.optional(intersection)
	}))
}
local v = {
	[MonsterParasite2.RewardIds.MonsterEgg] = "Prismatic"
}
local v2 = {
	[250000] = "rbxassetid://119640363267627",
	[1000000] = "rbxassetid://119640363267627",
	[5000000] = "rbxassetid://119640363267627"
}

local function currencyIcon(p, amount: number)
	local icon = p.Icon or ""
	local v3 = 0

	for k, v4 in pairs(v2) do
		if not (k <= amount and v3 < k) then
			continue
		end

		icon = v4
		v3 = k
	end

	return icon
end

function NotificationItem.Describe(data)
	assert(NotificationItem.Schema(data), "invalid notification item")

	if data.Kind == "Currency" then
		local v3 = assert(directory[data.Id], (`unknown currency notification id: {data.Id}`))
		return {
			Name = v3.DisplayName or "",
			Description = v3.Desc or "",
			Icon = currencyIcon(v3, data.Amount),
			Rarity = v3.Rarity or Rarity.Rarities.Rare
		}
	end

	if data.Kind == "Gear" then
		local v3 = assert(directory2[data.Id], (`unknown gear notification id: {data.Id}`))
		return {
			Name = v3.DisplayName or "",
			Description = v3.Description or "",
			Icon = v3.Icon or "",
			Rarity = Rarity.Rarities[v3.Rarity] or Rarity.Rarities.Common
		}
	end

	if data.Kind == "Egg" then
		local v3 = assert(Assets.Directory[data.Id], (`unknown egg notification id: {data.Id}`))
		local displayName = v3.Egg.DisplayName or ""

		if data.Mutation ~= nil then
			displayName = `{data.Mutation} {displayName}`
		end

		local icon

		if v3.Egg.Icon == "" then
			icon = Assets.BaseConfig.Egg.Icon
		else
			icon = v3.Egg.Icon
		end

		return {
			Name = displayName,
			Description = "",
			Icon = icon,
			Rarity = v3.Rarity
		}
	else
		if data.Kind == "TemporarySpeedBoost" then
			local v3 = math.max(math.floor(data.Amount / 60 + 0.5), 1)
			return {
				Name = `x{TreadmillUtil.GetTemporarySpeedBoostMultiplier()} Speed Boost`,
				Description = `{v3} MINUTES`,
				Icon = "rbxassetid://78137530993637",
				Rarity = Rarity.Rarities.Rare
			}
		end

		if data.Kind ~= "MonsterChestReward" then
			return {
				Name = "Speed Power",
				Description = "SPEED",
				Icon = "rbxassetid://78137530993637",
				Rarity = Rarity.Rarities.Rare
			}
		end

		local reward = MonsterParasite.GetReward(data.Id)
		local v3 = v[data.Id] or reward.Rarity
		return {
			Name = reward.DisplayName,
			Description = reward.DisplayNote or "",
			Icon = reward.Icon or "rbxassetid://78137530993637",
			Rarity = Rarity.Rarities[v3] or Rarity.Rarities.Common
		}
	end
end

return NotificationItem