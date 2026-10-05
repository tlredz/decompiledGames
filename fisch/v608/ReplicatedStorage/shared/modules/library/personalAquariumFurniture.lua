local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sharedPersonalAquarium = ReplicatedStorage.shared.modules.SharedPersonalAquarium
require(sharedPersonalAquarium.SharedTypes)
local PersonalAquariumFurniture = {
	["Divine Trophy: Bellona"] = {
		DisplayName = "Divine Trophy: Bellona",
		Icon = "rbxassetid://109710288383114",
		Recolorable = false
	},
	["Divine Trophy: Apollo"] = {
		DisplayName = "Divine Trophy: Apollo",
		Icon = "rbxassetid://127896179707940",
		Recolorable = false
	},
	["Divine Trophy: Poseidon"] = {
		DisplayName = "Divine Trophy: Poseidon",
		Icon = "rbxassetid://121127972394213",
		Recolorable = false
	},
	["Divine Trophy: Zeus"] = {
		DisplayName = "Divine Trophy: Zeus",
		Icon = "rbxassetid://130027554151835",
		Recolorable = false
	},
	["Divine Trophy: Hades"] = {
		DisplayName = "Divine Trophy: Hades",
		Icon = "rbxassetid://97731187311696",
		Recolorable = false
	},
	Bonfire = {
		DisplayName = "Bonfire",
		Icon = "rbxassetid://120188545643210",
		Recolorable = false
	},
	["Arcade Machine"] = {
		DisplayName = "Arcade Machine",
		Icon = "rbxassetid://140633444850553",
		Recolorable = false
	},
	["Volleyball Net"] = {
		DisplayName = "Volleyball Net",
		Icon = "rbxassetid://113095930940251",
		Recolorable = false
	},
	["Beach Chair"] = {
		DisplayName = "Beach Chair",
		Icon = "rbxassetid://120237495742913",
		Recolorable = false
	},
	["Sand Castle"] = {
		DisplayName = "Sand Castle",
		Icon = "rbxassetid://132561383032096",
		Recolorable = false
	},
	Chair = {
		DisplayName = "Chair",
		Icon = "rbxassetid://87261825965257",
		Recolorable = true
	},
	Couch = {
		DisplayName = "Couch",
		Icon = "rbxassetid://120306382704574",
		Recolorable = true
	},
	Bench = {
		DisplayName = "Bench",
		Icon = "rbxassetid://122220590110091",
		Recolorable = true
	},
	Plant = {
		DisplayName = "Plant",
		Icon = "rbxassetid://131292567625240",
		Recolorable = true
	},
	["CRT TV"] = {
		DisplayName = "CRT TV",
		Icon = "rbxassetid://136757746165809",
		Recolorable = true
	},
	["Low Coffee Table 1"] = {
		DisplayName = "Low Coffee Table 1",
		Icon = "rbxassetid://115628492530748",
		Recolorable = true
	},
	["Low Coffee Table 2"] = {
		DisplayName = "Low Coffee Table 2",
		Icon = "rbxassetid://102648980098077",
		Recolorable = true
	},
	["Low Coffee Table 3"] = {
		DisplayName = "Low Coffee Table 3",
		Icon = "rbxassetid://112809038913536",
		Recolorable = true
	},
	["Bookshelf 1"] = {
		DisplayName = "Bookshelf 1",
		Icon = "rbxassetid://82223767461682",
		Recolorable = true
	},
	["Bookshelf 2"] = {
		DisplayName = "Bookshelf 2",
		Icon = "rbxassetid://126045638229054",
		Recolorable = true
	},
	["Bookshelf 3"] = {
		DisplayName = "Bookshelf 3",
		Icon = "rbxassetid://102963951421325",
		Recolorable = true
	},
	["Record Player 1"] = {
		DisplayName = "Record Player 1",
		Icon = "rbxassetid://118139099021560",
		Recolorable = true
	},
	["Record Player 2"] = {
		DisplayName = "Record Player 2",
		Icon = "rbxassetid://129134080409807",
		Recolorable = true
	},
	["Vinyl Stack 1"] = {
		DisplayName = "Vinyl Stack 1",
		Icon = "rbxassetid://131385585885796",
		Recolorable = false
	},
	["Vinyl Stack 2"] = {
		DisplayName = "Vinyl Stack 2",
		Icon = "rbxassetid://88637274141826",
		Recolorable = false
	},
	["Vinyl Stack 3"] = {
		DisplayName = "Vinyl Stack 3",
		Icon = "rbxassetid://113267865974745",
		Recolorable = false
	},
	["Mini Fridge 1"] = {
		DisplayName = "Mini Fridge 1",
		Icon = "rbxassetid://98695714460257",
		Recolorable = true
	},
	["Mini Fridge 2"] = {
		DisplayName = "Mini Fridge 2",
		Icon = "rbxassetid://108435109595352",
		Recolorable = true
	},
	["Mini Fridge 3"] = {
		DisplayName = "Mini Fridge 3",
		Icon = "rbxassetid://85323130254090",
		Recolorable = true
	},
	["Blue Bubble Tube Lamp"] = {
		DisplayName = "Blue Bubble Tube Lamp",
		Icon = "rbxassetid://123651224314555",
		Recolorable = true
	},
	["Purple Bubble Tube Lamp"] = {
		DisplayName = "Purple Bubble Tube Lamp",
		Icon = "rbxassetid://133047141992494",
		Recolorable = true
	},
	["Red Bubble Tube Lamp"] = {
		DisplayName = "Red Bubble Tube Lamp",
		Icon = "rbxassetid://132661368298774",
		Recolorable = true
	},
	["LED Strip Blue"] = {
		DisplayName = "LED Strip Blue",
		Icon = "rbxassetid://122929548800810",
		Recolorable = true
	},
	["LED Strip Purple"] = {
		DisplayName = "LED Strip Purple",
		Icon = "rbxassetid://91242076672791",
		Recolorable = true
	},
	["LED Strip Red"] = {
		DisplayName = "LED Strip Red",
		Icon = "rbxassetid://86706933665737",
		Recolorable = true
	},
	["Lava Lamp"] = {
		DisplayName = "Lava Lamp",
		Icon = "rbxassetid://122694977182713",
		Recolorable = true
	},
	["Cloud Neon Sign"] = {
		DisplayName = "Cloud Neon Sign",
		Icon = "rbxassetid://98040821950096",
		Recolorable = true
	},
	["Logo Neon Sign"] = {
		DisplayName = "Logo Neon Sign",
		Icon = "rbxassetid://96221816168362",
		Recolorable = true
	},
	["Wave Neon Sign"] = {
		DisplayName = "Wave Neon Sign",
		Icon = "rbxassetid://94729927169872",
		Recolorable = true
	},
	["Terrarium 1"] = {
		DisplayName = "Terrarium 1",
		Icon = "rbxassetid://140138532153613",
		Recolorable = true
	},
	["Terrarium 2"] = {
		DisplayName = "Terrarium 2",
		Icon = "rbxassetid://91477166776930",
		Recolorable = true
	},
	["Terrarium 3"] = {
		DisplayName = "Terrarium 3",
		Icon = "rbxassetid://139738847530674",
		Recolorable = true
	},
	["Soft Ambient Lantern 1"] = {
		DisplayName = "Soft Ambient Lantern 1",
		Icon = "rbxassetid://132025576175723",
		Recolorable = true
	},
	["Soft Ambient Lantern 2"] = {
		DisplayName = "Soft Ambient Lantern 2",
		Icon = "rbxassetid://85440326869899",
		Recolorable = true
	},
	["Soft Ambient Lantern 3"] = {
		DisplayName = "Soft Ambient Lantern 3",
		Icon = "rbxassetid://81273441793668",
		Recolorable = true
	},
	["Digital Clock 1"] = {
		DisplayName = "Digital Clock 1",
		Icon = "rbxassetid://73439782386172",
		Recolorable = true
	},
	["Digital Clock 2"] = {
		DisplayName = "Digital Clock 2",
		Icon = "rbxassetid://100550852089069",
		Recolorable = true
	},
	["Cat Tower 1"] = {
		DisplayName = "Cat Tower 1",
		Icon = "rbxassetid://87961790756251",
		Recolorable = true
	},
	["Cat Tower 2"] = {
		DisplayName = "Cat Tower 2",
		Icon = "rbxassetid://122159599268640",
		Recolorable = true
	},
	["Cat Tower 3"] = {
		DisplayName = "Cat Tower 3",
		Icon = "rbxassetid://106956475190053",
		Recolorable = true
	},
	["Floating Shelf 1"] = {
		DisplayName = "Floating Shelf 1",
		Icon = "rbxassetid://89638955603829",
		Recolorable = true
	},
	["Floating Shelf 2"] = {
		DisplayName = "Floating Shelf 2",
		Icon = "rbxassetid://78553068549572",
		Recolorable = true
	},
	["Floating Shelf 3"] = {
		DisplayName = "Floating Shelf 3",
		Icon = "rbxassetid://130388952586907",
		Recolorable = true
	},
	["Surfboard 1"] = {
		DisplayName = "Surfboard 1",
		Icon = "rbxassetid://118630165234277",
		Recolorable = true
	},
	["Surfboard 2"] = {
		DisplayName = "Surfboard 2",
		Icon = "rbxassetid://90274498773554",
		Recolorable = true
	},
	["Surfboard 3"] = {
		DisplayName = "Surfboard 3",
		Icon = "rbxassetid://71597740836026",
		Recolorable = true
	},
	["Shoe Rack 1"] = {
		DisplayName = "Shoe Rack 1",
		Icon = "rbxassetid://132973664908259",
		Recolorable = true
	},
	["Shoe Rack 2"] = {
		DisplayName = "Shoe Rack 2",
		Icon = "rbxassetid://130371971662548",
		Recolorable = true
	},
	["Shoe Rack 3"] = {
		DisplayName = "Shoe Rack 3",
		Icon = "rbxassetid://95596107135508",
		Recolorable = true
	},
	Longboard = {
		DisplayName = "Longboard",
		Icon = "rbxassetid://102949473859711",
		Recolorable = true
	},
	Pennyboard = {
		DisplayName = "Pennyboard",
		Icon = "rbxassetid://135336247043830",
		Recolorable = true
	},
	Skateboard = {
		DisplayName = "Skateboard",
		Icon = "rbxassetid://98845563225347",
		Recolorable = true
	},
	["Yoga Mat"] = {
		DisplayName = "Yoga Mat",
		Icon = "rbxassetid://94096619712799",
		Recolorable = true
	},
	["Rolled Up Yoga Mat"] = {
		DisplayName = "Rolled Up Yoga Mat",
		Icon = "rbxassetid://102991126003326",
		Recolorable = true
	},
	["Foosball Table"] = {
		DisplayName = "Foosball Table",
		Icon = "rbxassetid://83111117387837",
		Recolorable = true
	},
	["Pool Table"] = {
		DisplayName = "Pool Table",
		Icon = "rbxassetid://137659332585656",
		Recolorable = true
	},
	["Dart Board"] = {
		DisplayName = "Dart Board",
		Icon = "rbxassetid://72466874192233",
		Recolorable = true
	},
	["Board Game Table"] = {
		DisplayName = "Board Game Table",
		Icon = "rbxassetid://117050682324972",
		Recolorable = true
	},
	["Water Dispenser 1"] = {
		DisplayName = "Water Dispenser 1",
		Icon = "rbxassetid://85931775757371",
		Recolorable = true
	},
	["Water Dispenser 2"] = {
		DisplayName = "Water Dispenser 2",
		Icon = "rbxassetid://72242523792627",
		Recolorable = true
	},
	["Water Dispenser 3"] = {
		DisplayName = "Water Dispenser 3",
		Icon = "rbxassetid://103538176540228",
		Recolorable = true
	},
	["Vending Machine 1"] = {
		DisplayName = "Vending Machine 1",
		Icon = "rbxassetid://98429976552949",
		Recolorable = true
	},
	["Vending Machine 2"] = {
		DisplayName = "Vending Machine 2",
		Icon = "rbxassetid://78030244057658",
		Recolorable = true
	},
	["Gumball Machine"] = {
		DisplayName = "Gumball Machine",
		Icon = "rbxassetid://136048835365726",
		Recolorable = true
	},
	["Japanese Partitions 1"] = {
		DisplayName = "Japanese Partitions 1",
		Icon = "rbxassetid://128676024227760",
		Recolorable = true
	},
	["Japanese Partitions 2"] = {
		DisplayName = "Japanese Partitions 2",
		Icon = "rbxassetid://72425255234720",
		Recolorable = true
	},
	["Japanese Partitions 3"] = {
		DisplayName = "Japanese Partitions 3",
		Icon = "rbxassetid://120426861032687",
		Recolorable = true
	},
	["Stereo Speaker System 1"] = {
		DisplayName = "Stereo Speaker System 1",
		Icon = "rbxassetid://105123000990422",
		Recolorable = true
	},
	["Stereo Speaker System 2"] = {
		DisplayName = "Stereo Speaker System 2",
		Icon = "rbxassetid://79841885208680",
		Recolorable = true
	},
	["Stereo Speaker System 3"] = {
		DisplayName = "Stereo Speaker System 3",
		Icon = "rbxassetid://127068831556472",
		Recolorable = true
	},
	["Poster 1"] = {
		DisplayName = "Poster 1",
		Icon = "rbxassetid://110359213281302",
		Recolorable = false
	},
	["Poster 2"] = {
		DisplayName = "Poster 2",
		Icon = "rbxassetid://78766307068416",
		Recolorable = false
	},
	["Poster 3"] = {
		DisplayName = "Poster 3",
		Icon = "rbxassetid://111595151537358",
		Recolorable = false
	},
	["Polaroid Photo Wall 1"] = {
		DisplayName = "Polaroid Photo Wall 1",
		Icon = "rbxassetid://114172385887409",
		Recolorable = true
	},
	["Polaroid Photo Wall 2"] = {
		DisplayName = "Polaroid Photo Wall 2",
		Icon = "rbxassetid://105747423256304",
		Recolorable = true
	},
	["Polaroid Photo Wall 3"] = {
		DisplayName = "Polaroid Photo Wall 3",
		Icon = "rbxassetid://72123679508192",
		Recolorable = true
	},
	["Art Easel 1"] = {
		DisplayName = "Art Easel 1",
		Icon = "rbxassetid://139267524024197",
		Recolorable = true
	},
	["Art Easel 2"] = {
		DisplayName = "Art Easel 2",
		Icon = "rbxassetid://126266291632394",
		Recolorable = true
	},
	["Art Easel 3"] = {
		DisplayName = "Art Easel 3",
		Icon = "rbxassetid://121404432122385",
		Recolorable = true
	},
	["Paint Shelf"] = {
		DisplayName = "Paint Shelf",
		Icon = "rbxassetid://101184905356329",
		Recolorable = true
	},
	["Guitar Mount 1"] = {
		DisplayName = "Guitar Mount 1",
		Icon = "rbxassetid://110259797227947",
		Recolorable = true
	},
	["Guitar Mount 2"] = {
		DisplayName = "Guitar Mount 2",
		Icon = "rbxassetid://108646929563350",
		Recolorable = true
	},
	["Guitar Mount 3"] = {
		DisplayName = "Guitar Mount 3",
		Icon = "rbxassetid://87979478628206",
		Recolorable = true
	},
	["Wet Floor Sign"] = {
		DisplayName = "Wet Floor Sign",
		Icon = "rbxassetid://105012495567121",
		Recolorable = true
	},
	["Rolling Chair"] = {
		DisplayName = "Rolling Chair",
		Icon = "rbxassetid://96432821549014",
		Recolorable = true
	},
	["Wall Clock"] = {
		DisplayName = "Wall Clock",
		Icon = "rbxassetid://134409427059770",
		Recolorable = true
	},
	["Seasonal Clock"] = {
		DisplayName = "Seasonal Clock",
		Icon = "rbxassetid://95845267979482",
		Recolorable = true
	},
	["Air Hockey Table"] = {
		DisplayName = "Air Hockey Table",
		Icon = "rbxassetid://99466442204051",
		Recolorable = true
	},
	["Pet Bed 1"] = {
		DisplayName = "Pet Bed 1",
		Icon = "rbxassetid://119439283755141",
		Recolorable = true
	},
	["Pet Bed 2"] = {
		DisplayName = "Pet Bed 2",
		Icon = "rbxassetid://78642057285705",
		Recolorable = true
	},
	["Gaming Setup 1"] = {
		DisplayName = "Gaming Setup 1",
		Icon = "rbxassetid://83726558245312",
		Recolorable = true
	},
	["Gaming Setup 2"] = {
		DisplayName = "Gaming Setup 2",
		Icon = "rbxassetid://117819319271560",
		Recolorable = true
	},
	["Gaming Setup 3"] = {
		DisplayName = "Gaming Setup 3",
		Icon = "rbxassetid://105976712880641",
		Recolorable = true
	}
}
local CrewStatueRewards = require(ReplicatedStorage.shared.modules.CrewStatueRewards)
CrewStatueRewards.addFurniture(PersonalAquariumFurniture)
return PersonalAquariumFurniture