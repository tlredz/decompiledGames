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
		FFlagStartTime = "PrincessKatanaStartTime",
		FFlagEndTime = "PrincessKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Princess Katana",
				Image = v2.Icons:GetSwordIcon("Dual Princess Katana"),
				ShowRoom = "PrincessKatanaShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Princess Katana",
						Item = v.createListReward({ v.createSwordReward("Princess Katana") }),
						ProductId = 1776904322
					},
					{
						GiftName = "Dual Princess Katana",
						Item = v.createListReward({
							v.createSwordReward("Dual Princess Katana"),
							v.createExplosionReward("Princess Explosion"),
							v.createEmoteReward("Emote212")
						}),
						ProductId = 1776904293
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "KingBladeStartTime",
		FFlagEndTime = "KingBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "King Blade",
				Image = v2.Icons:GetSwordIcon("King Blade"),
				ShowRoom = "KingBladeShowRoom",
				TemplateType = "Sword",
				Stock = "King Blade",
				Rewards = {
					{
						GiftName = "King Blade",
						Item = v.createListReward({
							v.createSwordReward("King Blade"),
							v.createExplosionReward("King Explosion"),
							v.createEmoteReward("Emote214")
						}),
						ProductId = 1776904289
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "QueenBladeStartTime",
		FFlagEndTime = "QueenBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Queen Blade",
				Image = v2.Icons:GetSwordIcon("Queen Blade"),
				ShowRoom = "QueenBladeShowRoom",
				TemplateType = "Sword",
				Stock = "Queen Blade",
				Rewards = {
					{
						GiftName = "Queen Blade",
						Item = v.createListReward({
							v.createSwordReward("Queen Blade"),
							v.createExplosionReward("Queen Explosion"),
							v.createEmoteReward("Emote213")
						}),
						ProductId = 1776904291
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "DualRoyalBladesStartTime",
		FFlagEndTime = "DualRoyalBladesEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Dual Royal Blades",
				Image = v2.Icons:GetSwordIcon("Dual Royal Blades"),
				ShowRoom = "DualRoyalBladesShowRoom",
				TemplateType = "Sword",
				Stock = "Dual Royal Blades",
				Rewards = {
					{
						GiftName = "Dual Royal Blades",
						Item = v.createListReward({
							v.createSwordReward("Dual Royal Blades"),
							v.createExplosionReward("Royal Explosion"),
							v.createEmoteReward("Emote215")
						}),
						ProductId = 1776904295
					}
				}
			}
		}
	}
}