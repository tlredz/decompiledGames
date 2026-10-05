local VintageFlyte = {
	Name = "Vintage Flyte",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://77678357664294",
		Hurt = "rbxassetid://105145745885574",
		Blink = "rbxassetid://112446707586788"
	},
	USE_SKIN_MODEL = false
}

function VintageFlyte.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageFlyte.FaceTextures.Normal
		end
	end
end

return VintageFlyte