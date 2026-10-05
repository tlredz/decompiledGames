return {
	Name = "Vintage Looey",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://78479926240886"
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://86226634254704"
		local normalTexture = config:WaitForChild("NormalTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		normalTexture.Texture = "rbxassetid://78479926240886"
		blinkTexture.Texture = "rbxassetid://113247110467375"
	end
}