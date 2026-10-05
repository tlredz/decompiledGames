require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
require(game.ReplicatedStorage.React.Components.Map.Types)
require(game.ReplicatedStorage.Definitions.Map.Types)
local sea = {
	Colosseum = require(script.Sea1.Colosseum),
	Sky = require(script.Sea1.Sky),
	SkyArea2 = require(script.Sea1.SkyArea2),
	Desert = require(script.Sea1.Desert),
	Jungle = require(script.Sea1.Jungle),
	Fountain = require(script.Sea1.Fountain)
}
local MagmaVillage = require(script.Sea1["Magma Village"])
sea["Magma Village"] = MagmaVillage
local MarineFortress = require(script.Sea1["Marine Fortress"])
sea["Marine Fortress"] = MarineFortress
local FrozenVillage = require(script.Sea1["Frozen Village"])
sea["Frozen Village"] = FrozenVillage
local PirateVillage = require(script.Sea1["Pirate Village"])
sea["Pirate Village"] = PirateVillage
local MiddleTown = require(script.Sea1["Middle Town"])
sea["Middle Town"] = MiddleTown
sea.Prison = require(script.Sea1.Prison)
local UnderwaterCity = require(script.Sea1["Underwater City"])
sea["Underwater City"] = UnderwaterCity
return {
	Sea1 = sea
}