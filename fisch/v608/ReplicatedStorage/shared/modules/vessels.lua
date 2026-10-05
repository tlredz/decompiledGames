local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local modules = ReplicatedStorage.shared.modules
local Worlds = require(modules.Worlds)
local CutsceneService = nil
local WorldService = nil
local PlayerService = nil
local Replion = require(packages.Replion)
local Promise = require(packages.Promise)
local forPlayerSafe, forPlayerNow

if RunService:IsServer() then
	local ServerScriptService = game:GetService("ServerScriptService")
	WorldService = require(ServerScriptService.server.legacyServices.WorldService)
	PlayerService = require(ServerScriptService.server.legacyServices.PlayerService)
	CutsceneService = require(ServerScriptService.server.legacyServices.CutsceneService)
	local legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
	forPlayerSafe = legacyPlayerData.forPlayerSafe
	local legacyPlayerData2 = require(ServerScriptService.server.modules.legacyPlayerData)
	forPlayerNow = legacyPlayerData2.forPlayerNow
else
	local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
	forPlayerSafe = legacyLocalPlayerData.fetch
	forPlayerNow = forPlayerSafe
end

local Vessels = {}
local v = {
	"Common",
	"Heat",
	"Ice",
	"Deep"
}
local _ = RunService:IsStudio() and 135499799161875
Vessels.library = {
	["Lighthouse Skiff"] = {
		Icon = "rbxassetid://75509074616519",
		Price = -1,
		Description = "Obtained via Boat Racing at Moosewood.",
		Level = 0,
		MaxSpeed = 190,
		Accel = 0.2,
		TurningSpeed = 1,
		BackwardsEfficiency = 0.9,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 4,
		Unpurchasable = true,
		Untradeable = true,
		BoostEnabled = true,
		BoostMaxSpeed = 100,
		BoostMaxTime = 4,
		BoostChargeTime = 30
	},
	["Blacktide Sailboat"] = {
		Icon = "rbxassetid://72971117877281",
		Price = -1,
		Description = "Obtained via Boat Racing at Forsaken Shores.",
		Level = 0,
		MaxSpeed = 180,
		Accel = 0.2,
		TurningSpeed = 1,
		BackwardsEfficiency = 0.9,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 4,
		Unpurchasable = true,
		Untradeable = true,
		BoostEnabled = true,
		BoostMaxSpeed = 75,
		BoostMaxTime = 6,
		BoostChargeTime = 25
	},
	["Crag-Catamaran"] = {
		Icon = "rbxassetid://80012604875190",
		Price = -1,
		Description = "Obtained via Boat Racing at Scoria Reach.",
		Level = 0,
		MaxSpeed = 180,
		Accel = 0.2,
		TurningSpeed = 1,
		BackwardsEfficiency = 0.9,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 4,
		Unpurchasable = true,
		Untradeable = true,
		BoostEnabled = true,
		BoostMaxSpeed = 100,
		BoostMaxTime = 4,
		BoostChargeTime = 30
	},
	["Glacier Jetboat"] = {
		Icon = "rbxassetid://72383317366408",
		Price = -1,
		Description = "Obtained via Boat Racing at Snowcap.",
		Level = 0,
		MaxSpeed = 170,
		Accel = 0.2,
		TurningSpeed = 1,
		BackwardsEfficiency = 0.9,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 1,
		SteerTilt = 4,
		Unpurchasable = true,
		Untradeable = true,
		BoostEnabled = true,
		BoostMaxSpeed = 100,
		BoostMaxTime = 5,
		BoostChargeTime = 30
	},
	["Primal Airboat"] = {
		Icon = "rbxassetid://135677616718394",
		Price = -1,
		Description = "Obtained via Boat Racing at Ancient Isle.",
		Level = 0,
		MaxSpeed = 200,
		Accel = 0.2,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 0.9,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 4,
		Unpurchasable = true,
		Untradeable = true,
		BoostEnabled = true,
		BoostMaxSpeed = 100,
		BoostMaxTime = 3,
		BoostChargeTime = 35
	},
	["Banana Boat"] = {
		Icon = "rbxassetid://76102715065127",
		Price = 1e999,
		Description = "🍌",
		Level = 1,
		MaxSpeed = 50,
		Accel = 50,
		TurningSpeed = 5,
		BackwardsEfficiency = 10,
		StopEfficiency = 0.5,
		Bobbing = 2,
		BobbingSpeed = 50,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Untradeable = true,
		Unpurchasable = true
	},
	["Little Sei Whale"] = {
		Icon = "rbxassetid://131745758260645",
		Price = 1e999,
		Description = "just a lil 🐋",
		Level = 1,
		MaxSpeed = 100,
		Accel = 0.5,
		TurningSpeed = 2,
		BackwardsEfficiency = 0.4,
		StopEfficiency = 0.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		Untradeable = true,
		Unpurchasable = true
	},
	Pufferfish = {
		Icon = "rbxassetid://109395014539464",
		Price = -1,
		Description = "His Greed Will Consume Him",
		Level = 0,
		MaxSpeed = 250,
		Accel = 0.25,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 0.5,
		StopEfficiency = 2,
		Bobbing = 5,
		BobbingSpeed = 0.5,
		Unpurchasable = true,
		Untradeable = true
	},
	["Huge Firework"] = {
		Icon = "rbxassetid://117666257077864",
		Price = -1,
		Description = "PEEEEEW!!",
		Level = 1,
		MaxSpeed = 250,
		Accel = 3,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 1,
		SteerTilt = 12,
		Unpurchasable = true
	},
	["Random Boat"] = {
		Icon = "rbxassetid://116816437660906",
		Price = -1,
		Description = "Spawn a random favorited boat",
		Level = 0.1,
		MaxSpeed = 0,
		Accel = 0,
		TurningSpeed = 0,
		BackwardsEfficiency = 0,
		StopEfficiency = 0,
		Bobbing = 0,
		BobbingSpeed = 0,
		Unpurchasable = true,
		Untradeable = true,
		SortOffset = -100000
	},
	["Reef Cutter"] = {
		Icon = "rbxassetid://109813655959472",
		Price = -1,
		Description = "Only available during Fischfest-2026",
		Level = 1,
		MaxSpeed = 220,
		Accel = 0.8,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true
	},
	["Reef Slasher"] = {
		Icon = "rbxassetid://115922023301906",
		Price = -1,
		Description = "Only available during Fischfest-2026",
		Level = 1,
		MaxSpeed = 200,
		Accel = 0.7,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true
	},
	["Sunslasher Popsicle Floatie"] = {
		Icon = "rbxassetid://127646086911222",
		Price = -1,
		Description = "Only available during Fischfest-2026",
		Level = 1,
		MaxSpeed = 125,
		Accel = 4,
		TurningSpeed = 2,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 5,
		BobbingSpeed = 8,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true
	},
	["Ducky Floatie"] = {
		Icon = "rbxassetid://110186533312366",
		Price = -1,
		Description = "Only available during Fischfest-2026",
		Level = 1,
		MaxSpeed = 50,
		Accel = 3,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 5,
		BobbingSpeed = 8,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true
	},
	["Crab Floatie"] = {
		Icon = "rbxassetid://136059746861237",
		Price = -1,
		Description = "Only available during Fischfest-2026",
		Level = 1,
		MaxSpeed = 80,
		Accel = 3,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 5,
		BobbingSpeed = 8,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true
	},
	["Pufferfish Floatie"] = {
		Icon = "rbxassetid://118461335786819",
		Price = -1,
		Description = "Only available during Fischfest-2026",
		Level = 1,
		MaxSpeed = 80,
		Accel = 3,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 5,
		BobbingSpeed = 8,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true
	},
	["Dumbo Octopus Floatie"] = {
		Icon = "rbxassetid://125692950302034",
		Price = -1,
		Description = "Only available during Fischfest-2026",
		Level = 1,
		MaxSpeed = 80,
		Accel = 3,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 5,
		BobbingSpeed = 8,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true
	},
	["Shiny Dumbo Octopus Floatie"] = {
		Icon = "rbxassetid://117154706179450",
		Price = -1,
		Description = "Only available during Fischfest-2026",
		Level = 1,
		MaxSpeed = 90,
		Accel = 3,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 5,
		BobbingSpeed = 8,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true
	},
	Cactus = {
		Icon = "rbxassetid://111054591221691",
		Price = -1,
		Description = "OUCH!",
		Level = 1,
		MaxSpeed = 70,
		Accel = 2,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 5,
		BobbingSpeed = 8,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true
	},
	["Smudged Titan"] = {
		Icon = "rbxassetid://130537585295238",
		Price = -1,
		Description = "hi im smudge (titan edition)",
		Level = 1,
		MaxSpeed = 55,
		Accel = 3,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.5,
		Bobbing = 3,
		BobbingSpeed = 1,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true
	},
	["Fischfest-Ski"] = {
		Icon = "rbxassetid://84047844240570",
		Price = -1,
		Description = "Only available during Fischfest-2026",
		Level = 0,
		MaxSpeed = 200,
		Accel = 0.4,
		TurningSpeed = 1,
		BackwardsEfficiency = 0.9,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 12,
		Unpurchasable = true,
		IsJetski = true,
		BoostEnabled = true,
		BoostMaxSpeed = 200,
		BoostMaxTime = 5,
		BoostChargeTime = 15
	},
	["Rivet's Motorcycle"] = {
		Icon = "rbxassetid://136805528527298",
		Price = -1,
		Description = "sick ride dude",
		Level = 0,
		MaxSpeed = 235,
		Accel = 0.7,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2.2,
		Bobbing = 6,
		BobbingSpeed = 3,
		ForwardTilt = 1,
		SteerTilt = 6,
		Unpurchasable = true,
		Untradeable = true
	},
	["Basketback Tortoise"] = {
		Icon = "rbxassetid://108190444034513",
		Price = -1,
		Description = "[Easter 2026 Exclusive]",
		Level = 0,
		MaxSpeed = 210,
		Accel = 0.3,
		TurningSpeed = 0.35,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2.2,
		Bobbing = 6,
		BobbingSpeed = 3,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Easter Egg Nest"] = {
		Icon = "rbxassetid://114511174312341",
		Price = -1,
		Description = "[Easter 2026 Exclusive]",
		Level = 0,
		MaxSpeed = 215,
		Accel = 0.1,
		TurningSpeed = 0.25,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 6,
		BobbingSpeed = 3,
		BlockRacing = true,
		Unpurchasable = true,
		Untradeable = true
	},
	Nico = {
		Icon = "rbxassetid://94407542039308",
		Price = -1,
		Description = "mrroew :3",
		Level = 0,
		MaxSpeed = 200,
		Accel = 0.5,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 0.5,
		StopEfficiency = 2,
		Bobbing = 0.1,
		BobbingSpeed = 10,
		Unpurchasable = true,
		Untradeable = true
	},
	["Shamrock Express"] = {
		Icon = "rbxassetid://112215523260889",
		Price = -1,
		Description = "[Shamrock Seas Exclusive]",
		Level = 0,
		MaxSpeed = 255,
		Accel = 0.1,
		TurningSpeed = 0.27,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 6,
		BobbingSpeed = 3,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Shamrock Leviathan"] = {
		Icon = "rbxassetid://77851870502038",
		Price = -1,
		Description = "[Shamrock Seas Exclusive]",
		Level = 0,
		MaxSpeed = 210,
		Accel = 0.3,
		TurningSpeed = 0.35,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2.2,
		Bobbing = 6,
		BobbingSpeed = 3,
		Unpurchasable = true
	},
	["Solid Gold Lucky Pot"] = {
		Icon = "rbxassetid://135056858828094",
		Price = -1,
		Description = "Huh? I'm a very lucky guy! [Shamrock Seas Exclusive]",
		Level = 1,
		MaxSpeed = 200,
		Accel = 0.2,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.5,
		Bobbing = 3,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Giant Lucky Pot"] = {
		Icon = "rbxassetid://97747171023442",
		Price = -1,
		Description = "Huh? I'm a REALLY lucky guy! [Shamrock Seas Exclusive]",
		Level = 1,
		MaxSpeed = 550,
		Accel = 0.05,
		TurningSpeed = 0.05,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.5,
		Bobbing = 3,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Rainbow Boat"] = {
		Icon = "rbxassetid://93097309265704",
		Price = -1,
		Description = "Colorful and beautifully (?) painted!",
		Level = 1,
		MaxSpeed = 215,
		Accel = 0.8,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Toxic-Proof Raft"] = {
		Icon = "rbxassetid://115979120593864",
		Price = -1,
		Description = "It seems to have been thrown together hastily and without much thought; hopefully it'll be enough...",
		Level = 1,
		MaxSpeed = 15,
		Accel = 0.1,
		TurningSpeed = 0.4,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 3,
		BobbingSpeed = 0.5,
		Durability = 150,
		Unpurchasable = true,
		Untradeable = true
	},
	Heart = {
		Icon = "rbxassetid://81792090855847",
		Price = -1,
		Description = "Only available during Valentides 2026",
		Level = 1,
		MaxSpeed = 190,
		Accel = 0.8,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 0.85,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Party Boat"] = {
		Icon = "rbxassetid://84399247645569",
		Price = -1,
		Description = "Party with your friends! [Boombox Exclusive]",
		Level = 0,
		MaxSpeed = 150,
		Accel = 0.2,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 1,
		BobbingSpeed = 1,
		SpawnOffset = 20,
		BlockRacing = true,
		Unpurchasable = true,
		Untradeable = true
	},
	["Mini Pirate Ship"] = {
		Icon = "rbxassetid://119647536711354",
		Price = -1,
		Description = "it's a mystery how this can hold a person...",
		Level = 1,
		MaxSpeed = 150,
		Accel = 15,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 1.2,
		StopEfficiency = 5,
		Bobbing = 0.1,
		BobbingSpeed = 0.01,
		Unpurchasable = true
	},
	Snowman = {
		Icon = "rbxassetid://91881858933047",
		Price = -1,
		Description = "Only available during Fischmas-2025",
		Level = 1,
		MaxSpeed = 150,
		Accel = 1,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		Unpurchasable = true
	},
	["Head Of Cthulu"] = {
		Icon = "rbxassetid://90849707354349",
		Price = -1,
		Description = "A seaborne vessel shaped like Cthulhu's head.",
		Level = 1,
		MaxSpeed = 135,
		Accel = 0.3,
		TurningSpeed = 0.45,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		Unpurchasable = true
	},
	["Cthulhu Boat"] = {
		Icon = "rbxassetid://95194471402955",
		Price = -1,
		Description = "Extremely fast, and equally cursed...",
		Level = 1,
		MaxSpeed = 265,
		Accel = 0.8,
		TurningSpeed = 0.9,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		IsJetski = true,
		Unpurchasable = true
	},
	["The Blubbernaut"] = {
		Icon = "rbxassetid://132147167716037",
		Price = -1,
		Description = "A compact, heavy-duty whale themed submarine with a reinforced shell and powerful thrusters, built for deep-sea dominance.",
		Level = 70,
		MaxSpeed = 180,
		Accel = 0.3,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		IsSubmarine = true,
		SubmarineVerticalSpeed = 90,
		BlockRacing = true,
		Unpurchasable = true
	},
	Cthulunaut = {
		Icon = "rbxassetid://87034267614710",
		Price = -1,
		Description = "The Cthulunaut is a deep-sea submarine, glowing eerie green, its hull carved with eldritch patterns, gliding through the abyss like a cosmic nightmare..",
		Level = 70,
		MaxSpeed = 180,
		Accel = 0.3,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		IsSubmarine = true,
		SubmarineVerticalSpeed = 90,
		BlockRacing = true,
		Unpurchasable = true
	},
	["King of the Kraken"] = {
		Icon = "rbxassetid://91329391188038",
		Price = -1,
		Description = "A small, standing ship with a sleek black hull and glowing blue accents.",
		Level = 1,
		MaxSpeed = 260,
		Accel = 0.8,
		TurningSpeed = 0.9,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		Unpurchasable = true,
		Untradeable = true
	},
	["Volcanic Research Boat"] = {
		Icon = "rbxassetid://116581949935250",
		Price = -1,
		Description = "Dr. Finneus's Volcanic Research Quest Boat!",
		Level = 1,
		MaxSpeed = 135,
		Accel = 0.3,
		TurningSpeed = 0.45,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Swan Boat"] = {
		Icon = "rbxassetid://72911569404830",
		Price = -1,
		Description = "The Swan Boat!",
		Level = 1,
		MaxSpeed = 180,
		Accel = 0.35,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.8,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Sea Pegasus"] = {
		Icon = "rbxassetid://72935532824780",
		Price = -1,
		Description = "The Sea Pegasus!",
		Level = 1,
		MaxSpeed = 180,
		Accel = 0.35,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.8,
		Bobbing = 2,
		BobbingSpeed = 1,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Loot Rider"] = {
		Icon = "rbxassetid://80827578890451",
		Price = -1,
		Description = "The Loot Rider!",
		Level = 1,
		MaxSpeed = 190,
		Accel = 0.35,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.8,
		Bobbing = 2,
		BobbingSpeed = 1,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Rowboat = {
		Icon = "rbxassetid://134432015160761",
		Price = 400,
		Description = "Sail the seas with your trusty paddles!",
		Level = 0.5,
		MaxSpeed = 25,
		Accel = 0.15,
		TurningSpeed = 0.4,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 3,
		BobbingSpeed = 1,
		Untradeable = true
	},
	["Trade Plaza Traveler's Rowboat"] = {
		Icon = "rbxassetid://110760955278690",
		Price = -1,
		Description = "Sail the seas with... someone else's trusty paddles!",
		Level = 1,
		MaxSpeed = 225,
		Accel = 0.15,
		TurningSpeed = 0.4,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 3,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	Surfboard = {
		Icon = "rbxassetid://140475994837078",
		Price = 1500,
		Description = "Surf the waves, catch the sharks!",
		Level = 7,
		MaxSpeed = 30,
		Accel = 0.2,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 3,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		Untradeable = true
	},
	["Bass Boat"] = {
		Icon = "rbxassetid://82321210811947",
		Price = 6000,
		Description = "Great for fishing with pals!",
		Level = 10,
		MaxSpeed = 45,
		Accel = 0.22,
		TurningSpeed = 0.4,
		BackwardsEfficiency = 1,
		StopEfficiency = 0.7,
		Bobbing = 2,
		BobbingSpeed = 1,
		Untradeable = true
	},
	Hovercraft = {
		Icon = "rbxassetid://86981907121786",
		Price = 7000,
		Description = "Hover around the seas! [Contribution by @DDkreep, @LiamGame09 and @kylecat11]",
		Level = 15,
		MaxSpeed = 55,
		Accel = 0.22,
		TurningSpeed = 0.4,
		BackwardsEfficiency = 1,
		StopEfficiency = 0.7,
		Bobbing = 1,
		BobbingSpeed = 1,
		Untradeable = true
	},
	Speedboat = {
		Icon = "rbxassetid://130743409246855",
		Price = 15000,
		Description = "Sail around at remarkable speeds!",
		Level = 20,
		MaxSpeed = 85,
		Accel = 0.25,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.3,
		Bobbing = 2.5,
		BobbingSpeed = 1,
		Untradeable = true
	},
	["Midnight Cruiser"] = {
		Icon = "rbxassetid://111198001071610",
		Price = -1,
		Description = "Midnight Cruiser!",
		Level = 50,
		MaxSpeed = 150,
		Accel = 0.3,
		TurningSpeed = 0.54,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Luxury Speedboat"] = {
		Icon = "rbxassetid://128624450327470",
		Price = 20000,
		Description = "Sail around at unprecedented speeds!",
		Level = 50,
		MaxSpeed = 150,
		Accel = 0.3,
		TurningSpeed = 0.54,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		Untradeable = true
	},
	["Hydro-Skiff"] = {
		Icon = "rbxassetid://140500501667988",
		Price = 1e999,
		Description = "A deep city exclusive!",
		Level = 50,
		MaxSpeed = 210,
		Accel = 0.3,
		TurningSpeed = 0.54,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		Untradeable = true,
		Unpurchasable = true
	},
	["Holiday Themed - Speedboat"] = {
		Icon = "rbxassetid://75366616883373",
		Price = -1,
		Description = "Sail around at unpresedented speeds! HOLIDAY XMAS!",
		Level = 1,
		MaxSpeed = 150,
		Accel = 0.3,
		TurningSpeed = 0.54,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true
	},
	Mila = {
		Icon = "rbxassetid://73843249851684",
		Price = -1,
		Description = "🥝",
		Level = 1,
		MaxSpeed = 250,
		Accel = 0.65,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true,
		DEV = true,
		BlockRacing = true,
		Disruptive = true,
		FreeMovement = true,
		StupidPhysics = true,
		NoMomentumLossOnImpact = true
	},
	["silly stone guy"] = {
		Icon = "rbxassetid://131712175288790",
		Price = -1,
		Description = "🪨",
		Level = 1,
		MaxSpeed = 100,
		Accel = 0.5,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true,
		BlockRacing = true,
		Disruptive = true,
		FreeMovement = true,
		StupidPhysics = true,
		NoMomentumLossOnImpact = true
	},
	["ziggurat of dominance"] = {
		Icon = "rbxassetid://79567999104662",
		Price = -1,
		Description = "tarnished stinks",
		Level = 1,
		MaxSpeed = 10000000000000,
		Accel = 10000000000000,
		TurningSpeed = 0,
		BackwardsEfficiency = 1,
		StopEfficiency = 10000000000000,
		Bobbing = 0,
		BobbingSpeed = 0,
		Unpurchasable = true,
		Untradeable = true,
		DEV = true
	},
	whatevenisthisboat = {
		Icon = "rbxassetid://70711347673919",
		Price = -1,
		Description = "son😭😭😭😭",
		Level = 1,
		MaxSpeed = 1500,
		Accel = 2,
		TurningSpeed = 2,
		BackwardsEfficiency = 1,
		StopEfficiency = 5,
		Bobbing = 0,
		BobbingSpeed = 0,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true,
		Untradeable = true,
		DEV = true
	},
	Theo = {
		Icon = "rbxassetid://114616291594414",
		Price = -1,
		Description = "plutoly forced me to do this - kiwi",
		Level = 1,
		MaxSpeed = 250,
		Accel = 0.65,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true
	},
	Dusekkar = {
		Icon = "rbxassetid://93722693864118",
		Price = -1,
		Description = "Woah! Is that the guy from forsaken??",
		Level = 1,
		MaxSpeed = 500,
		Accel = 1,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true,
		DEV = true,
		BlockRacing = true,
		Disruptive = true,
		FreeMovement = true,
		StupidPhysics = true,
		NoMomentumLossOnImpact = true
	},
	Brick = {
		Icon = "rbxassetid://111526498434575",
		Price = -1,
		Description = "🧱",
		Level = 1,
		MaxSpeed = 1000,
		Accel = 0.01,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 20,
		Bobbing = 0,
		BobbingSpeed = 0,
		Unpurchasable = true,
		Untradeable = true
	},
	["Artist's Cottage"] = {
		Icon = "rbxassetid://133096146340328",
		Price = -1,
		Description = "Obtainment TBD [Can Fly!]",
		Level = 1,
		MaxSpeed = 250,
		Accel = 0.5,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 3,
		BobbingSpeed = 0.5,
		FlyingBoat = true,
		VerticalMaxSpeed = 10,
		BlockRacing = true,
		Unpurchasable = true,
		Disruptive = true
	},
	["Whale Shark"] = {
		Icon = "rbxassetid://123258075251559",
		Price = -1,
		Description = "MY FAVORITE!",
		Level = 1,
		MaxSpeed = 500,
		Accel = 0.1,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 1,
		Bobbing = 0,
		BobbingSpeed = 0,
		ForwardTilt = 2,
		SteerTilt = 6,
		BlockRacing = true,
		Unpurchasable = true,
		Untradeable = true
	},
	Walrus = {
		Icon = "rbxassetid://75095169857880",
		Price = -1,
		Description = "big ol teeth",
		Level = 1,
		MaxSpeed = 300,
		Accel = 0.15,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 1,
		Bobbing = 1,
		BobbingSpeed = 1,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true,
		Untradeable = true
	},
	["Grandpa Horseshoe Crab"] = {
		Icon = "rbxassetid://128636774591080",
		Price = -1,
		Description = "A huge grandpa horseshoe crab. He must have lots of wisdom to go around!",
		Level = 1,
		MaxSpeed = 10,
		Accel = 0.09,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 1,
		StopEfficiency = 1,
		Bobbing = 1,
		BobbingSpeed = 1,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true,
		Untradeable = true
	},
	["Hourglass Boat"] = {
		Icon = "rbxassetid://71270478813335",
		Price = -1,
		Description = "A boat where time moves as fast as you do!",
		Level = 1,
		MaxSpeed = 165,
		Accel = 0.25,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 3,
		BobbingSpeed = 1,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	Chair = {
		Icon = "rbxassetid://115979227935769",
		Price = -1,
		Description = "🪑 - only for da cool people.",
		Level = 1,
		MaxSpeed = 185,
		Accel = 0.5,
		TurningSpeed = 1.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		IsJetski = true,
		Unpurchasable = true,
		Untradeable = true
	},
	["Rocket Chair"] = {
		Icon = "rbxassetid://115979227935769",
		Price = -1,
		Description = "🪑 - only for da cool people.",
		Level = 1,
		MaxSpeed = 185,
		Accel = 0.5,
		TurningSpeed = 1.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true
	},
	["Elite Chair"] = {
		Icon = "rbxassetid://127700176977542",
		Price = -1,
		Description = "🔴 - Only for da elite people.",
		Level = 1,
		MaxSpeed = 220,
		Accel = 0.4,
		TurningSpeed = 2,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		IsJetski = true,
		Unpurchasable = true,
		Untradeable = true
	},
	["Really Fast Jetski"] = {
		Icon = "rbxassetid://130682434368049",
		Price = -1,
		Description = "🔴",
		Level = 1,
		MaxSpeed = 500,
		Accel = 2.95,
		TurningSpeed = 2.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true,
		Untradeable = true,
		DEV = true
	},
	["Riced Out"] = {
		Icon = "rbxassetid://111975714531807",
		Price = -1,
		Description = "who would ever do this to a car? 💀",
		Level = 1,
		MaxSpeed = 235,
		Accel = 0.5,
		TurningSpeed = 1.2,
		BackwardsEfficiency = 2,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true,
		DEV = true
	},
	["Stock Car"] = {
		Icon = "rbxassetid://111810502266139",
		Price = -1,
		Description = "thanks sno",
		Level = 1,
		MaxSpeed = 185,
		Accel = 0.4,
		TurningSpeed = 1.2,
		BackwardsEfficiency = 2,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true
	},
	Towboat = {
		Icon = "rbxassetid://134432015160761",
		Price = -1,
		Description = "Sail the seas with your trusty paddles!",
		Level = 1,
		MaxSpeed = 676.7,
		Accel = 0.67,
		TurningSpeed = 1.67,
		BackwardsEfficiency = 67,
		StopEfficiency = 67,
		Bobbing = 3,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true,
		DEV = true
	},
	["Fischmas Speedboat"] = {
		Icon = "rbxassetid://130906482985374",
		Price = -1,
		Description = "The Fischmas Speedboat!",
		Level = 1,
		ProductId = 2677594734,
		MaxSpeed = 180,
		Accel = 0.35,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.8,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Fischmas Jetski"] = {
		Icon = "rbxassetid://91906307864355",
		Price = -1,
		Description = "The Fischmas Jetski!",
		Level = 1,
		MaxSpeed = 220,
		Accel = 0.35,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.8,
		Bobbing = 2,
		BobbingSpeed = 1,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Sleigh = {
		Icon = "rbxassetid://113467920745327",
		Price = -1,
		Description = "Deliver presents at ridiculous speeds! [Only obtainable during Fischmas 2024]",
		Level = 1,
		MaxSpeed = 90,
		Accel = 0.4,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 0.85,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Reindeer Cruiser"] = {
		Icon = "rbxassetid://127716910078260",
		Price = -1,
		Description = "A ducky boat with a pretty convincing reindeer disguise. [Only obtainable during Fischmas 2024]",
		Level = 1,
		MaxSpeed = 55,
		Accel = 0.25,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 4,
		BobbingSpeed = 0.5,
		Unpurchasable = true
	},
	["Snowmobile Jetski"] = {
		Icon = "rbxassetid://132722267987667",
		Price = -1,
		Description = "Jetski frozen christmas version!",
		Level = 60,
		MaxSpeed = 200,
		Accel = 0.3,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Hollywave Cruiser"] = {
		Icon = "rbxassetid://98034431985434",
		Price = -1,
		Description = "Santa's Luxury Christmas ride!",
		Level = 1,
		ProductId = 2680232259,
		ExpirationDate = DateTime.fromUniversalTime(2025, 1, 11, 15),
		LimitedAmount = 10000,
		MaxSpeed = 230,
		Accel = 0.2,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 1,
		BobbingSpeed = 1,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Santa’s Jetski"] = {
		Icon = "rbxassetid://140332102870016",
		Price = -1,
		Description = "Santa’s Jetski christmas version!",
		Level = 1,
		ProductId = 2677594486,
		MaxSpeed = 220,
		Accel = 0.4,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Jetski = {
		Icon = "rbxassetid://129451187335290",
		Price = 50000,
		Description = "Ski around with a friend at insane speeds!",
		Level = 60,
		MaxSpeed = 180,
		Accel = 0.3,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Untradeable = true
	},
	["Giant Jetski"] = {
		Icon = "rbxassetid://84885310730899",
		Price = 1e999,
		Description = "Ski around with a friend at insane speeds!... And at a giant size!",
		Level = 1,
		MaxSpeed = 250,
		Accel = 0.1,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 0.4,
		StopEfficiency = 0.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Untradeable = true,
		Unpurchasable = true
	},
	["Mini Jetski"] = {
		Icon = "rbxassetid://76036450232117",
		Price = -1,
		Description = "it's a mystery how this can hold a person...",
		Level = 1,
		MaxSpeed = 180,
		Accel = 10,
		TurningSpeed = 1,
		BackwardsEfficiency = 2,
		StopEfficiency = 5,
		Bobbing = 0.1,
		BobbingSpeed = 0.01,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	["Mini Rowboat"] = {
		Icon = "rbxassetid://139020682081628",
		Price = -1,
		Description = "Sail the puddles with your... tiny paddles!",
		Level = 1,
		MaxSpeed = 75,
		Accel = 10,
		TurningSpeed = 1,
		BackwardsEfficiency = 2,
		StopEfficiency = 5,
		Bobbing = 0.1,
		BobbingSpeed = 0.01,
		Unpurchasable = true
	},
	Log = {
		Icon = "rbxassetid://116884082120439",
		Price = -1,
		Description = "Not ideal, maybe the current will push you?",
		Level = 1,
		MaxSpeed = 5,
		Accel = 0.1,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 2,
		StopEfficiency = 5,
		Bobbing = 1,
		BobbingSpeed = 1,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	Tree = {
		Icon = "rbxassetid://75817090979050",
		Price = -1,
		Description = "How'd you chop the whole thing down?",
		Level = 1,
		MaxSpeed = 300,
		Accel = 0.1,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 2,
		StopEfficiency = 5,
		Bobbing = 1,
		BobbingSpeed = 1,
		ForwardTilt = 2,
		SteerTilt = 6,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Giant Driftwood"] = {
		Icon = "rbxassetid://98098877674918",
		Price = -1,
		Description = "A large enough driftwood to ride on the waters!",
		Level = 1,
		MaxSpeed = 10,
		Accel = 0.2,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 2,
		StopEfficiency = 5,
		Bobbing = 1,
		BobbingSpeed = 1,
		ForwardTilt = 1,
		SteerTilt = 6,
		Unpurchasable = true
	},
	["Beach Umbrella"] = {
		Icon = "rbxassetid://130957701166808",
		Price = -1,
		Description = "Seems awfully familiar...",
		Level = 1,
		MaxSpeed = 100,
		Accel = 0.5,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.5,
		Bobbing = 3,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Baby Chick"] = {
		Icon = "rbxassetid://94770049497994",
		Price = -1,
		Description = "It's so cute!",
		Level = 1,
		MaxSpeed = 95,
		Accel = 3,
		TurningSpeed = 1,
		BackwardsEfficiency = 2,
		StopEfficiency = 5,
		Bobbing = 1,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Crimson Jetski"] = {
		Icon = "rbxassetid://73133558403581",
		Price = -1,
		Description = "Speeding on the crimson currents...",
		Level = 1,
		MaxSpeed = 190,
		Accel = 0.35,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Fishing Boat"] = {
		Icon = "rbxassetid://76012409822158",
		Price = 20000,
		Description = "A trusty boat to reel in even the biggest fish!",
		Level = 25,
		MaxSpeed = 75,
		Accel = 0.3,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1.5,
		Untradeable = true
	},
	Titan = {
		Icon = "rbxassetid://124154643224531",
		Price = 5000,
		Description = "Huh? Who would want this?",
		Level = 40,
		MaxSpeed = 45,
		Accel = 0.2,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.5,
		Bobbing = 3,
		BobbingSpeed = 1,
		Untradeable = true
	},
	["Quack Cruiser"] = {
		Icon = "rbxassetid://110958729645045",
		Price = 5000,
		Description = "This duck sailed up to the lemonade stand.",
		Level = 35,
		MaxSpeed = 45,
		Accel = 0.2,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 4,
		BobbingSpeed = 0.5,
		Untradeable = true
	},
	["Evil Quacker"] = {
		Icon = "rbxassetid://129375255775643",
		Price = -1,
		Description = "EVIL!",
		Level = -1,
		MaxSpeed = 45,
		Accel = 1,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 4,
		BobbingSpeed = 0.5,
		Unpurchasable = true
	},
	["Atlantean Quacker"] = {
		Icon = "rbxassetid://80676589364492",
		Price = -1,
		Description = "ATLANTEAN DUCK!",
		Level = -1,
		MaxSpeed = 200,
		Accel = 0.3,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 4,
		BobbingSpeed = 0.5,
		Unpurchasable = true
	},
	Pontoon = {
		Icon = "rbxassetid://126083630313652",
		Price = 20000,
		Description = "Great for parties with some buddies!",
		Level = 30,
		MaxSpeed = 40,
		Accel = 0.2,
		TurningSpeed = 0.4,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 1,
		BobbingSpeed = 1,
		Untradeable = true
	},
	["Atlantean Pontoon"] = {
		Icon = "rbxassetid://129307569555429",
		Price = -1,
		Description = "Great for parties with some atlantean buddies!",
		Level = 1,
		MaxSpeed = 160,
		Accel = 0.4,
		TurningSpeed = 0.4,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 1,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true
	},
	["Pirate Ship"] = {
		Icon = "rbxassetid://88689922648864",
		Price = 20000,
		Description = "Argggg Matey!!",
		Level = 30,
		MaxSpeed = 80,
		Accel = 0.2,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 6,
		BobbingSpeed = 3,
		BlockRacing = true,
		Untradeable = true
	},
	["Ancient Megalodon"] = {
		Icon = "rbxassetid://105722349951484",
		Price = -1,
		Description = "A little dangerous...",
		Level = 1,
		MaxSpeed = 230,
		Accel = 0.1,
		TurningSpeed = 0.4,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 6,
		BobbingSpeed = 3,
		BlockRacing = true,
		Unpurchasable = true,
		Untradeable = true
	},
	["Scarlet Pirate Ship"] = {
		Icon = "rbxassetid://89703250732386",
		Price = -1,
		Description = "For true pirates...",
		Level = 1,
		MaxSpeed = 250,
		Accel = 0.1,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 6,
		BobbingSpeed = 3,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Dr. Glimmerfin's Boat"] = {
		Icon = "rbxassetid://139332412278271",
		Price = -1,
		Description = "A research vessel typically piloted by a Dr. Glimmerfin, chasing secrets across the waves.",
		Level = 75,
		MaxSpeed = 100,
		Accel = 0.25,
		TurningSpeed = 0.33,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2.2,
		Bobbing = 2.5,
		BobbingSpeed = 3,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Holiday Steampunk Ship"] = {
		Icon = "rbxassetid://90047369440873",
		Price = -1,
		Description = "Holiday Steampunk Ship",
		Level = 1,
		ProductId = 2677594586,
		MaxSpeed = 100,
		Accel = 0.25,
		TurningSpeed = 0.33,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2.2,
		Bobbing = 2.5,
		BobbingSpeed = 3,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Witch's Broom"] = {
		Icon = "rbxassetid://106471847970260",
		Price = -1,
		Description = "Only available during FischFright-2025 [Can fly]",
		Level = 1,
		MaxSpeed = 50,
		Accel = 0.5,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 3,
		BobbingSpeed = 0.5,
		ForwardTilt = 6,
		SteerTilt = 6,
		FlyingBoat = true,
		VerticalMaxSpeed = 10,
		BlockRacing = true,
		Unpurchasable = true,
		Disruptive = true
	},
	["Crested Cloud"] = {
		Icon = "rbxassetid://102635652987234",
		Price = -1,
		Description = "Perfect for Skycrest flight! [Can fly]",
		Level = 1,
		MaxSpeed = 90,
		Accel = 0.65,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 3,
		BobbingSpeed = 0.5,
		ForwardTilt = 6,
		SteerTilt = 6,
		FlyingBoat = true,
		VerticalMaxSpeed = 30,
		BlockRacing = true,
		Unpurchasable = true,
		Untradeable = true,
		Disruptive = true
	},
	["Glorp's Saucer"] = {
		Icon = "rbxassetid://118155693356900",
		Price = -1,
		Description = "Available through Glorp's questline [Can fly]",
		Level = 1,
		MaxSpeed = 75,
		Accel = 0.75,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 3,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		FlyingBoat = true,
		CanEject = true,
		VerticalMaxSpeed = 25,
		BlockRacing = true,
		Unpurchasable = true,
		Untradeable = true,
		Disruptive = true
	},
	Bill = {
		Icon = "rbxassetid://96379439743558",
		Price = -1,
		Description = "Bill",
		Level = 1,
		MaxSpeed = 250,
		Accel = 0.5,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 0,
		BobbingSpeed = 0.5,
		FlyingBoat = true,
		VerticalMaxSpeed = 50,
		BlockRacing = true,
		Unpurchasable = true,
		Untradeable = true,
		Disruptive = true
	},
	["Flying Rowboat"] = {
		Icon = "rbxassetid://134432015160761",
		Price = -1,
		Description = "stupid [Can fly]",
		Level = 1,
		MaxSpeed = 125,
		Accel = 1,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 3,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		FlyingBoat = true,
		VerticalMaxSpeed = 50,
		BlockRacing = true,
		Untradeable = true,
		Unpurchasable = true,
		DEV = true,
		Disruptive = true
	},
	["Flying Dutchman"] = {
		Icon = "rbxassetid://86518345531497",
		Price = -1,
		Description = "Only available during FischFright-2024",
		Level = 0,
		MaxSpeed = 80,
		Accel = 0.2,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 6,
		BobbingSpeed = 3,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Reborn Flying Dutchman"] = {
		Icon = "rbxassetid://105501305851016",
		Price = -1,
		Description = "Only available during FischFright-2025",
		Level = 0,
		MaxSpeed = 250,
		Accel = 0.2,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 6,
		BobbingSpeed = 3,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Witch's Pot"] = {
		Icon = "rbxassetid://105798620146975",
		Price = -1,
		Description = "Only available during FischFright-2025",
		Level = 0,
		MaxSpeed = 145,
		Accel = 0.2,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.5,
		Bobbing = 3,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["The Pearl"] = {
		Icon = "rbxassetid://140297535873347",
		Price = 50000,
		Description = "No one knows what sails this ship...",
		Level = 90,
		MaxSpeed = 95,
		Accel = 0.2,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1,
		StopEfficiency = 3,
		Bobbing = 6,
		BobbingSpeed = 3,
		BlockRacing = true,
		Untradeable = true
	},
	["Coral Cruiser Boat"] = {
		Icon = "rbxassetid://71002238163754",
		Price = -1,
		Description = "Fischer Special Special!",
		Level = 0,
		MaxSpeed = 85,
		Accel = 0.25,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.3,
		Bobbing = 2.5,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true
	},
	["Archaeological Boat"] = {
		Icon = "rbxassetid://82626003313983",
		Price = 20000,
		Description = "Boat used by archaeologists from ancient island.",
		Level = 30,
		MaxSpeed = 80,
		Accel = 0.2,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 1,
		BobbingSpeed = 3,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Celestial Cruiser"] = {
		Icon = "rbxassetid://139280064840536",
		Price = -1,
		Description = "A high-tech cruiser infused with celestial energy.",
		Level = 1,
		ProductId = 2689989326,
		ExpirationDate = DateTime.fromUniversalTime(2025, 1, 18, 15),
		LimitedAmount = 10000,
		MaxSpeed = 230,
		Accel = 0.4,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Pride of Fisch"] = {
		Icon = "rbxassetid://126957372936382",
		Price = -1,
		Description = "A majestic mega-yacht designed for true captains.",
		Level = 1,
		MaxSpeed = 230,
		Accel = 0.2,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 1,
		BobbingSpeed = 1,
		BlockRacing = true,
		Unpurchasable = true
	},
	Dreadcurrent = {
		Icon = "rbxassetid://116986982010060",
		Price = -1,
		Description = "A titanic phantom adrift through mist and myth, its wails echo with the sorrow of sailors long swallowed by the deep.",
		Level = 1,
		MaxSpeed = 300,
		Accel = 0.2,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 1,
		BobbingSpeed = 1,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Cobalt Corsair"] = {
		Icon = "rbxassetid://99027746232066",
		Price = -1,
		Description = "Sleek and stormborn, it cuts through waves like a blade of blue steel.",
		Level = 1,
		MaxSpeed = 245,
		Accel = 0.7,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	["Skygold Sprinter"] = {
		Icon = "rbxassetid://116876239112309",
		Price = -1,
		Description = "A flash of sunlit speed, built to streak across the sea like lightning in daylight.",
		Level = 1,
		MaxSpeed = 240,
		Accel = 0.8,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Fishscale Waverider"] = {
		Icon = "rbxassetid://72839527239663",
		Price = -1,
		Description = "Insane waverider!!",
		Level = 1,
		ProductId = 2701903593,
		ExpirationDate = DateTime.fromUniversalTime(2025, 1, 25, 15),
		LimitedAmount = 10000,
		MaxSpeed = 230,
		Accel = 0.4,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Atlantean Jetski"] = {
		Icon = "rbxassetid://92057714698349",
		Price = -1,
		Description = "The Atlantean Jet Ski is a glowing, rune-etched watercraft powered by a silent crystal engine, blending speed and elegance.",
		Level = 1,
		ProductId = 2706853697,
		ExpirationDate = DateTime.fromUniversalTime(2025, 2, 1, 15),
		LimitedAmount = 15000,
		MaxSpeed = 210,
		Accel = 0.8,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Serpent Cruiser"] = {
		Icon = "rbxassetid://139476969255100",
		Price = -1,
		Description = "The Serpent Cruiser is a sleek, snake-like vessel with glowing accents, built for speed and elegance as it weaves through any terrain.",
		Level = 1,
		MaxSpeed = 180,
		Accel = 0.6,
		TurningSpeed = 0.35,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true
	},
	["Guardian of Atlantis"] = {
		Icon = "rbxassetid://127484673570168",
		Price = -1,
		Description = "The Guardian of Atlantis Boat is a majestic vessel with glowing runes and a carved guardian’s visage, gliding through waves with regal power.",
		Level = 1,
		MaxSpeed = 240,
		Accel = 0.4,
		TurningSpeed = 0.25,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 1,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Orca Boat"] = {
		Icon = "rbxassetid://123444755161419",
		Price = -1,
		Description = "The Orca Boat glides through the waves with sleek black-and-white patterns, mimicking the grace of a real life Orca.",
		Level = 1,
		MaxSpeed = 180,
		Accel = 0.6,
		TurningSpeed = 0.35,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true
	},
	Gondola = {
		Icon = "rbxassetid://86464358166303",
		Price = -1,
		Description = "HOW CAN A GONDOLA GO THIS FAST??",
		Level = 1,
		MaxSpeed = 230,
		Accel = 0.4,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 1,
		SteerTilt = 2,
		Unpurchasable = true
	},
	["Love Crasher"] = {
		Icon = "rbxassetid://121237191241453",
		Price = -1,
		Description = "What's better than spending your day on the beautiful Love Crasher?",
		Level = 1,
		ProductId = 2837613240,
		FakePrice = 4999,
		LimitedAmount = 8000,
		MaxSpeed = 190,
		Accel = 0.6,
		TurningSpeed = 0.35,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true
	},
	Submarine = {
		Icon = "rbxassetid://94549000992556",
		Price = 1500000,
		Description = "A submarine, typically used for entering only the deepest of trenches.",
		Level = 70,
		MaxSpeed = 180,
		Accel = 0.3,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		IsSubmarine = true,
		BlockRacing = true,
		Untradeable = true
	},
	["Deep City Submarine"] = {
		Icon = "rbxassetid://136804274352115",
		Price = 1e999,
		Description = "A deep city exclusive!",
		Level = 0,
		MaxSpeed = 200,
		Accel = 0.45,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		IsSubmarine = true,
		SubmarineVerticalSpeed = 75,
		BlockRacing = true,
		Untradeable = true,
		Unpurchasable = true
	},
	["VESSEL OF IMPATIENCE"] = {
		Icon = "rbxassetid://94549000992556",
		Price = 1e999,
		Description = "estimated time of arrival: NOW",
		Level = 0,
		MaxSpeed = 300,
		Accel = 0.5,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		SubmarineVerticalSpeed = 300,
		SubmarineTier = v[4],
		IsSubmarine = true,
		BlockRacing = true,
		Untradeable = true,
		Unpurchasable = true,
		DEV = true
	},
	["Volcanic Speedboat"] = {
		Icon = "rbxassetid://86384399025640",
		Price = -1,
		Description = "A fiery, high-speed vessel forged from volcanic rock and molten metal. Its sleek, ember-lined hull cuts through the water, leaving a trail of steam and glowing lava streaks in its wake.",
		Level = 1,
		ProductId = 2954379627,
		LimitedAmount = 5000,
		FakePrice = 4999,
		MaxSpeed = 210,
		Accel = 0.6,
		TurningSpeed = 0.35,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true
	},
	["Molten Jetski"] = {
		Icon = "rbxassetid://95003767264216",
		Price = -1,
		Description = "A compact, agile watercraft built from obsidian and infused with the raw power of an erupting volcano.",
		Level = 1,
		MaxSpeed = 235,
		Accel = 0.6,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["The Mawrider"] = {
		Icon = "rbxassetid://134058280576237",
		Price = -1,
		Description = "Deep-sea vessel inspired by the elusive anglerfish.",
		Level = 1,
		ProductId = 3221390711,
		FakePrice = 4999,
		LimitedAmount = 5000,
		MaxSpeed = 230,
		Accel = 0.6,
		TurningSpeed = 0.65,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true
	},
	["Dead Fish Express"] = {
		Icon = "rbxassetid://96513560079594",
		Price = -1,
		Description = "A haunting skeletal vessel shaped like the remains of a giant fish, its hollow bones creaking as it drifts through the waters.",
		Level = 1,
		MaxSpeed = 190,
		Accel = 0.6,
		TurningSpeed = 0.4,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Camera Boat"] = {
		Icon = "rbxassetid://98664846868494",
		Price = -1,
		Description = "Lights, camera, action!",
		Level = 1,
		MaxSpeed = 200,
		Accel = 0.6,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.25,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true,
		Untradeable = true,
		DEV = true
	},
	["Crag-Craboat"] = {
		Icon = "rbxassetid://130741704886835",
		Price = -1,
		Description = "[Rewarded to Content Creators for promoting the Scoria Reach Update]",
		Level = 1,
		MaxSpeed = 500,
		Accel = 0.1,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.25,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true,
		Untradeable = true,
		DEV = true
	},
	["Flipper Express"] = {
		Icon = "rbxassetid://94391641146651",
		Price = -1,
		Description = "The ultimate whale-inspired luxury yacht! With a sleek, fin-like design and a powerful tail-shaped stern, it glides through the waves with effortless grace.",
		Level = 1,
		MaxSpeed = 245,
		Accel = 0.4,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 1,
		BobbingSpeed = 1,
		BlockRacing = true,
		Unpurchasable = true,
		SpawnOffset = 50
	},
	["Toro Veloce"] = {
		Icon = "rbxassetid://134110214330233",
		Price = -1,
		Description = "A sleek, high-speed sports jetski with cutting-edge design—ride the waves like a champion!",
		Level = 1,
		ProductId = 3231808129,
		FakePrice = 4999,
		LimitedAmount = 15000,
		MaxSpeed = 240,
		Accel = 0.6,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Red Racer"] = {
		Icon = "rbxassetid://137758255643127",
		Price = -1,
		Description = "A luxurious speedboat built for thrill and elegance, combining elite craftsmanship with unmatched velocity on the water.",
		Level = 1,
		MaxSpeed = 225,
		Accel = 0.25,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Lucky Pot"] = {
		Icon = "rbxassetid://122341403504224",
		Price = -1,
		Description = "Huh? I'm a lucky guy",
		Level = 1,
		MaxSpeed = 100,
		Accel = 0.2,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.5,
		Bobbing = 3,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Lucky Racer"] = {
		Icon = "rbxassetid://103178311237682",
		Price = -1,
		Description = "Feeling Lucky? Take this out for a spin...",
		Level = 1,
		ProductId = 3238002239,
		FakePrice = 4999,
		LimitedAmount = 15000,
		MaxSpeed = 235,
		Accel = 0.8,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Irish Jig"] = {
		Icon = "rbxassetid://93666916290774",
		Price = -1,
		Description = "A lively vessel that dances upon the waves like a true Celtic tune! The Irish Jig is a vibrant and sturdy boat, built for both adventure and celebration.",
		Level = 1,
		MaxSpeed = 228,
		Accel = 0.6,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1.5,
		StopEfficiency = 1.4,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Cursed Rowboat"] = {
		Icon = "rbxassetid://106746141538836",
		Price = -1,
		Description = "Row boat Small, cracked black wood with glowing blue runes. Oars twitch slightly. Surrounded by faint whispers.",
		Level = 1,
		MaxSpeed = 155,
		Accel = 0.25,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 3,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Cursed Banner Ship"] = {
		Icon = "rbxassetid://108455660194348",
		Price = -1,
		Description = "Sail in eerie style with the Cursed Banner — a sleek, dark ship glowing with haunting blue runes. Perfect for those who command the seas with a touch of mystery.",
		Level = 1,
		MaxSpeed = 200,
		Accel = 0.35,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.8,
		Bobbing = 2,
		BobbingSpeed = 1,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Windsurfer Boast"] = {
		Icon = "rbxassetid://75258416199056",
		Price = 1000000,
		Description = "",
		Level = 800,
		MaxSpeed = 190,
		Accel = 0.65,
		TurningSpeed = 0.65,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		Untradeable = true
	},
	["Cursed Rider"] = {
		Icon = "rbxassetid://127115059814209",
		Price = 2000000,
		Description = "",
		Level = 900,
		MaxSpeed = 200,
		Accel = 0.7,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		Untradeable = true
	},
	Airboat = {
		Icon = "rbxassetid://118034141225193",
		Price = 5000000,
		Description = "",
		Level = 1000,
		MaxSpeed = 210,
		Accel = 0.75,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		Untradeable = true
	},
	["Curse III"] = {
		Icon = "rbxassetid://90591412447366",
		Price = -1,
		Description = "The third in a line of vessels never meant to survive, Curse III is a razor-fast nightmare—armored in scorched plating, pulsing with unstable energy, and tuned to outrun whatever follows.",
		Level = 1,
		ProductId = 3250004378,
		FakePrice = 4999,
		LimitedAmount = 10000,
		MaxSpeed = 255,
		Accel = 0.8,
		TurningSpeed = 0.9,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Dreamers Redemption"] = {
		Icon = "rbxassetid://86672689180561",
		Price = -1,
		Description = "A weathered vessel reborn from forgotten dreams, the Dreamer’s Redemption carries those who still believe the sea can forgive.",
		Level = 1,
		MaxSpeed = 235,
		Accel = 0.4,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 1,
		BobbingSpeed = 1,
		BlockRacing = true,
		Unpurchasable = true,
		SpawnOffset = 50
	},
	["Cthulu's Cranium"] = {
		Price = -1,
		Description = "What else is cooler than surfing the waves in the dreamers head?",
		Level = 1,
		Icon = "rbxassetid://70671327958329",
		MaxSpeed = 140,
		Accel = 0.3,
		TurningSpeed = 0.45,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		Unpurchasable = true
	},
	["Lion's Fury"] = {
		Icon = "rbxassetid://73233180943848",
		Price = -1,
		Description = "Lion’s Fury - Golden lion-shaped jetski. Fast, loud, and wild.",
		Level = 1,
		ProductId = 3256916204,
		FakePrice = 4999,
		LimitedAmount = 15000,
		MaxSpeed = 235,
		Accel = 0.7,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true
	},
	["S.S. Tuskhorn"] = {
		Icon = "rbxassetid://117064100317202",
		Price = -1,
		Description = "Carved elephant-head war boat. Heavy, ancient, unshakable.",
		Level = 1,
		MaxSpeed = 200,
		Accel = 0.6,
		TurningSpeed = 0.4,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true,
		Untradeable = true
	},
	["King’s Throne"] = {
		Icon = "rbxassetid://127922702096875",
		Price = -1,
		Description = "A royal vessel, fit for a King!",
		Level = 1,
		MaxSpeed = 230,
		Accel = 0.2,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Bunny Jetski"] = {
		Icon = "rbxassetid://137056616134430",
		Price = -1,
		Description = "Unstoppable Easter joy!",
		Level = 1,
		MaxSpeed = 245,
		Accel = 0.9,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Small Utility Boat"] = {
		Icon = "rbxassetid://108811112310028",
		Price = 50000,
		Description = "A lightweight utility boat, made for short trips and simple work.",
		Level = 1,
		MaxSpeed = 80,
		Accel = 0.15,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		IsUtility = true,
		UtilityTier = 1,
		BlockRacing = true,
		Unpurchasable = false,
		Untradeable = true
	},
	["Medium Utility Boat"] = {
		Icon = "rbxassetid://101438175950563",
		Price = 250000,
		Description = "A balanced and reliable vessel, designed for strenuous tasks and moderate work.",
		Level = 1,
		MaxSpeed = 110,
		Accel = 0.25,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		IsUtility = true,
		UtilityTier = 2,
		BlockRacing = true,
		Unpurchasable = false,
		Untradeable = true
	},
	["Large Utility Boat"] = {
		Icon = "rbxassetid://83785780610841",
		Price = 500000,
		Description = "Highly strong and capable, built for heavy-duty tasks.",
		Level = 1,
		MaxSpeed = 150,
		Accel = 0.3,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		IsUtility = true,
		UtilityTier = 3,
		BlockRacing = true,
		Unpurchasable = false,
		Untradeable = true
	},
	["Huge Utility Boat"] = {
		Icon = "rbxassetid://99089060153627",
		Price = 1500000,
		Description = "A massive vessel built for pure strength, it handles major hauling tasks.",
		Level = 1,
		MaxSpeed = 190,
		Accel = 0.35,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		IsUtility = true,
		UtilityTier = 4,
		BlockRacing = true,
		Unpurchasable = false,
		Untradeable = true,
		SpawnOffset = 30
	},
	["Easter Basket"] = {
		Icon = "rbxassetid://125990379782355",
		Price = -1,
		Description = "Ride through Easter in style!",
		Level = 1,
		MaxSpeed = 190,
		Accel = 0.35,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Desolate Dragon"] = {
		Icon = "rbxassetid://117449588157233",
		Price = -1,
		Description = "Ride on the almighty fury of the Desolate Dragon.",
		Level = 1,
		ProductId = 3268963621,
		FakePrice = 4999,
		LimitedAmount = 25000,
		MaxSpeed = 230,
		Accel = 0.2,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1.2,
		StopEfficiency = 1.8,
		Bobbing = 2.2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Arctic Explorer"] = {
		Icon = "rbxassetid://106886543519092",
		Price = -1,
		Description = "LEGO Arctic Explorer Ship",
		Level = 1,
		MaxSpeed = 100,
		Accel = 0.25,
		TurningSpeed = 0.33,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2.2,
		Bobbing = 1.5,
		BobbingSpeed = 1.5,
		BlockRacing = true,
		Unpurchasable = true,
		SpawnOffset = 30
	},
	["Explorer Diving Boat"] = {
		Icon = "rbxassetid://104314152947635",
		Price = 0,
		Description = "LEGO Explorer Diving Boat",
		Level = 32,
		MaxSpeed = 150,
		Accel = 0.65,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Nessie Nomad"] = {
		Icon = "rbxassetid://85764098603565",
		Price = -1,
		Description = "Ride this legendary beast wherever the currents calls!",
		Level = 1,
		MaxSpeed = 220,
		Accel = 0.6,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.5,
		StopEfficiency = 3,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true
	},
	Dumbo = {
		Icon = "rbxassetid://138183995060934",
		Price = -1,
		Description = "The most fearsome vessel with the face of a cuddle... Don’t let the eyes fool you, this ship bites back.",
		Level = 1,
		LimitedAmount = 25000,
		ProductId = 3273792404,
		FakePrice = 4999,
		MaxSpeed = 245,
		Accel = 0.9,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	Clawberus = {
		Icon = "rbxassetid://87636758084219",
		Price = -1,
		Description = "A monstrous triple clawed lobster vessel forged from myth and salt, built to drag legends to the surface.",
		Level = 1,
		MaxSpeed = 180,
		Accel = 0.35,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.8,
		Bobbing = 2,
		BobbingSpeed = 1,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	Puffernaut = {
		Icon = "rbxassetid://139108850838086",
		Price = -1,
		Description = "Stuffed like a fishball and brave like a bean, this bloated beauty puffs its way where no bubble should go.",
		Level = 1,
		ProductId = 3278181273,
		FakePrice = 4999,
		LimitedAmount = 20000,
		MaxSpeed = 200,
		Accel = 0.3,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		IsSubmarine = true,
		SubmarineVerticalSpeed = 100,
		BlockRacing = true,
		Unpurchasable = true
	},
	Whaleski = {
		Icon = "rbxassetid://97509675338919",
		Price = -1,
		Description = "What’s faster than a whale in the ocean? Ride your Whaleski and fly right past your friends!",
		Level = 1,
		MaxSpeed = 245,
		Accel = 0.9,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Silent Speeder"] = {
		Icon = "rbxassetid://119932849004727",
		Price = -1,
		Description = "Cut through the waves with the Silent Speeder, a stealthy high-speed boat built for sleek escapes and smooth cruising.",
		Level = 1,
		ProductId = 3287040610,
		FakePrice = 1499,
		LimitedAmount = 20000,
		MaxSpeed = 240,
		Accel = 0.9,
		TurningSpeed = 0.9,
		BackwardsEfficiency = 1.5,
		StopEfficiency = 2,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Blue Cat"] = {
		Icon = "rbxassetid://76479620423317",
		Price = -1,
		Description = "Experience smooth sailing in style with the Blue Cat, a medium sized luxury boat purring with elegance.",
		Level = 1,
		MaxSpeed = 235,
		Accel = 0.8,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Vintage Hatchboat"] = {
		Icon = "rbxassetid://92775381082833",
		Price = -1,
		Description = "A classic sea cruiser with classy charm and retro flair, built for big ballers and big hauls.",
		Level = 1,
		MaxSpeed = 200,
		Accel = 0.6,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 3.5,
		Bobbing = 3,
		BobbingSpeed = 0.3,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Tri-Brick Rider"] = {
		Icon = "rbxassetid://111237769377148",
		Price = -1,
		Description = "A sleek, triple thrust vessel built for rapid waveskimming, perfect for chasing the next big catch.",
		Level = 1,
		ProductId = 3291165284,
		LimitedAmount = 40000,
		FakePrice = 1499,
		MaxSpeed = 230,
		Accel = 1,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.5,
		Bobbing = 1.5,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Bloop Boat"] = {
		Icon = "rbxassetid://111447839171751",
		Price = -1,
		Description = "???",
		Level = 1,
		MaxSpeed = 225,
		Accel = 0.25,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true,
		BlockRacing = true,
		Disruptive = true,
		FreeMovement = true,
		StupidPhysics = true,
		NoMomentumLossOnImpact = true
	},
	["Fish Bowl"] = {
		Icon = "rbxassetid://120431486261915",
		Price = -1,
		Description = "A glass domed speed bowl that lets you ride the waves like you're in your own aquatic exhibit.",
		Level = 1,
		MaxSpeed = 240,
		Accel = 0.6,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.1,
		Unpurchasable = true
	},
	["Crew-ser"] = {
		Icon = "rbxassetid://140417733107749",
		Price = 250000,
		CrewRatingRequirement = 20000,
		Description = "For the full crew!",
		Level = 500,
		MaxSpeed = 250,
		Accel = 0.3,
		TurningSpeed = 0.32,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 6,
		BobbingSpeed = 3,
		BlockRacing = true,
		Untradeable = true
	},
	["Ghosts Pirate Ship"] = {
		Icon = "rbxassetid://84575570131047",
		Price = -1,
		Description = "Silent, deadly, cursed forever. [Ghosts faction max rank vessel]",
		Level = 1,
		MaxSpeed = 320,
		Accel = 0.25,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 6,
		BobbingSpeed = 3,
		BlockRacing = true,
		Unpurchasable = true,
		Untradeable = true
	},
	["Marauder Ship"] = {
		Icon = "rbxassetid://85241378337056",
		Price = -1,
		Description = "Fast, fierce, unstoppable. [Midas' Mates faction max rank vessel]",
		Level = 1,
		MaxSpeed = 250,
		Accel = 0.2,
		TurningSpeed = 0.25,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 6,
		BobbingSpeed = 3,
		BlockRacing = true,
		Unpurchasable = true,
		Untradeable = true
	},
	["Red Marlins Ship"] = {
		Icon = "rbxassetid://91179825470447",
		Price = -1,
		Description = "Red sails, no survivors. [Red Marlins faction max rank vessel]",
		Level = 1,
		MaxSpeed = 210,
		Accel = 0.15,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 6,
		BobbingSpeed = 3,
		BlockRacing = true,
		Unpurchasable = true,
		Untradeable = true
	},
	["Aquarium Boat"] = {
		Icon = "rbxassetid://93687303900702",
		Price = 20000,
		Description = "I have an aquarium!",
		Level = 1,
		MaxSpeed = 150,
		Accel = 0.3,
		TurningSpeed = 0.54,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		IsJetski = true,
		Unpurchasable = true,
		Untradeable = true
	},
	["The Essex Boat"] = {
		Icon = "rbxassetid://98242807552885",
		Price = -1,
		Description = "Crafted for thrilling adventures, this Jurassic World-themed boat is built for exploring untamed waters with a prehistoric edge.",
		Level = 1,
		MaxSpeed = 250,
		Accel = 0.6,
		TurningSpeed = 0.54,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 3,
		BobbingSpeed = 1,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Smurf Boat"] = {
		Icon = "rbxassetid://107978832723436",
		Price = -1,
		Description = "The Official Smurf Boat!",
		Level = 1,
		MaxSpeed = 200,
		Accel = 0.5,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true
	},
	["Orange Unicycle"] = {
		Icon = "rbxassetid://119550165521495",
		Price = -1,
		Description = "One wheeled orange beauty built for balance and undeniable style.",
		Level = 1,
		ProductId = 3301481855,
		FakePrice = 1499,
		LimitedAmount = 20000,
		MaxSpeed = 180,
		Accel = 0.3,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	Hoverslime = {
		Icon = "rbxassetid://106516837415800",
		Price = -1,
		Description = "This is a futuristic slime boat! covered in dripping neon-green slime.",
		Level = 1,
		ProductId = 3311964710,
		FakePrice = 1499,
		LimitedAmount = 20000,
		MaxSpeed = 180,
		Accel = 0.3,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	["Popsicle Jetski"] = {
		Icon = "rbxassetid://131282114800723",
		Price = -1,
		Description = "Cool off in style; this frosty ride turns every wave into a sweet escape.",
		Level = 1,
		ProductId = 3324354033,
		FakePrice = 1999,
		LimitedAmount = 2500,
		MaxSpeed = 250,
		Accel = 0.7,
		TurningSpeed = 0.95,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Elysian Jolt"] = {
		Icon = "rbxassetid://105222654240996",
		Price = -1,
		Description = "A blur of light and silence; seen too late, gone too soon.",
		Level = 1,
		ProductId = 3330350469,
		FakePrice = 3199,
		LimitedAmount = 1200,
		MaxSpeed = 260,
		Accel = 0.8,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Inky Pal"] = {
		Icon = "rbxassetid://90969307755830",
		Price = -1,
		Description = "Bobbing cheerfully on the waves, this playful squid leaves behind a trail of bubbly ink and endless joy!",
		Level = 1,
		MaxSpeed = 245,
		Accel = 0.7,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.1,
		Unpurchasable = true
	},
	["Curse IV"] = {
		Icon = "rbxassetid://83529303349813",
		Price = -1,
		Description = "Forged in the shadow of its predecessor, Curse IV is a spectral blur of menace and velocity-clad in jagged, void-kissed armor, thrumming with a volatile pulse that defies containment, built to slip through the jaws of fate itself.",
		Level = 1,
		ProductId = 3338757372,
		FakePrice = 3799,
		LimitedAmount = 1000,
		MaxSpeed = 265,
		Accel = 0.85,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Banana Cruiser"] = {
		Icon = "rbxassetid://125038563008473",
		Price = -1,
		Description = "Splash into the ocean with our Banana Cruiser! An aerodynamic, tropical watercraft designed to capture the sweet Summer season.",
		Level = 1,
		MaxSpeed = 240,
		Accel = 1.1,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.1,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Meowmobile = {
		Icon = "rbxassetid://106311545459291",
		Price = -1,
		Description = "An adorable, cuddly kitty balancing on a fluffy ball of yarn! Roll thru' the ocean while driving this kitty and her favorite toy!",
		Level = 1,
		MaxSpeed = 245,
		Accel = 1.5,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 0.1,
		IsJetski = true,
		Unpurchasable = true
	},
	["Kraken of the Void"] = {
		Icon = "rbxassetid://110936424777607",
		Price = -1,
		Description = "A cosmic leviathan draped in shadow and silence, it rends reality itself with every rise from the fathomless dark. Once a sovereign; now a void-corrupted echo of a throne long drowned.",
		Level = 1,
		ProductId = 3346989166,
		FakePrice = 3599,
		LimitedAmount = 1500,
		MaxSpeed = 260,
		Accel = 0.9,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Captain's Goldfish"] = {
		Icon = "rbxassetid://87054703495104",
		Price = -1,
		Description = "A gleaming boat lovingly modeled after the captain's own pet goldfish, blending nautical charm with a splash of personality.",
		Level = 1,
		MaxSpeed = 200,
		Accel = 1,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3.7,
		Bobbing = 2,
		BobbingSpeed = 0.1,
		Unpurchasable = true
	},
	["Sushi-Rider"] = {
		Icon = "rbxassetid://109283579319074",
		Price = -1,
		Description = "Ride the waves on a wasabi-fueled jetstream with the Sushi-Rider; fresh, fast, and dangerously delicious.",
		Level = 1,
		MaxSpeed = 230,
		Accel = 1.6,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 0.1,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	["Black Comet"] = {
		Icon = "rbxassetid://79864326273860",
		Price = -1,
		Description = "Streak across the waves like a falling star; the Black Comet leaves only darkness in its wake...",
		Level = 1,
		ProductId = 3355198363,
		FakePrice = 3899,
		LimitedAmount = 1250,
		MaxSpeed = 270,
		Accel = 0.8,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Driftblub = {
		Icon = "rbxassetid://120040570276125",
		Price = -1,
		Description = "Blobbing...",
		Level = 1,
		MaxSpeed = 195,
		Accel = 0.4,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true
	},
	Demonwake = {
		Icon = "rbxassetid://81319792737758",
		Price = -1,
		Description = "Its wake trails with silent screams, swallowed by the sea before they're heard...",
		Level = 1,
		ProductId = 3363580606,
		FakePrice = 3599,
		LimitedAmount = 1500,
		MaxSpeed = 265,
		Accel = 0.9,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		IsJetski = true,
		Unpurchasable = true
	},
	["Cuddly Claw"] = {
		Icon = "rbxassetid://90334984370780",
		Price = -1,
		Description = "Sail away in a floating claw machine, brimming with cuddly plushies just waiting to be won!",
		Level = 1,
		MaxSpeed = 235,
		Accel = 1.55,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 0.1,
		Unpurchasable = true
	},
	Nocturne = {
		Icon = "rbxassetid://104260287643249",
		Price = -1,
		Description = "The dark whisper that stalks the midnight tide...",
		Level = 1,
		ProductId = 3372328768,
		FakePrice = 4099,
		LimitedAmount = 1250,
		MaxSpeed = 275,
		Accel = 0.85,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Sunny Ducky"] = {
		Icon = "rbxassetid://127740682057615",
		Price = -1,
		Description = "A chill duck floatie boat rocking beach shades, perfect for cruising sunny waves in style!",
		Level = 1,
		MaxSpeed = 225,
		Accel = 1.75,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 0.1,
		Unpurchasable = true
	},
	["Reef Ripper"] = {
		Icon = "rbxassetid://73264347167008",
		Price = -1,
		Description = "Carve through vicious waves with razor-edged speed! Old markings crawl along its scarred frame, a testament to battles fought with the sea.",
		Level = 1,
		MaxSpeed = 215,
		Accel = 0.75,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true
	},
	Crab = {
		Icon = "rbxassetid://126771105635898",
		Price = -1,
		Description = "quite the big crab...",
		Level = 1,
		MaxSpeed = 100,
		Accel = 5,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true
	},
	["Warp Star"] = {
		Icon = "rbxassetid://109247021565454",
		Price = -1,
		Description = "⭐",
		Level = 1,
		MaxSpeed = 200,
		Accel = 1,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	Mosslurker = {
		Icon = "rbxassetid://118394743462568",
		Price = -1,
		Description = "An ancient, moss-draped titan; now tamed for riding!",
		Level = 1,
		MaxSpeed = 250,
		Accel = 0.85,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 2,
		Unpurchasable = true
	},
	Evangeline = {
		Icon = "rbxassetid://97571176415524",
		Price = -1,
		Description = "The light hymn that guides the dawnlit sea...",
		Level = 1,
		ProductId = 3379910474,
		FakePrice = 3899,
		LimitedAmount = 1500,
		MaxSpeed = 270,
		Accel = 0.9,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	["Sandslasher Boat"] = {
		Icon = "rbxassetid://107928250302719",
		Price = -1,
		Description = "A big scary worm thing.",
		Level = 1,
		MaxSpeed = 300,
		Accel = 0.2,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	Mossjaw = {
		Icon = "rbxassetid://129498791494514",
		Price = -1,
		Description = "You've tamed a Mossjaw!... How well does it ride?",
		Level = 1,
		MaxSpeed = 300,
		Accel = 0.2,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		BlockRacing = true,
		Unpurchasable = true,
		Untradeable = true
	},
	Meteor = {
		Icon = "rbxassetid://81699504594864",
		Price = -1,
		Description = "💥",
		Level = 1,
		MaxSpeed = 1e999,
		Accel = 0.05,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 0.01,
		Bobbing = 0,
		BobbingSpeed = 0,
		ForwardTilt = 0,
		SteerTilt = 6,
		NoMomentumLossOnImpact = true,
		Unpurchasable = true,
		Untradeable = true
	},
	Magnet = {
		Icon = "rbxassetid://127635918006645",
		Price = -1,
		Description = "Doesn't seem very effective for boating...",
		Level = 1,
		MaxSpeed = 10,
		Accel = 5,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 5,
		Bobbing = 0,
		BobbingSpeed = 0,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true,
		Untradeable = true
	},
	["Mini Crowned Anglerfish"] = {
		Icon = "rbxassetid://92377448534492",
		Price = -1,
		Description = "Small, yet still dangerous...",
		Level = 1,
		MaxSpeed = 140,
		Accel = 3,
		TurningSpeed = 1,
		BackwardsEfficiency = 1,
		StopEfficiency = 5,
		Bobbing = 3,
		BobbingSpeed = 2,
		Unpurchasable = true,
		Untradeable = true
	},
	Dreadmarrow = {
		Icon = "rbxassetid://120051046622713",
		Price = -1,
		Description = "Dread forged from bone and bound in cursed chains, its fangs hunger for the abyss. Those who sail it are forever tethered to the dread that stirs beneath the waves...",
		Level = 1,
		ProductId = 3388723099,
		FakePrice = 4099,
		LimitedAmount = 1650,
		MaxSpeed = 280,
		Accel = 0.85,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Carrot Hopper"] = {
		Icon = "rbxassetid://115518713139810",
		Price = -1,
		Description = "A playful carrot bunny born from the lush rows of the Carrot Garden!",
		Level = 1,
		MaxSpeed = 240,
		Accel = 1,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 0.1,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Pastel Impulse"] = {
		Icon = "rbxassetid://100395693600042",
		Price = -1,
		Description = "A vessel born of shifting light, painted in endless hues; it sails as though chasing the horizon’s eternal rainbow.",
		Level = 1,
		ProductId = 3395832950,
		FakePrice = 3799,
		LimitedAmount = 1500,
		MaxSpeed = 275,
		Accel = 0.9,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Fisch Jet"] = {
		Icon = "rbxassetid://75366341515770",
		Price = -1,
		Description = "A sleek engine of momentum, built to tear through boundless waters!",
		Level = 1,
		MaxSpeed = 270,
		Accel = 0.7,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 0.1,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	["Violet Viper"] = {
		Icon = "rbxassetid://140470980522712",
		Price = -1,
		Description = "A razor-fast cyber boat wrapped in violet light; strikes the waves with deadly speed...",
		Level = 1,
		ProductId = 3402362897,
		FakePrice = 4099,
		LimitedAmount = 2000,
		MaxSpeed = 280,
		Accel = 0.85,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Purrari = {
		Icon = "rbxassetid://117729503245185",
		Price = -1,
		Description = "The Purrari; fast, playful, and full of personality!",
		Level = 1,
		MaxSpeed = 250,
		Accel = 1,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 10,
		IsJetski = true,
		Unpurchasable = true
	},
	Pantheress = {
		Icon = "rbxassetid://72518039573703",
		Price = -1,
		Description = "Sleek but sturdy boat radiating in feline power, rendered in brilliant pink lights; slicing through the current swiftly...",
		Level = 1,
		ProductId = 3408780955,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 285,
		Accel = 0.8,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		IsJetski = true,
		Unpurchasable = true
	},
	Waffle = {
		Icon = "rbxassetid://140412578953176",
		Price = -1,
		Description = "yummy!",
		Level = 1,
		MaxSpeed = 245,
		Accel = 1.2,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 0.1,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Sharkie Floatie"] = {
		Icon = "rbxassetid://104659968533700",
		Price = -1,
		Description = "chomp!",
		Level = 1,
		MaxSpeed = 245,
		Accel = 1.2,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 0.1,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Novaris = {
		Icon = "rbxassetid://112973090688508",
		Price = -1,
		Description = "A streamlined jetski forged of starlight and steel, its frame glimmers with shifting constellations as cosmic trails of neon blue and violet flare in its wake; riding it feels like carving straight through the fabric of the galaxy...",
		Level = 1,
		ProductId = 3415384709,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 285,
		Accel = 0.8,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Mecha Ray"] = {
		Icon = "rbxassetid://84127727922563",
		Price = -1,
		Description = "The Mecha Ray tears through the ocean at blistering speed, its armored frame built for raw, unstoppable power. A predator of metal and momentum, nothing outpaces its strike...",
		Level = 1,
		ProductId = 3421394004,
		FakePrice = 4099,
		LimitedAmount = 15000,
		MaxSpeed = 288,
		Accel = 0.78,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	["Macabre Mistress"] = {
		Icon = "rbxassetid://134759812744575",
		Price = -1,
		Description = "A sleek black phantom streaking across the water, leaving trails of pink fury in its wake. Born of midnight and menace, it rules the waves with deadly speed.",
		Level = 1,
		ProductId = 3427566517,
		FakePrice = 4099,
		LimitedAmount = 15000,
		MaxSpeed = 285,
		Accel = 0.8,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		Unpurchasable = true
	},
	["Sleepy Bear"] = {
		Icon = "rbxassetid://127181966135463",
		Price = -1,
		Description = "Don't wake him!",
		Level = 1,
		MaxSpeed = 245,
		Accel = 1.55,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 2,
		Unpurchasable = true
	},
	["Little Boo"] = {
		Icon = "rbxassetid://106522534076570",
		Price = -1,
		Description = "Boo!",
		Level = 1,
		MaxSpeed = 245,
		Accel = 1.55,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 2,
		Unpurchasable = true
	},
	["Candy Crawlie"] = {
		Icon = "rbxassetid://111567114319071",
		Price = -1,
		Description = "so cuddly.. so sweet.. so creepy!",
		Level = 1,
		MaxSpeed = 250,
		Accel = 1.55,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0,
		BobbingSpeed = 0.1,
		Unpurchasable = true
	},
	["Mummy Puppy"] = {
		Icon = "rbxassetid://94671599919126",
		Price = -1,
		Description = "wrapped in cuteness!",
		Level = 1,
		MaxSpeed = 240,
		Accel = 1.2,
		TurningSpeed = 0.85,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 0,
		SteerTilt = 3,
		Unpurchasable = true
	},
	["Lotus Boat"] = {
		Icon = "rbxassetid://95640290890526",
		Price = -1,
		Description = "blooming along the waves..",
		Level = 1,
		MaxSpeed = 233,
		Accel = 1.1,
		TurningSpeed = 0.77,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		Unpurchasable = true
	},
	Axofloatie = {
		Icon = "rbxassetid://85867502998281",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 235,
		Accel = 1.13,
		TurningSpeed = 0.65,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Mr. Thankful"] = {
		Icon = "rbxassetid://96565898569609",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 244,
		Accel = 1.12,
		TurningSpeed = 0.77,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true,
		Untradeable = true
	},
	["Mega Seal"] = {
		Icon = "rbxassetid://122459706799709",
		Price = -1,
		Description = "aar aar aar!",
		Level = 1,
		MaxSpeed = 244,
		Accel = 1.12,
		TurningSpeed = 0.77,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Chilly Cub"] = {
		Icon = "rbxassetid://137174431632061",
		Price = -1,
		Description = "roarrrrr",
		Level = 1,
		MaxSpeed = 244,
		Accel = 1.12,
		TurningSpeed = 0.77,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		IsJetski = true,
		Unpurchasable = true
	},
	Pengu = {
		Icon = "rbxassetid://103804678464448",
		Price = -1,
		Description = "awwwe",
		Level = 1,
		MaxSpeed = 255,
		Accel = 1.15,
		TurningSpeed = 0.77,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	Gingerpresent = {
		Icon = "rbxassetid://122267751620421",
		Price = -1,
		Description = "perfectly yummy gift for the holiday season :)",
		Level = 1,
		MaxSpeed = 260,
		Accel = 1.2,
		TurningSpeed = 0.77,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	["Cozy Sled"] = {
		Icon = "rbxassetid://88786925449008",
		Price = -1,
		Description = "only a little canadian :)",
		Level = 1,
		MaxSpeed = 245,
		Accel = 1.2,
		TurningSpeed = 0.77,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		Unpurchasable = true
	},
	["Tubert Beetle"] = {
		Icon = "rbxassetid://122141862640708",
		Price = -1,
		Description = "my special friend",
		Level = 1,
		MaxSpeed = 255,
		Accel = 1.2,
		TurningSpeed = 0.77,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	["Burger Buggy"] = {
		Icon = "rbxassetid://75953771302852",
		Price = -1,
		Description = "om nom nom",
		Level = 1,
		MaxSpeed = 266,
		Accel = 1.2,
		TurningSpeed = 0.85,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Evil Meows"] = {
		Icon = "rbxassetid://76021464068209",
		Price = -1,
		Description = "hiss!",
		Level = 1,
		MaxSpeed = 270,
		Accel = 1.2,
		TurningSpeed = 0.85,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Angelic Meows"] = {
		Icon = "rbxassetid://131603178551228",
		Price = -1,
		Description = "that other guy is evil...",
		Level = 1,
		MaxSpeed = 270,
		Accel = 1.2,
		TurningSpeed = 0.85,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Mourning Bloom"] = {
		Icon = "rbxassetid://129098677483078",
		Price = -1,
		Description = "soft and mauve; all must enjoy their final resting place...",
		Level = 1,
		MaxSpeed = 277,
		Accel = 1.2,
		TurningSpeed = 0.88,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		Unpurchasable = true
	},
	Lovebyte = {
		Icon = "rbxassetid://72677796669124",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 277,
		Accel = 1.2,
		TurningSpeed = 0.88,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		IsJetski = true,
		Unpurchasable = true
	},
	["Lovely Locket"] = {
		Icon = "rbxassetid://96333032298655",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 275,
		Accel = 1.25,
		TurningSpeed = 0.88,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	["Lovely Key"] = {
		Icon = "rbxassetid://115331824543502",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 275,
		Accel = 1.25,
		TurningSpeed = 0.88,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Lumalee = {
		Icon = "rbxassetid://128547861644482",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 277,
		Accel = 1.27,
		TurningSpeed = 0.77,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		Unpurchasable = true
	},
	["Petal Power"] = {
		Icon = "rbxassetid://138380134691066",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 275,
		Accel = 1.25,
		TurningSpeed = 0.78,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		Unpurchasable = true
	},
	["Lily of Glacia"] = {
		Icon = "rbxassetid://107591456700746",
		Price = -1,
		Description = "lost in the ice, may these flowers bloom one last time...",
		Level = 1,
		ProductId = 3546669120,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 306,
		Accel = 1.29,
		TurningSpeed = 1.27,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Frutiger Tunes"] = {
		Icon = "rbxassetid://120715987608223",
		Price = -1,
		Description = "from the metro station to the marina!",
		Level = 1,
		ProductId = 3551127632,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 305,
		Accel = 1.3,
		TurningSpeed = 1.25,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Red Riff Kitty"] = {
		Icon = "rbxassetid://128384560334947",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 277,
		Accel = 1.25,
		TurningSpeed = 0.78,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Pink Rebel Kitty"] = {
		Icon = "rbxassetid://106123277537012",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 277,
		Accel = 1.25,
		TurningSpeed = 0.78,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Iridescence = {
		Icon = "rbxassetid://106752957252772",
		Price = -1,
		Description = "rainbowww...",
		Level = 1,
		ProductId = 3555898725,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 303,
		Accel = 1.27,
		TurningSpeed = 1.27,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	["Doze-y-odon"] = {
		Icon = "rbxassetid://71401692459666",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 277,
		Accel = 1.25,
		TurningSpeed = 0.78,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Encore = {
		Icon = "rbxassetid://112424184591336",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 277,
		Accel = 1.25,
		TurningSpeed = 0.78,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	Bunvoyage = {
		Icon = "rbxassetid://85208842560038",
		Price = -1,
		Description = "the most precious seabunny :3",
		Level = 1,
		ProductId = 3560532971,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 300,
		Accel = 1.25,
		TurningSpeed = 1.25,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Sunfyre = {
		Icon = "rbxassetid://78625338128613",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3565027776,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 300,
		Accel = 1.25,
		TurningSpeed = 1.25,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Jettling = {
		Icon = "rbxassetid://72227707260016",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3569790585,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 303,
		Accel = 1.25,
		TurningSpeed = 1.25,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Spiritflutter = {
		Icon = "rbxassetid://70696039636451",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3573839896,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 287,
		Accel = 1.33,
		TurningSpeed = 1.1,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Velocitide = {
		Icon = "rbxassetid://93097416291350",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3577590565,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 287,
		Accel = 1.33,
		TurningSpeed = 1.1,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		IsJetski = true,
		Unpurchasable = true
	},
	["Phoenix Skate"] = {
		Icon = "rbxassetid://133537207305536",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3581115428,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 285,
		Accel = 1.32,
		TurningSpeed = 1.2,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Diablo = {
		Icon = "rbxassetid://85656871501318",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3584845792,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 299,
		Accel = 1.25,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Mechanexus = {
		Icon = "rbxassetid://119734460601976",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3588993527,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 301,
		Accel = 1.24,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		IsJetski = true,
		Unpurchasable = true
	},
	["Jet of the Exalted"] = {
		Icon = "rbxassetid://79176971928019",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3593268359,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 300,
		Accel = 1.22,
		TurningSpeed = 1.1,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true,
		ShowcaseOffset = CFrame.new(0, 7, 0) * CFrame.Angles(0, 0, 0)
	},
	Nightfaller = {
		Icon = "rbxassetid://114090870871867",
		Price = -1,
		Description = "Slice thru the galaxy!",
		Level = 1,
		ProductId = 3597241757,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 303,
		Accel = 1.22,
		TurningSpeed = 1.1,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true,
		ShowcaseOffset = CFrame.new(0, 5, 0) * CFrame.Angles(0, 0, 0)
	},
	Zephyrmantis = {
		Icon = "rbxassetid://84240049056523",
		Price = -1,
		Description = "Buggin' out over how cute I am!",
		Level = 1,
		ProductId = 3600909707,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 300,
		Accel = 1.24,
		TurningSpeed = 1.11,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true,
		ShowcaseOffset = CFrame.new(0, 5, 0) * CFrame.Angles(0, 0, 0)
	},
	Wavestrummer = {
		Icon = "rbxassetid://90348605017681",
		Price = -1,
		Description = "crashing thru the weary waters with the strums of the sea!",
		Level = 1,
		ProductId = 3602950335,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 300,
		Accel = 1.25,
		TurningSpeed = 1.13,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true,
		ShowcaseOffset = CFrame.new(0, 5, 0) * CFrame.Angles(0, 0, 0)
	},
	Shinigami = {
		Icon = "rbxassetid://72526651513781",
		Price = -1,
		Description = "speak to the one with the book..",
		Level = 1,
		ProductId = 3604332694,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 303,
		Accel = 1.25,
		TurningSpeed = 1.13,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true,
		ShowcaseOffset = CFrame.new(0, 5, 0) * CFrame.Angles(0, 0, 0)
	},
	Vitalica = {
		Icon = "rbxassetid://126891535373091",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3605587606,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 303,
		Accel = 1.25,
		TurningSpeed = 1.13,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = false,
		Unpurchasable = true,
		ShowcaseOffset = CFrame.new(0, 5, 0) * CFrame.Angles(0, 0, 0)
	},
	Botanica = {
		Icon = "rbxassetid://104232694493548",
		Price = -1,
		Description = "beautifully elegant...",
		Level = 1,
		ProductId = 3606773123,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 303,
		Accel = 1.25,
		TurningSpeed = 1.13,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true,
		ShowcaseOffset = CFrame.new(0, 5, 0) * CFrame.Angles(0, 0, 0)
	},
	Nevermore = {
		Icon = "rbxassetid://100092256867366",
		Price = -1,
		Description = "where the heart goes to rest.",
		Level = 1,
		ProductId = 3608035910,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 305,
		Accel = 1.25,
		TurningSpeed = 1.13,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true,
		ShowcaseOffset = CFrame.new(0, 5, 0) * CFrame.Angles(0, 0, 0)
	},
	Raingokart = {
		Icon = "rbxassetid://111334054109244",
		Price = -1,
		Description = "Collecting the stars along the prismed path!",
		Level = 1,
		ProductId = 3609222149,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 307,
		Accel = 1.26,
		TurningSpeed = 1.14,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true,
		ShowcaseOffset = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
	},
	Transcendence = {
		Icon = "rbxassetid://107250543601040",
		Price = -1,
		Description = "Controlled by the celestial cycles..",
		Level = 1,
		ProductId = 3610447158,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 308,
		Accel = 1.26,
		TurningSpeed = 1.14,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Draconica = {
		Icon = "rbxassetid://100581069642218",
		Price = -1,
		Description = "To ride with the angels, or with the devil..",
		Level = 1,
		ProductId = 3611590709,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 308,
		Accel = 1.26,
		TurningSpeed = 1.14,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Astropod = {
		Icon = "rbxassetid://94521772839979",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3612585102,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 308,
		Accel = 1.26,
		TurningSpeed = 1.14,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = false,
		Unpurchasable = true
	},
	Onyxum = {
		Icon = "rbxassetid://127486380029530",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3649686728,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 308,
		Accel = 1.26,
		TurningSpeed = 1.14,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Koutetsu = {
		Icon = "rbxassetid://72004313239191",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3708147864,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 310,
		Accel = 1.27,
		TurningSpeed = 1.15,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = false,
		Unpurchasable = true
	},
	Xanthos = {
		Icon = "rbxassetid://114093791285461",
		Price = -1,
		Description = "Vanta beast...",
		Level = 1,
		ProductId = 3709315641,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 310,
		Accel = 1.25,
		TurningSpeed = 1.16,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 1,
		SteerTilt = 1,
		IsJetski = false,
		Unpurchasable = true
	},
	Infrarana = {
		Icon = "rbxassetid://104079034355611",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3710371335,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 310,
		Accel = 1.25,
		TurningSpeed = 1.16,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 1,
		SteerTilt = 1,
		IsJetski = true,
		Unpurchasable = true
	},
	["Winged Royalty"] = {
		Icon = "rbxassetid://87921565808885",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3711378038,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 310,
		Accel = 1.25,
		TurningSpeed = 1.16,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 1,
		SteerTilt = 1,
		IsJetski = false,
		Unpurchasable = true
	},
	["Guardian Angel"] = {
		Icon = "rbxassetid://133168940496008",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3712471911,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 310,
		Accel = 1.25,
		TurningSpeed = 1.16,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 1,
		SteerTilt = 1,
		IsJetski = false,
		Unpurchasable = true
	},
	["Plushy Duomo"] = {
		Icon = "rbxassetid://132893306911024",
		Price = -1,
		Description = "cuddly claw's big sis :p",
		Level = 1,
		ProductId = 3713550808,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 310,
		Accel = 1.25,
		TurningSpeed = 1.16,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 1,
		SteerTilt = 1,
		IsJetski = false,
		Unpurchasable = true
	},
	["KR ROAR"] = {
		Icon = "rbxassetid://129568579557560",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3714826324,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 310,
		Accel = 1.25,
		TurningSpeed = 1.16,
		BackwardsEfficiency = 1.27,
		StopEfficiency = 1.77,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 1,
		SteerTilt = 1,
		IsJetski = true,
		Unpurchasable = false
	},
	["Digital Core"] = {
		Icon = "rbxassetid://123745152825703",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 277,
		Accel = 1.25,
		TurningSpeed = 0.78,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 2,
		IsJetski = true,
		Unpurchasable = true
	},
	Nekoflip = {
		Icon = "rbxassetid://91172056683451",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 277,
		Accel = 1.25,
		TurningSpeed = 0.78,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		Unpurchasable = true
	},
	["Cardistry Bun"] = {
		Icon = "rbxassetid://95867317745855",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 277,
		Accel = 1.25,
		TurningSpeed = 0.78,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Crazy Naynay"] = {
		Icon = "rbxassetid://113061204532166",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 277,
		Accel = 1.25,
		TurningSpeed = 0.78,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Lady Unicorn"] = {
		Icon = "rbxassetid://116300152295731",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 278,
		Accel = 1.25,
		TurningSpeed = 0.78,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 0,
		SteerTilt = 2,
		IsJetski = true,
		Unpurchasable = true
	},
	["Milku Original"] = {
		Icon = "rbxassetid://74559156432013",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 260,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	["Milku Banana"] = {
		Icon = "rbxassetid://139308261290933",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 260,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	["Milku Strawberry"] = {
		Icon = "rbxassetid://103987931755486",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 260,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	Glug = {
		Icon = "rbxassetid://112639261933598",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 263,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	["Cutie Sardines"] = {
		Icon = "rbxassetid://130516948682094",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 266,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	["Jelli Melon"] = {
		Icon = "rbxassetid://81889953801367",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 266,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	Sparkizzle = {
		Icon = "rbxassetid://97417647333417",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 270,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	Fizzfin = {
		Icon = "rbxassetid://84316704138291",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 270,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	["Crescent Cradle"] = {
		Icon = "rbxassetid://101682586499173",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 270,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	["Lunar Lullaby"] = {
		Icon = "rbxassetid://106318144309909",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 270,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	["Bluely Whale"] = {
		Icon = "rbxassetid://84535102670256",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 270,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	["Pinkly Whale"] = {
		Icon = "rbxassetid://134777679232390",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 270,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	["Neon Arrow"] = {
		Icon = "rbxassetid://127453973460125",
		Price = -1,
		Description = "surfin' with retro style!",
		Level = 1,
		MaxSpeed = 270,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	["Biggy Bubble"] = {
		Icon = "rbxassetid://132229193443529",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 270,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = true,
		Unpurchasable = true
	},
	Moneyheist = {
		Icon = "rbxassetid://72149740031136",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 270,
		Accel = 1.2,
		TurningSpeed = 0.75,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 3,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		ForwardTilt = 1,
		SteerTilt = 3,
		IsJetski = false,
		Unpurchasable = false
	},
	["Gingerbread Nessie Boat"] = {
		Icon = "rbxassetid://95475472901884",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 233,
		Accel = 1.2,
		TurningSpeed = 0.77,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		Unpurchasable = true
	},
	["Firerocket Racer"] = {
		Icon = "rbxassetid://74013989730279",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 210,
		Accel = 0.67,
		TurningSpeed = 0.85,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.55,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Milk Boat"] = {
		Icon = "rbxassetid://132783643272294",
		Price = -1,
		Description = "",
		Level = 1,
		MaxSpeed = 233,
		Accel = 1.2,
		TurningSpeed = 0.77,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 0.5,
		BobbingSpeed = 0.5,
		Unpurchasable = true
	},
	["Widow's Veil"] = {
		Icon = "rbxassetid://132654777972155",
		Price = -1,
		Description = "A scary, venomous vessel that strikes with silent precision; the Widow's Veil weaves death across the waves...",
		Level = 1,
		ProductId = 3433641400,
		FakePrice = 4099,
		LimitedAmount = 12500,
		MaxSpeed = 290,
		Accel = 0.8,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		Unpurchasable = true
	},
	Gravedigger = {
		Icon = "rbxassetid://76700259048420",
		Price = -1,
		Description = "A sinister jetski that rips through the waves like a wraith, leaving a chilling wake under the moon's ghostly glow...",
		Level = 1,
		ProductId = 3439887277,
		FakePrice = 4099,
		LimitedAmount = 12000,
		MaxSpeed = 287,
		Accel = 0.99,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Nemesis = {
		Icon = "rbxassetid://116416101709891",
		Price = -1,
		Description = "A phantom predator born from abyssal steel, the Nemesis carves oceans into screaming ribbons of foam. Twin turbines howl like vengeful gods, propelling her hull through liquid night at speeds that blur horizon and heartbeat...",
		Level = 1,
		ProductId = 3445698297,
		FakePrice = 4099,
		LimitedAmount = 11000,
		MaxSpeed = 285,
		Accel = 1.23,
		TurningSpeed = 1.01,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	Riptide = {
		Icon = "rbxassetid://113311825610773",
		Price = -1,
		Description = "",
		Level = 1,
		ProductId = 3450675526,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 287,
		Accel = 1.33,
		TurningSpeed = 1.1,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Ivorous = {
		Icon = "rbxassetid://118984110095434",
		Price = -1,
		Description = "Delicate petals lining the waves before you; its elegant lilac gradient allowing any journey to be all the more gorgeous...",
		Level = 1,
		ProductId = 3456277974,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 293,
		Accel = 1.11,
		TurningSpeed = 1.25,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	Scorpferno = {
		Icon = "rbxassetid://93892671133771",
		Price = -1,
		Description = "A boat engulfed in infernal flames, accompanies by a sharp, dagger-like stinger to protect you on your treacherous endeavors...",
		Level = 1,
		ProductId = 3461672574,
		FakePrice = 4099,
		LimitedAmount = 7500,
		MaxSpeed = 295,
		Accel = 1.35,
		TurningSpeed = 1.11,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Corruptor = {
		Icon = "rbxassetid://89233689843418",
		Price = -1,
		Description = "a fragmented nightmare of shadow and stark white light, exists only in the corrupted data stream of the world...",
		Level = 1,
		ProductId = 3467365834,
		FakePrice = 4099,
		LimitedAmount = 9000,
		MaxSpeed = 299,
		Accel = 1.2,
		TurningSpeed = 1.3,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		Unpurchasable = true
	},
	["Gleeb 9000"] = {
		Icon = "rbxassetid://108328303690945",
		Price = -1,
		Description = "Straight from out of this world, the Gleeb 9000 flies through the ocean; slicing through any disatrous current as though it is ripping through space itself...",
		Level = 1,
		ProductId = 3472916471,
		FakePrice = 4099,
		LimitedAmount = 6300,
		MaxSpeed = 297,
		Accel = 1.3,
		TurningSpeed = 0.9,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		Unpurchasable = true
	},
	Frostbite = {
		Icon = "rbxassetid://100641367416958",
		Price = -1,
		Description = "frozen over, yet still smashing through the ice; calling the glaciers home, but always making your journey onward chillingly quick...",
		Level = 1,
		ProductId = 3478374832,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 299,
		Accel = 1.5,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		Unpurchasable = true
	},
	["Krampus Curse"] = {
		Icon = "rbxassetid://123923936663752",
		Price = -1,
		Description = "haunting the holidays with evil spirit; slicing through the waves with intent to steal christmas!...",
		Level = 1,
		ProductId = 3484039653,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 295,
		Accel = 1.6,
		TurningSpeed = 1.2,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		IsJetski = true,
		Unpurchasable = true
	},
	Nullprawn = {
		Icon = "rbxassetid://138919350627082",
		Price = -1,
		Description = "dark but feisty; the nullprawn races through the waves with a promise...",
		Level = 1,
		ProductId = 3491805165,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 298,
		Accel = 1.7,
		TurningSpeed = 1.22,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Thief of Time"] = {
		Icon = "rbxassetid://135487344671507",
		Price = -1,
		Description = "it was just yesterday...",
		Level = 1,
		ProductId = 3501068429,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 295,
		Accel = 1.7,
		TurningSpeed = 1.22,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Razorella = {
		Icon = "rbxassetid://77400745705931",
		Price = -1,
		Description = "she's fierce, she's punk, she's beautiful...",
		Level = 1,
		ProductId = 3508796355,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 297,
		Accel = 1.67,
		TurningSpeed = 1.22,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Phantom Pawster"] = {
		Icon = "rbxassetid://79728420576436",
		Price = -1,
		Description = "meowing right through the wading waters, ready to pounce at any moment!",
		Level = 1,
		ProductId = 3515098949,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 303,
		Accel = 1.5,
		TurningSpeed = 1.1,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["S'more Speedster"] = {
		Icon = "rbxassetid://96310760049940",
		Price = -1,
		Description = "do you like your marshmallows crispy?",
		Level = 1,
		ProductId = 3521120007,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 300,
		Accel = 1.4,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	Arachne = {
		Icon = "rbxassetid://117722904424872",
		Price = -1,
		Description = "The mist parted not for a hull, but for a shadow; a dark, multi-limbed shape skating across the surface with a predatry grace...",
		Level = 1,
		ProductId = 3526082845,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 303,
		Accel = 1.33,
		TurningSpeed = 1.3,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		ForwardTilt = 1,
		SteerTilt = 2,
		IsJetski = true,
		Unpurchasable = true
	},
	Coquette = {
		Icon = "rbxassetid://111321030086394",
		Price = -1,
		Description = "born from the junction of deep sea dreams, and high speed fantasies...",
		Level = 1,
		ProductId = 3531708491,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 301,
		Accel = 1.31,
		TurningSpeed = 1.3,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		Unpurchasable = true
	},
	Arteria = {
		Icon = "rbxassetid://85271959028875",
		Price = -1,
		Description = "high-speed love letter opening the waves, running on pulses of pure adrenaline...",
		Level = 1,
		ProductId = 3536672740,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 304,
		Accel = 1.33,
		TurningSpeed = 1.2,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		IsJetski = true,
		Unpurchasable = true
	},
	Starliner = {
		Icon = "rbxassetid://80751091677121",
		Price = -1,
		Description = "racing through the cosmos; passing every star with nobility...",
		Level = 1,
		ProductId = 3541976251,
		FakePrice = 4099,
		LimitedAmount = 5000,
		MaxSpeed = 305,
		Accel = 1.29,
		TurningSpeed = 1.25,
		BackwardsEfficiency = 1.3,
		StopEfficiency = 1.75,
		Bobbing = 2,
		BobbingSpeed = 2,
		IsJetski = true,
		Unpurchasable = true
	},
	Sunflower = {
		Icon = "rbxassetid://132322372104462",
		Price = -1,
		Description = "Perfect for pollinating!",
		Level = 1,
		MaxSpeed = 240,
		Accel = 1.7,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 4,
		Bobbing = 2,
		BobbingSpeed = 0.1,
		Unpurchasable = true
	},
	Block = {
		Icon = "rbxassetid://112614833835250",
		Price = -1,
		Description = "First modelling job... did I do good?",
		Level = 1,
		MaxSpeed = 1e999,
		Accel = 0.1,
		TurningSpeed = 50,
		BackwardsEfficiency = 1,
		StopEfficiency = 100,
		Bobbing = 0,
		BobbingSpeed = 1,
		BlockRacing = true,
		Unpurchasable = true,
		Untradeable = true,
		DEV = true
	},
	["Chromatic Titan"] = {
		Icon = "rbxassetid://81429515459671",
		Price = -1,
		Description = "Huh? Who wouldn't want this!",
		Level = 1,
		MaxSpeed = 145,
		Accel = 1,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1.5,
		StopEfficiency = 2.5,
		Bobbing = 3,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true
	},
	["Cardboard Box"] = {
		Icon = "rbxassetid://125730231392097",
		Price = -1,
		Description = "Isn't it gonna get wet?",
		Level = 1,
		MaxSpeed = 165,
		Accel = 1.2,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1.5,
		StopEfficiency = 2.5,
		Bobbing = 3,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true
	},
	["Angler's Raft"] = {
		Icon = "rbxassetid://137035588547889",
		Price = -1,
		Description = "[Angler Exclusive Reward]",
		Level = 1,
		MaxSpeed = 200,
		Accel = 0.32,
		TurningSpeed = 0.7,
		BackwardsEfficiency = 1,
		StopEfficiency = 3.5,
		Bobbing = 2,
		BobbingSpeed = 0.4,
		Unpurchasable = true,
		Untradeable = true
	},
	["The Brick Hatchboat"] = {
		Icon = "rbxassetid://75184886925945",
		Price = -1,
		Description = "SUPER REAL.",
		Level = 1,
		MaxSpeed = 1500,
		Accel = 6.7,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 1,
		BobbingSpeed = 0.3,
		Unpurchasable = true,
		Untradeable = true,
		DEV = true
	},
	["Jungle Explorer Boat"] = {
		Icon = "rbxassetid://112252823794589",
		Price = -1,
		Description = "May prove to be useful for the Lost Jungle...",
		Level = 1,
		MaxSpeed = 210,
		Accel = 0.25,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 0.01,
		Bobbing = 0,
		BobbingSpeed = 0,
		Unpurchasable = true
	},
	["Relic Jungle Explorer Boat"] = {
		Icon = "rbxassetid://133801886273194",
		Price = -1,
		Description = "May prove to be useful for the Lost Jungle... A reward to those who solved the long forgotten Relic Rod puzzle!",
		Level = 1,
		MaxSpeed = 220,
		Accel = 0.3,
		TurningSpeed = 0.5,
		BackwardsEfficiency = 1,
		StopEfficiency = 0.01,
		Bobbing = 0,
		BobbingSpeed = 0,
		Unpurchasable = true
	},
	["A Rock"] = {
		Icon = "rbxassetid://71668336719720",
		Price = -1,
		Description = "It's not just a boulder...",
		Level = 1,
		MaxSpeed = 50000,
		Accel = 0.05,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true
	},
	["Dutchman's Spirit"] = {
		Icon = "rbxassetid://75246740836510",
		Price = -1,
		Description = "Only available during FischFright-2025",
		Level = 1,
		MaxSpeed = 220,
		Accel = 0.8,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Love of Fisch"] = {
		Icon = "rbxassetid://125752087549382",
		Price = -1,
		Description = "Only available during Valentides-2026",
		Level = 1,
		MaxSpeed = 202.6,
		Accel = 0.2,
		TurningSpeed = 0.14,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 1,
		BobbingSpeed = 1,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Giant Box of Chocolate"] = {
		Icon = "rbxassetid://122441071287246",
		Price = 3500,
		LocalCurrency = "Chocolates",
		Description = "Only available during Valentides-2026",
		Level = 1,
		MaxSpeed = 50,
		Accel = 1,
		TurningSpeed = 0.3,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 1,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Nessie's Skeleton"] = {
		Icon = "rbxassetid://74134944858605",
		Price = -1,
		Description = "Woah... So spooky...",
		Level = 1,
		MaxSpeed = 200,
		Accel = 0.3,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		Unpurchasable = true
	},
	["Classic Pumpkin"] = {
		Icon = "rbxassetid://81301566351186",
		Price = -1,
		Description = "Halloween Spotlight Reward [Rune Tier]",
		Level = 1,
		MaxSpeed = 100,
		Accel = 0.1,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	Ghosdeeri = {
		Icon = "rbxassetid://135512597871946",
		Price = -1,
		Description = "Halloween Spotlight Reward [Key Tier]",
		Level = 1,
		MaxSpeed = 200,
		Accel = 0.3,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		ForwardTilt = 2,
		SteerTilt = 6,
		Unpurchasable = true
	},
	["Roasted Turkey"] = {
		Icon = "rbxassetid://122525178200973",
		Price = -1,
		Description = "Tasty! It got a little wet though...",
		Level = 1,
		MaxSpeed = 180,
		Accel = 0.35,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		BlockRacing = true,
		Unpurchasable = true
	},
	["Gravy Boat"] = {
		Icon = "rbxassetid://126143433396617",
		Price = -1,
		Description = "Don't fall in!",
		Level = 1,
		MaxSpeed = 190,
		Accel = 0.3,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 2,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Clown Car"] = {
		Icon = "rbxassetid://70787043882307",
		Price = -1,
		Description = "PERFECT FOR THE WHOLE CREW!",
		Level = 1,
		MaxSpeed = 50,
		Accel = 5,
		TurningSpeed = 2,
		BackwardsEfficiency = 5,
		StopEfficiency = 5,
		Bobbing = 5,
		BobbingSpeed = 0.1,
		Unpurchasable = true
	},
	["Peppermint-Ski"] = {
		Icon = "rbxassetid://103112630314363",
		Price = -1,
		Description = "Only available during Fischmas-2025",
		Level = 1,
		MaxSpeed = 225,
		Accel = 0.8,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Summer-Ski"] = {
		Icon = "rbxassetid://110736898382651",
		Price = -1,
		Description = "Only available during Fischfest-2026",
		Level = 1,
		MaxSpeed = 225,
		Accel = 0.8,
		TurningSpeed = 1,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	},
	["Turbo Sleigh"] = {
		Icon = "rbxassetid://71003133222003",
		Price = -1,
		Description = "Only available during Fischmas-2025",
		Level = 1,
		MaxSpeed = 190,
		Accel = 0.8,
		TurningSpeed = 0.6,
		BackwardsEfficiency = 0.85,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Frozen Rowboat"] = {
		Icon = "rbxassetid://118020067531963",
		Price = -1,
		Description = "Only available during Fischmas-2025",
		Level = 1,
		MaxSpeed = 20,
		Accel = 0.1,
		TurningSpeed = 0.2,
		BackwardsEfficiency = 1,
		StopEfficiency = 2,
		Bobbing = 0.25,
		BobbingSpeed = 1,
		Unpurchasable = true
	},
	["Streaming Setup"] = {
		Icon = "rbxassetid://98679866812468",
		Price = -1,
		Description = "Stream at sea! [Twitch RB Battles Code-Exclusive]",
		Level = 1,
		MaxSpeed = 100,
		Accel = 0.2,
		TurningSpeed = 0.8,
		BackwardsEfficiency = 1,
		StopEfficiency = 1.5,
		Bobbing = 2,
		BobbingSpeed = 1,
		Unpurchasable = true,
		Untradeable = true
	},
	Nateboard = {
		Icon = "rbxassetid://98112502137845",
		Price = -1,
		Description = "Get off me",
		Level = 1,
		MaxSpeed = 235,
		Accel = 0.7,
		TurningSpeed = 1.15,
		BackwardsEfficiency = 1.1,
		StopEfficiency = 1.75,
		Bobbing = 2.85,
		BobbingSpeed = 2,
		ForwardTilt = 2,
		SteerTilt = 6,
		IsJetski = true,
		Unpurchasable = true
	}
}
local _ = {
	Color3.fromRGB(126, 59, 59),
	Color3.fromRGB(74, 74, 74),
	Color3.fromRGB(63, 70, 94),
	Color3.fromRGB(78, 102, 75),
	Color3.fromRGB(222, 222, 222),
	Color3.fromRGB(83, 75, 91),
	Color3.fromRGB(255, 209, 116)
}
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function onBoatGiveFailed(p, name: string, amount: number)
	table.insert(p.Data.NewFormat.FailedRewards, {
		Type = "Boat",
		Name = name,
		Amount = amount,
		Time = os.time()
	})
end

function Vessels.PurchaseValidityCheck(_, p, p2: string)
	local now = os.time()
	local v3 = Vessels.library[p2]

	if not v3 then
		return false, "Unknown boat!"
	end

	local v4 = forPlayerNow(p)

	if not (v4 and v4:FindFirstChild("Boats")) then
		return false, "Please wait a moment..."
	end

	if v3.ExpirationDate and v3.ExpirationDate.UnixTimestamp < now then
		return false, "This boat has expired!"
	end

	if not v3.LimitedAmount then
		return true
	end

	local replion = Replion.Server:GetReplion("LimitedStockItems")

	if not replion then
		return false, "Failed to check stock! Please try again later."
	end

	if replion:GetExpect({ "Stocks", p2 }) <= 0 then
		return false, "This boat is out of stock!"
	end

	return true
end

function Vessels.OnBoatProductPurchase(_, p, p2: string, flag: boolean)
	local now = os.time()
	local v3 = Vessels.library[p2]

	if not v3 then
		return false
	end

	local v4 = forPlayerNow(p)

	if not v4 or not v4:FindFirstChild("Boats") or v3.ExpirationDate and v3.ExpirationDate.UnixTimestamp < now then
		return false
	end

	if v3.LimitedAmount and not flag then
		local replion = Replion.Server:GetReplion("LimitedStockItems")

		if not replion then
			return false
		end

		if replion:GetExpect({ "Stocks", p2 }) <= 0 then
			return false
		else
			task.spawn(function()
				local ServerScriptService = game:GetService("ServerScriptService")
				local LimitedStockService = require(ServerScriptService.server.legacyServices.LimitedStockService)
				local success, result = pcall(function()
					return LimitedStockService:DecreaseStock(p2, 1)
				end)

				if not success then
					warn((`Failed to reduce stock: {result}`))
				end
			end)
		end
	end

	Vessels:Give(p, p2)
	return true
end

function Vessels:Give(player, name: string, value: number?, flag: boolean?)
	local amount = value or 1

	if amount <= 0 then
		return false
	end

	local v4, v5 = forPlayerNow(player)

	if not (v4 and v5) then
		return false
	end

	local boats = v4:FindFirstChild("Boats")

	if not boats then
		onBoatGiveFailed(v5, name, amount) -- equivalent call inferred; original call site unknown
		return true
	end

	if Vessels.library[name] then
		local child = boats:FindFirstChild(name)
		local value2

		if child then
			value2 = tonumber(child.Value) or 0
			child.Value = tostring(value2 + amount)
		else
			local stringValue = Instance.new("StringValue")
			stringValue.Name = name
			stringValue.Value = tostring(amount)
			stringValue.Parent = boats
			value2 = 0
		end

		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local anno_give_boat = ReplicatedStorage2:FindFirstChild("events"):FindFirstChild("anno_give_boat")

		if not flag and anno_give_boat and anno_give_boat:IsA("RemoteEvent") then
			anno_give_boat:FireClient(player, name, amount, value2 + amount)
		end

		return true
	else
		warn((`Unknown boat "{name}" given to {player.Name}!`))
		onBoatGiveFailed(v5, name, amount) -- equivalent call inferred; original call site unknown
		return true
	end
end

function Vessels.Ungive(_, p, childName: string)
	local v3 = forPlayerSafe(p)

	if not v3 then
		return false
	end

	local boats = v3:FindFirstChild("Boats")

	if not boats then
		return false
	end

	local child = boats:FindFirstChild(childName)

	if not child then
		return false
	end

	child:Destroy()
	return true
end

function Vessels:Has(p, childName: string)
	local v3 = forPlayerSafe(p)

	if not v3 then
		return false
	end

	local boats = v3:FindFirstChild("Boats")

	if boats then
		return boats:FindFirstChild(childName) ~= nil
	end

	return false
end

function Vessels.GetFavorited(_, p, callback)
	local v3 = forPlayerSafe(p)

	if not v3 then
		return {}
	end

	local boats = v3:FindFirstChild("Boats")

	if not boats then
		return {}
	end

	local names = {}

	for _, child in boats:GetChildren() do
		if not (Vessels.library[child.Name] and child:FindFirstChild("favorited") and child.favorited.Value and child.Name ~= "Random Boat") then
			continue
		end

		if not (not callback or callback(Vessels.library[child.Name], child.Name)) then
			continue
		end

		table.insert(names, child.Name)
	end

	return names
end

function Vessels.GetAllOwned(_, p, callback)
	local v3 = forPlayerSafe(p)

	if not v3 then
		return {}
	end

	local boats = v3:FindFirstChild("Boats")

	if not boats then
		return {}
	end

	local names = {}

	for _, child in boats:GetChildren() do
		if not (Vessels.library[child.Name] and child.Name ~= "Random Boat" and (not callback or callback(
			Vessels.library[child.Name],
			child.Name
		))) then
			continue
		end

		table.insert(names, child.Name)
	end

	return names
end

function Vessels.HasSubmarine(_, p)
	for k, v3 in Vessels.library do
		if typeof(v3) == "table" and v3.IsSubmarine == true and Vessels:Has(p, k) then
			return k
		end
	end

	return nil
end

function Vessels.Teleport(_, folder, cframe: CFrame, flag: boolean?)
	folder:SetAttribute("MovementPaused", true)
	local seaLevel = Worlds.WorldStats[WorldService:GetCurrentWorldIndex()]["Sea Level"] or 127

	if game.PlaceId == 140688791331730 then
		seaLevel = workspace.world.water.seaVolumes.MainSea.CFrame.Y + workspace.world.water.seaVolumes.MainSea.Size.Y / 2
	end

	local v3 = {}

	for _, descendant in folder:GetDescendants() do
		if not ((descendant:IsA("Seat") or descendant:IsA("VehicleSeat")) and descendant.Occupant) then
			continue
		end

		local playerFromCharacter = game.Players:GetPlayerFromCharacter(descendant.Occupant.Parent)

		if playerFromCharacter then
			table.insert(
				v3,
				Promise.try(playerFromCharacter.RequestStreamAroundAsync, playerFromCharacter, cframe.Position, 15)
			)
		end
	end

	Promise.allSettled(v3):await()
	folder:PivotTo(cframe)
	local planePart = folder:WaitForChild("PlanePart")

	if flag then
		seaLevel = cframe.Position.Y or seaLevel
	end

	planePart.CFrame = CFrame.new(0, seaLevel, 0)
	task.delay(2, function()
		folder:SetAttribute("MovementPaused", false)
	end)
end

function Vessels.Spawn(_, player, childName: string, childName2: string?, cframe: CFrame?, flag: boolean?, callback)
	local v3 = forPlayerSafe(player)

	if not v3 then
		return
	end

	local v4 = flag == true

	if not (v3:FindFirstChild("Boats"):FindFirstChild(childName) or v4) then
		warn("!! " .. tostring(player) .. " VesselHandler - Internal Error 1-1")
		return "Internal Error 1-1"
	end

	if workspace.active.boats:FindFirstChild(player.Name) then
		for _, descendant in workspace.active.boats:FindFirstChild(player.Name):GetDescendants() do
			if not ((descendant:IsA("VehicleSeat") or descendant:IsA("Seat")) and descendant:FindFirstChild("SeatWeld")) then
				continue
			end

			descendant.SeatWeld:Destroy()
		end

		workspace.active.boats:FindFirstChild(player.Name):Destroy()
	end

	local v5 = Vessels.library[childName]

	if WorldService:IsTradePlaza() and v5.Disruptive then
		ReplicatedStorage.events.anno_thought:FireClient(player, "This boat cannot be spawned here!")
		return
	end

	local v6 = nil

	if childName2 then
		local child = workspace.world.boatspawns:FindFirstChild(childName2)
		local requiredDurability = child:GetAttribute("RequiredDurability") or 0

		if (v5.Durability or 0) < requiredDurability then
			ReplicatedStorage.events.anno_thought:FireClient(
				player,
				(`This boat's durability is too low for it to spawn here! ({requiredDurability} Required)`)
			)
			return
		end

		for i = 1, #child:GetChildren() do
			local child2 = workspace.world.boatspawns:FindFirstChild(childName2):FindFirstChild((tostring(i)))
			local partsInPart = workspace:GetPartsInPart(child2)

			for _, v8 in pairs(partsInPart) do
				if v8:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Base") then
					v6 = nil
					break
				else
					v6 = child2
				end
			end

			if v6 ~= nil then
				break
			end

			if #partsInPart <= 0 then
				v6 = child2
			end
		end

		if child:HasTag("ForceCFrame") then
			cframe = v6 and v6.CFrame * CFrame.new(0, -(v6.Size.Y / 2), 0)

			if not cframe then
				return "No Open Space"
			end

			v6 = nil
		elseif v6 == nil then
			return "No Open Space"
		end
	end

	if v6 and v6:GetAttribute("BlockDisruptive") and v5.Disruptive then
		ReplicatedStorage.events.anno_thought:FireClient(player, "This boat cannot be spawned here!")
		return
	end

	local assets = require(ReplicatedStorage.shared.utils.assets)
	local cloneAsync = assets.getCloneAsync("vessel", childName)
	local spawnOffset = Vessels.library[childName].SpawnOffset

	if spawnOffset then
		v6 = v6 and {
			CFrame = v6.CFrame * CFrame.new(0, 0, -spawnOffset)
		}
	end

	local model = Instance.new("Model")
	model.Name = player.Name
	model:SetAttribute("SpawnId", game.HttpService:GenerateGUID(false))
	local seaLevel = Worlds.WorldStats[WorldService:GetCurrentWorldIndex()]["Sea Level"] or 127
	local v7 = WorldService:IsTradePlaza() or game.PlaceId == 140688791331730

	if v7 then
		local mainSea = workspace:FindFirstChild("world") and workspace.world:FindFirstChild("water") and workspace.world.water:FindFirstChild("seaVolumes") and workspace.world.water.seaVolumes:FindFirstChild("MainSea")

		if mainSea then
			seaLevel = mainSea.CFrame.Y + mainSea.Size.Y / 2
		end
	end

	if v7 and v6 then
		local position = v6.CFrame.Position
		cloneAsync:PivotTo(CFrame.new(position.X, seaLevel, position.Z) * (v6.CFrame - v6.CFrame.Position))
	elseif v7 and cframe then
		local position = cframe.Position
		cloneAsync:PivotTo(CFrame.new(position.X, seaLevel, position.Z) * (cframe - cframe.Position))
	elseif v6 then
		cloneAsync:PivotTo(v6.CFrame)
	else
		cloneAsync:PivotTo(cframe or CFrame.new(0, seaLevel, 0))
	end

	for _, v8 in cloneAsync:QueryDescendants("BasePart") do
		if v8.CollisionGroup == "Default" or v8.CollisionGroup == "Fish" then
			v8.CollisionGroup = "Boat"
		end
	end

	cloneAsync.ModelStreamingMode = Enum.ModelStreamingMode.PersistentPerPlayer
	cloneAsync:AddPersistentPlayer(player)
	cloneAsync.Parent = model
	local planePart_2 = cloneAsync:WaitForChild("PlanePart")
	planePart_2.CFrame = cframe or CFrame.new((Vector3.new(0, seaLevel, 0)))

	if cframe then
		cloneAsync:PivotTo(cframe)
	end

	local clone = script.Information:Clone()
	clone.BoatType.Value = childName
	clone.OwnedBy.Value = player.Name
	clone.Parent = cloneAsync
	cloneAsync:SetAttribute("OwnerUserId", player.UserId)

	if v5.FlyingBoat then
		cloneAsync:AddTag("FlyingBoat")
	end

	if v5.IsSubmarine then
		cloneAsync:SetAttribute("IsSubmarine", true)
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = "SubmarineTeleportRemote"
		remoteEvent.Parent = cloneAsync
		local v8 = v5.SubmarineTier and {
			Value = v5.SubmarineTier
		} or PlayerService:ReadDataPathNow(player, "Cache.Submarine.Skin")

		if v8 then
			local value = v8.Value
			cloneAsync:SetAttribute("Tier", table.find(v, value))
			local v9 = not cloneAsync.Body.Skins:FindFirstChild(value) and "Common" or value

			for _, folder in cloneAsync.Body.Skins:GetChildren() do
				for _, part in folder:GetDescendants() do
					if not (part:IsA("BasePart") and part:GetAttribute("DefaultTransparency")) then
						continue
					end

					part.Transparency = folder.Name ~= v9 and 1 or part:GetAttribute("DefaultTransparency") or 1
					part.CanCollide = folder.Name == v9 and (part:GetAttribute("DefaultCollision") or false)
				end
			end
		end
	end

	if v5.FreeMovement then
		local clone2 = script.vesselHandler:Clone()
		clone2.Parent = cloneAsync
		clone2.Enabled = true
	else
		cloneAsync:AddTag("Boat")

		for _, parent in cloneAsync:QueryDescendants("Seat") do
			local proximityPrompt = parent:FindFirstChildOfClass("ProximityPrompt")

			if proximityPrompt then
				proximityPrompt:Destroy()
			end

			local seatScript = parent:FindFirstChild("seatScript") or parent:FindFirstChild("seatAnim")

			if seatScript and seatScript.Enabled then
				local folder = Instance.new("Folder")
				folder.Name = "sitAnims"

				for _, v9 in seatScript:QueryDescendants("Animation") do
					v9.Parent = folder
				end

				folder.Parent = parent
				seatScript:Destroy()
			end

			if parent:HasTag("AutoSeat") then
				continue
			end

			parent.Disabled = true
			parent:AddTag("BoatSeat")
		end

		for _, parent in cloneAsync:QueryDescendants("VehicleSeat") do
			local proximityPrompt = parent:FindFirstChildOfClass("ProximityPrompt")

			if proximityPrompt then
				proximityPrompt.ObjectText = `{player.Name}'s Seat`
				proximityPrompt.MaxActivationDistance = math.max(proximityPrompt.MaxActivationDistance, 16)
			end

			local driveranimScript = parent:FindFirstChild("driveranimScript")

			if driveranimScript and driveranimScript.Enabled then
				local folder = Instance.new("Folder")
				folder.Name = "sitAnims"

				for _, v9 in driveranimScript:QueryDescendants("Animation") do
					v9.Parent = folder
				end

				folder.Parent = parent
				driveranimScript:Destroy()
			end

			parent.Disabled = true
		end

		if not v5.FreeMovement then
			for _, v8 in cloneAsync:QueryDescendants("BasePart") do
				v8.Massless = v5.FreeMovement
			end
		end

		local base = cloneAsync:WaitForChild("Base")
		local motor = base:FindFirstChild("Motor")

		if motor and motor:IsA("BodyVelocity") then
			motor:Destroy()
		end

		local rot = base:FindFirstChild("Rot")
		local maxTorque = base.AssemblyMass * 1000
		rot.D = 500
		rot.P = 3000
		rot.MaxTorque = Vector3.new(maxTorque, 0, maxTorque)
		local attachment = Instance.new("Attachment")
		attachment.Name = "BaseCenter"
		attachment.Parent = base
		attachment.WorldPosition = base.AssemblyCenterOfMass
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "BaseCenterLine"
		attachment2.Parent = attachment
		attachment2.CFrame = CFrame.fromOrientation(0, 1.5707963267948966, 0)
		local linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.Name = "Motor"
		linearVelocity.Attachment0 = attachment2
		linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
		linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
		linearVelocity.ForceLimitsEnabled = true
		linearVelocity.MaxForce = 0
		linearVelocity.Parent = base
		local linearVelocity2 = Instance.new("LinearVelocity")
		linearVelocity2.Name = "MoveResist"
		linearVelocity2.Attachment0 = attachment
		linearVelocity2.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
		linearVelocity2.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		linearVelocity2.ForceLimitsEnabled = true
		linearVelocity2.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		linearVelocity2.MaxAxesForce = Vector3.new(
			maxTorque,
			not (v5.FlyingBoat or v5.IsSubmarine) and 0 or maxTorque * workspace.Gravity,
			maxTorque
		) / 10
		linearVelocity2.Parent = base
		local linearVelocity3 = Instance.new("LinearVelocity")
		linearVelocity3.Name = "FlightMotor"
		linearVelocity3.Attachment0 = attachment
		linearVelocity3.RelativeTo = Enum.ActuatorRelativeTo.World
		linearVelocity3.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
		linearVelocity3.ForceLimitsEnabled = true
		linearVelocity3.MaxForce = maxTorque * workspace.Gravity * 10
		linearVelocity3.LineDirection = createVector(0, 1, 0)
		linearVelocity3.Enabled = v5.FlyingBoat or v5.IsSubmarine or false
		linearVelocity3.Parent = base
		local angularVelocity = Instance.new("AngularVelocity")
		angularVelocity.Name = "Steer"
		angularVelocity.Attachment0 = attachment
		angularVelocity.AngularVelocity = createVector(0, 0, 0)
		angularVelocity.MaxTorque = maxTorque
		angularVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
		angularVelocity.Parent = base
		local alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.Name = "SimpleSteer"
		alignOrientation.Attachment0 = attachment
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOrientation.MaxTorque = maxTorque
		alignOrientation.Responsiveness = 20
		alignOrientation.Enabled = false
		alignOrientation.Parent = base

		if v5.IsSubmarine or v5.FlyingBoat then
			local planePart = cloneAsync:FindFirstChild("PlanePart")
			local planeConstraint = planePart and planePart:FindFirstChild("PlaneConstraint")

			if planeConstraint then
				planeConstraint.Enabled = false
			end
		end
	end

	if typeof(callback) == "function" then
		callback(cloneAsync)
	end

	model.Parent = workspace.active.boats
	player:AddReplicationFocus(cloneAsync.PrimaryPart)

	if v6 then
		cloneAsync.PrimaryPart.CFrame = v6.CFrame
	elseif cframe then
		cloneAsync:PivotTo(cframe)
	end

	local v8 = {}
	cloneAsync.Base:SetNetworkOwner(player)
	local CheckOwnerShip

	CheckOwnerShip = function()
		if v8 == nil then
			return
		end

		debug.profilebegin("vessels::CheckOwnerShip")
		local now = tick()

		if cloneAsync:FindFirstChild("Base") and cloneAsync.Base:IsDescendantOf(workspace) and cloneAsync and cloneAsync:FindFirstChild("Base") and player then
			task.defer(function()
				if cloneAsync:FindFirstChild("Base") and cloneAsync.Base:GetNetworkOwner() ~= player then
					cloneAsync.Base:SetNetworkOwner(player)
				end
			end)
		end

		for _, child in cloneAsync:GetChildren() do
			if not (child:IsA("Seat") or child:IsA("VehicleSeat")) then
				continue
			end

			local parent = child.Occupant and child.Occupant.Parent

			if not parent then
				continue
			end

			if v8[parent] then
				v8[parent].seen = now
			else
				v8[parent] = {
					added = parent.ChildAdded:Connect(CheckOwnerShip),
					removed = parent.ChildRemoved:Connect(CheckOwnerShip),
					destroy = parent.AncestryChanged:Once(CheckOwnerShip),
					seen = now
				}
			end
		end

		for k, v9 in table.clone(v8) do
			if v9.seen == now then
				continue
			end

			v8[k].added:Disconnect()
			v8[k].removed:Disconnect()
			v8[k].destroy:Disconnect()
			v8[k] = nil
		end

		debug.profileend()
	end

	for _, descendant in cloneAsync:GetDescendants() do
		if descendant:IsA("Seat") or descendant:IsA("VehicleSeat") then
			descendant:GetPropertyChangedSignal("Occupant"):Connect(CheckOwnerShip)
		end
	end

	local onBobberPlaceEventConnection = PlayerService.OnBobberPlaceEvent:Connect(CheckOwnerShip)
	local thread

	if v5.IsSubmarine or v5.FreeMovement then
		thread = task.spawn(function()
			while task.wait() and cloneAsync:FindFirstChild("Base") and cloneAsync.Base:IsDescendantOf(workspace) do
				debug.profilebegin("vessels: auto ownership")

				if cloneAsync.Base:GetNetworkOwner() ~= player and not cloneAsync.Base:IsGrounded() then
					cloneAsync.Base:SetNetworkOwner(player)
				end

				debug.profileend()
			end
		end)
	else
		thread = nil
	end

	cloneAsync.Destroying:Once(function()
		for k, _ in table.clone(v8) do
			v8[k].added:Disconnect()
			v8[k].removed:Disconnect()
			v8[k].destroy:Disconnect()
			v8[k] = nil
		end

		v8 = nil
		onBobberPlaceEventConnection:Disconnect()
		onBobberPlaceEventConnection = nil

		if thread then
			task.cancel(thread)
		end
	end)
	local utilityAttachment = v5.IsUtility and cloneAsync:FindFirstChild("UtilityAttachment", true)

	if utilityAttachment then
		utilityAttachment:AddTag("UtilityAttachment")
	end

	ReplicatedStorage.events.anno_boat:FireClient(player, model, childName, model:GetAttribute("SpawnId"))

	if v2[player] then
		v2[player]:Destroy()
		v2[player] = nil
	end

	v2[player] = model

	if childName == "The Essex Boat" and childName2 == "Jurassic Dock" and v6 then
		CutsceneService:StartCutscene(player, "JurassicDock", v6.Name)
	end

	PlayerService.OnBoatSpawned:Fire(player, childName)
	return model
end

game.Players.PlayerRemoving:Connect(function(player)
	if v2[player] then
		task.wait(1)

		if game.Workspace:WaitForChild("active"):WaitForChild("boats"):FindFirstChild(player.Name) then
			for _, descendant in game.Workspace:WaitForChild("active"):WaitForChild("boats"):FindFirstChild(player.Name):GetDescendants() do
				if not ((descendant:IsA("VehicleSeat") or descendant:IsA("Seat")) and descendant:FindFirstChild("SeatWeld")) then
					continue
				end

				descendant.SeatWeld:Destroy()
			end
		end

		v2[player]:Destroy()
	end
end)
return Vessels