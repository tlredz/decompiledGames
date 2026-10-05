return {
	Name = "Cosmic Signal",
	DandyStore = true,
	Cost = 600,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://79836272795363"
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://78617770629832"
		local normalTexture = config:WaitForChild("NormalTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		normalTexture.Texture = "rbxassetid://79836272795363"
		blinkTexture.Texture = "rbxassetid://76390371833357"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()

		for _, part in pairs(clone:GetChildren()) do
			print(part)

			if not part:IsA("MeshPart") then
				continue
			end

			if part.Name == "Hat" then
				local weld = Instance.new("Weld")
				part.Parent = folder:WaitForChild("Head")
				weld.Parent = part
				weld.Part0 = part
				weld.Part1 = folder:WaitForChild("Head")
				part.Anchored = false
			else
				local weld = Instance.new("Weld")
				part.Parent = folder:WaitForChild(part.Name)
				weld.Parent = part
				weld.Part0 = part
				weld.Part1 = folder:WaitForChild(part.Name)
				part.Anchored = false
				local waitForChild = folder:WaitForChild(part.Name)
				waitForChild.Transparency = 1
			end
		end

		clone.cape.Parent = folder
		local attachment = clone.QuickLinks.CapeAttachment.Value
		folder.QuickLinks.RigidConstraint.Value.Attachment1 = attachment
		local children = clone.Animations:GetChildren()

		for _, v in pairs(children) do
			folder.Animations[tostring(v)].AnimationId = v.AnimationId
		end

		folder.Animate.Enabled = false
		folder.Animate.Enabled = true
		folder.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(121, 110, 207)
	end
}