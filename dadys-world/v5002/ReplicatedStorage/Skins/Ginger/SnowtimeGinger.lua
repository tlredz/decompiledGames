return {
	Name = "Snow-Time Ginger",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://121631179489237"
			end
		end

		local config = folder:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://90572827966658"
		hurtTexture.Texture = "rbxassetid://106081404492522"
		normalTexture.Texture = "rbxassetid://121631179489237"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		folder.RootPart.root:Destroy()
		local root = clone.RootPart.root
		root.Parent = folder.RootPart
		local animations = folder:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {
			Dress_Details = "Torso",
			Dress_Main = "Torso",
			LeftLowerArm_Fluff = "LeftLowerArm",
			LeftLowerArm_Main = "LeftLowerArm",
			RightLowerArm_Fluff = "RightLowerArm",
			RightLowerArm_Main = "RightLowerArm",
			LeftLowerLeg = "LeftUpperLeg2",
			LeftUpperLeg = "LeftUpperLeg3"
		}

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local weld = Instance.new("Weld")
			local child = folder:WaitForChild(v[part.Name] or part.Name)
			part.Parent = child
			weld.Parent = part
			weld.Part0 = part
			weld.Part1 = child
			part.Anchored = false
			child.Transparency = 1
		end

		local snowtimeTrail = clone.PrimaryPart:WaitForChild("SnowtimeTrail")
		snowtimeTrail.Parent = folder.PrimaryPart
		task.spawn(function()
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")
			local nameTag = humanoidRootPart and humanoidRootPart:WaitForChild("NameTag", 5)

			if not nameTag then
				return
			end

			local bubbleChat = folder.Head:FindFirstChild("BubbleChat")
			local nameTagOverride = bubbleChat and bubbleChat:FindFirstChild("NameTagOverride")
			local nameTagOverridePosition = root:FindFirstChild("NameTagOverridePosition", true)

			if nameTagOverride and nameTagOverridePosition then
				nameTagOverride.Value = nameTagOverridePosition
				nameTag.Adornee = nameTagOverridePosition
			end
		end)

		for _, emitter in pairs(clone.HumanoidRootPart:GetChildren()) do
			if emitter:IsA("ParticleEmitter") and emitter.Name ~= "ParticleThing" then
				emitter.Parent = folder.HumanoidRootPart
			end
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}