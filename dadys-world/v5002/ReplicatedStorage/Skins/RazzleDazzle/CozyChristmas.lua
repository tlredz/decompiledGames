return {
	Name = "Cozy Christmas",
	TowerName = "RazzleDazzle",
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
		blinkTexture.Texture = "rbxassetid://105283863874559"
		hurtTexture.Texture = "rbxassetid://103298841656057"
		normalTexture.Texture = "rbxassetid://137985580819597"
		local v = {
			RightLeg = "RightUpperLeg",
			RightArm = "RightUpperArm",
			LeftLeg = "LeftUpperLeg",
			LeftArm = "LeftUpperArm"
		}

		for _, part in pairs(instance:GetChildren()) do
			if part:IsA("MeshPart") then
				part.Transparency = 1
			end
		end

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

		instance.RootPart.root:Destroy()
		clone.RootPart.root.Parent = instance.RootPart
		instance.Animate.Enabled = false
		instance.Animate.Enabled = true
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}