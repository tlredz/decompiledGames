local createVector = vector.create
local currentCamera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local dough = FX:WaitForChild("Dough")
local origin = dough.Misc.Arms.Extend.Effects.Retract.Origin
local misc = Util.Misc
local tweenModel = Util.TweenModel

-- equivalent calls inferred from this helper; original call sites unknown
local function neofy(data, p)
	local v = Vector3.new(data.R, data.G, data.B) * (p and 1 + (p - 1) / 10 or 1)
	return Color3.new(math.min(1.96, v.X), math.min(1.96, v.Y), (math.min(1.96, v.Z)))
end

local function playParticles(p, width, p2, fastMode, ...)
	local v = 0

	for _, v2 in pairs({ ... }) do
		for _, emitter in pairs(v2:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			v = math.max(v, emitter.Lifetime.Max)
			local emit = emitter:GetAttribute("Emit") or emitter:GetAttribute("EmitCount")
			local emitDelay = emitter:GetAttribute("EmitDelay")
			local enable = emitter:GetAttribute("Enable")
			local v3 = math.min(1, p2)
			misc.ScaleParticle(emitter, width)

			if emitter:GetAttribute("LengthInfluenced") then
				emitter.Rate *= v3
				emitter.Speed = NumberRange.new(emitter.Speed.Min * p2, emitter.Speed.Max * p2)
				emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min * v3, emitter.Lifetime.Max * v3)
				emitter.Acceleration *= p2
			end

			if p then
				emitter.Color = ColorSequence.new(p)
			end

			emitter.Enabled = false
			local v5 = emitter

			local function fn()
				if emit then
					v5:Emit(emit * v3 * (fastMode and 0.25 or 1))
				end

				if enable then
					v5.Enabled = true

					if typeof(enable) == "number" then
						task.delay(enable * v3, function()
							v5.Enabled = false
						end)
					end
				end
			end

			if emitDelay and emitDelay > 0 then
				task.delay(emitDelay * v3, fn)
			else
				fn()
			end
		end
	end

	return v
end

local now = 0
return function(data)
	local random = Random.new()
	local cFrame = data.CFrame
	local width = data.Width
	local length = data.Length
	local color = data.Color or data.Buso

	if typeof(color) ~= "Color3" then
		color = nil
	end

	local duration = data.Duration
	local v = 4 * width / 4
	local v2 = math.min(2, (math.max(0.5, length / 107)))
	math.min(1, v2)
	local _ = length / 107
	local v3 = 200 + 4 * width * 3
	local magnitude = (currentCamera.CFrame.p - cFrame.p).Magnitude

	if v3 < magnitude then
		if v3 * 2 < magnitude then
			return
		end
	else
		local v4 = magnitude / v3
		Effect.new("ShakeCam"):replicate({
			PosInfluence = createVector(1, 1, 1),
			RotInfluence = createVector(1, 0, 1),
			Magnitude = 5,
			Roughness = 4,
			FadeIn = 0,
			FadeOut = duration / 2,
			Power = 1 - v4 * 0.5
		})
	end

	local clone = origin:Clone()
	clone.Size = createVector(5, 5, 0) * width
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	local v4 = 0

	for _, emitter in pairs(clone:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		v4 = math.max(v4, emitter.Lifetime.Max)
		emitter.Enabled = false
		misc.ScaleParticle(emitter, width)
		local v5 = emitter.Speed.Min / emitter.Speed.Max
		local v6 = math.min(emitter.Lifetime.Max, duration)
		local velocity = misc.CalculateVelocity(length, v6, emitter.Drag)
		emitter.Lifetime = NumberRange.new(v6 * v5, v6)
		emitter.Speed = NumberRange.new(velocity * v5, velocity)
		local enable = emitter:GetAttribute("Enable")
		local emit = emitter:GetAttribute("Emit") or emitter:GetAttribute("EmitCount")

		if emit then
			emitter:Emit(emit * v2 * (data.FastMode and 0.25 or 1))

			if duration < (not enable and 1e999 or enable + v6 or 1e999) / 2 then
				continue
			end
		end

		if not enable then
			continue
		end

		emitter.Enabled = true

		if typeof(enable) ~= "number" then
			continue
		end

		local v7 = math.min(duration, enable)
		local v8 = emitter
		task.delay(v7 * v2, function()
			v8.Enabled = false
			v8:Clear()
		end)
	end

	local color2 = neofy(color or Color3.new(1, 1, 1)) -- equivalent call inferred; original call site unknown
	local color3 = neofy((Color3.new(1, 1, 1))) -- equivalent call inferred; original call site unknown
	local halfDuration = duration / 2

	if halfDuration < 0.016666666666666666 then
		Util.Debris:AddItem(clone, v4)
	else
		task.delay(halfDuration / 1.25, function()
			clone.Attachment.CFrame = CFrame.new(0, 0, length)
			v4 = math.max(v4, playParticles(nil, width, v2, data.FastMode, clone.Attachment))
			Util.Debris:AddItem(clone, v4)

			if not data.LimitSound or tick() - now > 0.1 then
				Util.Sound:Play(
					"Dough.DoughArmRetract",
					clone.Attachment.WorldPosition,
					nil,
					0.314 / (1.5 * halfDuration)
				)
				now = tick()
			end

			if not data.FastMode then
				local v9 = random:NextNumber(-1, 1) * 3.141592653589793

				for i = 1, 1 do
					tweenModel(dough.Models.WindSwirl, {
						Color = color3,
						CFrame = cFrame * CFrame.new(0, 0, length) * CFrame.new(0, 0, 0) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						) * CFrame.Angles(0, (i == 1 and 0 or 3.141592653589793) + v9, 0),
						Size = createVector(0.8, 0, 0.8),
						Scale = 4 * width
					}, {
						Tween = TweenInfo.new(halfDuration * 1.1 * v2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						CFrame = CFrame.new(0, 5 * v, 0) * CFrame.Angles(0, -3.14, 0),
						Size = Vector3.new(0.125, 1 * v, 0.125),
						Scale = 4 * width,
						Transparency = 1
					})
				end

				for i = 1, 2 do
					tweenModel(dough.Models.ThinWind, {
						Color = color2,
						CFrame = cFrame * CFrame.new(0, 0, length) * CFrame.new(0, 0, 4 * v + (i - 1) * 1 * v) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						) * CFrame.Angles(0, 0, 3.141592653589793),
						Size = Vector3.new(0.2, 2 * v, 0.2),
						Scale = 4 * width * (4 - i) / 3,
						Transparency = 0.75
					}, {
						Tween = TweenInfo.new(
							halfDuration * v2 + halfDuration * v2 / 2 * (i - 1) / 2,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						),
						Color = color3,
						CFrame = CFrame.new(0, (i + 1) * -4 * 0.5 * v, 0),
						Size = Vector3.new(1, 0.25 * v, 1),
						Scale = 4 * width / 2 * (4 - i) / 3,
						Transparency = 1
					})
				end
			end
		end)
	end
end