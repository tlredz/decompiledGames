local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RepeatableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.RepeatableDevProducts)
return {
	All = {
		{
			Name = "House Party",
			Id = "HouseParty",
			Image = "rbxassetid://135911355390008",
			Description = [[
A casual get-together - perfect for hanging out with friends!
Includes: some balloons and pizza.]],
			Product = nil,
			Music = nil,
			SystemMessage = false
		},
		{
			Name = "Birthday Party",
			Id = "BirthdayParty",
			Image = "rbxassetid://105241029692623",
			Description = [[
Celebrate your birthday in Brookhaven!
Includes: birthday cake you can slice and serve to friends, confetti blasters, party hats and birthday music.]],
			Product = RepeatableDevProducts.BIRTHDAY_PARTY,
			Music = "rbxassetid://9043576653",
			SystemMessage = true
		},
		{
			Name = "Dance Party",
			Id = "DanceParty",
			Image = "rbxassetid://88752873537682",
			Description = [[
Turn up the music and dance!
Includes: disco ball with colorful lights, glow sticks, fun party sunglasses and upbeat dance music.]],
			Product = RepeatableDevProducts.DANCE_PARTY,
			Music = "rbxassetid://1843468464",
			SystemMessage = true
		},
		{
			Name = "Taco Party",
			Id = "TacoParty",
			Image = "rbxassetid://87665128129462",
			Description = [[
Host the ultimate taco party!
Includes: piñata you can smash open, taco stand with tacos and raining tacos music.]],
			Product = RepeatableDevProducts.TACO_PARTY,
			Music = "rbxassetid://142376088",
			SystemMessage = true
		}
	}
}