local VintageBoxten = {
	Name = "Vintage Boxten",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Blink = "rbxassetid://133783482176916",
		Hurt = "rbxassetid://120843218448264",
		Normal = "rbxassetid://17675982938"
	},
	USE_SKIN_MODEL = false
}

function VintageBoxten.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageBoxten.FaceTextures.Normal
		end
	end
end

return VintageBoxten