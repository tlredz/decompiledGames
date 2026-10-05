return {
	Name = "Autumn Palette",
	Cost = 600,
	DandyStore = true,
	ApplySkin = function(folder)
		local CollectionService = game:GetService("CollectionService")
		folder:SetAttribute("PaintingTexture", "rbxassetid://95523592318284")

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("MeshPart") and CollectionService:HasTag(descendant, "SkinPart") then
				if descendant.Material == Enum.Material.Neon then
					descendant.Color = Color3.fromRGB(85, 124, 99)
				else
					descendant.TextureID = "rbxassetid://90365248794114"
				end
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 124, 99)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 124, 99))
				})
			end
		end

		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local config = folder:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://109316879033709"
		hurtTexture.Texture = "rbxassetid://109680573399689"
		normalTexture.Texture = "rbxassetid://139495609427032"
		local v = {
			Head = "Head_Geo"
		}

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local weld = Instance.new("Weld")
			local child = folder:WaitForChild(v[part.Name] or part.Name)
			local decal = child:FindFirstChild("Decal")

			if decal then
				decal.Parent = part
			end

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