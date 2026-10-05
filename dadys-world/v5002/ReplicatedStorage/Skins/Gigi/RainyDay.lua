return {
	Name = "Rainy Day",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") and part.Name ~= "LidGeo" then
				part.TextureID = "rbxassetid://82055670340885"
			end
		end

		local config = folder:WaitForChild("Config")
		local normalTexture = config:WaitForChild("NormalTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		blinkTexture.Texture = "rbxassetid://95341845545372"
		hurtTexture.Texture = "rbxassetid://89609152301282"
		normalTexture.Texture = "rbxassetid://131488359790341"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		folder.RootPart["root.x"]:Destroy()
		clone.RootPart["root.x"].Parent = folder.RootPart
		local animations = folder:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {}

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