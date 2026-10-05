local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local TackySweater = {
	Name = "Tacky Sweater",
	TowerName = "Finn",
	Description = "No description yet",
	Mastery = false,
	Cost = 600
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
TackySweater.Unlocks = require(ReplicatedStorage2.SharedData.ReleaseTimes).Christmas2025_W3
TackySweater.Christmas = true
TackySweater.HolidaySkin = true
TackySweater.OverwriteAnimations = {
	Decode = "rbxassetid://74681552658005",
	Idle = "rbxassetid://116619987537832",
	Quirk = "rbxassetid://123357983272025",
	Run = "rbxassetid://137793536201511",
	Walk = "rbxassetid://105647809117847"
}
TackySweater.FaceTextures = {
	Blink = "rbxassetid://137599422148021",
	Hurt = "rbxassetid://116263783504497",
	Normal = "rbxassetid://120431234546660"
}
TackySweater.USE_SKIN_MODEL = true
TackySweater.BarnabyTexture = "rbxassetid://77972243628161"

function TackySweater.ApplySkin(instance)
	local barnaby_Geo = instance:WaitForChild("Barnaby_Geo")
	barnaby_Geo.TextureID = TackySweater.BarnabyTexture
	instance.Head.Particle.ParticleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 180, 147)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 180, 147))
	})
end

function TackySweater.UseAbility(instance, p, p2, _)
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

return TackySweater