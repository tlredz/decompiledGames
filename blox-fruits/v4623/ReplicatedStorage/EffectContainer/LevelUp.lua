game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(list)
	local character = list[1].Character
	local _ = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 600 then
		return
	end

	for _, child in pairs(script.Particles:GetChildren()) do
		local clone = child:Clone()
		Debris:AddItem(clone, 4)
		local speed = clone.Speed
		clone.Speed = NumberRange.new(speed.Min * 0.6153846153846154, speed.Max * 0.6153846153846154)
		local lifetime = clone.Lifetime
		clone.Lifetime = NumberRange.new(lifetime.Min * 3.25, lifetime.Max * 3.25)
		ScaleParticle({
			Emitter = clone,
			Scale = child.Name == "Stars" and 1.5 or 2,
			Time = 0.05,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out
		})
		clone.Parent = humanoidRootPart.RootRigAttachment
		clone:Emit(clone:GetAttribute("EmitCount"))
	end

	local cFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0)
	local clone = script.Rings:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	clone.Weld.Part0 = humanoidRootPart
	Debris:AddItem(clone, 4)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 3.25, lifetime.Max * 3.25)
		local speed = emitter.Speed
		emitter.Speed = NumberRange.new(speed.Min * 0.3076923076923077, speed.Max * 0.3076923076923077)
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end
end