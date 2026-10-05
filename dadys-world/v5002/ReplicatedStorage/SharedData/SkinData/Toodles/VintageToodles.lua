local VintageToodles = {
	Name = "Vintage Toodles",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Blink = "rbxassetid://135434516698701",
		Hurt = "rbxassetid://121110095885587",
		Normal = "rbxassetid://104112028738711"
	},
	USE_SKIN_MODEL = false
}

function VintageToodles.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageToodles.FaceTextures.Normal
		end
	end
end

return VintageToodles