return {
	Name = "Hot Chocolate",
	TowerName = "Bobette",
	Description = "No description yet",
	Mastery = false,
	ApplySkin = function(instance)
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://124423295241012"
		hurtTexture.Texture = "rbxassetid://133727957986519"
		normalTexture.Texture = "rbxassetid://113038681594709"
		local present = instance:WaitForChild("Present")
		local v = present:waitForChild("Box")
		local waitForChild = present:waitForChild("Bow")
		waitForChild.Color = Color3.fromRGB(240, 242, 245)
		v.Color = Color3.fromRGB(153, 108, 72)
		instance.RootPart.root:Destroy()
		clone.RootPart.root.Parent = instance.RootPart
		local animations = instance:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v2 = {}

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local weld = Instance.new("Weld")
			local child = instance:WaitForChild(v2[part.Name] or part.Name)
			part.Parent = child
			weld.Parent = part
			weld.Part0 = part
			weld.Part1 = child
			part.Anchored = false
			child.Transparency = 1
		end

		local particleAttachment = clone.RootPart.ParticleAttachment
		particleAttachment.Parent = instance.RootPart
		local particlePart = clone.HumanoidRootPart.ParticlePart
		particlePart.Parent = instance.HumanoidRootPart
		particlePart.RigidConstraint.Attachment1 = particleAttachment
		particlePart.CFrame = instance.HumanoidRootPart.CFrame
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}