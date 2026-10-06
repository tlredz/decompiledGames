local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function()
	local _ = game.ReplicatedStorage
	local _ = {
		"rbxassetid://9124108705",
		"rbxassetid://9124108519",
		"rbxassetid://9124108233",
		"rbxassetid://9124107993",
		"rbxassetid://9124107862",
		"rbxassetid://9124107682",
		"rbxassetid://9124107682",
		"rbxassetid://9124107682",
		"rbxassetid://9124106995",
		"rbxassetid://9124106734"
	}
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9099051717",
		PlaybackSpeed = 1.25,
		Volume = 3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = script.Parent
	sound:Play()
	script.Parent.Ring:Emit(1)
	script.Parent.Spark:Emit(2)
	script.Parent.Ball:Emit(1)
end