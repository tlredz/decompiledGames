local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local _ = data.cf
	local fromcf = data.fromcf
	local tocf = data.tocf
	local _ = data.charge_mode
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

	local v = 70
	local p = data.cf.p
	local v2 = "Bump"
	task.spawn(function()
		v = v or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
			_G.shake(v2)
		end
	end)
	local clone = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.bullet2:Clone()
	clone.CastShadow = false
	clone.Transparency = -1
	clone.Size = createVector(1, 1, 10)
	clone.CFrame = fromcf
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(ti, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
		CFrame = tocf
	}):Play()
	_G.PU:Dust(clone, ti + 0.5)
	local clone2 = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.shoot2:Clone()
	clone2.CFrame = fromcf * CFrame.new(0, 0, -8)
	clone2.Anchored = true
	clone2.Massless = true
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 1)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://12265826457",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8748164748",
		PlaybackSpeed = 2,
		Volume = 1
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://12485524695",
		Volume = 1.5
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone2
	sound3:Play()

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	wait(ti)
	local clone3 = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.explode1:Clone()
	clone3.CFrame = CFrame.new(tocf.p)
	clone3.Anchored = true
	clone3.Massless = true
	clone3.Parent = workspace.Effects
	_G.PU:Dust(clone3, 1.25)
	local sound4 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://12276907916",
		Volume = 3.5
	})
	_G.PU:Dust(sound4, 3)
	sound4.Parent = clone3
	sound4:Play()
	local sound5 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8748164748",
		Volume = 4,
		PlaybackSpeed = 0.85
	})
	_G.PU:Dust(sound5, 3)
	sound5.Parent = clone3
	sound5:Play()

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	local v3 = 70
	local p2 = data.tocf.p
	local v4 = "Bump"
	task.spawn(function()
		v3 = v3 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v3 then
			_G.shake(v4)
		end
	end)
end