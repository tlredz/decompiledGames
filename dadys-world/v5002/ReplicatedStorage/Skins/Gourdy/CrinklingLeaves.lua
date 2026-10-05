return {
	Name = "Crinkling Leaves",
	TowerName = "Gourdy",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	ApplySkin = function(instance)
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://75719910852011"
		hurtTexture.Texture = "rbxassetid://117393833656119"
		normalTexture.Texture = "rbxassetid://113866530082523"
		instance.RootPart.root:Destroy()
		clone.RootPart.root.Parent = instance.RootPart
		local animations = instance:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {
			Taill = "Tail",
			Head = "Head_Geo"
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