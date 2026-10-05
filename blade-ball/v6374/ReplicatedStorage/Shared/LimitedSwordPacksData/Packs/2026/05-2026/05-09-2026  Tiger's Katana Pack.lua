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
		RootFFlagStartTime = "TigerKatanaRootStartTime",
		RootFFlagEndTime = "TigerKatanaRootEndTime",
		FFlagStartTime = "TigerKatanaStartTime",
		FFlagEndTime = "TigerKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Tiger's Katana",
				Image = "rbxassetid://132298554962989",
				ShowRoom = "TigerKatanaShowRoom",
				TemplateType = "Bundle",
				Stock = "Tiger's Katana",
				Rewards = {
					{
						GiftName = "Tiger's Katana",
						GiftId = 3585199332,
						Item = v.createListReward({
							v.createSwordReward("Tiger's Katana"),
							v.createExplosionReward("Tiger Katana Explosion"),
							v.createEmoteReward("Emote1211")
						}),
						ProductId = 3585199333
					}
				}
			}
		}
	}
}