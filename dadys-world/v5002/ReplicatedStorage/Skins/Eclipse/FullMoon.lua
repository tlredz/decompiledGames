return {
	Name = "Full Moon",
	TowerName = "Eclipse",
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
		local transformBlinkTexture = config:WaitForChild("TransformBlinkTexture")
		local transformHurtTexture = config:WaitForChild("TransformHurtTexture")
		local transformNormalTexture = config:WaitForChild("TransformNormalTexture")
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
		local toonLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight")
		local extraLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ExtraLight")
		local pointLight = toonLight and toonLight:FindFirstChild("PointLight")
		local pointLight2 = extraLight and extraLight:FindFirstChild("PointLight")

		if pointLight then
			pointLight.Color = Color3.fromRGB(252, 238, 178)
		end

		if pointLight2 then
			pointLight2.Color = Color3.fromRGB(252, 238, 178)
		end

		blinkTexture.Texture = "rbxassetid://90045851893990"
		hurtTexture.Texture = "rbxassetid://93053102219394"
		normalTexture.Texture = "rbxassetid://134998968896270"
		transformBlinkTexture.Texture = "rbxassetid://90045851893990"
		transformHurtTexture.Texture = "rbxassetid://93053102219394"
		transformNormalTexture.Texture = "rbxassetid://114827039132468"
		local v = {}

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