local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)

local function hasReward(object, main)
	if main.Type == "Sword" then
		return object:Find("SwordSkins.Unlocked", main.Value) ~= nil
	end

	if main.Type == "Explosion" then
		return object:Find("ExplosionSkins.Unlocked", main.Value) ~= nil
	end

	if main.Type == "Emote" then
		return object:Get({ "Emotes", "Unlocked", main.Value }) ~= nil
	end

	if main.Type ~= "Ability" then
		return false
	end

	local v2 = object:Get({ "Trials", "Abilities", main.Value })

	if v2 and math.max(0, v2 - workspace:GetServerTimeNow()) > 0 then
		return false
	end

	return object:Find("Abilities.Unlocked", main.Value) ~= nil
end

local v2 = require3(ReplicatedStorage2.ServerInfo).isTestGame() and 100 or 1
return {
	FreePrice = 150,
	DuplicatedRewards = v.createBunnyCurrencyReward(40),
	Products = {
		[1] = {
			ProductId = 1789229059,
			GiftName = "1 Easter Egg"
		},
		[10] = {
			ProductId = 1789229057,
			GiftName = "10 Easter Eggs"
		}
	},
	Rewards = {
		[v.createCrateKeyReward("PremiumExplosion", 1, "Premium Explosion Crate")] = 13,
		[v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate")] = 7,
		[v.createWheelSpinReward(1)] = 16,
		[v.createBunnyCurrencyReward(200)] = 10.36,
		[v.createExplosionReward("Sigil Burst")] = 5,
		[v.createEmoteReward("Thinker")] = 2,
		[v.createGachaSpinsReward(3)] = 1,
		[v.createBunnyCurrencyReward(150)] = 10,
		[v.createBunnyCurrencyReward(50)] = 15,
		[v.createEmoteReward("Keep Moving")] = 10,
		[{
			Type = "GoldenReward",
			Main = v.createSwordReward("Golden Rapier")
		}] = v2 * 0.12,
		[{
			Type = "GoldenReward",
			Main = v.createGachaSpinsReward(3)
		}] = v2 * 0.5,
		[{
			Type = "GoldenReward",
			Main = v.createSwordReward("Diamond Starblade")
		}] = v2 * 0.02
	},
	GetRewards = function(object, items, flag: boolean?)
		local clone = table.clone(items)

		for k, item in items do
			if k.Type ~= "GoldenReward" then
				continue
			end

			if flag then
				local reward = hasReward(object, k.Main)
				local clone2 = table.clone(k)
				clone[k] = nil

				if (not reward or not k.Fallback or k.Fallback.Type ~= "RabbitToken" or not (object:Get("BunnyLeapUpgrade") or (object:Get({
					"AbilityUpgrades",
					"Bunny Leap"
				}) or 0) > 0)) and (not reward or k.Fallback) then
					local targetReward

					if reward and k.Fallback then
						targetReward = k.Fallback
					else
						targetReward = k.Main
					end

					clone2.TargetReward = targetReward
					clone[clone2] = item
				end
			else
				clone[k] = nil
				local reward = hasReward(object, k.Main)

				if reward and k.Fallback then
					clone[k.Fallback] = item
				elseif not reward then
					clone[k.Main] = item
				end
			end
		end

		return clone
	end
}