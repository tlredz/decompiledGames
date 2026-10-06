local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)

local function tween_beam_transparency(items, p, p2, tweenInfo, time)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = p
	TweenService:Create(numberValue, tweenInfo, {
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
	local hum = data.hum
	tick()
	local cFrame = root.CFrame
	local clone = ReplicatedStorage.Chest.FruitEffect.Love.Awake.LoveBow:Clone()
	clone:SetPrimaryPartCFrame(cFrame)
	clone.Parent = char
	_G.PU:Dust(clone, 12)
	local motor6D = Instance.new("Motor6D")
	motor6D.Parent = root
	motor6D.Name = "bow"
	motor6D.Part0 = root
	motor6D.Part1 = clone.PrimaryPart
	local arrow = clone.arrow
	local bow = clone.bow
	arrow.Size = Vector3.new()
	bow.Size = Vector3.new()
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15632846068",
		Volume = 4.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = bow
	sound:Play()
	TweenService:Create(arrow, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(2.279, 16.158, 3.256)
	}):Play()
	TweenService:Create(bow, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(1.148, 21.44, 7.697)
	}):Play()

	for _, emitter in pairs(arrow:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	for _, emitter in pairs(bow:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	local track, track2

	if localPlayer == data.plr then
		track = hum:LoadAnimation(ReplicatedStorage.Chest.Animation.LoveLove.LoveCBowHold)
		track2 = hum:LoadAnimation(ReplicatedStorage.Chest.Animation.LoveLove.LoveCBowRelease)
		track:Play()
	end

	PeodizService.new({
		Time = 10
	}, function()
		if not charge:IsDescendantOf(char) or char.Humanoid.Health <= 0 then
			return true
		end

		cFrame = root.CFrame
	end)

	if track then
		track:Stop()
	end

	if track2 then
		track2:Play()
	end

	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15632844219",
		Volume = 3
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = bow
	sound2:Play()
	task.spawn(function()
		wait(0.1)
		localshake({
			10,
			18,
			0,
			0.75
		}) -- equivalent call inferred; original call site unknown
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.shootup_fx:Clone()
		clone2.Parent = workspace.Effects
		clone2.CFrame = cFrame * CFrame.Angles(-0.6108652381980153, 0, 0) * CFrame.new(0, 20, 0)
		_G.PU:Dust(clone2, 1.5)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end
	end)
	task.spawn(function()
		wait(0.1)
		TweenService:Create(arrow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		wait(0.35)
		TweenService:Create(bow, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()

		for _, emitter in pairs(bow:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		tween_beam_transparency(
			{ clone.string_handle.Beam1, clone.string_handle.Beam2 },
			0,
			1,
			TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			0.25
		)
	end)
	_G.PU:Dust(clone, 2)
end