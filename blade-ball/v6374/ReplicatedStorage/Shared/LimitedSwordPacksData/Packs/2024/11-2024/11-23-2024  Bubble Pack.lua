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
		RootFFlagStartTime = "BubblePackRootStartTime",
		RootFFlagEndTime = "BubblePackRootEndTime",
		FFlagStartTime = "BubbleBladeStartTime",
		FFlagEndTime = "BubbleBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bubble Blade",
				Image = v2.Icons:GetSwordIcon("Dual Bubble Blade"),
				ShowRoom = "BubbleBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Bubble Blade",
						GiftId = 2661552688,
						Item = v.createListReward({ v.createSwordReward("Bubble Blade") }),
						ProductId = 2661552689
					},
					{
						GiftName = "Dual Bubble Blade",
						GiftId = 2661552692,
						Item = v.createListReward({
							v.createSwordReward("Dual Bubble Blade"),
							v.createExplosionReward("Bubble Magic"),
							v.createEmoteReward("Emote638")
						}),
						ProductId = 2661552694
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BubblePackRootStartTime",
		RootFFlagEndTime = "BubblePackRootEndTime",
		FFlagStartTime = "BubbleBlastersStartTime",
		FFlagEndTime = "BubbleBlastersEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bubble Blaster",
				Image = v2.Icons:GetSwordIcon("Dual Bubble Blasters"),
				ShowRoom = "BubbleBlastersShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Bubble Blaster",
						GiftId = 2661552693,
						Item = v.createListReward({
							v.createSwordReward("Bubble Blaster"),
							v.createExplosionReward("Bubblegum"),
							v.createEmoteReward("Emote639")
						}),
						ProductId = 2661552695
					},
					{
						GiftName = "Dual Bubble Blasters",
						GiftId = 2661552685,
						Item = v.createListReward({
							v.createSwordReward("Dual Bubble Blasters"),
							v.createExplosionReward("Bubblegum"),
							v.createEmoteReward("Emote640")
						}),
						ProductId = 2661552697
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BubblePackRootStartTime",
		RootFFlagEndTime = "BubblePackRootEndTime",
		FFlagStartTime = "BubblePackStartTime",
		FFlagEndTime = "BubblePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bubble Pack",
				Image = "rbxassetid://126891892360090",
				ShowRoom = "BubblePackShowRoom",
				Rewards = {
					{
						GiftName = "Bubble Pack",
						GiftId = 2661552690,
						Item = v.createListReward({
							v.createSwordReward("Bubble Blade"),
							v.createSwordReward("Bubble Blaster"),
							v.createExplosionReward("Bubble Magic"),
							v.createEmoteReward("Emote639")
						}),
						ProductId = 2661552687,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Bubble Pack",
						GiftId = 2661552691,
						Item = v.createListReward({
							v.createSwordReward("Dual Bubble Blade"),
							v.createSwordReward("Dual Bubble Blasters"),
							v.createExplosionReward("Bubblegum"),
							v.createEmoteReward("Emote638"),
							v.createEmoteReward("Emote640")
						}),
						ProductId = 2661552686,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}