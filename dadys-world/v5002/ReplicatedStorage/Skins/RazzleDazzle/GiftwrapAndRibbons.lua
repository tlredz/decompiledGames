local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Giftwrap and Ribbons",
	TowerName = "RazzleDazzle",
	Description = "No description yet",
	Mastery = false,
	Cost = 1200,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W3,
	Requirement1 = { "Christmas2025Ornaments", 1200 },
	Requirement2 = { "Coin", 1200 },
	Christmas = true,
	HolidaySkin = true,
	ApplySkin = function(instance)
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://104925666503045"
		hurtTexture.Texture = "rbxassetid://71066225221141"
		normalTexture.Texture = "rbxassetid://89809741236697"
		local v = {
			RightLeg = "RightUpperLeg",
			RightArm = "RightUpperArm",
			LeftLeg = "LeftUpperLeg",
			LeftArm = "LeftUpperArm"
		}

		for _, part in pairs(instance:GetChildren()) do
			if part:IsA("MeshPart") then
				part.Transparency = 1
			end
		end

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

		instance.RootPart.root:Destroy()
		clone.RootPart.root.Parent = instance.RootPart
		instance.Animate.Enabled = false
		instance.Animate.Enabled = true

		for _, child in pairs(clone.HumanoidRootPart:GetChildren()) do
			child.Parent = instance.HumanoidRootPart
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}