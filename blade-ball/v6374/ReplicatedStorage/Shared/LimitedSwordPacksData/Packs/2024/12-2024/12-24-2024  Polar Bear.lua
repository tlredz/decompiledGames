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
		RootFFlagStartTime = "PolarBearRootStartTime",
		RootFFlagEndTime = "PolarBearRootEndTime",
		FFlagStartTime = "PolarBearStartTime",
		FFlagEndTime = "PolarBearEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Polar Bear",
				Image = "rbxassetid://78883565340925",
				ShowRoom = "PolarBearShowRoom",
				TemplateType = "Bundle",
				Stock = "Polar Bear",
				Rewards = {
					{
						Stock = "Polar Bear",
						GiftName = "Polar Bear",
						GiftId = 2680479862,
						Item = v.createListReward({
							v.createSwordReward("Polar Bear"),
							v.createExplosionReward("Polar Bear Pop"),
							v.createEmoteReward("Polar Bear Emote")
						}),
						ProductId = 2680479847
					},
					{
						Stock = "Polar Bear Mount",
						GiftName = "Polar Bear Mount",
						GiftId = 2680479864,
						Item = v.createListReward({
							v.createSwordReward("Polar Bear"),
							v.createSwordAccessoryReward("Polar Bear"),
							v.createExplosionReward("Polar Bear Pop"),
							v.createEmoteReward("Polar Bear Emote")
						}),
						ProductId = 2680479869
					}
				}
			}
		}
	}
}