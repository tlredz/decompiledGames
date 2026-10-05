return {
	Name = "Inky Skull",
	TowerName = "Blott",
	Cost = 600,
	DandyStore = true,
	DecoyName = "BlotDecoyInkySkull",
	GeneratorOffset = {
		Y = 0.08,
		Z = -0.1
	},
	OverwriteAnimations = {
		Run = "rbxassetid://101475710776566",
		Walk = "rbxassetid://114440738472161",
		Idle = "rbxassetid://133086249164375",
		Ability = "rbxassetid://81209565719606",
		Quirk = "rbxassetid://108327693918704",
		Quirk_2 = "rbxassetid://116481286366991",
		Decode = "rbxassetid://125944881044658"
	},
	FaceTextures = {
		Normal = "rbxassetid://108724186955760",
		Blink = "rbxassetid://129341909732163",
		Hurt = "rbxassetid://117404841866741"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")

		if require(ReplicatedStorage.SharedUtils.Universe):IsLobby() then
			return
		end

		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		})
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		task.spawn(function()
			local particles = humanoidRootPart:WaitForChild("Particles", 3)

			if not particles then
				return
			end

			local particleEmitter = particles:WaitForChild("ParticleEmitter")
			local particleEmitter2 = humanoidRootPart:WaitForChild("Particles2"):WaitForChild("ParticleEmitter")
			particleEmitter.Color = colorSequence
			particleEmitter2.Color = colorSequence
		end)
	end
}