local VintageLooey = {
	Name = "Vintage Looey",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://78479926240886",
		Hurt = "rbxassetid://86226634254704",
		Blink = "rbxassetid://113247110467375"
	},
	USE_SKIN_MODEL = false
}

function VintageLooey.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageLooey.FaceTextures.Normal
		end
	end
end

return VintageLooey