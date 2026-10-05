local VintageCocoa = {
	Name = "Vintage Cocoa",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://89253399145517",
		Hurt = "rbxassetid://79497423621285",
		Blink = "rbxassetid://85011026117801"
	},
	USE_SKIN_MODEL = false
}

function VintageCocoa.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageCocoa.FaceTextures.Normal
		end
	end
end

return VintageCocoa