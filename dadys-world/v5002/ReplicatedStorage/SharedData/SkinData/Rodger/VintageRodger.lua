local VintageRodger = {
	Name = "Vintage Rodger",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Blink = "rbxassetid://96234258193269",
		Hurt = "rbxassetid://115841830254985",
		Normal = "rbxassetid://140338986046587"
	},
	USE_SKIN_MODEL = false
}

function VintageRodger.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("MeshPart") or part.Material == Enum.Material.SmoothPlastic or part:HasTag("DontChangeTexture") then
			continue
		end

		part.TextureID = "rbxassetid://103859346618479"
	end

	local decal = folder:WaitForChild("HeadGlass"):WaitForChild("Decal")
	decal.Texture = VintageRodger.FaceTextures.Normal
end

return VintageRodger