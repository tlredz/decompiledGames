local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(script:FindFirstAncestor("Packs").Parent.Types)
return {
	{
		RootFFlagStartTime = "SwanSerenityStartTime",
		RootFFlagEndTime = "SwanSerenityEndTime",
		FFlagStartTime = "SwanSerenityStartTime",
		FFlagEndTime = "SwanSerenityEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Swan Serenity",
				Image = "rbxassetid://120635066819255",
				ShowRoom = "SwanSerenityShowRoom",
				TemplateType = "Bundle",
				Stock = "Swan Serenity",
				Rewards = {
					{
						GiftName = "Swan Serenity",
						GiftId = 3716289611,
						Item = v.createListReward({
							v.createSwordReward("Swan Serenity"),
							v.createExplosionReward("Swan of Love Explosion"),
							v.createEmoteReward("Emote1286")
						}),
						ProductId = 3716289616
					}
				}
			}
		}
	}
}