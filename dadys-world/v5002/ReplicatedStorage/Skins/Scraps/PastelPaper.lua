local PastelPaper = {}
PastelPaper.Name = "Pastel Paper"

function PastelPaper.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = "rbxassetid://131131876870265"
		end
	end

	local config = folder:WaitForChild("Config")
	local hurtTexture = config:WaitForChild("HurtTexture")
	hurtTexture.Texture = "rbxassetid://84249013849465"
	local normalTexture = config:WaitForChild("NormalTexture")
	normalTexture.Texture = "rbxassetid://131131876870265"
	local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()

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

function PastelPaper.UseAbility(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			descendant.Transparency = 1
		elseif descendant:IsA("RopeConstraint") then
			descendant.Color = BrickColor.new("Lily white")
		end
	end

	local clone = script.Base:Clone()
	clone.Name = "GoobSkin"
	clone.Parent = folder.PrimaryPart
	clone.CFrame = folder.PrimaryPart.CFrame
	clone.Anchored = false
	local weld = Instance.new("Weld")
	weld.Parent = clone
	weld.Part0 = clone
	weld.Part1 = folder.PrimaryPart
end

return PastelPaper