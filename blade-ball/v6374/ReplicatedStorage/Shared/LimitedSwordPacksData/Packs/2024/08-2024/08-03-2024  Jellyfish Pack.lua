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
		RootFFlagStartTime = "JellyfishParasolPackRootStartTime",
		RootFFlagEndTime = "JellyfishParasolPackRootEndTime",
		FFlagStartTime = "JellyfishParasolStartTime",
		FFlagEndTime = "JellyfishParasolEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Stock = "Jellyfish Parasol",
				Name = "Jellyfish Parasol",
				Image = "rbxassetid://18784569099",
				ShowRoom = "JellyfishParasolShowRoom",
				TemplateType = "Bundle",
				Rewards = {
					{
						GiftName = "Jellyfish Parasol",
						GiftId = 1896542210,
						Item = v.createListReward({
							v.createSwordReward("Jellyfish Parasol"),
							v.createExplosionReward("Jellyfish Explosion"),
							v.createEmoteReward("Emote469")
						}),
						ProductId = 1896542212
					}
				}
			}
		}
	}
}