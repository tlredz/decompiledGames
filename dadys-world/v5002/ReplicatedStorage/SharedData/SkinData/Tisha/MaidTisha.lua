local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local MaidTisha = {}
MaidTisha.Name = "Lavender Maid"
MaidTisha.Cost = 600
MaidTisha.DandyStore = true
MaidTisha.OverwriteAnimations = {
	Idle = "rbxassetid://97897013860675",
	Ability = "rbxassetid://81560484561440",
	Decode = "rbxassetid://108650479686917",
	Quirk = "rbxassetid://133736232578672",
	IdleToExtract = "rbxassetid://85238767773454",
	Walk = "rbxassetid://118843430700558",
	Run = "rbxassetid://109515193459041"
}
MaidTisha.FaceTextures = {
	Blink = "rbxassetid://131210630821124",
	Hurt = "rbxassetid://126270218570116",
	Normal = "rbxassetid://87295821417072"
}
MaidTisha.USE_SKIN_MODEL = true

function MaidTisha.ApplySkin(_) end

function MaidTisha.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	instance:WaitForChild("Config"):WaitForChild("ModuleName")
	local v = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
	local clone = ReplicatedStorage.Parts.TishaPoof:Clone()
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.Color = Color3.fromRGB(109, 109, 165)
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

return MaidTisha