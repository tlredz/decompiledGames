return {
	Name = "Vintage Vee",
	Mastery = true,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://129753335817013"
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://90407192278067"
		local normalTexture = config:WaitForChild("NormalTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		normalTexture.Texture = "rbxassetid://129753335817013"
		blinkTexture.Texture = "rbxassetid://91197920351910"
		folder.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(207, 207, 207)
	end
}