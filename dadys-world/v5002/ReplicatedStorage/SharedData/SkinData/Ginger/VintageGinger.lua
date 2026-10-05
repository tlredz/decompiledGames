local VintageGinger = {
	Name = "Vintage Ginger",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://90749700528324",
		Blink = "rbxassetid://99685620326502",
		Hurt = "rbxassetid://80280170588350"
	},
	USE_SKIN_MODEL = false
}

function VintageGinger.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageGinger.FaceTextures.Normal
		end
	end
end

return VintageGinger