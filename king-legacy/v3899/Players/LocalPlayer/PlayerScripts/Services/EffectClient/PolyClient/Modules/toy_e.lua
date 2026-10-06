-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)

local function tween_beam_transparency(items, p, p2, p3, time)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = p
	TweenService:Create(numberValue, p3, {
		Value = p2
	}):Play()
	PeodizService.new({
		Time = time
	}, function()
		for _, item in pairs(items) do
			item.Transparency = NumberSequence.new(numberValue.Value)
		end
	end)

	if numberValue then
		numberValue:Destroy()
	end
end

function ImpactFrame(_, value)
	local v = value or 0.06
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.TintColor = Color3.new(0, 0, 0)
	colorCorrectionEffect.Brightness = 1
	task.delay(v * 0.5, function()
		TweenService:Create(colorCorrectionEffect, TweenInfo.new(v), {
			TintColor = Color3.new(0.4, 0.4, 0.4)
		}):Play()
	end)
	colorCorrectionEffect.Parent = game.Lighting
	_G.PU:Dust(colorCorrectionEffect, v)
end

function bloomBlur()
	local blurEffect = Instance.new("BlurEffect", game.Lighting)
	blurEffect.Size = 0
	local bloomEffect = Instance.new("BloomEffect", game.Lighting)
	_G.PU:Dust(blurEffect, 0.2)
	_G.PU:Dust(bloomEffect, 0.2)
	TweenService:Create(blurEffect, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0), {
		Size = 4
	}):Play()
	TweenService:Create(bloomEffect, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0), {
		Intensity = 3,
		Size = 35,
		Threshold = 1
	}):Play()
end

return function(data)
	local cf = data.cf
	local root = data.root
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - data.cf.p).Magnitude then
			_G.shake(p)
		end
	end

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	local char = data.char
	local _ = data.dinocolor
	local cFrame = root.CFrame
	local clone = ReplicatedStorage.Chest.FruitEffect.Toy.dino_transfrom:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = cFrame * CFrame.new(0, -2, 0) or cf
	_G.PU:Dust(clone, 3)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local lastTime = tick()
	PeodizService.ForLoop({
		Step = 40
	}, function(_)
		if tick() - lastTime > 0.1 then
			lastTime = tick()
			local v = {
				8,
				8,
				0,
				0.75
			}
			local v2 = 90
			local p = cf.p
			task.spawn(function()
				v2 = v2 or 100

				if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v2 then
					_G.shake(v)
				end
			end)
		end

		cf = root.CFrame * CFrame.new(0, -2, 0) or data.cf
		local v = cf * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) * CFrame.new(0, 0, math.random(55, 65))
		local magnitude = (cf.p - v.p).magnitude
		local v2 = CFrame.new(v.p, cf.p) * CFrame.new(0, 0, -magnitude)
		local v3 = CFrame.new(v.p, cf.p) * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(
			6.283185307179586 * math.random(),
			0,
			0
		) * CFrame.new(0, math.random(30, 60), 0)
		local cframe = CFrame.new(v.p, cf.p)
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.Parts:GetChildren()[math.random(1, 6)]:Clone()
		clone2.CFrame = cframe
		clone2.Parent = workspace.Effects
		local size = clone2.Size
		clone2.Size = Vector3.new()
		_G.PU:Dust(clone2, 1)
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = size * math.random(30, 40) / 10
		}):Play()
		task.spawn(function()
			PeodizService.HeartbeatWait({
				Time = 0.25,
				Tween = {
					EasingStyle = Enum.EasingStyle.Quad,
					EasingDirection = Enum.EasingDirection.Out
				}
			}, function(p)
				clone2.Position = bezier(math.floor(p * 100) / 100, cframe.p, v3.p, v2.p)
			end)
		end)
		task.spawn(function()
			wait(0.35)
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
		end)
		wait()
	end)
	local v = {
		15,
		20,
		0,
		2
	}
	local v2 = 90
	local p = cf.p
	task.spawn(function()
		v2 = v2 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v2 then
			_G.shake(v)
		end
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	if localPlayer == data.plr then
		bloomBlur()
		ImpactFrame({ char }, 0.175)
	end

	local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_transfrom2:Clone()
	clone2.Parent = workspace.Effects
	clone2.CFrame = cFrame * CFrame.new(0, -2, 0) or cf
	_G.PU:Dust(clone2, 2)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		local v3 = emitter
		task.spawn(function()
			wait(0.5)
			v3.Enabled = false
		end)
	end

	wait(0.14)
	task.spawn(function()
		PeodizService.ForLoop({
			Step = 23
		}, function(p2)
			math.floor(p2 * 23)
			local v3 = CFrame.new(cf.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.Angles(
				3.9269908169872414 * math.random(),
				0,
				0
			) * CFrame.new(0, 0, -math.random(55, 75))
			local magnitude = (cf.p - v3.p).magnitude
			local v4 = CFrame.new(v3.p, cf.p) * CFrame.new(0, 0, -magnitude)
			local v5 = CFrame.new(v3.p, cf.p) * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(
				6.283185307179586 * math.random(),
				0,
				0
			) * CFrame.new(0, math.random(30, 60), 0)
			local cframe = CFrame.new(v3.p, cf.p)
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Toy.Parts:GetChildren()[math.random(1, 6)]:Clone()
			clone3.CFrame = cframe
			clone3.Parent = workspace.Effects
			local v6 = clone3.Size * 1.5
			clone3.Size = Vector3.new()
			_G.PU:Dust(clone3, 0.75)
			TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = v6 * math.random(30, 40) / 10
			}):Play()

			for _, child in pairs(ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.FlyRock:GetChildren()) do
				local clone = child:Clone()
				clone.Parent = clone3
			end

			clone3.AT1.Trail.Attachment0 = clone3.AT1
			clone3.AT1.Trail.Attachment1 = clone3.AT2
			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 0.25,
					Tween = {
						EasingStyle = Enum.EasingStyle.Quad,
						EasingDirection = Enum.EasingDirection.Out
					}
				}, function(p3)
					clone3.Position = bezier(math.floor(p3 * 50) / 50, v4.p, v5.p, cframe.p)
				end)
			end)
			task.spawn(function()
				wait(0.25)
				TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = Vector3.new()
				}):Play()
			end)
		end)
	end)
end