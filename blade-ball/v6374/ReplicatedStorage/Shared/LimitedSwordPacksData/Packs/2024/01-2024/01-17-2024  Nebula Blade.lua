local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Common.Utils)
require3(script:FindFirstAncestor("Packs").Parent.Types)
return {
	{
		FFlagStartTime = "NebulaPackStartTime",
		FFlagEndTime = "NebulaPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Nebula Blade",
				Image = v2.Icons:GetSwordIcon("Dual Nebula Blade"),
				ShowRoom = "NebulaBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Nebula Blade",
						Item = v.createListReward({ v.createSwordReward("Nebula Blade") }),
						ProductId = 1730800275,
						DiscountedFrom = 499
					},
					{
						GiftName = "Dual Nebula Blade + Nebula Explosion",
						Item = v.createListReward({
							v.createSwordReward("Dual Nebula Blade"),
							v.createExplosionReward("Nebulas Explosion")
						}),
						ProductId = 1730801386,
						DiscountedFrom = 1299
					}
				}
			}
		}
	}
}