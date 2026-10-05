local VintageYatta = {
	Name = "Vintage Yatta",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://99865528152477",
		Hurt = "rbxassetid://95333038380477",
		Blink = "rbxassetid://83143380135989"
	},
	USE_SKIN_MODEL = false
}

function VintageYatta.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageYatta.FaceTextures.Normal
		end
	end
end

return VintageYatta