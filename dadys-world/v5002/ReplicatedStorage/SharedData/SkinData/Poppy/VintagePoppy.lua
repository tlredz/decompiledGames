local VintagePoppy = {
	Name = "Vintage Poppy",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Blink = "rbxassetid://102790143676193",
		Hurt = "rbxassetid://17675712871",
		Normal = "rbxassetid://17675710022"
	},
	USE_SKIN_MODEL = false
}

function VintagePoppy.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintagePoppy.FaceTextures.Normal
		end
	end
end

return VintagePoppy