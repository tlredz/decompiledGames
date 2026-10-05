local createVector = vector.create
local GleefulGift = {
	Name = "Gleeful Gift",
	TowerName = "Pebble",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0),
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Run = "rbxassetid://71009829672787",
		Walk = "rbxassetid://124155681228685",
		Idle = "rbxassetid://100834758780437",
		Quirk = "rbxassetid://87784898317116",
		Decode = "rbxassetid://122974799998053"
	},
	FaceTextures = {
		Normal = "rbxassetid://71092261595128",
		Blink = "rbxassetid://127981238560237",
		Hurt = "rbxassetid://95622846322396"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

function GleefulGift.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local v = instance:WaitForChild("HumanoidRootPart").Size.Y / 2 + humanoid.HipHeight
	local clone = game.ReplicatedStorage:WaitForChild("Parts"):WaitForChild("PoofPebbleSkins"):Clone()
	clone.Color = Color3.fromRGB(52, 129, 51)
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

return GleefulGift