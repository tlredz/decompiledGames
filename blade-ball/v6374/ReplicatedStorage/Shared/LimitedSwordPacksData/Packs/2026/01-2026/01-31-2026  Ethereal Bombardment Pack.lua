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
		RootFFlagStartTime = "EtherealBombardmentRootStartTime",
		RootFFlagEndTime = "EtherealBombardmentRootEndTime",
		FFlagStartTime = "EtherealBombardmentStartTime",
		FFlagEndTime = "EtherealBombardmentEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ethereal Bombardment",
				Image = "rbxassetid://101562016121273",
				ShowRoom = "EtherealBombardmentShowRoom",
				TemplateType = "Bundle",
				Stock = "Ethereal Bombardment",
				Rewards = {
					{
						GiftName = "Ethereal Bombardment",
						GiftId = 3527425408,
						Item = v.createListReward({
							v.createSwordReward("Ethereal Bombardment"),
							v.createExplosionReward("Ethereal Bombardment Explosion"),
							v.createEmoteReward("Emote1133")
						}),
						ProductId = 3527425403
					}
				}
			}
		}
	}
}