local CollectionService = game:GetService("CollectionService")
return {
	Name = "Ghastly Glow",
	TowerName = "Connie",
	Description = "No description yet",
	Halloween = true,
	HolidaySkin = true,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://130099326342245"
			end

			if CollectionService:HasTag(part, "SkinPart") then
				CollectionService:RemoveTag(part, "SkinPart")
			end
		end

		folder:SetAttribute(
			"AlternateColor",
			(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(198, 198, 222)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(198, 198, 222))
			}))
		)
		folder.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(198, 198, 222)
		folder.HumanoidRootPart.ExtraLight.PointLight.Color = Color3.fromRGB(198, 198, 222)
		local config = folder:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://74551710989470"
		hurtTexture.Texture = "rbxassetid://87138482960611"
		normalTexture.Texture = "rbxassetid://130099326342245"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local animations = folder:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {
			RightUpperArm = "RightUpperrArm",
			Torso = "UpperTorso"
		}

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local weld = Instance.new("Weld")
			local child = folder:WaitForChild(v[part.Name] or part.Name)
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