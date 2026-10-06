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

	local root = data.root
	tick()
	local cFrame = root.CFrame
	local char = data.char
	local mouseFolder = data.MouseFolder
	local clone = ReplicatedStorage.Chest.FruitEffect.Snow.boomerang:Clone()
	clone.CFrame = cFrame
	clone.Parent = workspace.Effects
	clone.Size = Vector3.new()
	_G.PU:Dust(clone, 2)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 50,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15808458399",
		Volume = 1.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Snow.boomerang_follow:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = workspace.Effects
	clone2.Size = createVector(46.354, 1.449, 46.354)
	_G.PU:Dust(clone2, 2)
	local v = 0
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(46.354, 1.449, 46.354)
	}):Play()
	task.spawn(function()
		wait(0.125)
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(69.531, 2.1735, 69.531)
		}):Play()
	end)
	wait()
	task.spawn(function()
		PeodizService.new({
			Time = 1.25,
			Tween = {
				EasingStyle = Enum.EasingStyle.Quad,
				EasingDirection = Enum.EasingDirection.Out
			}
		}, function(p)
			v = p * 179
		end)
	end)
	task.spawn(function()
		if sound then
			sound:Stop()
		end

		wait(1)
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 50,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://15808452043",
			Volume = 1
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone
		sound2:Play()
		localshake({
			10,
			10,
			0,
			0.5
		}) -- equivalent call inferred; original call site unknown
		clone2.Sparks:Emit(10)
		clone2.shockring:Emit(5)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
	end)
	local v2 = 1
	local lastTime = tick()
	localshake({
		11,
		11,
		0,
		1
	}) -- equivalent call inferred; original call site unknown
	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Value = cFrame.p
	PeodizService.new({
		Time = 1
	}, function()
		v2 += 1
		TweenService:Create(vector3Value, TweenInfo.new(0.1), {
			Value = mouseFolder.Value
		}):Play()

		if char.Humanoid.Health <= 0 then
			return true
		end

		cFrame = CFrame.new(root.CFrame.p, vector3Value.Value)
		clone2.CFrame = cFrame * CFrame.new(0, 0, math.sin((math.rad(v))) * -150)
		clone.CFrame = cFrame * CFrame.new(0, 0, math.sin((math.rad(v))) * -150) * CFrame.Angles(
			0,
			math.rad(tick() - lastTime) * 800,
			0
		)
	end)
end