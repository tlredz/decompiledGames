return {
	Name = "Vintage Soulvester",
	Mastery = true,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://111934462091702"
			end
		end

		local config = folder:WaitForChild("Config")
		local normalTexture = config:WaitForChild("NormalTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		normalTexture.Texture = "rbxassetid://111934462091702"
		hurtTexture.Texture = "rbxassetid://108105347522289"
		blinkTexture.Texture = "rbxassetid://108056744847322"
	end
}