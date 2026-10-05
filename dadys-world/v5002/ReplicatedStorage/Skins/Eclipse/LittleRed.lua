return {
	Name = "Little Red",
	TowerName = "Eclipse",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	ApplySkin = function(instance)
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		instance.RootPart["root.x"]:Destroy()
		clone.RootPart["root.x"].Parent = instance.RootPart
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		local transformBlinkTexture = config:WaitForChild("TransformBlinkTexture")
		local transformHurtTexture = config:WaitForChild("TransformHurtTexture")
		local transformNormalTexture = config:WaitForChild("TransformNormalTexture")
		blinkTexture.Texture = "rbxassetid://125483290859492"
		hurtTexture.Texture = "rbxassetid://112812686636876"
		normalTexture.Texture = "rbxassetid://99307621298150"
		transformBlinkTexture.Texture = "rbxassetid://125483290859492"
		transformHurtTexture.Texture = "rbxassetid://112812686636876"
		transformNormalTexture.Texture = "rbxassetid://92113188663412"
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
		local toonLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight")
		local extraLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ExtraLight")
		local pointLight = toonLight and toonLight:FindFirstChild("PointLight")
		local pointLight2 = extraLight and extraLight:FindFirstChild("PointLight")

		if pointLight then
			pointLight.Color = Color3.fromRGB(220, 84, 112)
		end

		if pointLight2 then
			pointLight2.Color = Color3.fromRGB(220, 84, 112)
		end

		local v = {
			Glasses_Geo = "Head",
			Glasses_Lens_Geo = "Head"
		}

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local weld = Instance.new("Weld")
			local child = instance:WaitForChild(v[part.Name] or part.Name)
			part.Parent = child
			weld.Parent = part
			weld.Part0 = part
			weld.Part1 = child
			part.Anchored = false
			child.Transparency = 1
		end

		local cape_Geo = instance:WaitForChild("Cape_Geo")
		cape_Geo.Transparency = 1
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}