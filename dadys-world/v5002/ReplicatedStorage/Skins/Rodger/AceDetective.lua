return {
	Name = "Ebony Detective",
	Creator = 925476472,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if not (part:IsA("MeshPart") and part.Material ~= Enum.Material.SmoothPlastic and part.Name ~= "HeadGlass") then
				continue
			end

			part.TextureID = "rbxassetid://86854944999267"
		end

		folder.HeadGlass.Decal.Texture = "rbxassetid://127059249684000"
		local config = folder:WaitForChild("Config")
		local normalTexture = config:WaitForChild("NormalTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		blinkTexture.Texture = "rbxassetid://96234258193269"
		hurtTexture.Texture = "rbxassetid://79192641097034"
		normalTexture.Texture = "rbxassetid://127059249684000"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local animations = folder:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {
			_Head = "Head"
		}

		for _, part in pairs(clone:GetChildren()) do
			if not (part:IsA("MeshPart") and part.Name ~= "HeadGlass") then
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
	end
}