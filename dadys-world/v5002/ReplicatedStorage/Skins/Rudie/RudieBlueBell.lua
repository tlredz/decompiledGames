return {
	Name = "Rudie Bluebell",
	HolidaySkin = true,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") and part.Name ~= "Nose" then
				part.TextureID = "rbxassetid://93083268903119"
			end
		end

		local nose = folder:WaitForChild("Nose", 5)

		if nose then
			nose.Color = Color3.new(0.360784, 0.615686, 1)
			nose.Size = Vector3.new(nose.Size.X, 0.4, nose.Size.Z)

			for _, light in pairs(nose:GetDescendants()) do
				if light:IsA("PointLight") or light:IsA("SpotLight") then
					light.Color = Color3.new(0.360784, 0.615686, 1)
				end
			end
		else
			warn("[RudieBlueBell] Nose part not found - skipping nose customization")
		end

		local humanoidRootPart = folder:WaitForChild("HumanoidRootPart")

		for _, light in pairs(humanoidRootPart:GetDescendants()) do
			if light:IsA("PointLight") or light:IsA("SpotLight") then
				light.Color = Color3.fromRGB(16, 77, 196)
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://104051737949847"
		local normalTexture = config:WaitForChild("NormalTexture")
		normalTexture.Texture = "rbxassetid://93083268903119"
		local blinkTexture = config:WaitForChild("BlinkTexture")
		blinkTexture.Texture = "rbxassetid://120058044247679"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()

		for _, part in pairs(clone:GetChildren()) do
			if not (part:IsA("MeshPart") and part.Name ~= "Nose") then
				continue
			end

			local weld = Instance.new("Weld")
			part.Parent = folder:WaitForChild(part.Name)
			weld.Parent = part
			weld.Part0 = part
			weld.Part1 = folder:WaitForChild(part.Name)
			part.Anchored = false
			local waitForChild = folder:WaitForChild(part.Name)
			waitForChild.Transparency = 1
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}