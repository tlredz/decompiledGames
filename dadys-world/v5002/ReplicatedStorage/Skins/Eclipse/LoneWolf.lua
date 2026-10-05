return {
	Name = "Howling Moonstone",
	TowerName = "Eclipse",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	ApplySkin = function(instance)
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		instance.RootPart["root.x"]:Destroy()
		clone.RootPart["root.x"].Parent = instance.RootPart
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		local transformBlinkTexture = config:WaitForChild("TransformBlinkTexture")
		local transformHurtTexture = config:WaitForChild("TransformHurtTexture")
		local transformNormalTexture = config:WaitForChild("TransformNormalTexture")
		blinkTexture.Texture = "rbxassetid://70368848884343"
		hurtTexture.Texture = "rbxassetid://108744971281791"
		normalTexture.Texture = "rbxassetid://131555929989578"
		transformBlinkTexture.Texture = "rbxassetid://70368848884343"
		transformHurtTexture.Texture = "rbxassetid://108744971281791"
		transformNormalTexture.Texture = "rbxassetid://106538004133545"
		local animations = instance:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {
			ParticlePart = "Head"
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

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}