local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
return function(data)
	local fromcf = data.fromcf
	local tocf = data.tocf
	local ti = data.ti
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

	local clone = ReplicatedStorage.Chest.FruitEffect.Venom.New.Ball:Clone()
	clone.CastShadow = false
	clone.CFrame = CFrame.new(fromcf.p, tocf.p)
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 5)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11594387301",
		Volume = 1.75
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	TweenService:Create(clone, TweenInfo.new(ti, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = tocf
	}):Play()
	wait(ti * 0.4)
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Venom.New.poison_explode:Clone()
	clone2.CFrame = CFrame.new(tocf.p)
	clone2.Parent = workspace.Effects
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 750,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://365002938",
		Volume = 1
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 750,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11594475441",
		Volume = 1.25
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone2
	sound3:Play()

	for _, emitter in pairs(clone2:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if emitter:GetAttribute("EmitCount") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		else
			emitter:Emit(15)
		end
	end

	local clone3 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball:Clone()
	clone3.Size = createVector(0, 0, 0)
	clone3.Material = Enum.Material.Neon
	clone3.CFrame = tocf
	clone3.Parent = workspace.Effects
	game.TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(50, 50, 50),
		Transparency = 1
	}):Play()
	_G.PU:Dust(clone3, 1)
	local v = 70
	local p = data.tocf.p
	local v2 = "SmallBump"
	task.spawn(function()
		v = v or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
			_G.shake(v2)
		end
	end)
	_G.PU:Dust(clone2, 3)
	_G.PU:Dust(clone, 0.25)
end