local _ = game.GameId == 4777817887
local LimitedSwordEvent = {
	Events = {
		NebulaLightning = {
			Duration = {
				Min = 1699714800,
				Max = DateTime.fromUniversalTime(2024, 1, 12, 16).UnixTimestamp
			},
			UseShowroom = true,
			Swords = {
				Single = {
					Price = "399",
					ProductId = 1701417403,
					GiftId = 1701417480,
					SwordIcon = "rbxassetid://15580262293",
					SwordName = "Nebula's Lightning"
				},
				Better = {
					Price = "3499",
					ProductId = 1701417621,
					GiftId = 1701417712,
					SwordIcon = "rbxassetid://15580262580",
					SwordName = "Dual Nebula's Lightning"
				}
			},
			Disabled = true
		},
		SwordPacks = {
			Duration = {
				Min = 0,
				Max = 0
			},
			UseShowroom = true,
			NoLimitedSwordUI = true,
			HideGiftButton = true,
			PromptText = "Buy Limited Swords",
			Swords = {
				Single = {
					ProductId = 0,
					GiftId = 0,
					SwordIcon = "",
					SwordName = "Aetherial Azure Reckoner"
				},
				Better = {
					ProductId = 0,
					GiftId = 0,
					SwordIcon = "",
					SwordName = "Dual Aetherial Azure Reckoner"
				}
			}
		}
	}
}

if LimitedSwordEvent.Events.SwordPacks then
	LimitedSwordEvent.Active = "SwordPacks"
end

return LimitedSwordEvent