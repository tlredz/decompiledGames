local v = {
	UltimateBlade = {
		ExpireDate = DateTime.fromUniversalTime(2023, 9, 30, 13),
		PlayTime = 240,
		SubPacks = {
			Basic = {
				PurchaseLimit = 3,
				ProductId = 1649003823,
				Rewards = {
					{
						Type = "CrateKey",
						Name = "PremiumExplosion",
						Amount = 1,
						DisplayName = "OP Explosion Crate",
						Icon = "rbxassetid://14798401525"
					},
					{
						Type = "Coin",
						Amount = 14500,
						Icon = "rbxassetid://14849044347",
						DisplayName = "14.5K"
					},
					{
						Type = "CrateKey",
						Name = "PremiumSword",
						Amount = 1,
						DisplayName = "OP Sword Crate",
						Icon = "rbxassetid://14798399577"
					},
					{
						Type = "Explosion",
						Name = "Runic Blast",
						Icon = "rbxassetid://14852855175",
						Alternative = {
							Type = "CrateKey",
							Name = "Explosion",
							DisplayName = "Explosion Crate",
							Amount = 3,
							Icon = "rbxassetid://14798401525"
						}
					},
					{
						Type = "Sword",
						Name = "Essence Cleaver",
						Icon = "rbxassetid://14841466009",
						Alternative = {
							Type = "CrateKey",
							Name = "Sword",
							DisplayName = "Sword Crate",
							Amount = 3,
							Icon = "rbxassetid://14798399577"
						}
					}
				}
			},
			Skill = {
				PurchaseLimit = 3,
				ProductId = 1649003949,
				Rewards = {
					{
						Type = "CrateKey",
						Name = "PremiumExplosion",
						Amount = 1,
						DisplayName = "OP Explosion Crate",
						Icon = "rbxassetid://14798401525"
					},
					{
						Type = "Coin",
						Amount = 30000,
						Icon = "rbxassetid://14849045938",
						DisplayName = "30K"
					},
					{
						Type = "Sword",
						Name = "Molten Greatblade",
						Icon = "rbxassetid://14841466149",
						Alternative = {
							Type = "CrateKey",
							Name = "Sword",
							DisplayName = "Sword Crate",
							Amount = 10,
							Icon = "rbxassetid://14798399577"
						}
					},
					{
						Type = "Explosion",
						Name = "Arctic Blast",
						Icon = "rbxassetid://14852855399",
						Alternative = {
							Type = "CrateKey",
							Name = "Explosion",
							DisplayName = "Explosion Crate",
							Amount = 10,
							Icon = "rbxassetid://14798401525"
						}
					},
					{
						Type = "Skill",
						Name = "Waypoint",
						DisplayName = "Waypoint Ability",
						Icon = "rbxassetid://14847396112"
					}
				}
			}
		},
		Bonus = {
			{
				Type = "Skill",
				Name = "Infinity",
				Icon = "rbxassetid://14847396284"
			},
			{
				Type = "Sword",
				Name = "Shattered Sword",
				Icon = "rbxassetid://14841466262"
			}
		}
	}
}
return table.freeze(v)