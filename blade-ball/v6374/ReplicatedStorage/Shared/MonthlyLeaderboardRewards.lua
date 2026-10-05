local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	["2025-6"] = {
		{
			Rank = 25,
			Reward = v.createCustomReward("Corrupted Kunais")
		},
		{
			Rank = 100,
			Reward = v.createCustomReward("Light Sword")
		},
		{
			Rank = 500,
			Reward = v.createCustomReward("Serated Blade")
		},
		{
			Rank = 1000,
			Reward = v.createCustomReward("Crimson Slasher")
		}
	},
	["2025-5"] = {
		{
			Rank = 25,
			Reward = v.createCustomReward("Bronze Staff", "rbxassetid://136105724967879")
		},
		{
			Rank = 100,
			Reward = v.createCustomReward("Null Riftblade", "rbxassetid://125587207167852")
		},
		{
			Rank = 500,
			Reward = v.createCustomReward("Blossoming Edge", "rbxassetid://118469730871179")
		},
		{
			Rank = 1000,
			Reward = v.createCustomReward("Entangled Axe", "rbxassetid://109697312771522")
		}
	},
	["2025-4"] = {
		{
			Rank = 25,
			Reward = v.createSwordReward("Amethyst Blade")
		},
		{
			Rank = 100,
			Reward = v.createSwordReward("Teal Longsword")
		},
		{
			Rank = 500,
			Reward = v.createSwordReward("Ice Mage Staff")
		},
		{
			Rank = 1000,
			Reward = v.createExplosionReward("Firenado")
		}
	},
	["2025-3"] = {
		{
			Rank = 25,
			Reward = v.createSwordReward("Chroma Shortaxe")
		},
		{
			Rank = 100,
			Reward = v.createSwordReward("Opal Staff")
		},
		{
			Rank = 500,
			Reward = v.createSwordReward("Amethyst Dagger")
		},
		{
			Rank = 1000,
			Reward = v.createExplosionReward("Warriors Enchantment")
		}
	}
}