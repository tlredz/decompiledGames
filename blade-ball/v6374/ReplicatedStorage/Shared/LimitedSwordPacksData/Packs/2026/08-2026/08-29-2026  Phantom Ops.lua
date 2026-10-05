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
		RootFFlagStartTime = "PhantomOpsStartTime",
		RootFFlagEndTime = "PhantomOpsEndTime",
		FFlagStartTime = "PhantomOpsStartTime",
		FFlagEndTime = "PhantomOpsEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Phantom Ops",
				Image = "rbxassetid://113241515177799",
				ShowRoom = "PhantomOpsShowRoom",
				TemplateType = "Bundle",
				Stock = "Phantom Ops",
				Rewards = {
					{
						GiftName = "Phantom Ops",
						GiftId = 3710423874,
						Item = v.createListReward({
							v.createSwordReward("Phantom Ops"),
							v.createExplosionReward("Phantom Ops Explosion"),
							v.createEmoteReward("Emote1267")
						}),
						ProductId = 3710423876
					}
				}
			}
		}
	}
}