local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VintageAstro = {}
VintageAstro.Name = "Vintage Astro"
VintageAstro.Mastery = true

function VintageAstro.ApplySkin(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			if descendant.Material == Enum.Material.Neon then
				descendant.Color = Color3.fromRGB(255, 255, 255)
			else
				descendant.TextureID = "rbxassetid://117409621761842"
			end
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
			})
		end
	end

	local config = folder:WaitForChild("Config")
	local hurtTexture = config:WaitForChild("HurtTexture")
	hurtTexture.Texture = "rbxassetid://133785042187726"
	local normalTexture = config:WaitForChild("NormalTexture")
	normalTexture.Texture = "rbxassetid://117409621761842"
	local blinkTexture = config:FindFirstChild("BlinkTexture")

	if blinkTexture then
		blinkTexture.Texture = "rbxassetid://105037340494589"
	end

	if folder.HumanoidRootPart:FindFirstChild("ToonLight") then
		folder.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(255, 255, 255)
	end
end

function VintageAstro.UseAbility(instance)
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
	clone.Color = Color3.fromRGB(255, 255, 255)
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

return VintageAstro