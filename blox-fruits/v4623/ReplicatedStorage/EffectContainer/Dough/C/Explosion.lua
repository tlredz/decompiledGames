local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local explosion = FX:WaitForChild("Dough").C.Explosion
local boatTween = Util.BoatTween
local _ = Util.TweenModel
local lightningBolt2 = Util.LightningBolt2
local attachmentPair = Util.AttachmentPair

local function createEffect(cFrame, instance, value, value2, color)
	local clone = instance:Clone()
	local v = value or 1
	local v2 = value2 or 1

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			Util.Misc.ScaleParticle(descendant, v)
			descendant.Rate *= v
			descendant.Lifetime = NumberRange.new(descendant.Lifetime.Min * v2, descendant.Lifetime.Max * v2)

			if color then
				descendant.Color = Util.Misc.SwapColorInKeypoints(descendant.Color, Color3.new(1, 0, 0), color)
			end
		end

		if descendant:IsA("Beam") then
			descendant.Width0 *= v
			descendant.Width1 *= v

			if color then
				descendant.Color = Util.Misc.SwapColorInKeypoints(descendant.Color, Color3.new(1, 0, 0), color)
			end
		end

		if descendant:IsA("BasePart") then
			descendant.Size *= v
		end

		if descendant:IsA("Attachment") then
			descendant.Position *= v
		end
	end

	if clone:IsA("BasePart") then
		clone.Size *= v
		clone.CFrame = cFrame

		if color then
			clone.Color = color
		end
	end

	clone.Parent = _WorldOrigin
	return clone
end

local v = {
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.2, Enum.EasingStyle.Sine),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine)
}

local function scaleTweenInfo(data, value)
	local v2 = {
		data.Time,
		data.EasingStyle,
		data.EasingDirection,
		data.RepeatCount,
		data.Reverses,
		data.DelayTime
	}
	v2[1] *= value or 1
	return TweenInfo.new(table.unpack(v2))
end

return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale or 1
	local lifetime = data.Lifetime or 1
	local buso = data.Buso
	local color = nil

	if typeof(buso) == "Instance" then
		color = buso.Color
	elseif typeof(buso) == "Color3" then
		color = buso
	end

	local random = Random.new()
	local effect = createEffect(cFrame * CFrame.Angles(0, 1.57, -1.57), explosion.Part, scale, lifetime, color)
	Util.Debris:AddItem(effect, 2 * lifetime + lifetime)
	local descendants = effect:GetDescendants()

	for _, effect2 in pairs(descendants) do
		if effect2:IsA("ParticleEmitter") then
			effect2.Enabled = true
		elseif effect2:IsA("Beam") then
			local transparency = effect2.Transparency
			effect2.Transparency = NumberSequence.new(1)
			local worldPosition = effect2.Attachment1.WorldPosition - createVector(0, 1, 0) * effect2.Attachment1.Position.Magnitude * 0.25
			boatTween:Create(effect2.Attachment1, {
				Time = 0.5 * lifetime,
				EasingStyle = "Circ",
				EasingDirection = "Out",
				StepType = "Heartbeat",
				Goal = {
					WorldPosition = worldPosition
				}
			}):Play()
			boatTween:Create(effect2, {
				Time = 0.25 * lifetime,
				EasingStyle = "Sine",
				EasingDirection = "In",
				StepType = "Heartbeat",
				Goal = {
					Transparency = transparency
				}
			}):Play()
		end
	end

	local effect2 = createEffect(effect.CFrame * CFrame.new(0, 3, 0), explosion.Lightning, scale, lifetime, color)
	effect2.Size *= 1.3
	Util.Debris:AddItem(effect2, 0.45 * lifetime + lifetime)
	local v2 = 0

	for _, emitter in pairs(effect2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			v2 = math.max(emitter.Lifetime.Max, v2)
		end
	end

	local v3 = 0
	Util.DistributedLoop:add(function(p, _)
		local now = tick()
		local v4 = false

		for _, emitter in pairs(effect2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") or v4 or not emitter.Enabled then
				continue
			end

			v4 = true
		end

		if v2 < now - v3 then
			for _, emitter in pairs(effect2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					Effect.new("Dough.Misc.SpriteParticle"):replicate({
						Particle = emitter,
						Sprite = emitter.Name,
						Duration = v2 + lifetime
					})
				end
			end

			v3 = now
		end

		if v4 and not (lifetime + 2 < p) then
			return
		else
			return true
		end
	end)

	for i = 1, 2 do
		local effect3 = createEffect(cFrame, explosion.Sphere, scale, lifetime)
		Util.Debris:AddItem(effect3, 1 * lifetime)

		if i == 1 then
			TweenService:Create(effect3, scaleTweenInfo(v[3], 2 * lifetime), {
				Transparency = 1,
				Size = effect3.Size * 4
			}):Play()
		else
			effect3.Color = color or Color3.new(1, 0, 0)
			TweenService:Create(effect3, scaleTweenInfo(v[4], 2 * lifetime), {
				Transparency = 1,
				Size = effect3.Size * 4
			}):Play()
		end
	end

	local effect3 = createEffect(cFrame * CFrame.new(0, 5, 0), explosion.Color2, 1.25 * scale, 1.5 * lifetime)
	Util.Debris:AddItem(effect3, 2)
	TweenService:Create(effect3, scaleTweenInfo(v[5], 1.5 * lifetime), {
		Size = Vector3.new(effect3.Size.X * 3, effect3.Size.Y * 3, effect3.Size.Z * 3),
		CFrame = effect3.CFrame * CFrame.Angles(0, 3.14, 0),
		Transparency = 1,
		Orientation = effect3.Orientation + createVector(0, 90, 0)
	}):Play()

	for _ = 1, 2 do
		local effect4 = createEffect(
			cFrame * CFrame.Angles(
				math.rad((math.random(0, 180))),
				math.rad((math.random(0, 180))),
				(math.rad((math.random(0, 180))))
			),
			explosion.Color1,
			scale,
			lifetime,
			color
		)
		TweenService:Create(effect4, scaleTweenInfo(v[5], lifetime), {
			Size = Vector3.new(effect4.Size.X * 3, effect4.Size.Y, effect4.Size.Z * 3),
			CFrame = effect4.CFrame * CFrame.Angles(0, 3.14, 0),
			Transparency = 1
		}):Play()
		Util.Debris:AddItem(effect4, 1)
	end

	local rayMap, v4, v5 = Util.RayMap(cFrame * createVector(0, 5, 0), -cFrame.UpVector * 10)

	if rayMap then
		local effect4 = createEffect(
			CFrame.new(v4, v4 + v5 * 10) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				math.random(-10, 10) / 10 * 3.141592653589793,
				0
			),
			explosion.Dust,
			scale,
			lifetime
		)

		for _, child in pairs(effect4.Attachment:GetChildren()) do
			child.Color = ColorSequence.new(rayMap.Color:Lerp(Color3.new(), 0.15))
			child:Emit(child:GetAttribute("EmitCount"))
			child.Enabled = true
		end

		task.delay(lifetime * 0.15, function()
			for _, child in pairs(effect4.Attachment:GetChildren()) do
				child.Enabled = false
			end

			Util.Debris:AddItem(effect4, 2.5 * lifetime)
		end)
	end

	task.spawn(function()
		for _ = 1, 8 do
			if typeof(buso) == "Instance" then
				color = buso.Color
			end

			local v6 = attachmentPair.new(nil, nil)
			v6.attachment0.Parent = effect
			local worldPosition = cFrame * (Vector3.new(
				random:NextNumber(-1, 1),
				random:NextNumber(0.5, 1),
				random:NextNumber(-1, 1)
			).Unit * random:NextNumber(100 * scale, 100 * scale))
			local lookVector = CFrame.lookAt(
				createVector(0, 0, 0),
				(worldPosition - cFrame.p) * createVector(1, 0.01, 1)
			):Lerp(
				CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)),
				random:NextNumber(0.1, 0.4)
			).LookVector
			local upVector = cFrame.UpVector
			v6.attachment0.WorldAxis = lookVector
			v6.attachment1.WorldAxis = -upVector
			v6.attachment0.Position = (worldPosition - cFrame.p).Unit * random:NextNumber(100 * scale / 4, 100 * scale)
			v6.attachment1.WorldPosition = worldPosition
			local v8 = lightningBolt2.new(v6.attachment0, v6.attachment1, 3 * random:NextInteger(3, 4))
			v8.CurveSize0 = scale * 100 / 2 * random:NextNumber(0.4, 0.7)
			v8.CurveSize1 = scale * 100 / 2 * random:NextNumber(0.4, 0.7)
			v8.Thickness = scale * 100 / 2 * 0.01
			v8.MaxRadius = scale * 100 / 4
			v8.Color = random:NextInteger(1, 2) == 1 and Color3.new() or color or Color3.new(1, 0, 0)
			v8.PulseSpeed = 4
			v8.AnimationSpeed = 10
			local v9 = 4 * v8.Thickness
			local v10 = scale * 100 / 2 * random:NextNumber(0.9, 1.9)
			local v11 = 0.5 * lifetime * random:NextNumber(0.5, 2)
			Util.DistributedLoop:add(function(p, p2)
				local v16 = math.min(1, p / v11)
				v8.AnimationSpeed = 10 - v16 * 5
				v8.CurveSize0 = 5 + v16 * v10 * 1.8
				v8.Thickness = v9 * math.sin(29.4 * p) ^ 2
			end)
			local v16 = v8
			task.delay(v11, function()
				task.wait(0.1)
				v16:Destroy()
				v6:destroy()
			end)
			task.wait(v11 / 8)
		end
	end)
	task.wait(0.375 * lifetime)
	task.delay(0.5 * lifetime, function()
		for _, child in pairs(effect2:GetChildren()) do
			child.Enabled = false
		end
	end)

	for _, effect4 in pairs(descendants) do
		if effect4:IsA("ParticleEmitter") then
			effect4.Enabled = false
		elseif effect4:IsA("Beam") then
			boatTween:Create(effect4, {
				Time = 0.55 * lifetime,
				EasingStyle = "Sine",
				EasingDirection = "Out",
				StepType = "Heartbeat",
				Goal = {
					Width0 = 0,
					Width1 = 0,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 1)
					})
				}
			}):Play()
		end
	end
end