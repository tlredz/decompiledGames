return {
	Name = "Antique Shade",
	ApplySkin = function(folder)
		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("MeshPart") then
				if descendant.Material == Enum.Material.Neon then
					descendant.Color = Color3.fromRGB(176, 176, 176)
				else
					descendant.TextureID = "rbxassetid://121772839986539"
				end
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
				})
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://130408247901556"
		local normalTexture = config:WaitForChild("NormalTexture")
		normalTexture.Texture = "rbxassetid://121772839986539"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()

		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 1
			end
		end

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			for _, part2 in pairs(part:GetChildren()) do
				if not part2:IsA("MeshPart") then
					continue
				end

				local weld = Instance.new("Weld")
				part.Parent = folder:WaitForChild(part.Name)
				weld.Parent = part
				weld.Part0 = part
				weld.Part1 = folder:WaitForChild(part.Name)
				part.Anchored = false
				local waitForChild = folder:WaitForChild(part.Name)
				waitForChild.Transparency = 1
			end
		end
	end
}