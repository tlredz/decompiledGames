local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = {
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true)
}

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame)
	else
		clone.CFrame = cFrame
	end

	clone.Parent = p2 or _WorldOrigin
	return clone
end

for _, child in pairs(script.Beam.Start.Attachment2:GetChildren()) do
	local speed = child.Speed
	child.Speed = NumberRange.new(speed.Min * 2, speed.Max * 2)
	local lifetime = child.Lifetime
	child.Lifetime = NumberRange.new(lifetime.Min * 0.5, lifetime.Max * 0.5)
	child.Rate *= 4.2
	ScaleParticle({
		Emitter = child,
		Scale = 1.75,
		Time = 0
	})
end

for _, emitter in pairs(script.Beam.Start.Attachment:GetChildren()) do
	if not emitter:IsA("ParticleEmitter") then
		continue
	end

	emitter.Rate *= 4.2
	ScaleParticle({
		Emitter = emitter,
		Scale = 1.75,
		Time = 0
	})
end

for _, emitter in pairs(script.Beam.End.Attachment:GetChildren()) do
	if emitter:IsA("ParticleEmitter") then
		emitter.Rate *= 4.2
	end
end

for _, emitter in pairs(script.Explosion:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		ScaleParticle({
			Emitter = emitter,
			Scale = 1.15,
			Time = 0
		})
	end
end

return function(player)
	local character = player.Character
	local _ = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	local position = player.Position
	local ground = player.Ground
	local normal = player.Normal

	if (workspace.CurrentCamera.CFrame.Position - position).magnitude > 1000 then
		return
	end

	local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -15) * CFrame.Angles(0, -1.57, 0)
	local beam = script.Beam
	local clone = beam:Clone()
	clone.Name = clone.Name

	if beam:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame)
	else
		clone.CFrame = cFrame
	end

	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 1.25)
	local _ = clone.Start
	TweenService:Create(
		clone.End,
		TweenInfo.new(player.ExplosionDelay, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		{
			Position = position
		}
	):Play()

	if character == game.Players.LocalPlayer.Character then
		CameraShaker:ShakeOnce(2.5, 4, 0.1, 0.75, createVector(0.15, 0.15, 0.15), createVector(1, 1, 1))
	end

	Sound:Play("FlameBeam", humanoidRootPart)
	task.wait(player.ExplosionDelay)

	if (workspace.CurrentCamera.CFrame.Position - position).magnitude < 120 then
		CameraShaker:ShakeOnce(19, 14, 0, 2.5)
	end

	Sound:Play("FlameProExplosion", position)
	local cframe = CFrame.new(position)
	local explosion = script.Explosion
	local clone2 = explosion:Clone()
	clone2.Name = clone2.Name

	if explosion:IsA("Model") then
		clone2:SetPrimaryPartCFrame(cframe)
	else
		clone2.CFrame = cframe
	end

	clone2.Parent = _WorldOrigin
	Debris:AddItem(clone2, 2)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	for _ = 1, 3 do
		local cFrame2 = clone2.CFrame * CFrame.Angles(
			math.rad((math.random(0, 180))),
			math.rad((math.random(0, 180))),
			(math.rad((math.random(0, 180))))
		)
		local color1 = script.Color1
		local clone3 = color1:Clone()
		clone3.Name = clone3.Name

		if color1:IsA("Model") then
			clone3:SetPrimaryPartCFrame(cFrame2)
		else
			clone3.CFrame = cFrame2
		end

		clone3.Parent = _WorldOrigin
		TweenService:Create(clone3, v[2], {
			Size = Vector3.new(clone3.Size.X * 14, clone3.Size.Y, clone3.Size.Z * 14),
			Transparency = 1
		}):Play()
		Debris:AddItem(clone3, 1)
	end

	if ground then
		local cFrame2 = CFrame.new(position, position + normal * 10) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
			0,
			math.random(-10, 10) / 10 * 3.141592653589793,
			0
		)
		local scar = script.Scar
		local clone3 = scar:Clone()
		clone3.Name = clone3.Name

		if scar:IsA("Model") then
			clone3:SetPrimaryPartCFrame(cFrame2)
		else
			clone3.CFrame = cFrame2
		end

		clone3.Parent = _WorldOrigin
		clone3.Size *= 2
		task.delay(3, function()
			for _, child in pairs(clone3:GetChildren()) do
				TweenService:Create(child, v[3], {
					Transparency = 1
				}):Play()
			end

			Debris:AddItem(clone3, 1.26)
		end)
	end

	task.wait(0.1)

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			TweenService:Create(descendant, TweenInfo.new(0.35), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		elseif descendant:IsA("PointLight") or descendant:IsA("SpotLight") then
			TweenService:Create(descendant, v[2], {
				Range = 0,
				Brightness = 0
			}):Play()
		end
	end
end