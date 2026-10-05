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
		RootFFlagStartTime = "BrutalityInPinkRootStartTime",
		RootFFlagEndTime = "BrutalityInPinkRoot2EndTime",
		FFlagStartTime = "BrutalityAffectionBatStartTime",
		FFlagEndTime = "BrutalityAffectionBatEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Brutality Affection Bat",
				Image = "rbxassetid://123662580881393",
				ShowRoom = "BrutalityAffectionBatShowRoom",
				TemplateType = "Bundle",
				Stock = "Brutality Affection Bat",
				Rewards = {
					{
						GiftName = "Brutality Affection Bat",
						GiftId = 3604305452,
						Item = v.createListReward({
							v.createSwordReward("Brutality Affection Bat"),
							v.createExplosionReward("Brutality Affection Explosion"),
							v.createEmoteReward("Emote1222")
						}),
						ProductId = 3604305459
					}
				}
			}
		}
	}
}