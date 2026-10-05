local createVector = vector.create
game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local DreamPebble = {}
DreamPebble.Name = "Star-Time Pebble"
DreamPebble.OverwriteAnimations = {
	Walk = "rbxassetid://108621188713265",
	Idle = "rbxassetid://94925084807494",
	Decode = "rbxassetid://130124125865280",
	Run = "rbxassetid://82078521925458",
	Quirk = "rbxassetid://81686244378448"
}
DreamPebble.FaceTextures = {
	Normal = "rbxassetid://94118610964552",
	Blink = "rbxassetid://132766043150769",
	Hurt = "rbxassetid://71342802770833"
}
DreamPebble.USE_SKIN_MODEL = true

function DreamPebble.ApplySkin(_) end

function DreamPebble.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local v = instance:WaitForChild("HumanoidRootPart").Size.Y / 2 + humanoid.HipHeight
	local clone = game.ReplicatedStorage:WaitForChild("Parts"):WaitForChild("Poof"):Clone()
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
	local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	local tweenInfo3 = TweenInfo.new(0.33, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone.CanTouch = false
	clone.Size = createVector(0, 0.25, 0)
	clone.Position = instance.PrimaryPart.Position + Vector3.new(0, -v, 0)
	Debris:AddItem(clone, 5)
	task.spawn(function()
		task.wait(0.1)
		local tween = TweenService:Create(clone, tweenInfo3, {
			Color = Color3.fromRGB(179, 179, 179)
		})
		tween:Play()
		tween.Completed:Wait()
		local tween2 = TweenService:Create(clone, tweenInfo3, {
			Color = Color3.fromRGB(157, 141, 83)
		})
		tween2:Play()
		tween2.Completed:Wait()
	end)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(45, 0.25, 45)
	}):Play()
	TweenService:Create(clone, tweenInfo2, {
		Transparency = 1,
		Rotation = createVector(0, 2.740167, 0)
	}):Play()
end

return DreamPebble