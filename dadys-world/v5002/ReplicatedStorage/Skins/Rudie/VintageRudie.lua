return {
	Name = "Vintage Rudie",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") and part.Name ~= "Nose" then
				part.TextureID = "rbxassetid://92994092090592"
			end
		end

		local nose = folder:WaitForChild("Nose", 5)

		if nose then
			nose.Color = Color3.new(1, 1, 1)

			for _, light in pairs(nose:GetDescendants()) do
				if light:IsA("PointLight") or light:IsA("SpotLight") then
					light.Color = Color3.new(1, 1, 1)
				end
			end
		else
			warn("[VintageRudie] Nose part not found - skipping nose customization")
		end

		local humanoidRootPart = folder:WaitForChild("HumanoidRootPart")

		for _, light in pairs(humanoidRootPart:GetDescendants()) do
			if light:IsA("PointLight") or light:IsA("SpotLight") then
				light.Color = Color3.new(1, 1, 1)
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://113785447525723"
		local normalTexture = config:WaitForChild("NormalTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		normalTexture.Texture = "rbxassetid://92994092090592"
		blinkTexture.Texture = "rbxassetid://139975153263997"
	end
}