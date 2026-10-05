local VintageCoal = {
	Name = "Vintage Coal",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://85834575316600",
		Blink = "rbxassetid://114152938698616",
		Hurt = "rbxassetid://117630025911000"
	},
	USE_SKIN_MODEL = false
}

function VintageCoal.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageCoal.FaceTextures.Normal
		end
	end
end

return VintageCoal