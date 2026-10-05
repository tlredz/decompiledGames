local VintageRibecca = {
	Name = "Vintage Ribecca",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://106389031528914",
		Blink = "rbxassetid://84980735025458",
		Hurt = "rbxassetid://85956386398745"
	},
	USE_SKIN_MODEL = false
}

function VintageRibecca.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageRibecca.FaceTextures.Normal
		end
	end
end

return VintageRibecca