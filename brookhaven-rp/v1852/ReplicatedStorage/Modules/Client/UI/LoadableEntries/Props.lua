local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local Props = {
	Entries = {
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Lights",
			Id = 101805429785894
		},
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Big Structures",
			Id = 139945506570660
		},
		{
			Filter = "Decor",
			IsCategory = true,
			Name = "Decor",
			Id = 106310313728533
		},
		{
			Filter = "Decor",
			IsCategory = true,
			Name = "Shapes",
			Id = 74989440821229
		},
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Furniture",
			Id = 80977209617187
		},
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Building Basics",
			Id = 96105175820811
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Food",
			Id = 83281266978332
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Tech",
			Id = 83769811453543
		},
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Outdoor Furniture",
			Id = 99716604645818
		},
		{
			Filter = "Decor",
			IsCategory = true,
			Name = "Fire & Smoke",
			Id = 118851768613109
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Car",
			Id = 72833138253471
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Fence",
			Id = 81536162673825
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Money & Documents",
			Id = 98961425344254
		},
		{
			Filter = "Decor",
			IsCategory = true,
			Name = "Nature",
			Id = 121197603052998
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Babies",
			Id = 137185224808902
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Military",
			Id = 125877693655809
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Construction",
			Id = 79514855623375
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Party",
			Id = 140485342022537
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Spooky",
			Id = 72865534330281
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Holiday",
			Id = 116912601958203
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Garbage",
			Id = 73159552832032
		},
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Clothing",
			Id = 93380191841475
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Sports",
			Id = 117972602751901
		},
		{
			Filter = "Home",
			IsCategory = true,
			Name = "Storage",
			Id = 75276781035625
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Arts and Crafts",
			Id = 133570882923701
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Hospital",
			Id = 113002453691004
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Music",
			Id = 120471198302852
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Fireworks",
			Id = 117343479190672
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Horses",
			Id = 119386209588954
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Hazardous",
			Id = 119180910736133
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Infrastructure",
			Id = 118936397777756
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Pets",
			Id = 140398850508069
		},
		{
			Filter = "Play",
			IsCategory = true,
			Name = "Small Vehicles",
			Id = 117440518235452
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Tools",
			Id = 115184100317084
		},
		{
			Filter = "Work",
			IsCategory = true,
			Name = "Signs",
			Id = 132813738566625
		},
		{
			Filter = "Seasonal",
			IsCategory = true,
			Name = "Carnival",
			Id = 134226962868986
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
			Name = "Wicked",
			Id = 128031356488978,
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
			Category = "Outdoor Furniture",
			Id = 135693429981572,
			Name = "WickerChair"
		},
		{
			Category = "Outdoor Furniture",
			Id = 77292168865760,
			Name = "Hammock"
		},
		{
			Category = "Outdoor Furniture",
			Id = 87946256849154,
			Name = "PatioDayBed"
		},
		{
			Category = "Outdoor Furniture",
			Id = 106123714458422,
			Name = "WickerTable"
		},
		{
			Category = "Furniture",
			Id = 73720220441465,
			Name = "ChairSwing"
		},
		{
			Category = "Outdoor Furniture",
			Id = 118852708390426,
			Name = "BenchSwing",
			PropVIP = true
		},
		{
			Category = "Outdoor Furniture",
			Id = 127262889108870,
			Name = "SingleTireSwing"
		},
		{
			Category = "Outdoor Furniture",
			Id = 72280938265526,
			Name = "SharedTireSwing"
		},
		{
			Category = "Arts and Crafts",
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
			Category = "Outdoor Furniture",
			Name = "LoungeChair",
			Item = "LoungeChair"
		},
		{
			Category = "Outdoor Furniture",
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
			Category = "Outdoor Furniture",
			Id = 16006250905,
			Name = "FurnitureTableOutsideCover",
			PropVIP = false
		},
		{
			Category = "Outdoor Furniture",
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
			Category = "Decor",
			Id = 107132551461778,
			Name = "FurnitureMirror1"
		},
		{
			Category = "Decor",
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
			Category = "Decor",
			Id = 84334656921153,
			Name = "CastleFineChinaTeapot"
		},
		{
			Category = "Decor",
			Id = 81559189559599,
			Name = "CastleTeacup&Saucer"
		},
		{
			Category = "Decor",
			Id = 137854226259258,
			Name = "CastleFancyJug"
		},
		{
			Category = "Furniture",
			Id = 128559272837190,
			Name = "CastleFancyBed"
		},
		{
			Category = "Decor",
			Id = 72819231786274,
			Name = "CastleFancyCurtains"
		},
		{
			Category = "Lights",
			Id = 103156527074592,
			Name = "CastleFancyChandelier"
		},
		{
			Category = "Decor",
			Id = 127881965505669,
			Name = "CastleFancyRug"
		},
		{
			Category = "Decor",
			Id = 94940174467197,
			Name = "FurnitureRoundRug"
		},
		{
			Category = "Decor",
			Id = 118936602818869,
			Name = "ArtisanRedCarpet"
		},
		{
			Category = "Decor",
			Id = 102768203247190,
			Name = "ArtisanBlueCarpet"
		},
		{
			Category = "Outdoor Furniture",
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
			Category = "Decor",
			Item = "FramedPortrait",
			Name = "FramedPortrait"
		},
		{
			Category = "Decor",
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
			Category = "Decor",
			Item = "HangingScroll",
			Name = "HangingScroll"
		},
		{
			Category = "Outdoor Furniture",
			Id = 82031750290293,
			Name = "BHStatue"
		},
		{
			Category = "Outdoor Furniture",
			Id = 117888091609338,
			Name = "BirdBath"
		},
		{
			Category = "Outdoor Furniture",
			Id = 87555220839065,
			Name = "Fuente"
		},
		{
			Category = "Decor",
			Id = 106688307890299,
			Name = "Mirror#1"
		},
		{
			Category = "Decor",
			Id = 133154991691964,
			Name = "Mirror#2"
		},
		{
			Category = "Nature",
			Id = 137544511912989,
			Name = "Monstera"
		},
		{
			Category = "Nature",
			Id = 75076453917460,
			Name = "Tarrario"
		},
		{
			Category = "Decor",
			Id = 109167289694287,
			Name = "GlassHurricaneLantern"
		},
		{
			Category = "Decor",
			Id = 109488552861479,
			Name = "RoomDiffuser"
		},
		{
			Category = "Decor",
			Id = 124135134497473,
			Name = "LavenderWallPlanter"
		},
		{
			Category = "Decor",
			Id = 88562449422613,
			Name = "PerfumeCarousel"
		},
		{
			Category = "Decor",
			Id = 116958796514634,
			Name = "BookCart"
		},
		{
			Category = "Decor",
			Id = 115175658138538,
			Name = "WaterBottle"
		},
		{
			Category = "Decor",
			Id = 129623372580967,
			Name = "HeartMirror"
		},
		{
			Category = "Decor",
			Id = 130459310048416,
			Name = "WickerTray"
		},
		{
			Category = "Decor",
			Id = 109226519424399,
			Name = "PanRack"
		},
		{
			Category = "Decor",
			Id = 89977250336861,
			Name = "ClothesHamper"
		},
		{
			Category = "Outdoor Furniture",
			Id = 16018687373,
			Name = "PoolKiddie"
		},
		{
			Category = "Outdoor Furniture",
			Id = 16018687499,
			Name = "PoolTowelPurple"
		},
		{
			Category = "Outdoor Furniture",
			Id = 16018687661,
			Name = "PoolTowelBlue"
		},
		{
			Category = "Outdoor Furniture",
			Id = 16018687908,
			Name = "PoolTowelRainbow"
		},
		{
			Category = "Outdoor Furniture",
			Id = 16018687236,
			Name = "PoolSandBox"
		},
		{
			Category = "Outdoor Furniture",
			Id = 18594542862,
			Name = "PoolUmbrella"
		},
		{
			Category = "Outdoor Furniture",
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
			Category = "Spooky",
			Id = 16010313895,
			Name = "DeadZombie"
		},
		{
			Category = "Spooky",
			Id = 16010314377,
			Name = "DeadSkeletonLay"
		},
		{
			Category = "Spooky",
			Id = 16010314714,
			Name = "DeadSkeletonSit"
		},
		{
			Category = "Spooky",
			Id = 16010314268,
			Name = "DeadSkeletonStand"
		},
		{
			Category = "Spooky",
			Id = 16010314502,
			Name = "DeadSkeletonStandArms"
		},
		{
			Category = "Spooky",
			Id = 16010314139,
			Name = "DeadHeadStone"
		},
		{
			Category = "Spooky",
			Id = 16010313720,
			Name = "DeadGraveBlood"
		},
		{
			Category = "Spooky",
			Id = 16010314870,
			Name = "DeadGraveSkeleton"
		},
		{
			Category = "Spooky",
			Id = 16010315111,
			Name = "DeadGraveBrown"
		},
		{
			Category = "Spooky",
			Id = 16010314018,
			Name = "DeadGraveAgency"
		},
		{
			Category = "Spooky",
			Id = 16010315001,
			Name = "DeadGraveBrownOpen"
		},
		{
			Category = "Spooky",
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
			Category = "Signs",
			Id = 98873066531195,
			Name = "PosterMap2"
		},
		{
			Category = "Signs",
			Id = 16246024499,
			Name = "PosterWoodGraph"
		},
		{
			Category = "Signs",
			Id = 72785543766332,
			Name = "PosterWorldMap"
		},
		{
			Category = "Signs",
			Id = 97464176535970,
			Name = "NewspaperStand"
		},
		{
			Category = "Signs",
			Id = 132035115583884,
			Name = "LeafletStand"
		},
		{
			Category = "Fire & Smoke",
			Id = 109970501056679,
			Name = "TorchFireWood"
		},
		{
			Category = "Fire & Smoke",
			Id = 15999345094,
			Name = "TorchFireBBQ"
		},
		{
			Category = "Fire & Smoke",
			Id = 15999345637,
			Name = "TorchFire"
		},
		{
			Category = "Fire & Smoke",
			Id = 15999356350,
			Name = "Torch4Skinny"
		},
		{
			Category = "Fire & Smoke",
			Id = 15999344962,
			Name = "Torch2Skinny"
		},
		{
			Category = "Fire & Smoke",
			Id = 15999345334,
			Name = "TorchBarrel"
		},
		{
			Category = "Fire & Smoke",
			Id = 16249273586,
			Name = "TorchFireLong"
		},
		{
			Category = "Fire & Smoke",
			Id = 15999344813,
			Name = "TorchLanturn"
		},
		{
			Category = "Pets",
			Id = 73697089709256,
			Name = "PetFoodBowl"
		},
		{
			Category = "Pets",
			Id = 132424986508756,
			Name = "DogHouse"
		},
		{
			Category = "Pets",
			Id = 134936022796132,
			Name = "ScratchPost"
		},
		{
			Category = "Pets",
			Id = 106218220483962,
			Name = "CatBed"
		},
		{
			Category = "Pets",
			Id = 122980160983225,
			Name = "DogBed"
		},
		{
			Category = "Pets",
			Id = 122466048301298,
			Name = "CatTower"
		},
		{
			Category = "Pets",
			Id = 73276837511671,
			Name = "BasketOfToys"
		},
		{
			Category = "Food",
			Id = 17746939254,
			Name = "AnimalMeat"
		},
		{
			Category = "Pets",
			Id = 17746977452,
			Name = "AnimalCageBirdRed"
		},
		{
			Category = "Pets",
			Id = 17746979988,
			Name = "AnimalCageBirdBlue"
		},
		{
			Category = "Pets",
			Id = 18594484424,
			Name = "AnimalFishSmall"
		},
		{
			Category = "Pets",
			Id = 18594464810,
			Name = "AnimalFishBigVIP",
			PropVIP = true
		},
		{
			Category = "Pets",
			Id = 78898330463716,
			Name = "MedicineCabinet"
		},
		{
			Category = "Pets",
			Id = 114898215650099,
			Name = "MedicineCabinet2"
		},
		{
			Category = "Pets",
			Id = 92740983357212,
			Name = "WeighingScale"
		},
		{
			Category = "Fence",
			Id = 16019834860,
			Name = "LazerSmall"
		},
		{
			Category = "Fence",
			Id = 16019834562,
			Name = "LazerMedium"
		},
		{
			Category = "Fence",
			Id = 16019834750,
			Name = "LazerLarge"
		},
		{
			Category = "Horses",
			Id = 15999183103,
			Name = "HorseBigBrown"
		},
		{
			Category = "Horses",
			Id = 15999142420,
			Name = "HorseBigBlack"
		},
		{
			Category = "Horses",
			Id = 15999142582,
			Name = "HorseSmallTan"
		},
		{
			Category = "Horses",
			Id = 15999143447,
			Name = "HorseSmallGrey"
		},
		{
			Category = "Horses",
			Id = 15999142279,
			Name = "HorseSmallWhite"
		},
		{
			Category = "Horses",
			Id = 15999181407,
			Name = "HorseHay"
		},
		{
			Category = "Horses",
			Id = 74181623506279,
			Name = "HorseSaddle"
		},
		{
			Category = "Horses",
			Id = 81303123592181,
			Name = "HorseJumpSmall"
		},
		{
			Category = "Horses",
			Id = 78703971359856,
			Name = "HorseJumpMedium"
		},
		{
			Category = "Horses",
			Id = 124781995731939,
			Name = "HorseJumpLarge"
		},
		{
			Category = "Horses",
			PassRequired = "HORSE_UNLOCKED",
			Name = "PropAkhal-Teke",
			ThemeImage = "rbxassetid://131468654182120",
			Id = 108378998335330,
			PropVIP = false
		},
		{
			Category = "Horses",
			PassRequired = "HORSE_UNLOCKED",
			Name = "PropShire",
			ThemeImage = "rbxassetid://131468654182120",
			Id = 96292534416237,
			PropVIP = false
		},
		{
			Category = "Horses",
			PassRequired = "HORSE_UNLOCKED",
			Name = "PropMiniHorse",
			ThemeImage = "rbxassetid://131468654182120",
			Id = 111214088979100,
			PropVIP = false
		},
		{
			Category = "Horses",
			PassRequired = "HORSE_UNLOCKED",
			Name = "PropFriesian",
			ThemeImage = "rbxassetid://131468654182120",
			Id = 107295990839355,
			PropVIP = false
		},
		{
			Category = "Horses",
			PassRequired = "HORSE_UNLOCKED",
			Name = "PropDonkey",
			ThemeImage = "rbxassetid://131468654182120",
			Id = 135957522719531,
			PropVIP = false
		},
		{
			Category = "Horses",
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
			Category = "Fire & Smoke",
			Id = 16019607362,
			Name = "SmokeWhite"
		},
		{
			Category = "Fire & Smoke",
			Id = 16019587130,
			Name = "SmokeGreen"
		},
		{
			Category = "Fire & Smoke",
			Id = 16019587273,
			Name = "SmokeYellow"
		},
		{
			Category = "Fire & Smoke",
			Id = 16019587439,
			Name = "SmokeBlue"
		},
		{
			Category = "Fire & Smoke",
			Id = 16019586856,
			Name = "SmokeRed"
		},
		{
			Category = "Fire & Smoke",
			Id = 16019587563,
			Name = "SmokePurple"
		},
		{
			Category = "Fire & Smoke",
			Id = 16249277953,
			Name = "SmokeWhiteWide"
		},
		{
			Category = "Decor",
			Id = 5480682123,
			Name = "GirlyBrush"
		},
		{
			Category = "Decor",
			Id = 16101444401,
			Name = "GirlyMirrorSmall"
		},
		{
			Category = "Lights",
			Id = 16101444029,
			Name = "GirlyShapeMoon"
		},
		{
			Category = "Lights",
			Id = 16101385291,
			Name = "GirlyShapeHeartPink"
		},
		{
			Category = "Lights",
			Id = 16246360907,
			Name = "GirlyShapeStar"
		},
		{
			Category = "Lights",
			Id = 71753735792068,
			Name = "EggLamp"
		},
		{
			Category = "Lights",
			Id = 108720346444795,
			Name = "LavaLamp"
		},
		{
			Category = "Furniture",
			Id = 16020186274,
			Name = "GirlyMirror"
		},
		{
			Category = "Furniture",
			Id = 16020186182,
			Name = "GirlyMakeupGlass"
		},
		{
			Category = "Furniture",
			Id = 16020186115,
			Name = "GirlyMakeupPink"
		},
		{
			Category = "Decor",
			Id = 16248974881,
			Name = "GirlyShelf"
		},
		{
			Category = "Decor",
			Id = 18594424331,
			Name = "GirlySingleRose"
		},
		{
			Category = "Decor",
			Id = 18594503743,
			Name = "GirlyVaseRose"
		},
		{
			Category = "Decor",
			Id = 16101387651,
			Name = "GirlyCandlesWhite"
		},
		{
			Category = "Decor",
			Id = 16101205214,
			Name = "GirlyCandlesVanilla"
		},
		{
			Category = "Decor",
			Id = 16101205711,
			Name = "GirlyCandlesGreen"
		},
		{
			Category = "Decor",
			Id = 16101387466,
			Name = "GirlyCandlesRed"
		},
		{
			Category = "Decor",
			Id = 16101205508,
			Name = "GirlyCandlesPink"
		},
		{
			Category = "Decor",
			Id = 16101387360,
			Name = "GirlyCandlesPurple"
		},
		{
			Category = "Furniture",
			Id = 16101541354,
			Name = "GirlyBeanBagPink"
		},
		{
			Category = "Decor",
			Id = 16101540983,
			Name = "GirlyPinkRoundRug"
		},
		{
			Category = "Decor",
			Id = 16101541126,
			Name = "GirlyPinkRoundRugPillows"
		},
		{
			Category = "Lights",
			Id = 16020305388,
			Name = "GirlyLightsWhite"
		},
		{
			Category = "Lights",
			Id = 16020305559,
			Name = "GirlyLightsPurple"
		},
		{
			Category = "Lights",
			Id = 16020315605,
			Name = "GirlyLightsPink"
		},
		{
			Category = "Lights",
			Id = 16020305729,
			Name = "GirlyLightsRoundWhite"
		},
		{
			Category = "Lights",
			Id = 16020305867,
			Name = "GirlyLightsRoundPurple"
		},
		{
			Category = "Lights",
			Id = 16020306021,
			Name = "GirlyLightsRoundPink"
		},
		{
			Category = "Decor",
			Id = 84557279747301,
			Name = "BuntingBanner"
		},
		{
			Category = "Outdoor Furniture",
			Id = 90270788127835,
			Name = "HotScoth"
		},
		{
			Category = "Big Structures",
			Id = 16010118931,
			Name = "BigKidsRedBlue"
		},
		{
			Category = "Big Structures",
			Id = 16010119430,
			Name = "BigOldCabin"
		},
		{
			Category = "Big Structures",
			Id = 16010119274,
			Name = "BigPinkTent"
		},
		{
			Category = "Big Structures",
			Id = 16010118525,
			Name = "BigTeePee"
		},
		{
			Category = "Big Structures",
			Id = 16010118599,
			Name = "BigHomeless"
		},
		{
			Category = "Big Structures",
			Name = "CardboardTent",
			Item = "CardboardTent"
		},
		{
			Category = "Big Structures",
			Id = 16010119125,
			Name = "BigCampingTent"
		},
		{
			Category = "Big Structures",
			Id = 16101444646,
			Name = "BigMedicalTent"
		},
		{
			Category = "Big Structures",
			Id = 16101445400,
			Name = "BigCage"
		},
		{
			Category = "Big Structures",
			Id = 16249029446,
			Name = "BigHorseFence"
		},
		{
			Category = "Big Structures",
			Id = 16101205877,
			Name = "BigGunBunker"
		},
		{
			Category = "Big Structures",
			Id = 16010118439,
			Name = "BigMilitaryTent"
		},
		{
			Category = "Big Structures",
			Id = 16010118789,
			Name = "BigWhiteCanopee"
		},
		{
			Category = "Big Structures",
			Id = 16010119018,
			Name = "BigUmbrella"
		},
		{
			Category = "Big Structures",
			Id = 16010118336,
			Name = "BigOutToilet"
		},
		{
			Category = "Big Structures",
			Id = 18594473709,
			Name = "BigTelephoneBooth"
		},
		{
			Category = "Big Structures",
			Id = 73760786122120,
			Name = "BigVotingBooth"
		},
		{
			Category = "Big Structures",
			Name = "ToriiGate",
			Item = "ToriiGate"
		},
		{
			Category = "Babies",
			Id = 5528668898,
			Name = "BabyMilkBottle"
		},
		{
			Category = "Babies",
			Id = 18596458978,
			Name = "BabyBoyWhite"
		},
		{
			Category = "Babies",
			Id = 18596464139,
			Name = "BabyGirlWhite"
		},
		{
			Category = "Babies",
			Id = 18596469044,
			Name = "BabyBoyBrown"
		},
		{
			Category = "Babies",
			Id = 18596466781,
			Name = "BabyGirlBrown"
		},
		{
			Category = "Babies",
			Id = 5528668413,
			Name = "BabyMonkey"
		},
		{
			Category = "Babies",
			Id = 5528669302,
			Name = "BabyHippo"
		},
		{
			Category = "Babies",
			Id = 114284773858113,
			Name = "BoyPlayTable",
			PropVIP = true
		},
		{
			Category = "Babies",
			Id = 86484899593280,
			Name = "GirlPlayTable",
			PropVIP = true
		},
		{
			Category = "Babies",
			Id = 119700521245685,
			Name = "BoyPlayRug"
		},
		{
			Category = "Babies",
			Id = 111404813615969,
			Name = "GirlPlayRug"
		},
		{
			Category = "Babies",
			Id = 119036886950226,
			Name = "PlayTunnelGirl"
		},
		{
			Category = "Babies",
			Id = 119894162170731,
			Name = "PlayTunnelBoy"
		},
		{
			Category = "Babies",
			Id = 84153415605888,
			Name = "PlayTunnelNeutral"
		},
		{
			Category = "Babies",
			Id = 96798262620700,
			Name = "BabyRattle"
		},
		{
			Category = "Babies",
			Id = 16017012321,
			Name = "BabyGirlCarSeat"
		},
		{
			Category = "Babies",
			Id = 16017012176,
			Name = "BabyBoyCarSeat"
		},
		{
			Category = "Babies",
			Id = 16896458517,
			Name = "BabyPoddyBoy"
		},
		{
			Category = "Babies",
			Id = 16896461926,
			Name = "BabyPoddyGirl"
		},
		{
			Category = "Babies",
			Id = 16017011740,
			Name = "BabyHighChair"
		},
		{
			Category = "Babies",
			Id = 16017011605,
			Name = "BabyDresser"
		},
		{
			Category = "Babies",
			Id = 16017011887,
			Name = "BabyBlanket"
		},
		{
			Category = "Babies",
			Id = 97431876012987,
			Name = "BabyCrib"
		},
		{
			Category = "Babies",
			Id = 6607753154,
			Name = "BabyRedCart"
		},
		{
			Category = "Babies",
			Id = 71578527601743,
			Name = "BabyStroller"
		},
		{
			Category = "Babies",
			Id = 116427179573250,
			Name = "BabyWalker"
		},
		{
			Category = "Babies",
			Id = 16017011455,
			Name = "BabyPlayPinBlue"
		},
		{
			Category = "Babies",
			Id = 16017012055,
			Name = "BabyPlayPinPink"
		},
		{
			Category = "Babies",
			Id = 114882329095432,
			Name = "ToyBlocks1"
		},
		{
			Category = "Babies",
			Id = 113254887236864,
			Name = "ToyBlocks2"
		},
		{
			Category = "Babies",
			Id = 85192027571298,
			Name = "ToyBlocks5"
		},
		{
			Category = "Babies",
			Id = 99169635798159,
			Name = "ToyBlocks3"
		},
		{
			Category = "Babies",
			Id = 96433526650879,
			Name = "ToyBlocks4"
		},
		{
			Category = "Holiday",
			Id = 16103812132,
			Name = "HalloweenPumkin5"
		},
		{
			Category = "Holiday",
			Id = 16103754922,
			Name = "HalloweenPumkin2"
		},
		{
			Category = "Holiday",
			Id = 16103755195,
			Name = "HalloweenPumkin3"
		},
		{
			Category = "Holiday",
			Id = 16103754629,
			Name = "HalloweenPumkin4"
		},
		{
			Category = "Holiday",
			Id = 16103832370,
			Name = "HalloweenSpider"
		},
		{
			Category = "Holiday",
			Id = 16103832279,
			Name = "HalloweenSpiderSideways"
		},
		{
			Category = "Holiday",
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
			Category = "Holiday",
			Id = 113675744495521,
			Name = "CandyBucketProp"
		},
		{
			Category = "Holiday",
			Name = "CandyBasketProp",
			Item = "Halloween2025CandyBasketProp"
		},
		{
			Category = "Holiday",
			Name = "SkeletonJumpscare",
			Item = "Halloween2025SkeletonJumpscare"
		},
		{
			Category = "Holiday",
			Name = "PumpkinJumpscare",
			Item = "Halloween2025PumpkinJumpscare"
		},
		{
			Category = "Holiday",
			Id = 83613753172219,
			Name = "HangingCage"
		},
		{
			Category = "Arts and Crafts",
			Id = 136987717409923,
			Name = "SpraypaintBox"
		},
		{
			Category = "Arts and Crafts",
			Id = 89481402639532,
			Name = "ToolsPaintBuckets"
		},
		{
			Category = "Arts and Crafts",
			Id = 77809860179231,
			Name = "GraffitiLove"
		},
		{
			Category = "Arts and Crafts",
			Id = 110660208920152,
			Name = "GraffitiRoblox"
		},
		{
			Category = "Arts and Crafts",
			Id = 94689936073095,
			Name = "GraffitiAgency",
			PropVIP = true
		},
		{
			Category = "Arts and Crafts",
			Id = 124272724078872,
			Name = "GraffitiBrookhaven"
		},
		{
			Category = "Arts and Crafts",
			Id = 109564336018704,
			Name = "BrickWallLarge"
		},
		{
			Category = "Arts and Crafts",
			Id = 88180181733042,
			Name = "BrickWallSmall"
		},
		{
			Category = "Arts and Crafts",
			Id = 92092174219027,
			Name = "BrickWallTall"
		},
		{
			Category = "Arts and Crafts",
			Id = 100096786593466,
			Name = "BrickWallWide"
		},
		{
			Category = "Arts and Crafts",
			Id = 99162498751550,
			Name = "PaintSingleBucket"
		},
		{
			Category = "Arts and Crafts",
			Id = 121182572540733,
			Name = "PaintEmptyBuckets"
		},
		{
			Category = "Arts and Crafts",
			Id = 129588170354500,
			Name = "EmptyPaintBucket"
		},
		{
			Category = "Arts and Crafts",
			Id = 90262630479646,
			Name = "Paint3Buckets"
		},
		{
			Category = "Arts and Crafts",
			Id = 95365196038685,
			Name = "PaintSplatter1"
		},
		{
			Category = "Arts and Crafts",
			Id = 87760119116431,
			Name = "PaintSplatter2"
		},
		{
			Category = "Arts and Crafts",
			Id = 76794859790471,
			Name = "PaintSplatter3"
		},
		{
			Category = "Arts and Crafts",
			Id = 102137644017975,
			Name = "PaintSplatter4"
		},
		{
			Category = "Arts and Crafts",
			Id = 133445663640072,
			Name = "Sketchbooks1"
		},
		{
			Category = "Arts and Crafts",
			Id = 119476113266022,
			Name = "Sketchbooks2"
		},
		{
			Category = "Arts and Crafts",
			Id = 76307306923612,
			Name = "Sketchbooks3"
		},
		{
			Category = "Arts and Crafts",
			Id = 103305115118963,
			Name = "Sketchbooks4"
		},
		{
			Category = "Arts and Crafts",
			Id = 91511356379450,
			Name = "PaintRollerTray"
		},
		{
			Category = "Arts and Crafts",
			Id = 92669236231771,
			Name = "PaintingSupplies"
		},
		{
			Category = "Arts and Crafts",
			Id = 116643572188742,
			Name = "Canvas1"
		},
		{
			Category = "Arts and Crafts",
			Id = 107282440981834,
			Name = "Canvas2"
		},
		{
			Category = "Arts and Crafts",
			Id = 108055476586612,
			Name = "Canvas3"
		},
		{
			Category = "Arts and Crafts",
			Id = 85839653177836,
			Name = "Canvas4"
		},
		{
			Category = "Arts and Crafts",
			Id = 138398486799866,
			Name = "PaintingBrookhaven"
		},
		{
			Category = "Arts and Crafts",
			Id = 80233849182875,
			Name = "PaintingTown1"
		},
		{
			Category = "Arts and Crafts",
			Id = 136648636292785,
			Name = "PaintingTown2"
		},
		{
			Category = "Construction",
			Id = 16101574202,
			Name = "WoodWall4"
		},
		{
			Category = "Construction",
			Id = 16101574331,
			Name = "WoodWall3"
		},
		{
			Category = "Construction",
			Id = 16101574450,
			Name = "WoodWall1"
		},
		{
			Category = "Construction",
			Id = 16101574613,
			Name = "WoodWall2"
		},
		{
			Category = "Construction",
			Id = 16896563071,
			Name = "WoodRome"
		},
		{
			Category = "Construction",
			Id = 16246089629,
			Name = "WoodOrangePipes"
		},
		{
			Category = "Construction",
			Id = 16248925774,
			Name = "WoodLogs"
		},
		{
			Category = "Construction",
			Id = 16246316332,
			Name = "Wood2x4"
		},
		{
			Category = "Construction",
			Id = 16246270216,
			Name = "WoodSheetrock"
		},
		{
			Category = "Construction",
			Id = 16248835515,
			Name = "WoodLongBoxes"
		},
		{
			Category = "Construction",
			Id = 16246091525,
			Name = "WoodBrick"
		},
		{
			Category = "Construction",
			Id = 16246024874,
			Name = "WoodBunchSmallBoxes"
		},
		{
			Category = "Construction",
			Id = 16249027554,
			Name = "WoodBigBox"
		},
		{
			Category = "Construction",
			Id = 16248975286,
			Name = "WoodArmyBoxes"
		},
		{
			Category = "Party",
			Id = 6239256158,
			Name = "PresentSingleBalloon"
		},
		{
			Category = "Party",
			Id = 15999793769,
			Name = "PresentPinkBalloon"
		},
		{
			Category = "Party",
			Id = 15999793339,
			Name = "PresentRedBalloon"
		},
		{
			Category = "Party",
			Id = 15999794043,
			Name = "PresentPastelBalloon"
		},
		{
			Category = "Party",
			Id = 15999793576,
			Name = "PresentOrangeBalloon"
		},
		{
			Category = "Party",
			Id = 15999792903,
			Name = "PresentBirthdayBalloon"
		},
		{
			Category = "Party",
			Id = 15999793099,
			Name = "PresentChristmasBalloon"
		},
		{
			Category = "Party",
			Id = 16896535869,
			Name = "PresentRobloxBalloons"
		},
		{
			Category = "Party",
			Id = 15999794846,
			Name = "PresentBlue"
		},
		{
			Category = "Party",
			Id = 15999794637,
			Name = "PresentPink"
		},
		{
			Category = "Party",
			Id = 15999795197,
			Name = "Present4Boxes"
		},
		{
			Category = "Party",
			Id = 15999795031,
			Name = "Present3Boxes"
		},
		{
			Category = "Party",
			Id = 15999794251,
			Name = "PresentBigRedWhite"
		},
		{
			Category = "Party",
			Id = 15999794416,
			Name = "PresentBigGreenWhite"
		},
		{
			Category = "Holiday",
			Id = 16018992979,
			Name = "ChristmasBag"
		},
		{
			Category = "Holiday",
			Id = 16018992828,
			Name = "ChristmasWhiteTree"
		},
		{
			Category = "Holiday",
			Id = 16897607867,
			Name = "ChristmasGreenTree"
		},
		{
			Category = "Holiday",
			Id = 16018992517,
			Name = "ChristmasSnowman"
		},
		{
			Category = "Holiday",
			Id = 16018992657,
			Name = "ChristmasCandles"
		},
		{
			Category = "Holiday",
			Id = 16101444548,
			Name = "ChristmasSantaPlate"
		},
		{
			Category = "Holiday",
			Id = 15999793099,
			Name = "PresentChristmasBalloon"
		},
		{
			Category = "Holiday",
			Id = 15999795197,
			Name = "Present4Boxes"
		},
		{
			Category = "Holiday",
			Id = 85753660605997,
			Name = "ChristmasLights"
		},
		{
			Category = "Holiday",
			Id = 97204214092127,
			Name = "GiftTable",
			Item = "GiftTable"
		},
		{
			Category = "Holiday",
			Id = 109164315893275,
			Name = "Snowman1",
			Item = "Snowman1"
		},
		{
			Category = "Holiday",
			Id = 92580562535830,
			Name = "Snowman2",
			Item = "Snowman2"
		},
		{
			Category = "Holiday",
			Id = 83111861800268,
			Name = "Snowman3",
			Item = "Snowman3"
		},
		{
			Category = "Holiday",
			Id = 83755713880693,
			Name = "ChristmasStall",
			Item = "ChristmasStall"
		},
		{
			Category = "Holiday",
			Id = 109150993680766,
			Name = "RockingHorse",
			Item = "RockingHorse"
		},
		{
			Category = "Holiday",
			Id = 100623509700259,
			Name = "GingerbreadHouse",
			Item = "GingerbreadHouse"
		},
		{
			Category = "Small Vehicles",
			Id = 82128402478304,
			Name = "SmallVehiclesSkateBoard"
		},
		{
			Category = "Small Vehicles",
			Id = 135699743531883,
			Name = "SmallVehiclesScooter"
		},
		{
			Category = "Small Vehicles",
			Id = 137466141639612,
			Name = "SmallVehiclesSegway"
		},
		{
			Category = "Small Vehicles",
			Id = 94959958905511,
			Name = "SmallVehiclesWheelChair"
		},
		{
			Category = "Small Vehicles",
			Id = 95866941387362,
			Name = "SmallVehiclesBoysBike"
		},
		{
			Category = "Small Vehicles",
			Id = 110468713519947,
			Name = "SmallVehiclesGirlsBike"
		},
		{
			Category = "Small Vehicles",
			Id = 105177106808063,
			Name = "SmallVehiclesBikeRack"
		},
		{
			Category = "Money & Documents",
			Id = 14240155516,
			Name = "CaseTicket"
		},
		{
			Category = "Money & Documents",
			Id = 4551084336,
			Name = "CaseClipBoard"
		},
		{
			Category = "Money & Documents",
			Id = 14240155098,
			Name = "CaseEnvelope"
		},
		{
			Category = "Money & Documents",
			Id = 16246316668,
			Name = "CaseBookRed"
		},
		{
			Category = "Money & Documents",
			Id = 16246315590,
			Name = "CaseBookBlack"
		},
		{
			Category = "Money & Documents",
			Id = 16101542129,
			Name = "CasePapers"
		},
		{
			Category = "Money & Documents",
			Id = 16101386034,
			Name = "CaseFolder"
		},
		{
			Category = "Money & Documents",
			Id = 16101206570,
			Name = "CaseBrownBriefcase"
		},
		{
			Category = "Money & Documents",
			Id = 16101206745,
			Name = "CaseBlackBriefcase"
		},
		{
			Category = "Money & Documents",
			Id = 16101206062,
			Name = "CaseOpenBrownBriefcase"
		},
		{
			Category = "Money & Documents",
			Id = 16101206225,
			Name = "CaseBlackBriefcaseFolder"
		},
		{
			Category = "Money & Documents",
			Id = 16101206375,
			Name = "CaseMoneyBackBriefcase"
		},
		{
			Category = "Money & Documents",
			Id = 16246023752,
			Name = "CaseOpenBrownBriefcaseGold"
		},
		{
			Category = "Money & Documents",
			Id = 16101574718,
			Name = "CaseSmallNukeBomb"
		},
		{
			Category = "Money & Documents",
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
			Category = "Signs",
			Id = 16246270728,
			Name = "SignMedWallBlack"
		},
		{
			Category = "Signs",
			Id = 16248834705,
			Name = "SignMedWallWhite"
		},
		{
			Category = "Signs",
			Id = 16249029555,
			Name = "SignLongBlack"
		},
		{
			Category = "Signs",
			Id = 16248834922,
			Name = "SignLongWhite"
		},
		{
			Category = "Signs",
			Id = 16248925383,
			Name = "SignWoodBlack"
		},
		{
			Category = "Signs",
			Id = 16248924547,
			Name = "SignWoodWhite"
		},
		{
			Category = "Signs",
			Id = 15998307297,
			Name = "SignBlackSmall"
		},
		{
			Category = "Signs",
			Id = 15998308852,
			Name = "SignBlackBig"
		},
		{
			Category = "Signs",
			Id = 15998309053,
			Name = "SignWhiteBig"
		},
		{
			Category = "Signs",
			Id = 16246315821,
			Name = "SignWetFloor"
		},
		{
			Category = "Signs",
			Name = "CardboardSign",
			Item = "CardboardSign"
		},
		{
			Category = "Signs",
			Id = 15998307506,
			Name = "SignOpenClose"
		},
		{
			Category = "Signs",
			Id = 16101385174,
			Name = "SignSweetHome"
		},
		{
			Category = "Signs",
			Id = 15998308537,
			Name = "SignHandy"
		},
		{
			Category = "Signs",
			Id = 15998309290,
			Name = "SignDangerZone"
		},
		{
			Category = "Signs",
			Id = 15998307944,
			Name = "SignNoParking"
		},
		{
			Category = "Signs",
			Id = 16101385571,
			Name = "SignNoBoys"
		},
		{
			Category = "Signs",
			Id = 16101542358,
			Name = "SignNoGirls"
		},
		{
			Category = "Signs",
			Id = 16101575984,
			Name = "SignKeepOut"
		},
		{
			Category = "Signs",
			Id = 16101575019,
			Name = "SignBiohazard"
		},
		{
			Category = "Signs",
			Id = 16101574859,
			Name = "SignRadiation"
		},
		{
			Category = "Signs",
			Id = 16101575448,
			Name = "SignCamera"
		},
		{
			Category = "Signs",
			Id = 16101575789,
			Name = "SignPoison"
		},
		{
			Category = "Signs",
			Id = 16101575261,
			Name = "SignMask"
		},
		{
			Category = "Signs",
			Id = 16101575605,
			Name = "SignCrazyPeople"
		},
		{
			Category = "Signs",
			Id = 16249091282,
			Name = "SignPlayerPictureSmall"
		},
		{
			Category = "Signs",
			Id = 16101576135,
			Name = "SignPlayerPicture"
		},
		{
			Category = "Signs",
			Id = 15998309196,
			Name = "SignOpenPlace"
		},
		{
			Category = "Signs",
			Id = 16246316504,
			Name = "SignSuperSaleStanding"
		},
		{
			Category = "Signs",
			Id = 16246024095,
			Name = "SignSuperSaleWall"
		},
		{
			Category = "Signs",
			Id = 16246133876,
			Name = "Sign50OffStand"
		},
		{
			Category = "Signs",
			Id = 16248835134,
			Name = "Sign50OffWall"
		},
		{
			Category = "Signs",
			Id = 15998308111,
			Name = "SignForSale"
		},
		{
			Category = "Signs",
			Id = 15998308238,
			Name = "SignForRent"
		},
		{
			Category = "Signs",
			Id = 15998308683,
			Name = "SignOpen"
		},
		{
			Category = "Signs",
			Id = 15998308373,
			Name = "SignClosed"
		},
		{
			Category = "Signs",
			Id = 15998307795,
			Name = "SignAgencySmall"
		},
		{
			Category = "Signs",
			Id = 15998307644,
			Name = "SignAgencyBig"
		},
		{
			Category = "Signs",
			Id = 70564895195365,
			Name = "SignFuturistic1"
		},
		{
			Category = "Signs",
			Id = 118996634846947,
			Name = "SignFuturistic2"
		},
		{
			Category = "Signs",
			Id = 130936678412450,
			Name = "SignAccessGranted"
		},
		{
			Category = "Signs",
			Id = 100594379454904,
			Name = "SignTapeMarksWhite"
		},
		{
			Category = "Signs",
			Id = 88150394111985,
			Name = "SignTapeMarksBlack"
		},
		{
			Category = "Nature",
			Id = 16018387079,
			Name = "PlantOutsideTreeGreenSmall"
		},
		{
			Category = "Nature",
			Id = 16018387210,
			Name = "PlantOutsideTreeGreenBig"
		},
		{
			Category = "Nature",
			Id = 16018386967,
			Name = "PlantOutsideTreeMedium"
		},
		{
			Category = "Nature",
			Id = 16018386472,
			Name = "PlantOutsideBushSmall"
		},
		{
			Category = "Nature",
			Id = 16018386634,
			Name = "PlantOutsideBushBig"
		},
		{
			Category = "Outdoor Furniture",
			Id = 16102581847,
			Name = "PlantSprinkler"
		},
		{
			Category = "Outdoor Furniture",
			Id = 5480684131,
			Name = "PlantWateringCan"
		},
		{
			Category = "Nature",
			Id = 4617189290,
			Name = "PlantBucket"
		},
		{
			Category = "Outdoor Furniture",
			Id = 5480682683,
			Name = "PlantLawnMower"
		},
		{
			Category = "Nature",
			Id = 16101386284,
			Name = "PlantFlowerWhite"
		},
		{
			Category = "Nature",
			Id = 16101386462,
			Name = "PlantFlowerPink"
		},
		{
			Category = "Nature",
			Id = 16101386814,
			Name = "PlantFlowerRed"
		},
		{
			Category = "Nature",
			Id = 16101386631,
			Name = "PlantFlowerPurple"
		},
		{
			Category = "Nature",
			Id = 16018386773,
			Name = "PlantGlassFlowersRed"
		},
		{
			Category = "Nature",
			Name = "FlowerArrangement",
			Item = "FlowerArrangement"
		},
		{
			Category = "Nature",
			Id = 83001906697373,
			Name = "PlantSmall1"
		},
		{
			Category = "Nature",
			Id = 121165175412104,
			Name = "PlantSmall2"
		},
		{
			Category = "Nature",
			Id = 92320005404599,
			Name = "PlantSmall3"
		},
		{
			Category = "Nature",
			Id = 83660962361536,
			Name = "PlantMed1"
		},
		{
			Category = "Nature",
			Id = 140447785480727,
			Name = "PlantMed2"
		},
		{
			Category = "Nature",
			Id = 84608840954226,
			Name = "PlantMed3"
		},
		{
			Category = "Nature",
			Id = 122717724431902,
			Name = "PlantMed4"
		},
		{
			Category = "Nature",
			Id = 91115213350587,
			Name = "PlantMed5"
		},
		{
			Category = "Nature",
			Id = 116451610167520,
			Name = "PlantMed6"
		},
		{
			Category = "Nature",
			Id = 127036620219883,
			Name = "PlantMed7"
		},
		{
			Category = "Nature",
			Id = 71991569089178,
			Name = "PlantLanky"
		},
		{
			Category = "Nature",
			Name = "BonsaiTreeSmallGreen",
			Item = "BonsaiTreeSmallGreen"
		},
		{
			Category = "Nature",
			Name = "BonsaiTreeSmallPink",
			Item = "BonsaiTreeSmallPink"
		},
		{
			Category = "Nature",
			Name = "BonsaiTreeLargeGreen",
			Item = "BonsaiTreeLargeGreen"
		},
		{
			Category = "Nature",
			Name = "BonsaiTreeLargePink",
			Item = "BonsaiTreeLargePink"
		},
		{
			Category = "Nature",
			Name = "BambooPlant",
			Item = "BambooPlant"
		},
		{
			Category = "Nature",
			Id = 76480941980136,
			Name = "CeramicVaseFlower"
		},
		{
			Category = "Nature",
			Id = 119462996697882,
			Name = "CeramicVaseLeaf"
		},
		{
			Category = "Nature",
			Id = 107056813176368,
			Name = "CeramicVaseShrub"
		},
		{
			Category = "Nature",
			Id = 132010922775208,
			Name = "HangingShrub"
		},
		{
			Category = "Nature",
			Id = 16018387418,
			Name = "PlantOutsideSmallBrown"
		},
		{
			Category = "Nature",
			Id = 16246020351,
			Name = "PlantDirtSmall"
		},
		{
			Category = "Nature",
			Id = 16246361411,
			Name = "PlantDirtBig"
		},
		{
			Category = "Nature",
			Id = 16246269937,
			Name = "PlantRockSmall"
		},
		{
			Category = "Nature",
			Id = 16246089174,
			Name = "PlantRockBig"
		},
		{
			Category = "Nature",
			Id = 16018386088,
			Name = "PlantPumkinSmall"
		},
		{
			Category = "Nature",
			Id = 16018386088,
			Name = "PlantPumkinBig"
		},
		{
			Category = "Outdoor Furniture",
			Id = 13463190567,
			Name = "PlantBoxCorn"
		},
		{
			Category = "Nature",
			Id = 16246020734,
			Name = "PlantCornShort"
		},
		{
			Category = "Nature",
			Id = 16246089410,
			Name = "PlantCornLong"
		},
		{
			Category = "Nature",
			Id = 16248925518,
			Name = "PlantCornBox"
		},
		{
			Category = "Nature",
			Id = 16249028270,
			Name = "PlantPumkinBox"
		},
		{
			Category = "Nature",
			Name = "Easter2026FlowerPlanterBox",
			Item = "Easter2026FlowerPlanterBox"
		},
		{
			Category = "Nature",
			Name = "Easter2026Vase",
			Item = "Easter2026Vase"
		},
		{
			Category = "Outdoor Furniture",
			Id = 131572677926937,
			Name = "FeedTrough"
		},
		{
			Category = "Outdoor Furniture",
			Id = 110522352682264,
			Name = "ScarecrowBoy"
		},
		{
			Category = "Outdoor Furniture",
			Id = 119901548328375,
			Name = "ScarecrowGirl"
		},
		{
			Category = "Outdoor Furniture",
			Id = 82987342065924,
			Name = "GardenGnomeBoy"
		},
		{
			Category = "Outdoor Furniture",
			Id = 101666203084731,
			Name = "GardenGnomeGirl"
		},
		{
			Category = "Outdoor Furniture",
			Id = 138925897574919,
			Name = "Weathervane"
		},
		{
			Category = "Nature",
			Item = "Easter2026FlowerHedge",
			Name = "FlowerHedge"
		},
		{
			Category = "Nature",
			Item = "Easter2026ChickHedge",
			Name = "Chick Hedge"
		},
		{
			Category = "Nature",
			Item = "Easter2026BunnyHedge",
			Name = "Bunny Hedge"
		},
		{
			Category = "Nature",
			Item = "Easter2026CarrotPatch",
			Name = "CarrotPatch"
		},
		{
			Category = "Nature",
			Id = 92691338053051,
			Name = "PottedTree"
		},
		{
			Category = "Shapes",
			Id = 15998827491,
			Name = "ShapeStarWhite"
		},
		{
			Category = "Shapes",
			Id = 15998827627,
			Name = "ShapeStarToothpaste"
		},
		{
			Category = "Shapes",
			Id = 15998827850,
			Name = "ShapeStarYellow"
		},
		{
			Category = "Shapes",
			Id = 15998827185,
			Name = "ShapeHeartRed"
		},
		{
			Category = "Shapes",
			Id = 15998827358,
			Name = "ShapeHeartPink"
		},
		{
			Category = "Shapes",
			Id = 16101443648,
			Name = "ShapeMoonWhite"
		},
		{
			Category = "Shapes",
			Id = 16101443868,
			Name = "ShapeMoonYellow"
		},
		{
			Category = "Shapes",
			Id = 15998828272,
			Name = "ShapeArrowBlackLeft"
		},
		{
			Category = "Shapes",
			Id = 15998828487,
			Name = "ShapeArrowBlackRight"
		},
		{
			Category = "Shapes",
			Id = 15998828054,
			Name = "ShapeArrowWhiteLeft"
		},
		{
			Category = "Shapes",
			Id = 15998828625,
			Name = "ShapeArrowWhiteRight"
		},
		{
			Category = "Shapes",
			Id = 116030516425073,
			Name = "ShapeCarRaceStraight"
		},
		{
			Category = "Shapes",
			Id = 104462299965454,
			Name = "ShapeCarRaceRight"
		},
		{
			Category = "Shapes",
			Id = 109611040538939,
			Name = "ShapeCarRaceLeft"
		},
		{
			Category = "Money & Documents",
			Id = 16101444225,
			Name = "MoneyGround"
		},
		{
			Category = "Money & Documents",
			Id = 75670843162039,
			Name = "MoneyBag"
		},
		{
			Category = "Money & Documents",
			Id = 16016114686,
			Name = "MoneyCashOne"
		},
		{
			Category = "Money & Documents",
			Id = 16016114900,
			Name = "MoneyCashThree"
		},
		{
			Category = "Money & Documents",
			Id = 16016114204,
			Name = "MoneyGoldOne"
		},
		{
			Category = "Money & Documents",
			Id = 16016114517,
			Name = "MoneyGoldThree"
		},
		{
			Category = "Money & Documents",
			Id = 16016114374,
			Name = "MoneySafe"
		},
		{
			Category = "Money & Documents",
			Id = 16016114012,
			Name = "MoneyATM"
		},
		{
			Category = "Money & Documents",
			Name = "TinCan",
			Item = "TinCan"
		},
		{
			Category = "Storage",
			Id = 16101207785,
			Name = "BoxOne"
		},
		{
			Category = "Storage",
			Id = 16101207194,
			Name = "BoxShortStraight"
		},
		{
			Category = "Storage",
			Id = 16101207070,
			Name = "BoxHalfWall"
		},
		{
			Category = "Storage",
			Id = 16101206930,
			Name = "BoxRandomSmall"
		},
		{
			Category = "Storage",
			Id = 16101207613,
			Name = "BoxRandomBig"
		},
		{
			Category = "Storage",
			Id = 16101207396,
			Name = "BoxBigWall"
		},
		{
			Category = "Storage",
			Id = 18594527889,
			Name = "BoxCostco"
		},
		{
			Category = "Storage",
			Id = 136970027943581,
			Name = "BoxLockers"
		},
		{
			Category = "Storage",
			Id = 118863421611869,
			Name = "BoxSmallBasket"
		},
		{
			Category = "Storage",
			Id = 86430674889609,
			Name = "BoxModernCreate"
		},
		{
			Category = "Storage",
			Id = 88674535390551,
			Name = "BoxModernCreateBig"
		},
		{
			Category = "Storage",
			Id = 138948830489711,
			Name = "BoxStorageSmall4Shelf"
		},
		{
			Category = "Storage",
			Id = 106303819226897,
			Name = "BoxStorageMed3Shelf"
		},
		{
			Category = "Storage",
			Id = 89140546010932,
			Name = "BoxStorageMed3Shelf1"
		},
		{
			Category = "Storage",
			Id = 71180692289913,
			Name = "BoxCabinet"
		},
		{
			Category = "Storage",
			Id = 116477477777968,
			Name = "BoxStorageLarge3Shelf"
		},
		{
			Category = "Storage",
			Id = 101918963236250,
			Name = "BoxWorkstation"
		},
		{
			Category = "Storage",
			Id = 81347318960430,
			Name = "BoxConveyor"
		},
		{
			Category = "Storage",
			Id = 100014542910339,
			Name = "BoxWorkstationLarge"
		},
		{
			Category = "Decor",
			Id = 16276542347,
			Name = "AwardTrophy"
		},
		{
			Category = "Decor",
			Id = 16246133402,
			Name = "AwardYoutubeSilver"
		},
		{
			Category = "Decor",
			Id = 16248835244,
			Name = "AwardYouTubeGold"
		},
		{
			Category = "Fence",
			Id = 15998676559,
			Name = "TapeDONOTCROSS"
		},
		{
			Category = "Fence",
			Id = 15998676157,
			Name = "TapeCRIMESCENE"
		},
		{
			Category = "Fence",
			Id = 15998676350,
			Name = "TapeUNDERCONSTRUCTION"
		},
		{
			Category = "Fence",
			Id = 15998675784,
			Name = "TapeCAUTION"
		},
		{
			Category = "Fence",
			Id = 15998676762,
			Name = "TapeWARNING"
		},
		{
			Category = "Fence",
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
			Category = "Hazardous",
			Id = 16246361602,
			Name = "BarrelYellow"
		},
		{
			Category = "Hazardous",
			Id = 16246316037,
			Name = "BarrelGreen"
		},
		{
			Category = "Hazardous",
			Id = 16246269693,
			Name = "BarrelRed"
		},
		{
			Category = "Hazardous",
			Id = 16248975086,
			Name = "BarrelBlue"
		},
		{
			Category = "Hazardous",
			Id = 113715740940230,
			Name = "NuclearWasteBarrel"
		},
		{
			Category = "Hazardous",
			Id = 83023611213507,
			Name = "WaterValve"
		},
		{
			Category = "Hazardous",
			Id = 125437304431354,
			Name = "PlantPowerSwitch"
		},
		{
			Category = "Hazardous",
			Id = 74433534250062,
			Name = "BigGenerator"
		},
		{
			Category = "Hazardous",
			Id = 80501436010590,
			Name = "HazmatSuitWearable"
		},
		{
			Category = "Hazardous",
			Id = 78465536927807,
			Name = "PowerTurbine"
		},
		{
			Category = "Spooky",
			Id = 16248975559,
			Name = "PowerBallBlue"
		},
		{
			Category = "Spooky",
			Id = 16248925962,
			Name = "PowerWhiteCube"
		},
		{
			Category = "Spooky",
			Id = 16246270975,
			Name = "PowerGoldCube"
		},
		{
			Category = "Spooky",
			Id = 111499618598477,
			Name = "Incubator"
		},
		{
			Category = "Military",
			Id = 87867217309505,
			Name = "PowerRockSword"
		},
		{
			Category = "Money & Documents",
			Id = 74867220406043,
			Name = "GoldPile01"
		},
		{
			Category = "Money & Documents",
			Id = 103661122000135,
			Name = "GoldPile03"
		},
		{
			Category = "Money & Documents",
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
			Category = "Tech",
			Id = 101867416997761,
			Name = "Phone"
		},
		{
			Category = "Tech",
			Id = 90160277045170,
			Name = "Tablet"
		},
		{
			Category = "Tech",
			Id = 129323410985415,
			Name = "ScreensPhoneChargerBlack"
		},
		{
			Category = "Tech",
			Id = 123145061676183,
			Name = "ScreensPhoneChargerPink"
		},
		{
			Category = "Tech",
			Id = 90256442150840,
			Name = "ScreensPhoneStand"
		},
		{
			Category = "Tech",
			Id = 92919099040975,
			Name = "ScreensTabletChargerBlack"
		},
		{
			Category = "Tech",
			Id = 133312841358156,
			Name = "ScreensTabletChargerPink"
		},
		{
			Category = "Tech",
			Id = 115543702669201,
			Name = "ScreensMouse"
		},
		{
			Category = "Tech",
			Id = 108930524228118,
			Name = "ScreensKeyBoard"
		},
		{
			Category = "Tech",
			Id = 105485792978074,
			Name = "ScreensLaptop"
		},
		{
			Category = "Tech",
			Id = 88226277712231,
			Name = "ScreensConsole1"
		},
		{
			Category = "Tech",
			Id = 74076662436365,
			Name = "ScreensConsole2"
		},
		{
			Category = "Tech",
			Id = 72726195662052,
			Name = "RetroConsole"
		},
		{
			Category = "Tech",
			Id = 138360642699791,
			Name = "DeskFan"
		},
		{
			Category = "Tech",
			Id = 92626805413713,
			Name = "PortableHeater"
		},
		{
			Category = "Tech",
			Id = 8779427352,
			Name = "ScreensGhostDetector"
		},
		{
			Category = "Tech",
			Id = 137157302591039,
			Name = "ScreensGhostCatcher"
		},
		{
			Category = "Tech",
			Id = 79605161273443,
			Name = "ScreensRadio"
		},
		{
			Category = "Tech",
			Id = 4622190558,
			Name = "ScreensMicSmall"
		},
		{
			Category = "Tech",
			Id = 16019402739,
			Name = "ScreensMicrophone"
		},
		{
			Category = "Tech",
			Id = 81679494931414,
			Name = "ScreensStandMic"
		},
		{
			Category = "Tech",
			Id = 16896544025,
			Name = "ScreensMicBoom"
		},
		{
			Category = "Tech",
			Id = 4529167642,
			Name = "ScreensCamera"
		},
		{
			Category = "Tech",
			Id = 16019402864,
			Name = "ScreensMovieCamera"
		},
		{
			Category = "Tech",
			Id = 120984509689255,
			Name = "CRTTV"
		},
		{
			Category = "Tech",
			Id = 91166894523566,
			Name = "ScreensTVSmall"
		},
		{
			Category = "Tech",
			Id = 96378387791216,
			Name = "ScreensTVBig"
		},
		{
			Category = "Tech",
			Id = 16246091726,
			Name = "ScreensGreenScreen"
		},
		{
			Category = "Tech",
			Id = 16000010426,
			Name = "ScreensGamingDesk"
		},
		{
			Category = "Tech",
			Id = 16000010234,
			Name = "ScreensPCDesk"
		},
		{
			Category = "Tech",
			Id = 70948636775597,
			Name = "ScreensBigSpeakers"
		},
		{
			Category = "Tech",
			Id = 16249028441,
			Name = "ScreensServer"
		},
		{
			Category = "Tech",
			Id = 16246134767,
			Name = "ScreensServerOldSchool"
		},
		{
			Category = "Tech",
			Id = 113700090456701,
			Name = "ScreensHugeServer"
		},
		{
			Category = "Tech",
			Id = 83185414383709,
			Name = "ScreensArcadeOrange"
		},
		{
			Category = "Tech",
			Id = 84280596680680,
			Name = "ScreensArcadeBlue"
		},
		{
			Category = "Tech",
			Id = 88490440756060,
			Name = "ScreensArcadeRed"
		},
		{
			Category = "Tech",
			Id = 118968826445135,
			Name = "ScreensArcadeToothpaste"
		},
		{
			Category = "Tech",
			Id = 93599614733933,
			Name = "ScreensArcadeGreen"
		},
		{
			Category = "Tech",
			Id = 130660818502675,
			Name = "DanceMachineCouple"
		},
		{
			Category = "Tech",
			Id = 72250057616043,
			Name = "ClawMachine"
		},
		{
			Category = "Tech",
			Id = 78462009607751,
			Name = "ArcadeBikeYellow"
		},
		{
			Category = "Tech",
			Id = 73070075391349,
			Name = "ArcadeBikeBlue"
		},
		{
			Category = "Tech",
			Id = 135345634167814,
			Name = "ScreensRobotMedium"
		},
		{
			Category = "Tech",
			Id = 78868630138144,
			Name = "ScreensRobotBig"
		},
		{
			Category = "Tech",
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
			Category = "Holiday",
			Id = 113433027227194,
			Name = "LeafPile"
		},
		{
			Category = "Holiday",
			Id = 138054200255690,
			Name = "CornStalk"
		},
		{
			Category = "Holiday",
			Id = 75906173842740,
			Name = "AutumnWreath"
		},
		{
			Category = "Holiday",
			Id = 123792368510082,
			Name = "Cornucopia"
		},
		{
			Category = "Holiday",
			Id = 118765716610614,
			Name = "MiniCornucopia"
		},
		{
			Category = "Holiday",
			Id = 131139366884182,
			Name = "ThanksgivingPumpkins"
		},
		{
			Category = "Holiday",
			Id = 118082144451369,
			Name = "ThanksgivingShelf"
		},
		{
			Category = "Holiday",
			Id = 113852293811851,
			Name = "ThanksgivingStandingShelf"
		},
		{
			Category = "Holiday",
			Id = 114311730066228,
			Name = "ThanksgivingWheelbarrow"
		},
		{
			Category = "Holiday",
			Id = 101741275572761,
			Name = "WallLeaves"
		},
		{
			Category = "Holiday",
			Id = 124573258659929,
			Name = "ClassicTurkey",
			Item = "ClassicTurkey"
		},
		{
			Category = "Holiday",
			Id = 102874983910303,
			Name = "CriminalTurkey",
			Item = "CriminalTurkey"
		},
		{
			Category = "Holiday",
			Id = 138569493031387,
			Name = "AgentTurkey",
			Item = "AgentTurkey"
		},
		{
			Category = "Holiday",
			Id = 93261586648483,
			Name = "PilgrimTurkey",
			Item = "PilgrimTurkey"
		},
		{
			Category = "Holiday",
			Id = 128464810280593,
			Name = "PoliceTurkey",
			Item = "PoliceTurkey"
		},
		{
			Category = "Holiday",
			Id = 90517580119387,
			Name = "DoctorTurkey",
			Item = "DoctorTurkey"
		},
		{
			Category = "Holiday",
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
			Category = "Lights",
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
			Category = "Decor",
			Id = 72992307596953,
			Name = "LuxuryCoffeeMaker"
		},
		{
			Category = "Decor",
			Id = 92975090225782,
			Name = "LuxuryMixer"
		},
		{
			Category = "Furniture",
			Id = 86062539414145,
			Name = "LuxuryWaterfall"
		},
		{
			Category = "Decor",
			Id = 91455752414679,
			Name = "PersonalBlender"
		},
		{
			Category = "Decor",
			Id = 103098333913166,
			Name = "SmallDecoration2"
		},
		{
			Category = "Decor",
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
			Category = "Decor",
			Id = 125785081961153,
			Name = "CoffeePot"
		},
		{
			Category = "Building Basics",
			Id = 123200327305638,
			Name = "Block1"
		},
		{
			Category = "Building Basics",
			Id = 78213748482539,
			Name = "Block2"
		},
		{
			Category = "Building Basics",
			Id = 129482066319056,
			Name = "Block3"
		},
		{
			Category = "Building Basics",
			Id = 92756842297663,
			Name = "Wall"
		},
		{
			Category = "Building Basics",
			Id = 95379728698190,
			Name = "HalfWall"
		},
		{
			Category = "Building Basics",
			Id = 86940942137471,
			Name = "HalfWall2"
		},
		{
			Category = "Building Basics",
			Id = 96557397242488,
			Name = "SideDoorWall"
		},
		{
			Category = "Building Basics",
			Id = 136071115553040,
			Name = "SideDoorWallEmpty"
		},
		{
			Category = "Building Basics",
			Id = 128119193854978,
			Name = "CenterDoorWall"
		},
		{
			Category = "Building Basics",
			Id = 134355600914343,
			Name = "CenterDoorWallEmpty"
		},
		{
			Category = "Building Basics",
			Id = 78334575579523,
			Name = "SingleWindowWall"
		},
		{
			Category = "Building Basics",
			Id = 125384119395112,
			Name = "SingleWindowWallEmpty"
		},
		{
			Category = "Building Basics",
			Id = 130577041220423,
			Name = "DoubleWindowWall"
		},
		{
			Category = "Building Basics",
			Id = 102098419080459,
			Name = "DoubleWindowWallEmpty"
		},
		{
			Category = "Building Basics",
			Id = 126036046294100,
			Name = "FullWindow"
		},
		{
			Category = "Building Basics",
			Id = 135202745590728,
			Name = "SmallWindow"
		},
		{
			Category = "Building Basics",
			Id = 100797721584238,
			Name = "GlassFull"
		},
		{
			Category = "Building Basics",
			Id = 121469171464528,
			Name = "GlassHalf"
		},
		{
			Category = "Building Basics",
			Id = 132746576151562,
			Name = "DoorFrame"
		},
		{
			Category = "Building Basics",
			Id = 80079449787809,
			Name = "RegularDoor"
		},
		{
			Category = "Building Basics",
			Id = 110136698929875,
			Name = "JailBars"
		},
		{
			Category = "Building Basics",
			Id = 114821632417107,
			Name = "JailDoor"
		},
		{
			Category = "Building Basics",
			Id = 72065412065226,
			Name = "Floor"
		},
		{
			Category = "Building Basics",
			Id = 96446321221301,
			Name = "HalfFloor"
		},
		{
			Category = "Building Basics",
			Id = 89576618010011,
			Name = "QuarterFloor"
		},
		{
			Category = "Building Basics",
			Id = 96449284111233,
			Name = "FloorCorner1"
		},
		{
			Category = "Building Basics",
			Id = 122225893596022,
			Name = "FloorCorner2"
		},
		{
			Category = "Building Basics",
			Id = 82318671098606,
			Name = "FloorCorner2Half"
		},
		{
			Category = "Building Basics",
			Id = 93359905425105,
			Name = "FloorCorner2Quarter"
		},
		{
			Category = "Building Basics",
			Id = 114117450440067,
			Name = "FloorCornerHalf"
		},
		{
			Category = "Building Basics",
			Id = 80302114689822,
			Name = "FloorCornerQuarter"
		},
		{
			Category = "Building Basics",
			Id = 107824494910887,
			Name = "WedgeSmall"
		},
		{
			Category = "Building Basics",
			Id = 107647034963644,
			Name = "WedgeMedium"
		},
		{
			Category = "Building Basics",
			Id = 132312793104553,
			Name = "WedgeLarge"
		},
		{
			Category = "Building Basics",
			Id = 120242734853586,
			Name = "CornerWedgeSmall"
		},
		{
			Category = "Building Basics",
			Id = 83117596738773,
			Name = "CornerWedgeMedium"
		},
		{
			Category = "Building Basics",
			Id = 118237416180367,
			Name = "CornerWedgeLarge"
		},
		{
			Category = "Building Basics",
			Id = 84603989172064,
			Name = "VerticalWedgeSmall"
		},
		{
			Category = "Building Basics",
			Id = 107365336977207,
			Name = "InvertedWedgeSmall"
		},
		{
			Category = "Building Basics",
			Id = 115977803697145,
			Name = "Cylinder"
		},
		{
			Category = "Building Basics",
			Id = 84404648682804,
			Name = "FlatCylinder"
		},
		{
			Category = "Building Basics",
			Id = 107715703101899,
			Name = "ThinCylinder"
		},
		{
			Category = "Building Basics",
			Id = 81847950491085,
			Name = "Cone"
		},
		{
			Category = "Building Basics",
			Id = 74800088912256,
			Name = "PillarSmall"
		},
		{
			Category = "Building Basics",
			Id = 106957275791499,
			Name = "PillarLarge"
		},
		{
			Category = "Building Basics",
			Id = 94265636343431,
			Name = "CylinderPillarSmall"
		},
		{
			Category = "Building Basics",
			Id = 119878180855928,
			Name = "CylinderPillarLarge"
		},
		{
			Category = "Building Basics",
			Id = 79413674094846,
			Name = "SmallArch"
		},
		{
			Category = "Building Basics",
			Id = 101005490896067,
			Name = "FullArch"
		},
		{
			Category = "Building Basics",
			Id = 133977173049176,
			Name = "LargeArch"
		},
		{
			Category = "Building Basics",
			Id = 93533821254035,
			Name = "SmallStairs"
		},
		{
			Category = "Building Basics",
			Id = 108748761041635,
			Name = "Stairs"
		},
		{
			Category = "Building Basics",
			Id = 85310304918381,
			Name = "SlopedStairs"
		},
		{
			Category = "Building Basics",
			Id = 115340971040323,
			Name = "WoodFenceShort"
		},
		{
			Category = "Building Basics",
			Id = 95402823960060,
			Name = "WoodFenceTall"
		},
		{
			Category = "Building Basics",
			Id = 83027167378521,
			Name = "FenceDoorShort"
		},
		{
			Category = "Building Basics",
			Id = 102364832369603,
			Name = "FenceDoor"
		},
		{
			Category = "Building Basics",
			Id = 126901669845117,
			Name = "HedgeRoundLow"
		},
		{
			Category = "Building Basics",
			Id = 98805183305768,
			Name = "HedgeRoundLowThick"
		},
		{
			Category = "Building Basics",
			Id = 72885700659964,
			Name = "HedgeRoundTall"
		},
		{
			Category = "Building Basics",
			Id = 93014625634114,
			Name = "HedgeRoundTallThick"
		},
		{
			Category = "Building Basics",
			Id = 70527098395576,
			Name = "Edge"
		},
		{
			Category = "Building Basics",
			Id = 115817449315313,
			Name = "EdgeHalf"
		},
		{
			Category = "Building Basics",
			Id = 139245120962348,
			Name = "Light"
		},
		{
			Category = "Building Basics",
			Id = 134910476909417,
			Name = "PotLight"
		},
		{
			Category = "Building Basics",
			Id = 101196438968956,
			Name = "SmallPyramid"
		},
		{
			Category = "Building Basics",
			Id = 89927666385518,
			Name = "Pyramid"
		}
	},
	GetTemplate = function(instance, p)
		if p.IsCategory == true then
			return instance:FindFirstChild("CategoryTemplate")
		end

		return nil
	end,
	Setup = function(instance, data)
		if data.ThemeImage then
			local propTheme = instance:FindFirstChild("PropTheme")

			if propTheme ~= nil and propTheme:IsA("ImageLabel") then
				propTheme.Visible = true
				propTheme.Image = data.ThemeImage
			end
		end

		if data.PropVIP then
			local propVIP = instance:FindFirstChild("PropVIP")

			if propVIP ~= nil and propVIP:IsA("GuiObject") then
				propVIP.Visible = true
			end
		end

		if data.IsCategory and data.Name == "Building Basics" then
			local propCollision = instance:FindFirstChild("PropCollision")

			if propCollision ~= nil then
				propCollision.Visible = true
			end
		end

		instance.Name = data.Name

		if data.IsCategory == true then
			local title = instance:FindFirstChild("Title")

			if title ~= nil and title:IsA("TextLabel") then
				title.Text = data.Name
			end
		end

		local icon = instance:FindFirstChild("Icon")

		if icon ~= nil and icon:IsA("ImageLabel") and data.Id ~= nil then
			icon.Image = "rbxassetid://" .. data.Id
		end
	end,
	IsGamepass = function(p)
		return p.PropVIP == true or p.PassRequired ~= nil
	end
}

function Props.FilterEntryValues(data)
	local breadcrumbsFilter = data.BreadcrumbsFilter
	local entries = {}

	for _, entry in Props.Entries do
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

function Props.GetRenderContext()
	return ItemRenderer.PROPS_CONTEXT
end

return Props