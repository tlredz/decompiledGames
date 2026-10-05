local module = require("../../EventConfig/Fischmas25")
local FischmasFetch = {}

for k, v in {
	{
		Name = "Jingle Jim",
		Fish = "Sparkling Bellfin",
		BellAmount = 250,
		SpecialRewards = {}
	},
	{
		Name = "Frostbite Fiona",
		Fish = "Gingerbread Man or Gingerbread mutated Fischmas fish",
		BellAmount = 100,
		SpecialRewards = {}
	},
	{
		Name = "Northwind Ned",
		Fish = "Shiny Northstar Whale",
		BellAmount = 750,
		SpecialRewards = {
			{
				"ItemOrFish",
				"Festive Relic",
				{
					Weight = 21
				},
				1
			}
		}
	},
	{
		Name = "Caroling Carla",
		Fish = "Merry Carol Carp",
		BellAmount = 300,
		SpecialRewards = {}
	},
	{
		Name = "Peppermint Patty",
		Fish = "Peppermint Pike",
		BellAmount = 100,
		SpecialRewards = {}
	},
	{
		Name = "Blitzen Barry",
		Fish = "Shiny Reindeer Ray",
		BellAmount = 250,
		SpecialRewards = {}
	},
	{
		Name = "Cozy Clara",
		Fish = "Hot Cocoa",
		BellAmount = 100,
		SpecialRewards = {}
	},
	{
		Name = "Tinsel Tom",
		Fish = "Sparkling Tinsel Trout",
		BellAmount = 250,
		SpecialRewards = {}
	},
	{
		Name = "Eggnog Edna",
		Fish = "Glass of Eggnog",
		BellAmount = 100,
		SpecialRewards = {}
	},
	{
		Name = "Snowball Sam",
		Fish = "15 Snowballs",
		BellAmount = 500,
		SpecialRewards = {
			{
				"ItemOrFish",
				"Festive Relic",
				{
					Weight = 21
				},
				1
			}
		}
	},
	{
		Name = "Ornament Ozzie",
		Fish = "Shiny Sparkling Ornament Pufferfish",
		BellAmount = 350,
		SpecialRewards = {}
	},
	{
		Name = "Holly Hannah",
		Fish = "Merry Wreath Wrasse",
		BellAmount = 250,
		SpecialRewards = {}
	},
	{
		Name = "Santa Shark",
		Fish = "Merry Santa Whale Shark",
		BellAmount = 650,
		SpecialRewards = {
			{
				"ItemOrFish",
				"Festive Relic",
				{
					Weight = 21
				},
				1
			}
		}
	},
	{
		Name = "Mistletoe Max",
		Fish = "Mistletoe Minnow",
		BellAmount = 100,
		SpecialRewards = {}
	},
	{
		Name = "Fruitcake Frank",
		Fish = "Gingerbread Fruitcake Flounder",
		BellAmount = 250,
		SpecialRewards = {}
	},
	{
		Name = "Bauble Bella",
		Fish = "Shiny Sparkling Bauble Bass",
		BellAmount = 350,
		SpecialRewards = {}
	},
	{
		Name = "Stocking Steve",
		Fish = "Merry Stockingfish",
		BellAmount = 250,
		SpecialRewards = {}
	},
	{
		Name = "Elfred",
		Fish = "Elf Eel",
		BellAmount = 100,
		SpecialRewards = {}
	},
	{
		Name = "Present Piper",
		Fish = "Shiny Snowy Present",
		BellAmount = 350,
		SpecialRewards = {}
	},
	{
		Name = "Jolly Jorah",
		Fish = "Merry Jolly Bait Crate",
		BellAmount = 250,
		SpecialRewards = {}
	}
} do
	FischmasFetch[`Fischmas{k}`] = {
		DisplayName = `Fischmas - {v.Name}`,
		Icon = "rbxassetid://78476264790401",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Side",
		AcceptIndicatorTag = `Fischmas{k}`,
		NavigationTargets = {
			{
				Zone = "Northstar Village",
				Tags = { (`Fischmas{k}`) }
			}
		},
		ExpiresAt = module.ExpiresAt,
		Description = `Bring a {v.Fish} to {v.Name}`,
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				`Cache.Fischmas{k}`,
				true,
				(`Bring a "{v.Fish}" to {v.Name}`)
			}
		},
		Rewards = {
			{ "LocalCurrency", "Bells", v.BellAmount }
		}
	}

	for _, specialReward in ipairs(v.SpecialRewards) do
		table.insert(FischmasFetch[`Fischmas{k}`].Rewards, specialReward)
	end
end

table.insert(FischmasFetch.Fischmas20.Rewards, { "Title", "🎄" })
return FischmasFetch