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
local _ = { TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) }

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, dust, p, p2)
	local clone = dust:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

local v = {
	LeftHand = "LeftWristRigAttachment",
	RightHand = "RightWristRigAttachment",
	LeftLowerArm = "LeftWristRigAttachment",
	RightLowerArm = "RightWristRigAttachment",
	LeftUpperArm = "LeftElbowRigAttachment",
	RightUpperArm = "RightElbowRigAttachment"
}
return function(player)
	local character = player.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 500 then
		return
	end

	local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 1, -10) * CFrame.Angles(0, 0, 3.141592653589793)
	local clone = script.eff:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	local weldConstraint = Instance.new("WeldConstraint", clone)
	weldConstraint.Part0 = humanoidRootPart
	weldConstraint.Part1 = clone

	for _, child in pairs(clone.Attachment:GetChildren()) do
		local lifetime = child.Lifetime
		child.Lifetime = NumberRange.new(lifetime.Min * 0.5, lifetime.Max * 0.5)
		child.Rate *= 2
		ScaleParticle({
			Emitter = child,
			Scale = 2,
			Time = 0.05,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out
		})
	end

	local clones = {}

	for _, parent in pairs(character:GetChildren()) do
		if not v[parent.Name] then
			continue
		end

		local clone2 = script.ChopGlow:Clone()
		clone2.Parent = parent[v[parent.Name]]
		local clone3 = script.Haze:Clone()
		clone3.Parent = parent[v[parent.Name]]
		local attachment = Instance.new("Attachment", parent)
		attachment.Position = createVector(0, 0.1, 0)
		Debris:AddItem(attachment, 1)
		local clone4 = script.Trail:Clone()
		clone4.Parent = parent
		clone4.Attachment0 = parent[v[parent.Name]]
		clone4.Attachment1 = attachment
		table.insert(clones, clone2)
		table.insert(clones, clone4)
		table.insert(clones, clone3)
	end

	local effect = createEffect(
		humanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 3.141592653589793, 0),
		script.Dust,
		"FullBodySpinDust" .. character.Name
	) -- equivalent call inferred; original call site unknown
	local lastTime = tick()
	local v5 = false
	local count = 0

	while effect ~= nil and effect.Parent ~= nil and tick() - lastTime < 8 and character:IsDescendantOf(workspace) and not (humanoid.Health <= 0) and player.Holding and player.Holding:IsDescendantOf(workspace) and (not player.ClientStatus or not player.ClientStatus.Parent ~= character) do
		v5 = not player.Holding.Value or v5

		if tick() - lastTime > 0.6666666666666666 and v5 then
			break
		end

		local ray = Ray.new(humanoidRootPart.Position, createVector(0, -10, 0))
		local part = workspace:FindPartOnRayWithWhitelist(ray, { map })

		if part == nil or effect == nil then
			effect.Attachment.ParticleEmitter.Enabled = false
			effect.Attachment.ParticleEmitter2.Enabled = false
		else
			effect.Attachment.ParticleEmitter.Color = ColorSequence.new(part.Color)
			effect.Attachment.ParticleEmitter2.Color = ColorSequence.new(part.Color)
			effect.Orientation = humanoidRootPart.Orientation - createVector(0, 180, 0)
			effect.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 3.141592653589793, 0)
			effect.Attachment.ParticleEmitter.Enabled = true
			effect.Attachment.ParticleEmitter2.Enabled = true
		end

		count += 1

		if count % 2 == 0 then
			Sound:Play("ChopWoosh", humanoidRootPart)
		end

		task.wait(0.05)
	end

	if effect then
		effect.Attachment.ParticleEmitter.Enabled = false
		effect.Attachment.ParticleEmitter2.Enabled = false
		Debris:AddItem(effect, 1)
	end

	if clone then
		clone.Punches.Enabled = false

		for _, child in pairs(clone.Attachment:GetChildren()) do
			child.Enabled = false
		end

		Debris:AddItem(clone, 1)
	end

	for _, v6 in pairs(clones) do
		v6.Enabled = false
		Debris:AddItem(v6, 0.5)
	end

	Sound:Play("ChopReassemble", humanoidRootPart)
end