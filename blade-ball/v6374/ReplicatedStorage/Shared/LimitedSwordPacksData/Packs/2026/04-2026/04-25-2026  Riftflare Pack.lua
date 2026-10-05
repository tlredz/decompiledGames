local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Common.Utils)
require3(script:FindFirstAncestor("Packs").Parent.Types)
return {
	{
		RootFFlagStartTime = "RiftflareStartTime",
		RootFFlagEndTime = "RiftflareEndTime",
		FFlagStartTime = "RiftflareBladeStartTime",
		FFlagEndTime = "RiftflareBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Riftflare Blade",
				Image = v2.Icons:GetSwordIcon("Dual Riftflare Blade"),
				ShowRoom = "RiftflareBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Riftflare Blade",
						GiftId = 3581336327,
						Item = v.createListReward({ v.createSwordReward("Riftflare Blade") }),
						ProductId = 3581336337
					},
					{
						GiftName = "Dual Riftflare Blade",
						GiftId = 3581336336,
						Item = v.createListReward({
							v.createSwordReward("Dual Riftflare Blade"),
							v.createExplosionReward("Riftflare Curse"),
							v.createEmoteReward("Emote1205")
						}),
						ProductId = 3581336335
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RiftflareStartTime",
		RootFFlagEndTime = "RiftflareEndTime",
		FFlagStartTime = "RiftflareLanceStartTime",
		FFlagEndTime = "RiftflareLanceEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Riftflare Lance",
				Image = v2.Icons:GetSwordIcon("Riftflare Lance"),
				ShowRoom = "RiftflareLanceShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Riftflare Lance",
						GiftId = 3581336330,
						Item = v.createListReward({
							v.createSwordReward("Riftflare Lance"),
							v.createExplosionReward("Riftflare Portal"),
							v.createEmoteReward("Emote1204")
						}),
						ProductId = 3581336329
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RiftflareStartTime",
		RootFFlagEndTime = "RiftflareEndTime",
		FFlagStartTime = "RiftflarePackStartTime",
		FFlagEndTime = "RiftflarePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Riftflare Pack",
				Image = "rbxassetid://86286795172831",
				ShowRoom = "RiftflarePackShowRoom",
				Rewards = {
					{
						GiftName = "Riftflare Pack",
						GiftId = 3581336328,
						Item = v.createListReward({
							v.createSwordReward("Riftflare Blade"),
							v.createSwordReward("Riftflare Lance"),
							v.createExplosionReward("Riftflare Curse"),
							v.createEmoteReward("Emote1204")
						}),
						ProductId = 3581336334,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Riftflare Pack",
						GiftId = 3581336332,
						Item = v.createListReward({
							v.createSwordReward("Dual Riftflare Blade"),
							v.createSwordReward("Riftflare Lance"),
							v.createExplosionReward("Riftflare Portal"),
							v.createEmoteReward("Emote1205"),
							v.createEmoteReward("Emote1204")
						}),
						ProductId = 3581336333,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}