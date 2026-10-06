local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)

local function tween_beam_transparency(items, p, p2, p3, time)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = p
	TweenService:Create(numberValue, p3, {
		Value = p2
	}):Play()
	PeodizService.HeartbeatWait({
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

	local function shoot(p)
		local clone = ReplicatedStorage.Chest.FruitEffect.Love.Awake.c_kick.heart_in:Clone()
		_G.PU:Dust(clone, 1)
		clone.CFrame = p * CFrame.Angles(0, 1.5707963267948966, 0)
		clone.Parent = workspace.Effects
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.c_kick.heart_out:Clone()
		_G.PU:Dust(clone2, 1)
		clone2.Parent = workspace.Effects
		clone2.CFrame = p * CFrame.Angles(0, 1.5707963267948966, 0)
		clone.Size = Vector3.new()
		clone2.Size = Vector3.new()
		clone2.Color = Color3.fromRGB(255, 158, 253)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://15756398784",
			Volume = 5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = p * CFrame.new(0, 0, 2) * CFrame.Angles(0, 1.5707963267948966, 0)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = p * CFrame.new(0, 0, 2) * CFrame.Angles(0, 1.5707963267948966, 0),
			Color = Color3.fromRGB(255, 89, 247)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(1.2049999, 19.1975, 21.970001)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(1.2049999, 19.1975, 21.970001)
		}):Play()
		task.spawn(function()
			wait(0.2)
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
		end)
	end

	local clone = ReplicatedStorage.Chest.FruitEffect.Love.Awake.c_kick.c_emit:Clone()
	_G.PU:Dust(clone, 1)
	clone.CFrame = cFrame
	clone.Parent = workspace.Effects
	local count = 0
	local v = {}

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	wait()
	localshake({
		10,
		10,
		0,
		1
	}) -- equivalent call inferred; original call site unknown
	PeodizService.HeartbeatWait({
		Time = 2
	}, function()
		if not charge:IsDescendantOf(char) or char.Humanoid.Health <= 0 then
			return true
		end

		if tick() - lastTime > 0.1 then
			lastTime = tick()
			localshake({
				2,
				4,
				0,
				0.75
			}) -- equivalent call inferred; original call site unknown
		end

		if tick() - lastTime2 > wait() then
			lastTime2 = tick()
			count += 1
			cFrame = root.CFrame
			local v3 = cFrame
			local v4 = CFrame.new(v3.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.Angles(
				6.283185307179586 * math.random(),
				0,
				0
			) * CFrame.new(0, 0, -40)
			v[#v + 1] = v4

			if v[count - 1] ~= nil then
				local v5 = v[count - 1]
				local v6 = v[count]
				local magnitude = (v5.p - v6.p).magnitude
				local part = Instance.new("Part")
				part.CFrame = CFrame.new(v5.p, v6.p)
				part.Size = createVector(4, 4, 0)
				part.Color = Color3.fromRGB(255, 158, 253)
				part.Material = Enum.Material.Neon
				part.CanCollide = false
				part.Anchored = true
				part.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = Vector3.new(2, 2, magnitude),
					CFrame = part.CFrame * CFrame.new(0, 0, -magnitude / 2)
				}):Play()
				task.spawn(function()
					wait(0.1)
					TweenService:Create(
						part,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Color = Color3.fromRGB(255, 89, 247)
						}
					):Play()
					TweenService:Create(
						part,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(0, 0, magnitude)
						}
					):Play()
				end)
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.c_kick.thrust:Clone()
				clone2.Parent = workspace.Effects
				clone2.Mesh.Scale = createVector(0.652, 1.044, 0.652)
				clone2.CFrame = CFrame.new(v5.p, v6.p) * CFrame.new(0, 0, 10) * CFrame.Angles(-1.5707963267948966, 0, 0)
				local Animate = require(clone2.Animate)
				Animate()
				_G.PU:Dust(clone2, 1)
				TweenService:Create(
					clone2.PointLight,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Range = 0
					}
				):Play()
				TweenService:Create(
					clone2,
					TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone2.CFrame * CFrame.new(0, magnitude, 0)
					}
				):Play()
				clone2.Circles.Enabled = true
				clone2.CirclesB.Enabled = true
				clone2.shards2:Emit(5)
				task.spawn(function()
					clone2.Neon.Color3 = Color3.fromRGB(800, 150, 406)
					wait(0.05)
					TweenService:Create(
						clone2.Neon,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Color3 = Color3.fromRGB(820, 180, 500)
						}
					):Play()
					TweenService:Create(
						clone2.Mesh,
						TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Scale = createVector(0.5, 0.9, 0.5)
						}
					):Play()
					wait(0.1)
					clone2.Circles.Enabled = false
					clone2.CirclesB.Enabled = false
				end)
				_G.PU:Dust(part, 0.5)
			end

			shoot(CFrame.new(v4.p, v3.p) * CFrame.new(0, 0, math.random(-2, 2)))
		end
	end)
	task.delay(10, function()
		table.clear(v)
	end)
	wait()
	localshake({
		10,
		10,
		0,
		1
	}) -- equivalent call inferred; original call site unknown
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.c_kick.c_emit:Clone()
	_G.PU:Dust(clone2, 1)
	clone2.CFrame = cFrame
	clone2.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15632846068",
		Volume = 5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end
end