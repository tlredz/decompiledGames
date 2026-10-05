return {
	Name = "Bowful Beauty",
	Cost = 600,
	DandyStore = true,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if not part:IsA("MeshPart") then
				continue
			end

			part.TextureID = "rbxassetid://137219373208242"
			part.Transparency = 1
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://72496495320498"
		local normalTexture = config:WaitForChild("NormalTexture")
		normalTexture.Texture = "rbxassetid://137219373208242"
		local blinkTexture = config:WaitForChild("BlinkTexture")
		blinkTexture.Texture = "rbxassetid://121744736938360"
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
			Goggles = "Head",
			BowCenter = "Head",
			BowLeft = "Head",
			BowRight = "Head",
			PonyTail = "Head",
			PonyTailHighlight = "Head",
			HeadHighlight = "Head",
			LeftArmHighlight = "LeftArm",
			RightArmHighlight = "RightArm",
			Gem1 = "Torso",
			Gem2 = "Torso",
			Gem3 = "Torso",
			Gem4 = "Torso",
			Gem5 = "Torso",
			Gem6 = "Torso",
			Gem7 = "Torso",
			Gem8 = "Torso"
		}

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local child = folder:FindFirstChild(v[part.Name] or part.Name)

			if child then
				local weld = Instance.new("Weld")
				part.Parent = child
				weld.Parent = part
				weld.Part0 = part
				weld.Part1 = child
				part.Anchored = false
				child.Transparency = 1
			else
				warn("Target part not found for: " .. part.Name .. ", skipping...")
			end
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}