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
		RootFFlagStartTime = "AstralSeraphBladeRootStartTime",
		RootFFlagEndTime = "AstralSeraphBladeRootEndTime",
		FFlagStartTime = "AstralSeraphBladeStartTime",
		FFlagEndTime = "AstralSeraphBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Astral Seraph Blade",
				Image = "rbxassetid://132192818524569",
				ShowRoom = "AstralSeraphBladeShowRoom",
				TemplateType = "Bundle",
				Stock = "Astral Seraph Blade",
				Rewards = {
					{
						GiftName = "Astral Seraph Blade",
						GiftId = 3609288738,
						Item = v.createListReward({
							v.createSwordReward("Astral Seraph Blade"),
							v.createExplosionReward("Astral Seraph Explosion"),
							v.createEmoteReward("Emote1250")
						}),
						ProductId = 3609288741
					}
				}
			}
		}
	}
}