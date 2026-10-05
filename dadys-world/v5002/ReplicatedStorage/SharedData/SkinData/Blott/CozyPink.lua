return {
	Name = "Cozy Pink",
	Cost = 600,
	DandyStore = true,
	DecoyName = "BlotDecoyCozyPink",
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
		Normal = "rbxassetid://125047300386210",
		Hurt = "rbxassetid://95814605131400",
		Blink = "rbxassetid://99495626331317"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")

		if require(ReplicatedStorage.SharedUtils.Universe):IsLobby() then
			return
		end

		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(21, 3, 7)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 3, 7))
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