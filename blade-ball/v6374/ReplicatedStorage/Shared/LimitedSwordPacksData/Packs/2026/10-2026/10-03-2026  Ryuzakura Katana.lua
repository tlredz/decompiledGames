local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(script:FindFirstAncestor("Packs").Parent.Types)
return {
	{
		RootFFlagStartTime = "RyuzakuraKatanaStartTime",
		RootFFlagEndTime = "RyuzakuraKatanaEndTime",
		FFlagStartTime = "RyuzakuraKatanaStartTime",
		FFlagEndTime = "RyuzakuraKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ryuzakura Katana",
				Image = "rbxassetid://107700965826324",
				ShowRoom = "RyuzakuraKatanaShowRoom",
				TemplateType = "Bundle",
				Stock = "Ryuzakura Katana",
				Rewards = {
					{
						GiftName = "Ryuzakura Katana",
						GiftId = 3716289592,
						Item = v.createListReward({
							v.createSwordReward("Ryuzakura Katana"),
							v.createExplosionReward("Ryuzakura Katana Explosion"),
							v.createEmoteReward("Emote1288")
						}),
						ProductId = 3716289596
					}
				}
			}
		}
	}
}