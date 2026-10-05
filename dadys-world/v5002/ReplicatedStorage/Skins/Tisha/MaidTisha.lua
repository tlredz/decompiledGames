local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local MaidTisha = {}
MaidTisha.Name = "Lavender Maid"

function MaidTisha.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = "rbxassetid://87295821417072"
		end
	end

	local config = folder:WaitForChild("Config")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local normalTexture = config:WaitForChild("NormalTexture")
	blinkTexture.Texture = "rbxassetid://131210630821124"
	hurtTexture.Texture = "rbxassetid://126270218570116"
	normalTexture.Texture = "rbxassetid://87295821417072"
	local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	folder.RootPart.root_jnt:Destroy()
	clone.RootPart.root_jnt.Parent = folder.RootPart
	local animations = folder:WaitForChild("Animations")

	for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
		local animation2 = animations:FindFirstChild(animation.Name)

		if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
			animation2.AnimationId = animation.AnimationId
		end
	end

	local v = {}

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		local weld = Instance.new("Weld")
		local child = folder:WaitForChild(v[part.Name] or part.Name)
		part.Parent = child
		weld.Parent = part
		weld.Part0 = part
		weld.Part1 = child
		part.Anchored = false
		child.Transparency = 1
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 10)
end

function MaidTisha.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	instance:WaitForChild("Config"):WaitForChild("ModuleName")
	local v = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
	local clone = ReplicatedStorage.Parts.TishaPoof:Clone()
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.Color = Color3.fromRGB(109, 109, 165)
	clone.CastShadow = false
	clone.CanTouch = false
	clone.Size = createVector(0, 0.25, 0)
	clone.Position = instance.PrimaryPart.Position + Vector3.new(0, -v, 0)
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(60, 0.25, 60),
		Transparency = 1,
		Rotation = createVector(0, 2.740167, 0)
	}):Play()
end

return MaidTisha