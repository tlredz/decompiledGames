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
		RootFFlagStartTime = "RegretBladesRootStartTime",
		RootFFlagEndTime = "RegretBladesRootEndTime",
		FFlagStartTime = "RegretBladesStartTime",
		FFlagEndTime = "RegretBladesEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Regret Blades",
				Image = "rbxassetid://116972539878219",
				ShowRoom = "RegretBladesShowRoom",
				TemplateType = "Bundle",
				Stock = "Regret Blades",
				Rewards = {
					{
						GiftName = "Regret Blades",
						GiftId = 3569908916,
						Item = v.createListReward({
							v.createSwordReward("Regret Blades"),
							v.createExplosionReward("Regret Blades Explosion"),
							v.createEmoteReward("Emote1197")
						}),
						ProductId = 3569908915
					}
				}
			}
		}
	}
}