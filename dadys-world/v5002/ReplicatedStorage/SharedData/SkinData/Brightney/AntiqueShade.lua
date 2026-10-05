return {
	Name = "Antique Shade",
	Cost = 600,
	DandyStore = true,
	OverwriteAnimations = {
		Run = "rbxassetid://140460025528188",
		Walk = "rbxassetid://112388974983746",
		Idle = "rbxassetid://100284093533851",
		Quirk = "rbxassetid://72241189500974",
		Decode = "rbxassetid://117566205501920",
		Ability = "rbxassetid://85289091170145"
	},
	FaceTextures = {
		Normal = "rbxassetid://89107504452084",
		Blink = "rbxassetid://130570393073457",
		Hurt = "rbxassetid://135433070521454"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(folder)
		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
				})
			end
		end
	end
}