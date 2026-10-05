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
		RootFFlagStartTime = "NebulaSniperPackRootStartTime",
		RootFFlagEndTime = "NebulaSniperPackRootEndTime",
		FFlagStartTime = "NebulaSniperStartTime",
		FFlagEndTime = "NebulaSniperEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Stock = "Nebula Sniper",
				Name = "Nebula Sniper",
				Image = "rbxassetid://18784548277",
				ShowRoom = "NebulaPackShowRoom",
				TemplateType = "Bundle",
				Rewards = {
					{
						GiftName = "Nebula Sniper",
						GiftId = 1896542208,
						Item = v.createListReward({
							v.createSwordReward("Nebula Sniper"),
							v.createExplosionReward("Cosmic Accuracy"),
							v.createEmoteReward("Emote468")
						}),
						ProductId = 1896542209
					}
				}
			}
		}
	}
}