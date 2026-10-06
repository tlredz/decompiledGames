local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - data.cf2.p).Magnitude then
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

	local cf = data.cf
	task.spawn(function()
		if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 150 then
			_G.BeckCameraShake(_G.CameraShakerModule.Presets.WaterStyleV)
			local clone = replicatedStorage.Chest.Etc.Blur:Clone()
			clone.Enabled = true
			clone.Parent = workspace.CurrentCamera
			clone.Size = 0
			_G.PU:Dust(clone, 1.5)
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = 10
			}):Play()
			wait(0.35)
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = 0
			}):Play()
		end
	end)
	local clone = replicatedStorage.Chest.MeleeEffect.WaterStyle.V2.V.c_explode:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = cf
	_G.PU:Dust(clone, 2)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11794376241",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11833462438",
		Volume = 1
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://13788993232",
		Volume = 1,
		PlaybackSpeed = 1.2
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone
	sound3:Play()
	local clone2 = replicatedStorage.Chest.MeleeEffect.WaterStyle.V2.V.ball:Clone()
	clone2.Parent = workspace.Effects
	clone2.CFrame = cf
	_G.PU:Dust(clone2, 1)
	clone2.Size = createVector(70, 70, 70)
	task.spawn(function()
		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			_G.ParticleSize(emitter, 1.5)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		wait()
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
	end)
	wait(0.1)
	PeodizService.ForLoop({
		Step = 6,
		WaitTime = 0.05
	}, function(p)
		local v = math.floor(p * 6)
		local clone3 = replicatedStorage.Chest.MeleeEffect.WaterStyle.V2.V.ball:Clone()
		clone3.Parent = workspace.Effects
		clone3.CFrame = data.cf2[v]
		_G.PU:Dust(clone3, 2)
		local clone4 = replicatedStorage.Chest.MeleeEffect.WaterStyle.V2.V.c_explode:Clone()
		clone4.Parent = workspace.Effects
		clone4.CFrame = clone3.CFrame
		_G.PU:Dust(clone4, 2)
		local sound4 = PeoUtils.CreateSound({
			RollOffMaxDistance = 300,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://13788993232",
			Volume = 1,
			PlaybackSpeed = 1.2
		})
		_G.PU:Dust(sound4, 3)
		sound4.Parent = clone4
		sound4:Play()
		local sound5 = PeoUtils.CreateSound({
			RollOffMaxDistance = 300,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://13788994904",
			Volume = 1
		})
		_G.PU:Dust(sound5, 3)
		sound5.Parent = clone4
		sound5:Play()
		clone3.Size = createVector(60, 60, 60)

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			_G.ParticleSize(emitter, 0.8)
			emitter:Emit(emitter:GetAttribute("EmitCount") / 3)
		end

		TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
	end)
end