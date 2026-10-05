local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Bundled Up",
	TowerName = "Shrimpo",
	Description = "No description yet",
	Mastery = false,
	Cost = 1200,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W4,
	Requirement1 = { "Christmas2025Ornaments", 1200 },
	Requirement2 = { "Coin", 1200 },
	Christmas = true,
	HolidaySkin = true,
	ApplySkin = function(instance)
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://86286742644229"
		hurtTexture.Texture = "rbxassetid://118351716176197"
		normalTexture.Texture = "rbxassetid://72525026837353"
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		instance.RootPart["root.x"]:Destroy()
		clone.RootPart["root.x"].Parent = instance.RootPart
		local animations = instance:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {
			ParticlePart = "Torso"
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

		local particleAttachment = clone.RootPart:WaitForChild("ParticleAttachment")
		particleAttachment.Parent = instance.RootPart
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}