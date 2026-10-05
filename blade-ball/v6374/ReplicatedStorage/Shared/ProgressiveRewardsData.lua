local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Shared.WeightRandom)
local v3 = require3(ReplicatedStorage2.Packages.Freeze)
local v4 = require3(ReplicatedStorage2.Shared.Inventory)
local rewardsList = {
	Free = {
		{
			Reward = v.createSwordReward("Eternal Spark"),
			Chance = 36.9495
		},
		{
			Reward = v.createCoinsReward(250, "Small"),
			Chance = 30
		},
		{
			Reward = v.createCoinsReward(500, "Small"),
			Chance = 10
		},
		{
			Reward = v.createWheelSpinReward(1),
			Chance = 5
		},
		{
			Reward = v.createEmoteReward("Radiant Shield"),
			Chance = 6
		},
		{
			Reward = v.createGachaSpinsReward(1),
			Chance = 3
		},
		{
			Reward = v.createSwordReward("Chrono Katana"),
			Chance = 2
		},
		{
			Reward = v.createBattlepassExplosionCrateReward(1),
			Chance = 7
		},
		{
			Reward = v.createSwordReward("Lunar Aegis"),
			Chance = 0.05
		},
		{
			Reward = v.createAbilityReward("Infinity"),
			Chance = 0.0005
		}
	},
	Robux_49 = {
		{
			Reward = v.createEmoteReward("Stellar Step"),
			Chance = 34.999
		},
		{
			Reward = v.createGachaSpinsReward(2),
			Chance = 25
		},
		{
			Reward = v.createSeasonPassCurrencyReward(500),
			Chance = 15
		},
		{
			Reward = v.createCoinsReward(1000, "Med"),
			Chance = 15
		},
		{
			Reward = v.createWheelSpinReward(3),
			Chance = 5
		},
		{
			Reward = v.createSwordReward("Noob"),
			Chance = 0.0005
		},
		{
			Reward = v.createBattlepassExplosionCrateReward(1),
			Chance = 5
		},
		{
			Reward = v.createAbilityReward("Infinity"),
			Chance = 0.0005
		}
	},
	Robux_99 = {
		{
			Reward = v.createCoinsReward(2500, "Med"),
			Chance = 29.9495
		},
		{
			Reward = v.createSwordReward("Solar Flare Blade"),
			Chance = 20
		},
		{
			Reward = v.createGachaSpinsReward(3),
			Chance = 25
		},
		{
			Reward = v.createSeasonPassCurrencyReward(1000),
			Chance = 20
		},
		{
			Reward = v.createBattlepassExplosionCrateReward(3),
			Chance = 5
		},
		{
			Reward = v.createSwordReward("Noob"),
			Chance = 0.0005
		},
		{
			Reward = v.createAbilityReward("Infinity"),
			Chance = 0.05
		}
	},
	Robux_199 = {
		{
			Reward = v.createEmoteReward("Orbital Dance"),
			Chance = 33
		},
		{
			Reward = v.createGachaSpinsReward(5),
			Chance = 33.9
		},
		{
			Reward = v.createSeasonPassCurrencyReward(2000),
			Chance = 33
		},
		{
			Reward = v.createAbilityReward("Infinity"),
			Chance = 0.1
		}
	},
	Robux_349 = {
		{
			Reward = v.createSwordReward("Starlight Spear"),
			Chance = 33
		},
		{
			Reward = v.createGachaSpinsReward(7),
			Chance = 33.76
		},
		{
			Reward = v.createSeasonPassCurrencyReward(5000),
			Chance = 33
		},
		{
			Reward = v.createAbilityReward("Infinity"),
			Chance = 0.24
		}
	},
	Robux_499 = {
		{
			Reward = v.createSwordReward("Golden Fang"),
			Chance = 33
		},
		{
			Reward = v.createGachaSpinsReward(10),
			Chance = 33.6
		},
		{
			Reward = v.createExplosionReward("Celestial Ascend"),
			Chance = 33
		},
		{
			DependsOn = v.createSwordReward("Golden Fang"),
			Reward = v.createSwordReward("Dual Golden Fang"),
			Chance = 33
		},
		{
			Reward = v.createAbilityReward("Infinity"),
			Chance = 0.4
		}
	},
	Robux_999 = {
		{
			Reward = v.createSwordReward("Golden Scythe"),
			Chance = 33
		},
		{
			Reward = v.createGachaSpinsReward(25),
			Chance = 33.5
		},
		{
			Reward = v.createExplosionReward("Ball Drop"),
			Chance = 33
		},
		{
			Reward = v.createAbilityReward("Infinity"),
			Chance = 0.5
		}
	}
}
local ProgressiveRewardsData = {
	Rewards = {
		"Free",
		"Robux_49",
		"Free",
		"Free",
		"Robux_49",
		"Robux_49",
		"Robux_49",
		"Robux_49",
		"Robux_49",
		"Robux_49",
		"Robux_49",
		"Robux_49",
		"Robux_49",
		"Robux_49",
		"Robux_49",
		"Robux_99",
		"Robux_99",
		"Robux_99",
		"Robux_99",
		"Robux_99",
		"Robux_99",
		"Robux_99",
		"Robux_99",
		"Robux_99",
		"Robux_99",
		"Robux_199",
		"Robux_199",
		"Robux_199",
		"Robux_199",
		"Robux_199",
		"Robux_199",
		"Robux_199",
		"Robux_199",
		"Robux_199",
		"Robux_199",
		"Robux_199",
		"Robux_199",
		"Robux_199",
		"Robux_199",
		"Robux_199",
		"Robux_349",
		"Robux_349",
		"Robux_349",
		"Robux_349",
		"Robux_349",
		"Robux_349",
		"Robux_349",
		"Robux_349",
		"Robux_349",
		"Robux_349",
		"Robux_349",
		"Robux_349",
		"Robux_349",
		"Robux_349",
		"Robux_349",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499",
		"Robux_499"
	},
	ProductIds = {
		Robux_49 = 1873216704,
		Robux_99 = 1873216703,
		Robux_199 = 1873216707,
		Robux_349 = 1873216708,
		Robux_499 = 1873216706,
		Robux_999 = 1873216705
	},
	MaxFreeItemsInARow = 3,
	ResetTime = 259200,
	RewardsList = rewardsList,
	Version = 2
}
v3.Dictionary.keys(rewardsList)

local function getNextRewardIndex(clone)
	local count = #clone

	if clone[count].Type ~= "Free" then
		return "Free"
	end

	local count2 = 0

	for i = count, math.max(1, count - ProgressiveRewardsData.MaxFreeItemsInARow + 1), -1 do
		if clone[i].Type ~= "Free" then
			break
		end

		count2 += 1
	end

	local v6 = ProgressiveRewardsData.Rewards[count + 1] or "Robux_999"

	if count2 < ProgressiveRewardsData.MaxFreeItemsInARow then
		return math.random() > 0.35 and "Free" or v6, true
	end

	return v6
end

function ProgressiveRewardsData.getRewardList(object, p, p2: string)
	local v6 = v4.Server:GetInventoryVersion(object.ReplicateTo) == "Old"
	local result = {}
	local total = 0
	local flag = false

	for k, v7 in rewardsList[p2] do
		local reward = v7.Reward
		local v8

		if v6 and (reward.Type == "Emote" or reward.Type == "Sword" or reward.Type == "Booth" or reward.Type == "Explosion") or reward.Type == "Ability" then
			local items = v4.Server:FindItems(object.ReplicateTo, reward.Type, reward.Value)
			local v9 = k
			local v10 = v3.List.find(p, function(p3)
				return p3.Index == v9 and p3.Type == p2
			end)
			v8 = #items > 0 or v10 ~= nil
		else
			v8 = false
		end

		if v7.DependsOn and #v4.Server:FindItems(object.ReplicateTo, v7.DependsOn.Type, v7.DependsOn.Value) <= 0 or v8 then
			flag = true
		else
			local chance = v7.Chance

			if p2 == "Free" and v7.Reward.Type == "Ability" and v7.Reward.Value == "Infinity" then
				local v9 = #(object:Get("ProgressiveRewards.Claimed") or {}) + 1
				local reward2 = ProgressiveRewardsData.Rewards[v9]

				if reward2 then
					for _, v11 in rewardsList[reward2] do
						if not (v11.Reward.Type == v7.Reward.Type and v11.Reward.Value == v7.Reward.Value) then
							continue
						end

						chance = v11.Chance
						break
					end
				end
			end

			result[tostring(k)] = chance
			total += chance
		end
	end

	if flag then
		for k, v7 in result do
			result[k] = v7 / total * 100
		end
	end

	return result
end

function ProgressiveRewardsData.getRewardsFor(object, value: number?, flag: boolean?)
	local progressiveRewards = object:Get("ProgressiveRewards")

	if not progressiveRewards then
		return
	end

	local result = {}

	if flag or v3.isEmpty(progressiveRewards.Rewards) then
		for i = 1, 5 do
			local reward = ProgressiveRewardsData.Rewards[i]
			local rewardList = ProgressiveRewardsData.getRewardList(object, result, reward)
			table.insert(result, {
				Type = reward,
				Index = assert((tonumber((v2.getPicker(rewardList)()))))
			})
		end

		return result
	else
		local clone = table.clone(progressiveRewards.Rewards)
		local v6 = value or 4

		if v6 == 0 then
			return clone
		end

		local result2 = {}

		for _ = 1, v6 do
			local nextRewardIndex, v7 = getNextRewardIndex(clone)
			local rewardList = ProgressiveRewardsData.getRewardList(object, clone, nextRewardIndex)

			if v3.isEmpty(rewardList) and v7 then
				rewardList = ProgressiveRewardsData.getRewardList(object, clone, "Free")
			end

			local v8 = v2.getPicker(rewardList)()

			if v8 == nil then
				warn((`!!!FAILED TO FIND ANY VALID ITEMS FOR {nextRewardIndex}!!!`))
			end

			local v9 = {
				Type = nextRewardIndex,
				Index = assert((tonumber(v8)))
			}
			table.insert(clone, v9)
			table.insert(result2, v9)
		end

		return result2
	end
end

return ProgressiveRewardsData