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
		RootFFlagStartTime = "NightRaverRootStartTime",
		RootFFlagEndTime = "NightRaverRootEndTime",
		FFlagStartTime = "NightRaverStartTime",
		FFlagEndTime = "NightRaverEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Night Raver",
				Image = "rbxassetid://134581133756930",
				ShowRoom = "NightRaverShowRoom",
				TemplateType = "Bundle",
				Stock = "Night Raver",
				Rewards = {
					{
						GiftName = "Night Raver",
						GiftId = 3551336794,
						Item = v.createListReward({
							v.createSwordReward("Night Raver"),
							v.createExplosionReward("Night Raver"),
							v.createEmoteReward("Emote1181")
						}),
						ProductId = 3551336791
					}
				}
			}
		}
	}
}