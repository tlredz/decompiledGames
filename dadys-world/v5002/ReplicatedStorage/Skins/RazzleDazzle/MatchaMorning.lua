return {
	Name = "Matcha Morning",
	Cost = 600,
	DandyStore = true,
	SortingOverride = "RazzleDazzle",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://85626871468269"
			end
		end

		local config = folder:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://138792724073593"
		hurtTexture.Texture = "rbxassetid://126930089906873"
		normalTexture.Texture = "rbxassetid://85626871468269"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local v = {
			RightLeg = "RightUpperLeg",
			RightArm = "RightUpperArm",
			LeftLeg = "LeftUpperLeg",
			LeftArm = "LeftUpperArm"
		}

		for _, part in pairs(folder:GetChildren()) do
			if part:IsA("MeshPart") then
				part.Transparency = 1
			end
		end

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
		end

		folder.RootPart.root:Destroy()
		clone.RootPart.root.Parent = folder.RootPart
		folder.Animate.Enabled = false
		folder.Animate.Enabled = true
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}