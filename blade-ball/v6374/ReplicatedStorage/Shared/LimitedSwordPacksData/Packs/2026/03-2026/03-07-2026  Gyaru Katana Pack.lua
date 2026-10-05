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
		RootFFlagStartTime = "GyaruKatanaRootStartTime",
		RootFFlagEndTime = "GyaruKatanaRootEndTime",
		FFlagStartTime = "GyaruKatanaStartTime",
		FFlagEndTime = "GyaruKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gyaru Katana",
				Image = "rbxassetid://137934121292705",
				ShowRoom = "GyaruKatanaShowRoom",
				TemplateType = "Bundle",
				Stock = "Gyaru Katana",
				Rewards = {
					{
						GiftName = "Gyaru Katana",
						GiftId = 3551336793,
						Item = v.createListReward({
							v.createSwordReward("Gyaru Katana"),
							v.createExplosionReward("Gyaru's Selfie"),
							v.createEmoteReward("Emote1179")
						}),
						ProductId = 3551336796
					}
				}
			}
		}
	}
}