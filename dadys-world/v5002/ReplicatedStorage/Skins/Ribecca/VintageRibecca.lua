return {
	Name = "Vintage Ribecca",
	Mastery = true,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://106389031528914"
			end
		end

		local config = folder:WaitForChild("Config")
		local normalTexture = config:WaitForChild("NormalTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		normalTexture.Texture = "rbxassetid://106389031528914"
		hurtTexture.Texture = "rbxassetid://85956386398745"
		blinkTexture.Texture = "rbxassetid://84980735025458"
	end
}