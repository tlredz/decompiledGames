return {
	Name = "Vintage Coal",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://85834575316600"
			end
		end

		local config = folder:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://114152938698616"
		hurtTexture.Texture = "rbxassetid://117630025911000"
		normalTexture.Texture = "rbxassetid://85834575316600"
	end
}