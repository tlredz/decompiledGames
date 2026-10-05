return {
	Name = "Snow-Time Bobette",
	ApplySkin = function(instance)
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://99943181332472"
		hurtTexture.Texture = "rbxassetid://76839654606099"
		normalTexture.Texture = "rbxassetid://105052389256905"
		local present = instance:WaitForChild("Present")
		local v = present:waitForChild("Box")
		local waitForChild = present:waitForChild("Bow")
		waitForChild.Color = Color3.fromRGB(110, 82, 205)
		v.Color = Color3.fromRGB(215, 219, 224)
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		instance.RootPart.root:Destroy()
		clone.RootPart.root.Parent = instance.RootPart
		local animations = instance:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v2 = {
			Dress_Details = "Torso",
			Dress_Main = "Torso"
		}

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

		local snowtimeTrail = clone.PrimaryPart:WaitForChild("SnowtimeTrail")
		snowtimeTrail.Parent = instance.PrimaryPart

		for _, child in pairs(clone.HumanoidRootPart:GetChildren()) do
			if child.Name ~= "ParticleThing" then
				child.Parent = instance.HumanoidRootPart
			end
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}