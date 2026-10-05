local module = require("../../EventConfig/FischFright25")
local FischFrightFetch = {}

for k, v in {
	{
		Name = "Patchen",
		Fish = "Shiny Candle Carp",
		CandyAmount = 400
	},
	{
		Name = "Jasper",
		Fish = "Shiny Werewolf Walleye",
		CandyAmount = 400
	},
	{
		Name = "Selene",
		Fish = "Spider Salmon",
		CandyAmount = 200
	},
	{
		Name = "Elara",
		Fish = "Sparkling Candy Corn Cod",
		CandyAmount = 350
	},
	{
		Name = "Vincent",
		Fish = "Marshmallow Mackerel",
		CandyAmount = 200
	},
	{
		Name = "Willow",
		Fish = "Kelpie",
		CandyAmount = 550
	},
	{
		Name = "Edris",
		Fish = "Scarecrow",
		CandyAmount = 750
	},
	{
		Name = "Pete",
		Fish = "Shiny Gummy Guppy",
		CandyAmount = 400
	},
	{
		Name = "Lilith",
		Fish = "Baby Nessie",
		CandyAmount = 1000
	},
	{
		Name = "Silas",
		Fish = "Skeletal Nessie",
		CandyAmount = 1500
	},
	{
		Name = "Vlad",
		Fish = "Vampire Perch",
		CandyAmount = 200
	},
	{
		Name = "Pumpkin Paul",
		Fish = "Jack-o-Lantern",
		CandyAmount = 750
	},
	{
		Name = "Evil Clown",
		Fish = "Shiny Mourning Manta Ray",
		CandyAmount = 750
	},
	{
		Name = "Jack Skellington",
		Fish = "Coffin Crab",
		CandyAmount = 200
	},
	{
		Name = "Jeremy",
		Fish = "Xtra Sour Gummy Pack",
		CandyAmount = 150
	},
	{
		Name = "Ghost",
		Fish = "Sparkling Ghost Minnow",
		CandyAmount = 440
	},
	{
		Name = "Dusekkar",
		Fish = "Nightmare Skeletal Nessie",
		CandyAmount = 8000
	},
	{
		Name = "Brianana",
		Fish = "Frightful Relic",
		CandyAmount = 2500
	},
	{
		Name = "Tibion",
		Fish = "Spooky Relic",
		CandyAmount = 2500
	}
} do
	FischFrightFetch[`Fischfright{k}`] = {
		DisplayName = `Fischfright - {v.Name}`,
		Icon = "rbxassetid://126723277769789",
		IconColor = Color3.fromRGB(139, 69, 19),
		QuestType = "Side",
		ExpiresAt = module.ExpiresAt,
		Description = `Catch a {v.Fish} and bring it back to {v.Name}`,
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				`Cache.Fischfright{k}`,
				true,
				(`Bring a "{v.Fish}" to {v.Name}`)
			}
		},
		Rewards = {
			{ "LocalCurrency", "Candy", v.CandyAmount }
		}
	}
end

table.insert(FischFrightFetch.Fischfright10.Rewards, { "Title", "💀" })
table.insert(FischFrightFetch.Fischfright11.Rewards, { "Title", "🧛" })
table.insert(FischFrightFetch.Fischfright13.Rewards, { "Title", "🤡" })
table.insert(FischFrightFetch.Fischfright14.Rewards, { "Title", "🎃" })
return FischFrightFetch