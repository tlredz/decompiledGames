return {
	Name = "Vintage Razzle & Dazzle",
	Mastery = true,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://132072874750246"
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://122883622899098"
		local normalTexture = config:WaitForChild("NormalTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		normalTexture.Texture = "rbxassetid://132072874750246"
		blinkTexture.Texture = "rbxassetid://111762523536636"
	end
}