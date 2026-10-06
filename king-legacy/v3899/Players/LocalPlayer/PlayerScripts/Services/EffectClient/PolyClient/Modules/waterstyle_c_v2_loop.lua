local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
return function(player, _)
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p)
		if localPlayer == player.plr then
			_G.shake(p)
		end
	end

	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - player.cf2.p).Magnitude then
			_G.shake(p)
		end
	end

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == player.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	local startCF = player.StartCF
	local rootPart = player.RootPart
	local followFolder = player.FollowFolder
	local character = player.Character
	tick()
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11833535004",
		Volume = 3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = rootPart
	sound:Play()
	task.spawn(function()
		wait(2.5)
		TweenService:Create(sound, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Volume = 0
		})
	end)
	local clone = player.WindParticle:Clone()
	clone.CFrame = startCF * CFrame.new(-15, 5, 0) * CFrame.Angles(0, 0, 1.0471975511965976)
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 3)
	local clone2 = player.WindParticle:Clone()
	clone2.CFrame = startCF * CFrame.new(15, 5, 0) * CFrame.Angles(0, 0, -1.0471975511965976)
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 3)
	local clone3 = player.WindParticle:Clone()
	clone3.CFrame = startCF * CFrame.new(-7.5, 2.5, 0) * CFrame.Angles(0, 0, 1.0471975511965976)
	clone3.Parent = workspace.Effects
	_G.PU:Dust(clone3, 10)
	local clone4 = player.WindParticle:Clone()
	clone4.CFrame = startCF * CFrame.new(-7.5, 2.5, 0) * CFrame.Angles(0, 0, -1.0471975511965976)
	clone4.Parent = workspace.Effects
	_G.PU:Dust(clone4, 10)
	_G.ParticleSize(clone3.ParticleEmitter, 0.5)
	_G.ParticleSize(clone4.ParticleEmitter, 0.5)
	task.spawn(function()
		PeodizService.HeartbeatWait({
			Time = 2,
			WaitTime = 0.1
		}, function()
			local clone5 = replicatedStorage2.Chest.Etc.AllMeshes.Rings:Clone()
			clone5.Transparency = 0.25
			clone5.Color = Color3.fromRGB(99, 159, 255)
			clone5.CFrame = rootPart.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone5.Parent = workspace.Effects
			TweenService:Create(clone5, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
				Size = createVector(40, 3, 40) * math.random(10, 20) / 15,
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone5, 0.5)
		end)
	end)
	local clone5 = replicatedStorage2.Chest.MeleeEffect.WaterStyle.V2.C.rotate_ball:Clone()
	clone5.Parent = workspace.Effects
	_G.PU:Dust(clone5, 3)
	local clone6 = replicatedStorage2.Chest.MeleeEffect.WaterStyle.V2.C.rotate_ball:Clone()
	clone6.Parent = workspace.Effects
	_G.PU:Dust(clone6, 3)
	clone5.Size = Vector3.new()
	clone6.Size = Vector3.new()
	task.spawn(function()
		clone5.specs.Enabled = true
		clone5.watersmoke.Enabled = true
		clone5.watersmoke2.Enabled = true
		clone5.Trail.Enabled = true
		TweenService:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(6, 6, 6)
		}):Play()
		TweenService:Create(clone6, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(6, 6, 6)
		}):Play()
		PeodizService.new({
			Time = 2
		}, function()
			clone5.CFrame = rootPart.CFrame * CFrame.new(math.sin(tick() * 6) * 20, math.cos(tick() * 6) * 20, 0)
			clone6.CFrame = rootPart.CFrame * CFrame.new(math.sin(tick() * 6) * -20, math.cos(tick() * 6) * -20, 0)
		end)
		TweenService:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
		TweenService:Create(clone6, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
		clone5.Trail.Enabled = false
		clone5.specs.Enabled = false
		clone5.watersmoke.Enabled = false
		clone5.watersmoke2.Enabled = false
	end)
	task.spawn(function()
		PeodizService.HeartbeatWait({
			Time = 2,
			WaitTime = 0.05
		}, function()
			if not followFolder:IsDescendantOf(character) or character.Humanoid.Health <= 0 then
				return true
			end

			clone.CFrame = rootPart.CFrame * CFrame.new(-15, 5, 0) * CFrame.Angles(0, 0, 1.0471975511965976)
			clone2.CFrame = rootPart.CFrame * CFrame.new(15, 5, 0) * CFrame.Angles(0, 0, -1.0471975511965976)
			clone3.CFrame = rootPart.CFrame * CFrame.new(-7.5, 2.5, 0) * CFrame.Angles(0, 0, 1.0471975511965976)
			clone4.CFrame = rootPart.CFrame * CFrame.new(7.5, 2.5, 0) * CFrame.Angles(0, 0, -1.0471975511965976)
			clone.ParticleEmitter:Emit(1)
			clone2.ParticleEmitter:Emit(1)
			clone3.ParticleEmitter:Emit(1)
			clone4.ParticleEmitter:Emit(1)
			clone3.specs:Emit(1)
			clone3.specs2:Emit(1)
			clone3.watersmoke:Emit(1)
			clone3.watersmoke2:Emit(1)
			clone4.specs:Emit(1)
			clone4.specs2:Emit(1)
			clone4.watersmoke:Emit(1)
			clone4.watersmoke2:Emit(1)
		end)
	end)
end