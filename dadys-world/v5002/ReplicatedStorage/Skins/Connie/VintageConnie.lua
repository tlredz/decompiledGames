return {
	Name = "Vintage Connie",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://93259414601902"
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://121613651890481"
		local normalTexture = config:WaitForChild("NormalTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		normalTexture.Texture = "rbxassetid://93259414601902"
		blinkTexture.Texture = "rbxassetid://90299781994020"
		folder.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(207, 207, 207)
	end
}