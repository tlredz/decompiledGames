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
		RootFFlagStartTime = "HellwingSetRootStartTime",
		RootFFlagEndTime = "HellwingSetRootEndTime",
		FFlagStartTime = "HellwingSetShowRoomStartTime",
		FFlagEndTime = "HellwingSetShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hellwing Set",
				Image = "rbxassetid://120614079997421",
				ShowRoom = "HellwingSetShowRoom",
				TemplateType = "Bundle",
				Stock = "Hellwing Set",
				Rewards = {
					{
						GiftName = "Hellwing Set",
						GiftId = 3440156698,
						Item = v.createListReward({
							v.createSwordReward("Hellwing Set"),
							v.createExplosionReward("Vampire Light"),
							v.createEmoteReward("Emote1063")
						}),
						ProductId = 3440156697
					}
				}
			}
		}
	}
}