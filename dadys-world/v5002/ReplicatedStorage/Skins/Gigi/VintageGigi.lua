return {
	Name = "Vintage Gigi",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") and part.Name ~= "LidGeo" then
				part.TextureID = "rbxassetid://114459075739089"
			end
		end

		local config = folder:WaitForChild("Config")
		local normalTexture = config:WaitForChild("NormalTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		blinkTexture.Texture = "rbxassetid://89321836642212"
		hurtTexture.Texture = "rbxassetid://85442511643201"
		normalTexture.Texture = "rbxassetid://114459075739089"
	end
}