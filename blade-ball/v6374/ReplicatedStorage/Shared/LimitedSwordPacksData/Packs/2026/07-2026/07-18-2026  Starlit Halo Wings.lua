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
		RootFFlagStartTime = "StarlitHaloWingsRootStartTime",
		RootFFlagEndTime = "StarlitHaloWingsRootEndTime",
		FFlagStartTime = "StarlitHaloWingsStartTime",
		FFlagEndTime = "StarlitHaloWingsEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Starlit Halo Wings",
				Image = "rbxassetid://103975435245352",
				ShowRoom = "StarlitHaloWingsShowRoom",
				TemplateType = "Bundle",
				Stock = "Starlit Halo Wings",
				Rewards = {
					{
						GiftName = "Starlit Halo Wings",
						GiftId = 3609288749,
						Item = v.createListReward({
							v.createSwordReward("Starlit Halo Wings"),
							v.createExplosionReward("Starlit Halo Wings Explosion"),
							v.createEmoteReward("Emote1247")
						}),
						ProductId = 3609288757
					}
				}
			}
		}
	}
}