local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PersonalityCatalog = require(script.PersonalityCatalog)
local Rarity = require(ReplicatedStorage.Data.Rarity)
require(script.Types)

local function makeAnimation(animationId: string)
	local animation = Instance.new("Animation")

	local function setAnimationId()
		animation.AnimationId = animationId
	end

	if not pcall(setAnimationId) then
		warn((`Animation {animationId} is not shared with this experience`))
	end

	return animation
end

ReplicatedStorage = table.freeze
local v = {
	_id = nil,
	DisplayName = "Assets",
	Icon = nil,
	Egg = table.freeze({
		DisplayName = "Assets",
		Icon = "rbxassetid://116524274262912",
		ModelName = nil,
		GrowthTime = 60,
		WeightKg = 80,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 1,
	IndexSpeedReward = 0,
	DropWeight = 1,
	VisualOdds = 1,
	ModelWeight = 80,
	Animations = 0,
	WalkAnimationReferenceSpeed = nil,
	Rarity = 0,
	BaseModelScale = 1,
	LimitedEggViewportScale = 1,
	LimitedEggViewportVerticalOffset = 0,
	BaseModelColor = 0,
	PossibleModelColors = 0,
	PlaceSound = nil,
	WalkSound = nil,
	RandomIdleSound = nil,
	LuckyBlockDropTable = nil,
	LuckyBlockDropTableType = nil,
	LuckyBlockLevelRange = nil,
	LuckyBlockOpenDuration = nil,
	DontRoll = nil,
	CannotFuse = nil,
	GenderLocked = nil,
	AlbinosColorFullWhite = nil
}
local freeze = table.freeze
local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://122342179426051"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://122342179426051 is not shared with this experience")
end

v.Animations = freeze({
	Idle = animation,
	Walk = nil,
	TransitionFadeDuration = nil
})
v.Rarity = Rarity.Rarities.Common
v.BaseModelColor = Color3.fromRGB(86, 160, 61)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.fromRGB(86, 160, 61), 1 }),
	table.freeze({ Color3.fromRGB(96, 119, 82), 1 }),
	table.freeze({ Color3.fromRGB(90, 100, 105), 1 }),
	table.freeze({ Color3.fromRGB(93, 84, 67), 1 }),
	table.freeze({ Color3.fromRGB(145, 122, 86), 1 })
})
Rarity = ReplicatedStorage(v)
ReplicatedStorage = script.Configs
freeze = table.freeze
local Nibbles013 = require(ReplicatedStorage["Nibbles #013"])
local v4 = {
	["Nibbles #013"] = Nibbles013,
	LimitedTimeExperimentPet = require(ReplicatedStorage.LimitedTimeExperimentPet),
	Hazardhog = require(ReplicatedStorage.Hazardhog),
	Ringlord = require(ReplicatedStorage.Ringlord)
}
local RingGuard = require(ReplicatedStorage["Ring Guard"])
v4["Ring Guard"] = RingGuard
local AlabasterWhale = require(ReplicatedStorage["Alabaster Whale"])
v4["Alabaster Whale"] = AlabasterWhale
local AlienSkeletonBoss = require(ReplicatedStorage["Alien Skeleton Boss"])
v4["Alien Skeleton Boss"] = AlienSkeletonBoss
v4.Ankylosaurus = require(ReplicatedStorage.Ankylosaurus)
local ArchdemonDragon = require(ReplicatedStorage["Archdemon Dragon"])
v4["Archdemon Dragon"] = ArchdemonDragon
local AscendedVermilionPhoenix = require(ReplicatedStorage["Ascended Vermilion Phoenix"])
v4["Ascended Vermilion Phoenix"] = AscendedVermilionPhoenix
local AshGecko = require(ReplicatedStorage["Ash Gecko"])
v4["Ash Gecko"] = AshGecko
local BabyAuroraDragon = require(ReplicatedStorage["Baby Aurora Dragon"])
v4["Baby Aurora Dragon"] = BabyAuroraDragon
v4.Balrog = require(ReplicatedStorage.Balrog)
local BananitaDolphinita = require(ReplicatedStorage["Bananita Dolphinita"])
v4["Bananita Dolphinita"] = BananitaDolphinita
v4.Basilisk = require(ReplicatedStorage.Basilisk)
v4.Bear = require(ReplicatedStorage.Bear)
local BelulaBeluga = require(ReplicatedStorage["Belula Beluga"])
v4["Belula Beluga"] = BelulaBeluga
local BomboclatCrocolat = require(ReplicatedStorage["Bomboclat Crocolat"])
v4["Bomboclat Crocolat"] = BomboclatCrocolat
v4.Bronto = require(ReplicatedStorage.Bronto)
local BrrBrrPatapim = require(ReplicatedStorage["Brr Brr Patapim"])
v4["Brr Brr Patapim"] = BrrBrrPatapim
local BurrowingOwl = require(ReplicatedStorage["Burrowing Owl"])
v4["Burrowing Owl"] = BurrowingOwl
v4.Camel = require(ReplicatedStorage.Camel)
v4.Catfish = require(ReplicatedStorage.Catfish)
local CaveDragon = require(ReplicatedStorage["Cave Dragon"])
v4["Cave Dragon"] = CaveDragon
v4.Centapede = require(ReplicatedStorage.Centapede)
v4.Cerberus = require(ReplicatedStorage.Cerberus)
v4.Chicken = require(ReplicatedStorage.Chicken)
local ChillinChilli = require(ReplicatedStorage["Chillin Chilli"])
v4["Chillin Chilli"] = ChillinChilli
v4.Chimpanzee = require(ReplicatedStorage.Chimpanzee)
local ColossalMammoth = require(ReplicatedStorage["Colossal Mammoth"])
v4["Colossal Mammoth"] = ColossalMammoth
v4.Crane = require(ReplicatedStorage.Crane)
v4.Crocodile = require(ReplicatedStorage.Crocodile)
local CyclopsGorilla = require(ReplicatedStorage["Cyclops Gorilla"])
v4["Cyclops Gorilla"] = CyclopsGorilla
v4.DeathstalkerScorpion = require(ReplicatedStorage.DeathstalkerScorpion)
local DemonImp = require(ReplicatedStorage["Demon Imp"])
v4["Demon Imp"] = DemonImp
v4.DesertLark = require(ReplicatedStorage.DesertLark)
v4.Dodo = require(ReplicatedStorage.Dodo)
v4.Dog = require(ReplicatedStorage.Dog)
v4.Dragon = require(ReplicatedStorage.Dragon)
local DreamAxolotl = require(ReplicatedStorage["Dream Axolotl"])
v4["Dream Axolotl"] = DreamAxolotl
local DrillMonster = require(ReplicatedStorage["Drill Monster"])
v4["Drill Monster"] = DrillMonster
v4.Duckling = require(ReplicatedStorage.Duckling)
local ElMaja = require(ReplicatedStorage["El Maja"])
v4["El Maja"] = ElMaja
local EmberDragon = require(ReplicatedStorage["Ember Dragon"])
v4["Ember Dragon"] = EmberDragon
local EternalLunarDragon = require(ReplicatedStorage["Eternal Lunar Dragon"])
v4["Eternal Lunar Dragon"] = EternalLunarDragon
v4.FennecFox = require(ReplicatedStorage.FennecFox)
local FinnedThresher = require(ReplicatedStorage["Finned Thresher"])
v4["Finned Thresher"] = FinnedThresher
local FlamingBull = require(ReplicatedStorage["Flaming Bull"])
v4["Flaming Bull"] = FlamingBull
v4.Frog = require(ReplicatedStorage.Frog)
local GalaxyGecko = require(ReplicatedStorage["Galaxy Gecko"])
v4["Galaxy Gecko"] = GalaxyGecko
v4.Gorilla = require(ReplicatedStorage.Gorilla)
v4.Hellhound = require(ReplicatedStorage.Hellhound)
local IceDragon = require(ReplicatedStorage["Ice Dragon"])
v4["Ice Dragon"] = IceDragon
v4.Irihorus = require(ReplicatedStorage.Irihorus)
v4.Jerboa = require(ReplicatedStorage.Jerboa)
v4.Kitsune = require(ReplicatedStorage.Kitsune)
v4.Koi = require(ReplicatedStorage.Koi)
v4.Kraken = require(ReplicatedStorage.Kraken)
local LaVaccaSaturnoSaturnita = require(ReplicatedStorage["La Vacca Saturno Saturnita"])
v4["La Vacca Saturno Saturnita"] = LaVaccaSaturnoSaturnita
local LavaIguana = require(ReplicatedStorage["Lava Iguana"])
v4["Lava Iguana"] = LavaIguana
local Lavafrog = require(ReplicatedStorage["Lava frog"])
v4["Lava frog"] = Lavafrog
v4.Mammoth = require(ReplicatedStorage.Mammoth)
local MangoliniParrochini = require(ReplicatedStorage["Mangolini Parrochini"])
v4["Mangolini Parrochini"] = MangoliniParrochini
local MechaScorpio = require(ReplicatedStorage["Mecha Scorpio"])
v4["Mecha Scorpio"] = MechaScorpio
local MechaFroggo = require(ReplicatedStorage["Mecha Froggo"])
v4["Mecha Froggo"] = MechaFroggo
local MechaCrawler = require(ReplicatedStorage["Mecha Crawler"])
v4["Mecha Crawler"] = MechaCrawler
local MechaCrocodon = require(ReplicatedStorage["Mecha Crocodon"])
v4["Mecha Crocodon"] = MechaCrocodon
local MechaKrakenoid = require(ReplicatedStorage["Mecha Krakenoid"])
v4["Mecha Krakenoid"] = MechaKrakenoid
local MechaDreadscale = require(ReplicatedStorage["Mecha Dreadscale"])
v4["Mecha Dreadscale"] = MechaDreadscale
local MireFox = require(ReplicatedStorage["Mire Fox"])
v4["Mire Fox"] = MireFox
v4.Scorpio = require(ReplicatedStorage.Scorpio)
v4.Froggo = require(ReplicatedStorage.Froggo)
v4.Crawler = require(ReplicatedStorage.Crawler)
v4.Crocodon = require(ReplicatedStorage.Crocodon)
v4.Krakenoid = require(ReplicatedStorage.Krakenoid)
v4.Dreadscale = require(ReplicatedStorage.Dreadscale)
v4.Mosasaurus = require(ReplicatedStorage.Mosasaurus)
local OniTiger = require(ReplicatedStorage["Oni Tiger"])
v4["Oni Tiger"] = OniTiger
local OrangutiniAnanassini = require(ReplicatedStorage["Orangutini Ananassini"])
v4["Orangutini Ananassini"] = OrangutiniAnanassini
v4.Orca = require(ReplicatedStorage.Orca)
v4.Parrotfish = require(ReplicatedStorage.Parrotfish)
v4.Penguin = require(ReplicatedStorage.Penguin)
local PolarBear = require(ReplicatedStorage["Polar Bear"])
v4["Polar Bear"] = PolarBear
v4.Pterodactyl = require(ReplicatedStorage.Pterodactyl)
v4.Raccoon = require(ReplicatedStorage.Raccoon)
v4.Rattlesnake = require(ReplicatedStorage.Rattlesnake)
local RedPanda = require(ReplicatedStorage["Red Panda"])
v4["Red Panda"] = RedPanda
local SabertoothTiger = require(ReplicatedStorage["Sabertooth Tiger"])
v4["Sabertooth Tiger"] = SabertoothTiger
v4.Salamander = require(ReplicatedStorage.Salamander)
local SandSpider = require(ReplicatedStorage["Sand Spider"])
v4["Sand Spider"] = SandSpider
v4.ScorchedDragon = require(ReplicatedStorage.ScorchedDragon)
local ShadowDragon = require(ReplicatedStorage["Shadow Dragon"])
v4["Shadow Dragon"] = ShadowDragon
local SnowyOwl = require(ReplicatedStorage["Snowy Owl"])
v4["Snowy Owl"] = SnowyOwl
v4.Spider = require(ReplicatedStorage.Spider)
v4.Stag = require(ReplicatedStorage.Stag)
local StrawberryElephant = require(ReplicatedStorage["Strawberry Elephant"])
v4["Strawberry Elephant"] = StrawberryElephant
v4.Swan = require(ReplicatedStorage.Swan)
v4.Swordfish = require(ReplicatedStorage.Swordfish)
v4.Tiger = require(ReplicatedStorage.Tiger)
local TobTobiTobTob = require(ReplicatedStorage["Tob Tobi Tob Tob"])
v4["Tob Tobi Tob Tob"] = TobTobiTobTob
v4.Toucan = require(ReplicatedStorage.Toucan)
v4.Tralaledon = require(ReplicatedStorage.Tralaledon)
v4.Triceratops = require(ReplicatedStorage.Triceratops)
local TrulimeroTrulicina = require(ReplicatedStorage["Trulimero Trulicina"])
v4["Trulimero Trulicina"] = TrulimeroTrulicina
local TungTungSahur = require(ReplicatedStorage["Tung Tung Sahur"])
v4["Tung Tung Sahur"] = TungTungSahur
v4.Turtle = require(ReplicatedStorage.Turtle)
v4.TyrannosaurusRex = require(ReplicatedStorage.TyrannosaurusRex)
v4.Unicorn = require(ReplicatedStorage.Unicorn)
local VoidDragon = require(ReplicatedStorage["Void Dragon"])
v4["Void Dragon"] = VoidDragon
v4.Walrus = require(ReplicatedStorage.Walrus)
v4.Warden = require(ReplicatedStorage.Warden)
local WhaleShark = require(ReplicatedStorage["Whale Shark"])
v4["Whale Shark"] = WhaleShark
v4.Yeti = require(ReplicatedStorage.Yeti)
v4.Crab = require(ReplicatedStorage.Crab)
v4.Rhino = require(ReplicatedStorage.Rhino)
v4.Mantis = require(ReplicatedStorage.Mantis)
local KaijuSpider = require(ReplicatedStorage["Kaiju Spider"])
v4["Kaiju Spider"] = KaijuSpider
v4.Shark = require(ReplicatedStorage.Shark)
local BladeHead = require(ReplicatedStorage["Blade Head"])
v4["Blade Head"] = BladeHead
local KingKong = require(ReplicatedStorage["King Kong"])
v4["King Kong"] = KingKong
v4.Godzilla = require(ReplicatedStorage.Godzilla)
v4.Wendigo = require(ReplicatedStorage.Wendigo)
v4.Shardwing = require(ReplicatedStorage.Shardwing)
local ShatteredDrake = require(ReplicatedStorage["Shattered Drake"])
v4["Shattered Drake"] = ShatteredDrake
local ShatteredColossus = require(ReplicatedStorage["Shattered Colossus"])
v4["Shattered Colossus"] = ShatteredColossus
v4.Ventinal = require(ReplicatedStorage.Ventinal)
local WorldEater = require(ReplicatedStorage["World Eater"])
v4["World Eater"] = WorldEater
v4.Mawbreaker = require(ReplicatedStorage.Mawbreaker)
v4.Dreadclaw = require(ReplicatedStorage.Dreadclaw)
local VoidSerpent = require(ReplicatedStorage["Void Serpent"])
v4["Void Serpent"] = VoidSerpent
v4.ArchAngel = require(ReplicatedStorage.ArchAngel)
local WorldBurner = require(ReplicatedStorage["World Burner"])
v4["World Burner"] = WorldBurner
v4.Pegasus = require(ReplicatedStorage.Pegasus)
local SkeletonHorse = require(ReplicatedStorage["Skeleton Horse"])
v4["Skeleton Horse"] = SkeletonHorse
v4.Aetheron = require(ReplicatedStorage.Aetheron)
v4.Equinox = require(ReplicatedStorage.Equinox)
v4.Dove = require(ReplicatedStorage.Dove)
v4.Lamb = require(ReplicatedStorage.Lamb)
v4.Moth = require(ReplicatedStorage.Moth)
v4.Peacock = require(ReplicatedStorage.Peacock)
v4.Jellyfish = require(ReplicatedStorage.Jellyfish)
v4.Centaur = require(ReplicatedStorage.Centaur)
local FlameSprite = require(ReplicatedStorage["Flame Sprite"])
v4["Flame Sprite"] = FlameSprite
v4.Toro = require(ReplicatedStorage.Toro)
v4.Imp = require(ReplicatedStorage.Imp)
local DemonHound = require(ReplicatedStorage["Demon Hound"])
v4["Demon Hound"] = DemonHound
local DarkGargoyle = require(ReplicatedStorage["Dark Gargoyle"])
v4["Dark Gargoyle"] = DarkGargoyle
v4.RazorFang = require(ReplicatedStorage.RazorFang)
local ToxicRat = require(ReplicatedStorage["Toxic Rat"])
v4["Toxic Rat"] = ToxicRat
v4.Radcoon = require(ReplicatedStorage.Radcoon)
v4.Toucax = require(ReplicatedStorage.Toucax)
v4.Nuceodille = require(ReplicatedStorage.Nuceodille)
local WheelHamster = require(ReplicatedStorage["Wheel Hamster"])
v4["Wheel Hamster"] = WheelHamster
local StackedTurtle = require(ReplicatedStorage["Stacked Turtle"])
v4["Stacked Turtle"] = StackedTurtle
v4.Frogfly = require(ReplicatedStorage.Frogfly)
v4.Spiderpig = require(ReplicatedStorage.Spiderpig)
v4.Sharkodile = require(ReplicatedStorage.Sharkodile)
v4.Octophant = require(ReplicatedStorage.Octophant)
local MechaScrambler = require(ReplicatedStorage["Mecha Scrambler"])
v4["Mecha Scrambler"] = MechaScrambler
v4.Dreadstinger = require(ReplicatedStorage.Dreadstinger)
v4.Rhinobear = require(ReplicatedStorage.Rhinobear)
local EyeballCrab = require(ReplicatedStorage["Eyeball Crab"])
v4["Eyeball Crab"] = EyeballCrab
local ThreeHeadedChicken = require(ReplicatedStorage["Three Headed Chicken"])
v4["Three Headed Chicken"] = ThreeHeadedChicken
local NuclearMantis = require(ReplicatedStorage["Nuclear Mantis"])
v4["Nuclear Mantis"] = NuclearMantis
local VoidAngler = require(ReplicatedStorage["Void Angler"])
v4["Void Angler"] = VoidAngler
local RiftEye = require(ReplicatedStorage["Rift Eye"])
v4["Rift Eye"] = RiftEye
local ShatteredRam = require(ReplicatedStorage["Shattered Ram"])
v4["Shattered Ram"] = ShatteredRam
v4.Shardling = require(ReplicatedStorage.Shardling)
v4.Voidmaw = require(ReplicatedStorage.Voidmaw)
v4.Riftwing = require(ReplicatedStorage.Riftwing)
local AbyssalOverlord = require(ReplicatedStorage["Abyssal Overlord"])
v4["Abyss Overlord"] = AbyssalOverlord
local AbyssalOverlordOP = require(ReplicatedStorage["Abyssal Overlord OP"])
v4["Abyss Overlord OP"] = AbyssalOverlordOP
local MantaRay = require(ReplicatedStorage["Manta Ray"])
v4["Manta Ray"] = MantaRay
v4.Spike = require(ReplicatedStorage.Spike)
local RiptideOctopus = require(ReplicatedStorage["Riptide Octopus"])
v4["Riptide Octopus"] = RiptideOctopus
local ElectricEel = require(ReplicatedStorage["Electric Eel"])
v4["Electric Eel"] = ElectricEel
v4.Megalodon = require(ReplicatedStorage.Megalodon)
v4.Cthulhu = require(ReplicatedStorage.Cthulhu)
local DepthsMantaRay = require(ReplicatedStorage["Depths Manta Ray"])
v4["Depths Manta Ray"] = DepthsMantaRay
local DepthsSpike = require(ReplicatedStorage["Depths Spike"])
v4["Depths Spike"] = DepthsSpike
local DepthsRiptideOctopus = require(ReplicatedStorage["Depths Riptide Octopus"])
v4["Depths Riptide Octopus"] = DepthsRiptideOctopus
local DepthsElectricEel = require(ReplicatedStorage["Depths Electric Eel"])
v4["Depths Electric Eel"] = DepthsElectricEel
local DepthsMegalodon = require(ReplicatedStorage["Depths Megalodon"])
v4["Depths Megalodon"] = DepthsMegalodon
local DepthsCthulhu = require(ReplicatedStorage["Depths Cthulhu"])
v4["Depths Cthulhu"] = DepthsCthulhu
local TerraSnapper = require(ReplicatedStorage["Terra Snapper"])
v4["Terra Snapper"] = TerraSnapper
local DepthsTerraSnapper = require(ReplicatedStorage["Depths Terra Snapper"])
v4["Depths Terra Snapper"] = DepthsTerraSnapper
v4.Glyptodon = require(ReplicatedStorage.Glyptodon)
v4.Terrorbird = require(ReplicatedStorage.Terrorbird)
v4.Megatherium = require(ReplicatedStorage.Megatherium)
v4.Dunkleosteus = require(ReplicatedStorage.Dunkleosteus)
v4.Gigantopithecus = require(ReplicatedStorage.Gigantopithecus)
v4.Sabertooth = require(ReplicatedStorage.Sabertooth)
local SkeletalGlyptodon = require(ReplicatedStorage["Skeletal Glyptodon"])
v4["Skeletal Glyptodon"] = SkeletalGlyptodon
local SkeletalTerrorbird = require(ReplicatedStorage["Skeletal Terrorbird"])
v4["Skeletal Terrorbird"] = SkeletalTerrorbird
local SkeletalMegatherium = require(ReplicatedStorage["Skeletal Megatherium"])
v4["Skeletal Megatherium"] = SkeletalMegatherium
local SkeletalDunkleosteus = require(ReplicatedStorage["Skeletal Dunkleosteus"])
v4["Skeletal Dunkleosteus"] = SkeletalDunkleosteus
local SkeletalGigantopithecus = require(ReplicatedStorage["Skeletal Gigantopithecus"])
v4["Skeletal Gigantopithecus"] = SkeletalGigantopithecus
local SkeletalSabertooth = require(ReplicatedStorage["Skeletal Sabertooth"])
v4["Skeletal Sabertooth"] = SkeletalSabertooth
local CitadelSnail = require(ReplicatedStorage["Citadel Snail"])
v4["Citadel Snail"] = CitadelSnail
local ToxicCrocodile = require(ReplicatedStorage["Toxic Crocodile"])
v4["Toxic Crocodile"] = ToxicCrocodile
local MechaChompa = require(ReplicatedStorage["Mecha Chompa"])
v4["Mecha Chompa"] = MechaChompa
local PinkDragonExperiment = require(ReplicatedStorage["Pink Dragon Experiment"])
v4["Pink Dragon Experiment"] = PinkDragonExperiment
local EyeBat = require(ReplicatedStorage["Eye Bat"])
v4["Eye Bat"] = EyeBat
local UncoiledArmadillo = require(ReplicatedStorage["Uncoiled Armadillo"])
v4["Uncoiled Armadillo"] = UncoiledArmadillo
local _67 = require(ReplicatedStorage["67"])
v4["67"] = _67
local _67OP = require(ReplicatedStorage["67 OP"])
v4["67 OP"] = _67OP
local ToxicHedgehog = require(ReplicatedStorage["Toxic Hedgehog"])
v4["Toxic Hedgehog"] = ToxicHedgehog
local ToxicHedgehogOP = require(ReplicatedStorage["Toxic Hedgehog OP"])
v4["Toxic Hedgehog OP"] = ToxicHedgehogOP
local directory = freeze(v4)
ReplicatedStorage = require
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
directory = ReplicatedStorage(ReplicatedStorage2.Shared.Flags.BalanceConfig).Bind("Game.Balance.Assets", directory, {
	EarningRate = true,
	IndexSpeedReward = true,
	DropWeight = true,
	VisualOdds = true,
	ModelWeight = true,
	Egg = {
		GrowthTime = true,
		WeightKg = true
	},
	LuckyBlockDropTable = true,
	LuckyBlockLevelRange = true,
	LuckyBlockOpenDuration = true
}, true, function(items)
	local total = 0

	for k, item in items do
		if not directory[k].DontRoll and directory[k].Rarity._id ~= "Eternal" then
			total += item.DropWeight or 0
		end

		if not item.Egg then
			continue
		end

		local v6

		if item.Egg.GrowthTime > 0 then
			v6 = item.Egg.WeightKg > 0
		else
			v6 = false
		end

		assert(v6)
	end

	assert(total > 0)
end)
local v6 = {}

for k, v7 in directory do
	local _id = v7.Rarity._id
	local v8 = v6[_id]

	if v8 == nil then
		v8 = {}
		v6[_id] = v8
	end

	v8[k] = v7
end

for _, list in v6 do
	table.freeze(list)
end

local frozen = table.freeze(v6)
local v7 = {
	Directory = directory,
	ByRarity = frozen,
	Personalities = PersonalityCatalog,
	BaseConfig = Rarity,
	AssetNameExists = function(p: string)
		if directory[p] == nil then
			return false, (`Asset name "{p}" does not exist in the Assets directory.`)
		end

		return true
	end
}
return table.freeze(v7)