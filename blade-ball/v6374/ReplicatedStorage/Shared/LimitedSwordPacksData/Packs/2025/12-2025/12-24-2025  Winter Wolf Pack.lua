local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.Common.Utils)
require3(script:FindFirstAncestor("Packs").Parent.Types)
return {
	{
		RootFFlagStartTime = "WinterWolfRootStartTime",
		RootFFlagEndTime = "WinterWolfRootEndTime",
		FFlagStartTime = "WinterWolfStartTime",
		FFlagEndTime = "WinterWolfEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Winter Wolf",
				Image = "rbxassetid://118727063898028",
				ShowRoom = "WinterWolfShowRoom",
				TemplateType = "Bundle",
				Stock = "Winter Wolf",
				Rewards = {
					{
						Stock = "Winter Wolf",
						GiftName = "Winter Wolf",
						GiftId = 3488878649,
						Item = v.createListReward({
							v.createSwordReward("Winter Wolf"),
							v.createExplosionReward("Winter Wolf Explosion"),
							v.createEmoteReward("Emote1116")
						}),
						ProductId = 3488878648
					},
					{
						Stock = "Winter Wolf Mount",
						GiftName = "Winter Wolf Mount",
						GiftId = 3488878650,
						Item = v.createListReward({
							v.createSwordReward("Winter Wolf"),
							v.createSwordAccessoryReward("Winter Wolf"),
							v.createExplosionReward("Winter Wolf Explosion"),
							v.createEmoteReward("Emote1116")
						}),
						ProductId = 3488878656
					}
				}
			}
		}
	}
}