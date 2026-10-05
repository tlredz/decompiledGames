local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local v = require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
local v2 = require3(ReplicatedStorage2.Misc.LightningBolt)
local v3 = require3(ReplicatedStorage2.Misc.LightningBolt.LightningSparks)
local v4 = require3(ReplicatedStorage2.Shared.ShockwaveEffect)
local v5 = require3(ReplicatedStorage2.Shared.SpeedModifiers)
local Phantom = {}
Phantom.cooldown = 18
Phantom.cooldownReductionPerUpgrade = 4
Phantom.iconId = "rbxassetid://15059341639"

function Phantom.validateArguments(p)
	assert(p ~= nil, "Bad arguments")
	assert(typeof(p.target) == "Instance", "Bad target")
	assert(p.target.Parent == workspace.Alive, "Bad target parent")
	assert(p.target:IsA("Model"), "Invalid target")
end

function Phantom.canBeUsed(p)
	return v.GetCharacterTargetCharacter(p.character) ~= nil
end

function Phantom.localOwnerActivation(p)
	local characterTargetCharacter = v.GetCharacterTargetCharacter(p.character)
	task.delay(p.upgradeLevel >= 2 and 0 or 0.5, function()
		p.character:PivotTo(characterTargetCharacter:GetPivot())

		if RunService:IsClient() then
			TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				FieldOfView = 75.60000000000001
			}):Play()
		end
	end)
	return {
		target = characterTargetCharacter
	}
end

function Phantom.serverActivationAsync(p, _, p2)
	task.delay(p.upgradeLevel >= 2 and 0 or 0.5, function()
		p.character:PivotTo(p2.target:GetPivot())
	end)

	if p2.target:FindFirstChildWhichIsA("Humanoid") then
		local v6 = v5:SetModifierFor(p2.target, "Phantom", v5.Utils.MinDebuff(p2.target, 10), v5.Priority.DEBUFF)
		task.delay(5, v6)
	end
end

function Phantom.anyClientActivationAsync(data, _, p)
	local clone, clone2, color

	if data.upgradeLevel >= 2 then
		clone = ReplicatedStorage2.Misc.maxTransmission:Clone()
		clone2 = ReplicatedStorage2.Misc.maxTransmission:Clone()
		color = Color3.fromRGB(255, 162, 0)
	else
		clone = ReplicatedStorage2.Misc.transmissionpart:Clone()
		clone2 = ReplicatedStorage2.Misc.transmissionpart:Clone()
		color = Color3.fromRGB(53, 39, 255)
	end

	clone.Parent = workspace.Runtime
	clone:PivotTo(data.character:GetPivot())
	clone.WeldConstraint.Part1 = data.rootPart
	task.delay(0.1, function()
		clone.otherpart.Position = clone.Position + createVector(0, 20, 0)
	end)
	clone2.Parent = workspace.Runtime
	clone2:PivotTo(p.target:GetPivot())
	clone2.WeldConstraint.Part1 = p.target:FindFirstChild("HumanoidRootPart")
	Debris:AddItem(clone, 5)
	Debris:AddItem(clone2, 7)

	if data.upgradeLevel < 2 then
		clone.charg:Play()
	end

	clone2.reaperSound:Play()

	if data.upgradeLevel < 2 then
		clone.Attachment.Osu:Emit(1)
		clone.Attachment.zapper:Emit(1)
	end

	clone.otherpart.Attachment.ParticleEmitter:Emit(20)
	clone2.Attachment.Smoke2nd:Emit(1)

	for _, part in data.character:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local clone3 = part:Clone()
		clone3:ClearAllChildren()
		clone3.Color = Color3.new(0, 0, 0)
		clone3.Size *= 1.2
		clone3.Anchored = false
		clone3.Parent = workspace.Runtime
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Parent = clone3
		weldConstraint.Part0 = clone3
		weldConstraint.Part1 = part
		Debris:AddItem(clone3, 2)
		task.delay(0.5, function()
			TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = clone3.Size * 1.5
			}):Play()
		end)
	end

	if data.upgradeLevel >= 2 then
		task.delay(0.1, function()
			local v6 = v2.new(clone.otherpart.Attachment, clone.Attachment, 7)
			v6.AnimationSpeed = 5
			v6.CurveSize0 = 3
			v6.CurveSize1 = 3
			v6.Color = color
			v6.Thickness = 0.5
			v6.PulseSpeed = 10
			v6.PulseLength = 4
			v6.FadeLength = 1
			v6.MaxRadius = 5
			v6.ContractFrom = 0.2
			v6.MinThicknessMultiplier = 0.75
			v6.MaxThicknessMultiplier = 1.5
			local v7 = v3.new(v6)
			v7.Color = Color3.new(1, 0.905882, 0.360784)
			v7.MaxSparkCount = 3
		end)
	else
		local v6 = v2.new(clone.otherpart.Attachment, clone.Attachment, 7)
		v6.AnimationSpeed = 5
		v6.CurveSize0 = 3
		v6.CurveSize1 = 3
		v6.Color = color
		v6.Thickness = 0.4
		v6.PulseSpeed = 10
		v6.PulseLength = 4
		v6.FadeLength = 1
		v6.MaxRadius = 5
		v6.ContractFrom = 0.2
		v6.MinThicknessMultiplier = 0.75
		v6.MaxThicknessMultiplier = 1.5
		local v7 = v3.new(v6)
		v7.Color = Color3.new(0, 0, 0)
		v7.MaxSparkCount = 3
	end

	v4({
		cframe = clone.CFrame,
		diameter = 15,
		orientation = "Forward",
		color = color
	})
	v4({
		cframe = clone2.CFrame,
		diameter = 15,
		orientation = "Forward",
		color = color
	})

	if data.upgradeLevel < 2 then
		task.wait(0.3)
	end

	clone.Attachment.Smoke:Emit(1)

	if data.upgradeLevel < 2 then
		task.wait(0.167)
	end

	clone2.atttoo.p22:Emit(1)

	for _, part in data.character:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local clone3 = part:Clone()
		clone3:ClearAllChildren()
		clone3.Color = Color3.fromRGB(17, 17, 17)
		clone3.Material = Enum.Material.Neon
		clone3.Transparency = 1 - (1 - clone3.Transparency) * 0.6
		clone3.CanCollide = false
		clone3.CanTouch = false
		clone3.CanQuery = false
		clone3.CastShadow = false
		clone3.Anchored = true
		clone3.Parent = workspace.Runtime
		Debris:AddItem(clone3, 2)
		task.delay(0.5, function()
			TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = createVector(0, 0, 0)
			}):Play()
		end)
	end
end

return Phantom