local Players = game:GetService("Players")
local BaseChainsaw = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ViewModels"):WaitForChild("BaseChainsaw"))
local object = setmetatable({}, BaseChainsaw)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseChainsaw.new(...), object)
	self:_Init()
	return self
end

function object.CreateHoldSounds(object2)
	local sounds = {}
	local sound = object2:CreateSound("rbxassetid://16359327230", 0.75, 1.25, true)
	local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
	pitchShiftSoundEffect.Octave = 0.625
	pitchShiftSoundEffect.Parent = sound
	table.insert(sounds, sound)
	local sound2 = object2:CreateSound("rbxassetid://16359327230", 0.5, 1.2, true)
	local pitchShiftSoundEffect2 = Instance.new("PitchShiftSoundEffect")
	pitchShiftSoundEffect2.Octave = 0.5
	pitchShiftSoundEffect2.Parent = sound2
	table.insert(sounds, sound2)
	return sounds
end

function object.PlayStartingHoldSounds(object2)
	object2:CreateSound("rbxassetid://18763594759", 0.5, 1, true, 10)
end

function object:_Init()
	self:_RegisterBlade(self.ItemModel:WaitForChild("Drill"):WaitForChild("Blade"))
end

return object