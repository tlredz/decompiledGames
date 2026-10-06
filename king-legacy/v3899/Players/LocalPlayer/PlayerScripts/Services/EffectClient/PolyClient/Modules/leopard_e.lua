local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
game:GetService("RunService")
return function(player, _)
	local _ = game.Players.LocalPlayer
	local startCF = player.StartCF
	local _ = player.Character
	local cFMouse = player.CFMouse
	local clone = replicatedStorage.Chest.FruitEffect.Leopard.bullet:Clone()
	_G.PU:Dust(clone, player.Speed + 1)
	clone.CastShadow = false
	clone.Color = Color3.fromRGB(255, 255, 121)
	clone.CFrame = startCF
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(player.Speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Transparency = 1,
		CFrame = cFMouse
	}):Play()

	for _, emitter in pairs(clone.at:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	wait(player.Speed)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	local clone2 = replicatedStorage.Chest.FruitEffect.Leopard.bullet_exp:Clone()
	_G.PU:Dust(clone2, 2)
	clone2.CFrame = cFMouse
	clone2.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://14975860524",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end
end