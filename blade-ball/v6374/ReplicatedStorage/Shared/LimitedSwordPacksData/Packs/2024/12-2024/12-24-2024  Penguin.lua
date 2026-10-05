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
		RootFFlagStartTime = "PenguinRootStartTime",
		RootFFlagEndTime = "PenguinRootEndTime",
		FFlagStartTime = "PenguinStartTime",
		FFlagEndTime = "PenguinEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Penguin",
				Image = "rbxassetid://104097834018817",
				ShowRoom = "PenguinShowRoom",
				TemplateType = "Bundle",
				Stock = "Penguin",
				Rewards = {
					{
						GiftName = "Penguin",
						GiftId = 2680479849,
						Item = v.createListReward({
							v.createSwordReward("Penguin"),
							v.createExplosionReward("Arctic Waddle"),
							v.createEmoteReward("Penguin Emote")
						}),
						ProductId = 2680479848
					}
				}
			}
		}
	}
}