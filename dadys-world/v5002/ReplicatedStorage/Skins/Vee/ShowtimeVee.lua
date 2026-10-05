return {
	Name = "Show-Time Vee",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://106448416543653"
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://90112425374978"
		local normalTexture = config:WaitForChild("NormalTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		normalTexture.Texture = "rbxassetid://106448416543653"
		blinkTexture.Texture = "rbxassetid://72292209716999"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			if part.Name == "Shoes_String_L" then
				part.Parent = folder
			elseif part.Name == "Shoes_String_R" then
				part.Parent = folder
			else
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

		folder.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(207, 207, 168)
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}