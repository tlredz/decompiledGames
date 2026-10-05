return {
	Name = "Sapphire Dots",
	Cost = 600,
	DandyStore = true,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://87671622175595"
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://70999539315245"
		local normalTexture = config:WaitForChild("NormalTexture")
		normalTexture.Texture = "rbxassetid://87671622175595"
		local blinkTexture = config:WaitForChild("BlinkTexture")
		blinkTexture.Texture = "rbxassetid://134348944718040"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local v = {
			Hat = "Head",
			Cap = "Head",
			Helmet = "Head",
			Hair = "Head",
			Crown = "Head",
			Headband = "Head",
			Headwear = "Head",
			LeftArmSleeve = "LeftArm",
			RightArmSleeve = "RightArm",
			LeftSleeve = "LeftArm",
			RightSleeve = "RightArm",
			LArmSleeve = "LeftArm",
			RArmSleeve = "RightArm",
			LeftLegSleeve = "LeftLeg",
			RightLegSleeve = "RightLeg",
			LeftPant = "LeftLeg",
			RightPant = "RightLeg",
			LLegSleeve = "LeftLeg",
			RLegSleeve = "RightLeg",
			TorsoArmor = "Torso",
			Chest = "Torso",
			ChestPiece = "Torso",
			Body = "Torso",
			Shirt = "Torso",
			FaceMask = "Head",
			Mask = "Head",
			Visor = "Head",
			Glasses = "Head",
			Goggles = "Head"
		}
		local v2 = {
			Hat = true,
			Cap = true,
			Helmet = true,
			Hair = true,
			Crown = true,
			Headband = true,
			Headwear = true,
			FaceMask = true,
			Mask = true,
			Visor = true,
			Glasses = true,
			Goggles = true
		}

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local child = folder:WaitForChild(v[part.Name] or part.Name)
			local weld = Instance.new("Weld")
			part.Parent = child
			weld.Parent = part
			weld.Part0 = part
			weld.Part1 = child
			part.Anchored = false

			if not v2[part.Name] then
				child.Transparency = 1
			end
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}