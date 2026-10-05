return {
	Name = "Golden Antlers",
	TowerName = "Rudie",
	Description = "No description yet",
	Mastery = false,
	ApplySkin = function(instance)
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://105852569646094"
		hurtTexture.Texture = "rbxassetid://104877823518213"
		normalTexture.Texture = "rbxassetid://134366444252148"
		instance.RootPart.root:Destroy()
		local root = clone.RootPart.root
		root.Parent = instance.RootPart
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")

		for _, light in pairs(humanoidRootPart:GetDescendants()) do
			if light:IsA("PointLight") or light:IsA("SpotLight") then
				light.Color = Color3.fromRGB(213, 39, 37)
			end
		end

		local nose = clone:WaitForChild("Nose", 5)

		if nose then
			local lights = {}

			for _, light in pairs(nose:GetDescendants()) do
				if not (light:IsA("PointLight") or light:IsA("SpotLight")) then
					continue
				end

				light.Color = Color3.fromRGB(213, 39, 37)
				lights[#lights + 1] = light
			end

			local attachment = nose:WaitForChild("Attachment", 3)
			local torso = root and root:FindFirstChild("torso")
			local chest = torso and torso:FindFirstChild("chest")
			local head = chest and chest:FindFirstChild("head")

			if attachment and head then
				attachment.CFrame = CFrame.new(-1, -1.7, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
				attachment.Parent = head
			else
				for _, v in pairs(lights) do
					v.Shadow = false
				end
			end
		else
			warn("[GoldenAntlers] Nose part not found - skipping nose customization")
		end

		local animations = instance:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {
			Nose = "Head"
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
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")
			local nameTag = humanoidRootPart2 and humanoidRootPart2:WaitForChild("NameTag", 5)

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