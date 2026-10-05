local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Currency = require(ReplicatedStorage.Modules.Currency)
local generator = Currency.Generator(1)
return {
	{
		Name = "Default",
		Display = "Default",
		Description = "The default house skin.",
		Thumbnails = {
			"rbxassetid://18670066246",
			"rbxassetid://18670066576",
			"rbxassetid://18670067019",
			"rbxassetid://18670067491",
			"rbxassetid://18670067891",
			"rbxassetid://18670068280",
			"rbxassetid://18670068764",
			"rbxassetid://18670069109"
		},
		Price = 0,
		Offsale = true
	},
	{
		Name = "Modern",
		Display = "Modern House",
		Description = "A modernized verison of the Neighbors house.",
		Thumbnails = {
			"rbxassetid://18669986283",
			"rbxassetid://18669986701",
			"rbxassetid://18669986989",
			"rbxassetid://18669987286",
			"rbxassetid://18669987619",
			"rbxassetid://18669988157",
			"rbxassetid://18669988689",
			"rbxassetid://18669989727"
		},
		Price = generator(350),
		Offsale = false
	},
	{
		Name = "Cabin",
		Display = "Cabin",
		Description = "A house for the Neighbors in the forest.",
		Thumbnails = {
			"rbxassetid://96483858657184",
			"rbxassetid://114318313859303",
			"rbxassetid://92458619468703",
			"rbxassetid://101251788396658",
			"rbxassetid://76568638132690",
			"rbxassetid://76749589154998",
			"rbxassetid://137135324261467",
			"rbxassetid://77908072511272"
		},
		Price = generator(500),
		Offsale = false
	},
	{
		Name = "Japandi",
		Display = "Japandi",
		Description = "Minimalist and cozy—where Japan meets Scandinavia.",
		Thumbnails = {
			"rbxassetid://94875080779192",
			"rbxassetid://82051222137905",
			"rbxassetid://96494333033825",
			"rbxassetid://124789797544661",
			"rbxassetid://102663105353793",
			"rbxassetid://131957726070401",
			"rbxassetid://129762503896644",
			"rbxassetid://83216081840257"
		},
		Price = generator(700),
		Offsale = false
	},
	{
		Name = "Hipster",
		Display = "Hipster House",
		Description = "Hippy house, spread the love.",
		Thumbnails = {
			"rbxassetid://105627347513734",
			"rbxassetid://98013231197179",
			"rbxassetid://123833913990215",
			"rbxassetid://129259843461747",
			"rbxassetid://119126095976597",
			"rbxassetid://109538155322713",
			"rbxassetid://109013824566845",
			"rbxassetid://122652324808309",
			"rbxassetid://93514473358537",
			"rbxassetid://104975217285869"
		},
		Price = generator(450),
		Offsale = false
	},
	{
		Name = "LuxuryHome",
		Display = "Luxury House",
		Description = "A house for the fanciest of Neighbors.",
		Thumbnails = {
			"rbxassetid://18669966813",
			"rbxassetid://18669967583",
			"rbxassetid://18669968420",
			"rbxassetid://18669968818",
			"rbxassetid://18669969146",
			"rbxassetid://18669969721",
			"rbxassetid://18669966464",
			"rbxassetid://18669970179"
		},
		Price = generator(2000),
		Offsale = false
	},
	{
		Name = "Amberwood",
		Display = "Amberwood House",
		Description = "A warm and elegant home crafted from amber wood where luxury meets nature.",
		Thumbnails = {
			"rbxassetid://85914133832897",
			"rbxassetid://102060805060647",
			"rbxassetid://81367827943056",
			"rbxassetid://134135364905512",
			"rbxassetid://110366179416128",
			"rbxassetid://122853669273168",
			"rbxassetid://85164185386762",
			"rbxassetid://139919323319438"
		},
		Price = generator(1250),
		Offsale = false
	}
}