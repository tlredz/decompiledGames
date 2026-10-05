local createVector = vector.create
local ReefExplorer = {
	Name = "Reef Explorer",
	TowerName = "Finn"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
ReefExplorer.OverwriteAnimations = {
	Decode = "rbxassetid://131360393559194",
	Idle = "rbxassetid://138486155047743",
	Quirk = "rbxassetid://111804822003433",
	Run = "rbxassetid://111692320509573",
	Walk = "rbxassetid://86506904957502"
}
ReefExplorer.FaceTextures = {
	Normal = "rbxassetid://79182467153609",
	Hurt = "rbxassetid://139064259477887",
	Blink = "rbxassetid://116264218167882"
}
ReefExplorer.USE_SKIN_MODEL = true
ReefExplorer.BarnabyTexture = "rbxassetid://103907100263068"

function ReefExplorer.ApplySkin(instance)
	if ReefExplorer.BarnabyTexture then
		local barnaby_Geo = instance:WaitForChild("Barnaby_Geo")
		barnaby_Geo.TextureID = ReefExplorer.BarnabyTexture
	end

	local head = instance:FindFirstChild("Head")
	local particle = head and head:FindFirstChild("Particle")
	local particleEmitter = particle and particle:FindFirstChild("ParticleEmitter")

	if particleEmitter then
		particleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(78, 166, 185)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(187, 240, 251))
		})
		particle.CFrame = CFrame.new(0, 0.8, 0.951)
	end
end

function ReefExplorer.UseAbility(instance, p, p2, _)
	local v = p2.Size.Y / 2 + p.HipHeight
	local parts = ReplicatedStorage:WaitForChild("Parts")
	local clone = parts.FinnIchorSplash.IchorSplash:Clone()
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Color = Color3.fromRGB(78, 166, 185)
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
		Color = Color3.fromRGB(150, 205, 210)
	}):Play()
	local clone2 = parts.FinnIchorSplash.IchorSplash:Clone()
	local tweenInfo2 = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone2.Color = Color3.fromRGB(180, 210, 212)
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
		Color = Color3.fromRGB(150, 205, 210)
	}):Play()
end

return ReefExplorer