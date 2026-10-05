local VintageBlott = {
	Name = "Vintage Blot",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://80398903223351",
		Hurt = "rbxassetid://85255709382407",
		Blink = "rbxassetid://102442514304595"
	},
	USE_SKIN_MODEL = false,
	DecoyName = "BlotDecoyVintage"
}

function VintageBlott.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageBlott.FaceTextures.Normal
		end

		if not (part.Name == "LeftFoot" or part.Name == "RightFoot") then
			continue
		end

		part.TextureID = ""
		part.Color = Color3.new(0, 0, 0)
	end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	if require(ReplicatedStorage.SharedUtils.Universe):IsLobby() then
		return
	end

	local colorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	})
	local humanoidRootPart = folder:WaitForChild("HumanoidRootPart")
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

return VintageBlott