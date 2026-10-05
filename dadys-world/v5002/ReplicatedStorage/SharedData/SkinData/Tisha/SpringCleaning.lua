local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpringCleaning = {
	Name = "Spring Cleaning",
	TowerName = "Tisha",
	Cost = 600,
	Easter = true,
	HolidaySkin = true,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W3,
	OverwriteAnimations = {
		Idle = "rbxassetid://97897013860675",
		Ability = "rbxassetid://81560484561440",
		Decode = "rbxassetid://121708296419903",
		Quirk = "rbxassetid://126141928984826",
		IdleToExtract = "rbxassetid://85238767773454",
		Walk = "rbxassetid://121018887759941",
		Run = "rbxassetid://109515193459041"
	},
	FaceTextures = {
		Normal = "rbxassetid://89646701164438",
		Blink = "rbxassetid://107640041492195",
		Hurt = "rbxassetid://104004104131170"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

function SpringCleaning.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local v = instance:WaitForChild("HumanoidRootPart").Size.Y / 2 + humanoid.HipHeight
	local clone = ReplicatedStorage2.Parts.TishaPoof:Clone()
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.Color = Color3.fromRGB(237, 183, 187)
	clone.CastShadow = false
	clone.CanTouch = false
	clone.Size = createVector(0, 0.25, 0)
	clone.Position = instance.PrimaryPart.Position + Vector3.new(0, -v, 0)
	task.spawn(function()
		local featherStick = instance:FindFirstChild("FeatherStick")
		local particleEmitter = featherStick and featherStick:FindFirstChild("ParticleEmitter")

		if particleEmitter then
			local clone2 = particleEmitter:Clone()
			clone2.Parent = clone
			clone2.Enabled = true
			task.delay(1.5, function()
				if clone2 and clone2.Parent then
					clone2.Enabled = false
				end
			end)
		end
	end)
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(60, 0.25, 60),
		Transparency = 1,
		Rotation = createVector(0, 2.740167, 0)
	}):Play()
end

return SpringCleaning