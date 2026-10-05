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
		RootFFlagStartTime = "CherryBlossomPackRootStartTime",
		RootFFlagEndTime = "CherryBlossomPackRootEndTime",
		FFlagStartTime = "CherryBlossomBladeStartTime",
		FFlagEndTime = "CherryBlossomBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Cherry Blossom Blade",
				Image = v2.Icons:GetSwordIcon("Dual Cherry Blossom Blade"),
				ShowRoom = "CherryBlossomBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Cherry Blossom Blade",
						GiftId = 3536879465,
						Item = v.createListReward({ v.createSwordReward("Cherry Blossom Blade") }),
						ProductId = 3536879475
					},
					{
						GiftName = "Dual Cherry Blossom Blade",
						GiftId = 3536879470,
						Item = v.createListReward({
							v.createSwordReward("Dual Cherry Blossom Blade"),
							v.createExplosionReward("Blossom Rain"),
							v.createEmoteReward("Emote1166")
						}),
						ProductId = 3536879472
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "CherryBlossomPackRootStartTime",
		RootFFlagEndTime = "CherryBlossomPackRootEndTime",
		FFlagStartTime = "CherryBlossomSpearStartTime",
		FFlagEndTime = "CherryBlossomSpearEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Cherry Blossom Spear",
				Image = v2.Icons:GetSwordIcon("Cherry Blossom Spear"),
				ShowRoom = "CherryBlossomSpearShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Cherry Blossom Spear",
						GiftId = 3536879476,
						Item = v.createListReward({
							v.createSwordReward("Cherry Blossom Spear"),
							v.createExplosionReward("Spring Is Pink"),
							v.createEmoteReward("Emote1165")
						}),
						ProductId = 3536879471
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "CherryBlossomPackRootStartTime",
		RootFFlagEndTime = "CherryBlossomPackRootEndTime",
		FFlagStartTime = "CherryBlossomPackStartTime",
		FFlagEndTime = "CherryBlossomPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Cherry Blossom Pack",
				Image = "rbxassetid://127624499521738",
				ShowRoom = "CherryBlossomPackShowRoom",
				Rewards = {
					{
						GiftName = "Cherry Blossom Pack",
						GiftId = 3536879468,
						Item = v.createListReward({
							v.createSwordReward("Cherry Blossom Blade"),
							v.createSwordReward("Cherry Blossom Spear"),
							v.createExplosionReward("Blossom Rain"),
							v.createEmoteReward("Emote1165")
						}),
						ProductId = 3536879469,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Cherry Blossom Pack",
						GiftId = 3536879474,
						Item = v.createListReward({
							v.createSwordReward("Dual Cherry Blossom Blade"),
							v.createSwordReward("Cherry Blossom Spear"),
							v.createExplosionReward("Spring Is Pink"),
							v.createEmoteReward("Emote1166"),
							v.createEmoteReward("Emote1165")
						}),
						ProductId = 3536879473,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}