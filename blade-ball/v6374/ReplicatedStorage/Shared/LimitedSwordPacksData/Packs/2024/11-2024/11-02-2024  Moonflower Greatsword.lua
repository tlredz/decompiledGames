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
		RootFFlagStartTime = "MoonflowerGreatswordRootStartTime",
		RootFFlagEndTime = "MoonflowerGreatswordRootEndTime",
		FFlagStartTime = "MoonflowerGreatswordShowRoomStartTime",
		FFlagEndTime = "MoonflowerGreatswordShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Moonflower Greatsword",
				Image = "rbxassetid://120636494655412",
				ShowRoom = "MoonflowerGreatswordShowRoom",
				TemplateType = "Bundle",
				Stock = "Moonflower Greatsword",
				Rewards = {
					{
						GiftName = "Moonflower Greatsword",
						GiftId = 2319193589,
						Item = v.createListReward({
							v.createSwordReward("Moonflower Greatsword"),
							v.createExplosionReward("Great Moon Landing"),
							v.createEmoteReward("Emote601")
						}),
						ProductId = 2319193590
					}
				}
			}
		}
	}
}