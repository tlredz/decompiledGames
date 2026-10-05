return {
	Name = "List Maker",
	TowerName = "Rodger",
	Description = "No description yet",
	Mastery = false,
	Cost = 1200,
	Unlocks = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0),
	Requirement1 = { "Christmas2025Ornaments", 1200 },
	Requirement2 = { "Coin", 1200 },
	Christmas = true,
	HolidaySkin = true,
	ApplySkin = function(instance)
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		instance.HeadGlass.Decal.Texture = "rbxassetid://127059249684000"
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://96234258193269"
		hurtTexture.Texture = "rbxassetid://79192641097034"
		normalTexture.Texture = "rbxassetid://127059249684000"
		instance.RootPart["root.x"]:Destroy()
		clone.RootPart["root.x"].Parent = instance.RootPart
		local animations = instance:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {
			_Head = "Head",
			HatGeo = "Head"
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

		for _, child in pairs(clone.HumanoidRootPart:GetChildren()) do
			child.Parent = instance.HumanoidRootPart
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}