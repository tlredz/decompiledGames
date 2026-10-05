local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local FlowerBud = {}
FlowerBud.Name = "Loyal Bud"
FlowerBud.Cost = 600
FlowerBud.DandyStore = true
FlowerBud.OverwriteAnimations = {
	Walk = "rbxassetid://108621188713265",
	Idle = "rbxassetid://94925084807494",
	Decode = "rbxassetid://130124125865280",
	Run = "rbxassetid://82078521925458",
	Quirk = "rbxassetid://81686244378448"
}
FlowerBud.FaceTextures = {
	Normal = "rbxassetid://132699111454634",
	Blink = "rbxassetid://122130492450240",
	Hurt = "rbxassetid://70589927678091"
}
FlowerBud.USE_SKIN_MODEL = true

function FlowerBud.ApplySkin(_) end

function FlowerBud.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local v = instance:WaitForChild("HumanoidRootPart").Size.Y / 2 + humanoid.HipHeight
	local clone = game.ReplicatedStorage:WaitForChild("Parts"):WaitForChild("PoofPebbleSkins"):Clone()
	clone.Color = Color3.fromRGB(101, 157, 100)
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
	local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone.CanTouch = false
	clone.Size = createVector(0, 0.25, 0)
	clone.Position = instance.PrimaryPart.Position + Vector3.new(0, -v, 0)
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(45, 0.25, 45)
	}):Play()
	TweenService:Create(clone, tweenInfo2, {
		Transparency = 1,
		Rotation = createVector(0, 2.740167, 0)
	}):Play()
end

return FlowerBud