local createVector = vector.create
local GoldenFishbowl = {
	Name = "Golden Fishbowl",
	TowerName = "Finn"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
GoldenFishbowl.OverwriteAnimations = {
	Idle = "rbxassetid://91263141219543",
	Quirk = "rbxassetid://92008024926024",
	Decode = "rbxassetid://130797866883315",
	Run = "rbxassetid://114157374655247",
	Walk = "rbxassetid://118058960084910"
}
GoldenFishbowl.FaceTextures = {
	Normal = "rbxassetid://108943251547423",
	Hurt = "rbxassetid://78881134081034",
	Blink = "rbxassetid://100233513551315"
}
GoldenFishbowl.USE_SKIN_MODEL = true
GoldenFishbowl.BarnabyTexture = "rbxassetid://74919718073275"

function GoldenFishbowl.ApplySkin(instance)
	if GoldenFishbowl.BarnabyTexture then
		local barnaby_Geo = instance:WaitForChild("Barnaby_Geo")
		barnaby_Geo.TextureID = GoldenFishbowl.BarnabyTexture
	end

	local head = instance:FindFirstChild("Head")
	local particle = head and head:FindFirstChild("Particle")
	local particleEmitter = particle and particle:FindFirstChild("ParticleEmitter")

	if particleEmitter then
		particleEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 203, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 203, 255))
		})
		particle.CFrame = CFrame.new(0, 0.755, 0.951)
	end
end

function GoldenFishbowl.UseAbility(instance, p, p2, _)
	local v = p2.Size.Y / 2 + p.HipHeight
	local parts = ReplicatedStorage:WaitForChild("Parts")
	local clone = parts.FinnIchorSplash.IchorSplash:Clone()
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Color = Color3.fromRGB(139, 203, 255)
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
		Color = Color3.fromRGB(247, 226, 160)
	}):Play()
	local clone2 = parts.FinnIchorSplash.IchorSplash:Clone()
	local tweenInfo2 = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone2.Color = Color3.fromRGB(200, 220, 244)
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
		Color = Color3.fromRGB(247, 226, 160)
	}):Play()
end

return GoldenFishbowl