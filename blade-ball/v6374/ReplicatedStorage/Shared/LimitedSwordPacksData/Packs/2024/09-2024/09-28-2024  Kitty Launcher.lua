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
		RootFFlagStartTime = "KittyLauncherRootStartTime",
		RootFFlagEndTime = "KittyLauncherRootEndTime",
		FFlagStartTime = "KittyLauncherShowRoomStartTime",
		FFlagEndTime = "KittyLauncherShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Kitty Launcher",
				Image = "rbxassetid://113062842095370",
				ShowRoom = "KittyLauncherShowRoom",
				TemplateType = "Bundle",
				Stock = "Kitty Launcher",
				Rewards = {
					{
						GiftName = "Kitty Launcher",
						GiftId = 1942159294,
						Item = v.createListReward({
							v.createSwordReward("Kitty Launcher"),
							v.createExplosionReward("Kitty Rocket"),
							v.createEmoteReward("Emote554")
						}),
						ProductId = 1942159281
					}
				}
			}
		}
	}
}