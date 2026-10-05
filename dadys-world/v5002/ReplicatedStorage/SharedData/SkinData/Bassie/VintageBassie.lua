local VintageBassie = {
	Name = "Vintage Bassie",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://82363019718744",
		Blink = "rbxassetid://127004780700052",
		Hurt = "rbxassetid://112882168353810"
	},
	USE_SKIN_MODEL = false
}

function VintageBassie.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageBassie.FaceTextures.Normal
		end
	end
end

return VintageBassie