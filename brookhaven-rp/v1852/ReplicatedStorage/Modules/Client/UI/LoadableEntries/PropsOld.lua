local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local PropsOld = {
	Entries = {
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Lights",
			Id = 16110380278
		},
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Girly",
			Id = 16110674287
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Military",
			Id = 18654948940
		},
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Building",
			Id = 108132564917383
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Sign",
			Id = 16110076431
		},
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Big",
			Id = 16110564040
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Animals",
			Id = 112362742253914
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Construction",
			Id = 14496212898
		},
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Furniture",
			Id = 16110789195
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Money",
			Id = 16110301233
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Food",
			Id = 18655580145
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Fence",
			Id = 16110749147
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Car",
			Id = 18655361598
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Baby",
			Id = 16110417017
		},
		{
			Filter = "Decor",
			IsCategory = true,
			Name = "Plant",
			Id = 16110340940
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Screens",
			Id = 16110224723
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Infrastructure",
			Id = 129095123215429
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Tools",
			Id = 18596343075
		},
		{
			Filter = "Decor",
			IsCategory = true,
			Name = "Torch",
			Id = 16109966337
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Present",
			Id = 16110261404
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Dead",
			Id = 16109924795
		},
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Clothing",
			Id = 16110107152
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Hospital",
			Id = 16567546105
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Sports",
			Id = 18655525398
		},
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Box",
			Id = 16109857357
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "WoodWall",
			Id = 16276847386
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Case",
			Id = 16109880197
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Garbage",
			Id = 16276768092
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Pool",
			Id = 16110469391
		},
		{
			Filter = "Decor",
			IsCategory = true,
			Name = "Smoke",
			Id = 13260145408
		},
		{
			Filter = "Decor",
			IsCategory = true,
			Name = "Shape",
			Id = 13260180509
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Lazer",
			Id = 11631247077
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Music",
			Id = 14825812113
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Fireworks",
			Id = 16109789684
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Tape",
			Id = 11628229399
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Poster",
			Id = 16109942024
		},
		{
			Filter = "Decor",
			IsCategory = true,
			Name = "Award",
			Id = 16276813247
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Horse",
			Id = 16110871128
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Barrel",
			Id = 16276787591
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Power",
			Id = 16276832790
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "SmallVehicles",
			Id = 135571600092131
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Halloween",
			Id = 16109814927
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Christmas",
			Id = 16110144404
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "ArtsAndCrafts",
			Id = 100452914924215
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Carnival",
			Id = 91893071996987
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Thanksgiving",
			Id = 123953031559531
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Wicked",
			Id = 128031356488978,
			CategoryDisclaimer = "Brought to you by NBCU"
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Minions",
			Id = 83709397299167,
			CategoryDisclaimer = "Brought to you by NBCU"
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Jurassic",
			Id = 127781741642328
		},
		{
			Category = "Furniture",
			Id = 16898870174,
			Name = "FurnitureChairBrown2"
		},
		{
			Category = "Furniture",
			Id = 16006289669,
			Name = "FurnitureChairBrown"
		},
		{
			Category = "Furniture",
			Id = 112426451220559,
			Name = "FurnitureBasicStool"
		},
		{
			Category = "Furniture",
			Id = 16006248614,
			Name = "FurnitureChairBlack"
		},
		{
			Category = "Furniture",
			Id = 93227894570741,
			Name = "FuturisticChair"
		},
		{
			Category = "Furniture",
			Id = 16006248886,
			Name = "FurnitureChairBlackBig"
		},
		{
			Category = "Furniture",
			Id = 16006249188,
			Name = "FurnitureChairWhite"
		},
		{
			Category = "Furniture",
			Id = 100696637136916,
			Name = "FurnitureRockingChair"
		},
		{
			Category = "Furniture",
			Id = 109320658895121,
			Name = "FurnitureChairOffice",
			PropVIP = false
		},
		{
			Category = "Furniture",
			Id = 16246269441,
			Name = "FurnitureDesk"
		},
		{
			Category = "Furniture",
			Id = 91259760627406,
			Name = "DirectorChair"
		},
		{
			Category = "Furniture",
			Id = 16248926053,
			Name = "FurnitureToilet"
		},
		{
			Category = "Furniture",
			Name = "GoldenToilet",
			Item = "GoldenToilet"
		},
		{
			Category = "Furniture",
			Id = 16006249798,
			Name = "FurnitureLoungeChair"
		},
		{
			Category = "Furniture",
			Id = 16006249532,
			Name = "FurnitureBeanBag"
		},
		{
			Category = "Furniture",
			Id = 135693429981572,
			Name = "WickerChair"
		},
		{
			Category = "Furniture",
			Id = 77292168865760,
			Name = "Hammock"
		},
		{
			Category = "Furniture",
			Id = 87946256849154,
			Name = "PatioDayBed"
		},
		{
			Category = "Furniture",
			Id = 106123714458422,
			Name = "WickerTable"
		},
		{
			Category = "Furniture",
			Id = 73720220441465,
			Name = "ChairSwing"
		},
		{
			Category = "Furniture",
			Id = 118852708390426,
			Name = "BenchSwing",
			PropVIP = true
		},
		{
			Category = "Furniture",
			Id = 127262889108870,
			Name = "SingleTireSwing"
		},
		{
			Category = "Furniture",
			Id = 72280938265526,
			Name = "SharedTireSwing"
		},
		{
			Category = "Furniture",
			Id = 18594458401,
			Name = "FurnitureArtBoard"
		},
		{
			Category = "Furniture",
			Id = 16101208249,
			Name = "FurnitureBench"
		},
		{
			Category = "Furniture",
			Id = 16006250026,
			Name = "FurnitureCouchBrown"
		},
		{
			Category = "Furniture",
			Name = "LoungeChair",
			Item = "LoungeChair"
		},
		{
			Category = "Furniture",
			Id = 16006250203,
			Name = "FurnitureTablePicnic"
		},
		{
			Category = "Furniture",
			Id = 16246091126,
			Name = "FurnitureBleachers"
		},
		{
			Category = "Furniture",
			Id = 16019402617,
			Name = "FurniturePulpit"
		},
		{
			Category = "Furniture",
			Id = 79295263190495,
			Name = "FurnitureWoodCoffeeStand"
		},
		{
			Category = "Furniture",
			Id = 138405901687071,
			Name = "FurnitureSmallBookshelf"
		},
		{
			Category = "Furniture",
			Id = 134306326393175,
			Name = "FurnitureTableEmpty1",
			PropVIP = false
		},
		{
			Category = "Furniture",
			Id = 112150739896213,
			Name = "FurnitureTableEmpty2",
			PropVIP = false
		},
		{
			Category = "Furniture",
			Id = 105589393526286,
			Name = "FuturisticTable"
		},
		{
			Category = "Furniture",
			Id = 105976092555585,
			Name = "FuturisticTableSet"
		},
		{
			Category = "Furniture",
			Id = 16006250679,
			Name = "FurnitureTable2Person"
		},
		{
			Category = "Furniture",
			Id = 16006250505,
			Name = "FurnitureTable4Person"
		},
		{
			Category = "Furniture",
			Id = 16006250346,
			Name = "FurnitureTable4PersonModern",
			PropVIP = false
		},
		{
			Category = "Furniture",
			Id = 98568631160418,
			Name = "FuturisticCoffeeTable"
		},
		{
			Category = "Furniture",
			Id = 16896494077,
			Name = "FurnitureRoundTable"
		},
		{
			Category = "Furniture",
			Name = "BarTable",
			Item = "BarTable"
		},
		{
			Category = "Furniture",
			Id = 16006250905,
			Name = "FurnitureTableOutsideCover",
			PropVIP = false
		},
		{
			Category = "Furniture",
			Id = 138467218332615,
			Name = "FurnitureTwoSeatUmbrella",
			PropVIP = false
		},
		{
			Category = "Furniture",
			Id = 16006247537,
			Name = "FurnitureDresserSmallBlack",
			PropVIP = false
		},
		{
			Category = "Furniture",
			Id = 16006247342,
			Name = "FurnitureDresserSmallBrown",
			PropVIP = false
		},
		{
			Category = "Furniture",
			Id = 16006247911,
			Name = "FurnitureDresserBigBlack",
			PropVIP = false
		},
		{
			Category = "Furniture",
			Id = 16006289366,
			Name = "FurnitureDresserBigWhite",
			PropVIP = false
		},
		{
			Category = "Furniture",
			Id = 16006247750,
			Name = "FurnitureDresserBigBrown",
			PropVIP = false
		},
		{
			Category = "Furniture",
			Id = 87913461764129,
			Name = "FurnitureDresserArmoire",
			PropVIP = false
		},
		{
			Category = "Furniture",
			Id = 107132551461778,
			Name = "FurnitureMirror1"
		},
		{
			Category = "Furniture",
			Id = 83291742248762,
			Name = "FurnitureMirror2"
		},
		{
			Category = "Furniture",
			Id = 16101386161,
			Name = "FurnitureFileCabinet"
		},
		{
			Category = "Furniture",
			Id = 16102583007,
			Name = "FurnitureShelterBed"
		},
		{
			Category = "Furniture",
			Id = 16102582871,
			Name = "FurnitureBedWhite"
		},
		{
			Category = "Furniture",
			Id = 16102583109,
			Name = "FurnitureBunkBed"
		},
		{
			Category = "Furniture",
			Id = 83190161448251,
			Name = "FuturisticLargeBed"
		},
		{
			Category = "Furniture",
			Id = 16102582543,
			Name = "FurnitureDoor"
		},
		{
			Category = "Furniture",
			Id = 131981250331357,
			Name = "FurnitureSilverThrone",
			PropVIP = false
		},
		{
			Category = "Furniture",
			Id = 108144898723511,
			Name = "FurnitureGoldThrone"
		},
		{
			Category = "Furniture",
			Id = 78811973250078,
			Name = "CastleFancyChair"
		},
		{
			Category = "Furniture",
			Id = 117061753762641,
			Name = "CastleFancyDressingTable"
		},
		{
			Category = "Furniture",
			Id = 84334656921153,
			Name = "CastleFineChinaTeapot"
		},
		{
			Category = "Furniture",
			Id = 81559189559599,
			Name = "CastleTeacup&Saucer"
		},
		{
			Category = "Furniture",
			Id = 137854226259258,
			Name = "CastleFancyJug"
		},
		{
			Category = "Furniture",
			Id = 128559272837190,
			Name = "CastleFancyBed"
		},
		{
			Category = "Furniture",
			Id = 72819231786274,
			Name = "CastleFancyCurtains"
		},
		{
			Category = "Furniture",
			Id = 103156527074592,
			Name = "CastleFancyChandelier"
		},
		{
			Category = "Furniture",
			Id = 127881965505669,
			Name = "CastleFancyRug"
		},
		{
			Category = "Furniture",
			Id = 94940174467197,
			Name = "FurnitureRoundRug"
		},
		{
			Category = "Furniture",
			Id = 118936602818869,
			Name = "ArtisanRedCarpet"
		},
		{
			Category = "Furniture",
			Id = 102768203247190,
			Name = "ArtisanBlueCarpet"
		},
		{
			Category = "Furniture",
			Id = 132239098617385,
			Name = "Doormat"
		},
		{
			Category = "Furniture",
			Item = "EasterBeanbag1",
			Name = "Easter Beanbag 1"
		},
		{
			Category = "Furniture",
			Item = "EasterBeanbag2",
			Name = "Easter Beanbag 2"
		},
		{
			Category = "Furniture",
			Item = "EasterBeanbag3",
			Name = "Easter Beanbag 3"
		},
		{
			Category = "Furniture",
			Item = "EasterBeanbag4",
			Name = "Easter Beanbag 4"
		},
		{
			Category = "Furniture",
			Item = "FramedPortrait",
			Name = "FramedPortrait"
		},
		{
			Category = "Furniture",
			Item = "FloorCushion",
			Name = "FloorCushion"
		},
		{
			Category = "Furniture",
			Item = "LowBackrestChair",
			Name = "LowBackrestChair"
		},
		{
			Category = "Furniture",
			Item = "LowDiningTable",
			Name = "LowDiningTable"
		},
		{
			Category = "Furniture",
			Item = "KotatsuTable",
			Name = "KotatsuTable"
		},
		{
			Category = "Furniture",
			Item = "Futon",
			Name = "Futon"
		},
		{
			Category = "Furniture",
			Item = "SlidingDoor",
			Name = "SlidingDoor"
		},
		{
			Category = "Furniture",
			Item = "HangingScroll",
			Name = "HangingScroll"
		},
		{
			Category = "Furniture",
			Id = 82031750290293,
			Name = "BHStatue"
		},
		{
			Category = "Furniture",
			Id = 117888091609338,
			Name = "BirdBath"
		},
		{
			Category = "Furniture",
			Id = 87555220839065,
			Name = "Fuente"
		},
		{
			Category = "Furniture",
			Id = 106688307890299,
			Name = "Mirror#1"
		},
		{
			Category = "Furniture",
			Id = 133154991691964,
			Name = "Mirror#2"
		},
		{
			Category = "Furniture",
			Id = 137544511912989,
			Name = "Monstera"
		},
		{
			Category = "Furniture",
			Id = 75076453917460,
			Name = "Tarrario"
		},
		{
			Category = "Furniture",
			Id = 109167289694287,
			Name = "GlassHurricaneLantern"
		},
		{
			Category = "Furniture",
			Id = 109488552861479,
			Name = "RoomDiffuser"
		},
		{
			Category = "Furniture",
			Id = 124135134497473,
			Name = "LavenderWallPlanter"
		},
		{
			Category = "Furniture",
			Id = 88562449422613,
			Name = "PerfumeCarousel"
		},
		{
			Category = "Furniture",
			Id = 116958796514634,
			Name = "BookCart"
		},
		{
			Category = "Furniture",
			Id = 115175658138538,
			Name = "WaterBottle"
		},
		{
			Category = "Furniture",
			Id = 129623372580967,
			Name = "HeartMirror"
		},
		{
			Category = "Furniture",
			Id = 130459310048416,
			Name = "WickerTray"
		},
		{
			Category = "Furniture",
			Id = 109226519424399,
			Name = "PanRack"
		},
		{
			Category = "Pool",
			Id = 16018687373,
			Name = "PoolKiddie"
		},
		{
			Category = "Pool",
			Id = 16018687499,
			Name = "PoolTowelPurple"
		},
		{
			Category = "Pool",
			Id = 16018687661,
			Name = "PoolTowelBlue"
		},
		{
			Category = "Pool",
			Id = 16018687908,
			Name = "PoolTowelRainbow"
		},
		{
			Category = "Pool",
			Id = 16018687236,
			Name = "PoolSandBox"
		},
		{
			Category = "Pool",
			Id = 18594542862,
			Name = "PoolUmbrella"
		},
		{
			Category = "Pool",
			Id = 125525800469680,
			Name = "WaterBallonBox"
		},
		{
			Category = "Hospital",
			Id = 11450993492,
			Name = "HospitalMeds"
		},
		{
			Category = "Hospital",
			Id = 4689446576,
			Name = "HospitalEar"
		},
		{
			Category = "Hospital",
			Id = 18594491768,
			Name = "HospitalRedBag"
		},
		{
			Category = "Hospital",
			Id = 16019305321,
			Name = "HospitalBedBig"
		},
		{
			Category = "Hospital",
			Id = 4826313379,
			Name = "HospitalMobileBed"
		},
		{
			Category = "Hospital",
			Id = 16019305516,
			Name = "HospitalSurgeryTable"
		},
		{
			Category = "Hospital",
			Id = 83632173469602,
			Name = "HospitalChair"
		},
		{
			Category = "Hospital",
			Id = 83473131765860,
			Name = "HospitalStandingMachine",
			PropVIP = false
		},
		{
			Category = "Hospital",
			Id = 16019305673,
			Name = "HospitalEquippment"
		},
		{
			Category = "Hospital",
			Id = 16561995474,
			Name = "HospitalLabDesk"
		},
		{
			Category = "Hospital",
			Id = 16561982630,
			Name = "HospitalMicroscope"
		},
		{
			Category = "Hospital",
			Id = 16561974921,
			Name = "HospitalTestTubes"
		},
		{
			Category = "Hospital",
			Id = 91902135586521,
			Name = "HospitalLabTable"
		},
		{
			Category = "Hospital",
			Id = 16561987745,
			Name = "HospitalPurpleBig"
		},
		{
			Category = "Hospital",
			Id = 16561967872,
			Name = "HospitalBigAllColors"
		},
		{
			Category = "Hospital",
			Id = 16561977012,
			Name = "HospitalGreenMedium"
		},
		{
			Category = "Hospital",
			Id = 16561979025,
			Name = "HospitalSmallWhite"
		},
		{
			Category = "Hospital",
			Id = 16528242227,
			Name = "HospitalRedGlass"
		},
		{
			Category = "Hospital",
			Id = 16528238809,
			Name = "HospitalToothpasteGlass"
		},
		{
			Category = "Hospital",
			Id = 16528231611,
			Name = "HospitalGreenGlass"
		},
		{
			Category = "Tools",
			Id = 72692896848553,
			Name = "ToolsFakeKey"
		},
		{
			Category = "Tools",
			Id = 5484924743,
			Name = "ToolsToothBrush"
		},
		{
			Category = "Tools",
			Id = 81397801832715,
			Name = "ToolsFlashLight"
		},
		{
			Category = "Tools",
			Id = 90951449674748,
			Name = "Wrench"
		},
		{
			Category = "Tools",
			Id = 86143538303644,
			Name = "Hammer"
		},
		{
			Category = "Tools",
			Id = 4617189079,
			Name = "ToolsShovel"
		},
		{
			Category = "Tools",
			Id = 73101564394231,
			Name = "Axe"
		},
		{
			Category = "Tools",
			Id = 83961417899838,
			Name = "FireX"
		},
		{
			Category = "Tools",
			Id = 14982217383,
			Name = "ToolsLaundry"
		},
		{
			Category = "Tools",
			Id = 5480918435,
			Name = "ToolsVacuum"
		},
		{
			Category = "Tools",
			Id = 4539801080,
			Name = "ToolsMop"
		},
		{
			Category = "Tools",
			Id = 16101443395,
			Name = "ToolsMopBucket"
		},
		{
			Category = "Tools",
			Id = 18594414789,
			Name = "ToolsFart",
			PropVIP = true
		},
		{
			Category = "Dead",
			Id = 16010313895,
			Name = "DeadZombie"
		},
		{
			Category = "Dead",
			Id = 16010314377,
			Name = "DeadSkeletonLay"
		},
		{
			Category = "Dead",
			Id = 16010314714,
			Name = "DeadSkeletonSit"
		},
		{
			Category = "Dead",
			Id = 16010314268,
			Name = "DeadSkeletonStand"
		},
		{
			Category = "Dead",
			Id = 16010314502,
			Name = "DeadSkeletonStandArms"
		},
		{
			Category = "Dead",
			Id = 16010314139,
			Name = "DeadHeadStone"
		},
		{
			Category = "Dead",
			Id = 16010313720,
			Name = "DeadGraveBlood"
		},
		{
			Category = "Dead",
			Id = 16010314870,
			Name = "DeadGraveSkeleton"
		},
		{
			Category = "Dead",
			Id = 16010315111,
			Name = "DeadGraveBrown"
		},
		{
			Category = "Dead",
			Id = 16010314018,
			Name = "DeadGraveAgency"
		},
		{
			Category = "Dead",
			Id = 16010315001,
			Name = "DeadGraveBrownOpen"
		},
		{
			Category = "Dead",
			Id = 74663654253755,
			Name = "DeadCapsule"
		},
		{
			Category = "Fireworks",
			Id = 16103755658,
			Name = "Fireworks1"
		},
		{
			Category = "Fireworks",
			Id = 16103755469,
			Name = "Fireworks2"
		},
		{
			Category = "Fireworks",
			Id = 110114069942845,
			Name = "Fireworks3"
		},
		{
			Category = "Fireworks",
			Id = 79128227711162,
			Name = "Fireworks4"
		},
		{
			Category = "Food",
			Id = 4549503313,
			Name = "FoodApple"
		},
		{
			Category = "Food",
			Id = 4549503602,
			Name = "FoodGreenApple"
		},
		{
			Category = "Food",
			Id = 4548051724,
			Name = "FoodBanana"
		},
		{
			Category = "Food",
			Id = 4549492371,
			Name = "FoodPizzaSlice"
		},
		{
			Category = "Food",
			Id = 7550750852,
			Name = "FoodSingleHotDog"
		},
		{
			Category = "Food",
			Id = 7550751862,
			Name = "FoodSingleTaco"
		},
		{
			Category = "Food",
			Id = 7550749946,
			Name = "FoodSingleBurrito"
		},
		{
			Category = "Food",
			Id = 5211787314,
			Name = "FoodSingleBurger"
		},
		{
			Category = "Food",
			Id = 7550750347,
			Name = "FoodSingleSandwich"
		},
		{
			Category = "Food",
			Id = 7550750594,
			Name = "FoodSingleBread"
		},
		{
			Category = "Food",
			Id = 7550751347,
			Name = "FoodPretzel"
		},
		{
			Category = "Food",
			Id = 7550749589,
			Name = "FoodGuda"
		},
		{
			Category = "Food",
			Id = 128933466166889,
			Name = "Dessert_Tray_Empty"
		},
		{
			Category = "Food",
			Id = 102878747993484,
			Name = "Dessert_Tray"
		},
		{
			Category = "Food",
			Id = 97779129837345,
			Name = "Cupcake"
		},
		{
			Category = "Food",
			Id = 7550751581,
			Name = "FoodBlueBerryMuffin"
		},
		{
			Category = "Food",
			Id = 5664163065,
			Name = "FoodWaffle"
		},
		{
			Category = "Food",
			Id = 7550750449,
			Name = "FoodDounut"
		},
		{
			Category = "Food",
			Id = 7550750055,
			Name = "FoodCookie"
		},
		{
			Category = "Food",
			Id = 108380912226369,
			Name = "ChocolateBar"
		},
		{
			Category = "Food",
			Id = 4548053271,
			Name = "FoodSingleIcecream"
		},
		{
			Category = "Food",
			Id = 5814230667,
			Name = "FoodPopcorn"
		},
		{
			Category = "Food",
			Id = 126536042378581,
			Name = "ChipsGreen"
		},
		{
			Category = "Food",
			Id = 133850941133176,
			Name = "ChipsRed"
		},
		{
			Category = "Food",
			Id = 5480684668,
			Name = "FoodWaterBottle"
		},
		{
			Category = "Food",
			Id = 18596139421,
			Name = "FoodWaterGlass"
		},
		{
			Category = "Food",
			Id = 89078412261400,
			Name = "Coke"
		},
		{
			Category = "Food",
			Id = 4548051862,
			Name = "FoodSportsDrink"
		},
		{
			Category = "Food",
			Id = 7550750730,
			Name = "FoodMocha"
		},
		{
			Category = "Food",
			Id = 7550750989,
			Name = "FoodChocolateShake"
		},
		{
			Category = "Food",
			Id = 7550750171,
			Name = "FoodFrapMint"
		},
		{
			Category = "Food",
			Id = 7550750255,
			Name = "FoodFrapStrawberry"
		},
		{
			Category = "Food",
			Id = 97633368074855,
			Name = "Milk"
		},
		{
			Category = "Food",
			Id = 18596566674,
			Name = "FoodEmptyPlate"
		},
		{
			Category = "Food",
			Id = 7550751199,
			Name = "FoodPlateSteak"
		},
		{
			Category = "Food",
			Id = 7550751718,
			Name = "FoodPlateMexican"
		},
		{
			Category = "Food",
			Id = 7550751455,
			Name = "FoodPlateBreakfest"
		},
		{
			Category = "Food",
			Id = 7550749793,
			Name = "FoodPlateChicken"
		},
		{
			Category = "Food",
			Id = 13268293800,
			Name = "FoodPlateHotDogs"
		},
		{
			Category = "Food",
			Id = 10897693168,
			Name = "FoodTrayJail"
		},
		{
			Category = "Food",
			Id = 4550403278,
			Name = "FoodTrayBurger"
		},
		{
			Category = "Food",
			Id = 14240154894,
			Name = "FoodTakeOutBurger"
		},
		{
			Category = "Food",
			Id = 14240154561,
			Name = "FoodTakeOutDinner"
		},
		{
			Category = "Food",
			Id = 6239256493,
			Name = "FoodTakeOutPizza"
		},
		{
			Category = "Food",
			Id = 18639333674,
			Name = "FoodTakeOutMexican"
		},
		{
			Category = "Food",
			Id = 6239256320,
			Name = "FoodCake"
		},
		{
			Category = "Food",
			Id = 18639331601,
			Name = "FoodCottonCandy"
		},
		{
			Category = "Food",
			Id = 18639324570,
			Name = "FoodTrayIcecream"
		},
		{
			Category = "Food",
			Id = 15999579624,
			Name = "FoodPrepPlate"
		},
		{
			Category = "Food",
			Id = 16246133601,
			Name = "FoodPlateCake"
		},
		{
			Category = "Food",
			Id = 15999579420,
			Name = "FoodPrepKnife"
		},
		{
			Category = "Food",
			Id = 15999579774,
			Name = "FoodPrepBake"
		},
		{
			Category = "Food",
			Id = 15999579516,
			Name = "FoodPrepBlender"
		},
		{
			Category = "Food",
			Id = 15999579918,
			Name = "FoodPrepBrookios"
		},
		{
			Category = "Food",
			Id = 15999580052,
			Name = "FoodPrepBoil"
		},
		{
			Category = "Food",
			Id = 119003250571918,
			Name = "PortableCookingSet"
		},
		{
			Category = "Food",
			Id = 123974357215945,
			Name = "FoodToaster"
		},
		{
			Category = "Food",
			Id = 115695423578061,
			Name = "FoodCoffeeMaker"
		},
		{
			Category = "Food",
			Id = 84277017433815,
			Name = "FoodCoffeeMaker2"
		},
		{
			Category = "Food",
			Id = 15999580142,
			Name = "FoodStarbrooks"
		},
		{
			Category = "Food",
			Id = 15999578863,
			Name = "FoodPizza"
		},
		{
			Category = "Food",
			Id = 15999579296,
			Name = "FoodLosPanchos"
		},
		{
			Category = "Food",
			Id = 15999578985,
			Name = "FoodBrooksDiner"
		},
		{
			Category = "Food",
			Id = 15999579135,
			Name = "FoodHamburger"
		},
		{
			Category = "Food",
			Id = 16101385704,
			Name = "FoodTVTrayChicken"
		},
		{
			Category = "Food",
			Id = 16101385883,
			Name = "FoodTVTraySteak"
		},
		{
			Category = "Food",
			Id = 16101385466,
			Name = "FoodGroceryBags"
		},
		{
			Category = "Food",
			Id = 114665333418423,
			Name = "FoodTray"
		},
		{
			Category = "Food",
			Id = 12804552287,
			Name = "FoodCartEntree"
		},
		{
			Category = "Food",
			Id = 15999580218,
			Name = "FoodCooler"
		},
		{
			Category = "Food",
			Id = 123684889754643,
			Name = "FoodVendingMachineFull"
		},
		{
			Category = "Food",
			Id = 71015493367663,
			Name = "FoodVendingMachineHalf"
		},
		{
			Category = "Food",
			Id = 121983975736593,
			Name = "FoodVendingMachineEmpty"
		},
		{
			Category = "Construction",
			Id = 16101387234,
			Name = "ConstructionConeSingle",
			PropVIP = false
		},
		{
			Category = "Construction",
			Id = 16101386950,
			Name = "ConstructionConeStraight",
			PropVIP = false
		},
		{
			Category = "Construction",
			Id = 15999008900,
			Name = "ConstructionBarrel"
		},
		{
			Category = "Construction",
			Id = 15999009062,
			Name = "ConstructionBarSmall"
		},
		{
			Category = "Construction",
			Id = 15999009809,
			Name = "ConstructionBarBig"
		},
		{
			Category = "Construction",
			Id = 15999009538,
			Name = "ConstructionLight"
		},
		{
			Category = "Construction",
			Id = 15999009669,
			Name = "ConstructionSign"
		},
		{
			Category = "Construction",
			Id = 15999009365,
			Name = "ConstructionElectric"
		},
		{
			Category = "Construction",
			Id = 15999009213,
			Name = "ConstructionWater"
		},
		{
			Category = "Construction",
			Id = 99879334718917,
			Name = "Sandbags01"
		},
		{
			Category = "Construction",
			Id = 85564462966813,
			Name = "Sandbags02"
		},
		{
			Category = "Construction",
			Id = 77710878934720,
			Name = "Sandbags03"
		},
		{
			Category = "Poster",
			Id = 98873066531195,
			Name = "PosterMap2"
		},
		{
			Category = "Poster",
			Id = 16246024499,
			Name = "PosterWoodGraph"
		},
		{
			Category = "Poster",
			Id = 16101444767,
			Name = "PosterWoodMap"
		},
		{
			Category = "Poster",
			Id = 16101444871,
			Name = "PosterWoodPlans"
		},
		{
			Category = "Poster",
			Id = 16101444981,
			Name = "PosterWoodSubway"
		},
		{
			Category = "Poster",
			Id = 16101445082,
			Name = "PosterMap"
		},
		{
			Category = "Poster",
			Id = 16101445158,
			Name = "PosterPlans"
		},
		{
			Category = "Poster",
			Id = 16101445278,
			Name = "PosterSubway"
		},
		{
			Category = "Poster",
			Id = 72785543766332,
			Name = "PosterWorldMap"
		},
		{
			Category = "Poster",
			Id = 97464176535970,
			Name = "NewspaperStand"
		},
		{
			Category = "Poster",
			Id = 132035115583884,
			Name = "LeafletStand"
		},
		{
			Category = "Torch",
			Id = 109970501056679,
			Name = "TorchFireWood"
		},
		{
			Category = "Torch",
			Id = 15999345094,
			Name = "TorchFireBBQ"
		},
		{
			Category = "Torch",
			Id = 15999345637,
			Name = "TorchFire"
		},
		{
			Category = "Torch",
			Id = 15999356350,
			Name = "Torch4Skinny"
		},
		{
			Category = "Torch",
			Id = 15999344962,
			Name = "Torch2Skinny"
		},
		{
			Category = "Torch",
			Id = 15999345334,
			Name = "TorchBarrel"
		},
		{
			Category = "Torch",
			Id = 16249273586,
			Name = "TorchFireLong"
		},
		{
			Category = "Torch",
			Id = 15999344813,
			Name = "TorchLanturn"
		},
		{
			Category = "Animals",
			Id = 73697089709256,
			Name = "PetFoodBowl"
		},
		{
			Category = "Animals",
			Id = 132424986508756,
			Name = "DogHouse"
		},
		{
			Category = "Animals",
			Id = 134936022796132,
			Name = "ScratchPost"
		},
		{
			Category = "Animals",
			Id = 106218220483962,
			Name = "CatBed"
		},
		{
			Category = "Animals",
			Id = 122980160983225,
			Name = "DogBed"
		},
		{
			Category = "Animals",
			Id = 122466048301298,
			Name = "CatTower"
		},
		{
			Category = "Animals",
			Id = 73276837511671,
			Name = "BasketOfToys"
		},
		{
			Category = "Animals",
			Id = 17746937646,
			Name = "AnimalCatFish"
		},
		{
			Category = "Animals",
			Id = 17746939254,
			Name = "AnimalMeat"
		},
		{
			Category = "Animals",
			Id = 17747334376,
			Name = "AnimalBone"
		},
		{
			Category = "Animals",
			Id = 17746942969,
			Name = "AnimalCatToy"
		},
		{
			Category = "Animals",
			Id = 17746941051,
			Name = "AnimalKittyLitter"
		},
		{
			Category = "Animals",
			Id = 17746977452,
			Name = "AnimalCageBirdRed"
		},
		{
			Category = "Animals",
			Id = 17746979988,
			Name = "AnimalCageBirdBlue"
		},
		{
			Category = "Animals",
			Id = 18594484424,
			Name = "AnimalFishSmall"
		},
		{
			Category = "Animals",
			Id = 18594464810,
			Name = "AnimalFishBigVIP",
			PropVIP = true
		},
		{
			Category = "Animals",
			Id = 78898330463716,
			Name = "MedicineCabinet"
		},
		{
			Category = "Animals",
			Id = 114898215650099,
			Name = "MedicineCabinet2"
		},
		{
			Category = "Animals",
			Id = 92740983357212,
			Name = "WeighingScale"
		},
		{
			Category = "Lazer",
			Id = 16019834860,
			Name = "LazerSmall"
		},
		{
			Category = "Lazer",
			Id = 16019834562,
			Name = "LazerMedium"
		},
		{
			Category = "Lazer",
			Id = 16019834750,
			Name = "LazerLarge"
		},
		{
			Category = "Horse",
			Id = 15999183103,
			Name = "HorseBigBrown"
		},
		{
			Category = "Horse",
			Id = 15999142420,
			Name = "HorseBigBlack"
		},
		{
			Category = "Horse",
			Id = 15999142582,
			Name = "HorseSmallTan"
		},
		{
			Category = "Horse",
			Id = 15999143447,
			Name = "HorseSmallGrey"
		},
		{
			Category = "Horse",
			Id = 15999142279,
			Name = "HorseSmallWhite"
		},
		{
			Category = "Horse",
			Id = 15999181407,
			Name = "HorseHay"
		},
		{
			Category = "Horse",
			Id = 74181623506279,
			Name = "HorseSaddle"
		},
		{
			Category = "Horse",
			Id = 81303123592181,
			Name = "HorseJumpSmall"
		},
		{
			Category = "Horse",
			Id = 78703971359856,
			Name = "HorseJumpMedium"
		},
		{
			Category = "Horse",
			Id = 124781995731939,
			Name = "HorseJumpLarge"
		},
		{
			Category = "Horse",
			PassRequired = "HORSE_UNLOCKED",
			Name = "PropAkhal-Teke",
			ThemeImage = "rbxassetid://131468654182120",
			Id = 108378998335330,
			PropVIP = false
		},
		{
			Category = "Horse",
			PassRequired = "HORSE_UNLOCKED",
			Name = "PropShire",
			ThemeImage = "rbxassetid://131468654182120",
			Id = 96292534416237,
			PropVIP = false
		},
		{
			Category = "Horse",
			PassRequired = "HORSE_UNLOCKED",
			Name = "PropMiniHorse",
			ThemeImage = "rbxassetid://131468654182120",
			Id = 111214088979100,
			PropVIP = false
		},
		{
			Category = "Horse",
			PassRequired = "HORSE_UNLOCKED",
			Name = "PropFriesian",
			ThemeImage = "rbxassetid://131468654182120",
			Id = 107295990839355,
			PropVIP = false
		},
		{
			Category = "Horse",
			PassRequired = "HORSE_UNLOCKED",
			Name = "PropDonkey",
			ThemeImage = "rbxassetid://131468654182120",
			Id = 135957522719531,
			PropVIP = false
		},
		{
			Category = "Horse",
			PassRequired = "HORSE_UNLOCKED",
			Name = "PropClydesdale",
			ThemeImage = "rbxassetid://131468654182120",
			Id = 109897302072282,
			PropVIP = false
		},
		{
			Category = "Sports",
			Id = 138912255107273,
			Name = "Basketball"
		},
		{
			Category = "Sports",
			Id = 4598172149,
			Name = "SportsSoccerBall"
		},
		{
			Category = "Sports",
			Id = 16016812749,
			Name = "SportsWeights"
		},
		{
			Category = "Sports",
			Id = 81323792839864,
			Name = "SitUpBench"
		},
		{
			Category = "Sports",
			Id = 89073540131858,
			Name = "Treadmill"
		},
		{
			Category = "Sports",
			Id = 80387084368843,
			Name = "PullUpBar"
		},
		{
			Category = "Sports",
			Id = 96522342572017,
			Name = "WeightBench"
		},
		{
			Category = "Sports",
			Id = 18594418619,
			Name = "SportsBike"
		},
		{
			Category = "Sports",
			Id = 16896509116,
			Name = "SportsPunchingBag"
		},
		{
			Category = "Sports",
			Id = 18594720040,
			Name = "SportsArrowMan"
		},
		{
			Category = "Sports",
			Id = 18594445846,
			Name = "SportsTarget"
		},
		{
			Category = "Sports",
			Id = 16016812557,
			Name = "SportsBasketBallHoop"
		},
		{
			Category = "Sports",
			Id = 115687312658086,
			Name = "SportsGoal"
		},
		{
			Category = "Sports",
			Id = 139362699993642,
			Name = "Scoreboard"
		},
		{
			Category = "Sports",
			Id = 137293485591287,
			Name = "YogaMat"
		},
		{
			Category = "Sports",
			Id = 96519000177029,
			Name = "YogaMatRolled"
		},
		{
			Category = "Clothing",
			Id = 6100222503,
			Name = "ClothingCarryOn"
		},
		{
			Category = "Clothing",
			Id = 4529193474,
			Name = "ClothingBackBag"
		},
		{
			Category = "Clothing",
			Id = 16019120379,
			Name = "ClothingGirl"
		},
		{
			Category = "Clothing",
			Id = 16019120033,
			Name = "ClothingBoy"
		},
		{
			Category = "Clothing",
			Id = 115272705333087,
			Name = "ClothingRack1"
		},
		{
			Category = "Clothing",
			Id = 73929078259734,
			Name = "ClothingRack2"
		},
		{
			Category = "Clothing",
			Id = 110291780975712,
			Name = "ClothingRack3"
		},
		{
			Category = "Clothing",
			Id = 136601051132833,
			Name = "ClothingRack4"
		},
		{
			Category = "Clothing",
			Id = 77103456456336,
			Name = "CoatRack"
		},
		{
			Category = "Clothing",
			Id = 93951811120736,
			Name = "ShoeRack"
		},
		{
			Category = "Clothing",
			Id = 89977250336861,
			Name = "ClothesHamper"
		},
		{
			Category = "Clothing",
			Id = 16019120270,
			Name = "ClothingLuggageBoy"
		},
		{
			Category = "Clothing",
			Id = 16019120168,
			Name = "ClothingLuggageGirl"
		},
		{
			Category = "Clothing",
			Id = 71463050208608,
			Name = "Mannequin"
		},
		{
			Category = "Carnival",
			Item = "Summer2026SlipAndSlide",
			Name = "Summer2026SlipAndSlide"
		},
		{
			Category = "Carnival",
			Item = "Summer2026Trampoline",
			Name = "Summer2026Trampoline"
		},
		{
			Category = "Carnival",
			Item = "Summer2026TicketMachine",
			Name = "Summer2026TicketMachine"
		},
		{
			Category = "Carnival",
			Item = "Summer2026BobcatProp",
			Name = "Summer2026BobcatProp"
		},
		{
			Category = "Carnival",
			Item = "Summer2026PhotoBooth",
			Name = "Summer2026PhotoBooth"
		},
		{
			Category = "Carnival",
			Id = 106317541880884,
			PropVIP = true,
			Name = "DunkTank",
			RequirementBehaviorData = {
				Behavior = "Summer2025VIP",
				Arguments = { "DunkTank" }
			}
		},
		{
			Category = "Carnival",
			Name = "CarnivalTent",
			RequirementBehaviorData = {
				Behavior = "Summer2025Purchasables",
				Arguments = { "CarnivalTent" }
			},
			Id = 123503244379623,
			ThemeImage = "rbxassetid://125759309353396",
			PropVIP = false
		},
		{
			Category = "Carnival",
			Name = "CarnivalBooth",
			RequirementBehaviorData = {
				Behavior = "Summer2025Purchasables",
				Arguments = { "CarnivalBooth" }
			},
			Id = 107291461476616,
			ThemeImage = "rbxassetid://125759309353396",
			PropVIP = false
		},
		{
			Category = "Carnival",
			Name = "BearPlush",
			RequirementBehaviorData = {
				Behavior = "Summer2025Purchasables",
				Arguments = { "BearPlush" }
			},
			Id = 116584851102322,
			ThemeImage = "rbxassetid://125759309353396",
			PropVIP = false
		},
		{
			Category = "Carnival",
			Name = "PopcornMachine",
			RequirementBehaviorData = {
				Behavior = "Summer2025Purchasables",
				Arguments = { "PopcornMachine" }
			},
			Id = 99811303777072,
			ThemeImage = "rbxassetid://125759309353396",
			PropVIP = false
		},
		{
			Category = "Carnival",
			Name = "UnicornPlush",
			RequirementBehaviorData = {
				Behavior = "Summer2025Purchasables",
				Arguments = { "UnicornPlush" }
			},
			Id = 82154074393718,
			ThemeImage = "rbxassetid://125759309353396",
			PropVIP = false
		},
		{
			Category = "Carnival",
			Name = "CarnivalSign1",
			RequirementBehaviorData = {
				Behavior = "Summer2025Purchasables",
				Arguments = { "CarnivalSigns" }
			},
			Id = 104954346934764,
			ThemeImage = "rbxassetid://125759309353396",
			PropVIP = false
		},
		{
			Category = "Carnival",
			Name = "CarnivalSign2",
			RequirementBehaviorData = {
				Behavior = "Summer2025Purchasables",
				Arguments = { "CarnivalSigns" }
			},
			Id = 94665985693773,
			ThemeImage = "rbxassetid://125759309353396",
			PropVIP = false
		},
		{
			Category = "Carnival",
			Name = "CarnivalSign5",
			RequirementBehaviorData = {
				Behavior = "Summer2025Purchasables",
				Arguments = { "CarnivalSigns" }
			},
			Id = 121321825555520,
			ThemeImage = "rbxassetid://125759309353396",
			PropVIP = false
		},
		{
			Category = "Carnival",
			Name = "CarnivalSign3",
			RequirementBehaviorData = {
				Behavior = "Summer2025Purchasables",
				Arguments = { "CarnivalSigns" }
			},
			Id = 115237624776087,
			ThemeImage = "rbxassetid://125759309353396",
			PropVIP = false
		},
		{
			Category = "Carnival",
			Name = "CarnivalSign4",
			RequirementBehaviorData = {
				Behavior = "Summer2025Purchasables",
				Arguments = { "CarnivalSigns" }
			},
			Id = 94592789806666,
			ThemeImage = "rbxassetid://125759309353396",
			PropVIP = false
		},
		{
			Category = "Smoke",
			Id = 16019607362,
			Name = "SmokeWhite"
		},
		{
			Category = "Smoke",
			Id = 16019587130,
			Name = "SmokeGreen"
		},
		{
			Category = "Smoke",
			Id = 16019587273,
			Name = "SmokeYellow"
		},
		{
			Category = "Smoke",
			Id = 16019587439,
			Name = "SmokeBlue"
		},
		{
			Category = "Smoke",
			Id = 16019586856,
			Name = "SmokeRed"
		},
		{
			Category = "Smoke",
			Id = 16019587563,
			Name = "SmokePurple"
		},
		{
			Category = "Smoke",
			Id = 16249277953,
			Name = "SmokeWhiteWide"
		},
		{
			Category = "Girly",
			Id = 5480682123,
			Name = "GirlyBrush"
		},
		{
			Category = "Girly",
			Id = 16101444401,
			Name = "GirlyMirrorSmall"
		},
		{
			Category = "Girly",
			Id = 16101444029,
			Name = "GirlyShapeMoon"
		},
		{
			Category = "Girly",
			Id = 16101385291,
			Name = "GirlyShapeHeartPink"
		},
		{
			Category = "Girly",
			Id = 16246360907,
			Name = "GirlyShapeStar"
		},
		{
			Category = "Girly",
			Id = 71753735792068,
			Name = "EggLamp"
		},
		{
			Category = "Girly",
			Id = 108720346444795,
			Name = "LavaLamp"
		},
		{
			Category = "Girly",
			Id = 16020186274,
			Name = "GirlyMirror"
		},
		{
			Category = "Girly",
			Id = 16020186182,
			Name = "GirlyMakeupGlass"
		},
		{
			Category = "Girly",
			Id = 16020186115,
			Name = "GirlyMakeupPink"
		},
		{
			Category = "Girly",
			Id = 16248974881,
			Name = "GirlyShelf"
		},
		{
			Category = "Girly",
			Id = 18594424331,
			Name = "GirlySingleRose"
		},
		{
			Category = "Girly",
			Id = 18594503743,
			Name = "GirlyVaseRose"
		},
		{
			Category = "Girly",
			Id = 16101387651,
			Name = "GirlyCandlesWhite"
		},
		{
			Category = "Girly",
			Id = 16101205214,
			Name = "GirlyCandlesVanilla"
		},
		{
			Category = "Girly",
			Id = 16101205711,
			Name = "GirlyCandlesGreen"
		},
		{
			Category = "Girly",
			Id = 16101387466,
			Name = "GirlyCandlesRed"
		},
		{
			Category = "Girly",
			Id = 16101205508,
			Name = "GirlyCandlesPink"
		},
		{
			Category = "Girly",
			Id = 16101387360,
			Name = "GirlyCandlesPurple"
		},
		{
			Category = "Girly",
			Id = 16101541354,
			Name = "GirlyBeanBagPink"
		},
		{
			Category = "Girly",
			Id = 16101540983,
			Name = "GirlyPinkRoundRug"
		},
		{
			Category = "Girly",
			Id = 16101541126,
			Name = "GirlyPinkRoundRugPillows"
		},
		{
			Category = "Girly",
			Id = 16020305388,
			Name = "GirlyLightsWhite"
		},
		{
			Category = "Girly",
			Id = 16020305559,
			Name = "GirlyLightsPurple"
		},
		{
			Category = "Girly",
			Id = 16020315605,
			Name = "GirlyLightsPink"
		},
		{
			Category = "Girly",
			Id = 16020305729,
			Name = "GirlyLightsRoundWhite"
		},
		{
			Category = "Girly",
			Id = 16020305867,
			Name = "GirlyLightsRoundPurple"
		},
		{
			Category = "Girly",
			Id = 16020306021,
			Name = "GirlyLightsRoundPink"
		},
		{
			Category = "Girly",
			Id = 84557279747301,
			Name = "BuntingBanner"
		},
		{
			Category = "Girly",
			Id = 90270788127835,
			Name = "HotScoth"
		},
		{
			Category = "Big",
			Id = 16010118931,
			Name = "BigKidsRedBlue"
		},
		{
			Category = "Big",
			Id = 16010119430,
			Name = "BigOldCabin"
		},
		{
			Category = "Big",
			Id = 16010119274,
			Name = "BigPinkTent"
		},
		{
			Category = "Big",
			Id = 16010118525,
			Name = "BigTeePee"
		},
		{
			Category = "Big",
			Id = 16010118599,
			Name = "BigHomeless"
		},
		{
			Category = "Big",
			Name = "CardboardTent",
			Item = "CardboardTent"
		},
		{
			Category = "Big",
			Id = 16010119125,
			Name = "BigCampingTent"
		},
		{
			Category = "Big",
			Id = 16101444646,
			Name = "BigMedicalTent"
		},
		{
			Category = "Big",
			Id = 16101445400,
			Name = "BigCage"
		},
		{
			Category = "Big",
			Id = 16249029446,
			Name = "BigHorseFence"
		},
		{
			Category = "Big",
			Id = 16101205877,
			Name = "BigGunBunker"
		},
		{
			Category = "Big",
			Id = 16010118439,
			Name = "BigMilitaryTent"
		},
		{
			Category = "Big",
			Id = 16010118789,
			Name = "BigWhiteCanopee"
		},
		{
			Category = "Big",
			Id = 16010119018,
			Name = "BigUmbrella"
		},
		{
			Category = "Big",
			Id = 16010118336,
			Name = "BigOutToilet"
		},
		{
			Category = "Big",
			Id = 18594473709,
			Name = "BigTelephoneBooth"
		},
		{
			Category = "Big",
			Id = 73760786122120,
			Name = "BigVotingBooth"
		},
		{
			Category = "Big",
			Name = "ToriiGate",
			Item = "ToriiGate"
		},
		{
			Category = "Baby",
			Id = 5528668898,
			Name = "BabyMilkBottle"
		},
		{
			Category = "Baby",
			Id = 18596458978,
			Name = "BabyBoyWhite"
		},
		{
			Category = "Baby",
			Id = 18596464139,
			Name = "BabyGirlWhite"
		},
		{
			Category = "Baby",
			Id = 18596469044,
			Name = "BabyBoyBrown"
		},
		{
			Category = "Baby",
			Id = 18596466781,
			Name = "BabyGirlBrown"
		},
		{
			Category = "Baby",
			Id = 5528668413,
			Name = "BabyMonkey"
		},
		{
			Category = "Baby",
			Id = 5528669302,
			Name = "BabyHippo"
		},
		{
			Category = "Baby",
			Id = 114284773858113,
			Name = "BoyPlayTable",
			PropVIP = true
		},
		{
			Category = "Baby",
			Id = 86484899593280,
			Name = "GirlPlayTable",
			PropVIP = true
		},
		{
			Category = "Baby",
			Id = 119700521245685,
			Name = "BoyPlayRug"
		},
		{
			Category = "Baby",
			Id = 111404813615969,
			Name = "GirlPlayRug"
		},
		{
			Category = "Baby",
			Id = 119036886950226,
			Name = "PlayTunnelGirl"
		},
		{
			Category = "Baby",
			Id = 119894162170731,
			Name = "PlayTunnelBoy"
		},
		{
			Category = "Baby",
			Id = 84153415605888,
			Name = "PlayTunnelNeutral"
		},
		{
			Category = "Baby",
			Id = 96798262620700,
			Name = "BabyRattle"
		},
		{
			Category = "Baby",
			Id = 16017012321,
			Name = "BabyGirlCarSeat"
		},
		{
			Category = "Baby",
			Id = 16017012176,
			Name = "BabyBoyCarSeat"
		},
		{
			Category = "Baby",
			Id = 16896458517,
			Name = "BabyPoddyBoy"
		},
		{
			Category = "Baby",
			Id = 16896461926,
			Name = "BabyPoddyGirl"
		},
		{
			Category = "Baby",
			Id = 16017011740,
			Name = "BabyHighChair"
		},
		{
			Category = "Baby",
			Id = 16017011605,
			Name = "BabyDresser"
		},
		{
			Category = "Baby",
			Id = 16017011887,
			Name = "BabyBlanket"
		},
		{
			Category = "Baby",
			Id = 97431876012987,
			Name = "BabyCrib"
		},
		{
			Category = "Baby",
			Id = 6607753154,
			Name = "BabyRedCart"
		},
		{
			Category = "Baby",
			Id = 71578527601743,
			Name = "BabyStroller"
		},
		{
			Category = "Baby",
			Id = 116427179573250,
			Name = "BabyWalker"
		},
		{
			Category = "Baby",
			Id = 16017011455,
			Name = "BabyPlayPinBlue"
		},
		{
			Category = "Baby",
			Id = 16017012055,
			Name = "BabyPlayPinPink"
		},
		{
			Category = "Baby",
			Id = 114882329095432,
			Name = "ToyBlocks1"
		},
		{
			Category = "Baby",
			Id = 113254887236864,
			Name = "ToyBlocks2"
		},
		{
			Category = "Baby",
			Id = 85192027571298,
			Name = "ToyBlocks5"
		},
		{
			Category = "Baby",
			Id = 99169635798159,
			Name = "ToyBlocks3"
		},
		{
			Category = "Baby",
			Id = 96433526650879,
			Name = "ToyBlocks4"
		},
		{
			Category = "Halloween",
			Id = 16103812132,
			Name = "HalloweenPumkin5"
		},
		{
			Category = "Halloween",
			Id = 16103754922,
			Name = "HalloweenPumkin2"
		},
		{
			Category = "Halloween",
			Id = 16103755195,
			Name = "HalloweenPumkin3"
		},
		{
			Category = "Halloween",
			Id = 16103754629,
			Name = "HalloweenPumkin4"
		},
		{
			Category = "Halloween",
			Id = 16103832370,
			Name = "HalloweenSpider"
		},
		{
			Category = "Halloween",
			Id = 16103832279,
			Name = "HalloweenSpiderSideways"
		},
		{
			Category = "Halloween",
			Id = 16103832145,
			Name = "HalloweenSpiderHanging"
		},
		{
			Category = "Wicked",
			Id = 139267159933567,
			Name = "EmeraldCityLight",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 110813557555659,
			Name = "EmeraldCityBooth",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 84972426655079,
			Name = "OzianBeamLight",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 95214179693933,
			Name = "GlindaCouch",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 108861235337079,
			Name = "GlindaVanity",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 83488688360533,
			Name = "BroomSwing",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 72315986673927,
			Name = "ElphabaCouch",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 86066741758628,
			Name = "ElphabaVanity",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 76143988189235,
			Name = "GreenBottle",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 131409460367424,
			Name = "OzianPodium",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 74559884265370,
			Name = "OzianGramophone",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 108042402796095,
			Name = "VintageCamera",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 135590897505043,
			Name = "WritingTablet",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 105131245888317,
			Name = "Grimmerie",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 93690339987486,
			Name = "PropagandaPoster_Glinda",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Wicked",
			Id = 78222489565507,
			Name = "PropagandaPoster_Elphaba",
			ThemeImage = "rbxassetid://77726165481399"
		},
		{
			Category = "Minions",
			Id = 75910805847209,
			Name = "DirectorChairMinions",
			ThemeImage = "rbxassetid://83709397299167"
		},
		{
			Category = "Minions",
			Id = 137099227690140,
			Name = "WantedPoster",
			ThemeImage = "rbxassetid://83709397299167"
		},
		{
			Category = "Minions",
			Id = 90692715020704,
			Name = "DynamiteKit",
			ThemeImage = "rbxassetid://83709397299167"
		},
		{
			Category = "Minions",
			Id = 89732140615240,
			Name = "MinionsSpotlight",
			ThemeImage = "rbxassetid://83709397299167"
		},
		{
			Category = "Minions",
			Id = 92039026687890,
			Name = "SwingingSaloonDoors",
			ThemeImage = "rbxassetid://83709397299167"
		},
		{
			Category = "Jurassic",
			Id = 113170114414212,
			Name = "JurassicPoster",
			ThemeImage = "rbxassetid://127781741642328"
		},
		{
			Category = "Jurassic",
			Id = 70590506690884,
			Name = "JurassicGate",
			ThemeImage = "rbxassetid://127781741642328"
		},
		{
			Category = "Jurassic",
			Id = 82173222647445,
			Name = "JurassicElectricFence1",
			ThemeImage = "rbxassetid://127781741642328"
		},
		{
			Category = "Jurassic",
			Id = 78647558763981,
			Name = "JurassicElectricFence2",
			ThemeImage = "rbxassetid://127781741642328"
		},
		{
			Category = "Jurassic",
			Id = 77843075492904,
			Name = "JurassicElectricFence3",
			ThemeImage = "rbxassetid://127781741642328"
		},
		{
			Category = "Halloween",
			Id = 113675744495521,
			Name = "CandyBucketProp"
		},
		{
			Category = "Halloween",
			Name = "CandyBasketProp",
			Item = "Halloween2025CandyBasketProp"
		},
		{
			Category = "Halloween",
			Name = "SkeletonJumpscare",
			Item = "Halloween2025SkeletonJumpscare"
		},
		{
			Category = "Halloween",
			Name = "PumpkinJumpscare",
			Item = "Halloween2025PumpkinJumpscare"
		},
		{
			Category = "Halloween",
			Id = 83613753172219,
			Name = "HangingCage"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 136987717409923,
			Name = "SpraypaintBox"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 89481402639532,
			Name = "ToolsPaintBuckets"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 77809860179231,
			Name = "GraffitiLove"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 110660208920152,
			Name = "GraffitiRoblox"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 94689936073095,
			Name = "GraffitiAgency",
			PropVIP = true
		},
		{
			Category = "ArtsAndCrafts",
			Id = 124272724078872,
			Name = "GraffitiBrookhaven"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 109564336018704,
			Name = "BrickWallLarge"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 88180181733042,
			Name = "BrickWallSmall"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 92092174219027,
			Name = "BrickWallTall"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 100096786593466,
			Name = "BrickWallWide"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 99162498751550,
			Name = "PaintSingleBucket"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 121182572540733,
			Name = "PaintEmptyBuckets"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 129588170354500,
			Name = "EmptyPaintBucket"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 90262630479646,
			Name = "Paint3Buckets"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 95365196038685,
			Name = "PaintSplatter1"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 87760119116431,
			Name = "PaintSplatter2"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 76794859790471,
			Name = "PaintSplatter3"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 102137644017975,
			Name = "PaintSplatter4"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 133445663640072,
			Name = "Sketchbooks1"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 119476113266022,
			Name = "Sketchbooks2"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 76307306923612,
			Name = "Sketchbooks3"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 103305115118963,
			Name = "Sketchbooks4"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 91511356379450,
			Name = "PaintRollerTray"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 92669236231771,
			Name = "PaintingSupplies"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 116643572188742,
			Name = "Canvas1"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 107282440981834,
			Name = "Canvas2"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 108055476586612,
			Name = "Canvas3"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 85839653177836,
			Name = "Canvas4"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 138398486799866,
			Name = "PaintingBrookhaven"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 80233849182875,
			Name = "PaintingTown1"
		},
		{
			Category = "ArtsAndCrafts",
			Id = 136648636292785,
			Name = "PaintingTown2"
		},
		{
			Category = "WoodWall",
			Id = 16101574202,
			Name = "WoodWall4"
		},
		{
			Category = "WoodWall",
			Id = 16101574331,
			Name = "WoodWall3"
		},
		{
			Category = "WoodWall",
			Id = 16101574450,
			Name = "WoodWall1"
		},
		{
			Category = "WoodWall",
			Id = 16101574613,
			Name = "WoodWall2"
		},
		{
			Category = "WoodWall",
			Id = 16896563071,
			Name = "WoodRome"
		},
		{
			Category = "WoodWall",
			Id = 16246089629,
			Name = "WoodOrangePipes"
		},
		{
			Category = "WoodWall",
			Id = 16248925774,
			Name = "WoodLogs"
		},
		{
			Category = "WoodWall",
			Id = 16246316332,
			Name = "Wood2x4"
		},
		{
			Category = "WoodWall",
			Id = 16246270216,
			Name = "WoodSheetrock"
		},
		{
			Category = "WoodWall",
			Id = 16248835515,
			Name = "WoodLongBoxes"
		},
		{
			Category = "WoodWall",
			Id = 16246091525,
			Name = "WoodBrick"
		},
		{
			Category = "WoodWall",
			Id = 16246024874,
			Name = "WoodBunchSmallBoxes"
		},
		{
			Category = "WoodWall",
			Id = 16249027554,
			Name = "WoodBigBox"
		},
		{
			Category = "WoodWall",
			Id = 16248975286,
			Name = "WoodArmyBoxes"
		},
		{
			Category = "Present",
			Id = 6239256158,
			Name = "PresentSingleBalloon"
		},
		{
			Category = "Present",
			Id = 15999793769,
			Name = "PresentPinkBalloon"
		},
		{
			Category = "Present",
			Id = 15999793339,
			Name = "PresentRedBalloon"
		},
		{
			Category = "Present",
			Id = 15999794043,
			Name = "PresentPastelBalloon"
		},
		{
			Category = "Present",
			Id = 15999793576,
			Name = "PresentOrangeBalloon"
		},
		{
			Category = "Present",
			Id = 15999792903,
			Name = "PresentBirthdayBalloon"
		},
		{
			Category = "Present",
			Id = 15999793099,
			Name = "PresentChristmasBalloon"
		},
		{
			Category = "Present",
			Id = 16896535869,
			Name = "PresentRobloxBalloons"
		},
		{
			Category = "Present",
			Id = 15999794846,
			Name = "PresentBlue"
		},
		{
			Category = "Present",
			Id = 15999794637,
			Name = "PresentPink"
		},
		{
			Category = "Present",
			Id = 15999795197,
			Name = "Present4Boxes"
		},
		{
			Category = "Present",
			Id = 15999795031,
			Name = "Present3Boxes"
		},
		{
			Category = "Present",
			Id = 15999794251,
			Name = "PresentBigRedWhite"
		},
		{
			Category = "Present",
			Id = 15999794416,
			Name = "PresentBigGreenWhite"
		},
		{
			Category = "Christmas",
			Id = 16018992979,
			Name = "ChristmasBag"
		},
		{
			Category = "Christmas",
			Id = 16018992828,
			Name = "ChristmasWhiteTree"
		},
		{
			Category = "Christmas",
			Id = 16897607867,
			Name = "ChristmasGreenTree"
		},
		{
			Category = "Christmas",
			Id = 16018992517,
			Name = "ChristmasSnowman"
		},
		{
			Category = "Christmas",
			Id = 16018992657,
			Name = "ChristmasCandles"
		},
		{
			Category = "Christmas",
			Id = 16101444548,
			Name = "ChristmasSantaPlate"
		},
		{
			Category = "Christmas",
			Id = 15999793099,
			Name = "PresentChristmasBalloon"
		},
		{
			Category = "Christmas",
			Id = 15999795197,
			Name = "Present4Boxes"
		},
		{
			Category = "Christmas",
			Id = 85753660605997,
			Name = "ChristmasLights"
		},
		{
			Category = "Christmas",
			Id = 97204214092127,
			Name = "GiftTable",
			Item = "GiftTable"
		},
		{
			Category = "Christmas",
			Id = 109164315893275,
			Name = "Snowman1",
			Item = "Snowman1"
		},
		{
			Category = "Christmas",
			Id = 92580562535830,
			Name = "Snowman2",
			Item = "Snowman2"
		},
		{
			Category = "Christmas",
			Id = 83111861800268,
			Name = "Snowman3",
			Item = "Snowman3"
		},
		{
			Category = "Christmas",
			Id = 83755713880693,
			Name = "ChristmasStall",
			Item = "ChristmasStall"
		},
		{
			Category = "Christmas",
			Id = 109150993680766,
			Name = "RockingHorse",
			Item = "RockingHorse"
		},
		{
			Category = "Christmas",
			Id = 100623509700259,
			Name = "GingerbreadHouse",
			Item = "GingerbreadHouse"
		},
		{
			Category = "SmallVehicles",
			Id = 82128402478304,
			Name = "SmallVehiclesSkateBoard"
		},
		{
			Category = "SmallVehicles",
			Id = 135699743531883,
			Name = "SmallVehiclesScooter"
		},
		{
			Category = "SmallVehicles",
			Id = 137466141639612,
			Name = "SmallVehiclesSegway"
		},
		{
			Category = "SmallVehicles",
			Id = 94959958905511,
			Name = "SmallVehiclesWheelChair"
		},
		{
			Category = "SmallVehicles",
			Id = 95866941387362,
			Name = "SmallVehiclesBoysBike"
		},
		{
			Category = "SmallVehicles",
			Id = 110468713519947,
			Name = "SmallVehiclesGirlsBike"
		},
		{
			Category = "SmallVehicles",
			Id = 105177106808063,
			Name = "SmallVehiclesBikeRack"
		},
		{
			Category = "Case",
			Id = 14240155516,
			Name = "CaseTicket"
		},
		{
			Category = "Case",
			Id = 4551084336,
			Name = "CaseClipBoard"
		},
		{
			Category = "Case",
			Id = 14240155098,
			Name = "CaseEnvelope"
		},
		{
			Category = "Case",
			Id = 16246316668,
			Name = "CaseBookRed"
		},
		{
			Category = "Case",
			Id = 16246315590,
			Name = "CaseBookBlack"
		},
		{
			Category = "Case",
			Id = 16101542129,
			Name = "CasePapers"
		},
		{
			Category = "Case",
			Id = 16101386034,
			Name = "CaseFolder"
		},
		{
			Category = "Case",
			Id = 16101206570,
			Name = "CaseBrownBriefcase"
		},
		{
			Category = "Case",
			Id = 16101206745,
			Name = "CaseBlackBriefcase"
		},
		{
			Category = "Case",
			Id = 16101206062,
			Name = "CaseOpenBrownBriefcase"
		},
		{
			Category = "Case",
			Id = 16101206225,
			Name = "CaseBlackBriefcaseFolder"
		},
		{
			Category = "Case",
			Id = 16101206375,
			Name = "CaseMoneyBackBriefcase"
		},
		{
			Category = "Case",
			Id = 16246023752,
			Name = "CaseOpenBrownBriefcaseGold"
		},
		{
			Category = "Case",
			Id = 16101574718,
			Name = "CaseSmallNukeBomb"
		},
		{
			Category = "Case",
			Id = 126106064897313,
			Name = "TreasureChestOpened"
		},
		{
			Category = "Lights",
			Id = 16017787152,
			Name = "LightsSpotLightWhite"
		},
		{
			Category = "Lights",
			Id = 16017786994,
			Name = "LightsSpotLightGreen"
		},
		{
			Category = "Lights",
			Id = 16017787448,
			Name = "LightsSpotLightPink"
		},
		{
			Category = "Lights",
			Id = 16017787752,
			Name = "LightsSpotLightRed"
		},
		{
			Category = "Lights",
			Id = 16017787607,
			Name = "LightsSpotLightToothpaste"
		},
		{
			Category = "Lights",
			Id = 18594443338,
			Name = "LightsDeskLamp"
		},
		{
			Category = "Lights",
			Id = 16017786122,
			Name = "LightsYellowLamp"
		},
		{
			Category = "Lights",
			Id = 90329909966990,
			Name = "TubeLamp"
		},
		{
			Category = "Lights",
			Id = 16017786844,
			Name = "LightsBlackModern"
		},
		{
			Category = "Lights",
			Id = 72126893288036,
			Name = "LightsStandingLamp"
		},
		{
			Category = "Lights",
			Id = 16017786386,
			Name = "LightsBlinkingColor"
		},
		{
			Category = "Lights",
			Id = 16017852861,
			Name = "LightsTallGrey"
		},
		{
			Category = "Lights",
			Id = 16246316207,
			Name = "LightsDouble"
		},
		{
			Category = "Lights",
			Id = 87223641218000,
			Name = "LightArch"
		},
		{
			Category = "Lights",
			Id = 101374492486594,
			Name = "FlashingLightArch",
			PropVIP = true
		},
		{
			Category = "Lights",
			Id = 136159078380738,
			Name = "RingLight"
		},
		{
			Category = "Lights",
			Id = 70923421811401,
			Name = "UmbrellaLight"
		},
		{
			Category = "Lights",
			Id = 121166458028987,
			Name = "BeaconLight"
		},
		{
			Category = "Lights",
			Id = 97904618555086,
			Name = "SoccerLights"
		},
		{
			Category = "Lights",
			Id = 98974659490539,
			Name = "Spotlight"
		},
		{
			Category = "Lights",
			Id = 90669542727101,
			Name = "RotatingLight"
		},
		{
			Category = "Lights",
			Item = "Easter2026StringLights",
			Name = "EasterStringLights"
		},
		{
			Category = "Lights",
			Id = 110114783288460,
			Name = "Chandelier2"
		},
		{
			Category = "Sign",
			Id = 16246270728,
			Name = "SignMedWallBlack"
		},
		{
			Category = "Sign",
			Id = 16248834705,
			Name = "SignMedWallWhite"
		},
		{
			Category = "Sign",
			Id = 16249029555,
			Name = "SignLongBlack"
		},
		{
			Category = "Sign",
			Id = 16248834922,
			Name = "SignLongWhite"
		},
		{
			Category = "Sign",
			Id = 16248925383,
			Name = "SignWoodBlack"
		},
		{
			Category = "Sign",
			Id = 16248924547,
			Name = "SignWoodWhite"
		},
		{
			Category = "Sign",
			Id = 15998307297,
			Name = "SignBlackSmall"
		},
		{
			Category = "Sign",
			Id = 15998308852,
			Name = "SignBlackBig"
		},
		{
			Category = "Sign",
			Id = 15998309053,
			Name = "SignWhiteBig"
		},
		{
			Category = "Sign",
			Id = 16246315821,
			Name = "SignWetFloor"
		},
		{
			Category = "Sign",
			Name = "CardboardSign",
			Item = "CardboardSign"
		},
		{
			Category = "Sign",
			Id = 15998307506,
			Name = "SignOpenClose"
		},
		{
			Category = "Sign",
			Id = 16101385174,
			Name = "SignSweetHome"
		},
		{
			Category = "Sign",
			Id = 15998308537,
			Name = "SignHandy"
		},
		{
			Category = "Sign",
			Id = 15998309290,
			Name = "SignDangerZone"
		},
		{
			Category = "Sign",
			Id = 15998307944,
			Name = "SignNoParking"
		},
		{
			Category = "Sign",
			Id = 16101385571,
			Name = "SignNoBoys"
		},
		{
			Category = "Sign",
			Id = 16101542358,
			Name = "SignNoGirls"
		},
		{
			Category = "Sign",
			Id = 16101575984,
			Name = "SignKeepOut"
		},
		{
			Category = "Sign",
			Id = 16101575019,
			Name = "SignBiohazard"
		},
		{
			Category = "Sign",
			Id = 16101574859,
			Name = "SignRadiation"
		},
		{
			Category = "Sign",
			Id = 16101575448,
			Name = "SignCamera"
		},
		{
			Category = "Sign",
			Id = 16101575789,
			Name = "SignPoison"
		},
		{
			Category = "Sign",
			Id = 16101575261,
			Name = "SignMask"
		},
		{
			Category = "Sign",
			Id = 16101575605,
			Name = "SignCrazyPeople"
		},
		{
			Category = "Sign",
			Id = 16249091282,
			Name = "SignPlayerPictureSmall"
		},
		{
			Category = "Sign",
			Id = 16101576135,
			Name = "SignPlayerPicture"
		},
		{
			Category = "Sign",
			Id = 15998309196,
			Name = "SignOpenPlace"
		},
		{
			Category = "Sign",
			Id = 16246316504,
			Name = "SignSuperSaleStanding"
		},
		{
			Category = "Sign",
			Id = 16246024095,
			Name = "SignSuperSaleWall"
		},
		{
			Category = "Sign",
			Id = 16246133876,
			Name = "Sign50OffStand"
		},
		{
			Category = "Sign",
			Id = 16248835134,
			Name = "Sign50OffWall"
		},
		{
			Category = "Sign",
			Id = 15998308111,
			Name = "SignForSale"
		},
		{
			Category = "Sign",
			Id = 15998308238,
			Name = "SignForRent"
		},
		{
			Category = "Sign",
			Id = 15998308683,
			Name = "SignOpen"
		},
		{
			Category = "Sign",
			Id = 15998308373,
			Name = "SignClosed"
		},
		{
			Category = "Sign",
			Id = 15998307795,
			Name = "SignAgencySmall"
		},
		{
			Category = "Sign",
			Id = 15998307644,
			Name = "SignAgencyBig"
		},
		{
			Category = "Sign",
			Id = 70564895195365,
			Name = "SignFuturistic1"
		},
		{
			Category = "Sign",
			Id = 118996634846947,
			Name = "SignFuturistic2"
		},
		{
			Category = "Sign",
			Id = 130936678412450,
			Name = "SignAccessGranted"
		},
		{
			Category = "Sign",
			Id = 100594379454904,
			Name = "SignTapeMarksWhite"
		},
		{
			Category = "Sign",
			Id = 88150394111985,
			Name = "SignTapeMarksBlack"
		},
		{
			Category = "Plant",
			Id = 16018387079,
			Name = "PlantOutsideTreeGreenSmall"
		},
		{
			Category = "Plant",
			Id = 16018387210,
			Name = "PlantOutsideTreeGreenBig"
		},
		{
			Category = "Plant",
			Id = 16018386967,
			Name = "PlantOutsideTreeMedium"
		},
		{
			Category = "Plant",
			Id = 16018386472,
			Name = "PlantOutsideBushSmall"
		},
		{
			Category = "Plant",
			Id = 16018386634,
			Name = "PlantOutsideBushBig"
		},
		{
			Category = "Plant",
			Id = 16102581847,
			Name = "PlantSprinkler"
		},
		{
			Category = "Plant",
			Id = 5480684131,
			Name = "PlantWateringCan"
		},
		{
			Category = "Plant",
			Id = 4617189290,
			Name = "PlantBucket"
		},
		{
			Category = "Plant",
			Id = 5480682683,
			Name = "PlantLawnMower"
		},
		{
			Category = "Plant",
			Id = 16101386284,
			Name = "PlantFlowerWhite"
		},
		{
			Category = "Plant",
			Id = 16101386462,
			Name = "PlantFlowerPink"
		},
		{
			Category = "Plant",
			Id = 16101386814,
			Name = "PlantFlowerRed"
		},
		{
			Category = "Plant",
			Id = 16101386631,
			Name = "PlantFlowerPurple"
		},
		{
			Category = "Plant",
			Id = 16018386773,
			Name = "PlantGlassFlowersRed"
		},
		{
			Category = "Plant",
			Name = "FlowerArrangement",
			Item = "FlowerArrangement"
		},
		{
			Category = "Plant",
			Id = 83001906697373,
			Name = "PlantSmall1"
		},
		{
			Category = "Plant",
			Id = 121165175412104,
			Name = "PlantSmall2"
		},
		{
			Category = "Plant",
			Id = 92320005404599,
			Name = "PlantSmall3"
		},
		{
			Category = "Plant",
			Id = 83660962361536,
			Name = "PlantMed1"
		},
		{
			Category = "Plant",
			Id = 140447785480727,
			Name = "PlantMed2"
		},
		{
			Category = "Plant",
			Id = 84608840954226,
			Name = "PlantMed3"
		},
		{
			Category = "Plant",
			Id = 122717724431902,
			Name = "PlantMed4"
		},
		{
			Category = "Plant",
			Id = 91115213350587,
			Name = "PlantMed5"
		},
		{
			Category = "Plant",
			Id = 116451610167520,
			Name = "PlantMed6"
		},
		{
			Category = "Plant",
			Id = 127036620219883,
			Name = "PlantMed7"
		},
		{
			Category = "Plant",
			Id = 71991569089178,
			Name = "PlantLanky"
		},
		{
			Category = "Plant",
			Name = "BonsaiTreeSmallGreen",
			Item = "BonsaiTreeSmallGreen"
		},
		{
			Category = "Plant",
			Name = "BonsaiTreeSmallPink",
			Item = "BonsaiTreeSmallPink"
		},
		{
			Category = "Plant",
			Name = "BonsaiTreeLargeGreen",
			Item = "BonsaiTreeLargeGreen"
		},
		{
			Category = "Plant",
			Name = "BonsaiTreeLargePink",
			Item = "BonsaiTreeLargePink"
		},
		{
			Category = "Plant",
			Name = "BambooPlant",
			Item = "BambooPlant"
		},
		{
			Category = "Plant",
			Id = 76480941980136,
			Name = "CeramicVaseFlower"
		},
		{
			Category = "Plant",
			Id = 119462996697882,
			Name = "CeramicVaseLeaf"
		},
		{
			Category = "Plant",
			Id = 107056813176368,
			Name = "CeramicVaseShrub"
		},
		{
			Category = "Plant",
			Id = 132010922775208,
			Name = "HangingShrub"
		},
		{
			Category = "Plant",
			Id = 16018387418,
			Name = "PlantOutsideSmallBrown"
		},
		{
			Category = "Plant",
			Id = 16246020351,
			Name = "PlantDirtSmall"
		},
		{
			Category = "Plant",
			Id = 16246361411,
			Name = "PlantDirtBig"
		},
		{
			Category = "Plant",
			Id = 16246269937,
			Name = "PlantRockSmall"
		},
		{
			Category = "Plant",
			Id = 16246089174,
			Name = "PlantRockBig"
		},
		{
			Category = "Plant",
			Id = 16018386088,
			Name = "PlantPumkinSmall"
		},
		{
			Category = "Plant",
			Id = 16018386088,
			Name = "PlantPumkinBig"
		},
		{
			Category = "Plant",
			Id = 13463190567,
			Name = "PlantBoxCorn"
		},
		{
			Category = "Plant",
			Id = 16246020734,
			Name = "PlantCornShort"
		},
		{
			Category = "Plant",
			Id = 16246089410,
			Name = "PlantCornLong"
		},
		{
			Category = "Plant",
			Id = 16248925518,
			Name = "PlantCornBox"
		},
		{
			Category = "Plant",
			Id = 16249028270,
			Name = "PlantPumkinBox"
		},
		{
			Category = "Plant",
			Name = "Easter2026FlowerPlanterBox",
			Item = "Easter2026FlowerPlanterBox"
		},
		{
			Category = "Plant",
			Name = "Easter2026Vase",
			Item = "Easter2026Vase"
		},
		{
			Category = "Plant",
			Id = 131572677926937,
			Name = "FeedTrough"
		},
		{
			Category = "Plant",
			Id = 110522352682264,
			Name = "ScarecrowBoy"
		},
		{
			Category = "Plant",
			Id = 119901548328375,
			Name = "ScarecrowGirl"
		},
		{
			Category = "Plant",
			Id = 82987342065924,
			Name = "GardenGnomeBoy"
		},
		{
			Category = "Plant",
			Id = 101666203084731,
			Name = "GardenGnomeGirl"
		},
		{
			Category = "Plant",
			Id = 138925897574919,
			Name = "Weathervane"
		},
		{
			Category = "Plant",
			Item = "Easter2026FlowerHedge",
			Name = "FlowerHedge"
		},
		{
			Category = "Plant",
			Item = "Easter2026ChickHedge",
			Name = "Chick Hedge"
		},
		{
			Category = "Plant",
			Item = "Easter2026BunnyHedge",
			Name = "Bunny Hedge"
		},
		{
			Category = "Plant",
			Item = "Easter2026CarrotPatch",
			Name = "CarrotPatch"
		},
		{
			Category = "Plant",
			Id = 92691338053051,
			Name = "PottedTree"
		},
		{
			Category = "Shape",
			Id = 15998827491,
			Name = "ShapeStarWhite"
		},
		{
			Category = "Shape",
			Id = 15998827627,
			Name = "ShapeStarToothpaste"
		},
		{
			Category = "Shape",
			Id = 15998827850,
			Name = "ShapeStarYellow"
		},
		{
			Category = "Shape",
			Id = 15998827185,
			Name = "ShapeHeartRed"
		},
		{
			Category = "Shape",
			Id = 15998827358,
			Name = "ShapeHeartPink"
		},
		{
			Category = "Shape",
			Id = 16101443648,
			Name = "ShapeMoonWhite"
		},
		{
			Category = "Shape",
			Id = 16101443868,
			Name = "ShapeMoonYellow"
		},
		{
			Category = "Shape",
			Id = 15998828272,
			Name = "ShapeArrowBlackLeft"
		},
		{
			Category = "Shape",
			Id = 15998828487,
			Name = "ShapeArrowBlackRight"
		},
		{
			Category = "Shape",
			Id = 15998828054,
			Name = "ShapeArrowWhiteLeft"
		},
		{
			Category = "Shape",
			Id = 15998828625,
			Name = "ShapeArrowWhiteRight"
		},
		{
			Category = "Shape",
			Id = 116030516425073,
			Name = "ShapeCarRaceStraight"
		},
		{
			Category = "Shape",
			Id = 104462299965454,
			Name = "ShapeCarRaceRight"
		},
		{
			Category = "Shape",
			Id = 109611040538939,
			Name = "ShapeCarRaceLeft"
		},
		{
			Category = "Money",
			Id = 16101444225,
			Name = "MoneyGround"
		},
		{
			Category = "Money",
			Id = 75670843162039,
			Name = "MoneyBag"
		},
		{
			Category = "Money",
			Id = 16016114686,
			Name = "MoneyCashOne"
		},
		{
			Category = "Money",
			Id = 16016114900,
			Name = "MoneyCashThree"
		},
		{
			Category = "Money",
			Id = 16016114204,
			Name = "MoneyGoldOne"
		},
		{
			Category = "Money",
			Id = 16016114517,
			Name = "MoneyGoldThree"
		},
		{
			Category = "Money",
			Id = 16016114374,
			Name = "MoneySafe"
		},
		{
			Category = "Money",
			Id = 16016114012,
			Name = "MoneyATM"
		},
		{
			Category = "Money",
			Name = "TinCan",
			Item = "TinCan"
		},
		{
			Category = "Box",
			Id = 16101207785,
			Name = "BoxOne"
		},
		{
			Category = "Box",
			Id = 16101207194,
			Name = "BoxShortStraight"
		},
		{
			Category = "Box",
			Id = 16101207070,
			Name = "BoxHalfWall"
		},
		{
			Category = "Box",
			Id = 16101206930,
			Name = "BoxRandomSmall"
		},
		{
			Category = "Box",
			Id = 16101207613,
			Name = "BoxRandomBig"
		},
		{
			Category = "Box",
			Id = 16101207396,
			Name = "BoxBigWall"
		},
		{
			Category = "Box",
			Id = 18594527889,
			Name = "BoxCostco"
		},
		{
			Category = "Box",
			Id = 136970027943581,
			Name = "BoxLockers"
		},
		{
			Category = "Box",
			Id = 118863421611869,
			Name = "BoxSmallBasket"
		},
		{
			Category = "Box",
			Id = 86430674889609,
			Name = "BoxModernCreate"
		},
		{
			Category = "Box",
			Id = 88674535390551,
			Name = "BoxModernCreateBig"
		},
		{
			Category = "Box",
			Id = 138948830489711,
			Name = "BoxStorageSmall4Shelf"
		},
		{
			Category = "Box",
			Id = 106303819226897,
			Name = "BoxStorageMed3Shelf"
		},
		{
			Category = "Box",
			Id = 89140546010932,
			Name = "BoxStorageMed3Shelf1"
		},
		{
			Category = "Box",
			Id = 71180692289913,
			Name = "BoxCabinet"
		},
		{
			Category = "Box",
			Id = 116477477777968,
			Name = "BoxStorageLarge3Shelf"
		},
		{
			Category = "Box",
			Id = 101918963236250,
			Name = "BoxWorkstation"
		},
		{
			Category = "Box",
			Id = 81347318960430,
			Name = "BoxConveyor"
		},
		{
			Category = "Box",
			Id = 100014542910339,
			Name = "BoxWorkstationLarge"
		},
		{
			Category = "Award",
			Id = 16276542347,
			Name = "AwardTrophy"
		},
		{
			Category = "Award",
			Id = 16246133402,
			Name = "AwardYoutubeSilver"
		},
		{
			Category = "Award",
			Id = 16248835244,
			Name = "AwardYouTubeGold"
		},
		{
			Category = "Tape",
			Id = 15998676559,
			Name = "TapeDONOTCROSS"
		},
		{
			Category = "Tape",
			Id = 15998676157,
			Name = "TapeCRIMESCENE"
		},
		{
			Category = "Tape",
			Id = 15998676350,
			Name = "TapeUNDERCONSTRUCTION"
		},
		{
			Category = "Tape",
			Id = 15998675784,
			Name = "TapeCAUTION"
		},
		{
			Category = "Tape",
			Id = 15998676762,
			Name = "TapeWARNING"
		},
		{
			Category = "Tape",
			Id = 15998675941,
			Name = "TapeQUARANTINE"
		},
		{
			Category = "Car",
			Id = 18594516783,
			Name = "CarFlag"
		},
		{
			Category = "Car",
			Id = 18594509108,
			Name = "CarTruckLightsWhite"
		},
		{
			Category = "Car",
			Id = 18594452578,
			Name = "CarTruckLightsOrange",
			PropVIP = true
		},
		{
			Category = "Car",
			Id = 117927678842256,
			Name = "CarRedLights"
		},
		{
			Category = "Car",
			Id = 128708908569275,
			Name = "CarBlueLights"
		},
		{
			Category = "Car",
			Id = 136944568650317,
			Name = "CarOrangeLights"
		},
		{
			Category = "Car",
			Id = 18594534946,
			Name = "CarPoliceLights"
		},
		{
			Category = "Car",
			Id = 18594469650,
			Name = "CarScoop"
		},
		{
			Category = "Car",
			Id = 106666671984898,
			Name = "CarTruckTurbo1"
		},
		{
			Category = "Car",
			Id = 124495130456241,
			Name = "CarTruckTurbo2"
		},
		{
			Category = "Car",
			Id = 98026072013839,
			Name = "CarTruckTurbo3",
			PropVIP = true
		},
		{
			Category = "Car",
			Id = 18655320596,
			Name = "CarRaceScoope"
		},
		{
			Category = "Car",
			Id = 18655322779,
			Name = "CarRaceScoopeVIP",
			PropVIP = true
		},
		{
			Category = "Car",
			Id = 18594524599,
			Name = "CarEngineBlower",
			PropVIP = true
		},
		{
			Category = "Car",
			Id = 18594716430,
			Name = "CarStorageRack"
		},
		{
			Category = "Car",
			Id = 18594560365,
			Name = "CarBoyBikeRack"
		},
		{
			Category = "Car",
			Id = 18594521460,
			Name = "CarGirlBikeRack"
		},
		{
			Category = "Car",
			Id = 18594539038,
			Name = "CarWingHalfColor"
		},
		{
			Category = "Car",
			Id = 18594497675,
			Name = "CarWingFullColor"
		},
		{
			Category = "Car",
			Id = 18594480199,
			Name = "CarFullColorVIP",
			PropVIP = true
		},
		{
			Category = "Car",
			Id = 18594555355,
			Name = "CarWingHalfColorVIP",
			PropVIP = true
		},
		{
			Category = "Car",
			Id = 16246134533,
			Name = "CarE85"
		},
		{
			Category = "Car",
			Id = 16248925661,
			Name = "CarJack"
		},
		{
			Category = "Car",
			Id = 16248975392,
			Name = "CarJackStandRed"
		},
		{
			Category = "Car",
			Id = 16249091170,
			Name = "CarJackStandBlue"
		},
		{
			Category = "Car",
			Id = 16246133748,
			Name = "CarTiresStreet"
		},
		{
			Category = "Car",
			Id = 16246361089,
			Name = "CarTiresTruck"
		},
		{
			Category = "Car",
			Id = 16248834810,
			Name = "CarTurboStage2"
		},
		{
			Category = "Car",
			Id = 16249090915,
			Name = "CarTurboStage3"
		},
		{
			Category = "Car",
			Id = 16249028590,
			Name = "CarEngineStand"
		},
		{
			Category = "Car",
			Id = 16246021109,
			Name = "CarEngineHoist"
		},
		{
			Category = "Car",
			Id = 16248974993,
			Name = "CarCompressor"
		},
		{
			Category = "Car",
			Id = 16102581657,
			Name = "CarToolBox"
		},
		{
			Category = "Car",
			Id = 130990517531078,
			Name = "CarTruckBigToolBox"
		},
		{
			Category = "Barrel",
			Id = 16246361602,
			Name = "BarrelYellow"
		},
		{
			Category = "Barrel",
			Id = 16246316037,
			Name = "BarrelGreen"
		},
		{
			Category = "Barrel",
			Id = 16246269693,
			Name = "BarrelRed"
		},
		{
			Category = "Barrel",
			Id = 16248975086,
			Name = "BarrelBlue"
		},
		{
			Category = "Barrel",
			Id = 113715740940230,
			Name = "NuclearWasteBarrel"
		},
		{
			Category = "Barrel",
			Id = 83023611213507,
			Name = "WaterValve"
		},
		{
			Category = "Barrel",
			Id = 125437304431354,
			Name = "PlantPowerSwitch"
		},
		{
			Category = "Barrel",
			Id = 74433534250062,
			Name = "BigGenerator"
		},
		{
			Category = "Barrel",
			Id = 80501436010590,
			Name = "HazmatSuitWearable"
		},
		{
			Category = "Barrel",
			Id = 78465536927807,
			Name = "PowerTurbine"
		},
		{
			Category = "Power",
			Id = 16248975559,
			Name = "PowerBallBlue"
		},
		{
			Category = "Power",
			Id = 16248925962,
			Name = "PowerWhiteCube"
		},
		{
			Category = "Power",
			Id = 16246270975,
			Name = "PowerGoldCube"
		},
		{
			Category = "Power",
			Id = 111499618598477,
			Name = "Incubator"
		},
		{
			Category = "Power",
			Id = 87867217309505,
			Name = "PowerRockSword"
		},
		{
			Category = "Power",
			Id = 74867220406043,
			Name = "GoldPile01"
		},
		{
			Category = "Power",
			Id = 103661122000135,
			Name = "GoldPile03"
		},
		{
			Category = "Power",
			Id = 85412139654721,
			Name = "GoldPile02"
		},
		{
			Category = "Garbage",
			Id = 16246316904,
			Name = "GarbageDropsPuke"
		},
		{
			Category = "Garbage",
			Id = 16248975673,
			Name = "GarbageDropsBrown"
		},
		{
			Category = "Garbage",
			Id = 16246134272,
			Name = "GarbageDropsGreen"
		},
		{
			Category = "Garbage",
			Id = 16246091308,
			Name = "GarbageDropsWater"
		},
		{
			Category = "Garbage",
			Id = 16249350054,
			Name = "GarbageBrownSmall"
		},
		{
			Category = "Garbage",
			Id = 16249353211,
			Name = "GarbageBrownBig"
		},
		{
			Category = "Garbage",
			Id = 16102582122,
			Name = "GarbageHuge"
		},
		{
			Category = "Garbage",
			Id = 75761428440603,
			Name = "GarbageCan"
		},
		{
			Category = "Garbage",
			Name = "NewspaperCarpet",
			Item = "NewspaperCarpet"
		},
		{
			Category = "Military",
			Name = "MilitaryMap",
			Item = "MilitaryMap"
		},
		{
			Category = "Military",
			Name = "PrincessBearyWinkleTheThird",
			Item = "PrincessBearyWinkleTheThird"
		},
		{
			Category = "Military",
			Name = "ToyMissile",
			Item = "ToyMissile"
		},
		{
			Category = "Military",
			Name = "WalkyTalky",
			Item = "WalkyTalky"
		},
		{
			Category = "Military",
			Id = 15343367226,
			Name = "MilitaryAxe"
		},
		{
			Category = "Military",
			Id = 15343364442,
			Name = "MilitarySwordBrown"
		},
		{
			Category = "Military",
			Id = 15343393273,
			Name = "MilitarySwordGold"
		},
		{
			Category = "Military",
			Name = "KatanaStand",
			Item = "KatanaStand"
		},
		{
			Category = "Military",
			Id = 15343371329,
			Name = "MilitaryBow"
		},
		{
			Category = "Military",
			Id = 135738051497357,
			Name = "MilitaryHandCuffs"
		},
		{
			Category = "Military",
			Id = 6351262697,
			Name = "MilitaryBiNocks"
		},
		{
			Category = "Military",
			Id = 99378934142108,
			Name = "MilitaryStunGun"
		},
		{
			Category = "Military",
			Id = 4587924290,
			Name = "MilitaryBomb"
		},
		{
			Category = "Military",
			Id = 4529287960,
			Name = "MilitaryGlock"
		},
		{
			Category = "Military",
			Id = 4529288285,
			Name = "MilitaryGlockBrown"
		},
		{
			Category = "Military",
			Id = 4529288149,
			Name = "MilitaryShotGun"
		},
		{
			Category = "Military",
			Id = 4529288610,
			Name = "MilitaryAssultGun"
		},
		{
			Category = "Military",
			Id = 15208272302,
			Name = "MilitarySniper"
		},
		{
			Category = "Military",
			Id = 18594549800,
			Name = "MilitaryBigCarGun"
		},
		{
			Category = "Military",
			Id = 18594410533,
			Name = "MilitaryBigGun"
		},
		{
			Category = "Military",
			Id = 18594406807,
			Name = "MilitaryCarMiniGunVIP",
			PropVIP = true
		},
		{
			Category = "Military",
			Id = 18594399613,
			Name = "MilitaryMiniGunVIP",
			PropVIP = true
		},
		{
			Category = "Military",
			Id = 16016209299,
			Name = "MilitaryGunRack"
		},
		{
			Category = "Military",
			Id = 134870764962991,
			Name = "VIPGunRack",
			PropVIP = true
		},
		{
			Category = "Military",
			Id = 105928996404133,
			Name = "MetalDetector"
		},
		{
			Category = "Military",
			Id = 132358503672016,
			Name = "TargetCriminal"
		},
		{
			Category = "Military",
			Id = 80993545620070,
			Name = "TargetAgent"
		},
		{
			Category = "Military",
			Id = 133172593407325,
			Name = "TargetCivilian"
		},
		{
			Category = "Military",
			Id = 107056142629350,
			Name = "BullsEyeTarget"
		},
		{
			Category = "Military",
			Id = 134695587668376,
			Name = "MilitaryCargoBox"
		},
		{
			Category = "Military",
			Id = 103957440015871,
			Name = "MilitaryCargoBundle"
		},
		{
			Category = "Military",
			Id = 16246271178,
			Name = "MilitaryAmmoGreen"
		},
		{
			Category = "Military",
			Id = 16248975194,
			Name = "MilitaryAmmoBrown"
		},
		{
			Category = "Military",
			Id = 16019402406,
			Name = "MilitaryTelescope"
		},
		{
			Category = "Military",
			Id = 16101208129,
			Name = "MilitaryBigNukeBomb"
		},
		{
			Category = "Military",
			Id = 16016209029,
			Name = "MilitaryTurret"
		},
		{
			Category = "Military",
			Id = 114699092382464,
			Name = "MilitaryCannon"
		},
		{
			Category = "Military",
			Id = 16101576279,
			Name = "MilitarySpareRockets"
		},
		{
			Category = "Military",
			Id = 16246360310,
			Name = "MilitarySatRoof"
		},
		{
			Category = "Military",
			Id = 16016209171,
			Name = "MilitarySat"
		},
		{
			Category = "Military",
			Id = 16101208009,
			Name = "MilitaryBlackSpot"
		},
		{
			Category = "Military",
			Id = 98081643340563,
			Name = "MilitaryGroundCracks"
		},
		{
			Category = "Military",
			Id = 138134443527233,
			Name = "HelipadDecal"
		},
		{
			Category = "Music",
			Id = 16018553258,
			Name = "MusicDrums"
		},
		{
			Category = "Music",
			Id = 16018553065,
			Name = "MusicGuitar"
		},
		{
			Category = "Music",
			Id = 16018552857,
			Name = "MusicElectricGuitar"
		},
		{
			Category = "Music",
			Id = 16018552687,
			Name = "MusicPiano"
		},
		{
			Category = "Music",
			Id = 16246360700,
			Name = "ScreensDJ"
		},
		{
			Category = "Music",
			Id = 113077324050977,
			Name = "BoomboxProp"
		},
		{
			Category = "Screens",
			Id = 101867416997761,
			Name = "Phone"
		},
		{
			Category = "Screens",
			Id = 90160277045170,
			Name = "Tablet"
		},
		{
			Category = "Screens",
			Id = 129323410985415,
			Name = "ScreensPhoneChargerBlack"
		},
		{
			Category = "Screens",
			Id = 123145061676183,
			Name = "ScreensPhoneChargerPink"
		},
		{
			Category = "Screens",
			Id = 90256442150840,
			Name = "ScreensPhoneStand"
		},
		{
			Category = "Screens",
			Id = 92919099040975,
			Name = "ScreensTabletChargerBlack"
		},
		{
			Category = "Screens",
			Id = 133312841358156,
			Name = "ScreensTabletChargerPink"
		},
		{
			Category = "Screens",
			Id = 115543702669201,
			Name = "ScreensMouse"
		},
		{
			Category = "Screens",
			Id = 108930524228118,
			Name = "ScreensKeyBoard"
		},
		{
			Category = "Screens",
			Id = 105485792978074,
			Name = "ScreensLaptop"
		},
		{
			Category = "Screens",
			Id = 88226277712231,
			Name = "ScreensConsole1"
		},
		{
			Category = "Screens",
			Id = 74076662436365,
			Name = "ScreensConsole2"
		},
		{
			Category = "Screens",
			Id = 72726195662052,
			Name = "RetroConsole"
		},
		{
			Category = "Screens",
			Id = 138360642699791,
			Name = "DeskFan"
		},
		{
			Category = "Screens",
			Id = 92626805413713,
			Name = "PortableHeater"
		},
		{
			Category = "Screens",
			Id = 8779427352,
			Name = "ScreensGhostDetector"
		},
		{
			Category = "Screens",
			Id = 137157302591039,
			Name = "ScreensGhostCatcher"
		},
		{
			Category = "Screens",
			Id = 79605161273443,
			Name = "ScreensRadio"
		},
		{
			Category = "Screens",
			Id = 4622190558,
			Name = "ScreensMicSmall"
		},
		{
			Category = "Screens",
			Id = 16019402739,
			Name = "ScreensMicrophone"
		},
		{
			Category = "Screens",
			Id = 81679494931414,
			Name = "ScreensStandMic"
		},
		{
			Category = "Screens",
			Id = 16896544025,
			Name = "ScreensMicBoom"
		},
		{
			Category = "Screens",
			Id = 4529167642,
			Name = "ScreensCamera"
		},
		{
			Category = "Screens",
			Id = 16019402864,
			Name = "ScreensMovieCamera"
		},
		{
			Category = "Screens",
			Id = 120984509689255,
			Name = "CRTTV"
		},
		{
			Category = "Screens",
			Id = 91166894523566,
			Name = "ScreensTVSmall"
		},
		{
			Category = "Screens",
			Id = 96378387791216,
			Name = "ScreensTVBig"
		},
		{
			Category = "Screens",
			Id = 16246091726,
			Name = "ScreensGreenScreen"
		},
		{
			Category = "Screens",
			Id = 16000010426,
			Name = "ScreensGamingDesk"
		},
		{
			Category = "Screens",
			Id = 16000010234,
			Name = "ScreensPCDesk"
		},
		{
			Category = "Screens",
			Id = 70948636775597,
			Name = "ScreensBigSpeakers"
		},
		{
			Category = "Screens",
			Id = 16249028441,
			Name = "ScreensServer"
		},
		{
			Category = "Screens",
			Id = 16246134767,
			Name = "ScreensServerOldSchool"
		},
		{
			Category = "Screens",
			Id = 113700090456701,
			Name = "ScreensHugeServer"
		},
		{
			Category = "Screens",
			Id = 83185414383709,
			Name = "ScreensArcadeOrange"
		},
		{
			Category = "Screens",
			Id = 84280596680680,
			Name = "ScreensArcadeBlue"
		},
		{
			Category = "Screens",
			Id = 88490440756060,
			Name = "ScreensArcadeRed"
		},
		{
			Category = "Screens",
			Id = 118968826445135,
			Name = "ScreensArcadeToothpaste"
		},
		{
			Category = "Screens",
			Id = 93599614733933,
			Name = "ScreensArcadeGreen"
		},
		{
			Category = "Screens",
			Id = 130660818502675,
			Name = "DanceMachineCouple"
		},
		{
			Category = "Screens",
			Id = 72250057616043,
			Name = "ClawMachine"
		},
		{
			Category = "Screens",
			Id = 78462009607751,
			Name = "ArcadeBikeYellow"
		},
		{
			Category = "Screens",
			Id = 73070075391349,
			Name = "ArcadeBikeBlue"
		},
		{
			Category = "Screens",
			Id = 135345634167814,
			Name = "ScreensRobotMedium"
		},
		{
			Category = "Screens",
			Id = 78868630138144,
			Name = "ScreensRobotBig"
		},
		{
			Category = "Screens",
			Id = 16896518167,
			Name = "ScreensSolar"
		},
		{
			Category = "Fence",
			Id = 16249028076,
			Name = "FencePlaceableSmall"
		},
		{
			Category = "Fence",
			Id = 16246088951,
			Name = "FencePlaceableBig"
		},
		{
			Category = "Fence",
			Id = 16248835331,
			Name = "FenceTireSpikes"
		},
		{
			Category = "Fence",
			Id = 16246361229,
			Name = "FenceStripes"
		},
		{
			Category = "Fence",
			Id = 16249090797,
			Name = "FenceVehicleFence"
		},
		{
			Category = "Fence",
			Id = 16249091069,
			Name = "FenceBarrierStripes"
		},
		{
			Category = "Fence",
			Id = 16005851309,
			Name = "FenceBarsGrey"
		},
		{
			Category = "Fence",
			Id = 16005851920,
			Name = "FenceBarsYellow"
		},
		{
			Category = "Fence",
			Id = 16005853751,
			Name = "FenceRanchWhite"
		},
		{
			Category = "Fence",
			Id = 16005877806,
			Name = "FenceConcrete"
		},
		{
			Category = "Fence",
			Id = 16005852042,
			Name = "FenceAnimals"
		},
		{
			Category = "Fence",
			Id = 16005852208,
			Name = "FenceTall"
		},
		{
			Category = "Fence",
			Id = 16248835041,
			Name = "FenceOldWhite"
		},
		{
			Category = "Fence",
			Id = 16246270478,
			Name = "FenceOldBrown"
		},
		{
			Category = "Fence",
			Id = 16005853068,
			Name = "FenceBoardsBrownWide"
		},
		{
			Category = "Fence",
			Id = 16005853295,
			Name = "FenceBoardsWhiteWide"
		},
		{
			Category = "Fence",
			Id = 16005852855,
			Name = "FenceBoardsBrownWideStraight"
		},
		{
			Category = "Fence",
			Id = 16005853525,
			Name = "FenceBoardsBrownSkinny"
		},
		{
			Category = "Fence",
			Id = 16248925872,
			Name = "FenceBlackSmall"
		},
		{
			Category = "Fence",
			Id = 16246360540,
			Name = "FenceBlackBig"
		},
		{
			Category = "Fence",
			Id = 16246134049,
			Name = "FenceJailWall"
		},
		{
			Category = "Fence",
			Item = "Easter2026WhiteFenceGate",
			Name = "WhiteFenceGate"
		},
		{
			Category = "Fence",
			Item = "Easter2026WhiteFencePanel",
			Name = "WhiteFencePanel"
		},
		{
			Category = "Thanksgiving",
			Id = 113433027227194,
			Name = "LeafPile"
		},
		{
			Category = "Thanksgiving",
			Id = 138054200255690,
			Name = "CornStalk"
		},
		{
			Category = "Thanksgiving",
			Id = 75906173842740,
			Name = "AutumnWreath"
		},
		{
			Category = "Thanksgiving",
			Id = 123792368510082,
			Name = "Cornucopia"
		},
		{
			Category = "Thanksgiving",
			Id = 118765716610614,
			Name = "MiniCornucopia"
		},
		{
			Category = "Thanksgiving",
			Id = 131139366884182,
			Name = "ThanksgivingPumpkins"
		},
		{
			Category = "Thanksgiving",
			Id = 118082144451369,
			Name = "ThanksgivingShelf"
		},
		{
			Category = "Thanksgiving",
			Id = 113852293811851,
			Name = "ThanksgivingStandingShelf"
		},
		{
			Category = "Thanksgiving",
			Id = 114311730066228,
			Name = "ThanksgivingWheelbarrow"
		},
		{
			Category = "Thanksgiving",
			Id = 101741275572761,
			Name = "WallLeaves"
		},
		{
			Category = "Thanksgiving",
			Id = 124573258659929,
			Name = "ClassicTurkey",
			Item = "ClassicTurkey"
		},
		{
			Category = "Thanksgiving",
			Id = 102874983910303,
			Name = "CriminalTurkey",
			Item = "CriminalTurkey"
		},
		{
			Category = "Thanksgiving",
			Id = 138569493031387,
			Name = "AgentTurkey",
			Item = "AgentTurkey"
		},
		{
			Category = "Thanksgiving",
			Id = 93261586648483,
			Name = "PilgrimTurkey",
			Item = "PilgrimTurkey"
		},
		{
			Category = "Thanksgiving",
			Id = 128464810280593,
			Name = "PoliceTurkey",
			Item = "PoliceTurkey"
		},
		{
			Category = "Thanksgiving",
			Id = 90517580119387,
			Name = "DoctorTurkey",
			Item = "DoctorTurkey"
		},
		{
			Category = "Thanksgiving",
			Id = 103545122441750,
			Name = "FirefighterTurkey",
			Item = "FirefighterTurkey"
		},
		{
			Category = "Infrastructure",
			Id = 104253906554626,
			Name = "BreakerPanel"
		},
		{
			Category = "Infrastructure",
			Id = 110368425577473,
			Name = "ElectricPoleSimple"
		},
		{
			Category = "Infrastructure",
			Id = 93348472468547,
			Name = "ElectricPoleTransformers"
		},
		{
			Category = "Infrastructure",
			Id = 138400312719140,
			Name = "HighVoltageBoxBig"
		},
		{
			Category = "Infrastructure",
			Id = 95428450129185,
			Name = "HighVoltageBoxSmall"
		},
		{
			Category = "Infrastructure",
			Id = 72218490173662,
			Name = "HighVoltageBoxWall"
		},
		{
			Category = "Infrastructure",
			Id = 87136186313906,
			Name = "TransformerBig"
		},
		{
			Category = "Infrastructure",
			Id = 89413578976143,
			Name = "TransformerMedium1"
		},
		{
			Category = "Infrastructure",
			Id = 77661339513906,
			Name = "TransformerMedium2"
		},
		{
			Category = "Infrastructure",
			Id = 120697474459279,
			Name = "TransformerMedium3"
		},
		{
			Category = "Infrastructure",
			Id = 116419904753523,
			Name = "TransformerSmall1"
		},
		{
			Category = "Infrastructure",
			Id = 83302669173774,
			Name = "TransformerSmall2"
		},
		{
			Category = "Infrastructure",
			Id = 107987971865268,
			Name = "TransformerSmall3"
		},
		{
			Category = "Infrastructure",
			Id = 120534735743369,
			Name = "TransmissionTower"
		},
		{
			Category = "Furniture",
			Id = 91496504925727,
			Name = "Chandelier"
		},
		{
			Category = "Furniture",
			Id = 89981077576042,
			Name = "DecorativePanelLight"
		},
		{
			Category = "Furniture",
			Id = 116673898575587,
			Name = "DecorativePanel"
		},
		{
			Category = "Furniture",
			Id = 136437220518303,
			Name = "HallTable"
		},
		{
			Category = "Furniture",
			Id = 72992307596953,
			Name = "LuxuryCoffeeMaker"
		},
		{
			Category = "Furniture",
			Id = 92975090225782,
			Name = "LuxuryMixer"
		},
		{
			Category = "Furniture",
			Id = 86062539414145,
			Name = "LuxuryWaterfall"
		},
		{
			Category = "Furniture",
			Id = 91455752414679,
			Name = "PersonalBlender"
		},
		{
			Category = "Furniture",
			Id = 103098333913166,
			Name = "SmallDecoration2"
		},
		{
			Category = "Furniture",
			Id = 97629001934551,
			Name = "SmallDecoration1"
		},
		{
			Category = "Furniture",
			Id = 73813365313993,
			Name = "TerracotaTiles"
		},
		{
			Category = "Furniture",
			Id = 96788428959568,
			Name = "WashingMachine"
		},
		{
			Category = "Furniture",
			Id = 125785081961153,
			Name = "CoffeePot"
		},
		{
			Category = "Building",
			Id = 123200327305638,
			Name = "Block1"
		},
		{
			Category = "Building",
			Id = 78213748482539,
			Name = "Block2"
		},
		{
			Category = "Building",
			Id = 129482066319056,
			Name = "Block3"
		},
		{
			Category = "Building",
			Id = 92756842297663,
			Name = "Wall"
		},
		{
			Category = "Building",
			Id = 95379728698190,
			Name = "HalfWall"
		},
		{
			Category = "Building",
			Id = 86940942137471,
			Name = "HalfWall2"
		},
		{
			Category = "Building",
			Id = 96557397242488,
			Name = "SideDoorWall"
		},
		{
			Category = "Building",
			Id = 136071115553040,
			Name = "SideDoorWallEmpty"
		},
		{
			Category = "Building",
			Id = 128119193854978,
			Name = "CenterDoorWall"
		},
		{
			Category = "Building",
			Id = 134355600914343,
			Name = "CenterDoorWallEmpty"
		},
		{
			Category = "Building",
			Id = 78334575579523,
			Name = "SingleWindowWall"
		},
		{
			Category = "Building",
			Id = 125384119395112,
			Name = "SingleWindowWallEmpty"
		},
		{
			Category = "Building",
			Id = 130577041220423,
			Name = "DoubleWindowWall"
		},
		{
			Category = "Building",
			Id = 102098419080459,
			Name = "DoubleWindowWallEmpty"
		},
		{
			Category = "Building",
			Id = 126036046294100,
			Name = "FullWindow"
		},
		{
			Category = "Building",
			Id = 135202745590728,
			Name = "SmallWindow"
		},
		{
			Category = "Building",
			Id = 100797721584238,
			Name = "GlassFull"
		},
		{
			Category = "Building",
			Id = 121469171464528,
			Name = "GlassHalf"
		},
		{
			Category = "Building",
			Id = 132746576151562,
			Name = "DoorFrame"
		},
		{
			Category = "Building",
			Id = 80079449787809,
			Name = "RegularDoor"
		},
		{
			Category = "Building",
			Id = 110136698929875,
			Name = "JailBars"
		},
		{
			Category = "Building",
			Id = 114821632417107,
			Name = "JailDoor"
		},
		{
			Category = "Building",
			Id = 72065412065226,
			Name = "Floor"
		},
		{
			Category = "Building",
			Id = 96446321221301,
			Name = "HalfFloor"
		},
		{
			Category = "Building",
			Id = 89576618010011,
			Name = "QuarterFloor"
		},
		{
			Category = "Building",
			Id = 96449284111233,
			Name = "FloorCorner1"
		},
		{
			Category = "Building",
			Id = 122225893596022,
			Name = "FloorCorner2"
		},
		{
			Category = "Building",
			Id = 82318671098606,
			Name = "FloorCorner2Half"
		},
		{
			Category = "Building",
			Id = 93359905425105,
			Name = "FloorCorner2Quarter"
		},
		{
			Category = "Building",
			Id = 114117450440067,
			Name = "FloorCornerHalf"
		},
		{
			Category = "Building",
			Id = 80302114689822,
			Name = "FloorCornerQuarter"
		},
		{
			Category = "Building",
			Id = 107824494910887,
			Name = "WedgeSmall"
		},
		{
			Category = "Building",
			Id = 107647034963644,
			Name = "WedgeMedium"
		},
		{
			Category = "Building",
			Id = 132312793104553,
			Name = "WedgeLarge"
		},
		{
			Category = "Building",
			Id = 120242734853586,
			Name = "CornerWedgeSmall"
		},
		{
			Category = "Building",
			Id = 83117596738773,
			Name = "CornerWedgeMedium"
		},
		{
			Category = "Building",
			Id = 118237416180367,
			Name = "CornerWedgeLarge"
		},
		{
			Category = "Building",
			Id = 84603989172064,
			Name = "VerticalWedgeSmall"
		},
		{
			Category = "Building",
			Id = 107365336977207,
			Name = "InvertedWedgeSmall"
		},
		{
			Category = "Building",
			Id = 115977803697145,
			Name = "Cylinder"
		},
		{
			Category = "Building",
			Id = 84404648682804,
			Name = "FlatCylinder"
		},
		{
			Category = "Building",
			Id = 107715703101899,
			Name = "ThinCylinder"
		},
		{
			Category = "Building",
			Id = 81847950491085,
			Name = "Cone"
		},
		{
			Category = "Building",
			Id = 74800088912256,
			Name = "PillarSmall"
		},
		{
			Category = "Building",
			Id = 106957275791499,
			Name = "PillarLarge"
		},
		{
			Category = "Building",
			Id = 94265636343431,
			Name = "CylinderPillarSmall"
		},
		{
			Category = "Building",
			Id = 119878180855928,
			Name = "CylinderPillarLarge"
		},
		{
			Category = "Building",
			Id = 79413674094846,
			Name = "SmallArch"
		},
		{
			Category = "Building",
			Id = 101005490896067,
			Name = "FullArch"
		},
		{
			Category = "Building",
			Id = 133977173049176,
			Name = "LargeArch"
		},
		{
			Category = "Building",
			Id = 93533821254035,
			Name = "SmallStairs"
		},
		{
			Category = "Building",
			Id = 108748761041635,
			Name = "Stairs"
		},
		{
			Category = "Building",
			Id = 85310304918381,
			Name = "SlopedStairs"
		},
		{
			Category = "Building",
			Id = 115340971040323,
			Name = "WoodFenceShort"
		},
		{
			Category = "Building",
			Id = 95402823960060,
			Name = "WoodFenceTall"
		},
		{
			Category = "Building",
			Id = 83027167378521,
			Name = "FenceDoorShort"
		},
		{
			Category = "Building",
			Id = 102364832369603,
			Name = "FenceDoor"
		},
		{
			Category = "Building",
			Id = 126901669845117,
			Name = "HedgeRoundLow"
		},
		{
			Category = "Building",
			Id = 98805183305768,
			Name = "HedgeRoundLowThick"
		},
		{
			Category = "Building",
			Id = 72885700659964,
			Name = "HedgeRoundTall"
		},
		{
			Category = "Building",
			Id = 93014625634114,
			Name = "HedgeRoundTallThick"
		},
		{
			Category = "Building",
			Id = 70527098395576,
			Name = "Edge"
		},
		{
			Category = "Building",
			Id = 115817449315313,
			Name = "EdgeHalf"
		},
		{
			Category = "Building",
			Id = 139245120962348,
			Name = "Light"
		},
		{
			Category = "Building",
			Id = 134910476909417,
			Name = "PotLight"
		},
		{
			Category = "Building",
			Id = 101196438968956,
			Name = "SmallPyramid"
		},
		{
			Category = "Building",
			Id = 89927666385518,
			Name = "Pyramid"
		}
	},
	Setup = function(instance, data)
		if data.ThemeImage then
			instance.PropTheme.Visible = true
			instance.PropTheme.Image = data.ThemeImage
		end

		if data.PropVIP then
			instance.PropVIP.Visible = true
		end

		if data.IsCategory and data.Name == "Building" then
			local propCollision = instance:FindFirstChild("PropCollision")

			if propCollision ~= nil then
				propCollision.Visible = true
			end
		end

		instance.Name = data.Name
		local icon = instance.Icon

		if data.Id ~= nil then
			icon.Image = "rbxassetid://" .. data.Id
		end
	end,
	IsGamepass = function(p)
		return p.PropVIP == true or p.PassRequired ~= nil
	end
}

function PropsOld.FilterEntryValues(data)
	local breadcrumbsFilter = data.BreadcrumbsFilter
	local entries = {}

	for _, entry in PropsOld.Entries do
		if breadcrumbsFilter == nil then
			if data.CurrentCategory == nil then
				if data.CategoryFilter == nil and data.GamepassFilter == nil and entry.Category ~= nil or data.GamepassFilter ~= nil and not data.GamepassFilter(entry) or data.CategoryFilter ~= nil and not data.CategoryFilter(entry) then
					continue
				end
			elseif entry.Category ~= data.CurrentCategory then
				continue
			end

			table.insert(entries, entry)
		else
			if data.CurrentCategory == nil then
				if entry.IsCategory ~= true or not breadcrumbsFilter(entry) or data.CategoryFilter ~= nil and not data.CategoryFilter(entry) then
					continue
				end
			elseif entry.IsCategory == true or entry.Category ~= data.CurrentCategory or not breadcrumbsFilter(entry) then
				continue
			end

			if data.GamepassFilter == nil or data.GamepassFilter(entry) then
				table.insert(entries, entry)
			end
		end
	end

	return entries
end

function PropsOld.GetRenderContext()
	return ItemRenderer.PROPS_CONTEXT
end

return PropsOld