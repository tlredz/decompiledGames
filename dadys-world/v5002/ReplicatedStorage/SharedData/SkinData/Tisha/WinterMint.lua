local createVector = vector.create
local WinterMint = {
	Name = "Winter Mint",
	TowerName = "Tisha",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0),
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Decode = "rbxassetid://73194617893805",
		Walk = "rbxassetid://132404299819701",
		Run = "rbxassetid://116741313910962",
		Quirk = "rbxassetid://77442035732104",
		IdleToExtract = "rbxassetid://109473811458829",
		Idle = "rbxassetid://100527134720369",
		Ability = "rbxassetid://96057142834033"
	},
	FaceTextures = {
		Blink = "rbxassetid://121255757213880",
		Hurt = "rbxassetid://94105557598383",
		Normal = "rbxassetid://134668668117322"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

function WinterMint.UseAbility(instance)
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
	clone.Color = Color3.fromRGB(117, 177, 148)
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

return WinterMint