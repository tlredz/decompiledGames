return {
	Name = "Vintage Brightney",
	ApplySkin = function(folder)
		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("MeshPart") then
				if descendant.Material == Enum.Material.Neon then
					descendant.Color = Color3.fromRGB(176, 176, 176)
				else
					descendant.TextureID = "rbxassetid://17676556539"
				end
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
				})
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://17676559743"
		local normalTexture = config:WaitForChild("NormalTexture")
		normalTexture.Texture = "rbxassetid://17676556539"
	end
}