local Bobbers = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rarities = require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("rarities"))
Bobbers.Bobbers = {
	["Event Horizon"] = {
		Name = "Event Horizon",
		Rarity = "Mythical",
		Icon = "rbxassetid://83521836413439",
		Untradeable = true
	},
	Piano = {
		Name = "Piano",
		Rarity = "Mythical",
		Icon = "rbxassetid://106713224167198",
		Untradeable = true
	},
	["Obsidian Chunk"] = {
		Name = "Obsidian Chunk",
		Rarity = "Exotic",
		Icon = "rbxassetid://106909162917461",
		Untradeable = true
	},
	["Idol Crest"] = {
		Name = "Idol Crest",
		Rarity = "Mythical",
		Icon = "rbxassetid://103488066957810",
		Untradeable = true
	},
	dool = {
		Icon = "rbxassetid://107902995924565",
		Rarity = "Secret",
		Name = "dool",
		Untradeable = true
	},
	["Master Orb"] = {
		Icon = "rbxassetid://93097166339800",
		Rarity = "Exotic",
		Name = "Master Orb",
		Untradeable = true
	},
	["Scrap-Gauge"] = {
		Icon = "rbxassetid://134981245859666",
		Rarity = "Legendary",
		Name = "Scrap-Gauge",
		Untradeable = true
	},
	["Angler Lure"] = {
		Icon = "rbxassetid://131811915121947",
		Rarity = "Legendary",
		Name = "Angler Lure",
		Untradeable = true
	},
	["Crystal Prism"] = {
		Icon = "rbxassetid://140414959196368",
		Rarity = "Legendary",
		Name = "Crystal Prism",
		Untradeable = true
	},
	Lemon = {
		Name = "Lemon",
		Rarity = "Limited",
		Icon = "rbxassetid://90490301782864",
		Untradeable = true
	},
	Lime = {
		Name = "Lime",
		Rarity = "Limited",
		Icon = "rbxassetid://89403353383875",
		Untradeable = true
	},
	Berry = {
		Name = "Berry",
		Rarity = "Limited",
		Icon = "rbxassetid://89057005537844",
		Untradeable = true
	},
	Banana = {
		Name = "Banana",
		Rarity = "Limited",
		Icon = "rbxassetid://127647490973100",
		Untradeable = true
	},
	["Exalted Bobber"] = {
		Name = "Exalted Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://79066824574985",
		Untradeable = true
	},
	BBQ = {
		Name = "BBQ",
		Rarity = "Legendary",
		Icon = "rbxassetid://82536163485687",
		Untradeable = true
	},
	["Golden Crew Crest"] = {
		Name = "Golden Crew Crest",
		Rarity = "Limited",
		Icon = "rbxassetid://81246246586287",
		Untradeable = true
	},
	["Silver Crew Crest"] = {
		Name = "Silver Crew Crest",
		Rarity = "Limited",
		Icon = "rbxassetid://104074632525385",
		Untradeable = true
	},
	["Bronze Crew Crest"] = {
		Name = "Bronze Crew Crest",
		Rarity = "Limited",
		Icon = "rbxassetid://116960077960611",
		Untradeable = true
	},
	["Crew Crest"] = {
		Name = "Crew Crest",
		Rarity = "Limited",
		Icon = "rbxassetid://134573689658114",
		Untradeable = true
	},
	["Random Bobber"] = {
		Name = "Random Bobber",
		Rarity = "Secret",
		Icon = "rbxassetid://91112724587479",
		Untradeable = true
	},
	["Sand Sifter"] = {
		Name = "Sand Sifter",
		Rarity = "Legendary",
		Icon = "rbxassetid://76370678628943",
		Untradeable = true
	},
	["Small Cactus"] = {
		Name = "Small Cactus",
		Rarity = "Legendary",
		Icon = "rbxassetid://111054591221691",
		Untradeable = true
	},
	Moon = {
		Name = "Moon",
		Rarity = "Limited",
		Icon = "rbxassetid://71524146091699",
		Untradeable = true
	},
	Gemidium = {
		Name = "Gemidium",
		Rarity = "Limited",
		Icon = "rbxassetid://104354972935509",
		Untradeable = true
	},
	["Tropical Conch"] = {
		Name = "Tropical Conch",
		Rarity = "Limited",
		Icon = "rbxassetid://97182311493925"
	},
	["Rescue Float"] = {
		Name = "Rescue Float",
		Rarity = "Limited",
		Icon = "rbxassetid://105575922856238"
	},
	["Sand Castle"] = {
		Name = "Sand Castle",
		Rarity = "Limited",
		Icon = "rbxassetid://112004656939573"
	},
	["The Sun"] = {
		Icon = "rbxassetid://72721136009726",
		Name = "The Sun",
		Rarity = "Limited"
	},
	["Beach Ball"] = {
		Icon = "rbxassetid://78015397794318",
		Name = "Beach Ball",
		Rarity = "Limited"
	},
	["Crew Bobber"] = {
		Name = "Crew Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://116178582806504",
		Untradeable = true,
		Price = 500,
		CrewRatingRequirement = 100
	},
	["Barnacled Hook"] = {
		Name = "Barnacled Hook",
		Rarity = "Unusual",
		Icon = "rbxassetid://135758793608044",
		Untradeable = true
	},
	["Keepers Energy"] = {
		Name = "Keepers Energy",
		Rarity = "Legendary",
		Icon = "rbxassetid://120440169324348",
		Untradeable = true
	},
	["Guitar Pick"] = {
		Name = "Guitar Pick",
		Rarity = "Legendary",
		Icon = "rbxassetid://91568035274230"
	},
	["Fisch Coin"] = {
		Name = "Fisch Coin",
		Rarity = "Common",
		Icon = "rbxassetid://139013553435940"
	},
	["Stone Claymore"] = {
		Name = "Stone Claymore",
		Rarity = "Unusual",
		Icon = "rbxassetid://125853141653826",
		Untradeable = true
	},
	["Harp of Light"] = {
		Name = "Harp of Light",
		Rarity = "Rare",
		Icon = "rbxassetid://119593195704247",
		Untradeable = true
	},
	["Poseidon's Pillar"] = {
		Name = "Poseidon's Pillar",
		Rarity = "Legendary",
		Icon = "rbxassetid://120668264452280",
		Untradeable = true
	},
	["Supercharged Battery"] = {
		Name = "Supercharged Battery",
		Rarity = "Mythical",
		Icon = "rbxassetid://79766826319133",
		Untradeable = true
	},
	["Cursed Tombstone"] = {
		Name = "Cursed Tombstone",
		Rarity = "Exotic",
		Icon = "rbxassetid://91114913685891",
		Untradeable = true
	},
	["Olympian Core"] = {
		Name = "Olympian Core",
		Rarity = "Secret",
		Icon = "rbxassetid://81165766212183",
		Untradeable = true
	},
	["Master Relay"] = {
		Name = "Master Relay",
		Rarity = "Mythical",
		Icon = "rbxassetid://134014917014842",
		Untradeable = true
	},
	Comet = {
		Name = "Comet",
		Rarity = "Exotic",
		Icon = "rbxassetid://128948044462727",
		Untradeable = true
	},
	["Sky Crystal"] = {
		Name = "Sky Crystal",
		Rarity = "Mythical",
		Icon = "rbxassetid://120465015664132",
		Untradeable = true
	},
	["Chocolate Bunny"] = {
		Name = "Chocolate Bunny",
		Rarity = "Limited",
		Icon = "rbxassetid://105129137130734",
		Untradeable = true
	},
	Oakling = {
		Name = "Oakling",
		Rarity = "Rare",
		Icon = "rbxassetid://83808119305529",
		Untradeable = true
	},
	["Redlip Batfish"] = {
		Name = "Redlip Batfish",
		Rarity = "Limited",
		Icon = "rbxassetid://115705899327189",
		Untradeable = true
	},
	["Mini Reef Guardian"] = {
		Name = "Mini Reef Guardian",
		Rarity = "Limited",
		Icon = "rbxassetid://130666298817591",
		Untradeable = true
	},
	["Not-So-Largemouth Bass"] = {
		Name = "Not-So-Largemouth Bass",
		Rarity = "Limited",
		Icon = "rbxassetid://98764061826122",
		Untradeable = true
	},
	["Golden Coin"] = {
		Name = "Golden Coin",
		Rarity = "Limited",
		Icon = "rbxassetid://90759723221642"
	},
	["Toxic Lily Pad"] = {
		Name = "Toxic Lily Pad",
		Rarity = "Rare",
		Icon = "rbxassetid://129721856144439",
		Untradeable = true
	},
	["Large Leaf"] = {
		Name = "Large Leaf",
		Rarity = "Rare",
		Icon = "rbxassetid://128966542536381",
		Untradeable = true
	},
	["Honey Comb"] = {
		Name = "Honey Comb",
		Rarity = "Legendary",
		Icon = "rbxassetid://72761165952693",
		Untradeable = true
	},
	["Toxic Flower"] = {
		Name = "Toxic Flower",
		Rarity = "Limited",
		Icon = "rbxassetid://77370730600681"
	},
	["Crag-Crabobber"] = {
		Name = "Crag-Crabobber",
		Rarity = "Mythical",
		Icon = "rbxassetid://130741704886835",
		Untradeable = true
	},
	Chocolate = {
		Name = "Chocolate",
		Price = 150,
		LocalCurrency = "Chocolates",
		Rarity = "Limited",
		Icon = "rbxassetid://79751867440985"
	},
	["Bronze Chocolate"] = {
		Name = "Bronze Chocolate",
		Rarity = "Limited",
		Icon = "rbxassetid://122858408235923"
	},
	["Silver Chocolate"] = {
		Name = "Silver Chocolate",
		Rarity = "Limited",
		Icon = "rbxassetid://105845794158509"
	},
	["Gold Chocolate"] = {
		Name = "Gold Chocolate",
		Rarity = "Limited",
		Icon = "rbxassetid://113117041767760"
	},
	["Love Letter"] = {
		Name = "Love Letter",
		Rarity = "Limited",
		Icon = "rbxassetid://105610038734489"
	},
	["Bronze Heart-Lock"] = {
		Name = "Bronze Heart-Lock",
		Rarity = "Limited",
		Icon = "rbxassetid://80693715241819"
	},
	["Silver Heart-Lock"] = {
		Name = "Silver Heart-Lock",
		Rarity = "Limited",
		Icon = "rbxassetid://72445077684062"
	},
	["Gold Heart-Lock"] = {
		Name = "Gold Heart-Lock",
		Rarity = "Limited",
		Icon = "rbxassetid://73108919394752"
	},
	["Bronze Heart"] = {
		Name = "Bronze Heart",
		Rarity = "Limited",
		Icon = "rbxassetid://73446198503969"
	},
	["Silver Heart"] = {
		Name = "Silver Heart",
		Rarity = "Limited",
		Icon = "rbxassetid://91724225923064"
	},
	["Gold Heart"] = {
		Name = "Gold Heart",
		Rarity = "Limited",
		Icon = "rbxassetid://84298828038085"
	},
	["Cupid's Treat Box"] = {
		Name = "Cupid's Treat Box",
		Rarity = "Limited",
		Icon = "rbxassetid://81732247862401"
	},
	["Cataclysm Cranium"] = {
		Name = "Cataclysm Cranium",
		Rarity = "Divine Secret",
		Icon = "rbxassetid://79685571700591",
		Untradeable = true
	},
	["Jungle Flower"] = {
		Name = "Jungle Flower",
		Rarity = "Legendary",
		Icon = "rbxassetid://105040098077512",
		Untradeable = true
	},
	Starfish = {
		Name = "Starfish",
		Rarity = "Legendary",
		Icon = "rbxassetid://136827659398299",
		Untradeable = true
	},
	Bookshelf = {
		Name = "Bookshelf",
		Rarity = "Legendary",
		Icon = "rbxassetid://123092683697559",
		Untradeable = true
	},
	["Golden Diver"] = {
		Name = "Golden Diver",
		Rarity = "Legendary",
		Icon = "rbxassetid://98426187630632",
		Untradeable = true
	},
	Brazier = {
		Name = "Brazier",
		Rarity = "Legendary",
		Icon = "rbxassetid://131944116136834",
		Untradeable = true
	},
	Obelisk = {
		Icon = "rbxassetid://73382810077211",
		Name = "Obelisk",
		Rarity = "Mythical",
		Untradeable = true
	},
	Nightmare = {
		Icon = "rbxassetid://125791401207266",
		Name = "Nightmare",
		Rarity = "Secret",
		Untradeable = true
	},
	Frostwhale = {
		Icon = "rbxassetid://112290166157640",
		Name = "Frostwhale",
		Rarity = "Limited"
	},
	Chimney = {
		Icon = "rbxassetid://107548612282629",
		Name = "Chimney",
		Rarity = "Limited"
	},
	Ribbon = {
		Icon = "rbxassetid://129035875656921",
		Name = "Ribbon",
		Rarity = "Limited"
	},
	Wreath = {
		Icon = "rbxassetid://127417816336330",
		Name = "Wreath",
		Rarity = "Limited"
	},
	["Light-Wrapped Bobber"] = {
		Icon = "rbxassetid://90461571532319",
		Name = "Light-Wrapped Bobber",
		Rarity = "Limited"
	},
	["Toy Train"] = {
		Icon = "rbxassetid://111555433798843",
		Name = "Toy Train",
		Rarity = "Limited"
	},
	["Santa's Hat"] = {
		Icon = "rbxassetid://113166221461291",
		Name = "Santa's Hat",
		Rarity = "Limited"
	},
	Acorn = {
		Icon = "rbxassetid://132833133627516",
		Name = "Acorn",
		Rarity = "Limited"
	},
	["Apple Pie Slice"] = {
		Icon = "rbxassetid://86696379618753",
		Name = "Apple Pie Slice",
		Rarity = "Limited"
	},
	Pickaxe = {
		Name = "Pickaxe",
		Rarity = "Legendary",
		Icon = "rbxassetid://101557604391326",
		Untradeable = true
	},
	Fisch = {
		Name = "Fisch",
		Rarity = "Secret",
		Icon = "rbxassetid://98191170945068",
		Untradeable = true
	},
	Eyeball = {
		Name = "Eyeball",
		Rarity = "Limited",
		Icon = "rbxassetid://72816918636894"
	},
	Ghost = {
		Name = "Ghost",
		Rarity = "Limited",
		Icon = "rbxassetid://86867303122396"
	},
	Gravestone = {
		Name = "Gravestone",
		Rarity = "Limited",
		Icon = "rbxassetid://111949656554604"
	},
	Spider = {
		Name = "Spider",
		Rarity = "Limited",
		Icon = "rbxassetid://140107307743217"
	},
	Lollipop = {
		Name = "Lollipop",
		Rarity = "Limited",
		Icon = "rbxassetid://129133988902656"
	},
	["Mimic Spellbook"] = {
		Name = "Mimic Spellbook",
		Rarity = "Limited",
		Icon = "rbxassetid://88871347174001"
	},
	["Chromatic Bobber"] = {
		Name = "Chromatic Bobber",
		Rarity = "Secret",
		Icon = "rbxassetid://91307638231718",
		Untradeable = true
	},
	["Miniature Bomb"] = {
		Icon = "rbxassetid://80789367331632",
		Name = "Miniature Bomb",
		Rarity = "Special",
		Untradeable = true
	},
	["Bears Got Your Fish"] = {
		Name = "Bears Got Your Fish",
		Rarity = "Legendary",
		Icon = "rbxassetid://122819991189755"
	},
	["Baby Ghoul"] = {
		Name = "Baby Ghoul",
		Rarity = "Legendary",
		Icon = "rbxassetid://104086762303276"
	},
	Candypop = {
		Name = "Candypop",
		Rarity = "Legendary",
		Icon = "rbxassetid://140720880418364"
	},
	["Coffinpaw Bobber"] = {
		Name = "Coffinpaw Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://125445288762118"
	},
	Hydrangea = {
		Name = "Hydrangea",
		Rarity = "Legendary",
		Icon = "rbxassetid://102948168031713"
	},
	Axobobber = {
		Name = "Axobobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://74250658468422"
	},
	["Baby Turkey"] = {
		Name = "Baby Turkey",
		Rarity = "Legendary",
		Icon = "rbxassetid://83053747397087"
	},
	Snowball = {
		Name = "Snowball",
		Rarity = "Legendary",
		Icon = "rbxassetid://130958689296237"
	},
	["Polar Bear Bobber"] = {
		Name = "Polar Bear Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://75763429972407"
	},
	["Nibbled Fish"] = {
		Name = "Nibbled Fish",
		Rarity = "Legendary",
		Icon = "rbxassetid://139595344455819"
	},
	["Present Bow Bobber"] = {
		Name = "Present Bow Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://93700962118397"
	},
	["Pinecone Bobber"] = {
		Name = "Pinecone Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://74778307864938"
	},
	["Little Leaf"] = {
		Name = "Little Leaf",
		Rarity = "Legendary",
		Icon = "rbxassetid://91623501772309"
	},
	["Ketchup Bobber"] = {
		Name = "Ketchup Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://109512078883705"
	},
	["Mini Evil Kitty"] = {
		Name = "Mini Evil Kitty",
		Rarity = "Legendary",
		Icon = "rbxassetid://71206609197942"
	},
	["Miffy Bunny"] = {
		Name = "Miffy Bunny",
		Rarity = "Legendary",
		Icon = "rbxassetid://83958979865018"
	},
	Clicky = {
		Name = "Clicky",
		Rarity = "Legendary",
		Icon = "rbxassetid://98949088415500"
	},
	FlipMini = {
		Name = "FlipMini",
		Rarity = "Legendary",
		Icon = "rbxassetid://111656908761225"
	},
	["Mini Mothy"] = {
		Name = "Mini Mothy",
		Rarity = "Legendary",
		Icon = "rbxassetid://122971726526253"
	},
	Waterstar = {
		Name = "Waterstar",
		Rarity = "Legendary",
		Icon = "rbxassetid://89436037745496"
	},
	Whaletopia = {
		Name = "Whaletopia",
		Rarity = "Legendary",
		Icon = "rbxassetid://117543611643015"
	},
	["Joyous Dog"] = {
		Name = "Joyous Dog",
		Rarity = "Legendary",
		Icon = "rbxassetid://88202319862142"
	},
	Dovette = {
		Name = "Dovette",
		Rarity = "Legendary",
		Icon = "rbxassetid://122237579389071"
	},
	["Scribble Sam"] = {
		Name = "Scribble Sam",
		Rarity = "Legendary",
		Icon = "rbxassetid://105297600487501"
	},
	Bubbleness = {
		Name = "Bubbleness",
		Rarity = "Legendary",
		Icon = "rbxassetid://97771938999458"
	},
	["Gingerbread Nessie Bobber"] = {
		Name = "Gingerbread Nessie Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://88909129482621"
	},
	["Melty Man Bobber"] = {
		Name = "Melty Man Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://84639248771941"
	},
	["Party Hat Bobber"] = {
		Name = "Party Hat Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://108045332318058"
	},
	["Balloon Doggy Bobber"] = {
		Name = "Balloon Doggy Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://118312326443231"
	},
	Bee = {
		Name = "Bee",
		Rarity = "Legendary",
		Icon = "rbxassetid://74808227530116"
	},
	Spearhead = {
		Name = "Spearhead",
		Rarity = "Limited",
		Icon = "rbxassetid://74627227002130"
	},
	["Luminescent Flower"] = {
		Name = "Luminescent Flower",
		Rarity = "Legendary",
		Icon = "rbxassetid://136955146235635",
		Untradeable = true
	},
	["Crimson Flower"] = {
		Name = "Crimson Flower",
		Rarity = "Legendary",
		Icon = "rbxassetid://89089650635089",
		Untradeable = true
	},
	["Rotund Seal"] = {
		Name = "Rotund Seal",
		Rarity = "Legendary",
		Icon = "rbxassetid://74728164289913"
	},
	Butter = {
		Name = "Butter",
		Rarity = "Legendary",
		Icon = "rbxassetid://126405364094126"
	},
	["Kitty Car Key"] = {
		Name = "Kitty Car Key",
		Rarity = "Legendary",
		Icon = "rbxassetid://82973637616453"
	},
	["Pilot Gear"] = {
		Name = "Pilot Gear",
		Rarity = "Legendary",
		Icon = "rbxassetid://126697340323864"
	},
	Strawberry = {
		Name = "Strawberry",
		Rarity = "Legendary",
		Icon = "rbxassetid://93736511101807"
	},
	["Tryhard Bobber"] = {
		Name = "Tryhard Bobber",
		Rarity = "Apex",
		Icon = "rbxassetid://106353062466060",
		Untradeable = true
	},
	["Fabulous Bobber"] = {
		Name = "Fabulous Bobber",
		Rarity = "Mythical",
		Icon = "rbxassetid://103631214322337",
		Untradeable = true
	},
	["Astraeus Bobber"] = {
		Name = "Astraeus Bobber",
		Rarity = "Mythical",
		Icon = "rbxassetid://131983849785199",
		Untradeable = true
	},
	["Ethereal Bobber"] = {
		Name = "Ethereal Bobber",
		Rarity = "Mythical",
		Icon = "rbxassetid://99975578724364",
		Untradeable = true
	},
	["Floppy Bobber"] = {
		Name = "Floppy Bobber",
		Rarity = "Secret",
		Icon = "rbxassetid://108960296411804",
		Untradeable = true
	},
	["Dusk Bobber"] = {
		Name = "Dusk Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://108504882827938",
		Untradeable = true
	},
	["Spirit Bobber"] = {
		Name = "Spirit Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://103797143984751",
		Untradeable = true
	},
	["Ghostly Conch"] = {
		Name = "Ghostly Conch",
		Rarity = "Legendary",
		Icon = "rbxassetid://125169419848461",
		Untradeable = true
	},
	["Prismatic Gem"] = {
		Name = "Prismatic Gem",
		Rarity = "Legendary",
		Icon = "rbxassetid://75449705551793",
		Untradeable = true
	},
	Astro = {
		Name = "Astro",
		Rarity = "Legendary",
		Icon = "rbxassetid://82616719548630"
	},
	Meteor = {
		Name = "Meteor",
		Rarity = "Legendary",
		Icon = "rbxassetid://100122792056668"
	},
	Telescope = {
		Name = "Telescope",
		Rarity = "Legendary",
		Icon = "rbxassetid://124614915945049"
	},
	Moss = {
		Name = "Moss",
		Rarity = "Legendary",
		Icon = "rbxassetid://95729310863214"
	},
	Coconut = {
		Name = "Coconut",
		Rarity = "Legendary",
		Icon = "rbxassetid://130760391269228"
	},
	["Dumbo Prize"] = {
		Name = "Dumbo Prize",
		Rarity = "Legendary",
		Icon = "rbxassetid://95403642759327"
	},
	Cheezburger = {
		Name = "Cheezburger",
		Rarity = "Legendary",
		Icon = "rbxassetid://77954476898749"
	},
	Bloxiade = {
		Name = "Bloxiade",
		Rarity = "Legendary",
		Icon = "rbxassetid://107943922710504"
	},
	["Chocolate Milk"] = {
		Name = "Chocolate Milk",
		Rarity = "Legendary",
		Icon = "rbxassetid://112758527438865"
	},
	Chiwari = {
		Name = "Chiwari",
		Rarity = "Legendary",
		Icon = "rbxassetid://101843656274135"
	},
	Nanatama = {
		Name = "Nanatama",
		Rarity = "Legendary",
		Icon = "rbxassetid://101299751082862"
	},
	Uwa = {
		Name = "Uwa",
		Rarity = "Legendary",
		Icon = "rbxassetid://113160866803825"
	},
	Veyrith = {
		Name = "Veyrith",
		Rarity = "Legendary",
		Icon = "rbxassetid://87053448606735"
	},
	Mourvex = {
		Name = "Mourvex",
		Rarity = "Legendary",
		Icon = "rbxassetid://79010291712553"
	},
	Karthok = {
		Name = "Karthok",
		Rarity = "Legendary",
		Icon = "rbxassetid://118158089478540"
	},
	Nomster = {
		Name = "Nomster",
		Rarity = "Legendary",
		Icon = "rbxassetid://83219665545293"
	},
	Kuraudo = {
		Name = "Kuraudo",
		Rarity = "Legendary",
		Icon = "rbxassetid://95114052618588"
	},
	["Dizzy Star"] = {
		Name = "Dizzy Star",
		Rarity = "Legendary",
		Icon = "rbxassetid://92221723258945"
	},
	["Evil Hammy"] = {
		Name = "Evil Hammy",
		Rarity = "Legendary",
		Icon = "rbxassetid://122210700388440"
	},
	["Silly Hammy"] = {
		Name = "Silly Hammy",
		Rarity = "Legendary",
		Icon = "rbxassetid://97532690200190"
	},
	["Nervous Hammy"] = {
		Name = "Nervous Hammy",
		Rarity = "Legendary",
		Icon = "rbxassetid://99742203463584"
	},
	Cybernade = {
		Name = "Cybernade",
		Rarity = "Legendary",
		Icon = "rbxassetid://123753778453363"
	},
	Cruciful = {
		Name = "Cruciful",
		Rarity = "Legendary",
		Icon = "rbxassetid://75607164176675"
	},
	Sceptara = {
		Name = "Sceptara",
		Rarity = "Legendary",
		Icon = "rbxassetid://92861618415522"
	},
	["Pink Starbun"] = {
		Name = "Pink Starbun",
		Rarity = "Legendary",
		Icon = "rbxassetid://114895550772826"
	},
	["Green Starbun"] = {
		Name = "Green Starbun",
		Rarity = "Legendary",
		Icon = "rbxassetid://108944645734846"
	},
	["Blue Starbun"] = {
		Name = "Blue Starbun",
		Rarity = "Legendary",
		Icon = "rbxassetid://139137890486133"
	},
	Winterfluff = {
		Name = "Winterfluff",
		Rarity = "Legendary",
		Icon = "rbxassetid://73560611760196"
	},
	["Frigid Lotus"] = {
		Name = "Frigid Lotus",
		Rarity = "Legendary",
		Icon = "rbxassetid://133140428242879"
	},
	["Glacial Shard"] = {
		Name = "Glacial Shard",
		Rarity = "Legendary",
		Icon = "rbxassetid://124227220164886"
	},
	Spikesplosion = {
		Name = "Spikesplosion",
		Rarity = "Legendary",
		Icon = "rbxassetid://87522452784846"
	},
	["Fuse Bomb"] = {
		Name = "Fuse Bomb",
		Rarity = "Legendary",
		Icon = "rbxassetid://105842844364656"
	},
	["Bundle of TNT"] = {
		Name = "Bundle of TNT",
		Rarity = "Legendary",
		Icon = "rbxassetid://85878283829633"
	},
	["Monkey Plush"] = {
		Name = "Monkey Plush",
		Rarity = "Legendary",
		Icon = "rbxassetid://72130253258747"
	},
	["Tiger Plush"] = {
		Name = "Tiger Plush",
		Rarity = "Legendary",
		Icon = "rbxassetid://126015700363367"
	},
	["Dragon Plush"] = {
		Name = "Dragon Plush",
		Rarity = "Legendary",
		Icon = "rbxassetid://137418822222731"
	},
	Taiyaki = {
		Name = "Taiyaki",
		Rarity = "Legendary",
		Icon = "rbxassetid://76311750436958"
	},
	["Little Mouse"] = {
		Name = "Little Mouse",
		Rarity = "Legendary",
		Icon = "rbxassetid://110185413125900"
	},
	Beachball = {
		Name = "Beachball",
		Rarity = "Legendary",
		Icon = "rbxassetid://131424281798552"
	},
	["Not-So-Colossal Squid"] = {
		Name = "Not-So-Colossal Squid",
		Rarity = "Legendary",
		Icon = "rbxassetid://74550354036318"
	},
	["Purple Wiggly Worm"] = {
		Name = "Purple Wiggly Worm",
		Rarity = "Rare",
		Icon = "rbxassetid://137513139812585"
	},
	["Blue Wiggly Worm"] = {
		Name = "Blue Wiggly Worm",
		Rarity = "Rare",
		Icon = "rbxassetid://84582445299935"
	},
	["Green Wiggly Worm"] = {
		Name = "Green Wiggly Worm",
		Rarity = "Rare",
		Icon = "rbxassetid://102153978795727"
	},
	["The Moby Bobber"] = {
		Name = "The Moby Bobber",
		Rarity = "Rare",
		Icon = "rbxassetid://88441037526810"
	},
	["Bloxy Cola"] = {
		Name = "Bloxy Cola",
		Rarity = "Legendary",
		Icon = "rbxassetid://115353756965058",
		Untradeable = true
	},
	["Clownfish Cat Toy"] = {
		Name = "Clownfish Cat Toy",
		Rarity = "Legendary",
		Icon = "rbxassetid://81538394292522",
		Untradeable = true
	},
	["UFO Of Glorp"] = {
		Name = "UFO Of Glorp",
		Rarity = "Legendary",
		Icon = "rbxassetid://79068757700014",
		Untradeable = true
	},
	["Faberge Egg"] = {
		Name = "Faberge Egg",
		Rarity = "Legendary",
		Icon = "rbxassetid://83535586164268"
	},
	["Volcano Bobber"] = {
		Name = "Volcano Bobber",
		Rarity = "Legendary",
		Icon = "rbxassetid://89564923245417"
	},
	["Easter Egg"] = {
		Icon = "rbxassetid://81739323540595",
		Name = "Easter Egg",
		Rarity = "Rare"
	},
	["Easter Bunny"] = {
		Icon = "rbxassetid://96422730409279",
		Name = "Easter Bunny",
		Rarity = "Legendary"
	},
	["Easter Basket"] = {
		Icon = "rbxassetid://117420953773899",
		Name = "Easter Basket",
		Rarity = "Legendary"
	},
	Peep = {
		Icon = "rbxassetid://93498777781560",
		Name = "Easter Basket",
		Rarity = "Legendary"
	},
	Lucky = {
		Icon = "rbxassetid://124492311549484",
		Name = "Lucky",
		Rarity = "Rare"
	},
	["Heart Candy"] = {
		Icon = "rbxassetid://100227977398144",
		Name = "Heart Candy",
		Rarity = "Rare"
	},
	["Red Rose"] = {
		Icon = "rbxassetid://93366347670284",
		Name = "Red Rose",
		Rarity = "Rare"
	},
	Mila = {
		Icon = "rbxassetid://94276978522293",
		Name = "Mila",
		Rarity = "Exotic",
		Untradeable = true
	},
	["Zombi Kitty"] = {
		Icon = "rbxassetid://79791636912971",
		Name = "Zombi Kitty",
		Rarity = "Exotic",
		Untradeable = true
	},
	kittyyy = {
		Icon = "rbxassetid://1499586367",
		Name = "kittyyy",
		Rarity = "Exotic",
		Untradeable = true
	},
	["mild lea sauce"] = {
		Icon = "rbxassetid://86224267624033",
		Name = "mild lea sauce",
		Rarity = "Exotic",
		Untradeable = true
	},
	Betsy = {
		Icon = "rbxassetid://73718836772908",
		Name = "Betsy",
		Rarity = "Exotic",
		Untradeable = true
	},
	Quiche = {
		Icon = "rbxassetid://112567788433260",
		Name = "Quiche",
		Rarity = "Exotic",
		Untradeable = true
	},
	["Subspace Tripmine"] = {
		Icon = "rbxassetid://72980965754053",
		Name = "Subspace Tripmine",
		Rarity = "Exotic",
		Untradeable = true
	},
	Detector = {
		Icon = "rbxassetid://108977243480731",
		Name = "Detector",
		Rarity = "Secret",
		Untradeable = true
	},
	alarm = {
		Icon = "rbxassetid://74239181571037",
		Name = "alarm",
		Rarity = "Secret",
		Untradeable = true
	},
	chicky = {
		Icon = "rbxassetid://4376443752",
		Name = "chicky",
		Rarity = "Secret",
		Untradeable = true
	},
	everythingandnothing = {
		Icon = "rbxassetid://128956909024507",
		Name = "everythingandnothing",
		Rarity = "Secret",
		Untradeable = true
	},
	Box = {
		Icon = "rbxassetid://102114073123598",
		Name = "Box",
		Rarity = "Exotic",
		Untradeable = true
	},
	Seal = {
		Name = "Seal",
		Rarity = "Secret",
		Icon = "rbxassetid://74728164289913",
		Untradeable = true
	},
	Glimmer = {
		Icon = "rbxassetid://125572557052913",
		Name = "Glimmer",
		Rarity = "Rare"
	},
	["Coral Reef"] = {
		Icon = "rbxassetid://140000844222620",
		Name = "Coral Reef",
		Rarity = "Rare",
		Untradeable = true
	},
	["Hour Glass"] = {
		Icon = "rbxassetid://110943692860133",
		Name = "Hour Glass",
		Rarity = "Rare"
	},
	["Ancient Book"] = {
		Icon = "rbxassetid://83503293129642",
		Name = "Ancient Book",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Frozen Rubber Ducky"] = {
		Icon = "rbxassetid://92871011795504",
		Name = "Frozen Rubber Ducky",
		Rarity = "Rare",
		Untradeable = true
	},
	["Bloop Bobber"] = {
		Icon = "rbxassetid://93229716319394",
		Name = "Bloop",
		Rarity = "Secret"
	},
	["Founders Rainbow"] = {
		Icon = "rbxassetid://125884939349479",
		Name = "Founders Rainbow",
		Rarity = "Mythical",
		Untradeable = true
	},
	Coal = {
		Icon = "rbxassetid://104346013224684",
		Name = "Coal",
		Rarity = "Rare",
		Untradeable = true
	},
	["Snow Globe"] = {
		Icon = "rbxassetid://103937598448133",
		Name = "Snow Globe",
		Rarity = "Legendary"
	},
	["Elite Crystal"] = {
		Icon = "rbxassetid://76053154971662",
		Name = "Elite Crystal",
		Rarity = "Mythical"
	},
	["Green Festive Light"] = {
		Icon = "rbxassetid://100520061266838",
		Name = "Green Festive Light",
		Rarity = "Unusual"
	},
	["Red Festive Light"] = {
		Icon = "rbxassetid://93159654126612",
		Name = "Red Festive Light",
		Rarity = "Unusual"
	},
	["White Festive Light"] = {
		Icon = "rbxassetid://89162373455066",
		Name = "White Festive Light",
		Rarity = "Unusual"
	},
	["Ruined Dreamer"] = {
		Icon = "rbxassetid://100329319237592",
		Name = "Ruined Dreamer",
		Rarity = "Unusual"
	},
	["Smurf Bobber"] = {
		Icon = "rbxassetid://101440279657772",
		Name = "Smurf Bobber",
		Rarity = "Legendary"
	},
	Stock = {
		Icon = "rbxassetid://76799441324551",
		Name = "Stock",
		Rarity = "Trash",
		Untradeable = true
	},
	["Pirate Wheel"] = {
		Icon = "rbxassetid://94489525636995",
		Name = "Pirate Wheel",
		Rarity = "Rare",
		Untradeable = true
	},
	Anchor = {
		Icon = "rbxassetid://101615176246826",
		Name = "Anchor",
		Rarity = "Rare",
		Untradeable = true
	},
	["Vertigo Rock"] = {
		Icon = "rbxassetid://103044252894263",
		Name = "Vertigo Rock",
		Rarity = "Legendary",
		Untradeable = true
	},
	Skeleton = {
		Icon = "rbxassetid://123014850160754",
		Name = "Skeleton",
		Rarity = "Rare",
		Untradeable = true
	},
	Sun = {
		Icon = "rbxassetid://85312711922352",
		Name = "Sun",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Fake Pufferfish"] = {
		Icon = "rbxassetid://81168563989804",
		Name = "Fake Pufferfish",
		Rarity = "Rare",
		Untradeable = true
	},
	Lava = {
		Icon = "rbxassetid://116728599052342",
		Name = "Lava",
		Rarity = "Legendary",
		Untradeable = true
	},
	Mushroom = {
		Icon = "rbxassetid://119638463716771",
		Name = "Mushroom",
		Rarity = "Rare",
		Untradeable = true
	},
	["Mini Terrapin"] = {
		Icon = "rbxassetid://115515112238230",
		Name = "Mini Terrapin",
		Rarity = "Rare",
		Untradeable = true
	},
	Aurora = {
		Icon = "rbxassetid://101257472871902",
		Name = "Aurora",
		Rarity = "Exotic",
		Untradeable = true
	},
	Frozen = {
		Icon = "rbxassetid://96047804486608",
		Name = "Frozen",
		Rarity = "Unusual",
		Untradeable = true
	},
	["Rubber Ducky"] = {
		Icon = "rbxassetid://128835062710982",
		Name = "Rubber Ducky",
		Rarity = "Legendary",
		Untradeable = true
	},
	Brine = {
		Icon = "rbxassetid://107669350039571",
		Name = "Brine",
		Rarity = "Mythical",
		Untradeable = true
	},
	Infested = {
		Icon = "rbxassetid://78022776552371",
		Name = "Infested",
		Rarity = "Rare",
		Untradeable = true
	},
	["Nautilis Shell"] = {
		Icon = "rbxassetid://99807185528001",
		Name = "Nautilus Shell",
		Rarity = "Mythical",
		Untradeable = true
	},
	Gem = {
		Icon = "rbxassetid://97671100659825",
		Name = "Gem",
		Rarity = "Legendary"
	},
	Amber = {
		Icon = "rbxassetid://131493732248880",
		Name = "Amber",
		Rarity = "Mythical",
		Untradeable = true
	},
	["Azure Flower"] = {
		Icon = "rbxassetid://98919375783065",
		Name = "Azure Flower",
		Rarity = "Rare",
		Untradeable = true
	},
	["Blue Moon"] = {
		Icon = "rbxassetid://123317352535188",
		Name = "Blue Moon",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Carrot Friend"] = {
		Icon = "rbxassetid://135165422634883",
		Name = "Carrot Friend",
		Rarity = "Mythical",
		Untradeable = true
	},
	["Cryogenic Icicle"] = {
		Icon = "rbxassetid://111354019763397",
		Name = "Cryogenic Icicle",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Crystal Cluster"] = {
		Icon = "rbxassetid://116929331648700",
		Name = "Crystal Cluster",
		Rarity = "Mythical",
		Untradeable = true
	},
	["Cursed Dreamer"] = {
		Icon = "rbxassetid://77217866354127",
		Name = "Cursed Dreamer",
		Rarity = "Mythical",
		Untradeable = true
	},
	["Ember Cluster"] = {
		Icon = "rbxassetid://90872728547417",
		Name = "Ember Cluster",
		Rarity = "Rare",
		Untradeable = true
	},
	["Fishing Net"] = {
		Icon = "rbxassetid://122251542701378",
		Name = "Fishing Net",
		Rarity = "Unusual",
		Untradeable = true
	},
	["Frigid Crystal"] = {
		Icon = "rbxassetid://106169553838480",
		Name = "Frigid Crystal",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Lobster Pal"] = {
		Icon = "rbxassetid://90332096279690",
		Name = "Lobster Pal",
		Rarity = "Unusual",
		Untradeable = true
	},
	["Lush Tree"] = {
		Icon = "rbxassetid://85326541463871",
		Name = "Lush Tree",
		Rarity = "Rare",
		Untradeable = true
	},
	["Spiritual Gem"] = {
		Icon = "rbxassetid://72231830342258",
		Name = "Spiritual Gem",
		Rarity = "Rare",
		Untradeable = true
	},
	Lighthouse = {
		Icon = "rbxassetid://119030827260896",
		Name = "Lighthouse",
		Rarity = "Rare",
		Untradeable = true
	},
	Cannon = {
		Icon = "rbxassetid://94869510397236",
		Name = "Cannon",
		Rarity = "Rare",
		Untradeable = true
	},
	["Chilled Spikes"] = {
		Icon = "rbxassetid://97908725842704",
		Name = "Chilled Spikes",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Quiet Crystal"] = {
		Icon = "rbxassetid://132344195198080",
		Name = "Quiet Crystal",
		Rarity = "Legendary",
		Untradeable = true
	},
	Harpoon = {
		Icon = "rbxassetid://125867785628617",
		Name = "Harpoon",
		Rarity = "Mythical",
		Untradeable = true
	},
	["Lava Spout"] = {
		Icon = "rbxassetid://131771496726433",
		Name = "Lava Spout",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Oceanic Tunnel"] = {
		Icon = "rbxassetid://89416376345265",
		Name = "Oceanic Tunnel",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Pine Tree"] = {
		Icon = "rbxassetid://124045584921732",
		Name = "Pine Tree",
		Rarity = "Rare",
		Untradeable = true
	},
	["Treasure Chest"] = {
		Icon = "rbxassetid://137712869113708",
		Name = "Treasure Chest",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Treasure Whale"] = {
		Icon = "rbxassetid://110792798559341",
		Name = "Treasure Whale",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Baby Anglerfish"] = {
		Icon = "rbxassetid://121694502433836",
		Name = "Baby Anglerfish",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Cliff Peak"] = {
		Icon = "rbxassetid://104620762656943",
		Name = "Cliff Peak",
		Rarity = "Rare",
		Untradeable = true
	},
	["Celestial Koi"] = {
		Name = "Celestial Koi",
		Rarity = "Legendary",
		Icon = "rbxassetid://104557486604363",
		Untradeable = true
	},
	["Abyssal Devourer"] = {
		Name = "Abyssal Devourer",
		Rarity = "Mythical",
		Icon = "rbxassetid://116196649776127",
		Untradeable = true
	},
	["Zeus' Herald"] = {
		Name = "Zeus' Herald",
		Rarity = "Legendary",
		Icon = "rbxassetid://116759995138970",
		Untradeable = true
	},
	["King Jellyfish"] = {
		Name = "King Jellyfish",
		Rarity = "Legendary",
		Icon = "rbxassetid://78893528650622",
		Untradeable = true
	},
	["Atlantis Guardian"] = {
		Icon = "rbxassetid://135865832852748",
		Name = "Atlantis Guardian",
		Rarity = "Legendary",
		Untradeable = true
	},
	Tornado = {
		Icon = "rbxassetid://137227877812366",
		Name = "Tornado",
		Rarity = "Legendary",
		Untradeable = true
	},
	Star = {
		Icon = "rbxassetid://115713630342231",
		Name = "Star",
		Rarity = "Rare"
	},
	Huge = {
		Icon = "rbxassetid://137446617417324",
		Name = "Huge",
		Rarity = "Unusual"
	},
	Cat = {
		Icon = "rbxassetid://85964398514625",
		Name = "Cat",
		Rarity = "Uncommon"
	},
	Cube = {
		Icon = "rbxassetid://104839564118786",
		Name = "Cube",
		Rarity = "Uncommon"
	},
	LED = {
		Icon = "rbxassetid://99705450689360",
		Name = "LED",
		Rarity = "Legendary"
	},
	Heart = {
		Icon = "rbxassetid://132020998293062",
		Name = "Heart",
		Rarity = "Common"
	},
	Wireframe = {
		Icon = "rbxassetid://115266544482422",
		Name = "Wireframe",
		Rarity = "Unusual"
	},
	Lightning = {
		Icon = "rbxassetid://85157161921697",
		Name = "Lightning",
		Rarity = "Legendary"
	},
	Translucent = {
		Icon = "rbxassetid://87423635427741",
		Name = "Translucent",
		Rarity = "Rare"
	},
	Income = {
		Icon = "rbxassetid://77826503777114",
		Name = "Income",
		Rarity = "Legendary"
	},
	["Evil Ducky"] = {
		Icon = "rbxassetid://111638923721053",
		Name = "Evil Ducky",
		Rarity = "Mythical"
	},
	["Jack-O-Bobber"] = {
		Icon = "rbxassetid://82351305391701",
		Name = "Jack-O-Bobber",
		Rarity = "Legendary"
	},
	["Dark Art Skull"] = {
		Icon = "rbxassetid://100729713012305",
		Name = "Dark Art Skull",
		Rarity = "Mythical"
	},
	Bat = {
		Icon = "rbxassetid://92078480249572",
		Name = "Bat",
		Rarity = "Legendary"
	},
	["Candy Corn"] = {
		Icon = "rbxassetid://110447219242882",
		Name = "Candy Corn",
		Rarity = "Legendary"
	},
	["Party Popper"] = {
		Icon = "rbxassetid://104482876123634",
		Name = "Party Popper",
		Rarity = "Legendary"
	},
	["Sunken Relic"] = {
		Icon = "rbxassetid://73938870647117",
		Name = "Sunken Relic",
		Rarity = "Rare"
	},
	Diamond = {
		Icon = "rbxassetid://136967467157106",
		Name = "Diamond",
		Rarity = "Uncommon",
		Untradeable = true
	},
	Shaped = {
		Icon = "rbxassetid://124787627420558",
		Name = "Shaped",
		Rarity = "Uncommon",
		Untradeable = true
	},
	Clover = {
		Icon = "rbxassetid://140697344570928",
		Name = "Clover",
		Rarity = "Uncommon"
	},
	Leaf = {
		Icon = "rbxassetid://70547053621945",
		Name = "Leaf",
		Rarity = "Uncommon"
	},
	Eye = {
		Icon = "rbxassetid://74590656527175",
		Name = "Eye",
		Rarity = "Unusual",
		Untradeable = true
	},
	["Gold Coin"] = {
		Icon = "rbxassetid://76807664247631",
		Name = "Gold Coin",
		Rarity = "Unusual"
	},
	Compass = {
		Icon = "rbxassetid://88366017993717",
		Name = "Compass",
		Rarity = "Unusual"
	},
	Whaley = {
		Icon = "rbxassetid://129902270860649",
		Name = "Whaley",
		Rarity = "Legendary"
	},
	["Meteor Stone"] = {
		Icon = "rbxassetid://78140806286048",
		Name = "Meteor Stone",
		Rarity = "Mythical"
	},
	["Drifter's Tale"] = {
		Icon = "rbxassetid://86585566958893",
		Name = "Drifter's Tale",
		Rarity = "Mythical"
	},
	Carbon = {
		Icon = "rbxassetid://120626791329576",
		Name = "Carbon",
		Rarity = "Mythical"
	},
	["Pirate Hat"] = {
		Name = "Pirate Hat",
		Rarity = "Mythical",
		Icon = "rbxassetid://114591288449487"
	},
	["Mermaid's Pearl"] = {
		Name = "Mermaid's Pearl",
		Rarity = "Mythical",
		Icon = "rbxassetid://122789457507786"
	},
	["Ocean King"] = {
		Name = "Ocean King",
		Rarity = "Mythical",
		Icon = "rbxassetid://71084280591752"
	},
	["Crown Of the Depths"] = {
		Name = "Crown Of the Depths",
		Rarity = "Mythical",
		Icon = "rbxassetid://139863572356522"
	},
	["Abyssal Skull"] = {
		Name = "Abyssal Skull",
		Rarity = "Mythical",
		Icon = "rbxassetid://79505111780839"
	},
	["Key of the Depths"] = {
		Name = "Key of the Depths",
		Rarity = "Mythical",
		Icon = "rbxassetid://83929526562174"
	},
	["Ancient Serpent Skull"] = {
		Name = "Ancient Serpent Skull",
		Rarity = "Mythical",
		Icon = "rbxassetid://138308561732851"
	},
	["Fossil Fish"] = {
		Name = "Fossil Fish",
		Rarity = "Mythical",
		Icon = "rbxassetid://81547981212724"
	},
	["Evil Totem"] = {
		Name = "Evil Totem",
		Rarity = "Mythical",
		Icon = "rbxassetid://104809963048785"
	},
	["Rune Meg Bobber"] = {
		Name = "Rune Meg Bobber",
		Rarity = "Mythical",
		Icon = "rbxassetid://80629752047698"
	},
	["Jade Serpent Bobber"] = {
		Name = "Jade Serpent Bobber",
		Rarity = "Mythical",
		Icon = "rbxassetid://134559252817102"
	},
	["Ancient Relic Bobber"] = {
		Name = "Ancient Relic Bobber",
		Rarity = "Mythical",
		Icon = "rbxassetid://134785609192501"
	},
	["Ancient Relic"] = {
		Name = "Ancient Relic",
		Rarity = "Mythical",
		Icon = "rbxassetid://95813765216243",
		Untradeable = true
	},
	["Jingle Bell"] = {
		Icon = "rbxassetid://85865140984021",
		Name = "Jingle Bell",
		Rarity = "Unusual"
	},
	["XMAS Ornament"] = {
		Icon = "rbxassetid://99811772542857",
		Name = "XMAS Ornament",
		Rarity = "Unusual"
	},
	["Gift Box"] = {
		Icon = "rbxassetid://83810721883782",
		Name = "Gift Box",
		Rarity = "Unusual"
	},
	Snowman = {
		Name = "Snowman",
		Rarity = "Mythical",
		Icon = "rbxassetid://87714065596578"
	},
	["Frozen Crown"] = {
		Name = "Frozen Crown",
		Rarity = "Mythical",
		Icon = "rbxassetid://80967763188770"
	},
	["Elf Hat"] = {
		Name = "Elf Hat",
		Rarity = "Mythical",
		Icon = "rbxassetid://94434954932659"
	},
	["North Star Bobber"] = {
		Name = "North Star Bobber",
		Rarity = "Mythical",
		Icon = "rbxassetid://112716883555023"
	},
	["Snowflake Crystal"] = {
		Name = "Snowflake Crystal",
		Rarity = "Mythical",
		Icon = "rbxassetid://79635443324042"
	},
	["Santa Hat"] = {
		Name = "Santa Hat",
		Rarity = "Mythical",
		Icon = "rbxassetid://103004522129962"
	},
	["Frozen Serpent"] = {
		Name = "Frozen Serpent",
		Rarity = "Mythical",
		Icon = "rbxassetid://85320134878932"
	},
	["Reindeer Antlers"] = {
		Name = "Reindeer Antlers",
		Rarity = "Mythical",
		Icon = "rbxassetid://134259827782610"
	},
	["Candy Cane"] = {
		Name = "Candy Cane",
		Rarity = "Mythical",
		Icon = "rbxassetid://81159661896669"
	},
	["Evil Santa"] = {
		Name = "Evil Santa",
		Rarity = "Mythical",
		Icon = "rbxassetid://97678383216332"
	},
	Firework = {
		Name = "Firework",
		Rarity = "Mythical",
		Icon = "rbxassetid://110815599910972"
	},
	["Festive Party Hat"] = {
		Name = "Festive Party Hat",
		Rarity = "Mythical",
		Icon = "rbxassetid://114646930546028"
	},
	["Confetti Globe"] = {
		Name = "Confetti Globe",
		Rarity = "Mythical",
		Icon = "rbxassetid://128448917834337"
	},
	["Crystallized Ball"] = {
		Icon = "rbxassetid://94606186834498",
		Name = "Crystallized Ball",
		Rarity = "Rare"
	},
	["Mythic Sea Star"] = {
		Name = "Mythic Sea Star",
		Rarity = "Mythical",
		Icon = "rbxassetid://96091312770944"
	},
	["Coral Crown"] = {
		Name = "Coral Crown",
		Rarity = "Mythical",
		Icon = "rbxassetid://101358685812580"
	},
	["Abyssal Trident"] = {
		Name = "Abyssal Trident",
		Rarity = "Mythical",
		Icon = "rbxassetid://76621534152641"
	},
	["Firework Rocket"] = {
		Name = "Firework Rocket",
		Rarity = "Mythical",
		Icon = "rbxassetid://86675023668200"
	},
	Firefin = {
		Name = "Firefin",
		Rarity = "Mythical",
		Icon = "rbxassetid://128188486396892"
	},
	["Gold Koi"] = {
		Name = "Gold Koi",
		Rarity = "Mythical",
		Icon = "rbxassetid://113535223746504"
	},
	Dreadspire = {
		Name = "Dreadspire",
		Rarity = "Mythical",
		Icon = "rbxassetid://128546804975251"
	},
	Skull = {
		Icon = "rbxassetid://70560452275181",
		Name = "Skull",
		Rarity = "Rare"
	},
	["Lunar Serpent"] = {
		Name = "Lunar Serpent",
		Rarity = "Mythical",
		Icon = "rbxassetid://101731310492214"
	},
	Seahorse = {
		Name = "Seahorse",
		Rarity = "Mythical",
		Icon = "rbxassetid://109858072350819"
	},
	["Fire Snake"] = {
		Name = "Fire Snake",
		Rarity = "Mythical",
		Icon = "rbxassetid://72738551442663"
	},
	Kraken = {
		Name = "Kraken",
		Rarity = "Mythical",
		Icon = "rbxassetid://97568467176521"
	},
	Mermaid = {
		Name = "Mermaid",
		Rarity = "Mythical",
		Icon = "rbxassetid://120124367491536"
	},
	["Sunken Ship"] = {
		Icon = "rbxassetid://86140451904387",
		Name = "Sunken Ship",
		Rarity = "Unusual"
	},
	["Sunken Diver"] = {
		Icon = "rbxassetid://106016205915048",
		Name = "Sunken Diver",
		Rarity = "Limited"
	},
	["Fang Fish"] = {
		Name = "Fang Fish",
		Rarity = "Mythical",
		Icon = "rbxassetid://83993444539394"
	},
	Firefly = {
		Name = "Firefly",
		Rarity = "Mythical",
		Icon = "rbxassetid://84629917295940"
	},
	Cyber = {
		Name = "Cyber",
		Rarity = "Mythical",
		Icon = "rbxassetid://81217309661379"
	},
	Orca = {
		Name = "Orca",
		Rarity = "Mythical",
		Icon = "rbxassetid://128610025107339"
	},
	["Love Heart"] = {
		Name = "Love Heart",
		Rarity = "Mythical",
		Icon = "rbxassetid://96561065534958"
	},
	["Box O’Chocolate"] = {
		Name = "Box O’Chocolate",
		Rarity = "Mythical",
		Icon = "rbxassetid://73794480159808"
	},
	["Cupid's Arrow"] = {
		Name = "Cupid's Arrow",
		Rarity = "Mythical",
		Icon = "rbxassetid://99324980050654"
	},
	["Skeleton Anchor"] = {
		Name = "Skeleton Anchor",
		Rarity = "Mythical",
		Icon = "rbxassetid://137275220428699"
	},
	["Soulless Fish"] = {
		Name = "Soulless Fish",
		Rarity = "Mythical",
		Icon = "rbxassetid://130031177097749"
	},
	["Obsidian Lockheart"] = {
		Name = "Obsidian Lockheart",
		Rarity = "Mythical",
		Icon = "rbxassetid://98118242139223"
	},
	["Midnight Medusa"] = {
		Name = "Midnight Medusa",
		Rarity = "Mythical",
		Icon = "rbxassetid://100717820674232"
	},
	Trenchmaw = {
		Name = "Trenchmaw",
		Rarity = "Mythical",
		Icon = "rbxassetid://96986544051038"
	},
	["Hadal Core"] = {
		Name = "Hadal Core",
		Rarity = "Mythical",
		Icon = "rbxassetid://84302833333365"
	},
	["Barnacle Buoy"] = {
		Name = "Barnacle Buoy",
		Rarity = "Mythical",
		Icon = "rbxassetid://133912211961524"
	},
	["Blue Whale Bobber"] = {
		Name = "Blue Whale Bobber",
		Rarity = "Mythical",
		Icon = "rbxassetid://126283166829234"
	},
	["Deep-Sea Diver Helmet"] = {
		Name = "Deep-Sea Diver Helmet",
		Rarity = "Mythical",
		Icon = "rbxassetid://131005330815336"
	},
	["Quantum Anchor"] = {
		Name = "Quantum Anchor",
		Rarity = "Mythical",
		Icon = "rbxassetid://136553783511691"
	},
	Drone = {
		Name = "Drone",
		Rarity = "Mythical",
		Icon = "rbxassetid://121845412315888"
	},
	Jetstrike = {
		Name = "Jetstrike",
		Rarity = "Mythical",
		Icon = "rbxassetid://106674730478947"
	},
	["Rainbow Shamrock"] = {
		Name = "Rainbow Shamrock",
		Rarity = "Mythical",
		Icon = "rbxassetid://102824558495490"
	},
	["Shamrock Stem"] = {
		Name = "Shamrock Stem",
		Rarity = "Mythical",
		Icon = "rbxassetid://127666729440119"
	},
	["Pot o’ Gold"] = {
		Name = "Pot o’ Gold",
		Rarity = "Mythical",
		Icon = "rbxassetid://98324432436323"
	},
	["Sunken Horror"] = {
		Name = "Sunken Horror",
		Rarity = "Mythical",
		Icon = "rbxassetid://125639578450568"
	},
	["Tentacle Orb"] = {
		Name = "Tentacle Orb",
		Rarity = "Mythical",
		Icon = "rbxassetid://139755019444057"
	},
	["Eldrich Eye"] = {
		Name = "Eldrich Eye",
		Rarity = "Mythical",
		Icon = "rbxassetid://94186199665259"
	},
	["Abyssal Heart"] = {
		Name = "Abyssal Heart",
		Rarity = "Mythical",
		Icon = "rbxassetid://113654402427277"
	},
	["Cursed Barnacle"] = {
		Name = "Cursed Barnacle",
		Rarity = "Mythical",
		Icon = "rbxassetid://73330185072801"
	},
	["Forbidden Glyph"] = {
		Name = "Forbidden Glyph",
		Rarity = "Mythical",
		Icon = "rbxassetid://97007070446370"
	},
	Porky = {
		Name = "Porky",
		Rarity = "Mythical",
		Icon = "rbxassetid://136157684651789"
	},
	["Lion’s Mane"] = {
		Name = "Lion’s Mane",
		Rarity = "Mythical",
		Icon = "rbxassetid://100122375952290"
	},
	["Silverback Fury"] = {
		Name = "Silverback Fury",
		Rarity = "Mythical",
		Icon = "rbxassetid://101776362234610"
	},
	["Devil Head"] = {
		Name = "Devil Head",
		Rarity = "Mythical",
		Icon = "rbxassetid://137689083872547"
	},
	["Golden Skull"] = {
		Name = "Golden Skull",
		Rarity = "Mythical",
		Icon = "rbxassetid://89879820755534"
	},
	["Man O War"] = {
		Name = "Man O War",
		Rarity = "Mythical",
		Icon = "rbxassetid://101417954842594"
	},
	["Glowfish Bobber"] = {
		Name = "Glowfish Bobber",
		Rarity = "Mythical",
		Icon = "rbxassetid://122977493566463"
	},
	["Roslit Bay Bobber"] = {
		Name = "Roslit Bay Bobber",
		Rarity = "Mythical",
		Icon = "rbxassetid://137216983183561"
	},
	["Bobber Of Odin"] = {
		Name = "Bobber Of Odin",
		Rarity = "Mythical",
		Icon = "rbxassetid://120725788236849"
	},
	["Cloud Castle"] = {
		Name = "Cloud Castle",
		Rarity = "Mythical",
		Icon = "rbxassetid://94956436996925"
	},
	["Odin's Journey"] = {
		Name = "Odin's Journey",
		Rarity = "Mythical",
		Icon = "rbxassetid://137892383036797"
	},
	["Crab Bobber"] = {
		Name = "Crab Bobber",
		Rarity = "Mythical",
		Icon = "rbxassetid://83454961975901"
	},
	["Lobster Head"] = {
		Name = "Lobster Head",
		Rarity = "Mythical",
		Icon = "rbxassetid://110143785803612"
	},
	["Blue Claw"] = {
		Name = "Blue Claw",
		Rarity = "Mythical",
		Icon = "rbxassetid://75136769846105"
	},
	["Cursed Coin"] = {
		Name = "Cursed Coin",
		Rarity = "Mythical",
		Icon = "rbxassetid://97744638229037"
	},
	["Hidden Treasure"] = {
		Name = "Hidden Treasure",
		Rarity = "Mythical",
		Icon = "rbxassetid://94659102495544"
	},
	["Treasure Island"] = {
		Name = "Treasure Island",
		Rarity = "Mythical",
		Icon = "rbxassetid://128341469902881"
	},
	["Apex Skull"] = {
		Name = "Apex Skull",
		Rarity = "Mythical",
		Icon = "rbxassetid://122869722889301"
	},
	Inkling = {
		Name = "Inkling",
		Rarity = "Mythical",
		Icon = "rbxassetid://140138452492674"
	},
	["Magma Serpent"] = {
		Name = "Magma Serpent",
		Rarity = "Mythical",
		Icon = "rbxassetid://71853474860791"
	},
	["Ice Skull"] = {
		Name = "Ice Skull",
		Rarity = "Mythical",
		Icon = "rbxassetid://86509881283450"
	},
	["Key of Obsidian"] = {
		Name = "Key of Obsidian",
		Rarity = "Mythical",
		Icon = "rbxassetid://103682471768786"
	},
	Slimely = {
		Name = "Slimely",
		Rarity = "Mythical",
		Icon = "rbxassetid://132382498404921"
	},
	Submarine = {
		Name = "Submarine",
		Rarity = "Mythical",
		Icon = "rbxassetid://95047920645936"
	},
	["Crystallized Relic"] = {
		Name = "Crystallized Relic",
		Rarity = "Mythical",
		Icon = "rbxassetid://138906207304160"
	},
	Nessie = {
		Name = "Nessie",
		Rarity = "Mythical",
		Icon = "rbxassetid://139125536519863"
	},
	["Cursed Mirror"] = {
		Name = "Cursed Mirror",
		Rarity = "Mythical",
		Icon = "rbxassetid://125939803359558"
	},
	["Prism Cube"] = {
		Name = "Prism Cube",
		Rarity = "Mythical",
		Icon = "rbxassetid://113705017200519"
	},
	["Phantom Dragon"] = {
		Name = "Phantom Dragon",
		Rarity = "Mythical",
		Icon = "rbxassetid://115154632412388"
	},
	["Book of Dreams"] = {
		Name = "Book of Dreams",
		Rarity = "Mythical",
		Icon = "rbxassetid://113398433341702"
	},
	["Dino Fang"] = {
		Name = "Dino Fang",
		Rarity = "Mythical",
		Icon = "rbxassetid://126029158554758"
	},
	["Eye of Seraph"] = {
		Name = "Eye of Seraph",
		Rarity = "Mythical",
		Icon = "rbxassetid://109440839854178"
	},
	["Magic Ball"] = {
		Name = "Magic Ball",
		Rarity = "Mythical",
		Icon = "rbxassetid://97506987402832"
	},
	Grenade = {
		Icon = "rbxassetid://113222520479118",
		Name = "Grenade",
		Rarity = "Trash",
		Untradeable = true
	},
	Bomb = {
		Icon = "rbxassetid://80789367331632",
		Name = "Bomb",
		Rarity = "Apex",
		Untradeable = true
	},
	goober = {
		Icon = "rbxassetid://125926541339320",
		Name = "goober",
		Rarity = "Trash",
		Untradeable = true
	},
	["the goober"] = {
		Icon = "rbxassetid://125926541339320",
		Name = "the goober",
		Rarity = "Trash",
		Untradeable = true
	},
	["The Dusekkar"] = {
		Icon = "rbxassetid://91676479698512",
		Name = "The Dusekkar",
		Rarity = "Secret",
		Untradeable = true
	}
}
local CrewStatueRewards = require(ReplicatedStorage.shared.modules.CrewStatueRewards)
CrewStatueRewards.addBobbers(Bobbers.Bobbers)

function toHex(color: Color3)
	return "#" .. color:ToHex()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onBobberGiveFailed(p, name: string)
	table.insert(p.Data.NewFormat.FailedRewards, {
		Type = "Bobber",
		Name = name,
		Amount = 1,
		Time = os.time()
	})
end

function Bobbers.Owns(_, p, childName: string)
	local character = require(ReplicatedStorage.shared.modules.character)
	local v = character.PS(p)

	if not (v and Bobbers.Bobbers[childName]) then
		return false
	end

	local bobber = v:FindFirstChild("Stats"):FindFirstChild("bobber")

	if bobber then
		return bobber:FindFirstChild(childName) and true or false
	end

	return false
end

function Bobbers.Give(_, player, name: string)
	local character = require(ReplicatedStorage.shared.modules.character)
	local v, v2 = character.PS(player)

	if not (v and v2) then
		return false
	end

	if Bobbers.Bobbers[name] then
		local bobber = v:FindFirstChild("Stats"):FindFirstChild("bobber")

		if not bobber then
			onBobberGiveFailed(v2, name) -- equivalent call inferred; original call site unknown
			return false
		end

		local child = bobber:FindFirstChild(name)

		if child then
			child.Value = tostring(tonumber(child.Value) + 1)
		else
			local stringValue = Instance.new("StringValue")
			stringValue.Name = name
			stringValue.Value = tostring(1)
			stringValue.Parent = bobber
		end

		local rarity = rarities.Rarities[Bobbers.Bobbers[name].Rarity]
		local v3 = string.match(name, "Bobber$") and name or name .. " Bobber"
		local v4 = "You have unlocked the <font color = '" .. toHex(rarity.Color) .. "'><b>" .. v3 .. "</b></font>!"

		if rarity.ColorGradient then
			v4 = "You have unlocked the <b>" .. v3 .. "</b>!"
		end

		ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_thought"):FireClient(
			player,
			v4,
			nil,
			nil,
			nil,
			Bobbers.Bobbers[name].Rarity
		)
		return true
	else
		warn((`Unknown bobber "{name}" given to {player.Name}!`))
		onBobberGiveFailed(v2, name) -- equivalent call inferred; original call site unknown
		return false
	end
end

function Bobbers.Remove(_, p, childName: string, value: number?)
	local character = require(ReplicatedStorage.shared.modules.character)
	local v = character.PS(p)

	if not v then
		return false
	end

	local bobber = v:FindFirstChild("Stats"):FindFirstChild("bobber")

	if not bobber then
		return false
	end

	local child = bobber:FindFirstChild(childName)

	if not child then
		return false
	end

	local v2 = (tonumber(child.Value) or 1) - (value or 1)

	if v2 <= 0 or value == 0 then
		child:Destroy()

		if bobber.Value == childName then
			bobber.Value = "Stock"
		end
	else
		child.Value = tostring(v2)
	end

	return true
end

return Bobbers