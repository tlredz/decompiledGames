local VintageEclipse = {
	Name = "Vintage Eclipse",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		TransformNormal = "rbxassetid://124520636845102",
		TransformHurt = "rbxassetid://88808713092537",
		TransformBlink = "rbxassetid://94333588839033",
		Normal = "rbxassetid://123902502438768",
		Hurt = "rbxassetid://88808713092537",
		Blink = "rbxassetid://94333588839033"
	},
	USE_SKIN_MODEL = false
}

function VintageEclipse.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageEclipse.FaceTextures.Normal
		end
	end

	local config = folder:WaitForChild("Config")
	local transformNormalTexture = config:WaitForChild("TransformNormalTexture")
	local transformHurtTexture = config:WaitForChild("TransformHurtTexture")
	local transformBlinkTexture = config:WaitForChild("TransformBlinkTexture")
	transformBlinkTexture.Texture = VintageEclipse.FaceTextures.TransformBlink
	transformHurtTexture.Texture = VintageEclipse.FaceTextures.TransformHurt
	transformNormalTexture.Texture = VintageEclipse.FaceTextures.TransformNormal
	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")
	local toonLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight")
	local extraLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ExtraLight")
	local pointLight = toonLight and toonLight:FindFirstChild("PointLight")
	local pointLight2 = extraLight and extraLight:FindFirstChild("PointLight")

	if pointLight then
		pointLight.Color = Color3.fromRGB(128, 128, 128)
	end

	if pointLight2 then
		pointLight2.Color = Color3.fromRGB(128, 128, 128)
	end

	local blackoutLight = folder:FindFirstChild("BlackoutLight", true)

	if blackoutLight then
		blackoutLight.Color = Color3.fromRGB(128, 128, 128)
	end
end

return VintageEclipse