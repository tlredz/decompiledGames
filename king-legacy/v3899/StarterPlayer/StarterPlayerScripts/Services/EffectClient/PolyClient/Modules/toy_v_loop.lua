local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local cf = data.cf
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

	local charge = data.charge
	local char = data.char
	local root = data.root
	local clone = ReplicatedStorage.Chest.FruitEffect.Toy.firework_fx:Clone()
	clone.CFrame = cf
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 2)

	if localPlayer == data.plr then
		_G.shake({
			2.5,
			3.5,
			0.33,
			1
		})
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") * 1 or 1)
		end
	end

	local v = {
		Color3.fromRGB(0, 255, 247),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(255, 247, 0),
		(Color3.fromRGB(255, 0, 255))
	}
	local clones = {}
	local v2 = {}

	for i = 1, 4 do
		local v3 = {
			CFrame.new(12, 0, 0),
			CFrame.new(-12, 0, 0),
			CFrame.new(0, 12, 0),
			(CFrame.new(0, -12, 0))
		}
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.missile_holder:Clone()
		_G.PU:Dust(clone2, 11)
		clone2.Material = Enum.Material.Neon
		clone2.changable.Color = v[i]
		clone2.Attachment.sharddown.Color = ColorSequence.new(v[i])
		clone2.Attachment.sharddown2.Color = ColorSequence.new(v[i])
		clone2.Parent = workspace.Effects
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = CFrame.new()
		cFrameValue.Name = "GivenCF"
		cFrameValue.Parent = clone2
		clones[#clones + 1] = clone2
		v2[#v2 + 1] = cFrameValue
		TweenService:Create(cFrameValue, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Value = v3[i]
		}):Play()
	end

	task.spawn(function()
		for _ = 1, 3 do
			task.spawn(function()
				local v3 = math.random(10, 15)
				local v4 = math.random(8, 12)
				local cFrame2 = cf * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.bullet:Clone()
				clone2.CFrame = cFrame2
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 2)
				clone2.Transparency = 1

				if math.random(1, 2) == 1 then
					clone2.Trail.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
				end

				PeodizService.ForLoop({
					Step = 24
				}, function(_)
					clone2.CFrame = cFrame2 * CFrame.new(math.sin(tick() * v3) * v4, 0, math.cos(tick() * v3) * v4)
				end)
			end)
		end

		for _ = 1, 2 do
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.Shockwave2:Clone()
			clone2.CFrame = cf * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			) * CFrame.Angles(math.rad((math.random(-10, 10))), 0, 0)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 3)
			TweenService:Create(clone2.Mesh, TweenInfo.new(0.66, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = clone2.Mesh.Scale * math.random(2, 3)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.new(0, 0, 5) * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			TweenService:Create(clone2.Decal, TweenInfo.new(0.66, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			wait()
		end
	end)
	local lastTime = tick()
	local cFrame = root.CFrame
	PeodizService.new({
		Time = 8
	}, function()
		if not charge:IsDescendantOf(char) or char.Humanoid.Health <= 0 then
			return true
		end

		for k, v3 in pairs(clones) do
			v3.CFrame = root.CFrame * v2[k].Value * CFrame.new(
				0,
				math.sin(k + tick() * 5) * 1.5,
				(math.sin(tick() * 5))
			) * CFrame.Angles(math.rad(math.sin(k + tick() * 4) * 15), 0, 0)
		end

		if tick() - lastTime > 0.25 then
			lastTime = tick()
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy["Shockwave" .. tostring(math.random(1, 2))]:Clone()
			clone2.CFrame = root.CFrame * CFrame.Angles(
				math.rad((math.random(-25, 25))),
				math.rad((math.random(-25, 25))),
				(math.rad((math.random(-25, 25))))
			)
			clone2.Parent = workspace.Effects
			clone2.Decal.Transparency = 0.5
			_G.PU:Dust(clone2, 3)
			TweenService:Create(
				clone2.Mesh,
				TweenInfo.new(1.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = clone2.Mesh.Scale * math.random(20, 30) / 10
				}
			):Play()
			TweenService:Create(clone2, TweenInfo.new(0.9, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.new(0, 0, 2) * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			TweenService:Create(
				clone2.Decal,
				TweenInfo.new(1.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
		end

		cFrame = root.CFrame
	end)
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.flare_exp_big:Clone()
	clone2.CFrame = cFrame * CFrame.Angles(
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random()
	)
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 2)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15487854383",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15487856146",
		PlaybackSpeed = 0.88,
		Volume = 3
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	local v3 = {
		4,
		5,
		0.45,
		0.66
	}
	local v4 = 60
	local p = cFrame.p
	task.spawn(function()
		v4 = v4 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v4 then
			_G.shake(v3)
		end
	end)
	local clone3 = ReplicatedStorage.Chest.FruitEffect.Toy.firework_fx:Clone()
	clone3.CFrame = cFrame
	clone3.Parent = workspace.Effects
	_G.PU:Dust(clone3, 2)

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	local clone4 = ReplicatedStorage.Chest.FruitEffect.Toy.firework_jump:Clone()
	clone4.CFrame = cFrame
	clone4.Parent = workspace.Effects
	_G.PU:Dust(clone4, 2)

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	for _ = 1, 2 do
		task.spawn(function()
			local v5 = math.random(10, 15)
			local v6 = math.random(8, 12)
			local cFrame2 = cFrame * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			local clone5 = ReplicatedStorage.Chest.FruitEffect.Toy.bullet:Clone()
			clone5.CFrame = cFrame2
			clone5.Parent = workspace.Effects
			_G.PU:Dust(clone5, 2)
			clone5.Transparency = 1

			if math.random(1, 2) == 1 then
				clone5.Trail.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
			end

			PeodizService.ForLoop({
				Step = 24
			}, function(_)
				clone5.CFrame = cFrame2 * CFrame.new(math.sin(tick() * v5) * v6, 0, math.cos(tick() * v5) * v6)
			end)
		end)
	end

	if clones then
		for k, v5 in pairs(clones) do
			local v7 = cFrame * CFrame.Angles(0, 1.5707963267948966 * k, 0) * CFrame.new(0, 40, 55)
			TweenService:Create(v5, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(v7.p, cFrame.p)
			}):Play()
			local v8 = k
			task.spawn(function()
				local v9 = math.random(10, 15) + 5
				local v10 = math.random(35, 40)
				local cFrame2 = cFrame * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				local clone5 = ReplicatedStorage.Chest.FruitEffect.Toy.firework_trail:Clone()
				clone5.CFrame = cFrame2
				clone5.Parent = workspace.Effects
				_G.PU:Dust(clone5, 2)
				clone5.Transparency = 1
				clone5.Trail.Color = ColorSequence.new(v[v8])
				PeodizService.ForLoop({
					Step = 20
				}, function(p2)
					local v12 = math.floor(p2 * 20)
					clone5.CFrame = cFrame2 * CFrame.new(
						math.sin(tick() * v9) * v10 - v12 * 1,
						0,
						math.cos(tick() * v9) * v10 - v12 * 1
					)
				end)
			end)
			local folder = v5
			local v10 = k
			task.spawn(function()
				local sound3 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://15523288343",
					Volume = 1.2
				})
				_G.PU:Dust(sound3, 3)
				sound3.Parent = folder
				sound3:Play()
				wait(0.3)
				TweenService:Create(folder, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(v7.p, cFrame.p) * CFrame.new(0, 0, -50)
				}):Play()
				wait(0.1)
				local v11 = {
					2.25,
					3.75,
					0.33,
					0.88
				}
				local v12 = 60
				local p2 = cFrame.p
				task.spawn(function()
					v12 = v12 or 100

					if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v12 then
						_G.shake(v11)
					end
				end)
				local clone5 = ReplicatedStorage.Chest.FruitEffect.Toy.flare_exp:Clone()
				clone5.Parent = workspace.Effects
				clone5.CFrame = CFrame.new(v7.p, cFrame.p) * CFrame.new(0, 0, -45) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, math.random(0, math.random(10, 25)))
				_G.PU:Dust(clone5, 2)
				local sound4 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://15487854383",
					Volume = 0.88
				})
				_G.PU:Dust(sound4, 3)
				sound4.Parent = clone5
				sound4:Play()
				local sound5 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://15488399583",
					Volume = 0.88
				})
				_G.PU:Dust(sound5, 3)
				sound5.Parent = clone5
				sound5:Play()
				task.spawn(function()
					local pointLight = Instance.new("PointLight")
					pointLight.Parent = clone5
					pointLight.Color = v[v10]
					pointLight.Range = 50
					pointLight.Brightness = 1
					wait()
					TweenService:Create(
						pointLight,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Brightness = 0.25,
							Range = 0
						}
					):Play()
					_G.PU:Dust(pointLight, 1)
				end)

				for i, emitter in pairs(clone5:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Color = ColorSequence.new(v[v10])
					emitter:Emit(emitter:GetAttribute("EmitCount") * 1 or 1)
				end

				_G.PU:Dust(folder, 0.5)
				wait()
				folder.Attachment.sharddown.Enabled = false
				folder.Attachment.sharddown2.Enabled = false

				for i, part in pairs(folder:GetDescendants()) do
					if part:IsA("BasePart") then
						TweenService:Create(
							part,
							TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Size = Vector3.new()
							}
						):Play()
					end
				end
			end)
			wait(0.15)
		end
	end

	task.delay(10, function()
		table.clear(clones)
		table.clear(v2)
	end)
end