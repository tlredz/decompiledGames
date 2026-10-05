local VintageSquirm = {
	Name = "Vintage Squirm",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Blink = "rbxassetid://87927772793877",
		Hurt = "rbxassetid://85756035257217",
		Normal = "rbxassetid://120199825799200"
	},
	USE_SKIN_MODEL = false
}

function VintageSquirm.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageSquirm.FaceTextures.Normal
		end
	end
end

return VintageSquirm