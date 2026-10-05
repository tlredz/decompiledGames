return {
	Name = "Vintage Eclipse",
	Mastery = true,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://123902502438768"
			end
		end

		local config = folder:WaitForChild("Config")
		local normalTexture = config:WaitForChild("NormalTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local transformNormalTexture = config:WaitForChild("TransformNormalTexture")
		local transformHurtTexture = config:WaitForChild("TransformHurtTexture")
		local transformBlinkTexture = config:WaitForChild("TransformBlinkTexture")
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

		normalTexture.Texture = "rbxassetid://123902502438768"
		hurtTexture.Texture = "rbxassetid://88808713092537"
		blinkTexture.Texture = "rbxassetid://94333588839033"
		transformNormalTexture.Texture = "rbxassetid://124520636845102"
		transformHurtTexture.Texture = "rbxassetid://88808713092537"
		transformBlinkTexture.Texture = "rbxassetid://94333588839033"
		local blackoutLight = folder:FindFirstChild("BlackoutLight", true)

		if blackoutLight then
			blackoutLight.Color = Color3.fromRGB(128, 128, 128)
		end
	end
}