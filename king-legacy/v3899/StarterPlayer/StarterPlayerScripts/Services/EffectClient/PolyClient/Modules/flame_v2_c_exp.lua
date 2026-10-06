local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
return function(p, _)
	local _ = game.Players.LocalPlayer
	local cf = p.cf
	local clone = replicatedStorage.Chest.FruitEffect.Flame.V2.bullet_exp:Clone()
	_G.PU:Dust(clone, 1)
	clone.CFrame = CFrame.new(cf.p)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://14975860524",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local pointLight = Instance.new("PointLight")
	pointLight.Color = Color3.fromRGB(255, 81, 0)
	pointLight.Range = 60
	pointLight.Brightness = 1
	pointLight.Parent = clone
	TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = 0.5,
		Range = 0
	}):Play()

	for _, emitter in pairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end