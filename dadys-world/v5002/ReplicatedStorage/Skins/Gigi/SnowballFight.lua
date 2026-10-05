return {
	Name = "Snowball Fight",
	TowerName = "Gigi",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Christmas = true,
	HolidaySkin = true,
	ApplySkin = function(instance)
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://103461149002726"
		hurtTexture.Texture = "rbxassetid://127926547928140"
		normalTexture.Texture = "rbxassetid://99212494281662"
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
			SnowballGeo = "Head"
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