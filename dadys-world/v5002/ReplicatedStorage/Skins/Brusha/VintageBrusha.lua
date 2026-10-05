return {
	Name = "Vintage Brusha",
	Mastery = true,
	ApplySkin = function(folder)
		folder:SetAttribute("PaintingTexture", "rbxassetid://91627552432293")

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("MeshPart") then
				if descendant.Material == Enum.Material.Neon then
					descendant.Color = Color3.fromRGB(155, 155, 155)
				else
					descendant.TextureID = "rbxassetid://127470696147948"
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
		local blinkTexture = config:FindFirstChild("BlinkTexture")
		local normalTexture = config:FindFirstChild("NormalTexture")
		normalTexture.Texture = "rbxassetid://127470696147948"
		hurtTexture.Texture = "rbxassetid://78021387864362"

		if blinkTexture then
			blinkTexture.Texture = "rbxassetid://120478298089445"
		end
	end
}