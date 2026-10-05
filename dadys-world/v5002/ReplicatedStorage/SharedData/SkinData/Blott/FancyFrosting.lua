local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Fancy Frosting",
	TowerName = "Blott",
	Description = "No description yet",
	Mastery = false,
	Cost = 1200,
	Requirement1 = { "Baskets", 1200 },
	Requirement2 = { "Coin", 1200 },
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W4,
	Easter = true,
	HolidaySkin = true,
	DecoyName = "BlotDecoyFruityFrosting",
	OverwriteAnimations = {
		Quirk_2 = "rbxassetid://113745182024580",
		Run = "rbxassetid://135797909866470",
		Walk = "rbxassetid://138744026494998",
		Idle = "rbxassetid://77511767447167",
		Quirk = "rbxassetid://103515239820041",
		Decode = "rbxassetid://99708463404059",
		Ability = "rbxassetid://118391400779513"
	},
	FaceTextures = {
		Normal = "rbxassetid://112106325838843",
		Blink = "rbxassetid://137539741118725",
		Hurt = "rbxassetid://110436338271072"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

		if require(ReplicatedStorage2.SharedUtils.Universe):IsLobby() then
			return
		end

		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(182, 150, 164)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(182, 150, 164))
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