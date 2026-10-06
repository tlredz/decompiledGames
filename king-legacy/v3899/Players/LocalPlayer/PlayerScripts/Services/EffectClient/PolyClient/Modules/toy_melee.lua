-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local _ = data.cf
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

	local speed = data.speed
	local fromcf = data.fromcf
	local tocf = data.tocf
	local magnitude = (fromcf.p - tocf.p).magnitude
	local color = ({
		Color3.fromRGB(0, 255, 247),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(255, 247, 0),
		(Color3.fromRGB(255, 0, 255))
	})[math.random(1, 4)]
	local v2 = 0
	local v3 = CFrame.new(fromcf.p, tocf.p) * CFrame.new(0, 0, -magnitude / 2) * CFrame.new(
		math.random(-15, 15),
		math.random(-5, 15),
		0
	)
	local cframe = CFrame.new(bezier(v2 / 100, fromcf.p, v3.p, tocf.p))
	local cframe2 = CFrame.new(bezier((v2 + 1) / 100, fromcf.p, v3.p, tocf.p))
	local clone = ReplicatedStorage.Chest.FruitEffect.Toy.small_missile:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = CFrame.new(cframe.p, cframe2.p) * CFrame.new(0, 0, 6)
	clone.changable.Color = color
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15523288343",
		Volume = 1.2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(cframe.p, cframe2.p)
	}):Play()
	CFrame.new(fromcf.p, tocf.p)

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local size = descendant.Size
			descendant.Size = Vector3.new()
			TweenService:Create(descendant, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = size
			}):Play()
		end

		if not descendant:IsA("ParticleEmitter") then
			continue
		end

		descendant.Color = ColorSequence.new(color)

		if descendant.Parent == clone.spawn then
			descendant:Emit(descendant:GetAttribute("EmitCount") or 1)
		end
	end

	wait(0.25)
	task.spawn(function()
		PeodizService.new({
			Time = speed,
			Tween = {
				EasingStyle = Enum.EasingStyle.Quad,
				EasingDirection = Enum.EasingDirection.Out
			}
		}, function(p7)
			v2 = p7 * 99
		end)
	end)
	task.spawn(function()
		PeodizService.new({
			Time = speed
		}, function(_)
			cframe = CFrame.new(bezier(v2 / 100, fromcf.p, v3.p, tocf.p))
			cframe2 = CFrame.new(bezier((v2 + 1) / 100, fromcf.p, v3.p, tocf.p))
			clone.CFrame = CFrame.new(cframe.p, cframe2.p)
		end)
	end)
	wait(speed * 0.85)
	clone.Attachment.sharddown.Enabled = false
	clone.Attachment.sharddown2.Enabled = false
	_G.PU:Dust(clone, 1)
	local v6 = {
		2,
		3,
		0.33,
		0.88
	}
	local v7 = 60
	local p7 = tocf.p
	task.spawn(function()
		v7 = v7 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p7).Magnitude < v7 then
			_G.shake(v6)
		end
	end)
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.flare_exp_m1:Clone()
	_G.PU:Dust(clone2, 1.5)
	clone2.Parent = workspace.Effects
	clone2.CFrame = tocf * CFrame.Angles(
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random()
	)
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15523291284",
		Volume = 1.2
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Color = ColorSequence.new(color)
		emitter:Emit(emitter:GetAttribute("EmitCount") * 0.75 or 1)
	end

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
		end
	end
end