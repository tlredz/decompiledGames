local VintageVee = {
	Name = "Vintage Vee",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Blink = "rbxassetid://91197920351910",
		Hurt = "rbxassetid://90407192278067",
		Normal = "rbxassetid://129753335817013"
	},
	USE_SKIN_MODEL = false
}

function VintageVee.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageVee.FaceTextures.Normal
		end
	end

	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")
	local toonLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight")
	local extraLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ExtraLight")
	local pointLight = toonLight and toonLight:FindFirstChild("PointLight")
	local pointLight2 = extraLight and extraLight:FindFirstChild("PointLight")
	local color = Color3.fromRGB(207, 207, 207)

	if pointLight then
		pointLight.Color = color
	end

	if pointLight2 then
		pointLight2.Color = color
	end
end

return VintageVee