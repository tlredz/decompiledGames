local VintageRazzleDazzle = {
	Name = "Vintage Razzle & Dazzle",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Blink = "rbxassetid://111762523536636",
		Hurt = "rbxassetid://122883622899098",
		Normal = "rbxassetid://132072874750246"
	},
	USE_SKIN_MODEL = false
}

function VintageRazzleDazzle.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageRazzleDazzle.FaceTextures.Normal
		end
	end
end

return VintageRazzleDazzle