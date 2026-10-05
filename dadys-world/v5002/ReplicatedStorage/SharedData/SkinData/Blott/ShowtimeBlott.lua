return {
	Name = "Show-Time Blot",
	DecoyName = "BlotDecoyShowtime",
	OverwriteAnimations = {
		Run = "rbxassetid://105628011122110",
		Walk = "rbxassetid://76703698283994",
		Idle = "rbxassetid://73993990162132",
		Quirk = "rbxassetid://108937676109525",
		Decode = "rbxassetid://116500889072011",
		Ability = "rbxassetid://82315667887245",
		Quirk_2 = "rbxassetid://84847950895504"
	},
	FaceTextures = {
		Normal = "rbxassetid://76874388784568",
		Hurt = "rbxassetid://128704050526816",
		Blink = "rbxassetid://102223273583604"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")

		if require(ReplicatedStorage.SharedUtils.Universe):IsLobby() then
			return
		end

		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 31, 40)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 31, 40))
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