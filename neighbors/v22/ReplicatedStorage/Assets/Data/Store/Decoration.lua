local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Currency = require(ReplicatedStorage.Modules.Currency)
require(ReplicatedStorage.Modules.SpriteSheet)
local generator = Currency.Generator(1)
local v = {
	Basic = generator(30),
	Decent = generator(60),
	Good = generator(150),
	Amazing = generator(300),
	Offsale = generator(1e999)
}
local Decoration = {
	Avatar = {
		Bookworm = {
			Display = "Bookworm",
			Image = "rbxassetid://93566435418889",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Good,
			Description = "Bookworm."
		},
		Art = {
			Display = "Art",
			Image = "rbxassetid://73718890535115",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Price = v.Good,
			Description = "Embracing your artistic side"
		},
		Crayon = {
			Display = "Crayon",
			Image = "rbxassetid://80296566869191",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = false,
			Rarity = "Royalty",
			Price = v.Good,
			Description = "Don't ruin the walls now!"
		},
		["Blades of Grass"] = {
			Display = "Blades of Grass",
			Image = "rbxassetid://121192988895930",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = false,
			Rarity = "Royalty",
			Price = v.Good,
			Description = "Maybe you can run along them?"
		},
		Brainss = {
			Display = "Brainss",
			Image = "rbxassetid://136389072762581",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Good,
			Description = "Smarty pants."
		},
		["Sovereign Shells"] = {
			Display = "Sovereign Shells",
			Image = "rbxassetid://75763232211597",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = false,
			Rarity = "Royalty",
			Price = v.Good,
			Description = "Crown of the shells."
		},
		Surfboards = {
			Display = "Surfboards",
			Image = "rbxassetid://90466674708300",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = false,
			Price = v.Basic,
			Description = "Beach and surfs!"
		},
		["4th Flags"] = {
			Display = "4th Flags",
			Image = "rbxassetid://90123070049557",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Flags of the 4th"
		},
		["Eagles Embrace"] = {
			Display = "Eagles Embrace",
			Image = "rbxassetid://81251410416954",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "The american eagle."
		},
		["4th Fireworks"] = {
			Display = "4th Fireworks",
			Image = "rbxassetid://101220875773559",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Fireworks of the 4th"
		},
		["Celebration Rockets"] = {
			Display = "Celebration Rockets",
			Image = "rbxassetid://79075485100200",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Rockets to light up the night sky."
		},
		["4th Starry Popsicle"] = {
			Display = "4th Starry Popsicle",
			Image = "rbxassetid://134252485569678",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "A tasty icy delight."
		},
		["Founders Hat"] = {
			Display = "Founders Hat",
			Image = "rbxassetid://73007740346468",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "The hat you should wear on the 4th."
		},
		["Chick Ring"] = {
			Display = "Chick Ring",
			Image = "rbxassetid://129858647127627",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Ring of chicks."
		},
		["Choco Egg"] = {
			Display = "Choco Egg",
			Image = "rbxassetid://120105248470318",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Chocolate egg, what was inside?"
		},
		["Egg Basket"] = {
			Display = "Egg Basket",
			Image = "rbxassetid://123730721678697",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Price = v.Good,
			Description = "Basket of Eggs."
		},
		["Egg Meadow"] = {
			Display = "Egg Meadow",
			Image = "rbxassetid://78230865223366",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Price = v.Good,
			Description = "A meadow of eggs, maybe you'll find a lucky one."
		},
		["Leaping Bunny"] = {
			Display = "Leaping Bunny",
			Image = "rbxassetid://117319397091491",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Price = v.Good,
			Description = "Little bunny jumping over your head."
		},
		["Bunny Wreath"] = {
			Display = "Bunny Wreath",
			Image = "rbxassetid://72912763006734",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Price = v.Good,
			Description = "A wreath of little bunnies."
		},
		["Coin Swirl"] = {
			Display = "Coin Swirl",
			Image = "rbxassetid://79853937078952",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Luck is the new currency!"
		},
		["Lucky Horseshoe"] = {
			Display = "Lucky Horseshoe",
			Image = "rbxassetid://79273368604917",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "The original good luck charm."
		},
		["Charm Circle"] = {
			Display = "Charm Circle",
			Image = "rbxassetid://87635584994794",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Six kinds of lucky."
		},
		["Lucky Topper"] = {
			Display = "Lucky Topper",
			Image = "rbxassetid://121963640586435",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Top o’ the morning to ya!"
		},
		["Rainbow Riches"] = {
			Display = "Rainbow Riches",
			Image = "rbxassetid://81192896037644",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Chasing dreams and gold pots."
		},
		["Shamrock Vine"] = {
			Display = "Shamrock Vine",
			Image = "rbxassetid://130090235511232",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Green is my signature color."
		},
		["Gilded Moon"] = {
			Display = "Gilded Moon",
			Image = "rbxassetid://91465792445432",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Ramadan Kareem!"
		},
		["Hanging Glow"] = {
			Display = "Hanging Glow",
			Image = "rbxassetid://136727256712863",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Ramadan Kareem!"
		},
		["Thorns of Love"] = {
			Display = "Thorns of Love",
			Image = "rbxassetid://72605562091031",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Sometimes love just feels like a thorn"
		},
		["Love Delight"] = {
			Display = "Love Delight",
			Image = "rbxassetid://85099791941966",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "A love so delightful you wish you could taste it"
		},
		["Sweet Sayings"] = {
			Display = "Sweet Sayings",
			Image = "rbxassetid://72521583967569",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "A whole lot of compliments to compliment your profile!"
		},
		["Sweet Circle"] = {
			Display = "Sweet Circle",
			Image = "rbxassetid://117128352327683",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "A whole lot of chocolates to compliment your profile!"
		},
		["Shot By Cupid"] = {
			Display = "Shot By Cupid",
			Image = "rbxassetid://107247535049495",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "You are now bound to fall in love."
		},
		["Locked In"] = {
			Display = "Locked In",
			Image = "rbxassetid://106123506555588",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "LOCKED IN."
		},
		["Heart Elixir"] = {
			Display = "Heart Elixir",
			Image = "rbxassetid://96103494457886",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Don't drink too much of it, you might fall in overwhelming love."
		},
		["Blossoming Beauty"] = {
			Display = "Blossoming Beauty",
			Image = "rbxassetid://138279572657924",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Stand out with blossoming beauty, especially on valentines day."
		},
		["New Years Decor"] = {
			Display = "New Years",
			Image = "rbxassetid://137390753584675",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "It's 2026 once every lifetime."
		},
		["2026"] = {
			Display = "2026",
			Image = "rbxassetid://139970795589629",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Isn't it crazy that we're closer to 2030 than we are to 2020?"
		},
		["Party Blower"] = {
			Display = "Party Blower",
			Image = "rbxassetid://82901390783647",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "HAPPY NEW YEARS!! 🥳"
		},
		["Fireworks Decor"] = {
			Display = "Fireworks",
			Image = "rbxassetid://129201415288807",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "I don't think fireworks goes there..."
		},
		Wreath = {
			Display = "Wreath",
			Image = "rbxassetid://124947366159165",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Uncommon",
			Price = v.Offsale,
			Description = "I don't think a wreath goes there."
		},
		["Santa's Elf"] = {
			Display = "Santa's Elf",
			Image = "rbxassetid://133890990010696",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Uncommon",
			Price = v.Offsale,
			Description = "Santa's little elf."
		},
		Cookie = {
			Display = "Cookie",
			Image = "rbxassetid://100892277526443",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Uncommon",
			Price = v.Offsale,
			Description = "Yum!"
		},
		["Xmas Lights"] = {
			Display = "Xmas Lights",
			Image = "rbxassetid://100526736634374",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Uncommon",
			Price = v.Offsale,
			Description = "Shining bright, showing off the Christmas Spirit!"
		},
		["Pumpkin Pie"] = {
			Display = "Pumpkin Pie",
			Image = "rbxassetid://101222324462038",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Uncommon",
			Price = v.Offsale,
			Description = "Celebrating harvest and Pumpkin Pie!"
		},
		PilgrimProfile = {
			Display = "Pilgrim",
			Image = "rbxassetid://113624090450176",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Uncommon",
			Price = v.Offsale,
			Description = "Celebrating harvest and gratitude!"
		},
		["Cursed Pulse"] = {
			Display = "Cursed Pulse",
			Image = "rbxassetid://78566746559359",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Common",
			Price = v.Offsale,
			Description = "A heartbeat from the underworld—each swing thrums with dark energy, spreading fear with every strike."
		},
		["Hallows Pulse"] = {
			Display = "Hallows Pulse",
			Image = "rbxassetid://99937452854477",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Common",
			Price = v.Offsale,
			Description = "Fueled by the spirit of Halloween itself, its glow beats like a haunted heart in the dark."
		},
		Valedictorians = {
			Display = "Valedictorians",
			Image = "rbxassetid://134889046173293",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Cap off your profile with scholarly style!"
		},
		["Study Nook"] = {
			Display = "Study Nook",
			Image = "rbxassetid://89709576103019",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "Unleash your inner scholar with this Study-tastic decoration!"
		},
		["Deputy Drip"] = {
			Display = "Deputy Drip",
			Image = "rbxassetid://138812386301042",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Uncommon",
			Price = v.Offsale,
			Description = "There's a snake in my boot!"
		},
		["Cuddly Bear"] = {
			Display = "Cuddly Bear",
			Image = "rbxassetid://100299000661320",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "A friendly bear hug around your profile!"
		},
		["Gleeble Glorp"] = {
			Display = "Gleeble Glorp",
			Image = "rbxassetid://100782513547817",
			Size = UDim2.new(0.85, 24, 0.85, 16),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "👽👽"
		},
		["Cosmic Cow-Napping"] = {
			Display = "Cosmic Cow-Napping",
			Image = "rbxassetid://80711573834785",
			Size = UDim2.new(0.85, 24, 0.85, 16),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Uncommon",
			Price = v.Offsale,
			Description = "Beamed up in style!"
		},
		["Hypno-Hop"] = {
			Display = "Hypno-Hop",
			Image = "rbxassetid://105774494041650",
			Size = UDim2.new(0.85, 24, 0.85, 16),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "Straight from the mothership—ribbit!"
		},
		Skyfire = {
			Display = "Skyfire",
			Image = "rbxassetid://134007158587820",
			Size = UDim2.new(0.85, 24, 0.85, 16),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "Engines primed for warp-speed style!"
		},
		WitchHat = {
			Display = "Witch",
			Image = "rbxassetid://15056813688",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "I can almost hear the cackling!"
		},
		BlossomWings = {
			Display = "Blossom Wings",
			Image = "rbxassetid://15090435973",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Basic,
			Description = "How amazing!"
		},
		Fangs = {
			Display = "Fangs",
			Image = "rbxassetid://97456322249967",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "I'm hungry!"
		},
		Ghost = {
			Display = "Ghost",
			Image = "rbxassetid://123129077914138",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Boooooo!"
		},
		Bats = {
			Display = "Bats",
			Image = "rbxassetid://131730752276357",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Cover the night sky!"
		},
		SkeletonHands = {
			Display = "Skeleton Hands",
			Image = "rbxassetid://96309030433385",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Spooky grabbers!"
		},
		Grapes = {
			Display = "Grapes",
			Image = "rbxassetid://75953187639782",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Basic,
			Description = "Do it for the vine!"
		},
		KittyCat = {
			Display = "Kitty Cat",
			Image = "rbxassetid://108018358313369",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Basic,
			Description = "Meowww!"
		},
		Mango = {
			Display = "Mango",
			Image = "rbxassetid://94554212064125",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Basic,
			Description = "The best fruit, of course!"
		},
		WaterSlide = {
			Display = "Water Slide",
			Image = "rbxassetid://117418209931783",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Decent,
			Description = "Take a fun ride down the water slide!"
		},
		Water = {
			Display = "Water",
			Image = "rbxassetid://111334937467581",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Decent,
			Description = "Splash splash splash away!"
		},
		VaporWave = {
			Display = "Vapor Wave",
			Image = "rbxassetid://123867450468544",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Decent,
			Description = "Chill vibes all around."
		},
		Umbrella = {
			Display = "Umbrella",
			Image = "rbxassetid://97060823171841",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Decent,
			Description = "Get under the umbrella!"
		},
		Scarf = {
			Display = "Scarf",
			Image = "rbxassetid://87788725809997",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			Description = "Cozy, festive, and full of fall spirit!",
			HidePurchaseButton = true
		},
		["Turkey Tail"] = {
			Display = "Turkey Tail",
			Image = "rbxassetid://79286479754034",
			Size = UDim2.new(1, 16, 1, 16),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			Description = "Gobble Gobble!",
			HidePurchaseButton = true
		},
		Sprout = {
			Display = "Sprout",
			Image = "rbxassetid://117824389819749",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Basic,
			Description = "Just a little sprout!"
		},
		Shocker = {
			Display = "Shocker",
			Image = "rbxassetid://98458340622020",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Good,
			Description = "Don't get zapped!"
		},
		Puppy = {
			Display = "Puppy",
			Image = "rbxassetid://81677124713600",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Decent,
			Description = "Just like the filter!"
		},
		Butterfly = {
			Display = "Butterfly",
			Image = "rbxassetid://99686849425840",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Decent,
			Description = "Fly like a butterfly, sting like a bee!"
		},
		Lantern = {
			Display = "Lantern",
			Image = "rbxassetid://110358608249038",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Decent,
			Description = "Lets light this place up!"
		},
		LadyBug = {
			Display = "Lady Bug",
			Image = "rbxassetid://124383005668244",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Basic,
			Description = "Just a harmless insect."
		},
		Dragon = {
			Display = "Dragon",
			Image = "rbxassetid://95527722221091",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Amazing,
			Description = "The most fierce animal in the kingdom!"
		},
		Devil = {
			Display = "Devil",
			Image = "rbxassetid://115889853469912",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Good,
			Description = "Evil lurks..."
		},
		Candles = {
			Display = "Candles",
			Image = "rbxassetid://98723794771271",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Their glow wards off spirits… or summons them."
		},
		["Plant Eater"] = {
			Display = "Plant Eater",
			Image = "rbxassetid://139819198820069",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "It doesn’t eat meat… only screams and leaves."
		},
		Cauldron = {
			Display = "Cauldron",
			Image = "rbxassetid://103109441063466",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Decent,
			HidePurchaseButton = true,
			Description = "Brewed from the darkest nights and strangest sights."
		},
		Medusa = {
			Display = "Medusa",
			Image = "rbxassetid://118387078044546",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Serpents coil, and silence follows."
		},
		Boltface = {
			Display = "Boltface",
			Image = "rbxassetid://123879145148305",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "The bolts that sparked life into a legend."
		},
		["Scissor Hands"] = {
			Display = "Scissor Hands",
			Image = "rbxassetid://112491129939603",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Snip, snip… don’t get too close."
		},
		Thing = {
			Display = "Thing",
			Image = "rbxassetid://90770773960043",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Always lending a hand… literally."
		},
		Organs = {
			Display = "Organs",
			Image = "rbxassetid://111880749721589",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Beating, pulsing… and watching you."
		},
		Branches = {
			Display = "Branches",
			Image = "rbxassetid://89397508237032",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Twisted limbs that reach into the shadows."
		},
		Nightpaws = {
			Display = "Nightpaws",
			Image = "rbxassetid://90887995211345",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Eyes that glow, claws that strike."
		},
		Infected = {
			Display = "Infected",
			Image = "rbxassetid://80805199351190",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Brainsssss..."
		},
		Ravens = {
			Display = "Ravens",
			Image = "rbxassetid://124398066260854",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "A messenger from the dark unknown."
		},
		["Window Frame"] = {
			Display = "Window Frame",
			Image = "rbxassetid://122423759993738",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AppearUnderProfile = true,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Their glow wards off spirits… or summons them."
		},
		DarkBow = {
			Display = "Dark Bow",
			Image = "rbxassetid://79738482840599",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Amazing,
			Description = "Nice pretty little bow!"
		},
		Cowboy = {
			Display = "Cowboy",
			Image = "rbxassetid://83833377494700",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Good,
			Description = "YEHAWWWWWWW!"
		},
		Banana = {
			Display = "Banana",
			Image = "rbxassetid://75951362554335",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Decent,
			Description = "Get your potassium in!"
		},
		Axolotl = {
			Display = "Axolotl",
			Image = "rbxassetid://111357784602176",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Amazing,
			Description = "The most awesome sea creature around!"
		},
		AlienCat = {
			Display = "Alien Cat",
			Image = "rbxassetid://101457545354525",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Price = v.Amazing,
			Description = "This cat is out of this world!"
		},
		["Bat Hero"] = {
			Display = "Bat Hero",
			Image = "rbxassetid://112999114878325",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Unique",
			Price = v.Offsale,
			Description = "The Darkest Knight"
		},
		["The Raven"] = {
			Display = "Raven",
			Image = "rbxassetid://106511512605757",
			Size = UDim2.new(0.85, 24, 0.85, 16),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "Evil beware, we have waffles"
		},
		["The Shield"] = {
			Display = "Cpt. Neighbors",
			Image = "rbxassetid://86449636014318",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "On your left."
		},
		["Amazing Woman"] = {
			Display = "Amazing Woman",
			Image = "rbxassetid://105118923853849",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Unique",
			Price = v.Offsale,
			Description = "The lasso compels you!"
		},
		Airship = {
			Display = "Airship",
			Image = "rbxassetid://84061003517778",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Sail in the sky!"
		},
		Steamworks = {
			Display = "Steamworks",
			Image = "rbxassetid://121370955643830",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "Let off some steam!"
		},
		["Kitty Paws"] = {
			Display = "Kitty Paws",
			Image = "rbxassetid://78092176040373",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Goes well with the Pawlord title"
		},
		["Kitty Ears"] = {
			Display = "Kitty Ears",
			Image = "rbxassetid://127778951603669",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Unique",
			Price = v.Offsale,
			Description = "Careful, might bite"
		},
		["Heart & Dagger"] = {
			Display = "Heart & Dagger",
			Image = "rbxassetid://134608853907075",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "And it began to bleed."
		},
		["Sad Skulls"] = {
			Display = "Sad Skulls",
			Image = "rbxassetid://106918495333068",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "They're just so sad"
		},
		Anubis = {
			Display = "Anubis",
			Image = "rbxassetid://81855654492410",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Uncommon",
			Price = v.Offsale,
			Description = "Become the King of Egypt."
		},
		["Scarab Circlet"] = {
			Display = "Scarab Circlet",
			Image = "rbxassetid://83039460129392",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Unique",
			Price = v.Offsale,
			Description = "Curse of the Scarab"
		},
		["Wilted Rose"] = {
			Display = "Wilted Rose",
			Image = "rbxassetid://126347059979992",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Unique",
			Price = v.Offsale,
			Description = "Falling like a petal"
		},
		Guts = {
			Display = "Guts",
			Image = "rbxassetid://120066148402778",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "Is this a berserk reference?"
		},
		Doves = {
			Display = "Doves",
			Image = "rbxassetid://98092315403608",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "An Angelic Dove to perch on your head."
		},
		["Stained Glass"] = {
			Display = "Stained Glass",
			Image = "rbxassetid://72529605140672",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "This will project a myriad of colors onto you."
		},
		["Dark Clouds"] = {
			Display = "Dark Clouds",
			Image = "rbxassetid://104091221998267",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "Some Dark Clouds for those rainy days."
		},
		Tsunami = {
			Display = "Tsunami",
			Image = "rbxassetid://111925453546589",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "These waves seem oddly familiar."
		},
		["Leafy Acorns"] = {
			Display = "Leafy Acorns",
			Image = "rbxassetid://139764853777908",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "For those autumn days."
		},
		["Friendly Raccoon"] = {
			Display = "Friendly Raccoon",
			Image = "rbxassetid://94219729738137",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Just a lil guy keeping you company."
		},
		Cappuccina = {
			Display = "Cappuccina",
			Image = "rbxassetid://111709540865495",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "Feel like a ballerina."
		},
		["Six Seven"] = {
			Display = "Six Seven",
			Image = "rbxassetid://133134606013695",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "PLEASE MAKE IT STOP."
		},
		["Dominus Hackerous"] = {
			Display = "Dominus Hackerous",
			Image = "rbxassetid://103661207251094",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "Super hackerman!"
		},
		Glitch = {
			Display = "Glitch",
			Image = "rbxassetid://102184808346153",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "M-must b-be.. be a g-lliitch."
		},
		["Fluffy Flower"] = {
			Display = "Fluffy Flower",
			Image = "rbxassetid://102491613359416",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Royalty",
			Price = v.Offsale,
			Description = "The fluffiest flower!"
		},
		["Cozy Kitty"] = {
			Display = "Cozy Kitty",
			Image = "rbxassetid://84778482388728",
			Size = UDim2.new(1, 18, 1, 18),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			HidePurchaseButton = true,
			Rarity = "Rare",
			Price = v.Offsale,
			Description = "Like a kitty near a warm fire."
		}
	},
	Banner = {
		ColorfulCorridor = {
			Display = "Colorful Corridor",
			Image = "rbxassetid://95114155454446",
			LimitedDecor = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = true,
			Description = "A lovely myriad."
		},
		DailyCommute = {
			Display = "Daily Commute",
			Image = "rbxassetid://128232451564510",
			LimitedDecor = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = false,
			Description = "Don't forget your life outside of your commute!"
		},
		DeansList = {
			Display = "Deans List",
			Image = "rbxassetid://73797716133058",
			LimitedDecor = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = false,
			Description = "Can't be that bad right?"
		},
		FirstDay = {
			Display = "First Day",
			Image = "rbxassetid://112920118300652",
			LimitedDecor = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = false,
			Description = "Show up with confidence, do so much work that it's impossible for you to fail!"
		},
		StudySession = {
			Display = "Study Session",
			Image = "rbxassetid://130839365231655",
			LimitedDecor = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = false,
			Description = "Remember to drink water and take breaks!"
		},
		WrittenAssignment = {
			Display = "Written Assignment",
			Image = "rbxassetid://89701669759238",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = false,
			Description = "The faster it's done, the less time you spend thinking about it!"
		},
		MelancholyClassroom = {
			Display = "Melancholy Classroom",
			Image = "rbxassetid://96585463037650",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = false,
			Description = "Just rest..."
		},
		BeachShore = {
			Display = "Beach Shore",
			Image = "rbxassetid://110659726775514",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "Colorful seashells and a surfboard rest where sand meets sparkling ocean waves."
		},
		DeepJellyfish = {
			Display = "Deep Jellyfish",
			Image = "rbxassetid://96942789220649",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "Bioluminescent blue jellyfish drift through deep ocean waters."
		},
		SandCastle = {
			Display = "Sand Castle",
			Image = "rbxassetid://111760690391311",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "A sandcastle sits on a sunny beach beside a tipped-over red bucket."
		},
		SummerMeadow = {
			Display = "Summer Meadow",
			Image = "rbxassetid://87119353275012",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "A cartoon caterpillar and bee wander through a bright, breezy green meadow."
		},
		SunsetSkate = {
			Display = "Sunset Skate",
			Image = "rbxassetid://107635276427782",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "Stick figures skate in a graffiti park under a vibrant sunset."
		},
		TropicalSunset = {
			Display = "Tropical Sunset",
			Image = "rbxassetid://134799539573560",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "Silhouetted palm trees and hammocks frame a massive, glowing sunset."
		},
		TwinSeagulls = {
			Display = "Twin Seagulls",
			Image = "rbxassetid://85642546660310",
			LimitedDecor = os.time({
				year = 2026,
				month = 8,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "A stylized, symmetrical close-up of a seagull's yellow eyes and orange beak."
		},
		TimelessLegacy = {
			Display = "Timeless Legacy",
			Image = "rbxassetid://109434822333247",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "A stained-glass tribute to freedom and time."
		},
		StarSpangled = {
			Display = "Star Spangled",
			Image = "rbxassetid://138867281528381",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Stars and stripes waving in the wind."
		},
		ProudAmerica = {
			Display = "Proud America",
			Image = "rbxassetid://107974389690608",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "A sky-high celebration of the nation."
		},
		PatriotsHonor = {
			Display = "Patriots Honor",
			Image = "rbxassetid://121265927159908",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Holding the flag high with pride."
		},
		InUnity = {
			Display = "In Unity",
			Image = "rbxassetid://71844290441214",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "United in colors and purpose."
		},
		HeroicHeritage = {
			Display = "Heroic Heritage",
			Image = "rbxassetid://104885851672968",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Bold stripes and stars for a heroic look."
		},
		FoundedFreedom = {
			Display = "Founded Freedom",
			Image = "rbxassetid://71511081095311",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "A skyline built on freedom."
		},
		StripedEggs = {
			Display = "Striped Eggs",
			Image = "rbxassetid://123497460375559",
			Price = v.Good,
			Description = "Lucky... these striped eggs are rare!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		BunBeneathTheStars = {
			Display = "Bun Beneath the Stars",
			Image = "rbxassetid://101966581952071",
			Price = v.Good,
			Description = "For those who know tea.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		PixelPeekaboo = {
			Display = "Pixel Peekaboo",
			Image = "rbxassetid://116086707587290",
			Price = v.Good,
			Description = "PEEKABOOOOOOOOOOOOOO!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		WackABunny = {
			Display = "Wack a' Bunny",
			Image = "rbxassetid://130220582243848",
			Price = v.Good,
			Description = "Can you spot the bunny?",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		SunsettingBunnies = {
			Display = "Sunsetting Bunnies",
			Image = "rbxassetid://102799672729012",
			Price = v.Good,
			Description = "Couple of bunnies, enjoying the sunset.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		AmongstTheEggs = {
			Display = "Amongst the Eggs",
			Image = "rbxassetid://135746786064838",
			Price = v.Good,
			Description = "They're shy, hiding behind the eggs",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		CoquetteBunnies = {
			Display = "Coquette Bunnies",
			Image = "rbxassetid://88018751131085",
			Price = v.Good,
			Description = "Pink pink pink BUNNIES!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		CarrotGazing = {
			Display = "Carrot Gazing",
			Image = "rbxassetid://136274626722741",
			Price = v.Basic,
			Description = "Admiring the delicious carrots!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		Bunnies = {
			Display = "Bunnies",
			Image = "rbxassetid://79623462823194",
			Price = v.Basic,
			Description = "Bunnies everywhere",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		DryingBunnies = {
			Display = "Drying Bunnies",
			Image = "rbxassetid://135613644011695",
			Price = v.Basic,
			Description = "5 Cutie bunnies drying off for the day.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		DaydreamingBunny = {
			Display = "Daydreaming Bunny",
			Image = "rbxassetid://135613644011695",
			Price = v.Basic,
			Description = "Daydreaming on a blossoming branch, DON'T FALL!.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		ModerationBanner = {
			Display = "Moderation Banner",
			Image = "rbxassetid://95984125415111",
			Price = 0,
			Description = "For those who know ball.",
			ScaleType = Enum.ScaleType.Crop,
			RequiredRank = 100
		},
		PinkModerationBanner = {
			Display = "Pink Moderation Banner",
			Image = "rbxassetid://106278916178812",
			Price = 0,
			Description = "For those who know tea.",
			ScaleType = Enum.ScaleType.Crop,
			RequiredRank = 100
		},
		EndoftheRainbow = {
			Display = "End of the Rainbow",
			Image = "rbxassetid://135180949950468",
			Price = v.Offsale,
			Description = "A view worth its weight in gold.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		GoldSprinkles = {
			Display = "Gold Sprinkles",
			Image = "rbxassetid://116207487449877",
			Price = v.Offsale,
			Description = "Sprinkling a little fortune on your day!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		LuckyCheers = {
			Display = "Lucky Cheers",
			Image = "rbxassetid://74455817446249",
			Price = v.Offsale,
			Description = "Hats on, mugs up.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		["2026"] = {
			Display = "2026",
			Image = "rbxassetid://131960142858459",
			Price = v.Decent,
			Description = "Happy new year!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		FestiveDecoration = {
			Display = "Festive Decoration",
			Image = "rbxassetid://105268401252751",
			Price = v.Offsale,
			Description = "Make your profile festive with this decoration!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		SantaClaus = {
			Display = "Santa Claus",
			Image = "rbxassetid://91625632522653",
			Price = v.Offsale,
			Description = "Ho Ho HO!.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		Snowflakes = {
			Display = "Snowflakes",
			Image = "rbxassetid://138292571296973",
			Price = v.Offsale,
			Description = "Small, white snowflake shapes.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		Snowmen = {
			Display = "Snowmen",
			Image = "rbxassetid://136156943929197",
			Price = v.Offsale,
			Description = "Look at them, they're adorable!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		SnowyHouse = {
			Display = "Snowy House",
			Image = "rbxassetid://105302779824914",
			Price = v.Offsale,
			Description = "A secluded, cozy cute house.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		SnowySled = {
			Display = "Snowy Sled",
			Image = "rbxassetid://118290242758807",
			Price = v.Offsale,
			Description = "Isn't she having the time of her life?",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		StarryCity = {
			Display = "Starry City",
			Image = "rbxassetid://129149631026637",
			Price = v.Decent,
			Description = "A city skyline under a night sky with stars!",
			ScaleType = Enum.ScaleType.Crop
		},
		Trees = {
			Display = "Trees",
			Image = "rbxassetid://138730749438017",
			Price = v.Offsale,
			Description = "Simple green trees.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		VibrantLights = {
			Display = "Vibrant Lights",
			Image = "rbxassetid://124408315394415",
			Price = v.Good,
			Description = "Bright, colorful lights!",
			ScaleType = Enum.ScaleType.Crop
		},
		CrimsonFlow = {
			Display = "Crimson Flow",
			Image = "rbxassetid://78546067420473",
			Price = v.Basic,
			Description = "Reds that scream adventure!",
			ScaleType = Enum.ScaleType.Crop
		},
		HeartBonk = {
			Display = "Heart Bonk",
			Image = "rbxassetid://87501525929009",
			Price = v.Basic,
			Description = "Smash hearts, not feelings.",
			ScaleType = Enum.ScaleType.Crop
		},
		Meowtrix = {
			Display = "Meowtrix",
			Image = "rbxassetid://75029449098937",
			Price = v.Decent,
			Description = "Cats taking over the grid!",
			ScaleType = Enum.ScaleType.Crop
		},
		NightBound = {
			Display = "Night Bound",
			Image = "rbxassetid://140317406393596",
			Price = v.Basic,
			Description = "When the stars call your name.",
			ScaleType = Enum.ScaleType.Crop
		},
		TrafficJammed = {
			Display = "Traffic Jammed",
			Image = "rbxassetid://72888964990374",
			Price = v.Basic,
			Description = "Stop-and-go has never looked this cool.",
			ScaleType = Enum.ScaleType.Crop
		},
		RibbitWave = {
			Display = "Ribbit Wave",
			Image = "rbxassetid://108963958162448",
			Price = v.Decent,
			Description = "Frogs riding cosmic tides.",
			ScaleType = Enum.ScaleType.Crop
		},
		Waveglow = {
			Display = "Waveglow",
			Image = "rbxassetid://104923777285971",
			Price = v.Basic,
			Description = "Surf’s up in neon vibes!",
			ScaleType = Enum.ScaleType.Crop
		},
		WatchersGaze = {
			Display = "Watchers Gaze",
			Image = "rbxassetid://107924366313252",
			Price = v.Decent,
			Description = "Someone is always watching… wink wink.",
			ScaleType = Enum.ScaleType.Crop
		},
		TheLurking = {
			Display = "The Lurking",
			Image = "rbxassetid://133655138555665",
			Price = v.Basic,
			Description = "Shadows have their own fun.",
			ScaleType = Enum.ScaleType.Crop
		},
		SunnyHatch = {
			Display = "Sunny Hatch",
			Image = "rbxassetid://136110317527226",
			Price = v.Basic,
			Description = "Egg-citing mornings guaranteed.",
			ScaleType = Enum.ScaleType.Crop
		},
		SpookySplit = {
			Display = "Spooky Split",
			Image = "rbxassetid://74732090064088",
			Price = v.Basic,
			Description = "Halloween vibes 24/7.",
			ScaleType = Enum.ScaleType.Crop
		},
		SoftMeow = {
			Display = "Soft Meow",
			Image = "rbxassetid://88506839011771",
			Price = v.Decent,
			Description = "Purr-fectly soothing.",
			ScaleType = Enum.ScaleType.Crop
		},
		RisingEmber = {
			Display = "Rising Ember",
			Image = "rbxassetid://124326852765049",
			Price = v.Basic,
			Description = "Feel the heat of style.",
			ScaleType = Enum.ScaleType.Crop
		},
		OpalCrush = {
			Display = "Opal Crush",
			Image = "rbxassetid://133607899737763",
			Price = v.Basic,
			Description = "Shimmer like no one’s watching.",
			ScaleType = Enum.ScaleType.Crop
		},
		OfflineAura = {
			Display = "Offline Aura",
			Image = "rbxassetid://137987440787316",
			Price = v.Decent,
			Description = "Vibe offline, look online.",
			ScaleType = Enum.ScaleType.Crop
		},
		MorningRush = {
			Display = "Morning Rush",
			Image = "rbxassetid://86135005069131",
			Price = v.Decent,
			Description = "Speed through sunrise!",
			ScaleType = Enum.ScaleType.Crop
		},
		MidnightDrift = {
			Display = "Midnight Drift",
			Image = "rbxassetid://106740468820557",
			Price = v.Decent,
			Description = "Glide under moonlit skies.",
			ScaleType = Enum.ScaleType.Crop
		},
		MetroDusk = {
			Display = "Metro Dusk",
			Image = "rbxassetid://73203629895409",
			Price = v.Decent,
			Description = "City lights, dreamy nights.",
			ScaleType = Enum.ScaleType.Crop
		},
		ExpressO = {
			Display = "Express-O",
			Image = "rbxassetid://84674199795032",
			Price = v.Decent,
			Description = "Speed and caffeine combined.",
			ScaleType = Enum.ScaleType.Crop
		},
		CosmicCalm = {
			Display = "Cosmic Calm",
			Image = "rbxassetid://124868594876605",
			Price = v.Decent,
			Description = "Peace out in the galaxy.",
			ScaleType = Enum.ScaleType.Crop
		},
		CatStack = {
			Display = "Cat Stack",
			Image = "rbxassetid://105019394046610",
			Price = v.Decent,
			Description = "Tower of paws incoming.",
			ScaleType = Enum.ScaleType.Crop
		},
		["8BitLife"] = {
			Display = "8-Bit Life",
			Image = "rbxassetid://136576146576280",
			Price = v.Decent,
			Description = "Pixel dreams, retro vibes.",
			ScaleType = Enum.ScaleType.Crop
		},
		Bloomwave = {
			Display = "Bloomwave",
			Image = "rbxassetid://130443304110537",
			Price = v.Decent,
			Description = "Flowers ride neon tides.",
			ScaleType = Enum.ScaleType.Crop
		},
		Webs = {
			Display = "Webs",
			Image = "rbxassetid://15057564813",
			Color = Color3.fromHex("470f67"),
			Transparency = 0.2,
			Price = v.Basic,
			Description = "Someone has to keep these spiders under control."
		},
		Slime = {
			Display = "Slime",
			Image = "rbxassetid://15057520820",
			Transparency = 0.25,
			Price = v.Basic,
			Description = "Who spilled all of this!?"
		},
		Pumpkin = {
			Display = "Pumpkin",
			Image = "rbxassetid://15057076718",
			Color = Color3.fromHex("8b4938"),
			Price = v.Basic,
			Description = ""
		},
		LeavesBanner = {
			Display = "Leaves",
			Image = "rbxassetid://15057447074",
			Color = Color3.fromHex("dd806c"),
			Transparency = 0.35,
			Price = v.Basic,
			Description = "Such calming leaves."
		},
		Ribbons = {
			Display = "Ribbons",
			Image = "rbxassetid://15090436554",
			Color = Color3.fromHex("562878"),
			Transparency = 0.2,
			Size = UDim2.new(1, 0, 1, 12),
			Price = v.Basic,
			Description = ""
		},
		Blossom = {
			Display = "Blossom",
			Image = "rbxassetid://15090436373",
			Color = Color3.fromHex("fc9dad"),
			Transparency = 0.1,
			Price = v.Decent,
			Description = ""
		},
		SunnySky = {
			Display = "Sunny Sky",
			Image = "rbxassetid://15090437096",
			Color = Color3.fromHex("2ccbff"),
			Transparency = 0.15,
			Price = v.Basic,
			Description = "Summer time memories"
		},
		["Bloom Pop"] = {
			Display = "Bloom Pop",
			Image = "rbxassetid://117718082919776",
			Color = Color3.fromHex("2ccbff"),
			Transparency = 0.15,
			Price = v.Offsale,
			Description = "Hearts blooming and popping.",
			HidePurchaseButton = true,
			ScaleType = Enum.ScaleType.Crop
		},
		["Cloud Crush"] = {
			Display = "Cloud Crush",
			Image = "rbxassetid://110380478212445",
			Color = Color3.fromHex("2ccbff"),
			Transparency = 0.15,
			Price = v.Offsale,
			Description = "Heart on cloud 9",
			HidePurchaseButton = true,
			ScaleType = Enum.ScaleType.Crop
		},
		["Dark Bloom"] = {
			Display = "Dark Bloom",
			Image = "rbxassetid://139750291732055",
			Color = Color3.fromHex("2ccbff"),
			Transparency = 0.15,
			Price = v.Offsale,
			Description = "A love so strong.",
			HidePurchaseButton = true,
			ScaleType = Enum.ScaleType.Crop
		},
		["Honey Pop"] = {
			Display = "Honey Pop",
			Image = "rbxassetid://94032266343127",
			Color = Color3.fromHex("2ccbff"),
			Transparency = 0.15,
			Price = v.Offsale,
			Description = "As sweet as honey.",
			HidePurchaseButton = true,
			ScaleType = Enum.ScaleType.Crop
		},
		["Love Leftovers"] = {
			Display = "Love Leftovers",
			Image = "rbxassetid://84715307727365",
			Color = Color3.fromHex("2ccbff"),
			Transparency = 0.15,
			Price = v.Offsale,
			Description = "Someone has to eat them.",
			HidePurchaseButton = true,
			ScaleType = Enum.ScaleType.Crop
		},
		["Nightly Love"] = {
			Display = "Nightly Love",
			Image = "rbxassetid://93791187961574",
			Color = Color3.fromHex("2ccbff"),
			Transparency = 0.15,
			Price = v.Offsale,
			Description = "Under the pink night.",
			HidePurchaseButton = true,
			ScaleType = Enum.ScaleType.Crop
		},
		["Sugar Smiles"] = {
			Display = "Sugar Smiles",
			Image = "rbxassetid://78167407904479",
			Color = Color3.fromHex("2ccbff"),
			Transparency = 0.15,
			Price = v.Offsale,
			Description = "Remember to brush!",
			HidePurchaseButton = true,
			ScaleType = Enum.ScaleType.Crop
		}
	},
	Background = {
		AssignmentOverload = {
			Display = "Assignment Overload",
			Image = "rbxassetid://70975264544723",
			LimitedDecor = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = false,
			Description = "Work hard but don't overwork yourself! Breaks are important!"
		},
		LazyAfternoon = {
			Display = "Lazy Afternoon",
			Image = "rbxassetid://109055452190166",
			LimitedDecor = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = true,
			Description = "It's okay to have lazy days, just don't get too comfortable :)"
		},
		LeafyTravels = {
			Display = "Leafy Travels",
			Image = "rbxassetid://118361984293968",
			LimitedDecor = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = false,
			Description = "It'd be great to be a leaf wouldn't it?"
		},
		QuietRide = {
			Display = "Quiet Ride",
			Image = "rbxassetid://140473799165847",
			LimitedDecor = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = false,
			Description = "Peace... that's all you need."
		},
		ScheduledArrival = {
			Display = "Smiling Suns",
			Image = "rbxassetid://135080415285442",
			LimitedDecor = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = false,
			Description = "Be on time next time!"
		},
		SpringSolitude = {
			Display = "Spring Solitude",
			Image = "rbxassetid://132905051292009",
			LimitedDecor = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = false,
			Description = "Being alone isn't as bad as you think."
		},
		SunlitHallway = {
			Display = "Sunlit Hallway",
			Image = "rbxassetid://81386282363344",
			LimitedDecor = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Good,
			HidePurchaseButton = false,
			Description = "Bask in the light."
		},
		BreadDucks = {
			Display = "Bread Ducks",
			Image = "rbxassetid://138496743765313",
			LimitedDecor = os.time({
				year = 2026,
				month = 8,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "Two cute, silly yellow ducklings wearing slices of bread around their heads on a polka-dot background."
		},
		FruitKabobs = {
			Display = "Fruit Kabobs",
			Image = "rbxassetid://84668862492724",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "Colorful skewers of fresh summer fruits arranged over a red-and-white checkered picnic pattern."
		},
		PalmCanopy = {
			Display = "Palm Canopy",
			Image = "rbxassetid://139632384587351",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "A perspective looking straight up the trunk of a palm tree toward green leaves and orange coconuts."
		},
		PoolPals = {
			Display = "Pool Pals",
			Image = "rbxassetid://118437646920661",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "A cute cat and dog float lazily in inner tubes next to a pink flamingo float."
		},
		SmilingSun = {
			Display = "Smiling Suns",
			Image = "rbxassetid://117849283507924",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "A friendly cartoon sun shines its warm rays over a row of bright beach umbrellas."
		},
		SnorkelAdventure = {
			Display = "Snorkel Adventure",
			Image = "rbxassetid://89317797487797",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "A Bacon Hair explores the blue ocean depths wearing a snorkel mask."
		},
		SummerBreeze = {
			Display = "Summer Breeze",
			Image = "rbxassetid://132115291860637",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Basic,
			HidePurchaseButton = false,
			Description = "A cheerful pink caterpillar and three tiny bees drift among tropical plumeria flowers."
		},
		ThoughtfullyAmerican = {
			Display = "Thoughtfully American",
			Image = "rbxassetid://130413063760140",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Wavy stripes and star-spangled style."
		},
		LibertyBound = {
			Display = "Liberty Bound",
			Image = "rbxassetid://121341541213954",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Liberty stands tall behind the stars and stripes."
		},
		SpiritSoars = {
			Display = "Spirit Soars",
			Image = "rbxassetid://96954312165994",
			Rarity = "Rare",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Soar high with the flag trailing behind."
		},
		AmericanSpirit = {
			Display = "American Spirit",
			Image = "rbxassetid://138442414484607",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "An explosive display of patriotic colors."
		},
		FreedomReigns = {
			Display = "Freedom Reigns",
			Image = "rbxassetid://100823238326473",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Simple, bold, and iconic."
		},
		HonorWatch = {
			Display = "Honor Watch",
			Image = "rbxassetid://130267939332248",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "The noble eagle watches over the land."
		},
		FreedomFirm = {
			Display = "Freedom Firm",
			Image = "rbxassetid://139216998850268",
			ScaleType = Enum.ScaleType.Crop,
			Price = v.Offsale,
			HidePurchaseButton = true,
			Description = "Wear the light of liberty upon your brow."
		},
		SmittenBunny = {
			Display = "Smitten Bunny",
			Image = "rbxassetid://81477739792884",
			Price = v.Good,
			Description = "For the easter holidays, a smitten bunny.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		RainyBunny = {
			Display = "Rainy Bunny",
			Image = "rbxassetid://101435002958580",
			Price = v.Good,
			Description = "Chilling in the rain.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		MugBunny = {
			Display = "Mug Bunny",
			Image = "rbxassetid://111699725768683",
			Price = v.Good,
			Description = "Cozy bunny in a cozy mug.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		MoneyBunny = {
			Display = "Money Bunny",
			Image = "rbxassetid://126134865735697",
			Price = v.Good,
			Description = "Dollar dollar bunnies!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		MeadowBunny = {
			Display = "Meadow Bunny",
			Image = "rbxassetid://137605388223811",
			Price = v.Basic,
			Description = "Little bunny frolicking in the meadow.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		StarryPeek = {
			Display = "Starry Peek",
			Image = "rbxassetid://93439304738574",
			Price = v.Offsale,
			Description = "Bunny beneath the starry night!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		DryingBunny = {
			Display = "Drying Bunny",
			Image = "rbxassetid://105010206524392",
			Price = v.Good,
			Description = "What are you doing on the drying line little bunny.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		EggSpill = {
			Display = "Egg Spill",
			Image = "rbxassetid://121000897240602",
			Price = v.Good,
			Description = "Slow down! You're going to lose all the eggs.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		BunnyPunch = {
			Display = "Bunny Punch",
			Image = "rbxassetid://96320731876090",
			Price = v.Good,
			Description = "Tease the bunny, you get the paw.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		BunnySurprise = {
			Display = "Bunny Surprise",
			Image = "rbxassetid://122227753871205",
			Price = v.Good,
			Description = "SURPRISE! The bunnies are coming",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		BunnyGoalie = {
			Display = "Bunny Goalie",
			Image = "rbxassetid://124892813296520",
			Price = v.Basic,
			Description = "Keeping the eggs out of the net!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		BunnyBalloon = {
			Display = "Bunny Balloons",
			Image = "rbxassetid://80262567634778",
			Price = v.Offsale,
			Description = "The balloons aren't edible",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		ModerationBackground = {
			Display = "Moderation Background",
			Image = "rbxassetid://121615462499202",
			Price = 0,
			Description = "For those who know ball.",
			ScaleType = Enum.ScaleType.Crop,
			RequiredRank = 100
		},
		PinkModerationBackground = {
			Display = "Pink Moderation Background",
			Image = "rbxassetid://71994816927521",
			Price = 0,
			Description = "For those who know tea.",
			ScaleType = Enum.ScaleType.Crop,
			RequiredRank = 100
		},
		Cloverdose = {
			Display = "Cloverdose",
			Image = "rbxassetid://106405114520753",
			Price = v.Offsale,
			Description = "A little too much luck? Never.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		LuckyCollage = {
			Display = "Lucky Collage",
			Image = "rbxassetid://131012795940192",
			Price = v.Offsale,
			Description = "From leprechauns to rainbows, we’ve got it all!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		ShamRocked = {
			Display = "Sham Rocked",
			Image = "rbxassetid://116866124652064",
			Price = v.Offsale,
			Description = "That feeling when the luck hits you all at once.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		EarlyChristmas = {
			Display = "Early Christmas",
			Image = "rbxassetid://122631433298135",
			Price = v.Offsale,
			Description = "Celebrating Christmas early!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		EarlyPresents = {
			Display = "Early Presents",
			Image = "rbxassetid://114206729223284",
			Price = v.Offsale,
			Description = "Presents that were received early!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		FestiveSnow = {
			Display = "Festive Snow",
			Image = "rbxassetid://111064824808912",
			Price = v.Offsale,
			Description = "Snow that is part of a holiday!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		FreshStart = {
			Display = "Fresh Start",
			Image = "rbxassetid://122174871007365",
			Price = v.Offsale,
			Description = "A clean slate for the start of a new time!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		Penguin = {
			Display = "Penguin",
			Image = "rbxassetid://94119053892590",
			Price = v.Offsale,
			Description = "A cute penguin, makes a great companion!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		SnowBuddies = {
			Display = "Snow Buddies",
			Image = "rbxassetid://77050363251450",
			Price = v.Offsale,
			Description = "Look at them!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		Snowman = {
			Display = "Snowman",
			Image = "rbxassetid://127331248682395",
			Price = v.Offsale,
			Description = "A simple Snowman.",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		SnowyNight = {
			Display = "Snowy Night",
			Image = "rbxassetid://136892082390595",
			Price = v.Offsale,
			Description = "A scene of snow falling at night!",
			ScaleType = Enum.ScaleType.Crop,
			HidePurchaseButton = true
		},
		BooBuddies = {
			Display = "Boo Buddies",
			Image = "rbxassetid://126017238792069",
			Price = v.Basic,
			Description = "Ghosts just wanna have fun!",
			ScaleType = Enum.ScaleType.Crop
		},
		ZeroHour = {
			Display = "Zero Hour",
			Image = "rbxassetid://96543193151015",
			Price = v.Basic,
			Description = "Time’s up—make it count.",
			ScaleType = Enum.ScaleType.Crop
		},
		Starpop = {
			Display = "Starpop",
			Image = "rbxassetid://78064969031241",
			Price = v.Basic,
			Description = "A burst of cosmic candy energy!",
			ScaleType = Enum.ScaleType.Crop
		},
		SinCircuit = {
			Display = "Sin Circuit",
			Image = "rbxassetid://100802829556885",
			Price = v.Basic,
			Description = "Where neon meets chaos.",
			ScaleType = Enum.ScaleType.Crop
		},
		Rosebound = {
			Display = "Rosebound",
			Image = "rbxassetid://115952771510926",
			Price = v.Basic,
			Description = "Beauty with a hint of bite.",
			ScaleType = Enum.ScaleType.Crop
		},
		OniCurrent = {
			Display = "Oni Current",
			Image = "rbxassetid://113172989349744",
			Price = v.Basic,
			Description = "Power surging with spirit energy.",
			ScaleType = Enum.ScaleType.Crop
		},
		MortalConnection = {
			Display = "Mortal Connection",
			Image = "rbxassetid://138809140544260",
			Price = v.Basic,
			Description = "Bound by fate, online or off.",
			ScaleType = Enum.ScaleType.Crop
		},
		MoonHalo = {
			Display = "Moon Halo",
			Image = "rbxassetid://96325716860852",
			Price = v.Good,
			Description = "Glow softly under lunar light.",
			ScaleType = Enum.ScaleType.Crop
		},
		Mindpool = {
			Display = "Mindpool",
			Image = "rbxassetid://81454706461887",
			Price = v.Good,
			Description = "Dive deep into your own thoughts.",
			ScaleType = Enum.ScaleType.Crop
		},
		MetroNoise = {
			Display = "Metro Noise",
			Image = "rbxassetid://94717608825224",
			Price = v.Good,
			Description = "City lights, city fights, city nights.",
			ScaleType = Enum.ScaleType.Crop
		},
		LonelyFamiliar = {
			Display = "Lonely Familiar",
			Image = "rbxassetid://81064016762728",
			Price = v.Good,
			Description = "Even ghosts need a friend.",
			ScaleType = Enum.ScaleType.Crop
		},
		KillerCrush = {
			Display = "Killer Crush",
			Image = "rbxassetid://80685740036263",
			Price = v.Decent,
			Description = "Love hurts… literally.",
			ScaleType = Enum.ScaleType.Crop
		},
		InnerBeast = {
			Display = "Inner Beast",
			Image = "rbxassetid://86310121020537",
			Price = v.Good,
			Description = "Let the wild side roar.",
			ScaleType = Enum.ScaleType.Crop
		},
		FeelingQuiet = {
			Display = "Feeling Quiet",
			Image = "rbxassetid://134916214608322",
			Price = v.Decent,
			Description = "Silent mood, loud thoughts.",
			ScaleType = Enum.ScaleType.Crop
		},
		DigitalIdle = {
			Display = "Digital Idle",
			Image = "rbxassetid://109327507008862",
			Price = v.Decent,
			Description = "Lag never looked this chill.",
			ScaleType = Enum.ScaleType.Crop
		},
		Departure = {
			Display = "Departure",
			Image = "rbxassetid://90693808541910",
			Price = v.Decent,
			Description = "Every end starts a new journey.",
			ScaleType = Enum.ScaleType.Crop
		},
		DaybreakDistrict = {
			Display = "Daybreak District",
			Image = "rbxassetid://134637167188490",
			Price = v.Good,
			Description = "Morning lights meet urban dreams.",
			ScaleType = Enum.ScaleType.Crop
		},
		CurtainCall = {
			Display = "Curtain Call",
			Image = "rbxassetid://81804798891471",
			Price = v.Good,
			Description = "Take a bow, star of the show!",
			ScaleType = Enum.ScaleType.Crop
		},
		CloudSerenade = {
			Display = "Cloud Serenade",
			Image = "rbxassetid://78697247128660",
			Price = v.Good,
			Description = "Sing softly above the skies.",
			ScaleType = Enum.ScaleType.Crop
		},
		CatVibes = {
			Display = "Cat Vibes",
			Image = "rbxassetid://114983849220606",
			Price = v.Good,
			Description = "Cool, calm, and purr-ified.",
			ScaleType = Enum.ScaleType.Crop
		},
		BoomGirl = {
			Display = "Boom Girl",
			Image = "rbxassetid://139056018113969",
			Price = v.Good,
			Description = "Explosive charm and louder style.",
			ScaleType = Enum.ScaleType.Crop
		},
		BerryCute = {
			Display = "Berry Cute",
			Image = "rbxassetid://136009829452390",
			Price = v.Good,
			Description = "Sweet, tangy, and totally adorable!",
			ScaleType = Enum.ScaleType.Crop
		},
		AstralKiss = {
			Display = "Astral Kiss",
			Image = "rbxassetid://126579413217719",
			Price = v.Good,
			Description = "A smooch straight from the stars.",
			ScaleType = Enum.ScaleType.Crop
		},
		Candy = {
			Display = "Candy",
			Image = "rbxassetid://15057554299",
			Transparency = 0.35,
			Price = v.Basic,
			Description = "So much candy!"
		},
		Cauldrons = {
			Display = "Cauldrons",
			Image = "rbxassetid://15057533152",
			Transparency = 0.35,
			Price = v.Good,
			Description = "Something malicious is brewing."
		},
		ReaperBG = {
			Display = "Reaper",
			Image = "rbxassetid://15057514656",
			Price = v.Basic,
			Description = "Fetch me their souls..."
		},
		LeavesBG = {
			Display = "Leaves",
			Image = "rbxassetid://15057074374",
			Color = Color3.fromHex("fdc5af"),
			Price = v.Basic,
			Description = "Such calming leaves."
		},
		MushroomForest = {
			Display = "Mushroom Forest",
			Image = "rbxassetid://15057447467",
			Color = Color3.fromHex("feeae2"),
			Transparency = 0.35,
			Price = v.Good,
			Description = "What a beautiful forest!"
		},
		FallingBlossoms = {
			Display = "Falling Blossoms",
			Image = "rbxassetid://15090436242",
			Transparency = 0.3,
			Price = v.Decent,
			Description = "You wish you were below these."
		},
		Ribs = {
			Display = "Ribs",
			Image = "rbxassetid://15090436778",
			Transparency = 0,
			Price = v.Basic,
			Description = ""
		},
		Beach = {
			Display = "Beach",
			Image = "rbxassetid://15090437303",
			Transparency = 0,
			Price = v.Basic,
			Description = "Summer time memories"
		},
		Popsicles = {
			Display = "Popsicles",
			Image = "rbxassetid://15090437019",
			Transparency = 0.2,
			Price = v.Decent,
			Description = "Classic popsicles!"
		},
		HeartsAndCheckers = {
			Display = "Hearts & Checkers",
			Image = "rbxassetid://15090437547",
			Transparency = 0.2,
			Price = v.Basic,
			Description = "Pink is such a nice color."
		},
		Skulls = {
			Display = "Skulls",
			Image = "rbxassetid://124086366826654",
			Transparency = 0.2,
			Price = v.Decent,
			Description = "Spooky Scary."
		},
		Entranced = {
			Display = "Entranced",
			Image = "rbxassetid://100969126616138",
			Transparency = 0,
			Price = v.Offsale,
			Description = "Cast a spell a on you",
			HidePurchaseButton = true,
			ScaleType = Enum.ScaleType.Crop
		},
		["Sweet Rose"] = {
			Display = "Popsicles",
			Image = "rbxassetid://118892086636360",
			Transparency = 0.2,
			Price = v.Offsale,
			Description = "Sweet sweet roses...",
			HidePurchaseButton = true,
			ScaleType = Enum.ScaleType.Crop
		},
		["Second Half"] = {
			Display = "Second Half",
			Image = "rbxassetid://121707105040812",
			Transparency = 0.2,
			Price = v.Offsale,
			Description = "Your other half.",
			HidePurchaseButton = true,
			ScaleType = Enum.ScaleType.Crop
		},
		["First Half"] = {
			Display = "First Half",
			Image = "rbxassetid://110822094514455",
			Transparency = 0.2,
			Price = v.Offsale,
			Description = "Your other half.",
			HidePurchaseButton = true,
			ScaleType = Enum.ScaleType.Crop
		},
		["Deck of Hearts"] = {
			Display = "Deck of Hearts",
			Image = "rbxassetid://123738628028545",
			Transparency = 0.2,
			Price = v.Offsale,
			Description = "Full of hearts.",
			HidePurchaseButton = true,
			ScaleType = Enum.ScaleType.Crop
		},
		["Rising Heart"] = {
			Display = "Rising Heart",
			Image = "rbxassetid://98683712696772",
			Transparency = 0.2,
			Price = v.Offsale,
			Description = "I like you this much.",
			HidePurchaseButton = true,
			ScaleType = Enum.ScaleType.Crop
		}
	}
}

for k, v2 in next, Decoration, nil do
	for _, v3 in next, v2, nil do
		v3.Type = k

		if v3.LimitedDecor and os.time() - v3.LimitedDecor >= 1209600 then
			v3.LimitedDecor = nil
		end
	end
end

return Decoration