local VintageTeagan = {
	Name = "Vintage Teagan",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Blink = "rbxassetid://134362245620007",
		Hurt = "rbxassetid://113008779563401",
		Normal = "rbxassetid://100194622211282"
	},
	USE_SKIN_MODEL = false
}

function VintageTeagan.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageTeagan.FaceTextures.Normal
		end
	end

	folder.Head.Particles.ParticleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50))
	})
	folder.Head.Particles.ParticleEmitter2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50))
	})
end

return VintageTeagan