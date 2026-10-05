local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)

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

return function(data)
	local cFrame = data.CFrame

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).magnitude > 400 then
		return
	end

	local scale = data.Scale or 1
	local endPosition = data.EndPosition or 40
	local duration = data.Duration or 0.6
	local color1 = data.Color1 or Color3.fromRGB(172, 255, 235)
	local color2 = data.Color2 or Color3.fromRGB(128, 197, 254)
	local clone = script.circle:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	local descendants = clone.Attachment:GetDescendants()
	Debris:AddItem(clone, duration + 5)
	TweenService:Create(clone, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
		CFrame = CFrame.new(endPosition)
	}):Play()

	for _, emitter in pairs(descendants) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local speed = emitter.Speed
		emitter.Speed = NumberRange.new(speed.Min * 2, speed.Max * 2)
		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 0.5, lifetime.Max * 0.5)
		emitter.Rate *= 1.5

		if scale ~= 1 then
			ScaleParticle({
				Emitter = emitter,
				Scale = scale,
				Time = 0
			})
		end

		if emitter:FindFirstChild("Color1") then
			emitter.Color = ColorSequence.new(color1)
		elseif emitter:FindFirstChild("Color2") then
			emitter.Color = ColorSequence.new(color2)
		end

		emitter.Enabled = true
	end

	local flag = true
	task.spawn(function()
		local count = 0

		while flag do
			Sound:Play("QuickSlice", clone.Position)
			count += 1

			if count % 3 == 0 then
				for _, emitter in pairs(descendants) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(1)
					end
				end
			end

			task.wait(0.09)
		end
	end)
	task.wait(duration)

	for _, emitter in pairs(descendants) do
		if emitter:IsA("ParticleEmitter") then
			ScaleParticle({
				Emitter = emitter,
				Scale = 0,
				Time = 0.125,
				EasingStyle = Enum.EasingStyle.Quad,
				EasingDirection = Enum.EasingDirection.Out
			})
		end
	end

	for _, emitter in pairs(clone.Explosion:GetChildren()) do
		if not (emitter:IsA("ParticleEmitter") and emitter.Name == "Flare") then
			continue
		end

		ScaleParticle({
			Emitter = emitter,
			Scale = 1.5 * scale,
			Time = 0.2,
			EasingStyle = Enum.EasingStyle.Quad,
			EasingDirection = Enum.EasingDirection.Out
		})

		if emitter:FindFirstChild("Color1") then
			emitter.Color = ColorSequence.new(color1)
		elseif emitter:FindFirstChild("Color2") then
			emitter.Color = ColorSequence.new(color2)
		end

		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	Sound:Play("ChopTackle2", clone.Position)
	task.wait(0.125)
	flag = false

	for _, emitter in pairs(clone.Explosion:GetChildren()) do
		if not (emitter:IsA("ParticleEmitter") and emitter.Name ~= "Flare") then
			continue
		end

		ScaleParticle({
			Emitter = emitter,
			Scale = 1.5 * scale,
			Time = 0.2,
			EasingStyle = Enum.EasingStyle.Quad,
			EasingDirection = Enum.EasingDirection.Out
		})

		if emitter:FindFirstChild("Color1") then
			emitter.Color = ColorSequence.new(color1)
		elseif emitter:FindFirstChild("Color2") then
			emitter.Color = ColorSequence.new(color2)
		end

		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	clone.Anchored = true

	for _, emitter in pairs(descendants) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end