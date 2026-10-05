local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local NorthStar = {}
NorthStar.Name = "North Star"
NorthStar.TowerName = "Astro"
NorthStar.Description = "No description yet"
NorthStar.Mastery = false
NorthStar.Cost = 600
NorthStar.Unlocks = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0)
NorthStar.Christmas = true
NorthStar.HolidaySkin = true

function NorthStar.ApplySkin(instance)
	local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	local config = instance:WaitForChild("Config")
	local normalTexture = config:WaitForChild("NormalTexture")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	blinkTexture.Texture = "rbxassetid://110103961049129"
	hurtTexture.Texture = "rbxassetid://86316420625696"
	normalTexture.Texture = "rbxassetid://106373897802967"
	instance.RootPart["root.x"]:Destroy()
	clone.RootPart["root.x"].Parent = instance.RootPart
	local animations = instance:WaitForChild("Animations")

	for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
		local animation2 = animations:FindFirstChild(animation.Name)

		if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
			animation2.AnimationId = animation.AnimationId
		end
	end

	local v = {
		ScarfGeo = "Torso"
	}

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		local weld = Instance.new("Weld")
		local child = instance:WaitForChild(v[part.Name] or part.Name)
		part.Parent = child
		weld.Parent = part
		weld.Part0 = part
		weld.Part1 = child
		part.Anchored = false
		child.Transparency = 1
	end

	instance.Animate.Enabled = false
	instance.Animate.Enabled = true

	if instance.HumanoidRootPart:FindFirstChild("ToonLight") then
		instance.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(165, 200, 231)
	end

	local Debris2 = game:GetService("Debris")
	Debris2:AddItem(clone, 10)
end

function NorthStar.UseAbility(instance)
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
	clone.Color = Color3.fromRGB(165, 200, 231)
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(60, 0.25, 60),
		Transparency = 1,
		Rotation = createVector(0, 2.740167, 0)
	}):Play()
end

return NorthStar