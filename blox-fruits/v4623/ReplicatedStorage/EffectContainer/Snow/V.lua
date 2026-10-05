local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local Util = require(game.ReplicatedStorage.Util)
require(game.ReplicatedStorage.Util.ScaleParticle)
local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
local VignetteService = require(game.ReplicatedStorage.Util.VignetteService)
local BoatTween = require(game.ReplicatedStorage.Util.BoatTween)
local Effect = require(game.ReplicatedStorage.Effect)
local colorCorrection = Effect.new("ColorCorrection")
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
local v = {
	TweenInfo.new(6, Enum.EasingStyle.Linear),
	TweenInfo.new(1, Enum.EasingStyle.Sine),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
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

local function ScaleParticle(emitter, p)
	local keypoints = emitter.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	emitter.Size = NumberSequence.new(numberSequenceKeypoints)
	emitter.Speed = NumberRange.new(emitter.Speed.Min * p, emitter.Speed.Max * p)
	emitter.Acceleration *= p
end

for _, emitter in pairs(script.Model.Area.Emit:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		ScaleParticle(emitter, 1.75)
	end
end

return function(player)
	local humanoidRootPart = player.Character.HumanoidRootPart
	local vignettesByVignette = {}

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 2000 then
		return
	end

	local position = humanoidRootPart.Position

	for i = 1, 9 do
		local v2 = i / 9

		if (workspace.CurrentCamera.CFrame.Position - position).magnitude < 150 and i % 3 == 0 then
			CameraShaker:ShakeOnce(v2 * 12, v2 * 10, v2 * 0.5, v2 * 1.25)
		end

		local clone = script.FireBrush:Clone()
		clone.CFrame = CFrame.new(position)
		clone.Parent = _WorldOrigin
		local v3 = i
		task.spawn(function()
			local cframe = CFrame.Angles(0, v3 / 6 * 3.141592653589793 * 2, 0)
			local v5 = 38 * (0.8 + math.random() * 0.4)
			local lastTime = tick()

			while tick() - lastTime < 0.66 do
				local v6 = (tick() - lastTime) / 0.66
				clone.CFrame = CFrame.new(humanoidRootPart.Position) * cframe * CFrame.Angles(
					0,
					6.283185307179586 * v6,
					0
				) * CFrame.new(0, v5 * 0.1 * 1 * (1 - v6) * v3, v5 * (1 - v6) * (v3 / 3 + 1))
				task.wait()
			end

			for i2, emitter in pairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(1)
			clone:Destroy()
		end)
	end

	local clone = script.Blur:Clone()
	clone.Size = 0
	clone.Parent = game.Lighting
	local v2 = false

	for i = 1, 2 do
		local vignette = VignetteService:CreateVignette({ script["ParticleEmitter" .. i]:Clone() })
		vignette:UpdateEnabled(false)
		vignette:Enabled(false)
		vignettesByVignette[vignette] = vignette
	end

	local clone2 = script.Base:Clone()
	clone2.CFrame = CFrame.new(position) * CFrame.new(0, -1.5, 0)
	clone2.Parent = _WorldOrigin
	Util.Sound:Play("BlizV", position, nil, 2)
	task.wait(0.5)
	Util.Sound:Play("ColdGust", position, nil, 0.5)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.wait(0.25)
	local cFrame = CFrame.new(position) * CFrame.new(0, -2, 0)
	local model = script.Model
	local clone3 = model:Clone()
	clone3.Name = clone3.Name

	if model:IsA("Model") then
		clone3:SetPrimaryPartCFrame(cFrame)
	else
		clone3.CFrame = cFrame
	end

	clone3.Parent = _WorldOrigin
	local descendants = clone3:GetDescendants()

	for _, child in pairs(clone3.Area.Emit:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	if (workspace.CurrentCamera.CFrame.Position - position).magnitude < 225 then
		colorCorrection:replicate({
			TintColor = Color3.fromRGB(152, 194, 219),
			Saturation = -2,
			Brightness = 1.25,
			Contrast = 1,
			FadeIn = 0.05,
			Lifetime = 0.15,
			FadeOut = 0.1
		})
		CameraShaker:ShakeOnce(20, 22, 0, 4)
	end

	local v4 = Util.Sound:Play("WindTunnelLoop", position, nil, 1.25)
	local flag = true
	task.spawn(function()
		for i = 1, 30 do
			local ResizeModel = require(game.ReplicatedStorage.Util.ResizeModel)
			ResizeModel(clone3, (1 - i / 30 * 0.1) * 1.11)
			task.wait()
		end

		local size = clone3.Area.Size
		local total = 0

		while flag do
			total += task.wait()
			clone3.Area.Size = size + createVector(1, 1, 1) * math.sin(total * 4) * 6
		end
	end)
	task.spawn(function()
		while wait(0.2) and flag do
			local v5 = (workspace.CurrentCamera.CFrame.Position - clone3.Area.Position).magnitude < clone3.Area.Size.X / 2

			if v2 and not v5 then
				v2 = false

				for _, v6 in pairs(vignettesByVignette) do
					v6:Enabled(false)
					v6:UpdateEnabled(false)
				end

				TweenService:Create(clone, v[3], {
					Size = 0
				}):Play()
			elseif v5 and not v2 then
				v2 = true

				for _, v6 in pairs(vignettesByVignette) do
					v6:Enabled(true)
					v6:UpdateEnabled(true)
				end

				TweenService:Create(clone, v[3], {
					Size = 7
				}):Play()
			end
		end
	end)
	local random = Random.new()
	local v5 = 10 + random:NextNumber(0, 2)
	local primaryPart = clone3.PrimaryPart
	local magnitude = primaryPart.Size.Magnitude
	local v6 = {}
	local v7 = {}
	local times = {}
	local nows = {}
	local v8 = {}
	local v9 = {}
	local v10 = {}

	for i = 1, v5 do
		local number = random:NextNumber(-1, 1)
		local number2 = random:NextNumber(-0.25, 1)
		local number3 = random:NextNumber(-1, 1)
		local clone4 = script.SnowCloud:Clone()
		local color = clone4.Color
		local size = clone4:GetAttribute("Size") * random:NextNumber(0.5, 2) * magnitude / 2.5
		local v12 = primaryPart.CFrame * Vector3.new(
			magnitude * 0.75 * math.cos(6.283185307179586 * number),
			magnitude / 4 * number2 * 1.1,
			magnitude * 0.75 * math.sin(6.283185307179586 * number3)
		)
		local cframe = CFrame.Angles(
			0.5235987755982988 * random:NextNumber(-1, 1),
			0.5235987755982988 * random:NextNumber(-1, 1),
			0.5235987755982988 * random:NextNumber(-1, 1)
		)
		local v13 = CFrame.new(v12, primaryPart.Position) * cframe
		clone4.Name = i
		clone4.Transparency = 1
		clone4.Size = size * 0
		clone4.CFrame = primaryPart.CFrame * cframe
		clone4.Parent = _WorldOrigin
		v6[i] = size
		v7[i] = primaryPart.CFrame:ToObjectSpace(v13)
		local tween = TweenService:Create(
			clone4,
			TweenInfo.new(random:NextNumber(0.25, 0.5) / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = size,
				Transparency = 0,
				Color = color:Lerp(Color3.new(1, 1, 1), random:NextNumber(0, 0.5))
			}
		)
		tween:Play()
		times[i] = tween.TweenInfo.Time
		nows[i] = tick()

		for _, child in pairs(clone4:GetChildren()) do
			Util.Misc.ScaleParticle(child, size.Magnitude * 0.75)
			child.Enabled = true
			child.Rate *= 0.1
		end

		table.insert(v8, clone4)
	end

	task.spawn(function()
		for k, _ in pairs(v8) do
			v9[k] = random:NextNumber(0.25, 0.75)
			v10[k] = random:NextNumber(0, 1) * 2 * 3.141592653589793
		end

		local _ = primaryPart.CFrame
		local v11 = 0.016666666666666666

		while #v8 > 0 do
			local lastTime = tick()
			local v12 = primaryPart.CFrame * CFrame.new(0, primaryPart.Size.Y / 2.5, 0)

			for _, v13 in pairs(v8) do
				local name = tonumber(v13.Name)
				v10[name] += 1.5707963267948966 * v9[name] * v11
				local vector2

				if name % 3 == 0 then
					vector2 = Vector3.new(math.cos(v10[name]), 0, (math.sin(v10[name])))
				elseif name % 2 == 0 then
					vector2 = Vector3.new(math.sin(v10[name]), 0, (math.cos(v10[name])))
				else
					vector2 = Vector3.new(math.cos(v10[name]), (math.sin(v10[name])))
				end

				local v14 = math.min(1, (lastTime - nows[name]) / times[name]) + 0.01
				local v15 = math.clamp((lastTime - nows[name] - times[name]) / 0.25, 0, 1)
				v13.Size = v6[name] * (1 - math.sin(v10[name]) * 0.25 * v15)
				local v16 = v12 * (v7[name].Position / 2 * v14 + v7[name].Position / 4 * vector2 * v14)
				v13.CFrame = CFrame.new(v16, v12.p) * v7[name]
			end

			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Wait()
			v11 = tick() - lastTime
		end

		v6 = {}
		v7 = {}
		v9 = {}
		v10 = {}
		nows = {}
		times = {}
	end)
	task.wait(7.5)
	Util.Sound:FadeOut(v4, 0.25)
	Util.Sound:Play("BlizzardEnd", position, nil, 0.5)
	clone2:Destroy()
	flag = false

	for _, v11 in pairs(v8) do
		for _, child in pairs(v11:GetChildren()) do
			child.Enabled = false
		end

		local name = tonumber(v11.Name)
		local tween = TweenService:Create(
			v11,
			TweenInfo.new(random:NextNumber(0.75, 1.5), Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		)
		tween:Play()
		local v13 = v11
		task.delay(tween.TweenInfo.Time, function()
			v8[name] = nil
			v13:Destroy()
		end)
	end

	for _, v11 in pairs(vignettesByVignette) do
		v11:Enabled(false)
		v11:UpdateEnabled(false)
	end

	task.delay(0.4, function()
		for _, v11 in pairs(vignettesByVignette) do
			v11:Destroy()
		end

		TweenService:Create(clone, v[2], {
			Size = 0
		}):Play()
		Debris:AddItem(clone, 0.6)
	end)
	TweenService:Create(clone3.Area, v[2], {
		Transparency = 1
	}):Play()

	for _, instance in pairs(descendants) do
		if instance:IsA("ParticleEmitter") then
			instance.Enabled = false
		elseif instance:IsA("Beam") then
			BoatTween:Create(instance, {
				Time = 1,
				EasingStyle = "Sine",
				EasingDirection = "Out",
				StepType = "Heartbeat",
				Goal = {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 1)
					})
				}
			}):Play()
		elseif instance:IsA("PointLight") then
			TweenService:Create(instance, v[2], {
				Range = 0,
				Brightness = 0
			}):Play()
		end
	end

	Debris:AddItem(clone3, 1.5)
end