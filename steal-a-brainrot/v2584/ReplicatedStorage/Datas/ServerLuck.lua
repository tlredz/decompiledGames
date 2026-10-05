local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Updates)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
return {
	{
		Duration = 900,
		Multiplier = 2,
		ProductId = 3296448740,
		Id = "2x"
	},
	{
		Duration = 900,
		Multiplier = 4,
		ProductId = 3296448922,
		Id = "4x"
	},
	{
		Duration = 900,
		Multiplier = 8,
		ProductId = 3520574597,
		Icon = "rbxassetid://124799036749678",
		Tag = "rainbow",
		IsEnabled = function()
			return FFlags:GetInstant("8xServerLuckEnabled", true)
		end,
		Id = "8x"
	}
}