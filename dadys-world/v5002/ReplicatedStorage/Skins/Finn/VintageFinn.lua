local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local VintageFinn = {}
VintageFinn.Name = "Vintage Finn"

function VintageFinn.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = "rbxassetid://79208733066419"
		end
	end

	local barnaby_Geo = folder:WaitForChild("Barnaby_Geo")
	barnaby_Geo.TextureID = "rbxassetid://82442124258465"
	local config = folder:WaitForChild("Config")
	local normalTexture = config:WaitForChild("NormalTexture")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	blinkTexture.Texture = "rbxassetid://130682898537496"
	hurtTexture.Texture = "rbxassetid://83001351225478"
	normalTexture.Texture = "rbxassetid://79208733066419"
	folder.Head.Particle.ParticleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
	})
end

function VintageFinn.UseAbility(instance, p, p2, _)
	local v = p2.Size.Y / 2 + p.HipHeight
	local clone = script.IchorSplash:Clone()
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Color = Color3.fromRGB(0, 0, 0)
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

return VintageFinn