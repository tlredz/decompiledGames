local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local currentCamera = workspace.CurrentCamera
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local map = workspace:WaitForChild("Map")
local Effect = require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local blackHole = FX:WaitForChild("Dark").BlackHole
local sound = Util.Sound
local debris = Util.Debris
local cameraShaker = Util.CameraShaker
local _ = Util.ParticleScaler

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local v = {
	TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Parent = p2 or _WorldOrigin
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	return clone
end

return function(data)
	local height = data.Height or 15
	local holding = data.Holding
	local position = data.Position
	local chargeTime = data.ChargeTime or 2
	local _ = data.Scale or 1

	if (workspace.CurrentCamera.CFrame.Position - position).magnitude > 500 then
		return
	end

	if data.Player == game.Players.LocalPlayer then
		Effect.new("Dark.Gradient"):replicate({
			Transparency = 0.7,
			Duration = 0.3
		})
	end

	local rayCastWhitelist, v2, v3 = Util.RayCastWhitelist(
		position + createVector(0, 1, 0),
		createVector(0, -15, 0),
		{ map }
	)
	local random = Random.new()
	local v4 = not rayCastWhitelist and 0 or height
	local alignCFrame = Util.Misc.AlignCFrame

	if rayCastWhitelist then
		position = v2 or position
	end

	local cFrame = alignCFrame(CFrame.new(position), v3)
	local clone = blackHole.Absorption:Clone()
	clone.Parent = _WorldOrigin
	clone.Name = clone.Name
	clone.CFrame = cFrame
	TweenService:Create(clone, v[1], {
		CFrame = clone.CFrame * CFrame.new(0, v4, 0),
		Size = createVector(2.5, 2.5, 2.5)
	}):Play()
	sound:Play("DarkBlackHoleSpawn", clone, nil, 1)

	if data.Player == game.Players.LocalPlayer then
		Effect.new("Dark.Gradient"):replicate({
			Transparency = 0.7,
			Duration = 0.3,
			Toggle = true
		})
	end

	local descendants = clone:GetDescendants()
	local v6 = {}

	for _, emitter in pairs(descendants) do
		if emitter:IsA("ParticleEmitter") then
			table.insert(v6, {
				Object = emitter,
				Data = {
					Size = emitter.Size.Keypoints,
					Speed = emitter.Speed,
					Acceleration = emitter.Acceleration
				}
			})
		end
	end

	clone.Attachment2.Position += Vector3.new(0, -15 + v4, 0)
	Util.Misc.ScaleParticle(clone.Attachment2.Lines, 1.25)
	clone.Attachment2.Lines:Emit(10)

	for _, v7 in pairs(v6) do
		if not (v7.Object.Name == "CHARGE PART" and v7.Object.Parent.Name == "Charging" or v7.Object.Name == "Ring" and v7.Object.Parent.Name == "Attachment") then
			continue
		end

		Util.Misc.ScaleParticle(v7.Object, 2.5, v7.Data)
		v7.Object:Emit(1)
	end

	math.clamp(1 - (currentCamera.CFrame.p - clone.Position).Magnitude / 150, 0, 1)
	local shakeSustain = cameraShaker:ShakeSustain(cameraShaker.Presets.Bump4)
	local v7 = {
		Magnitude = shakeSustain.Magnitude,
		Roughness = shakeSustain.Roughness
	}
	task.delay(0.1, function()
		for _, emitter in pairs(descendants) do
			if not (emitter:IsA("ParticleEmitter") and emitter.Name == "CHARGE PART") then
				continue
			end

			if emitter:GetAttribute("EmitCount") and emitter:GetAttribute("EmitCount") == 27 then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			emitter.Enabled = true
		end
	end)
	local lastTime = tick()
	local v8 = 0
	local v9 = false

	while true do
		local now = tick()
		local v10 = now - lastTime
		local v11 = math.min(1, v10 / 0.65)
		local v12 = math.min(1, v10 / chargeTime)
		local cubic = Util.Tween.ease.inout.cubic(v12, 0, 1, 1)
		local point = Util.Tween.point(2.5, 1, cubic)

		if v10 > 3 or not holding or not holding:IsDescendantOf(workspace) or data.Status and not data.Status:IsDescendantOf(workspace) then
			break
		end

		v9 = not holding.Value or v9
		local v13 = math.clamp(1 - (currentCamera.CFrame.p - clone.Position).Magnitude / 150, 0, 1)

		for k, v14 in pairs(v7) do
			shakeSustain[k] = v14 * v13
		end

		clone.Size = createVector(1, 1, 1) * point

		for _, v14 in pairs(v6) do
			if not (v14.Object.Name == "CHARGE PART" and v14.Object.Parent.Name == "Charging" or v14.Object.Name == "Ring" and v14.Object.Parent.Name == "Attachment") then
				continue
			end

			Util.Misc.ScaleParticle(v14.Object, point, v14.Data)
		end

		if now - v8 > Util.Tween.point(0.25, 0.1, cubic) and not v9 then
			local number = random:NextNumber(0.35, 1)
			local number2 = random:NextNumber(0.35, 1)
			local number3 = random:NextNumber(0.35, 1)
			local ray = Ray.new(
				clone.Position + Vector3.new(math.random(-30, 30), 0, math.random(-30, 30)),
				createVector(0, -100, 0)
			)
			local part, position2 = game.Workspace:FindPartOnRayWithWhitelist(ray, { map })

			if part then
				local clone2 = blackHole.Part:Clone()
				clone2.Size = Vector3.new(clone2.Size.X * number, clone2.Size.Y * number2, clone2.Size.Z * number3) * point
				clone2.Position = position2
				clone2.Color = part.Color
				clone2.Smoke.Color = ColorSequence.new(part.Color)
				clone2.Smoke:Emit(5)
				clone2.Material = part.Material
				clone2.Parent = _WorldOrigin
				local vector2 = Vector3.new()
				local v16 = cubic
				Util.DistributedLoop:add(function(p, p2)
					if not clone2 or not clone2:IsDescendantOf(workspace) or clone2.Transparency == 1 then
						return true
					end

					vector2 += createVector(1, 1, 1) * (0.05 + 0.1 * v16) * p2
					clone2.CFrame *= CFrame.Angles(vector2.X, vector2.Y, vector2.Z)
				end)
				TweenInfo.new(v[3].Time * (1 - 0.75 * cubic), v[3].EasingStyle, v[3].EasingDirection)
				TweenService:Create(clone2, v[3], {
					Transparency = 1,
					Position = cFrame * Vector3.new(0, v4, 0)
				}):Play()
				debris:AddItem(clone2, 1.25)
			end

			v8 = now
		end

		if v11 == 1 and v9 then
			break
		else
			RunService.RenderStepped:Wait()
		end
	end

	local v10 = tick() - lastTime
	local v11 = math.max(0.35, clone.Boom.Star.Lifetime.Max)

	if chargeTime <= v10 then
		clone.Transparency = 1
		clone.Part.Transparency = 1
		clone.Size = createVector(1, 1, 1)

		for _, v12 in pairs(v6) do
			if not (v12.Object.Name == "CHARGE PART" and v12.Object.Parent.Name == "Charging" or v12.Object.Name == "Ring" and v12.Object.Parent.Name == "Attachment") then
				continue
			end

			Util.Misc.ScaleParticle(v12.Object, 1, v12.Data)
		end

		for _, emitter in pairs(descendants) do
			if emitter.Name == "Ring" and emitter.Parent.Name == "Attachment" then
				emitter.Enabled = false
				emitter:Clear()
			end

			if not (emitter:IsA("ParticleEmitter") and emitter.Name == "CHARGE PART") then
				continue
			end

			emitter.Enabled = false
			emitter:Clear()
		end
	else
		local v12 = math.min(1, v10 / chargeTime)
		local point = Util.Tween.point(2.5, 1, v12)
		task.spawn(function()
			local lastTime2 = tick()

			while true do
				local v13 = math.min(1, (tick() - lastTime2) / (v11 / 2))
				local quad = Util.Tween.ease.out.quad(v13, 0, 1, 1)
				local point2 = Util.Tween.point(point, 1, quad)
				clone.Size = createVector(1, 1, 1) * point2

				for _, v14 in pairs(v6) do
					if not (v14.Object.Name == "CHARGE PART" and v14.Object.Parent.Name == "Charging" or v14.Object.Name == "Ring" and v14.Object.Parent.Name == "Attachment") then
						continue
					end

					Util.Misc.ScaleParticle(v14.Object, point2, v14.Data)
				end

				if v13 == 1 then
					clone.Transparency = 1
					clone.Part.Transparency = 1
					clone.Size = createVector(1, 1, 1)

					for _, v14 in pairs(v6) do
						if not (v14.Object.Name == "CHARGE PART" and v14.Object.Parent.Name == "Charging" or v14.Object.Name == "Ring" and v14.Object.Parent.Name == "Attachment") then
							continue
						end

						Util.Misc.ScaleParticle(v14.Object, 1, v14.Data)
					end

					for _, emitter in pairs(descendants) do
						if emitter.Name == "Ring" and emitter.Parent.Name == "Attachment" then
							emitter.Enabled = false
							emitter:Clear()
						end

						if not (emitter:IsA("ParticleEmitter") and emitter.Name == "CHARGE PART") then
							continue
						end

						emitter.Enabled = false
						emitter:Clear()
					end

					break
				else
					RunService.RenderStepped:Wait()
				end
			end
		end)
	end

	sound:Play("Twinkle", clone, nil, 1)
	clone.Boom.Star:Emit(1)

	if data.Player == game.Players.LocalPlayer then
		Effect.new("Dark.Gradient"):replicate({
			Duration = v11 / 2,
			Toggle = false
		})
	end

	shakeSustain:StartFadeOut(v11 / 2)
	task.wait(v11)
	sound:Play("DarkBlackHoleExplosion", clone, nil, 1)
	sound:Play("DarkBlackHoleFlash", clone, nil, 1)

	if data.Player == game.Players.LocalPlayer then
		Effect.new("Dark.Gradient"):replicate({
			Transparency = 0.45,
			Duration = 0.35,
			Toggle = true
		})
	end

	for _, emitter in pairs(descendants) do
		if not (emitter:IsA("ParticleEmitter") and emitter.Name ~= "Lines") then
			continue
		end

		if emitter.Parent.Name == "Boom" and emitter:GetAttribute("EmitCount") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			if emitter.Name ~= "Smoke" and emitter.Name ~= "Wisp" then
				local speed = emitter.Speed
				emitter.Speed = NumberRange.new(speed.Min * 2, speed.Max * 2)
				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min * 0.5, lifetime.Max * 0.5)
			end

			emitter.Enabled = true
		end
	end

	local shakeSustain2 = cameraShaker:ShakeSustain(cameraShaker.Presets.Bump2)
	local v12 = {
		Magnitude = shakeSustain2.Magnitude,
		Roughness = shakeSustain2.Roughness
	}
	local lastTime2 = tick()

	while tick() - lastTime2 < 2 do
		local v13 = math.clamp(1 - (currentCamera.CFrame.p - clone.Position).Magnitude / 300, 0, 1)

		for k, v14 in pairs(v12) do
			shakeSustain2[k] = v14 * v13
		end

		RunService.RenderStepped:Wait()
	end

	shakeSustain2:StartFadeOut(1)

	for _, emitter in pairs(descendants) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.wait(0.5)

	if data.Player == game.Players.LocalPlayer then
		Effect.new("Dark.Gradient"):replicate({
			Duration = 0.35,
			Toggle = false
		})
	end

	TweenService:Create(clone, v[1], {
		Transparency = 1
	}):Play()
	debris:AddItem(clone, 1.5)
	v6 = {}
end