local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Chilly Penguin",
	TowerName = "Blott",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W4,
	Christmas = true,
	HolidaySkin = true,
	DecoyName = "BlotDecoyPenguinBlott",
	OverwriteAnimations = {
		Run = "rbxassetid://116382128617198",
		Walk = "rbxassetid://111956853718786",
		Idle = "rbxassetid://84864853462167",
		Quirk = "rbxassetid://118360066825530",
		Decode = "rbxassetid://113952389112479",
		Ability = "rbxassetid://97743476332216",
		Quirk_2 = "rbxassetid://129747143449512"
	},
	FaceTextures = {
		Normal = "rbxassetid://84806792174302",
		Blink = "rbxassetid://95363812770913",
		Hurt = "rbxassetid://77968069202275"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

		if require(ReplicatedStorage2.SharedUtils.Universe):IsLobby() then
			return
		end

		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 89, 166)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 89, 166))
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