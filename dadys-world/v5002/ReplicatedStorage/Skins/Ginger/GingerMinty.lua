return {
	Name = "Ginger Mint",
	HolidaySkin = true,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://123154138265098"
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://121709096963303"
		local normalTexture = config:WaitForChild("NormalTexture")
		normalTexture.Texture = "rbxassetid://123154138265098"
		local blinkTexture = config:WaitForChild("BlinkTexture")
		blinkTexture.Texture = "rbxassetid://133889872440839"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
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

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}