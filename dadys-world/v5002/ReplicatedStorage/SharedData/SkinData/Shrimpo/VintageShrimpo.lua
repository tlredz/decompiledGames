local VintageShrimpo = {
	Name = "Vintage Shrimpo",
	OverwriteAnimations = {},
	FaceTextures = {
		Blink = "rbxassetid://137961682100953",
		Hurt = "rbxassetid://122425957586245",
		Normal = "rbxassetid://104915857820906"
	},
	USE_SKIN_MODEL = false
}

function VintageShrimpo.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageShrimpo.FaceTextures.Normal
		end
	end
end

return VintageShrimpo