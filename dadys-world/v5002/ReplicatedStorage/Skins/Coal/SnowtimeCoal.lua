return {
	Name = "Snow-Time Coal",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://120628320629905"
			end
		end

		local config = folder:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://138185397222306"
		hurtTexture.Texture = "rbxassetid://110813636281174"
		normalTexture.Texture = "rbxassetid://120628320629905"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		folder.RootPart.root:Destroy()
		clone.RootPart.root.Parent = folder.RootPart
		local animations = folder:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {
			MainBody_Details = "MainBody"
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

		for _, emitter in pairs(clone.HumanoidRootPart:GetChildren()) do
			if emitter:IsA("ParticleEmitter") and emitter.Name ~= "ParticleThing" then
				emitter.Parent = folder.HumanoidRootPart
			end
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}