local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function()
	local mesh = script.Parent.n.Mesh
	local mesh2 = script.Parent.n2.Mesh
	mesh.Scale = createVector(0.25, 0.5, 0.5)
	mesh2.Scale = createVector(1, 0.75, 0.75)
	mesh2.Offset = createVector(5, 0, 0)
	mesh.Offset = Vector3.new()
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9366054763",
		Volume = 3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = script.Parent.Primary
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9279738916",
		Volume = 0.5
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = script.Parent.Primary
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9191515635",
		Volume = 1.5,
		PlaybackSpeed = 1.5
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = script.Parent.Primary
	sound3:Play()
	wait()
	game.TweenService:Create(mesh, TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		Scale = createVector(0.5, 0, 0),
		Offset = createVector(0, 0, 0)
	}):Play()
	game.TweenService:Create(mesh2, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		Scale = createVector(1.75, 0, 0)
	}):Play()
	wait(0.05)
end