local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local PeodizLightning = require(ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules").PeodizLightning)
return function(p)
	local targetPosition = p.TargetPosition
	local startPositon = p.StartPositon
	PeodizLightning.new(0.5, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		Position1 = startPositon,
		Position2 = targetPosition,
		Step = 5
	}):Play()
	local clone = ReplicatedStorage.Chest.SwordEffect.Longaevus.Shock:Clone()
	clone.CFrame = CFrame.new(startPositon, targetPosition) * CFrame.new(
		0,
		0,
		-(startPositon - targetPosition).Magnitude / 2
	)
	clone.Size = createVector(0.5, 0.5, 0)
	clone.Parent = workspace.Effects
	clone.ParticleEmitter2:Emit(math.random(2, 4))
	_G.PU:Dust(clone, 1.55)
	local TweenService = game:GetService("TweenService")
	TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential), {
		Size = Vector3.new(4.5, 4.5, (startPositon - targetPosition).Magnitude)
	}):Play()
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(clone, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
		CFrame = clone.CFrame * CFrame.Angles(0, 0, 6.283185307179586 * math.random())
	}):Play()
	local clone2 = ReplicatedStorage.Chest.SwordEffect.Longaevus.SoundPart2:Clone()
	_G.PU:Dust(clone2, 1.2)
	clone2.CFrame = CFrame.new(startPositon)
	clone2.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9203313181",
		Volume = 3,
		PlaybackSpeed = math.random(90, 110) / 100
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9185254682",
		Volume = 3,
		PlaybackSpeed = math.random(150, 190) / 100
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()
	spawn(function()
		wait(0.3)
		local TweenService3 = game:GetService("TweenService")
		TweenService3:Create(clone, TweenInfo.new(0.77, Enum.EasingStyle.Quart), {
			Transparency = 1
		}):Play()
	end)
end