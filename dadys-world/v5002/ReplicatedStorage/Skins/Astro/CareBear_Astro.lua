local createVector = vector.create
local CareBearAstro = {}
CareBearAstro.Name = "Bedtime Bear"
CareBearAstro.RobuxCost = script:GetAttribute("RobuxCost") or -1
CareBearAstro.ProductId = 3367099746

function CareBearAstro.ApplySkin(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			if descendant.Material == Enum.Material.Neon then
				descendant.Color = Color3.fromRGB(255, 192, 203)
			else
				descendant.TextureID = "rbxassetid://123395769799853"
			end
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 192, 203)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 192, 203))
			})
		end
	end

	local config = folder:WaitForChild("Config")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	hurtTexture.Texture = "rbxassetid://111735939065160"
	blinkTexture.Texture = "rbxassetid://70642054131996"
	local normalTexture = config:WaitForChild("NormalTexture")
	normalTexture.Texture = "rbxassetid://123395769799853"
	local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	local v = {
		HatGeo = "HatGeo",
		Hat = "Head",
		Cap = "Head",
		Helmet = "Head",
		Hair = "Head",
		Crown = "Head",
		Headband = "Head",
		Headwear = "Head",
		StarBigGeo = "StarBigGeo",
		StarSmallGeo = "StarSmallGeo",
		Star = "Torso",
		StarBig = "Torso",
		StarSmall = "Torso",
		LeftArmSleeve = "LeftArm",
		RightArmSleeve = "RightArm",
		LeftLegSleeve = "LeftLeg",
		RightLegSleeve = "RightLeg",
		TorsoArmor = "Torso",
		Chest = "Torso",
		Body = "Torso"
	}
	local v2 = {}

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		local v3 = v[part.Name] or part.Name
		local child = folder:WaitForChild(v3)
		local weld = Instance.new("Weld")
		part.Parent = child
		weld.Parent = part
		weld.Part0 = part
		weld.Part1 = child
		part.Anchored = false

		if not v2[v3] then
			child.Transparency = 1
		end
	end

	folder.RootPart["root.x"]:Destroy()
	clone.RootPart["root.x"].Parent = folder.RootPart
	folder.Animate.Enabled = false
	folder.Animate.Enabled = true

	if folder.HumanoidRootPart:FindFirstChild("ToonLight") then
		folder.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(81, 140, 165)
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 10)
end

function CareBearAstro.UseAbility(instance)
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local TweenService = game:GetService("TweenService")
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	instance:WaitForChild("Config"):WaitForChild("ModuleName")
	local v = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
	local clone = ReplicatedStorage.Parts.CrescentMoonStarPoof:Clone()
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone.CanTouch = false
	clone.Size = createVector(0, 0.25, 0)
	clone.Position = instance.PrimaryPart.Position + Vector3.new(0, -v, 0)
	local _, v2, _ = instance.PrimaryPart.CFrame:ToOrientation()
	clone.CFrame = CFrame.new(clone.Position) * CFrame.Angles(0, v2 + 3.141592653589793, 0)
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(60, 0.25, 60),
		Transparency = 1
	}):Play()
end

return CareBearAstro