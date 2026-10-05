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
		RootFFlagStartTime = "FloppyChickenShowRoomRootStartTime",
		RootFFlagEndTime = "FloppyChickenShowRoomRootEndTime",
		FFlagStartTime = "FloppyChickenShowRoomStartTime",
		FFlagEndTime = "FloppyChickenShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Floppy Chicken",
				Image = "rbxassetid://112366905279403",
				ShowRoom = "FloppyChickenShowRoom",
				TemplateType = "Bundle",
				Stock = "Floppy Chicken",
				Rewards = {
					{
						GiftName = "Floppy Chicken",
						GiftId = 3251942816,
						Item = v.createListReward({
							v.createSwordReward("Floppy Chicken"),
							v.createExplosionReward("Floppy Chicken Explosion"),
							v.createEmoteReward("Emote853")
						}),
						ProductId = 3251942818
					}
				}
			}
		}
	}
}