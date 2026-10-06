local createVector = vector.create

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local mouseFolder = data.MouseFolder
	local charge = data.Charge
	local char = data.Char
	local root = data.Root
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

	local cFrame = root.CFrame * CFrame.new(0, 4, -35)
	local cFrame2 = mouseFolder.Value
	local lastTime = tick()
	local clone = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.ray_charge:Clone()
	clone.CFrame = cFrame
	clone.Size = Vector3.new()
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 6)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15907850732",
		Volume = 5,
		PlaybackSpeed = 1.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15978629881",
		Volume = 4,
		Looped = true
	})
	sound2.Parent = clone
	sound2:Play()
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(10, 10, 10)
	}):Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	localshake("SmallerBump") -- equivalent call inferred; original call site unknown
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.ray_charge2:Clone()
	_G.PU:Dust(clone2, 6)
	clone2.CFrame = cFrame
	clone2.Parent = workspace.Effects
	local flag = false
	PeodizService.new({
		Time = 4
	}, function()
		if not (root and charge:IsDescendantOf(char)) then
			return true
		end

		if tick() - lastTime > 1.5 and not flag then
			local v2 = {
				9,
				10,
				0,
				0.75
			}
			local v3 = 90
			local p = cFrame.p
			task.spawn(function()
				v3 = v3 or 100

				if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v3 then
					_G.shake(v2)
				end
			end)
			clone2.Attachment.Ring:Emit(1)
			local sound3 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15978640305",
				Volume = 5,
				PlaybackSpeed = 1.5
			})
			_G.PU:Dust(sound3, 3)
			sound3.Parent = clone2
			sound3:Play()

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			flag = true
			lastTime = tick()
		end

		if tick() - lastTime > 0.1 and flag then
			lastTime = tick()
		end

		cFrame = root.CFrame * CFrame.new(0, 4, -35)
		cFrame2 = mouseFolder.Value
		clone.CFrame = cFrame
		clone2.CFrame = cFrame
	end)
	wait()
	cFrame2 = mouseFolder.Value or cFrame2
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15907852697",
		Volume = 6
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone
	sound3:Play()
	clone.Trail.Enabled = true
	local v2 = {
		4,
		6,
		0,
		0.75
	}
	local v3 = 90
	local p = cFrame.p
	task.spawn(function()
		v3 = v3 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v3 then
			_G.shake(v2)
		end
	end)
	local v4 = (cFrame.p - cFrame2.p).magnitude / 800
	task.spawn(function()
		local clone3 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.ray_trail:Clone()
		clone3.Parent = workspace.Effects
		clone3.CFrame = CFrame.new(cFrame.p, cFrame2.p)
		_G.PU:Dust(clone3, 2)
		local clone4 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.ray_trail:Clone()
		clone4.Parent = workspace.Effects
		clone4.CFrame = CFrame.new(cFrame.p, cFrame2.p)
		_G.PU:Dust(clone4, 2)
		PeodizService.ForLoop({
			Step = 15
		}, function(p3)
			local v5 = math.floor(p3 * 15)
			local v6 = 15 - v5 * 0.5
			clone3.CFrame = CFrame.new(cFrame.p, cFrame2.p) * CFrame.new(
				math.sin(0.6283185307179586 * v5) * v6,
				math.cos(0.6283185307179586 * v5) * v6,
				-v5 * 7
			)
			clone4.CFrame = CFrame.new(cFrame.p, cFrame2.p) * CFrame.new(
				-math.sin(0.6283185307179586 * v5 + 5) * v6,
				-math.cos(0.6283185307179586 * v5 + 5) * v6,
				-v5 * 7 + 10
			)
			task.wait()
		end)
	end)
	TweenService:Create(clone, TweenInfo.new(v4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = cFrame2
	}):Play()
	wait(v4 * 0.85)
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = Vector3.new()
	}):Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	if flag then
		local v5 = {
			7,
			9,
			0,
			0.88
		}
		local v6 = 90
		local p3 = cFrame2.p
		task.spawn(function()
			v6 = v6 or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < v6 then
				_G.shake(v5)
			end
		end)
	else
		local v5 = {
			5,
			7,
			0,
			0.75
		}
		local v6 = 90
		local p3 = cFrame2.p
		task.spawn(function()
			v6 = v6 or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < v6 then
				_G.shake(v5)
			end
		end)
	end

	local clone3 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.ring_fx:Clone()
	clone3.CFrame = CFrame.new(cFrame2.p)
	clone3.Parent = workspace.Effects
	_G.PU:Dust(clone3, 1)

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	local clone4 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.dino_circle:Clone()
	clone4.CFrame = CFrame.new(cFrame2.p) * CFrame.Angles(0, 0, 1.5707963267948966)
	clone4.Parent = workspace.Effects
	_G.PU:Dust(clone4, 4)
	local sound4 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15907843108",
		Volume = 3.5,
		Looped = true
	})
	_G.PU:Dust(sound4, 3)
	sound4.Parent = clone4
	sound4:Play()
	local sound5 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15978620987",
		Volume = 7
	})
	_G.PU:Dust(sound5, 3)
	sound5.Parent = clone4
	sound5:Play()
	clone4.Size = createVector(8, 0, 0)
	TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = createVector(8, 90, 90)
	}):Play()

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local pointLight = Instance.new("PointLight")
	pointLight.Parent = clone4
	pointLight.Color = Color3.fromRGB(255, 97, 49)
	pointLight.Range = 0
	pointLight.Brightness = 0
	_G.PU:Dust(pointLight, 4)
	TweenService:Create(pointLight, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 1,
		Range = 60
	}):Play()
	local lastTime2 = tick()

	if flag then
		local angles = data.angles
		local clones = {}

		for _ = 1, 3 do
			local clone5 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.split_ball:Clone()
			clone5.Parent = workspace.Effects
			clone5.CFrame = CFrame.new(cFrame2.p)
			_G.PU:Dust(clone5, 2)
			clones[#clones + 1] = clone5
		end

		task.spawn(function()
			local v5 = 0
			task.spawn(function()
				PeodizService.new({
					Time = 0.35,
					Tween = {
						EasingStyle = Enum.EasingStyle.Quad,
						EasingDirection = Enum.EasingDirection.Out
					}
				}, function(p3)
					v5 = p3 * 50
				end)
			end)
			PeodizService.new({
				Time = 0.35
			}, function()
				for i = 1, 3 do
					local v6 = clones[i]
					local v7 = CFrame.new(cFrame2.p) * angles[i]
					local magnitude = (cFrame2.p - v7.p).magnitude
					local v8 = CFrame.new(cFrame2.p, v7.p) * CFrame.new(0, 100, -magnitude / 2)
					v6.Position = bezier(v5 / 50, cFrame2.p, v8.p, v7.p)
				end
			end)

			for i = 1, 3 do
				local v7 = 60
				local v8 = cFrame2.p
				local v9 = {
					4.5,
					6,
					0,
					0.75
				}
				task.spawn(function()
					v7 = v7 or 100

					if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - v8).Magnitude < v7 then
						_G.shake(v9)
					end
				end)
				local v10 = clones[i]
				TweenService:Create(v10, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = Vector3.new(),
					Transparency = 1
				}):Play()
				v10.Attachment.flame4.Enabled = false
				local clone5 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.dino_circle_small:Clone()
				clone5.CFrame = CFrame.new(cFrame2.p) * angles[i] * CFrame.Angles(0, 0, 1.5707963267948966)
				clone5.Parent = workspace.Effects
				_G.PU:Dust(clone5, 4)
				clone5.Size = createVector(6, 0, 0)
				TweenService:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(6, 60, 60)
				}):Play()

				for _, emitter in pairs(clone5:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Enabled = true
					local v11 = emitter
					task.spawn(function()
						wait(2)
						v11.Enabled = false
					end)
				end
			end

			task.delay(10, function()
				table.clear(clones)
			end)
		end)
	end

	local clone5 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.flame_spiral:Clone()
	clone5.Parent = workspace.Effects
	clone5.CFrame = CFrame.new(cFrame2.p) * CFrame.Angles(0, (tick() - lastTime2) * 10, 0) * CFrame.new(
		0,
		math.sin((tick())) * 3 + 2,
		-60
	)
	_G.PU:Dust(clone5, 4)
	local clone6 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.flame_spiral:Clone()
	clone6.Parent = workspace.Effects
	clone6.CFrame = CFrame.new(cFrame2.p) * CFrame.Angles(0, 3.141592653589793 + (tick() - lastTime2) * 10, 0) * CFrame.new(
		0,
		math.sin(tick() * 2) * 4 + 3,
		-60
	)
	_G.PU:Dust(clone6, 4)
	PeodizService.new({
		Time = 3
	}, function()
		clone5.CFrame = CFrame.new(cFrame2.p) * CFrame.Angles(0, (tick() - lastTime2) * 10, 0) * CFrame.new(
			0,
			math.sin((tick())) * 3 + 2,
			-60
		)
		clone6.CFrame = CFrame.new(cFrame2.p) * CFrame.Angles(0, 3.141592653589793 + (tick() - lastTime2) * 10, 0) * CFrame.new(
			0,
			math.sin(tick() * 2) * 4 + 3,
			-60
		)
	end)

	if sound4 then
		sound4:Stop()
	end

	TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0.25,
		Range = 0
	}):Play()

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end