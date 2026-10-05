local VintageGigi = {
	Name = "Vintage Gigi",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://114459075739089",
		Blink = "rbxassetid://89321836642212",
		Hurt = "rbxassetid://85442511643201"
	},
	USE_SKIN_MODEL = false
}

function VintageGigi.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageGigi.FaceTextures.Normal
		end
	end
end

return VintageGigi