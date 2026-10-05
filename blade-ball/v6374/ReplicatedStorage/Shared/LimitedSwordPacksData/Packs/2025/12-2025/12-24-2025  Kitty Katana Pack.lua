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
		RootFFlagStartTime = "KittyKatanaRootStartTime",
		RootFFlagEndTime = "KittyKatanaRootEndTime",
		FFlagStartTime = "KittyKatanaShowRoomStartTime",
		FFlagEndTime = "KittyKatanaShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Kitty Katana",
				Image = "rbxassetid://104287544147026",
				ShowRoom = "KittyKatanaShowRoom",
				TemplateType = "Bundle",
				Stock = "Kitty Katana",
				Rewards = {
					{
						GiftName = "Kitty Katana",
						GiftId = 3488864859,
						Item = v.createListReward({
							v.createSwordReward("Kitty Katana"),
							v.createExplosionReward("Kitty Katana Explosion"),
							v.createEmoteReward("Emote1117")
						}),
						ProductId = 3488864857
					}
				}
			}
		}
	}
}