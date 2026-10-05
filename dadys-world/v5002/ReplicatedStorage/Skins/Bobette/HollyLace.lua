return {
	Name = "Holly Lace",
	TowerName = "Bobette",
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
		blinkTexture.Texture = "rbxassetid://124750157555888"
		hurtTexture.Texture = "rbxassetid://115485626561630"
		normalTexture.Texture = "rbxassetid://95640390912394"
		local present = instance:WaitForChild("Present")
		local v = present:waitForChild("Box")
		local waitForChild = present:waitForChild("Bow")
		waitForChild.Color = Color3.fromRGB(139, 169, 85)
		v.Color = Color3.fromRGB(138, 35, 69)
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

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}