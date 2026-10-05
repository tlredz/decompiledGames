local createVector = vector.create
local FishFinn = {
	Name = "Prismatic Pal",
	Cost = 600,
	DandyStore = true
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
FishFinn.OverwriteAnimations = {
	Decode = "rbxassetid://136301232640482",
	Idle = "rbxassetid://124825166312410",
	Quirk = "rbxassetid://107628210399738",
	Run = "rbxassetid://74253224976998",
	Walk = "rbxassetid://114035408856324"
}
FishFinn.FaceTextures = {
	Blink = "rbxassetid://118876543128166",
	Hurt = "rbxassetid://111458205318155",
	Normal = "rbxassetid://88067670783845"
}
FishFinn.USE_SKIN_MODEL = true
FishFinn.BarnabyTexture = "rbxassetid://138613077704708"

function FishFinn.ApplySkin(instance)
	local barnaby_Geo = instance:WaitForChild("Barnaby_Geo")
	barnaby_Geo.TextureID = FishFinn.BarnabyTexture
	instance.Head.Particle.ParticleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(0.176471, 0.839216, 0.941176)),
		ColorSequenceKeypoint.new(1, Color3.new(0.176471, 0.839216, 0.941176))
	})
end

function FishFinn.UseAbility(instance, p, p2, _)
	local v = p2.Size.Y / 2 + p.HipHeight
	local parts = ReplicatedStorage:WaitForChild("Parts")
	local clone = parts.FinnIchorSplash.IchorSplash:Clone()
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

return FishFinn