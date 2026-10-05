return {
	Name = "Sanguine Silence",
	TowerName = "Blott",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	HolidayYear = 2025,
	DecoyName = "BlotDecoySanguineSilence",
	OverwriteAnimations = {
		Run = "rbxassetid://92489402713516",
		Walk = "rbxassetid://131770818989788",
		Idle = "rbxassetid://100351437201289",
		Quirk = "rbxassetid://83746190372026",
		Decode = "rbxassetid://97777532031174",
		Ability = "rbxassetid://126743231389053",
		Quirk_2 = "rbxassetid://116902446833462"
	},
	FaceTextures = {
		Normal = "rbxassetid://95454602326287",
		Blink = "rbxassetid://97999390942492",
		Hurt = "rbxassetid://136644576625716"
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