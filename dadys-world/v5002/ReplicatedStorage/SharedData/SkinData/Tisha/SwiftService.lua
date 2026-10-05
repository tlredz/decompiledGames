local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SwiftService = {}
SwiftService.Name = "Swift Service"
SwiftService.TowerName = "Tisha"
SwiftService.OverwriteAnimations = {
	Run = "rbxassetid://73441286767225",
	Walk = "rbxassetid://131970898009943",
	Idle = "rbxassetid://98001160929061",
	Quirk = "rbxassetid://131232111505294",
	Decode = "rbxassetid://100732841914074",
	Ability = "rbxassetid://106466423552689",
	Idle_Extract = "rbxassetid://118265758902543"
}
SwiftService.FaceTextures = {
	Normal = "rbxassetid://105039007643055",
	Blink = "rbxassetid://126733974551243",
	Hurt = "rbxassetid://110616575519265"
}
SwiftService.USE_SKIN_MODEL = true

function SwiftService.ApplySkin(_) end

function SwiftService.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local v = instance:WaitForChild("HumanoidRootPart").Size.Y / 2 + humanoid.HipHeight
	local clone = ReplicatedStorage.Parts.TishaPoof:Clone()
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.Color = Color3.fromRGB(129, 207, 226)
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

return SwiftService