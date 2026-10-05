local CollectionService = game:GetService("CollectionService")
return {
	Name = "Frosty Mittens",
	HolidaySkin = true,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if not part:IsA("MeshPart") then
				continue
			end

			part.TextureID = "rbxassetid://103702366962904"

			if CollectionService:hasTag(part, "SkinPart") then
				CollectionService:RemoveTag(part, "SkinPart")
			end
		end

		folder:SetAttribute(
			"AlternateColor",
			(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(0.2, Color3.fromRGB(248, 221, 244)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(252, 192, 243))
			}))
		)
		folder.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(252, 192, 243)
		folder.HumanoidRootPart.ExtraLight.PointLight.Color = Color3.fromRGB(252, 192, 243)
		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://85761097152398"
		local normalTexture = config:WaitForChild("NormalTexture")
		normalTexture.Texture = "rbxassetid://103702366962904"
		local blinkTexture = config:WaitForChild("BlinkTexture")
		blinkTexture.Texture = "rbxassetid://135022145474790"
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