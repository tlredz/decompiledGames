local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local DrearyMuse = {}
DrearyMuse.Name = "Dreary Muse"
DrearyMuse.TowerName = "Tisha"
DrearyMuse.Cost = 600
DrearyMuse.DandyStore = true
DrearyMuse.OverwriteAnimations = {
	IdleToExtract = "rbxassetid://139510422036961",
	Run = "rbxassetid://112844271228278",
	Quirk = "rbxassetid://82306302168256",
	Idle = "rbxassetid://95155757779211",
	Walk = "rbxassetid://93229018465766",
	Ability = "rbxassetid://138320771157896",
	Decode = "rbxassetid://82323971903485"
}
DrearyMuse.FaceTextures = {
	Hurt = "rbxassetid://109832067790237",
	Blink = "rbxassetid://98188375925966",
	Normal = "rbxassetid://103017927088978"
}
DrearyMuse.USE_SKIN_MODEL = true

function DrearyMuse.ApplySkin(_) end

function DrearyMuse.UseAbility(instance)
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
	clone.Color = Color3.fromRGB(173, 112, 179)
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

return DrearyMuse