return {
	Name = "Zapped Creation",
	TowerName = "Vee",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	ApplySkin = function(instance)
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://134409485069961"
		hurtTexture.Texture = "rbxassetid://129678438592785"
		normalTexture.Texture = "rbxassetid://93296441177635"
		local rigidConstraint = instance:WaitForChild("Head"):WaitForChild("StaticScreen"):WaitForChild("RigidConstraint")
		rigidConstraint.Attachment0 = nil
		instance.RootPart.root:Destroy()
		local root = clone.RootPart.root
		root.Parent = instance.RootPart
		rigidConstraint.Attachment0 = root:WaitForChild("torso"):WaitForChild("chest"):WaitForChild("head"):WaitForChild("HeadBoneAttachment")
		local animations = instance:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
		local toonLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight")
		local extraLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ExtraLight")
		local pointLight = toonLight and toonLight:FindFirstChild("PointLight")
		local pointLight2 = extraLight and extraLight:FindFirstChild("PointLight")

		if pointLight then
			pointLight.Color = Color3.fromRGB(198, 210, 114)
		end

		if pointLight2 then
			pointLight2.Color = Color3.fromRGB(198, 210, 114)
		end

		local v = {
			Shirt = "Torso"
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

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}