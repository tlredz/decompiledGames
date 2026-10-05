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
		RootFFlagStartTime = "RiftflareKatanaRootStartTime",
		RootFFlagEndTime = "RiftflareKatanaRootEndTime",
		FFlagStartTime = "RiftflareKatanaStartTime",
		FFlagEndTime = "RiftflareKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Riftflare Katana",
				Image = "rbxassetid://110149083849623",
				ShowRoom = "RiftflareKatanaShowRoom",
				TemplateType = "Bundle",
				Stock = "Riftflare Katana",
				Rewards = {
					{
						GiftName = "Riftflare Katana",
						GiftId = 3527425406,
						Item = v.createListReward({
							v.createSwordReward("Riftflare Katana"),
							v.createExplosionReward("Riftflare Katana Explosion"),
							v.createEmoteReward("Emote1135")
						}),
						ProductId = 3527425405
					}
				}
			}
		}
	}
}