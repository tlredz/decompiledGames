local CosmoBerry = {}
CosmoBerry.Name = "Berry Roll"
CosmoBerry.Cost = 600
CosmoBerry.DandyStore = true

function CosmoBerry.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = "rbxassetid://92753035262118"
		end
	end

	local config = folder:WaitForChild("Config")
	local hurtTexture = config:WaitForChild("HurtTexture")
	hurtTexture.Texture = "rbxassetid://107728926944726"
	local normalTexture = config:WaitForChild("NormalTexture")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	normalTexture.Texture = "rbxassetid://92753035262118"
	blinkTexture.Texture = "rbxassetid://132042366025547"
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

	folder.Cosmo["root.x"]:Destroy()
	clone.Cosmo["root.x"].Parent = folder.Cosmo
	folder.Animate.Enabled = false
	folder.Animate.Enabled = true
	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 10)
end

function CosmoBerry.UseAbility(_, _, p, p2)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Movement = require(ReplicatedStorage.Parts.RenderModules.CosmoCookie.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.CosmoCookie.Cookie:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position

	if clone:IsA("BasePart") then
		clone.Color = Color3.fromRGB(255, 102, 153)
	end

	if clone:FindFirstChild("Trail") then
		clone.Trail.Enabled = true
		clone.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 51, 102)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 153, 204))
		})
	end

	if clone:FindFirstChild("SmokePart") then
		clone.SmokePart.Enabled = true
		clone.SmokePart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 102, 153)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 204, 229))
		})
	end

	if clone:FindFirstChild("HeartPart") then
		clone.HeartPart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 51, 102)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 153, 204))
		})
	end

	local function chase()
		local position = clone.Position
		Movement.parabola(clone, position, p2, 20, 25, 0.5)
	end

	local position = clone.Position
	Movement.parabola(clone, position, p2, 20, 25, 0.5)

	if clone then
		clone.SmokePart.Enabled = false
		clone.Transparency = 1
		clone.HeartPart:Emit(10)

		if clone:FindFirstChild("Eat") then
			clone.Eat:Play()
		end
	end
end

return CosmoBerry