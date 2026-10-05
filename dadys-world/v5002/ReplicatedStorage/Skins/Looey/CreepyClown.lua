return {
	Name = "Creepy Clown",
	TowerName = "Looey",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	ApplySkin = function(instance)
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		instance.RootPart.root:Destroy()
		clone.RootPart.root.Parent = instance.RootPart
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://90105282450568"
		hurtTexture.Texture = "rbxassetid://138976200855729"
		normalTexture.Texture = "rbxassetid://84613214899393"
		local animations = instance:WaitForChild("Animations")

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
			if not (part:IsA("MeshPart") or v[part.Name]) then
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

		local lowerTorso = instance:WaitForChild("LowerTorso")
		lowerTorso.Transparency = 1
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}