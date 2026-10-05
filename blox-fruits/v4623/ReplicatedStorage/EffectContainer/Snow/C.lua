local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local Util = require(game.ReplicatedStorage.Util)
require(game.ReplicatedStorage.Util.ScaleParticle)
local BoatTween = require(game.ReplicatedStorage.Util.BoatTween)
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
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(2, Enum.EasingStyle.Sine)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
return function(player)
	local _ = player.Character.HumanoidRootPart
	local v2 = player.Position + createVector(0, 1, 0)

	if (workspace.CurrentCamera.CFrame.Position - v2).magnitude > 1000 then
		return
	end

	local random = Random.new()
	local cframe = CFrame.new(v2 + createVector(0, 83, 0))
	local clone = script.Cloud:Clone()
	clone.Name = clone.Name
	clone.CFrame = cframe
	clone.Parent = _WorldOrigin
	local v3 = 7 + random:NextInteger(0, 1)
	local v4 = clone.Size.Magnitude / 4
	local v5 = {}
	local v6 = {}
	local times = {}
	local nows = {}
	local v7 = {}
	local v8 = {}
	local v9 = {}

	for i = 1, v3 do
		local number = random:NextNumber(-1, 1)
		local number2 = random:NextNumber(-0.25, 1)
		local number3 = random:NextNumber(-1, 1)
		local clone2 = script.SnowCloud:Clone()
		local color = clone2.Color
		local size = clone2:GetAttribute("Size") * random:NextNumber(0.6, 2.1) * v4 / 2
		local v11 = clone.CFrame * Vector3.new(
			v4 * 0.75 * math.cos(6.283185307179586 * number),
			v4 / 4 * number2 * 1.1,
			v4 * 0.75 * math.sin(6.283185307179586 * number3)
		)
		local cframe2 = CFrame.Angles(
			0.5235987755982988 * random:NextNumber(-1, 1),
			0.5235987755982988 * random:NextNumber(-1, 1),
			0.5235987755982988 * random:NextNumber(-1, 1)
		)
		local v12 = CFrame.new(v11, clone.Position) * cframe2
		clone2.Name = i
		clone2.Transparency = 1
		clone2.Size = size * 0
		clone2.CFrame = clone.CFrame * cframe2
		clone2.Parent = _WorldOrigin
		v5[i] = size
		v6[i] = clone.CFrame:ToObjectSpace(v12)
		local tween = TweenService:Create(
			clone2,
			TweenInfo.new(random:NextNumber(0.25, 0.75), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			{
				Size = size,
				Transparency = 0,
				Color = color:Lerp(Color3.new(1, 1, 1), random:NextNumber(0, 0.5))
			}
		)
		tween:Play()
		times[i] = tween.TweenInfo.Time
		nows[i] = tick()

		for _, child in pairs(clone2:GetChildren()) do
			Util.Misc.ScaleParticle(child, size.Magnitude * 0.75)
			child.Enabled = true
			child.Rate *= 0.8
		end

		table.insert(v7, clone2)
	end

	task.spawn(function()
		for k, _ in pairs(v7) do
			v8[k] = random:NextNumber(0.5, 2)
			v9[k] = random:NextNumber(0, 1) * 2 * 3.141592653589793
		end

		local _ = clone.CFrame
		local v10 = 0.016666666666666666

		while #v7 > 0 do
			local lastTime = tick()
			local cFrame = clone.CFrame

			for _, v11 in pairs(v7) do
				local name = tonumber(v11.Name)
				v9[name] += 1.5707963267948966 * v8[name] * v10
				local vector2

				if name % 3 == 0 then
					vector2 = Vector3.new(math.cos(v9[name]), 0, (math.sin(v9[name])))
				elseif name % 2 == 0 then
					vector2 = Vector3.new(math.sin(v9[name]), 0, (math.cos(v9[name])))
				else
					vector2 = Vector3.new(math.cos(v9[name]), (math.sin(v9[name])))
				end

				local v12 = math.min(1, (lastTime - nows[name]) / times[name]) + 0.01
				local v13 = math.clamp((lastTime - nows[name] - times[name]) / 0.25, 0, 1)
				v11.Size = v5[name] * (1 - math.sin(v9[name]) * 0.25 * v13)
				local v14 = cFrame * (v6[name].Position / 2 * v12 + v6[name].Position / 3 * vector2 * v12)
				v11.CFrame = CFrame.new(v14, cFrame.p) * v6[name]
			end

			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Wait()
			v10 = tick() - lastTime
		end

		v5 = {}
		v6 = {}
		v8 = {}
		v9 = {}
		nows = {}
		times = {}
	end)
	Util.Sound:Play("IceStart", clone, nil, 1)
	task.wait(0.21)
	local cframe2 = CFrame.new(v2 + createVector(0, 60, 0))
	local clone2 = script.Downpour:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cframe2
	clone2.Parent = _WorldOrigin
	clone2.Emit.Start1:Emit(20)

	for _, child in pairs(clone2.Emit:GetChildren()) do
		child.Enabled = true
	end

	local folder = nil
	task.spawn(function()
		local cframe3 = CFrame.new(v2 + createVector(0, 30, 0))
		local clone3 = script.SnowSpin:Clone()
		clone3.Name = clone3.Name
		clone3.CFrame = cframe3
		clone3.Parent = _WorldOrigin
		folder = clone3

		while folder ~= nil and folder.Parent ~= nil do
			tick()
			folder.CFrame *= CFrame.Angles(0, -0.2617993877991494, 0)
			task.wait()
		end
	end)

	if (workspace.CurrentCamera.CFrame.Position - v2).magnitude < 120 then
		CameraShaker:ShakeOnce(19, 14, 0, 2.5)
		local clone3 = script.Blur:Clone()
		clone3.Parent = game.Lighting
		TweenService:Create(clone3, v[1], {
			Size = 7
		}):Play()
		task.delay(3, function()
			TweenService:Create(clone3, v[2], {
				Size = 0
			}):Play()
			Debris:AddItem(clone3, 2)
		end)
	end

	local cframe3 = CFrame.new(v2 + createVector(0, 0.5, 0))
	local clone3 = script.Ground:Clone()
	clone3.Name = clone3.Name
	clone3.CFrame = cframe3
	clone3.Parent = _WorldOrigin

	for _, child in pairs(clone3.Explosion:GetChildren()) do
		local lifetime = child.Lifetime
		child.Lifetime = NumberRange.new(lifetime.Min * 2, lifetime.Max * 2)
		child:Emit(child:GetAttribute("EmitCount"))
	end

	clone3.Spikes:Emit(20)
	local v10 = Util.Sound:Play("WindTunnelLoop", clone, nil, 1)
	task.wait(1)

	for _, beam in pairs(folder:GetDescendants()) do
		if beam:IsA("Beam") then
			BoatTween:Create(beam, {
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
		end
	end

	Debris:AddItem(folder, 1)
	task.wait(0.5)
	Util.Sound:FadeOut(v10, 0.5)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	Debris:AddItem(clone, 3)
	task.wait(0.1)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	Debris:AddItem(clone2, 1)
	task.wait(0.1)

	for _, descendant in pairs(clone3:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		elseif descendant:IsA("PointLight") then
			TweenService:Create(descendant, v[2], {
				Range = 0,
				Brightness = 0
			}):Play()
		end
	end

	Debris:AddItem(clone3, 1)
	task.wait(0.8)

	for _, v11 in pairs(v7) do
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
			v7[name] = nil
			v13:Destroy()
		end)
	end
end