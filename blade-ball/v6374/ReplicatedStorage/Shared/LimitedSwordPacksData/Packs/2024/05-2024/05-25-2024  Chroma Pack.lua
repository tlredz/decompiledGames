local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Common.Utils)
require3(script:FindFirstAncestor("Packs").Parent.Types)
return {
	{
		RootFFlagStartTime = "ChromaSetRootStartTime",
		RootFFlagEndTime = "ChromaSetRootEndTime",
		FFlagStartTime = "ChromaBladeStartTime",
		FFlagEndTime = "ChromaBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Chroma Blade",
				Image = v2.Icons:GetSwordIcon("Chroma Blade"),
				ShowRoom = "ChromaBladeShowRoom",
				Stock = "Chroma Blade",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Chroma Blade",
						GiftId = 1834830945,
						Item = v.createListReward({
							v.createSwordReward("Chroma Blade"),
							v.createExplosionReward("Chroma Blade Explosion"),
							v.createEmoteReward("Emote348")
						}),
						ProductId = 1834830944
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ChromaSetRootStartTime",
		RootFFlagEndTime = "ChromaSetRootEndTime",
		FFlagStartTime = "RunicScytheStartTime",
		FFlagEndTime = "RunicScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Chroma Scythe",
				Image = v2.Icons:GetSwordIcon("Chroma Scythe"),
				ShowRoom = "ChromaScytheShowRoom",
				TemplateType = "Sword",
				Stock = "Chroma Scythe",
				Rewards = {
					{
						GiftName = "Chroma Scythe",
						GiftId = 1834830948,
						Item = v.createListReward({
							v.createSwordReward("Chroma Scythe"),
							v.createExplosionReward("Chroma Scythe Explosion"),
							v.createEmoteReward("Emote349")
						}),
						ProductId = 1834830946
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ChromaSetRootStartTime",
		RootFFlagEndTime = "ChromaSetRootEndTime",
		FFlagStartTime = "DualChromaSetStartTime",
		FFlagEndTime = "DualChromaSetEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Dual Chroma Set",
				Image = v2.Icons:GetSwordIcon("Dual Chroma Set"),
				ShowRoom = "DualChromaSetShowRoom",
				TemplateType = "Sword",
				Stock = "Dual Chroma Set",
				Rewards = {
					{
						GiftName = "Dual Chroma Set",
						GiftId = 1834830943,
						Item = v.createListReward({
							v.createSwordReward("Dual Chroma Set"),
							v.createExplosionReward("Dual Chroma Set Explosion"),
							v.createEmoteReward("Emote350")
						}),
						ProductId = 1834830947
					}
				}
			}
		}
	}
}