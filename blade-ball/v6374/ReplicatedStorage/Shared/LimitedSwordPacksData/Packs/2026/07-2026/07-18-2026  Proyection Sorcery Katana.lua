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
		RootFFlagStartTime = "ProyectionSorceryKatanaRootStartTime",
		RootFFlagEndTime = "ProyectionSorceryKatanaRootEndTime",
		FFlagStartTime = "ProyectionSorceryKatanaStartTime",
		FFlagEndTime = "ProyectionSorceryKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Proyection Sorcery Katana",
				Image = "rbxassetid://95872582316593",
				ShowRoom = "ProyectionSorceryKatanaShowRoom",
				TemplateType = "Bundle",
				Stock = "Proyection Sorcery Katana",
				Rewards = {
					{
						GiftName = "Proyection Sorcery Katana",
						GiftId = 3609288729,
						Item = v.createListReward({
							v.createSwordReward("Proyection Sorcery Katana"),
							v.createExplosionReward("Proyection Sorcery Explosion"),
							v.createEmoteReward("Emote1248")
						}),
						ProductId = 3609288733
					}
				}
			}
		}
	}
}