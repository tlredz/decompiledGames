return {
	Name = "Vintage Rodger",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") and part.Material ~= Enum.Material.SmoothPlastic then
				part.TextureID = "rbxassetid://103859346618479"
			end
		end

		folder.HeadGlass.Decal.Texture = "rbxassetid://140338986046587"
		folder.Head.Name ..= "_"
		local config = folder:WaitForChild("Config")
		local normalTexture = config:WaitForChild("NormalTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		blinkTexture.Texture = "rbxassetid://96234258193269"
		hurtTexture.Texture = "rbxassetid://115841830254985"
		normalTexture.Texture = "rbxassetid://140338986046587"
	end
}