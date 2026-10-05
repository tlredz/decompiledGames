local VintageBrightney = {
	Name = "Vintage Brightney",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://122333232731693",
		Blink = "rbxassetid://130359615208695",
		Hurt = "rbxassetid://121089833084787"
	},
	USE_SKIN_MODEL = false
}

function VintageBrightney.ApplySkin(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") and not descendant:HasTag("DontChangeTexture") then
			descendant.TextureID = VintageBrightney.FaceTextures.Normal
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
			})
		end
	end
end

return VintageBrightney