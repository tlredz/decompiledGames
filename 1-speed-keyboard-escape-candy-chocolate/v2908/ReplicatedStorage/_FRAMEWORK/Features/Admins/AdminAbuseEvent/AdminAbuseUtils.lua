local Animations = require(script.Animations)
local Cutscenes = require(script.Cutscenes)
local Map = require(script.Map)
local Musics = require(script.Musics)
local NPCDance = require(script.NPCDance)
local Sequencer = require(script.Sequencer)
return {
	Animations = Animations,
	Cutscenes = Cutscenes,
	Map = Map,
	Musics = Musics,
	NPCDance = NPCDance,
	Sequence = Sequencer,
	SoundtrackRotation = require(script.SoundtrackRotation),
	cleanupAll = function()
		Animations.cleanup()
		Cutscenes.cleanup()
		Musics.cleanup()
		Sequencer.Cleanup()
	end
}