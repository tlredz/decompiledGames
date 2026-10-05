-- equivalent calls inferred from this helper; original call sites unknown
local function UTC(data)
	return DateTime.fromUniversalTime(data.year, data.month, data.day, data.hour or 0, data.min or 0, data.sec or 0).UnixTimestamp
end

local v = {
	["Penciled Out"] = {
		Display = "Penciled Out",
		Icon = "rbxassetid://122349516768088",
		NewSkin = true
	},
	["Craft Trimmers"] = {
		Display = "Craft Trimmers",
		Icon = "rbxassetid://112005537114308",
		NewSkin = true
	},
	["Toothache Dodger"] = {
		Display = "Toothache Dodger",
		Icon = "rbxassetid://133320232990605",
		NewSkin = true
	},
	["Chalkline Lasso"] = {
		Display = "Chalkline Lasso",
		Icon = "rbxassetid://77992512485049",
		NewSkin = true
	},
	["Bento Capsule"] = {
		Display = "Bento Capsule",
		Icon = "rbxassetid://100967668402396",
		NewSkin = true
	},
	["Crayon Bat"] = {
		Display = "Crayon Bat",
		Icon = "rbxassetid://93990211112416",
		NewSkin = true
	},
	["Milk Carton"] = {
		Display = "Milk Carton",
		Icon = "rbxassetid://95843098363318",
		NewSkin = true
	},
	["Graffiti Bat"] = {
		Display = "Graffiti Bat",
		Icon = "rbxassetid://113444392095354",
		NewSkin = true
	},
	["Classroom Capture"] = {
		Display = "Classroom Capture",
		Icon = "rbxassetid://109955407407638",
		NewSkin = true
	},
	["Note Taking Clippers"] = {
		Display = "Note Taking Clippers",
		Icon = "rbxassetid://106244173908818",
		NewSkin = true
	},
	["Stapler Taser"] = {
		Display = "Stapler Taser",
		Icon = "rbxassetid://112998425056805",
		NewSkin = true
	},
	["Teachers Pet Brush"] = {
		Display = "Teachers Pet Brush",
		Icon = "rbxassetid://104568270881118",
		NewSkin = true
	},
	["Paint Jetpack"] = {
		Display = "Paint Jetpack",
		Icon = "rbxassetid://110128877918895",
		NewSkin = true
	},
	["Pencil Pack"] = {
		Display = "Pencil Pack",
		Icon = "rbxassetid://135207834201427",
		NewSkin = true
	},
	["X's and O's Crushers"] = {
		Display = "X's and O's Crushers",
		Icon = "rbxassetid://96992809293143",
		NewSkin = true
	},
	["Trinket Lasso"] = {
		Display = "Trinket Lasso",
		Icon = "rbxassetid://118659997824511",
		NewSkin = false
	},
	["Ice Cream Bat"] = {
		Display = "IceCream Bat",
		Icon = "rbxassetid://113015038238469",
		NewSkin = false
	},
	["Sunbathe Ball"] = {
		Display = "Sunbathe Ball",
		Icon = "rbxassetid://70798719914551",
		NewSkin = false
	},
	["Beach Day Clippers"] = {
		Display = "Beach Day Clippers",
		Icon = "rbxassetid://105457339479683",
		NewSkin = false
	},
	["Banana Shocker"] = {
		Display = "Banana Shocker",
		Icon = "rbxassetid://82881346524752",
		NewSkin = false
	},
	["Seaside Capture"] = {
		Display = "Seaside Capture",
		Icon = "rbxassetid://135832088734398",
		NewSkin = false
	},
	["Sundial Capture"] = {
		Display = "Sundial Capture",
		Icon = "rbxassetid://80104632800236",
		NewSkin = false
	},
	["Popsicle Pack"] = {
		Display = "Popsicle Pack",
		Icon = "rbxassetid://77967921211857",
		NewSkin = false
	},
	["Deep Sea Jetpack"] = {
		Display = "Deep Sea Jetpack",
		Icon = "rbxassetid://118014338641052",
		NewSkin = false
	},
	["Coconut Dusters"] = {
		Display = "Coconut Dusters",
		Icon = "rbxassetid://92155223300316",
		NewSkin = false
	},
	["Shimmer Lasso"] = {
		Display = "Shimmer Lasso",
		Icon = "rbxassetid://120394969776525",
		NewSkin = false
	},
	["Hotdog Bat"] = {
		Display = "Hotdog Bat",
		Icon = "rbxassetid://122975811369449",
		NewSkin = false
	},
	["Melon Clippers"] = {
		Display = "Melon Clippers",
		Icon = "rbxassetid://139308537157504",
		NewSkin = false
	},
	["Crabby Stingers"] = {
		Display = "Crabby Stingers",
		Icon = "rbxassetid://127366877739851",
		NewSkin = false
	},
	["Beach Ball"] = {
		Display = "Beach Ball",
		Icon = "rbxassetid://136757994593559",
		NewSkin = false
	},
	Lemonade = {
		Display = "Lemonade",
		Icon = "rbxassetid://98642692566774",
		NewSkin = false
	},
	Watermelonade = {
		Display = "Watermelonade",
		Icon = "rbxassetid://78047541872640",
		NewSkin = false
	},
	["Orange Mango"] = {
		Display = "Orange Mango",
		Icon = "rbxassetid://73387882310426",
		NewSkin = false
	},
	["Strawberry Capture"] = {
		Display = "Strawberry Capture",
		Icon = "rbxassetid://81391327245803",
		NewSkin = false
	},
	["Sandy Pack"] = {
		Display = "Sandy Pack",
		Icon = "rbxassetid://139195411904876",
		NewSkin = false
	},
	["Sunset Smashers"] = {
		Display = "Sunset Smashers",
		Icon = "rbxassetid://101493673838653",
		NewSkin = false
	},
	["Shell Lasso"] = {
		Display = "Shell Lasso",
		Icon = "rbxassetid://105054445884438",
		NewSkin = false
	},
	Sandsmasher = {
		Display = "Sandsmasher",
		Icon = "rbxassetid://84211221274673",
		NewSkin = false
	},
	Glider = {
		Display = "Glider",
		Icon = "rbxassetid://131392626237481",
		NewSkin = false
	},
	["Sandbox Reprisal"] = {
		Display = "Sandbox Reprisal",
		Icon = "rbxassetid://85212926617467",
		NewSkin = false
	},
	["Beach Trimmer"] = {
		Display = "Beach Trimmer",
		Icon = "rbxassetid://87461999159716",
		NewSkin = false
	},
	["Beach Block"] = {
		Display = "Beach Block",
		Icon = "rbxassetid://71431307067625",
		NewSkin = false
	},
	["Eagle Wings"] = {
		Display = "Eagle Wings",
		Icon = "rbxassetid://114420257651587",
		NewSkin = false
	},
	["Patty Dodger"] = {
		Display = "Patty Dodger",
		Icon = "rbxassetid://91068390793591",
		NewSkin = false
	},
	["Freedom Zapper"] = {
		Display = "Freedom Zapper",
		Icon = "rbxassetid://85056202687488",
		NewSkin = false
	},
	["Independence Brush"] = {
		Display = "Independence Brush",
		Icon = "rbxassetid://79066712673972",
		NewSkin = false
	},
	["Independent Clippers"] = {
		Display = "Independent Clippers",
		Icon = "rbxassetid://114826873620970",
		NewSkin = false
	},
	["Freedom Bat"] = {
		Display = "Freedom Bat",
		Icon = "rbxassetid://119963244788875",
		NewSkin = false
	},
	["Freedom Taser"] = {
		Display = "Freedom Taser",
		Icon = "rbxassetid://77460657561489",
		NewSkin = false
	},
	["Heroic Gloves"] = {
		Display = "Heroic Gloves",
		Icon = "rbxassetid://123381538636196",
		NewSkin = false
	},
	["Liberated Ball"] = {
		Display = "Liberated Ball",
		Icon = "rbxassetid://124871744084732",
		NewSkin = false
	},
	["Star Spangled Gloves"] = {
		Display = "Star Spangled Gloves",
		Icon = "rbxassetid://125728933189526",
		NewSkin = false
	},
	["Star Spangled Taser"] = {
		Display = "Star Spangled Taser",
		Icon = "rbxassetid://113651267624045",
		NewSkin = false
	},
	["Feathered Lasso"] = {
		Display = "Feathered Lasso",
		Icon = "rbxassetid://138416135536852",
		NewSkin = false
	},
	["American Lasso"] = {
		Display = "American Lasso",
		Icon = "rbxassetid://109671856944233",
		NewSkin = false
	},
	["Spiritual Surfboard"] = {
		Display = "Spiritual Surfboard",
		Icon = "rbxassetid://125130924189021",
		NewSkin = false
	},
	["Spiritual Soarer"] = {
		Display = "Spiritual Soarer",
		Icon = "rbxassetid://81924329820310",
		NewSkin = false
	},
	["Coco Smashers"] = {
		Display = "Coco Smashers",
		Icon = "rbxassetid://90067783667085",
		NewSkin = false
	},
	["Hatch Smackers"] = {
		Display = "Hatch Smackers",
		Icon = "rbxassetid://84890652850421",
		NewSkin = false
	},
	["Bunny Booster"] = {
		Display = "Bunny Booster",
		Icon = "rbxassetid://83563880725296",
		NewSkin = false
	},
	["Sundae Thruster"] = {
		Display = "Sundae Thruster",
		Icon = "rbxassetid://104012194450696",
		NewSkin = false
	},
	["Hare Zapper"] = {
		Display = "Hare Zapper",
		Icon = "rbxassetid://106533901512989",
		NewSkin = false
	},
	["Bunny Beater"] = {
		Display = "Bunny Beater",
		Icon = "rbxassetid://134218346547959",
		NewSkin = false
	},
	["Harey Brush"] = {
		Display = "Harey Brush",
		Icon = "rbxassetid://138942327873823",
		NewSkin = false
	},
	["Hop Shot"] = {
		Display = "Hop Shot",
		Icon = "rbxassetid://122193545983067",
		NewSkin = false
	},
	["Egg Roller"] = {
		Display = "Egg Roller",
		Icon = "rbxassetid://130620951986673",
		NewSkin = false
	},
	["Chick Trimmer"] = {
		Display = "Chick Trimmer",
		Icon = "rbxassetid://117322562952451",
		NewSkin = false
	},
	["Bunny Capsule"] = {
		Display = "Bunny Capsule",
		Icon = "rbxassetid://139844141506040",
		NewSkin = false
	},
	["Bunny Bat"] = {
		Display = "Bunny Bat",
		Icon = "rbxassetid://76612031750552",
		NewSkin = false
	},
	["Egg Zapper"] = {
		Display = "Egg Zapper",
		Icon = "rbxassetid://96491782340309",
		NewSkin = false
	},
	["Hatchling Ball"] = {
		Display = "Hatchling Ball",
		Icon = "rbxassetid://110430189509920",
		NewSkin = false
	},
	["Peep Chain"] = {
		Display = "Peep Chain",
		Icon = "rbxassetid://104202906754058",
		NewSkin = false
	},
	["Egg Throne"] = {
		Display = "Egg Throne",
		Icon = "rbxassetid://89131693227041",
		NewSkin = false
	},
	["Yolk Bat"] = {
		Display = "Yolk Bat",
		Icon = "rbxassetid://106548707030538",
		NewSkin = false
	},
	["Bunny Clippers"] = {
		Display = "Bunny Clippers",
		Icon = "rbxassetid://85756513189076",
		NewSkin = false
	},
	["Easter Zapper"] = {
		Display = "Easter Zapper",
		Icon = "rbxassetid://72822841433648",
		NewSkin = false
	},
	["Easter Egg Brush"] = {
		Display = "Easter Egg Brush",
		Icon = "rbxassetid://105681501116176",
		NewSkin = false
	},
	["Egg Snatcher"] = {
		Display = "Egg Snatcher",
		Icon = "rbxassetid://125585244065160",
		NewSkin = false
	},
	["Bunny Ball"] = {
		Display = "Bunny Ball",
		Icon = "rbxassetid://96703010554511",
		NewSkin = false
	},
	["Egg Meadow Capture"] = {
		Display = "Egg Meadow Capture",
		Icon = "rbxassetid://133645842955618",
		NewSkin = false
	},
	["Egg Basket Jetpack"] = {
		Display = "Egg Basket Jetpack",
		Icon = "rbxassetid://77943549222788",
		NewSkin = false
	},
	["Bunny Gloves"] = {
		Display = "Bunny Gloves",
		Icon = "rbxassetid://74580560750070",
		NewSkin = false
	},
	["Ruby Zap"] = {
		Display = "Ruby Zap",
		Icon = "rbxassetid://70915009403985",
		NewSkin = false
	},
	["Shock Block"] = {
		Display = "Shock Block",
		Icon = "rbxassetid://134391519326914",
		NewSkin = false
	},
	["Moon Shot"] = {
		Display = "Moon Shot",
		Icon = "rbxassetid://98206117146585",
		NewSkin = false
	},
	["Cryo Box"] = {
		Display = "Cryo Box",
		Icon = "rbxassetid://116041845575168",
		NewSkin = false
	},
	["Storm King"] = {
		Display = "Storm King",
		Icon = "rbxassetid://74191143644762",
		NewSkin = false
	},
	["Frost Pulse"] = {
		Display = "Frost Pulse",
		Icon = "rbxassetid://123721896901926",
		NewSkin = false
	},
	["Iron Gear"] = {
		Display = "Iron Gear",
		Icon = "rbxassetid://90422755284137",
		NewSkin = false
	},
	["Cobalt Pop"] = {
		Display = "Cobalt Pop",
		Icon = "rbxassetid://76782811346133",
		NewSkin = false
	},
	["Retro Instant"] = {
		Display = "Retro Instant",
		Icon = "rbxassetid://104225928235143",
		NewSkin = false
	},
	["Sleek Digital"] = {
		Display = "Sleek Digital",
		Icon = "rbxassetid://80467935163582",
		NewSkin = false
	},
	["Vintage Leather"] = {
		Display = "Vintage Leather",
		Icon = "rbxassetid://74253340142975",
		NewSkin = false
	},
	["Pot o' Pain"] = {
		Display = "Pot o' Pain",
		Icon = "rbxassetid://115255209101281",
		NewSkin = false
	},
	["Clover Crusher"] = {
		Display = "Clover Crusher",
		Icon = "rbxassetid://101849183802761",
		NewSkin = false
	},
	["Clover Catcher"] = {
		Display = "Clover Catcher",
		Icon = "rbxassetid://133093294931798",
		NewSkin = false
	},
	["Rainbow Shocker"] = {
		Display = "Rainbow Shocker",
		Icon = "rbxassetid://138290242064260",
		NewSkin = false
	},
	["Lepre' Capture"] = {
		Display = "Lepre' Capture",
		Icon = "rbxassetid://94791182038392",
		NewSkin = false
	},
	["Lucky Drums Jetpack"] = {
		Display = "Lucky Drums Jetpack",
		Icon = "rbxassetid://112084070594700",
		NewSkin = false
	},
	["Wings o' Luck"] = {
		Display = "Wings o' Luck",
		Icon = "rbxassetid://96228664806916",
		NewSkin = false
	},
	["Pot o' Punch"] = {
		Display = "Pot o' Punch",
		Icon = "rbxassetid://113827117234439",
		NewSkin = false
	},
	["Lepre' Punch"] = {
		Display = "Lepre' Punch",
		Icon = "rbxassetid://127462792290058",
		NewSkin = false
	},
	["Windy Clover Jetpack"] = {
		Display = "Windy Clover Jetpack",
		Icon = "rbxassetid://104418515803037",
		NewSkin = false
	},
	["Radiant Star"] = {
		Display = "Radiant Star",
		Icon = "rbxassetid://91325007204384",
		NewSkin = false
	},
	["Emerald Fanous"] = {
		Display = "Emerald Fanous",
		Icon = "rbxassetid://114352266145544",
		NewSkin = false
	},
	["Midnight Crescent"] = {
		Display = "Midnight Crescent",
		Icon = "rbxassetid://121851047351895",
		NewSkin = false
	},
	["Crescent Lasso"] = {
		Display = "Crescent Lasso",
		Icon = "rbxassetid://130798774319469",
		NewSkin = false
	},
	["Luminous Lasso"] = {
		Display = "Luminous Lasso",
		Icon = "rbxassetid://96697919124964",
		NewSkin = false
	},
	["Aura Aviator"] = {
		Display = "Aura Aviator",
		Icon = "rbxassetid://127297758872190",
		NewSkin = false
	},
	["Celestial Carpet"] = {
		Display = "Celestial Carpet",
		Icon = "rbxassetid://92629227721381",
		NewSkin = false
	},
	["Fanous Flight"] = {
		Display = "Fanous Flight",
		Icon = "rbxassetid://137392313318894",
		NewSkin = false
	},
	["Lunar Thruster"] = {
		Display = "Lunar Thruster",
		Icon = "rbxassetid://106631303099372",
		NewSkin = false
	},
	["Radiant Rise"] = {
		Display = "Radiant Rise",
		Icon = "rbxassetid://104901747811829",
		NewSkin = false
	},
	["Pot of Gold"] = {
		Display = "Pot of Gold",
		Icon = "rbxassetid://101978824844434",
		NewSkin = false
	},
	["Four Leaf Bat"] = {
		Display = "Four Leaf Bat",
		Icon = "rbxassetid://121959179689519",
		NewSkin = false
	},
	["Fortunes Snare"] = {
		Display = "Fortunes Snare",
		Icon = "rbxassetid://138844182338364",
		NewSkin = false
	},
	["Pot o' Taser"] = {
		Display = "Pot o' Taser",
		Icon = "rbxassetid://137217910544014",
		NewSkin = false
	},
	["Dodge o' Gold"] = {
		Display = "Dodge o' Gold",
		Icon = "rbxassetid://132548791403130",
		NewSkin = false
	},
	["Fang Back"] = {
		Display = "Fang Back",
		Icon = "rbxassetid://124962984548193",
		NewSkin = false
	},
	["Berry Bounce"] = {
		Display = "Berry Bounce",
		Icon = "rbxassetid://73930969300326",
		NewSkin = false
	},
	["Tropic Trap"] = {
		Display = "Tropic Trap",
		Icon = "rbxassetid://90593944774856",
		NewSkin = false
	},
	["Hippie Hex"] = {
		Display = "Hippie Hex",
		Icon = "rbxassetid://103883876332054",
		NewSkin = false
	},
	["Gold Rush"] = {
		Display = "Gold Rush",
		Icon = "rbxassetid://97628923430903",
		NewSkin = false
	},
	["Star Burst"] = {
		Display = "Star Burst",
		Icon = "rbxassetid://131070961203578",
		NewSkin = false
	},
	["Button Up"] = {
		Display = "Button Up",
		Icon = "rbxassetid://123482176393889",
		NewSkin = false
	},
	["Crimson Drip"] = {
		Display = "Crimson Drip",
		Icon = "rbxassetid://96552407753829",
		NewSkin = false
	},
	["House Edge"] = {
		Display = "House Edge",
		Icon = "rbxassetid://88187025513701",
		NewSkin = false
	},
	["Tide Turn"] = {
		Display = "Tide Turn",
		Icon = "rbxassetid://120015173701505",
		NewSkin = false
	},
	["Bit Block"] = {
		Display = "Bit Block",
		Icon = "rbxassetid://99644985742494",
		NewSkin = false
	},
	["Tarot Reflect"] = {
		Display = "Tarot Reflect",
		Icon = "rbxassetid://79720528107322",
		NewSkin = false
	},
	["Action Swap"] = {
		Display = "Action Swap",
		Icon = "rbxassetid://131140924301765",
		NewSkin = false
	},
	["Holographic Swap"] = {
		Display = "Holographic Swap",
		Icon = "rbxassetid://96689294839277",
		NewSkin = false
	},
	["Kitty Reflect"] = {
		Display = "Kitty Reflect",
		Icon = "rbxassetid://85928718659951",
		NewSkin = false
	},
	["Bunny Swap"] = {
		Display = "Bunny Swap",
		Icon = "rbxassetid://119107741821093",
		NewSkin = false
	},
	["Cyber Counter"] = {
		Display = "Cyber Counter",
		Icon = "rbxassetid://89065655919144",
		NewSkin = false
	},
	["Royal Swap"] = {
		Display = "Royal Swap",
		Icon = "rbxassetid://79781569435029",
		NewSkin = false
	},
	["Glitched Counter"] = {
		Display = "Glitched Counter",
		Icon = "rbxassetid://75972324950764",
		NewSkin = false
	},
	["Heart Balloons"] = {
		Display = "Heart Balloons",
		Icon = "rbxassetid://72245654993195",
		NewSkin = false
	},
	["Cupid Orbit"] = {
		Display = "Cupid Orbit",
		Icon = "rbxassetid://85330981599575",
		NewSkin = false
	},
	["Tower of Love Bat"] = {
		Display = "Tower of Love Bat",
		Icon = "rbxassetid://113730386662202",
		NewSkin = false
	},
	["Heartlock Chain"] = {
		Display = "Heartlock Chain",
		Icon = "rbxassetid://134129054545677",
		NewSkin = false
	},
	["Crimson Kisses"] = {
		Display = "Crimson Kisses",
		Icon = "rbxassetid://137949438726550",
		NewSkin = false
	},
	["Love Bear Bat"] = {
		Display = "Love Bear Bat",
		Icon = "rbxassetid://106306508410667",
		NewSkin = false
	},
	["Sweet Static"] = {
		Display = "Sweet Static",
		Icon = "rbxassetid://73512499032012",
		NewSkin = false
	},
	["Molten Heart"] = {
		Display = "Molten Heart",
		Icon = "rbxassetid://102099371357349",
		NewSkin = false
	},
	["Torn Affection"] = {
		Display = "Torn Affection",
		Icon = "rbxassetid://86876594286997",
		NewSkin = false
	},
	["Cupid Bat"] = {
		Display = "Cupid Bat",
		Icon = "rbxassetid://95491591975297",
		NewSkin = false
	},
	["Rose Embrace"] = {
		Display = "Rose Embrace",
		Icon = "rbxassetid://73507205139598",
		NewSkin = false
	},
	["Sweet Knockout"] = {
		Display = "Sweet Knockout",
		Icon = "rbxassetid://116489080954943",
		NewSkin = false
	},
	["Midnight Crush"] = {
		Display = "Midnight Crush",
		Icon = "rbxassetid://98486235681325",
		NewSkin = false
	},
	["Rose Loop"] = {
		Display = "Rose Loop",
		Icon = "rbxassetid://76297706314392",
		NewSkin = false
	},
	["Thorned Hearts"] = {
		Display = "Thorned Hearts",
		Icon = "rbxassetid://94938487880131",
		NewSkin = false
	},
	["Love Surge"] = {
		Display = "Love Surge",
		Icon = "rbxassetid://134088874300503",
		NewSkin = false
	},
	["Rose Sting"] = {
		Display = "Rose Sting",
		Icon = "rbxassetid://115084990501018",
		NewSkin = false
	},
	["Ribbon Snare"] = {
		Display = "Ribbon Snare",
		Icon = "rbxassetid://86589685355792",
		NewSkin = false
	},
	["Cupid Shock"] = {
		Display = "Cupid Shock",
		Icon = "rbxassetid://77001233674625",
		NewSkin = false
	},
	["Sweet Bruiser"] = {
		Display = "Sweet Bruiser",
		Icon = "rbxassetid://77845964735183",
		NewSkin = false
	},
	["Cupid Core"] = {
		Display = "Cupid Core",
		Icon = "rbxassetid://138606448204093",
		NewSkin = false
	},
	["Throne of Hearts"] = {
		Display = "Throne of Hearts",
		Icon = "rbxassetid://138475162470693",
		NewSkin = false
	},
	["Love Burst"] = {
		Display = "Love Burst",
		Icon = "rbxassetid://127113524822796",
		NewSkin = false
	},
	["Cupids Guard"] = {
		Display = "Cupids Guard",
		Icon = "rbxassetid://123384936758679",
		NewSkin = false
	},
	["Confetti Taser"] = {
		Display = "Confetti Taser",
		Icon = "rbxassetid://75281976826451",
		NewSkin = false
	},
	["Confetti Gloves"] = {
		Display = "Confetti Gloves",
		Icon = "rbxassetid://135888642894704",
		NewSkin = false
	},
	["New Years Jetpack"] = {
		Display = "New Years Jetpack",
		Icon = "rbxassetid://85250095395754",
		NewSkin = false
	},
	["New Years Bat"] = {
		Display = "New Years Bat",
		Icon = "rbxassetid://91278692670986",
		NewSkin = false
	},
	["Resolution Lasso"] = {
		Display = "Resolution Lasso",
		Icon = "rbxassetid://129034444193651",
		NewSkin = false
	},
	["Firework Slugger"] = {
		Display = "Firework Slugger",
		Icon = "rbxassetid://113467559434108",
		NewSkin = false
	},
	["Firework Jetpack"] = {
		Display = "Firework Jetpack",
		Icon = "rbxassetid://114106158742462",
		NewSkin = false
	},
	["Firework Lasso"] = {
		Display = "Firework Lasso",
		Icon = "rbxassetid://102550025865202",
		NewSkin = false
	},
	["Disco Ball"] = {
		Display = "Disco Ball",
		Icon = "rbxassetid://132785786636109",
		NewSkin = false
	},
	["Cookie Taser"] = {
		Display = "Cookie Taser",
		Icon = "rbxassetid://79386097612891",
		NewSkin = false
	},
	["Cookie Wings"] = {
		Display = "Cookie Wings",
		Icon = "rbxassetid://127460716800007",
		NewSkin = false
	},
	["Peppermint Taser"] = {
		Display = "Peppermint Taser",
		Icon = "rbxassetid://80524738581870",
		NewSkin = false
	},
	["Stocking Gloves"] = {
		Display = "Stocking Gloves",
		Icon = "rbxassetid://118154986014846",
		NewSkin = false
	},
	["Cookie Gloves"] = {
		Display = "Cookie Gloves",
		Icon = "rbxassetid://116345308125853",
		NewSkin = false
	},
	Breadstick = {
		Display = "Breadstick",
		Icon = "rbxassetid://107130836427200",
		NewSkin = false
	},
	["Naughty List"] = {
		Display = "Naughty List",
		Icon = "rbxassetid://122872334103196",
		NewSkin = false
	},
	["Cookie Ball"] = {
		Display = "Cookie Ball",
		Icon = "rbxassetid://101302442278770",
		NewSkin = false
	},
	Giftbag = {
		Display = "Giftbag",
		Icon = "rbxassetid://128308390635645",
		NewSkin = false
	},
	Stocklash = {
		Display = "Stocklash",
		Icon = "rbxassetid://82581699429755",
		NewSkin = false
	},
	["Chimney Jetpack"] = {
		Display = "Chimney Jetpack",
		Icon = "rbxassetid://137533848818329",
		NewSkin = false
	},
	["Ginger Gun"] = {
		Display = "Ginger Gun",
		Icon = "rbxassetid://79386097612891",
		NewSkin = false
	},
	["Present Jetpack"] = {
		Display = "Present Jetpack",
		Icon = "rbxassetid://125977999693397",
		NewSkin = false
	},
	["Naughty Jetpack"] = {
		Display = "Naughty Jetpack",
		Icon = "rbxassetid://79428388805504",
		NewSkin = false
	},
	["Mischief Gloves"] = {
		Display = "Mischief Gloves",
		Icon = "rbxassetid://131534095798063",
		NewSkin = false
	},
	["Naughty Bat"] = {
		Display = "Naughty Bat",
		Icon = "rbxassetid://132768490535840",
		NewSkin = false
	},
	["Pine Bat"] = {
		Display = "Pine Bat",
		Icon = "rbxassetid://104150173745717",
		NewSkin = false
	},
	["Globe Capsule"] = {
		Display = "Globe Capsule",
		Icon = "rbxassetid://108161553668926",
		NewSkin = false
	},
	["Mischief Ball"] = {
		Display = "Mischief Ball",
		Icon = "rbxassetid://74419218534168",
		NewSkin = false
	},
	["Naughty Lasso"] = {
		Display = "Naughty Lasso",
		Icon = "rbxassetid://88860598731691",
		NewSkin = false
	},
	Pepperlash = {
		Display = "Pepperlash",
		Icon = "rbxassetid://130472445281488",
		NewSkin = false
	},
	["BlazeBuddy Jetpack"] = {
		Display = "BlazeBuddy Jetpack",
		Icon = "rbxassetid://108126204584242",
		NewSkin = false
	},
	["AquaBuddy Jetpack"] = {
		Display = "AquaBuddy Jetpack",
		Icon = "rbxassetid://122628919741163",
		NewSkin = false
	},
	["GameBuddy Jetpack"] = {
		Display = "GameBuddy Jetpack",
		Icon = "rbxassetid://77416111895786",
		NewSkin = false
	},
	["Jackpot Jetpack"] = {
		Display = "Jackpot Jetpack",
		Icon = "rbxassetid://107911438981728",
		NewSkin = false
	},
	["Stuffed Jetpack"] = {
		Display = "Stuffed Jetpack",
		Icon = "rbxassetid://135746729682285",
		NewSkin = false
	},
	["Stuffed Ball"] = {
		Display = "Stuffed Ball",
		Icon = "rbxassetid://139115095091505",
		NewSkin = false
	},
	["Tenderized Bat"] = {
		Display = "Tenderized Bat",
		Icon = "rbxassetid://105732053071247",
		NewSkin = false
	},
	["Tenderized Capsule"] = {
		Display = "Tenderized Capsule",
		Icon = "rbxassetid://106718810576643",
		NewSkin = false
	},
	["Autumn Lasso"] = {
		Display = "Autumn Lasso",
		Icon = "rbxassetid://111402487008631",
		NewSkin = false
	},
	["Fluffy Flight Jetpack"] = {
		Display = "Fluffy Flight Jetpack",
		Icon = "rbxassetid://101508190710488",
		NewSkin = false
	},
	["Petal Chan"] = {
		Display = "Petal Chan",
		Icon = "rbxassetid://109154584634636",
		NewSkin = false
	},
	["Kitty Clippers"] = {
		Display = "Kitty Clippers",
		Icon = "rbxassetid://121090254817643",
		NewSkin = false
	},
	["Purrfect Dodgeball"] = {
		Display = "Purrfect Dodgeball",
		Icon = "rbxassetid://124022282525594",
		NewSkin = false
	},
	["Hello Sparky"] = {
		Display = "Hello Sparky",
		Icon = "rbxassetid://76576263241749",
		NewSkin = false
	},
	["Binary Ball"] = {
		Display = "Binary Ball",
		Icon = "rbxassetid://95533918135577",
		NewSkin = false
	},
	["Bit Breaker Taser"] = {
		Display = "Bit Breaker Taser",
		Icon = "rbxassetid://110734554661401",
		NewSkin = false
	},
	["Crypto Clippers"] = {
		Display = "Crypto Clippers",
		Icon = "rbxassetid://77005224895534",
		NewSkin = false
	},
	["Glitch Wires"] = {
		Display = "Glitch Wires",
		Icon = "rbxassetid://81285137056189",
		NewSkin = false
	},
	["Byte Capsule"] = {
		Display = "Byte Capsule",
		Icon = "rbxassetid://104444777262396",
		NewSkin = false
	},
	["Acorn Club"] = {
		Display = "Acorn Club",
		Icon = "rbxassetid://126158531747581",
		NewSkin = false
	},
	["Leafy Capsule"] = {
		Display = "Leafy Capsule",
		Icon = "rbxassetid://97383273386690",
		NewSkin = false
	},
	["Crispy Clippers"] = {
		Display = "Crispy Clippers",
		Icon = "rbxassetid://105198725257521",
		NewSkin = false
	},
	["Chestnut Taser"] = {
		Display = "Chestnut Taser",
		Icon = "rbxassetid://112395184634211",
		NewSkin = false
	},
	["Harvest Hands"] = {
		Display = "Harvest Hands",
		Icon = "rbxassetid://109782004177636",
		NewSkin = false
	},
	["Speed Hero Jetpack"] = {
		Display = "Speed Hero Jetpack",
		Icon = "rbxassetid://84489136958901",
		NewSkin = false
	},
	["Revenger Bat"] = {
		Display = "Revenger Bat",
		Icon = "rbxassetid://113958972799781",
		NewSkin = false
	},
	["Secret Art Lasso"] = {
		Display = "Secret Art Lasso",
		Icon = "rbxassetid://90758885013435",
		NewSkin = false
	},
	["Void Gloves"] = {
		Display = "Void Gloves",
		Icon = "rbxassetid://128925491399384",
		NewSkin = false
	},
	["Capsule of Hope"] = {
		Display = "Capsule of Hope",
		Icon = "rbxassetid://101791122012215",
		NewSkin = false
	},
	Bonebreaker = {
		Display = "Bonebreaker",
		Icon = "rbxassetid://116911097073207",
		NewSkin = false
	},
	["Graveyard Clippers"] = {
		Display = "Graveyard Clippers",
		Icon = "rbxassetid://80698967837417",
		NewSkin = false
	},
	Bloodbind = {
		Display = "Bloodbind",
		Icon = "rbxassetid://77706826340150",
		NewSkin = false
	},
	["Hell Capsule"] = {
		Display = "Hell Capsule",
		Icon = "rbxassetid://135779490712651",
		NewSkin = false
	},
	Wand = {
		Display = "Wand",
		Icon = "rbxassetid://116831903358369",
		NewSkin = false
	},
	["Spine Soarer"] = {
		Display = "Spine Soarer",
		Icon = "rbxassetid://128821625886088",
		NewSkin = false
	},
	["Butcher Wings"] = {
		Display = "Butcher Wings",
		Icon = "rbxassetid://107424360778648",
		NewSkin = false
	},
	["Jack-O-Pack"] = {
		Display = "Jack-O-Pack",
		Icon = "rbxassetid://75990371252073",
		NewSkin = false
	},
	["Cursed Slugger"] = {
		Display = "Cursed Slugger",
		Icon = "rbxassetid://135707926149119",
		NewSkin = false
	},
	["Eternal Lasso"] = {
		Display = "Eternal Lasso",
		Icon = "rbxassetid://93124024299762",
		NewSkin = false
	},
	["Boney Clippers"] = {
		Display = "Boney Clippers",
		Icon = "rbxassetid://131637615466401",
		NewSkin = false
	},
	["Jack-O-Clippers"] = {
		Display = "Jack-O-Clippers",
		Icon = "rbxassetid://77819670906519",
		NewSkin = false
	},
	["Angelic Bat"] = {
		Display = "Angelic Bat",
		Icon = "rbxassetid://104313766719911",
		NewSkin = false
	},
	["Heavenly Taser"] = {
		Display = "Heavenly Taser",
		Icon = "rbxassetid://134885651894483",
		NewSkin = false
	},
	["Holy Wings"] = {
		Display = "Holy Wings",
		Icon = "rbxassetid://139496674228891",
		NewSkin = false
	},
	["Angelic Ball"] = {
		Display = "Angelic Ball",
		Icon = "rbxassetid://113897569245730",
		NewSkin = false
	},
	["Glassy Ball"] = {
		Display = "Glassy Ball",
		Icon = "rbxassetid://76675536876395",
		NewSkin = false
	},
	["Heavenly Capture"] = {
		Display = "Heavenly Capture",
		Icon = "rbxassetid://135103614620482",
		NewSkin = false
	},
	["Ribonic Jetpack"] = {
		Display = "Ribonic Jetpack",
		Icon = "rbxassetid://126694898491271",
		NewSkin = false
	},
	["Redistal Bat"] = {
		Display = "Redistal Bat",
		Icon = "rbxassetid://139811761930473",
		NewSkin = false
	},
	["Cutup Clippers"] = {
		Display = "Cutup Clippers",
		Icon = "rbxassetid://74539762847973",
		NewSkin = false
	},
	["Flesh Lasso"] = {
		Display = "Flesh Lasso",
		Icon = "rbxassetid://76553973908695",
		NewSkin = false
	},
	["Withering Rose"] = {
		Display = "Withering Rose",
		Icon = "rbxassetid://108776895339430",
		NewSkin = false
	},
	["Septre Bat"] = {
		Display = "Septre Bat",
		Icon = "rbxassetid://98261720070010",
		NewSkin = false
	},
	["Uneyed Brush"] = {
		Display = "Uneyed Brush",
		Icon = "rbxassetid://111436471783777",
		NewSkin = false
	},
	["Beetle Ball"] = {
		Display = "Beetle Ball",
		Icon = "rbxassetid://95167655413762",
		NewSkin = false
	},
	["Ancient Capsule"] = {
		Display = "Ancient Capsule",
		Icon = "rbxassetid://84225132856878",
		NewSkin = false
	},
	["Ancient Lasso"] = {
		Display = "Ancient Lasso",
		Icon = "rbxassetid://75427640944761",
		NewSkin = false
	},
	["Vexed Bat"] = {
		Display = "Vexed Bat",
		Icon = "rbxassetid://137618662267467",
		NewSkin = false
	},
	["Nocturne Clippers"] = {
		Display = "Nocturne Clippers",
		Icon = "rbxassetid://139617169987070",
		NewSkin = false
	},
	["Static Taser"] = {
		Display = "Static Taser",
		Icon = "rbxassetid://131546202390666",
		NewSkin = false
	},
	["Bleak Capture"] = {
		Display = "Bleak Capture",
		Icon = "rbxassetid://86313954488215",
		NewSkin = false
	},
	["Thorned Lasso"] = {
		Display = "Thorned Lasso",
		Icon = "rbxassetid://126302463890577",
		NewSkin = false
	},
	["Whisker Jetpack"] = {
		Display = "Whisker Jetpack",
		Icon = "rbxassetid://84118711259670",
		NewSkin = false
	},
	["Pawser Gloves"] = {
		Display = "Pawser Gloves",
		Icon = "rbxassetid://78129506603215",
		NewSkin = false
	},
	["Fluffdrive Clippers"] = {
		Display = "Fluffdrive Clippers",
		Icon = "rbxassetid://97929231042654",
		NewSkin = false
	},
	["Fuzzle Capture"] = {
		Display = "Fuzzle Capture",
		Icon = "rbxassetid://82202010071127",
		NewSkin = false
	},
	["Snug Bat"] = {
		Display = "Snug Bat",
		Icon = "rbxassetid://110375067960865",
		NewSkin = false
	},
	Emberjet = {
		Display = "Emberjet",
		Icon = "rbxassetid://86873546575905",
		NewSkin = false
	},
	["Infernum Bat"] = {
		Display = "Infernum Bat",
		Icon = "rbxassetid://77334333398309",
		NewSkin = false
	},
	["Smelter Clippers"] = {
		Display = "Smelter Clippers",
		Icon = "rbxassetid://131396325898347",
		NewSkin = false
	},
	["Cinder Lasso"] = {
		Display = "Cinder Lasso",
		Icon = "rbxassetid://93710078459655",
		NewSkin = false
	},
	["Ironclad Gloves"] = {
		Display = "Ironclad Gloves",
		Icon = "rbxassetid://86290769249100",
		NewSkin = false
	},
	["Pencil Pitcher"] = {
		Display = "Pencil Pitcher",
		Icon = "rbxassetid://129187991962641",
		NewSkin = false
	},
	["Nerdy Clippers"] = {
		Display = "Nerdy Clippers",
		Icon = "rbxassetid://120891803674559",
		NewSkin = false
	},
	["Scribble Strike"] = {
		Display = "Scribble Strike",
		Icon = "rbxassetid://102307326756172",
		NewSkin = false
	},
	["Recess Rope"] = {
		Display = "Recess Rope",
		Icon = "rbxassetid://134466606588778",
		NewSkin = false
	},
	Jetbag = {
		Display = "Jetbag",
		Icon = "rbxassetid://133925981811387",
		NewSkin = false
	},
	["Nebula Catcher"] = {
		Display = "Nebula Catcher",
		Icon = "rbxassetid://136614538956855",
		NewSkin = false
	},
	["Lightyear Clippers"] = {
		Display = "Lightyear Clippers",
		Icon = "rbxassetid://137774664095317",
		NewSkin = false
	},
	["Yee-haw Bat"] = {
		Display = "Yee-haw Bat",
		Icon = "rbxassetid://89647176179470",
		NewSkin = false
	},
	["One-Eyed Punch"] = {
		Display = "One-Eyed Punch",
		Icon = "rbxassetid://91703262000243",
		NewSkin = false
	},
	["Winding Jetpack"] = {
		Display = "Winding Jetpack",
		Icon = "rbxassetid://82122394760035",
		NewSkin = false
	},
	["Lightning Lash"] = {
		Display = "Lightning Lash",
		Icon = "rbxassetid://112526633244716",
		NewSkin = false
	},
	["Wonder Lash"] = {
		Display = "Wonder Lash",
		Icon = "rbxassetid://132934128129540",
		NewSkin = false
	},
	["Starstriker Bat"] = {
		Display = "Starstriker Bat",
		Icon = "rbxassetid://80313270760876",
		NewSkin = false
	},
	["Power of Friendship"] = {
		Display = "Power of Friendship",
		Icon = "rbxassetid://72692131437920",
		NewSkin = false
	},
	["Freedom Capsule"] = {
		Display = "Freedom Capsule",
		Icon = "rbxassetid://118567519606785",
		NewSkin = false
	},
	["Neighbors Cape"] = {
		Display = "Neighbors Cape",
		Icon = "rbxassetid://95740716003185",
		NewSkin = false
	},
	["Abducta-Bat"] = {
		Display = "Abducta-Bat",
		Icon = "rbxassetid://72537099277119",
		NewSkin = false
	},
	["Gamma Ball"] = {
		Display = "Gamma Ball",
		Icon = "rbxassetid://119186141894160",
		NewSkin = false
	},
	["Plasma Lasso"] = {
		Display = "Plasma Lasso",
		Icon = "rbxassetid://75375729175382",
		NewSkin = false
	},
	["One-Eyed Clippers"] = {
		Display = "One-Eyed Clippers",
		Icon = "rbxassetid://89135905734800",
		NewSkin = false
	},
	["Tiny Traveler"] = {
		Display = "Tiny Traveler",
		Icon = "rbxassetid://86153951915438",
		NewSkin = false
	},
	Lightsword = {
		Display = "Lightsword",
		Icon = "rbxassetid://103169320196981",
		NewSkin = false
	},
	["Pool Noodle"] = {
		Display = "Pool Noodle",
		Icon = "rbxassetid://96705537314393",
		NewSkin = false
	},
	["Prickler Bat"] = {
		Display = "Prickler Bat",
		Icon = "rbxassetid://124348193112741",
		NewSkin = false
	},
	["Spiked Bat"] = {
		Display = "Spiked Bat",
		Icon = "rbxassetid://14304471975"
	},
	["Barbarian Bat"] = {
		Display = "Barbarian Bat",
		Icon = "rbxassetid://14304472394"
	},
	["American Bat"] = {
		Display = "American Bat",
		Icon = "rbxassetid://14304472552"
	},
	["Hola Gato Bat"] = {
		Display = "Hola Gato Bat",
		Icon = "rbxassetid://14304472153"
	},
	["8-Ball Bat"] = {
		Display = "8-Ball Bat",
		Icon = "rbxassetid://14304472747"
	},
	["Stop Sign Bat"] = {
		Display = "Stop Sign Bat",
		Icon = "rbxassetid://14662580040"
	},
	["Golf Club"] = {
		Display = "Golf Club",
		Icon = "rbxassetid://14960862834"
	},
	Crowbar = {
		Display = "Crowbar",
		Icon = "rbxassetid://14960862995"
	},
	["Rusty Pipe"] = {
		Display = "Rusty Pipe",
		Icon = "rbxassetid://14960862477"
	},
	["Wooden Club"] = {
		Display = "Wooden Club",
		Icon = "rbxassetid://14960862285"
	},
	["Fly Swatter"] = {
		Display = "Fly Swatter",
		Icon = "rbxassetid://14960862924"
	},
	["Tennis Racket"] = {
		Display = "Tennis Racket",
		Icon = "rbxassetid://14960862365"
	},
	["Badminton Racket"] = {
		Display = "Badminton Racket",
		Icon = "rbxassetid://14960862729"
	},
	Sunflower = {
		Display = "Sunflower",
		Icon = "rbxassetid://17462366004"
	},
	["Lily Flower"] = {
		Display = "Lily Flower",
		Icon = "rbxassetid://17462363342"
	},
	["Daisy Flower"] = {
		Display = "Daisy Flower",
		Icon = "rbxassetid://17462360750"
	},
	Violaflare = {
		Display = "Violaflare",
		Icon = "rbxassetid://102781736530007",
		NewSkin = false
	},
	Hydrangea = {
		Display = "Hydrangea",
		Icon = "rbxassetid://124681028174531",
		NewSkin = false
	},
	["Checkered Gloves"] = {
		Display = "Checkered Gloves",
		Icon = "rbxassetid://115118213456157",
		NewSkin = false
	},
	["Gold Segway"] = {
		Display = "Gold Segway",
		Icon = "rbxassetid://14369140103"
	},
	["Lava Segway"] = {
		Display = "Lava Segway",
		Icon = "rbxassetid://14369142551"
	},
	["Nebula Segway"] = {
		Display = "Nebula Segway",
		Icon = "rbxassetid://14369141025"
	},
	["Water Segway"] = {
		Display = "Water Segway",
		Icon = "rbxassetid://14369141722"
	},
	["Pink Cloud"] = {
		Display = "Pink Cloud",
		Icon = "rbxassetid://14474842065"
	},
	["Tan Cloud"] = {
		Display = "Tan Cloud",
		Icon = "rbxassetid://14474840908"
	},
	["Red Cloud"] = {
		Display = "Red Cloud",
		Icon = "rbxassetid://14474839582"
	},
	["Yellow Cloud"] = {
		Display = "Yellow Cloud",
		Icon = "rbxassetid://14474836537"
	},
	["Aladdin's Carpet"] = {
		Display = "Aladdin's Carpet",
		Icon = "rbxassetid://14474822628"
	},
	["Sci-Fi Carpet"] = {
		Display = "Sci-Fi Carpet",
		Icon = "rbxassetid://14474820653"
	},
	["Stripey Carpet"] = {
		Display = "Stripey Carpet",
		Icon = "rbxassetid://14474828143"
	},
	["Trippy Carpet"] = {
		Display = "Trippy Carpet",
		Icon = "rbxassetid://14474833053"
	},
	["Heavenly Wings"] = {
		Display = "Heavenly Wings",
		Icon = "rbxassetid://14494595358"
	},
	["Megabat Wings"] = {
		Display = "Megabat Wings",
		Icon = "rbxassetid://14494595054"
	},
	["Fallen Wings"] = {
		Display = "Fallen Wings",
		Icon = "rbxassetid://14494595644"
	},
	["Sakura Wings"] = {
		Display = "Sakura Wings",
		Icon = "rbxassetid://14494594789"
	},
	["Angelic Wings"] = {
		Display = "Angelic Wings",
		Icon = "rbxassetid://14494596233"
	},
	["Bat Wings"] = {
		Display = "Bat Wings",
		Icon = "rbxassetid://14494595922"
	},
	["Demonic Wings"] = {
		Display = "Demonic Wings",
		Icon = "rbxassetid://14629188883"
	},
	["Dragon Wings"] = {
		Display = "Dragon Wings",
		Icon = "rbxassetid://14629189323"
	},
	["Vampire Wings"] = {
		Display = "Vampire Wings",
		Icon = "rbxassetid://14629189040"
	},
	["Lavender Wings"] = {
		Display = "Lavender Wings",
		Icon = "rbxassetid://14662534812"
	},
	["Fairy Wings"] = {
		Display = "Fairy Wings",
		Icon = "rbxassetid://14784638645"
	},
	["Ethereal Wings"] = {
		Display = "Ethereal Wings",
		Icon = "rbxassetid://14784638839"
	},
	["Lumnia Wings"] = {
		Display = "Lumnia Wings",
		Icon = "rbxassetid://14784638439"
	},
	["Black Bat Wings"] = {
		Display = "Black Bat Wings",
		Icon = "rbxassetid://14784639022"
	},
	Broom = {
		Display = "Broom",
		Icon = "rbxassetid://15113390985"
	},
	UFO = {
		Display = "UFO",
		Icon = "rbxassetid://15244715569"
	},
	Starpack = {
		Display = "Starpack",
		Icon = "rbxassetid://15244715832"
	},
	["Lava Hoverboard"] = {
		Display = "Lava Hoverboard",
		Icon = "rbxassetid://14512570420"
	},
	["Gold Hoverboard"] = {
		Display = "Gold Hoverboard",
		Icon = "rbxassetid://14512570666"
	},
	["Nebula Hoverboard"] = {
		Display = "Nebula Hoverboard",
		Icon = "rbxassetid://14512570159"
	},
	["Water Hoverboard"] = {
		Display = "Water Hoverboard",
		Icon = "rbxassetid://14512569869"
	},
	Bucket = {
		Display = "Bucket",
		Icon = "rbxassetid://14662524395"
	},
	Pot = {
		Display = "Pot",
		Icon = "rbxassetid://14662524013"
	},
	["Pumpkin Bag"] = {
		Display = "Pumpkin Bag",
		Icon = "rbxassetid://14662531289"
	},
	["Banana Peel"] = {
		Display = "Banana Peel",
		Icon = "rbxassetid://14662512106"
	},
	["Bear Trap"] = {
		Display = "Bear Trap",
		Icon = "rbxassetid://14662540964"
	},
	["Wet Sign"] = {
		Display = "Wet Sign",
		Icon = "rbxassetid://14662511752"
	},
	Blueberry = {
		Display = "Blueberry",
		Icon = "rbxassetid://14834322607"
	},
	Carrot = {
		Display = "Carrot",
		Icon = "rbxassetid://14834322486"
	},
	Dragonfruit = {
		Display = "Dragonfruit",
		Icon = "rbxassetid://14834322379"
	},
	Eggplant = {
		Display = "Eggplant",
		Icon = "rbxassetid://14834322270"
	},
	Orange = {
		Display = "Orange",
		Icon = "rbxassetid://14834322185"
	},
	["Tomato Pumpkin"] = {
		Display = "Tomato Pumpkin",
		Icon = "rbxassetid://14834322069"
	},
	["8-Bit Dragonite Wings"] = {
		Display = "8-Bit Dragonite Wings",
		Icon = "rbxassetid://15244716295"
	},
	["8-Bit Sapphire Wings"] = {
		Display = "8-Bit Sapphire Wings",
		Icon = "rbxassetid://15394864833"
	},
	["8-Bit Skeleton Wings"] = {
		Display = "8-Bit Skeleton Wings",
		Icon = "rbxassetid://15244716064"
	},
	["8-Bit Angelic Wings"] = {
		Display = "8-Bit Angelic Wings",
		Icon = "rbxassetid://15244716492"
	},
	["8-Bit Baseball Bat"] = {
		Display = "8-Bit Baseball Bat",
		Icon = "rbxassetid://15310671326"
	},
	["8-Bit Paper Bag"] = {
		Display = "8-Bit Paper Bag",
		Icon = "rbxassetid://15310671704"
	},
	["8-Bit Shocker"] = {
		Display = "8-Bit Shocker",
		Icon = "rbxassetid://15310671911"
	},
	["8-Bit Zapper"] = {
		Display = "8-Bit Zapper",
		Icon = "rbxassetid://15310671998"
	},
	["8-Bit Decoy"] = {
		Display = "8-Bit Decoy",
		Icon = "rbxassetid://15310671543"
	},
	["8-Bit Growth Potion"] = {
		Display = "8-Bit Growth Potion",
		Icon = "rbxassetid://15310671763"
	},
	["8-Bit Gloves"] = {
		Display = "8-Bit Gloves",
		Icon = "rbxassetid://15310672233"
	},
	["8-Bit Dodgeball"] = {
		Display = "8-Bit Dodgeball",
		Icon = "rbxassetid://15310672139"
	},
	["8-Bit Capsule"] = {
		Display = "8-Bit Capsule",
		Icon = "rbxassetid://15310671837"
	},
	["8-Bit Boogie Time"] = {
		Display = "8-Bit Boogie Time",
		Icon = "rbxassetid://15328832581"
	},
	["Leaf Blower"] = {
		Display = "Leaf Blower",
		Icon = "rbxassetid://15374889310"
	},
	Jollypack = {
		Display = "Jollypack",
		Icon = "rbxassetid://15580160009"
	},
	["Gamma Glider"] = {
		Display = "Gamma Glider",
		Icon = "rbxassetid://15580176141"
	},
	["Flora Flyer"] = {
		Display = "Flora Flyer",
		Icon = "rbxassetid://15580179151"
	},
	["Gift Capsule"] = {
		Display = "Gift Capsule",
		Icon = "rbxassetid://15580226395"
	},
	["Santa's Styler"] = {
		Display = "Santa's Styler",
		Icon = "rbxassetid://15580261323"
	},
	["Peppermint Ornament"] = {
		Display = "Peppermint Ornament",
		Icon = "rbxassetid://15580245535"
	},
	["Poinsettia Ornament"] = {
		Display = "Poinsettia Ornament",
		Icon = "rbxassetid://15580247034"
	},
	["Winter Ornament"] = {
		Display = "Winter Ornament",
		Icon = "rbxassetid://15580248413"
	},
	["Santa's Bag"] = {
		Display = "Santa's Bag",
		Icon = "rbxassetid://15580221232"
	},
	["Christmas Joyride"] = {
		Display = "Christmas Joyride",
		Icon = "rbxassetid://15580162676"
	},
	["Aero Pack"] = {
		Display = "Aero Pack",
		Icon = "rbxassetid://15580146477"
	},
	["Sunburst Flyer"] = {
		Display = "Sunburst Flyer",
		Icon = "rbxassetid://15580173143"
	},
	["Candy Cane Bat"] = {
		Display = "Candy Cane Bat",
		Icon = "rbxassetid://15580197198"
	},
	["Gift Bat"] = {
		Display = "Gift Bat",
		Icon = "rbxassetid://15580204110"
	},
	["Fancy Wrapped Bat"] = {
		Display = "Fancy Wrapped Bat",
		Icon = "rbxassetid://15580202211"
	},
	["Santa's Trimmer"] = {
		Display = "Santa's Trimmer",
		Icon = "rbxassetid://15580223942"
	},
	Snowball = {
		Display = "Snowball",
		Icon = "rbxassetid://15589821623"
	},
	["Christmas Lights Lasso"] = {
		Display = "Christmas Lights Lasso",
		Icon = "rbxassetid://15685905779"
	},
	FlowerCord = {
		Display = "Rose Vine",
		Icon = "rbxassetid://16289587190"
	},
	SaintPatRope = {
		Display = "Celtic Lasso",
		Icon = "rbxassetid://16734905139"
	},
	["Elf Pack"] = {
		Display = "Elf Pack",
		Icon = "rbxassetid://15716678722"
	},
	["Santa's Sleigh"] = {
		Display = "Santa's Sleigh",
		Icon = "rbxassetid://15716680436"
	},
	["Heart Ball"] = {
		Display = "Heart Ball",
		Icon = "rbxassetid://16316825086"
	},
	["Bouquet Bat"] = {
		Display = "Bouquet Bat",
		Icon = "rbxassetid://16316805080"
	},
	["Heart Bat"] = {
		Display = "Heart Bat",
		Icon = "rbxassetid://16316815727"
	},
	["Heart Cloud"] = {
		Display = "Heart Cloud",
		Icon = "rbxassetid://16316855332"
	},
	["Heart Wings"] = {
		Display = "Heart Wings",
		Icon = "rbxassetid://16316848630"
	},
	["Eternal Blossom Wings"] = {
		Display = "Eternal Blossom Wings",
		Icon = "rbxassetid://16316852192"
	},
	["Catch’O’Ball"] = {
		Display = "Catch’O’Ball",
		Icon = "rbxassetid://16705620845"
	},
	["Clover Bat"] = {
		Display = "Clover Bat",
		Icon = "rbxassetid://16705638253"
	},
	["Leprechaun's Ball"] = {
		Display = "Leprechaun's Ball",
		Icon = "rbxassetid://16705635208"
	},
	["Shamrock Dryer"] = {
		Display = "Shamrock Dryer",
		Icon = "rbxassetid://16705628345"
	},
	["Clippers of Chance"] = {
		Display = "Clippers of Chance",
		Icon = "rbxassetid://16705625251"
	},
	["Majestic Clover Wings"] = {
		Display = "Majestic Clover Wings",
		Icon = "rbxassetid://16709983740"
	},
	["Lucky Luminary"] = {
		Display = "Lucky Luminary",
		Icon = "rbxassetid://16709985669"
	},
	["Enchanting Brush"] = {
		Display = "Enchanting Brush",
		Icon = "rbxassetid://16726027071"
	},
	["Bat of Bountiful Blasts"] = {
		Display = "Bat of Bountiful Blasts",
		Icon = "rbxassetid://16881376572"
	},
	["Captivating Capsule of Confinement"] = {
		Display = "Captivating Capsule of Confinement",
		Icon = "rbxassetid://16881382457"
	},
	["Egg of Elusive Evasion"] = {
		Display = "Egg of Elusive Evasion",
		Icon = "rbxassetid://16881384806"
	},
	["Breezy Blaster of Brilliance"] = {
		Display = "Breezy Blaster of Brilliance",
		Icon = "rbxassetid://16881387463"
	},
	["Eggshell Wings"] = {
		Display = "Eggshell Wings",
		Icon = "rbxassetid://16881392368"
	},
	["Hare Hopper"] = {
		Display = "Hare Hopper",
		Icon = "rbxassetid://16881394912"
	},
	["Lapin Lasso"] = {
		Display = "Lapin Lasso",
		Icon = "rbxassetid://16881397686"
	},
	["Carrot Powered Clippers"] = {
		Display = "Carrot Powered Clippers",
		Icon = "rbxassetid://16881399889"
	},
	["Bunny Brush"] = {
		Display = "Bunny Brush",
		Icon = "rbxassetid://16883753099"
	},
	["Golf Ball"] = {
		Display = "Golf Ball",
		Icon = "rbxassetid://16896598980"
	},
	Volleyball = {
		Display = "Volleyball",
		Icon = "rbxassetid://16896602939"
	},
	["Soccer Ball"] = {
		Display = "Soccer Ball",
		Icon = "rbxassetid://16896606121"
	},
	Football = {
		Display = "Football",
		Icon = "rbxassetid://16896609008"
	},
	Basketball = {
		Display = "Basketball",
		Icon = "rbxassetid://16896612388"
	},
	["Tennis Ball"] = {
		Display = "Tennis Ball",
		Icon = "rbxassetid://16897236255"
	},
	Baseball = {
		Display = "Baseball",
		Icon = "rbxassetid://16896614643"
	},
	["Leaflet Capsule"] = {
		Display = "Leaflet Capsule",
		Icon = "rbxassetid://17209122535"
	},
	["Aqua Capsule"] = {
		Display = "Aqua Capsule",
		Icon = "rbxassetid://17227913342"
	},
	["Justice Capsule"] = {
		Display = "Justice Capsule",
		Icon = "rbxassetid://17227918106"
	},
	["Gemini Capsule"] = {
		Display = "Gemini Capsule",
		Icon = "rbxassetid://17227922938"
	},
	["Fiery Capsule"] = {
		Display = "Fiery Capsule",
		Icon = "rbxassetid://17227927034"
	},
	["Cosmic Zapper"] = {
		Display = "Cosmic Zapper",
		Icon = "rbxassetid://17209142105"
	},
	["Spectrum Zapper"] = {
		Display = "Spectrum Zapper",
		Icon = "rbxassetid://17209147801"
	},
	["Star Cuffs"] = {
		Display = "Star Cuffs",
		Icon = "rbxassetid://17209151405"
	},
	["Heart Cuffs"] = {
		Display = "Heart Cuffs",
		Icon = "rbxassetid://17228065018"
	},
	["Vortex Cuffs"] = {
		Display = "Vortex Cuffs",
		Icon = "rbxassetid://17228072682"
	},
	["Skull Cuffs"] = {
		Display = "Skull Cuffs",
		Icon = "rbxassetid://17209187592"
	},
	["Death Ball"] = {
		Display = "Death Ball",
		Icon = "rbxassetid://17209195625"
	},
	["Venom Ball"] = {
		Display = "Venom Ball",
		Icon = "rbxassetid://17224536312"
	},
	["Electro Ball"] = {
		Display = "Electro Ball",
		Icon = "rbxassetid://17209204270"
	},
	["The Meteor"] = {
		Display = "The Meteor",
		Icon = "rbxassetid://17209208231"
	},
	["Neon Link"] = {
		Display = "Neon Link",
		Icon = "rbxassetid://17621958216"
	},
	["Leafy Cord"] = {
		Display = "Leafy Cord",
		Icon = "rbxassetid://17621955839"
	},
	["Aqua Cord"] = {
		Display = "Aqua Cord",
		Icon = "rbxassetid://17621953526"
	},
	["Fiery Lasso"] = {
		Display = "Fiery Lasso",
		Icon = "rbxassetid://17621919985"
	},
	["Futuristic Lasso"] = {
		Display = "Futuristic Lasso",
		Icon = "rbxassetid://17621987553"
	},
	["Snake Cord"] = {
		Display = "Snake Cord",
		Icon = "rbxassetid://17621717055"
	},
	["The Belt"] = {
		Display = "The Belt",
		Icon = "rbxassetid://17621709799"
	},
	["Bow Cord"] = {
		Display = "Bow Cord",
		Icon = "rbxassetid://17621713638"
	},
	["Prism Flutter Wings"] = {
		Display = "Prism Flutter Wings",
		Icon = "rbxassetid://17609549864"
	},
	["Pastel Whisper Wings"] = {
		Display = "Pastel Whisper Wings",
		Icon = "rbxassetid://17609552199"
	},
	["Crimson Blaze Wings"] = {
		Display = "Crimson Blaze Wings",
		Icon = "rbxassetid://17609554053"
	},
	["Aurora Wings"] = {
		Display = "Aurora Wings",
		Icon = "rbxassetid://17609555836"
	},
	Duck = {
		Display = "Duck",
		Icon = "rbxassetid://17609680840"
	},
	["Moth Wings"] = {
		Display = "Moth Wings",
		Icon = "rbxassetid://17624250598"
	},
	["Divine Wings"] = {
		Display = "Divine Wings",
		Icon = "rbxassetid://17624245918"
	},
	["Abyssal Bat"] = {
		Display = "Abyssal Bat",
		Icon = "rbxassetid://17639566976"
	},
	["Sunstrike Bat"] = {
		Display = "Sunstrike Bat",
		Icon = "rbxassetid://17639564685"
	},
	Coconut = {
		Display = "Coconut",
		Icon = "rbxassetid://17639662892"
	},
	["Lego Blocks"] = {
		Display = "Lego Blocks",
		Icon = "rbxassetid://17663253514"
	},
	["Mint Frisbee"] = {
		Display = "Mint Frisbee",
		Icon = "rbxassetid://17685287274"
	},
	["Candy Frisbee"] = {
		Display = "Candy Frisbee",
		Icon = "rbxassetid://17685291477"
	},
	["Cartoony Paintball Gun"] = {
		Display = "Cartoony Paintball Gun",
		Icon = "rbxassetid://17685416863"
	},
	["Skittle Pop"] = {
		Display = "Skittle Pop",
		Icon = "rbxassetid://18638919621"
	},
	["Mango Pop"] = {
		Display = "Mango Pop",
		Icon = "rbxassetid://18638917146"
	},
	["Glazier Pop"] = {
		Display = "Glazier Pop",
		Icon = "rbxassetid://18638914364"
	},
	["Rainbow Pop"] = {
		Display = "Rainbow Pop",
		Icon = "rbxassetid://18638909190"
	},
	["Cherry Pop"] = {
		Display = "Cherry Pop",
		Icon = "rbxassetid://18638896044"
	},
	["Blueberry Pop"] = {
		Display = "Blueberry Pop",
		Icon = "rbxassetid://18638889221"
	},
	["Melted Coco"] = {
		Display = "Melted Coco",
		Icon = "rbxassetid://84040256500141"
	},
	["Wafer Vanilla"] = {
		Display = "Wafer Vanilla",
		Icon = "rbxassetid://75738980604994"
	},
	["Green Apple Pop"] = {
		Display = "Green Apple Pop",
		Icon = "rbxassetid://18638892906"
	},
	["Electric Guitar"] = {
		Display = "Electric Guitar",
		Icon = "rbxassetid://115215456641885",
		NewSkin = false
	},
	Ukulele = {
		Display = "Ukulele",
		Icon = "rbxassetid://117779920971133",
		NewSkin = false
	},
	Saxophone = {
		Display = "Saxophone",
		Icon = "rbxassetid://117327655931013"
	},
	Drums = {
		Display = "Drums",
		Icon = "rbxassetid://106140603407808"
	},
	Maracas = {
		Display = "Maracas",
		Icon = "rbxassetid://105428055012886"
	},
	Harp = {
		Display = "Harp",
		Icon = "rbxassetid://93656224455252"
	},
	Harmonica = {
		Display = "Harmonica",
		Icon = "rbxassetid://98672499881294",
		NewSkin = false
	},
	Tamborine = {
		Display = "Tambourine",
		Icon = "rbxassetid://95304454750785",
		NewSkin = false
	},
	Starjet = {
		Display = "Starjet",
		Icon = "rbxassetid://130357571196435",
		NewSkin = false
	},
	Cape = {
		Display = "Cape",
		Icon = "rbxassetid://109711388649681",
		NewSkin = false
	},
	["Surf Board"] = {
		Display = "Surf Board",
		Icon = "rbxassetid://97624934563684",
		NewSkin = false
	},
	["Breezcap Jetpack"] = {
		Display = "Breezcap Jetpack",
		Icon = "rbxassetid://103294558230721"
	},
	["Pizza Jetpack"] = {
		Display = "Pizza Jetpack",
		Icon = "rbxassetid://122213984837916"
	},
	["Jetski Jetpack"] = {
		Display = "Jetski Jetpack",
		Icon = "rbxassetid://75255810482205"
	},
	["Cornball Bat"] = {
		Display = "Cornball Bat",
		Icon = "rbxassetid://102161426345421"
	},
	["Downpour Bat"] = {
		Display = "Downpour Bat",
		Icon = "rbxassetid://119425758290533"
	},
	["Sprinkill Trap"] = {
		Display = "Sprinkill Trap",
		Icon = "rbxassetid://112576768184424"
	},
	["Red Bellflower"] = {
		Display = "Red Bellflower",
		Icon = "rbxassetid://111286296520509"
	},
	["Sand Potion"] = {
		Display = "Sand Potion",
		Icon = "rbxassetid://116455746697975"
	},
	["Melon Capsule"] = {
		Display = "Melon Capsule",
		Icon = "rbxassetid://137770240910581"
	},
	["Heartbit Capsule"] = {
		Display = "Heartbit Capsule",
		Icon = "rbxassetid://109553724105823"
	},
	["Seedraze Jetpack"] = {
		Display = "Seedraze Jetpack",
		Icon = "rbxassetid://75614917581499",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Poprush Jetpack"] = {
		Display = "Poprush Jetpack",
		Icon = "rbxassetid://72000279678631",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Tideshell Jetpack"] = {
		Display = "Tideshell Jetpack",
		Icon = "rbxassetid://70509768646963",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	SunBurst = {
		Display = "SunBurst",
		Icon = "rbxassetid://76187837523823",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Pollenix Jetpack"] = {
		Display = "Pollenix Jetpack",
		Icon = "rbxassetid://105496034662645",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Deepair Jetpack"] = {
		Display = "Deepair Jetpack",
		Icon = "rbxassetid://107937436353396",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Flamfloat Jetpack"] = {
		Display = "Flamfloat Jetpack",
		Icon = "rbxassetid://91925745212451",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Lemon Boba"] = {
		Display = "Lemon Boba",
		Icon = "rbxassetid://95630304379644",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Blueberry Boba"] = {
		Display = "Blueberry Boba",
		Icon = "rbxassetid://106425939143306",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Strawberry Boba"] = {
		Display = "Strawberry Boba",
		Icon = "rbxassetid://94864399955715",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Green Tea"] = {
		Display = "Green Tea",
		Icon = "rbxassetid://126545584557515",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Strawberry Cream"] = {
		Display = "Strawberry Cream",
		Icon = "rbxassetid://140228850269384",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Melon Pop"] = {
		Display = "Melon Pop",
		Icon = "rbxassetid://102603556289909",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Taste the Rainbow"] = {
		Display = "Taste the Rainbow",
		Icon = "rbxassetid://87371691360592",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Pearlite Capsule"] = {
		Display = "Pearlite Capsule",
		Icon = "rbxassetid://80390778781581",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Fizball Capsule"] = {
		Display = "Fizball Capsule",
		Icon = "rbxassetid://78907932762518",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Twilight Rose"] = {
		Display = "Twilight Rose",
		Icon = "rbxassetid://111144735402850",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Lupine Flower"] = {
		Display = "Lupine Flower",
		Icon = "rbxassetid://140353361265004",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Summer Clippers"] = {
		Display = "Summer Clippers",
		Icon = "rbxassetid://110968851548270",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Drippy Clippers"] = {
		Display = "Drippy Clippers",
		Icon = "rbxassetid://96896915267712",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Slamsicle Bat"] = {
		Display = "Slamsicle Bat",
		Icon = "rbxassetid://138631310640970",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Anchor Bat"] = {
		Display = "Anchor Bat",
		Icon = "rbxassetid://137184676437850",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Coffin Trap"] = {
		Display = "Coffin Trap",
		Icon = "rbxassetid://78218984767429",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Jawbreak Trap"] = {
		Display = "Jawbreak Trap",
		Icon = "rbxassetid://83206917863322",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Floral Gloves"] = {
		Display = "Floral Gloves",
		Icon = "rbxassetid://80691686255868",
		LimitedTime = {
			Start = UTC({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = UTC({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		}
	},
	["Cheetah Gloves"] = {
		Display = "Cheetah Gloves",
		Icon = "rbxassetid://135243512979601"
	},
	["Bandaged Gloves"] = {
		Display = "Bandaged Gloves",
		Icon = "rbxassetid://107943844780739"
	},
	["Frostbite Bat"] = {
		Display = "Frostbite Bat",
		Icon = "rbxassetid://18730548715"
	},
	["Fiery Frisbee"] = {
		Display = "Fiery Frisbee",
		Icon = "rbxassetid://18729611138"
	},
	["Monarch Butterfly Wings"] = {
		Display = "Monarch Butterfly Wings",
		Icon = "rbxassetid://17628797830"
	},
	["Tinkerbell Wings"] = {
		Display = "Tinkerbell Wings",
		Icon = "rbxassetid://17628801386"
	},
	["Rainbow Pack"] = {
		Display = "Rainbow Starpack",
		Icon = "rbxassetid://18729657368"
	},
	["Turtle Shell"] = {
		Display = "Turtle Shell",
		Icon = "rbxassetid://18729750688"
	},
	["Dog Bone"] = {
		Display = "Dog Bone",
		Icon = "rbxassetid://18729795593"
	},
	Soap = {
		Display = "Soap",
		Icon = "rbxassetid://18729801981"
	},
	["Ripper Wings"] = {
		Display = "Ripper Wings",
		Icon = "rbxassetid://90048336132483"
	},
	["Fear Flight"] = {
		Display = "Fear Flight",
		Icon = "rbxassetid://87420208405985"
	},
	["Soul Trap"] = {
		Display = "Soul Trap",
		Icon = "rbxassetid://123427311607543"
	},
	["Coffin Buzzer"] = {
		Display = "Coffin Buzzer",
		Icon = "rbxassetid://85515070385744"
	},
	["Spiderweb Lasso"] = {
		Display = "Spiderweb Lasso",
		Icon = "rbxassetid://82528768085704"
	},
	["Evil Broom"] = {
		Display = "Evil Broom",
		Icon = "rbxassetid://77456496838548"
	},
	["Franken Bat"] = {
		Display = "Franken Bat",
		Icon = "rbxassetid://75430482743022"
	},
	["Worm Lasso"] = {
		Display = "Worm Lasso",
		Icon = "rbxassetid://93598105699501"
	},
	["Compassionate Clippers"] = {
		Display = "Compassionate Clippers",
		Icon = "rbxassetid://81334487820147"
	},
	["Rosie's Ball"] = {
		Display = "Rosie's Ball",
		Icon = "rbxassetid://110789986523288"
	},
	["Blush Brush"] = {
		Display = "Blush Brush",
		Icon = "rbxassetid://115814643412204"
	},
	["Heart Pack"] = {
		Display = "Heart Pack",
		Icon = "rbxassetid://95072297519007"
	},
	["Valentine Jet"] = {
		Display = "Valentine Jet",
		Icon = "rbxassetid://93916733734283"
	},
	Valwings = {
		Display = "Valwings",
		Icon = "rbxassetid://93233833686310"
	},
	Bouquet = {
		Display = "Bouquet",
		Icon = "rbxassetid://82575406425436"
	},
	["Cupid's Capsule"] = {
		Display = "Cupid's Capsule",
		Icon = "rbxassetid://137846566336110"
	},
	["Cloverburst Wings"] = {
		Display = "Cloverburst Wings",
		Icon = "rbxassetid://92529604800843"
	},
	["Lucky Lift"] = {
		Display = "Lucky Lift",
		Icon = "rbxassetid://91788037970216"
	},
	["Fortune Capsule"] = {
		Display = "Fortune Capsule",
		Icon = "rbxassetid://71940710312764"
	},
	["Shamrock Ball"] = {
		Display = "Shamrock Ball",
		Icon = "rbxassetid://123734201947543"
	},
	["Charm Bat"] = {
		Display = "Charm Bat",
		Icon = "rbxassetid://86089324877284"
	},
	["Leprechaun's Clippers"] = {
		Display = "Leprechaun's Clippers",
		Icon = "rbxassetid://79532451337377"
	},
	["Girly Clippers"] = {
		Display = "Girly Clipper",
		Icon = "rbxassetid://124086517750637"
	},
	["Emo Clippers"] = {
		Display = "Emo Clippers",
		Icon = "rbxassetid://134297027570573"
	},
	["Rusty Clippers"] = {
		Display = "Rusty Clippers",
		Icon = "rbxassetid://85527801234282"
	},
	["Carbo Clippers"] = {
		Display = "Carbo Clippers",
		Icon = "rbxassetid://79604792898291"
	},
	Eggstriker = {
		Display = "Eggstriker",
		Icon = "rbxassetid://74011057490400"
	},
	["The Egg Trapper"] = {
		Display = "The Egg Trapper",
		Icon = "rbxassetid://109075151245536"
	},
	["Hard Candy Wings"] = {
		Display = "Hard Candy Wings",
		Icon = "rbxassetid://124114923838215"
	},
	["Egg Euphoria"] = {
		Display = "Egg Euphoria",
		Icon = "rbxassetid://137275752894485"
	},
	EggPack = {
		Display = "EggPack",
		Icon = "rbxassetid://123427300713699"
	},
	["Bunny Blower"] = {
		Display = "Bunny Blower",
		Icon = "rbxassetid://74412510225947"
	},
	["Easter's Lost Trimmers"] = {
		Display = "Easter's Lost Trimmers",
		Icon = "rbxassetid://78969618834384"
	},
	["Easter Brush"] = {
		Display = "Easter Brush",
		Icon = "rbxassetid://133803794250031"
	},
	["Celestial Bunny's Wings"] = {
		Display = "Celestial Bunny's Wings",
		Icon = "rbxassetid://123742029707376"
	},
	["Peep Lasso"] = {
		Display = "Peep Lasso",
		Icon = "rbxassetid://81154256833034"
	}
}
local Skins = require(game.ReplicatedStorage.Assets.Data.Crates.Skins)
local v102 = {}
local Skins2 = {}

for _, skin in Skins do
	for k, item in skin.Items do
		for _, v103 in item do
			v102[v103] = k
		end
	end
end

local function getCaseScaledPrice(rarity: string, items, price: number)
	if (not items[rarity] and 0 or #items[rarity] or 0) == 0 then
		return 0
	end

	if table.find({ "Unique", "???", "Collectible" }, rarity) then
		return 1e999
	end

	local v105 = ({
		Common = 52,
		Uncommon = 32,
		Rare = 9.6,
		Royalty = 5,
		Unique = 1,
		["???"] = 0.4,
		Collectible = 0
	})[rarity]

	if not v105 or v105 == 0 then
		return 1e999
	end

	local v106 = v105 / 100
	local v107 = ({
		Common = 2,
		Uncommon = 3,
		Rare = 4,
		Royalty = 5
	})[rarity] or 1
	return math.ceil(price * (1 / v106) * v107 / 100) * 100
end

local function getSkinCase(k: string)
	for k2, skin in Skins do
		for _, list in skin.Items do
			if table.find(list, k) then
				return k2
			end
		end
	end

	return nil
end

local Holiday = require(game.ReplicatedStorage.Modules.Holiday)
local currentHoliday = Holiday:GetCurrentHoliday()
local allHolidays = Holiday:GetAllHolidays()
local v103 = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Royalty = 4,
	Unique = 5,
	["???"] = 6
}

for k, v104 in v do
	local flag = false

	for _, allHoliday in allHolidays do
		if not (allHoliday.Skins and table.find(allHoliday.Skins, k)) then
			continue
		end

		flag = true
		break
	end

	if flag then
		if currentHoliday.Skins and table.find(currentHoliday.Skins, k) then
			v104.LimitedTime = {
				Start = UTC(currentHoliday.Deadline.Start),
				End = UTC(currentHoliday.Deadline.End)
			}
		else
			v104.LimitedTime = {
				Start = 1,
				End = 1
			}
		end
	end

	v104.Rarity = v102[k]
	v104.ItemType = "Skins"
	v104.Order = v103[v104.Rarity]
	local skinCase = getSkinCase(k)

	if skinCase and Skins[skinCase] then
		if Skins[skinCase].Offsale then
			v104.Price = 1e999
		else
			local price = Skins[skinCase].Price
			v104.Price = getCaseScaledPrice(v104.Rarity, Skins[skinCase].Items, price)
		end
	end

	if v104.LimitedTime then
		for _, skin in Skins do
			for _, list in skin.Items do
				if not table.find(list, k) then
					continue
				end

				skin.LimitedTimeItems = skin.LimitedTimeItems or {}
				skin.LimitedTimeItems[k] = v104.LimitedTime
			end
		end
	end

	Skins2[k] = v104
end

return Skins2