local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local GoldenTissues = {}
GoldenTissues.Name = "Golden Tissues"
GoldenTissues.TowerName = "Tisha"
GoldenTissues.OverwriteAnimations = {
	Run = "rbxassetid://137651296949014",
	Walk = "rbxassetid://97207541098706",
	Idle = "rbxassetid://133180041158641",
	Quirk = "rbxassetid://101699896765601",
	Decode = "rbxassetid://82470856578727",
	Ability = "rbxassetid://124570208491016",
	IdleToExtract = "rbxassetid://70997860514970"
}
GoldenTissues.FaceTextures = {
	Normal = "rbxassetid://92570581865890",
	Blink = "rbxassetid://127196998356772",
	Hurt = "rbxassetid://137133831764836"
}
GoldenTissues.USE_SKIN_MODEL = true

function GoldenTissues.ApplySkin(_) end

function GoldenTissues.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local v = instance:WaitForChild("HumanoidRootPart").Size.Y / 2 + humanoid.HipHeight
	local clone = ReplicatedStorage.Parts.TishaPoof:Clone()
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
	clone.Parent = workspace
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.Color = Color3.fromRGB(215, 196, 104)
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

return GoldenTissues