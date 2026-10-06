local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)

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
	local _ = data.cf
	local localPlayer = game.Players.LocalPlayer

	-- equivalent calls inferred from this helper; original call sites unknown
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

	local charge = data.charge
	local char = data.char
	local root = data.root
	local _ = data.hum
	local lastTime = tick()
	local lastTime2 = tick()
	local cFrame = root.CFrame
	local clone = ReplicatedStorage.Chest.FruitEffect.Love.Awake.spin_kick_1:Clone()
	_G.PU:Dust(clone, 4)
	clone.CFrame = CFrame.new(cFrame.p)
	clone.Anchored = true
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 900,
		RollOffMinDistance = 0,
		RollOffMode = Enum.RollOffMode.Linear,
		SoundId = "rbxassetid://15693831943",
		Volume = 4.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.spin_kick_2:Clone()
	_G.PU:Dust(clone2, 4)
	clone2.CFrame = CFrame.new(cFrame.p)
	clone2.Anchored = true
	clone2.Parent = workspace.Effects

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local pointLight = Instance.new("PointLight")
	pointLight.Parent = clone
	pointLight.Color = Color3.fromRGB(234, 71, 255)
	pointLight.Range = 0
	pointLight.Brightness = 0.25
	_G.PU:Dust(pointLight, 4)
	TweenService:Create(pointLight, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 1,
		Range = 60
	}):Play()
	PeodizService.new({
		Time = 2
	}, function()
		if not charge:IsDescendantOf(char) or char.Humanoid.Health <= 0 then
			return true
		end

		if tick() - lastTime > 0.1 then
			lastTime = tick()
			localshake({
				3,
				5,
				0,
				0.75
			}) -- equivalent call inferred; original call site unknown
		end

		cFrame = root.CFrame
		clone.CFrame = CFrame.new(cFrame.p)
		clone2.CFrame = CFrame.new(cFrame.p) * CFrame.Angles(0, math.rad((tick() - lastTime2) * 55), 0)
	end)

	if sound and sound.Parent then
		sound:Stop()
	end

	TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = 0
	}):Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	local clone3 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.v_emit:Clone()
	clone3.Parent = workspace.Effects
	clone3.CFrame = cFrame
	_G.PU:Dust(clone3, 1.5)

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	wait(0.05)
	local v = {
		12,
		20,
		0,
		1
	}
	local v2 = 90
	local p = cFrame.p
	task.spawn(function()
		v2 = v2 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v2 then
			_G.shake(v)
		end
	end)

	if localPlayer == data.plr then
		bloomBlur()
	end

	for i = 1, 5 do
		local v3 = i
		task.spawn(function()
			local orientation, v4, v5 = cFrame:ToOrientation()
			local cFrame2 = CFrame.new(cFrame.p) * CFrame.fromOrientation(0, v4, 0) * CFrame.Angles(
				0,
				1.2566370614359172 * v3,
				0
			) * CFrame.new(0, 0, -10)
			local clone4 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.v_thrust.trail:Clone()
			_G.PU:Dust(clone4, 1)
			clone4.h1.Enabled = true
			clone4.h2.Enabled = true
			clone4.shockring.Enabled = true
			clone4.ShardsFlying.Enabled = true
			clone4.ShardsFlying2.Enabled = true
			clone4.Circles.Enabled = true
			clone4.CirclesB.Enabled = true
			clone4.Specs.Enabled = true
			clone4.CFrame = cFrame2
			clone4.Parent = workspace.Effects
			local clone5 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.v_thrust.trhust:Clone()
			clone5.Parent = workspace.Effects
			clone5.Mesh.Scale = createVector(1.25, 2.5, 1.25)
			clone5.CFrame = cFrame2 * CFrame.new(0, 0, -20) * CFrame.Angles(-1.5707963267948966, 0, 0)
			local Animate = require(clone5.Animate)
			Animate()
			_G.PU:Dust(clone5, 1)
			task.spawn(function()
				clone5.Neon.Color3 = Color3.fromRGB(800, 150, 406)
				wait(0.05)
				TweenService:Create(
					clone5.Neon,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Color3 = Color3.fromRGB(820, 180, 500)
					}
				):Play()
				TweenService:Create(
					clone5.Mesh,
					TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Scale = createVector(0.7, 1.8, 0.7)
					}
				):Play()
			end)
			TweenService:Create(clone5, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone5.CFrame * CFrame.new(0, 80, 0)
			}):Play()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15702685639",
				Volume = 5
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone4
			sound2:Play()

			for i2 = 1, 4 do
				cFrame2 *= CFrame.new(0, 0, -30)
				TweenService:Create(
					clone4,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = cFrame2 * CFrame.new(0, 0, -5)
					}
				):Play()
				task.wait(0.029)
				clone4.shards2:Emit(5)
				clone4.shards3:Emit(3)
				clone4.Wave1:Emit(math.random(1, 2))
				clone4.Wave12B:Emit(1)
				clone4.Wave2:Emit(math.random(1, 2))
				clone4.shockring:Emit(1)
			end

			wait(0.1)
			clone4.h1.Enabled = false
			clone4.h2.Enabled = false
			clone4.shockring.Enabled = false
			clone4.ShardsFlying.Enabled = false
			clone4.ShardsFlying2.Enabled = false
			clone4.Circles.Enabled = false
			clone4.CirclesB.Enabled = false
			clone4.Specs.Enabled = false
			TweenService:Create(
				clone4.PointLight,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Range = 0
				}
			):Play()
		end)
	end
end