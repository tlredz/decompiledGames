local createVector = vector.create
local VintageTisha = {
	Name = "Vintage Tisha",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Blink = "rbxassetid://127297234549195",
		Hurt = "rbxassetid://131966880655115",
		Normal = "rbxassetid://80193849347450"
	},
	USE_SKIN_MODEL = false
}

function VintageTisha.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageTisha.FaceTextures.Normal
		end
	end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

function VintageTisha.UseAbility(instance)
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
	clone.Color = Color3.fromRGB(255, 255, 255)
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

return VintageTisha