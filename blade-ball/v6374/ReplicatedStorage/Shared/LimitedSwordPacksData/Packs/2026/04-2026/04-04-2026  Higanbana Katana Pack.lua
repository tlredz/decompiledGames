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
		RootFFlagStartTime = "HiganbanaKatanaRootStartTime",
		RootFFlagEndTime = "HiganbanaKatanaRootEndTime",
		FFlagStartTime = "HiganbanaKatanaStartTime",
		FFlagEndTime = "HiganbanaKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Higanbana Katana",
				Image = "rbxassetid://118698840936874",
				ShowRoom = "HiganbanaKatanaShowRoom",
				TemplateType = "Bundle",
				Stock = "Higanbana Katana",
				Rewards = {
					{
						GiftName = "Higanbana Katana",
						GiftId = 3569908918,
						Item = v.createListReward({
							v.createSwordReward("Higanbana Katana"),
							v.createExplosionReward("Higanbana Explosion"),
							v.createEmoteReward("Emote1194")
						}),
						ProductId = 3569908914
					}
				}
			}
		}
	}
}