local createVector = vector.create
local Debris = game:GetService("Debris")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunnyWabbit = {}
BunnyWabbit.Name = "Bunny Wabbit"
BunnyWabbit.TowerName = "Pebble"
BunnyWabbit.Description = "No description yet"
BunnyWabbit.Mastery = false
BunnyWabbit.Cost = 600
BunnyWabbit.Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W1
BunnyWabbit.Easter = true
BunnyWabbit.HolidaySkin = true
BunnyWabbit.OverwriteAnimations = {
	Run = "rbxassetid://139422098206132",
	Walk = "rbxassetid://117535870219805",
	Idle = "rbxassetid://107115042417306",
	Quirk = "rbxassetid://117493922001353",
	Decode = "rbxassetid://130424144066816"
}
BunnyWabbit.FaceTextures = {
	Normal = "rbxassetid://71779305022170",
	Blink = "rbxassetid://133869808720948",
	Hurt = "rbxassetid://94566720278610"
}
BunnyWabbit.USE_SKIN_MODEL = true

function BunnyWabbit.ApplySkin(_) end

function BunnyWabbit.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local v = instance:WaitForChild("HumanoidRootPart").Size.Y / 2 + humanoid.HipHeight
	local clone = game.ReplicatedStorage:WaitForChild("Parts"):WaitForChild("PoofPebbleSkins"):Clone()
	clone.Color = Color3.fromRGB(243, 201, 254)
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

return BunnyWabbit