local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
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
		task.spawn(function()
			value = value or 100

			if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < value then
				_G.shake(p2)
			end
		end)
	end

	local cf = p.cf
	local v = 200
	local p2 = cf.p
	local v2 = "Bump"
	task.spawn(function()
		v = v or 100

		if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v then
			_G.shake(v2)
		end
	end)
	local clone = replicatedStorage.Chest.FruitEffect.Flame.V2.FlameBall:Clone()
	clone.Size = createVector(85, 85, 85)
	clone.CFrame = cf
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 10)
	task.spawn(function()
		TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(170, 170, 170)
		}):Play()
		wait(0.2)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
	end)
	clone.Attachment0.Par1.Enabled = true
	clone.Attachment0.Par2.Enabled = true
	local clone2 = replicatedStorage.Chest.FruitEffect.Flame.V2.FlameBall2:Clone()
	clone2.Size = createVector(86, 86, 86)
	clone2.CFrame = cf
	clone2.Color = Color3.fromRGB(255, 0, 0)
	clone2.Parent = workspace.Effects
	TweenService:Create(clone2, TweenInfo.new(3), {
		Orientation = createVector(0, 1800, 0)
	}):Play()
	task.spawn(function()
		TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(170, 170, 170)
		}):Play()
		wait(0.2)
		TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
	end)
	_G.PU:Dust(clone2, 10)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 0,
		RollOffMode = Enum.RollOffMode.Linear,
		SoundId = "rbxassetid://14967830759",
		Volume = 1
	})
	_G.PU:Dust(sound, 10)
	sound.Parent = clone2
	sound:Play()
	wait(0.35)
	local clone3 = replicatedStorage.Chest.FruitEffect.Flame.V2.stars:Clone()
	_G.PU:Dust(clone3, 1)
	clone3.CFrame = cf * CFrame.new(0, 35, 0)
	clone3.Parent = workspace.Effects
	task.spawn(function()
		PeodizService.ForLoop({
			Step = 7,
			WaitTime = 0.05
		}, function(p3)
			if math.floor(p3 * 7) % 2 == 1 then
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://9769503074",
					Volume = 2
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone3
				sound2:Play()
			end
		end)
	end)

	if localPlayer == p.plr then
		task.spawn(function()
			local clone4 = script.inverse:Clone()
			clone4.Parent = game.Lighting
			clone4.Enabled = true
			task.wait(0.35)
			clone4:Destroy()
		end)
	end

	wait(0.35)
	local clone4 = replicatedStorage.Chest.FruitEffect.Flame.V2.Fire:Clone()
	clone4.Par1.Enabled = true
	clone4.Par2.Enabled = true
	clone4.RealisticFire.Enabled = true
	clone4.Specs.Enabled = true
	clone4.as.Enabled = true
	clone4.rock.Enabled = true
	clone4.CFrame = CFrame.new(cf.p)
	clone4.Parent = workspace.Effects
	_G.PU:Dust(clone4, 3)

	for _, emitter in pairs(clone4.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	delay(1.5, function()
		clone4.Par1.Enabled = false
		clone4.Par2.Enabled = false
		clone4.RealisticFire.Enabled = false
		clone4.Specs.Enabled = false
		clone4.as.Enabled = false
		clone4.rock.Enabled = false
	end)
	local v3 = 200
	local p3 = cf.p
	local v4 = "Explosion"
	task.spawn(function()
		v3 = v3 or 100

		if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < v3 then
			_G.shake(v4)
		end
	end)

	for i = 1, 4 do
		local v5 = i
		task.spawn(function()
			local clone5 = replicatedStorage.Chest.FruitEffect.Flame.V2.tower_big:Clone()
			_G.PU:Dust(clone5, 3)
			clone5.CFrame = cf * CFrame.Angles(0, 1.5707963267948966 * v5, 0) * CFrame.new(
				0,
				-30,
				math.random(200, 250) * 0.4
			)
			clone5.Parent = workspace.Effects
			TweenService:Create(clone5, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = clone5.CFrame * CFrame.new(0, 30, 0)
			}):Play()
			local pointLight = Instance.new("PointLight")
			pointLight.Color = Color3.fromRGB(255, 81, 0)
			pointLight.Range = 60
			pointLight.Brightness = 1
			pointLight.Parent = clone5
			task.spawn(function()
				wait(2)
				TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Brightness = 0,
					Range = 0
				}):Play()
			end)

			for i2, emitter in pairs(clone5.exp:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			wait()

			for i2, emitter in pairs(clone5.Attachment:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				local v6 = emitter
				task.spawn(function()
					wait(1)
					v6.Enabled = false
				end)
			end

			for i2, emitter in pairs(clone5:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				local v6 = emitter
				task.spawn(function()
					wait(1)
					v6.Enabled = false
				end)
			end
		end)
	end

	PeodizService.ForLoop({
		Step = 15
	}, function(_)
		local attachment = Instance.new("Attachment", clone)
		attachment.Position = createVector(0, 0, 0)
		local clone5 = replicatedStorage.Chest.FruitEffect.FlameNew.FlameBeam:Clone()
		clone5.Parent = clone
		clone5.Attachment0 = attachment
		clone5.Width0 = math.random(60, 100)
		clone5.Attachment1 = clone.Attachment0
		local cframe = CFrame.new(0, 0, -math.random(50, 90))
		TweenService:Create(attachment, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			WorldPosition = clone.CFrame * CFrame.Angles(
				math.rad((math.random(1, 360))),
				math.rad((math.random(1, 360))),
				(math.rad((math.random(1, 360))))
			) * CFrame.new(0, 0, -150) * cframe.p
		}):Play()
		TweenService:Create(clone5, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Width0 = 0
		}):Play()
		_G.PU:Dust(attachment, 1)
		_G.PU:Dust(clone5, 1)
	end)
	delay(1, function()
		if sound and sound.Parent then
			game.TweenService:Create(sound, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				Volume = 0
			}):Play()
		end

		clone.Attachment0.Par1.Enabled = false
		clone.Attachment0.Par2.Enabled = false
		TweenService:Create(clone, TweenInfo.new(1), {
			Size = Vector3.new()
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(1), {
			Size = Vector3.new()
		}):Play()
		_G.PU:Dust(clone2, 1)
		_G.PU:Dust(clone, 1)
	end)
end