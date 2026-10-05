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
		RootFFlagStartTime = "BlossomKatanaShowRoomRootStartTime",
		RootFFlagEndTime = "BlossomKatanaShowRoomRootEndTime",
		FFlagStartTime = "BlossomKatanaShowRoomStartTime",
		FFlagEndTime = "BlossomKatanaShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Blossom Katana",
				Image = "rbxassetid://137824097672693",
				ShowRoom = "BlossomKatanaShowRoom",
				TemplateType = "Bundle",
				Stock = "Blossom Katana",
				Rewards = {
					{
						GiftName = "Blossom Katana",
						GiftId = 3257957360,
						Item = v.createListReward({
							v.createSwordReward("Blossom Katana"),
							v.createExplosionReward("Blossom Katana Explosion"),
							v.createEmoteReward("Blossom Katana Emote")
						}),
						ProductId = 3257957359
					}
				}
			}
		}
	}
}