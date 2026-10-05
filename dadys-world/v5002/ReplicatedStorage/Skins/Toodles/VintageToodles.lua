return {
	Name = "Vintage Toodles",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://104112028738711"
			end
		end

		local config = folder:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://135434516698701"
		hurtTexture.Texture = "rbxassetid://121110095885587"
		normalTexture.Texture = "rbxassetid://104112028738711"
	end
}