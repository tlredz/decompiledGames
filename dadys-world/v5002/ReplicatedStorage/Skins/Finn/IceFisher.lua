local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local IceFisher = {}
IceFisher.Name = "Ice Fisher"
IceFisher.TowerName = "Finn"
IceFisher.Description = "No description yet"
IceFisher.Mastery = false
IceFisher.Cost = 1200
IceFisher.Unlocks = require(ReplicatedStorage2.SharedData.ReleaseTimes).Christmas2025_W4
IceFisher.Requirement1 = { "Christmas2025Ornaments", 1200 }
IceFisher.Requirement2 = { "Coin", 1200 }
IceFisher.Christmas = true
IceFisher.HolidaySkin = true

function IceFisher.ApplySkin(instance)
	local barnaby_Geo = instance:WaitForChild("Barnaby_Geo")
	barnaby_Geo.TextureID = "rbxassetid://76574716777201"
	local config = instance:WaitForChild("Config")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local normalTexture = config:WaitForChild("NormalTexture")
	blinkTexture.Texture = "rbxassetid://100365975594665"
	hurtTexture.Texture = "rbxassetid://119749527507053"
	normalTexture.Texture = "rbxassetid://79319881245868"
	local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
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
		FishingRod_Geo = "Torso",
		ParticlePart = "Torso"
	}

	for _, part in pairs(clone:GetChildren()) do
		if not (part:IsA("MeshPart") or v[part.Name]) then
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

	local particleAttachment = clone.RootPart:WaitForChild("ParticleAttachment")
	particleAttachment.Parent = instance.RootPart
	local Debris2 = game:GetService("Debris")
	Debris2:AddItem(clone, 10)
end

function IceFisher.UseAbility(instance, p, p2, _)
	local v = p2.Size.Y / 2 + p.HipHeight
	local clone = script.IchorSplash:Clone()
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Color = Color3.fromRGB(84, 141, 154)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone.CanTouch = false
	clone.Size = createVector(0, 0.25, 0)
	clone.Position = instance.PrimaryPart.Position + Vector3.new(0, -v + 0.125, 0)
	Audio:Play("Sounds.Toon.Finn.Ability", {
		Parent = clone
	})
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(20, 0.25, 20),
		Transparency = 1,
		CFrame = clone.CFrame * CFrame.new(0, 0.25, 0) * CFrame.Angles(0, 2.7401669256310974, 0),
		Color = Color3.fromRGB(172, 172, 172)
	}):Play()
	local clone2 = script.IchorSplash:Clone()
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo2 = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone2.Color = Color3.fromRGB(180, 180, 180)
	clone2.Parent = workspace
	clone2.Anchored = true
	clone2.CanCollide = false
	clone2.CanQuery = false
	clone2.CastShadow = false
	clone2.CanTouch = false
	clone2.Size = createVector(0, 0.25, 0)
	clone2.Position = instance.PrimaryPart.Position + Vector3.new(0, -v, 0)
	Debris:AddItem(clone2, 5)
	TweenService:Create(clone2, tweenInfo2, {
		Size = createVector(12, 0.25, 12),
		Transparency = 1,
		CFrame = clone2.CFrame * CFrame.new(0, 0.25, 0) * CFrame.Angles(0, 2.7401669256310974, 0),
		Color = Color3.fromRGB(172, 172, 172)
	}):Play()
end

return IceFisher