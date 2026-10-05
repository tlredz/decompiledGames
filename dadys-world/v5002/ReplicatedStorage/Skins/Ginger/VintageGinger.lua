return {
	Name = "Vintage Ginger",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://90749700528324"
			end
		end

		local config = folder:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://99685620326502"
		hurtTexture.Texture = "rbxassetid://80280170588350"
		normalTexture.Texture = "rbxassetid://90749700528324"
	end
}