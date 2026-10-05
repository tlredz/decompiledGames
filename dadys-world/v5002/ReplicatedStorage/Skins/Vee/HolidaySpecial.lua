return {
	Name = "Holiday Special",
	TowerName = "Vee",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0),
	Christmas = true,
	HolidaySkin = true,
	ApplySkin = function(instance)
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://86595457734291"
		hurtTexture.Texture = "rbxassetid://93638698188647"
		normalTexture.Texture = "rbxassetid://81841752761425"
		local rigidConstraint = instance:WaitForChild("Head"):WaitForChild("StaticScreen"):WaitForChild("RigidConstraint")
		rigidConstraint.Attachment0 = nil
		instance.RootPart.root:Destroy()
		local root = clone.RootPart.root
		root.Parent = instance.RootPart
		rigidConstraint.Attachment0 = root:WaitForChild("torso"):WaitForChild("chest"):WaitForChild("head"):WaitForChild("HeadBoneAttachment")
		local animations = instance:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {
			Light_01 = "Head",
			Light_02 = "Head"
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