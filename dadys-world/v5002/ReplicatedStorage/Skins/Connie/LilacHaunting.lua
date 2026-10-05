local CollectionService = game:GetService("CollectionService")
return {
	Name = "Lilac Haunting",
	HolidaySkin = true,
	EasterSkin = true,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://81072404342708"
			end

			if CollectionService:hasTag(part, "SkinPart") then
				CollectionService:RemoveTag(part, "SkinPart")
			end
		end

		folder:SetAttribute(
			"AlternateColor",
			(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(227, 212, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(161, 130, 217))
			}))
		)
		folder.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(161, 130, 217)
		folder.HumanoidRootPart.ExtraLight.PointLight.Color = Color3.fromRGB(161, 130, 217)
		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://106022233381525"
		local normalTexture = config:WaitForChild("NormalTexture")
		normalTexture.Texture = "rbxassetid://81072404342708"
		local blinkTexture = config:WaitForChild("BlinkTexture")
		blinkTexture.Texture = "rbxassetid://92701651982193"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
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