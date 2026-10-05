local createVector = vector.create
local SwimmyFinn = {
	Name = "Swimmy Finn"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
SwimmyFinn.OverwriteAnimations = {
	Idle = "rbxassetid://102148951128189",
	Quirk = "rbxassetid://98653242934533",
	Run = "rbxassetid://130874516840041",
	Decode = "rbxassetid://106205750895773",
	Walk = "rbxassetid://111829905909442"
}
SwimmyFinn.FaceTextures = {
	Normal = "rbxassetid://103982035642949",
	Hurt = "rbxassetid://73591468600574",
	Blink = "rbxassetid://110051458469352"
}
SwimmyFinn.USE_SKIN_MODEL = true
SwimmyFinn.BarnabyTexture = "rbxassetid://77702075903877"

function SwimmyFinn.ApplySkin(instance)
	local barnaby_Geo = instance:WaitForChild("Barnaby_Geo")
	barnaby_Geo.TextureID = SwimmyFinn.BarnabyTexture
	local head = instance:FindFirstChild("Head")
	local particle = head and head:FindFirstChild("Particle")
	local particleEmitter = particle and particle:FindFirstChild("ParticleEmitter")

	if particleEmitter then
		particleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(82, 130, 88)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(82, 130, 88))
		})
		particle.CFrame = CFrame.new(0, 0.481, 0.751)
	end
end

function SwimmyFinn.UseAbility(instance, p, p2, _)
	local v = p2.Size.Y / 2 + p.HipHeight
	local parts = ReplicatedStorage:WaitForChild("Parts")
	local clone = parts.FinnIchorSplash.IchorSplash:Clone()
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Color = Color3.fromRGB(82, 130, 88)
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
	local clone2 = parts.FinnIchorSplash.IchorSplash:Clone()
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

return SwimmyFinn