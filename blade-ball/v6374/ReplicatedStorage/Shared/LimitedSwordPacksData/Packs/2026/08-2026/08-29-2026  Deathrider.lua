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
		RootFFlagStartTime = "DeathriderStartTime",
		RootFFlagEndTime = "DeathriderEndTime",
		FFlagStartTime = "DeathriderStartTime",
		FFlagEndTime = "DeathriderEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Deathrider",
				Image = "rbxassetid://80983918950474",
				ShowRoom = "DeathriderShowRoom",
				TemplateType = "Bundle",
				Stock = "Deathrider",
				Rewards = {
					{
						GiftName = "Deathrider",
						GiftId = 3710423215,
						Item = v.createListReward({
							v.createSwordReward("Deathrider"),
							v.createExplosionReward("Deathrider Explosion"),
							v.createEmoteReward("Emote1269")
						}),
						ProductId = 3710423249
					}
				}
			}
		}
	}
}