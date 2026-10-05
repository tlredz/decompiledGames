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
		RootFFlagStartTime = "SerpentsGreatswordRootStartTime",
		RootFFlagEndTime = "SerpentsGreatswordRootEndTime",
		FFlagStartTime = "SerpentsGreatswordShowRoomStartTime",
		FFlagEndTime = "SerpentsGreatswordShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Serpent's Greatsword",
				Image = "rbxassetid://93127700330553",
				ShowRoom = "SerpentsGreatswordShowRoom",
				TemplateType = "Bundle",
				Stock = "Serpent's Greatsword",
				Rewards = {
					{
						GiftName = "Serpent's Greatsword",
						GiftId = 2708243457,
						Item = v.createListReward({
							v.createSwordReward("Serpent's Greatsword"),
							v.createExplosionReward("Serpent's Judgment"),
							v.createEmoteReward("Emote756")
						}),
						ProductId = 2708243456
					}
				}
			}
		}
	}
}