local createVector = vector.create
game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p, character)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = character or _WorldOrigin
	return clone
end

return function(player)
	local character = player.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 300 then
		return
	end

	Sound:Play("SpikeSpinStart", humanoidRootPart)
	local effect = createEffect(
		humanoidRootPart.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(0, 0, 3.141592653589793),
		script.SpinPart,
		"SpinCircle" .. character.Name
	) -- equivalent call inferred; original call site unknown
	local weldConstraint = Instance.new("WeldConstraint", effect)
	weldConstraint.Part0 = humanoidRootPart
	weldConstraint.Part1 = effect

	for _, child in pairs(effect.Attachment:GetChildren()) do
		ScaleParticle({
			Emitter = child,
			Scale = 5,
			Time = 3,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out
		})
	end

	for i = 1, 2 do
		local effect2 = createEffect(humanoidRootPart.CFrame, script.Spike, "ArmSpike" .. character.Name, character) -- equivalent call inferred; original call site unknown

		if i == 1 then
			effect2.Weld.Part0 = character.LeftHand
		else
			effect2.Weld.Part0 = character.RightHand
		end
	end

	local effect2 = createEffect(
		humanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 3.141592653589793, 0),
		script.Dust,
		"SpikeSpinDust" .. character.Name
	) -- equivalent call inferred; original call site unknown
	local lastTime = tick()
	local v5 = nil

	while effect2 ~= nil and effect2.Parent ~= nil and effect.Name == "SpinCircle" .. character.Name and player.Status and player.Status:IsDescendantOf(workspace) and humanoid:IsDescendantOf(workspace) and humanoid.Health > 0 do
		local ray = Ray.new(humanoidRootPart.Position, createVector(0, -15, 0))
		local part, v7 = workspace:FindPartOnRayWithWhitelist(ray, { map })

		if tick() - lastTime > 0.3 and not v5 then
			v5 = Sound:Play("SpikeSpinLoop", humanoidRootPart)
		end

		if part == nil or effect2 == nil then
			effect2.Attachment.ParticleEmitter.Enabled = false
			effect2.Attachment.ParticleEmitter2.Enabled = false
		else
			effect2.Attachment.ParticleEmitter.Color = ColorSequence.new(part.Color)
			effect2.Attachment.ParticleEmitter2.Color = ColorSequence.new(part.Color)
			effect2.Orientation = humanoidRootPart.Orientation - createVector(0, 180, 0)
			effect2.CFrame = CFrame.new(v7) * (humanoidRootPart.CFrame - humanoidRootPart.CFrame.p) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			)
			effect2.Attachment.ParticleEmitter.Enabled = true
			effect2.Attachment.ParticleEmitter2.Enabled = true
		end

		task.wait(0.065)
	end

	if effect then
		effect.Name = "OldSpinny"

		for _, child in pairs(effect.Attachment:GetChildren()) do
			child.Enabled = false
		end

		effect:FindFirstChildOfClass("WeldConstraint"):Destroy()
		effect.Anchored = true
		Debris:AddItem(effect, 1)
	end

	if effect2 then
		effect2.Attachment.ParticleEmitter.Enabled = false
		effect2.Attachment.ParticleEmitter2.Enabled = false
		Debris:AddItem(effect2, 1)
	end

	for _, child in pairs(character:GetChildren()) do
		if child.Name == "ArmSpike" .. character.Name then
			child:Destroy()
		end
	end

	if v5 then
		Sound:FadeOut(v5, 0.5)
	end
end