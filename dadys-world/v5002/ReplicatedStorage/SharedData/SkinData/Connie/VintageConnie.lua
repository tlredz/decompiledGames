local VintageConnie = {
	Name = "Vintage Connie",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Blink = "rbxassetid://90299781994020",
		Hurt = "rbxassetid://121613651890481",
		Normal = "rbxassetid://93259414601902"
	},
	USE_SKIN_MODEL = false
}

function VintageConnie.ApplySkin(folder)
	local color = Color3.fromRGB(207, 207, 207)

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("MeshPart") then
			continue
		end

		part.TextureID = VintageConnie.FaceTextures.Normal
		part.Color = color
	end

	folder:SetAttribute(
		"AlternateColor",
		(ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color) }))
	)

	for _, light in pairs(folder.HumanoidRootPart:GetDescendants()) do
		if light:IsA("Light") then
			light.Color = color
		end
	end
end

return VintageConnie