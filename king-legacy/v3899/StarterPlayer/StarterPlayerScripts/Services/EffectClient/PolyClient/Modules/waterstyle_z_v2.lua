local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local replicatedStorage2 = game.ReplicatedStorage
game:GetService("TweenService")
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
return function(p, _)
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p2)
		if localPlayer == p.plr then
			_G.shake(p2)
		end
	end

	local function rangeshake(p2, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - p.cf.p).Magnitude then
			_G.shake(p2)
		end
	end

	local function local_rangeshake(p2, value, p3)
		if p2 and p3 then
			task.spawn(function()
				value = value or 100

				if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < value then
					_G.shake(p2)
				end
			end)
		end
	end

	local cf = p.cf
	local clone = replicatedStorage2.Chest.MeleeEffect.WaterStyle.V2.Z.trail:Clone()
	_G.PU:Dust(clone, 1.5)
	local clone2 = replicatedStorage2.Chest.MeleeEffect.WaterStyle.V2.Z.Shark:Clone()
	clone2.Size = Vector3.new()
	_G.PU:Dust(clone2, 1.5)
	local cFrame = cf
	PeodizService.ForLoop({
		Step = 6,
		WaitTime = 0.05
	}, function(p2)
		local v = math.floor(p2 * 6)
		local clone3 = replicatedStorage2.Chest.MeleeEffect.WaterStyle.V2.Z.ball2:Clone()
		clone3.Parent = workspace.Effects
		clone3.CFrame = cf * CFrame.new(0, 0, v * -125 / 6) * CFrame.new(0, 0, 10.416666666666666) * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) * CFrame.new(0, 0, math.random(5, 10))
		clone3.Size = createVector(1, 1, 1) * math.random(15, 20)
		_G.PU:Dust(clone3, 1)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://13518876454",
			Volume = 2,
			PlaybackSpeed = 1.25
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone3
		sound:Play()
		local cframe = CFrame.new(cFrame.p, clone3.CFrame.p)
		cFrame = clone3.CFrame
		local v2 = 60
		local p3 = cframe.p

		if p3 then
			local v3 = "SmallestBump"
			task.spawn(function()
				v2 = v2 or 100

				if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < v2 then
					_G.shake(v3)
				end
			end)
		end

		if v == 1 then
			clone2.CFrame = clone3.CFrame
			clone2.Parent = workspace.Effects
			clone.CFrame = clone3.CFrame
			clone.Parent = workspace.Effects
			game.TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(14.298, 21.58, 48.543)
			}):Play()
		end

		game.TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = cframe
		}):Play()
		game.TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone3.CFrame
		}):Play()

		for _, emitter in pairs(clone3:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.spawn(function()
			wait()
			game.TweenService:Create(
				clone3,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = Vector3.new()
				}
			):Play()
		end)

		if v == 6 then
			wait()
			game.TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
		end
	end)
	wait(0.2)
	local clone3 = replicatedStorage2.Chest.MeleeEffect.WaterStyle.V2.Z.fx:Clone()
	clone3.Parent = workspace.Effects
	clone3.CFrame = cf * CFrame.new(0, 0, -55)
	_G.PU:Dust(clone3, 1.5)

	for _, emitter in pairs(clone3:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11833377508",
		Volume = 3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone3
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://13518877234",
		Volume = 3
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone3
	sound2:Play()
	PeodizService.ForLoop({
		Step = 4,
		WaitTime = 0.05
	}, function(p2)
		local v = math.floor(p2 * 4)
		local clone4 = replicatedStorage2.Chest.MeleeEffect.WaterStyle.V2.Z.ball:Clone()
		clone4.Parent = workspace.Effects
		clone4.CFrame = cf * CFrame.new(0, 0, v * -125 / 4) * CFrame.new(0, 0, 15.625) * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) * CFrame.new(0, 0, 5)
		_G.PU:Dust(clone4, 1)
		task.spawn(function()
			clone4.Size = createVector(35, 35, 35)
			wait()
			clone4.ParticleEmitter:Emit(1)
			clone4.sw1:Emit(1)
			game.TweenService:Create(
				clone4,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = Vector3.new()
				}
			):Play()
		end)
	end)
end