local VintageSoulvester = {
	Name = "Vintage Soulvester",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://111934462091702",
		Blink = "rbxassetid://108056744847322",
		Hurt = "rbxassetid://108105347522289"
	},
	USE_SKIN_MODEL = false
}

function VintageSoulvester.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageSoulvester.FaceTextures.Normal
		end
	end

	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")
	local toonLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight")
	local extraLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ExtraLight")
	local pointLight = toonLight and toonLight:FindFirstChild("PointLight")
	local pointLight2 = extraLight and extraLight:FindFirstChild("PointLight")

	if pointLight then
		pointLight.Color = Color3.fromRGB(255, 255, 255)
	end

	if pointLight2 then
		pointLight2.Color = Color3.fromRGB(255, 255, 255)
	end
end

return VintageSoulvester