local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local AstroStar = {}
AstroStar.Name = "Starry Night"

function AstroStar.ApplySkin(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			if descendant.Material == Enum.Material.Neon then
				descendant.Color = Color3.fromRGB(255, 207, 123)
			else
				descendant.TextureID = "rbxassetid://71647795710115"
			end
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 207, 123)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 207, 123))
			})
		end
	end

	local config = folder:WaitForChild("Config")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	hurtTexture.Texture = "rbxassetid://90405702447868"
	blinkTexture.Texture = "rbxassetid://83716440516398"
	local normalTexture = config:WaitForChild("NormalTexture")
	normalTexture.Texture = "rbxassetid://71647795710115"
	local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	local _ = {
		Hat = "Head",
		Hat_Geo = "HatGeo",
		Cap = "Head",
		Helmet = "Head",
		Hair = "Head",
		Crown = "Head",
		Headband = "Head",
		Headwear = "Head"
	}
	local _ = {
		Hat = true,
		Hat_Geo = true,
		Cap = true,
		Helmet = true,
		Hair = true,
		Crown = true,
		Headband = true,
		Headwear = true
	}

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

	folder.RootPart["root.x"]:Destroy()
	clone.RootPart["root.x"].Parent = folder.RootPart
	folder.Animate.Enabled = false
	folder.Animate.Enabled = true
	local children = clone.Animations:GetChildren()

	for _, v in pairs(children) do
		folder.Animations[tostring(v)].AnimationId = v.AnimationId
	end

	folder.Animate.Enabled = false
	folder.Animate.Enabled = true

	if folder.HumanoidRootPart:FindFirstChild("ToonLight") then
		folder.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(255, 207, 123)
	end
end

function AstroStar.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	instance:WaitForChild("Config"):WaitForChild("ModuleName")
	local v = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
	local clone = ReplicatedStorage.Parts.AstroPoof:Clone()
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
	clone.Color = Color3.fromRGB(255, 207, 123)
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(60, 0.25, 60),
		Transparency = 1,
		Rotation = createVector(0, 2.740167, 0)
	}):Play()
end

return AstroStar