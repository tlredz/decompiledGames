local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local GemPebble = {}
GemPebble.Name = "Thorned Geode"
GemPebble.Cost = 600
GemPebble.DandyStore = true
GemPebble.OverwriteAnimations = {
	Walk = "rbxassetid://108621188713265",
	Idle = "rbxassetid://94925084807494",
	Decode = "rbxassetid://130124125865280",
	Run = "rbxassetid://82078521925458",
	Quirk = "rbxassetid://81686244378448"
}
GemPebble.FaceTextures = {
	Normal = "rbxassetid://87557350023725",
	Blink = "rbxassetid://87351396084520",
	Hurt = "rbxassetid://125047613332743"
}
GemPebble.USE_SKIN_MODEL = true

function GemPebble.ApplySkin(_) end

function GemPebble.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local v = instance:WaitForChild("HumanoidRootPart").Size.Y / 2 + humanoid.HipHeight
	local clone = game.ReplicatedStorage:WaitForChild("Parts"):WaitForChild("PoofPebbleSkins"):Clone()
	clone.Color = Color3.fromRGB(147, 71, 157)
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
		Rotation = createVector(0, 2.740167, 0),
		Color = Color3.fromRGB(65, 129, 157)
	}):Play()
end

return GemPebble