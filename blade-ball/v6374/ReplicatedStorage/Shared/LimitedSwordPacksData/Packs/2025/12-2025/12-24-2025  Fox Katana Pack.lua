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
		RootFFlagStartTime = "FoxKatanaRootStartTime",
		RootFFlagEndTime = "FoxKatanaRootEndTime1",
		FFlagStartTime = "FoxKatanaShowRoomStartTime",
		FFlagEndTime = "FoxKatanaShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Fox Katana",
				Image = "rbxassetid://140186197797328",
				ShowRoom = "FoxKatanaShowRoom",
				TemplateType = "Bundle",
				Stock = "Fox Katana",
				Rewards = {
					{
						GiftName = "Fox Katana",
						GiftId = 3492927326,
						Item = v.createListReward({
							v.createSwordReward("Fox Katana"),
							v.createExplosionReward("Fox Katana Explosion"),
							v.createEmoteReward("Emote1119")
						}),
						ProductId = 3492927325
					}
				}
			}
		}
	}
}