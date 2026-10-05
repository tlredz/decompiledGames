local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LostPrince = {}
LostPrince.Name = "Lost Prince"
LostPrince.TowerName = "Gourdy"
LostPrince.Description = "No description yet"
LostPrince.Mastery = false
LostPrince.Cost = 1200
LostPrince.Requirement1 = { "Halloween2025", 1200 }
LostPrince.Requirement2 = { "Coin", 1200 }
LostPrince.Halloween = true
LostPrince.HolidaySkin = true

function LostPrince.ApplySkin(instance)
	local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	local config = instance:WaitForChild("Config")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local normalTexture = config:WaitForChild("NormalTexture")
	blinkTexture.Texture = "rbxassetid://119059374472783"
	hurtTexture.Texture = "rbxassetid://84425683014979"
	normalTexture.Texture = "rbxassetid://74144162455123"
	instance.RootPart.root:Destroy()
	clone.RootPart.root.Parent = instance.RootPart
	local animations = instance:WaitForChild("Animations")

	for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
		local animation2 = animations:FindFirstChild(animation.Name)

		if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
			animation2.AnimationId = animation.AnimationId
		end
	end

	local v = {
		Taail = "Tail",
		Head = "Head_Geo",
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

function LostPrince.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local v = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
	local gourdyAOE = ReplicatedStorage.Parts:FindFirstChild("gourdyAOE")

	if not gourdyAOE then
		warn("gourdyAOE mesh not found in ReplicatedStorage.Parts")
		return
	end

	local clone = gourdyAOE:Clone()
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone.CanTouch = false
	clone.Color = Color3.fromRGB(124, 121, 118)
	clone.Transparency = 0.2
	clone:PivotTo((CFrame.new(humanoidRootPart.Position + Vector3.new(0, -v + 0.2, 0))))
	TweenService:Create(clone, TweenInfo.new(1.33, Enum.EasingStyle.Cubic), {
		Size = createVector(19.27, 0.25, 20.0785),
		Transparency = 1,
		CFrame = clone.CFrame * CFrame.Angles(0, -0.7853981633974483, 0)
	}):Play()
	Debris:AddItem(clone, 3)
end

return LostPrince