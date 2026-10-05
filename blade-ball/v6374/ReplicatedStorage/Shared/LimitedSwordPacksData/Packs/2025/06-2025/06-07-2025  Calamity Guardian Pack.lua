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
		RootFFlagStartTime = "CalamityGuardianRootStartTime",
		RootFFlagEndTime = "CalamityGuardianRootEndTime",
		FFlagStartTime = "CalamityGuardianShowRoomStartTime",
		FFlagEndTime = "CalamityGuardianShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Calamity Guardian",
				Image = "rbxassetid://94212398747159",
				ShowRoom = "CalamityGuardianShowRoom",
				TemplateType = "Bundle",
				Stock = "Calamity Guardian",
				Rewards = {
					{
						GiftName = "Calamity Guardian",
						GiftId = 3302235586,
						Item = v.createListReward({
							v.createSwordReward("Calamity Guardian"),
							v.createExplosionReward("Calamity Guardian Explosion"),
							v.createEmoteReward("Emote952")
						}),
						ProductId = 3302235587
					}
				}
			}
		}
	}
}