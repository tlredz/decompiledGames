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
		RootFFlagStartTime = "SoulrenderScytheRootStartTime",
		RootFFlagEndTime = "SoulrenderScytheRootEndTime",
		FFlagStartTime = "SoulrenderScytheShowRoomStartTime",
		FFlagEndTime = "SoulrenderScytheShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Soulrender Scythe",
				Image = "rbxassetid://116411389777200",
				ShowRoom = "SoulrenderScytheShowRoom",
				TemplateType = "Bundle",
				Stock = "Soulrender Scythe",
				Rewards = {
					{
						GiftName = "Soulrender Scythe",
						GiftId = 1942159290,
						Item = v.createListReward({
							v.createSwordReward("Soulrender Scythe"),
							v.createExplosionReward("Soul Lantern"),
							v.createEmoteReward("Emote553")
						}),
						ProductId = 1942159296
					}
				}
			}
		}
	}
}