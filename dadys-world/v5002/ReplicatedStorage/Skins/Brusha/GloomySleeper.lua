return {
	Name = "Gloomy Sleeper",
	Cost = 600,
	DandyStore = true,
	ApplySkin = function(folder)
		local CollectionService = game:GetService("CollectionService")
		folder:SetAttribute("PaintingTexture", "rbxassetid://73920383880337")

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("MeshPart") and CollectionService:HasTag(descendant, "SkinPart") then
				if descendant.Material == Enum.Material.Neon then
					descendant.Color = Color3.fromRGB(100, 100, 120)
				else
					descendant.TextureID = "rbxassetid://134398763923866"
				end
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 170)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
				})
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local blinkTexture = config:FindFirstChild("BlinkTexture")
		local normalTexture = config:FindFirstChild("NormalTexture")
		normalTexture.Texture = "rbxassetid://134398763923866"
		hurtTexture.Texture = "rbxassetid://85474521879426"

		if blinkTexture then
			blinkTexture.Texture = "rbxassetid://118249574491510"
		end

		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			if part.Name == "Hat" then
				local weld = Instance.new("Weld")
				part.Parent = folder:WaitForChild("Head")
				weld.Parent = part
				weld.Part0 = part
				weld.Part1 = folder:WaitForChild("Head")
				part.Anchored = false
			else
				local child = folder:WaitForChild(part.Name)
				CollectionService:RemoveTag(child, "SkinPart")
				local weld = Instance.new("Weld")
				part.Parent = child
				weld.Parent = part
				weld.Part0 = part
				weld.Part1 = child
				part.Anchored = false
				child.Transparency = 1
			end
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}