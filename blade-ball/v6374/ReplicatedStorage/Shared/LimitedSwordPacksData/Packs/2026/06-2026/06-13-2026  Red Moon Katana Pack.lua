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
		RootFFlagStartTime = "RedMoonKatanaRootStartTime",
		RootFFlagEndTime = "RedMoonKatanaRoot2EndTime",
		FFlagStartTime = "RedMoonKatanaStartTime",
		FFlagEndTime = "RedMoonKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Red Moon Katana",
				Image = "rbxassetid://108617848615631",
				ShowRoom = "RedMoonKatanaShowRoom",
				TemplateType = "Bundle",
				Stock = "Red Moon Katana",
				Rewards = {
					{
						GiftName = "Red Moon Katana",
						GiftId = 3604305446,
						Item = v.createListReward({
							v.createSwordReward("Red Moon Katana"),
							v.createExplosionReward("Red Moon Katana Explosion"),
							v.createEmoteReward("Emote1225")
						}),
						ProductId = 3604305449
					}
				}
			}
		}
	}
}