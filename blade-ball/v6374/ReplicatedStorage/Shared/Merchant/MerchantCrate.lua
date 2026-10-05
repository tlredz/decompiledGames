local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local MerchantCrate = {
	Robux = {
		{
			Reward = v.createExplosionReward("Witch's Fury"),
			Chance = 35,
			ChanceColor = Color3.fromRGB(20, 255, 235)
		},
		{
			Reward = v.createEmoteReward("Phantom Flight"),
			Chance = 30,
			ChanceColor = Color3.fromRGB(20, 255, 235)
		},
		{
			Reward = v.createSwordReward("Nightmare's Slash"),
			Chance = 25.5,
			ChanceColor = Color3.fromRGB(20, 255, 235)
		},
		{
			Reward = v.createSwordReward("Skullsplitter"),
			Chance = 9,
			ChanceColor = Color3.fromRGB(255, 204, 20)
		},
		{
			Reward = v.createSwordReward("Headless Horror"),
			Chance = 0.5,
			ChanceColor = Color3.fromRGB(255, 20, 20)
		}
	},
	Coin = {
		{
			Reward = v.createExplosionReward("Cursed Ashes"),
			Chance = 36,
			ChanceColor = Color3.fromRGB(20, 255, 235)
		},
		{
			Reward = v.createEmoteReward("Spectral Possession"),
			Chance = 33,
			ChanceColor = Color3.fromRGB(20, 255, 235)
		},
		{
			Reward = v.createSwordReward("Hollow Blade"),
			Chance = 25.9,
			ChanceColor = Color3.fromRGB(20, 255, 235)
		},
		{
			Reward = v.createSwordReward("Nightshade"),
			Chance = 5,
			ChanceColor = Color3.fromRGB(255, 204, 20)
		},
		{
			Reward = v.createSwordReward("Headless Horror"),
			Chance = 0.1,
			ChanceColor = Color3.fromRGB(255, 20, 20)
		}
	}
}

for _, list in pairs(MerchantCrate) do
	local total = 0

	for _, v2 in ipairs(list) do
		total += v2.Chance
	end

	if total ~= 100 and RunService:IsStudio() then
		warn((`{list} MerchantCrate odds do not add up to 100%: {total}`))
	end
end

return MerchantCrate