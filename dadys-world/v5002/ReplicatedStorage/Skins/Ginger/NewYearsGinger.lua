return {
	Name = "New Years Ginger",
	TowerName = "Ginger",
	Description = "No description yet",
	Mastery = false,
	ApplySkin = function(instance)
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://95051763902744"
		hurtTexture.Texture = "rbxassetid://108219247253648"
		normalTexture.Texture = "rbxassetid://118330145591412"
		instance.RootPart.root:Destroy()
		local root = clone.RootPart.root
		root.Parent = instance.RootPart
		local animations = instance:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {
			LeftLowerLeg = "LeftUpperLeg2",
			LeftUpperLeg = "LeftUpperLeg3"
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

		task.spawn(function()
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			local nameTag = humanoidRootPart and humanoidRootPart:WaitForChild("NameTag", 5)

			if not nameTag then
				return
			end

			local bubbleChat = instance.Head:FindFirstChild("BubbleChat")
			local nameTagOverride = bubbleChat and bubbleChat:FindFirstChild("NameTagOverride")
			local nameTagOverridePosition = root:FindFirstChild("NameTagOverridePosition", true)

			if nameTagOverride and nameTagOverridePosition then
				nameTagOverride.Value = nameTagOverridePosition
				nameTag.Adornee = nameTagOverridePosition
			end
		end)

		for _, child in pairs(clone.HumanoidRootPart:GetChildren()) do
			child.Parent = instance.HumanoidRootPart
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}