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

	local v = {
		Fire = Color3.fromRGB(202, 0, 0),
		Heal = Color3.fromRGB(79, 202, 42),
		Ice = Color3.fromRGB(22, 130, 202),
		Water = Color3.fromRGB(0, 55, 255)
	}
	local v2 = {
		Fire = Color3.fromRGB(255, 0, 0),
		Heal = Color3.fromRGB(100, 255, 53),
		Ice = Color3.fromRGB(28, 164, 255),
		Water = Color3.fromRGB(0, 55, 255)
	}
	local mode = data.mode
	local color = v[mode]
	local v4 = v2[mode]
	local fromcf = data.fromcf
	local tocf = data.tocf
	local magnitude = (fromcf.p - tocf.p).magnitude
	local speed = data.speed
	local v5 = CFrame.new(fromcf.p, tocf.p) * CFrame.new(0, data.height, -magnitude / 2)
	local v6 = 0
	task.spawn(function()
		PeodizService.new({
			Time = speed,
			Tween = {
				EasingStyle = Enum.EasingStyle.Linear,
				EasingDirection = Enum.EasingDirection.Out
			}
		}, function(p)
			v6 = p * 200
		end)
	end)
	local clone = ReplicatedStorage.Chest.FruitEffect.Toy.gift_projectile:Clone()
	_G.PU:Dust(clone, speed + 1)
	clone.Cube.Color = color
	local p = fromcf.p
	local p2 = v5.p
	local p3 = tocf.p
	clone.CFrame = CFrame.new(1 * p + 0 * p2 + 0 * p3)
	clone.Parent = workspace.Effects
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.projectile_trail:Clone()
	_G.PU:Dust(clone2, speed + 1)
	local p4 = fromcf.p
	local p5 = v5.p
	local p6 = tocf.p
	clone2.CFrame = CFrame.new(1 * p4 + 0 * p5 + 0 * p6)
	clone2.Parent = workspace.Effects
	localshake("SmallestBump") -- equivalent call inferred; original call site unknown

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Color = ColorSequence.new(v4)
		end
	end

	task.wait()
	task.spawn(function()
		PeodizService.new({
			Time = speed
		}, function(p7)
			clone.CFrame = CFrame.new(bezier(p7, fromcf.p, v5.p, tocf.p)) * CFrame.Angles(math.rad(v6 * 8), 0, 0)
			clone2.CFrame = CFrame.new(bezier(p7, fromcf.p, v5.p, tocf.p))
		end)
	end)
	wait(speed)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = Vector3.new()
	}):Play()
	TweenService:Create(clone.Cube, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = Vector3.new()
	}):Play()
	local v7 = CFrame.new(tocf.p) * CFrame.new(0, math.random(0, 5), 0) * CFrame.Angles(
		0,
		6.283185307179586 * math.random(),
		0
	) * CFrame.Angles(
		math.rad((math.random(-15, 15))),
		math.rad((math.random(-15, 15))),
		(math.rad((math.random(-15, 15))))
	)
	local clone3 = ReplicatedStorage.Chest.FruitEffect.Toy.gift:Clone()
	clone3:SetPrimaryPartCFrame(v7)
	clone3.Parent = workspace.Effects
	clone3.Cube.Color = color
	_G.PU:Dust(clone3, 2)

	local function explode(mode2, cframe)
		if mode2 == "Fire" then
			cframe = CFrame.new(cframe.p)
			local clone4 = ReplicatedStorage.Chest.FruitEffect.Toy.flame_exp:Clone()
			_G.PU:Dust(clone4, 2)
			clone4.CFrame = cframe * CFrame.new(0, -5, 0)
			clone4.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://14968313699",
				Volume = 0.85,
				PlaybackSpeed = 1.2
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone4
			sound:Play()
			local v8 = 60
			local p7 = cframe.p
			local v9 = "SmallBump"
			task.spawn(function()
				v8 = v8 or 100

				if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p7).Magnitude < v8 then
					_G.shake(v9)
				end
			end)
			local pointLight = Instance.new("PointLight")
			pointLight.Color = Color3.fromRGB(255, 81, 0)
			pointLight.Range = 60
			pointLight.Brightness = 1
			pointLight.Parent = clone4
			task.spawn(function()
				wait()
				TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Brightness = 0,
					Range = 0
				}):Play()
			end)
			spawn(function()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(
					cframe.p + createVector(0, 5, 0),
					createVector(0, -10, 0),
					raycastParams
				)
				local position = cframe.p + createVector(0, -5, 0)
				local instance, normal

				if raycastResult then
					instance = raycastResult.Instance
					position = raycastResult.Position
					normal = raycastResult.Normal
					local _ = instance.Material
				end

				if instance then
					local clone5 = ReplicatedStorage.Chest.SwordEffect.AuthenticMace.Burn:Clone()
					clone5.Decal.Transparency = 0.25
					clone5.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						6.283185307179586 * math.random(),
						0
					)
					clone5.Parent = workspace.Effects
					_G.PU:Dust(clone5, 1.5)
					TweenService:Create(clone5, TweenInfo.new(0.25), {
						Size = createVector(120, 0, 120)
					}):Play()
					spawn(function()
						wait(0.75)

						if clone5:FindFirstChild("Decal") then
							TweenService:Create(clone5.Decal, TweenInfo.new(0.35), {
								Transparency = 1
							}):Play()
						end
					end)
				end
			end)

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end

		if mode2 == "Ice" then
			local v8 = 60
			local p7 = cframe.p
			local v9 = "SmallBump"
			task.spawn(function()
				v8 = v8 or 100

				if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p7).Magnitude < v8 then
					_G.shake(v9)
				end
			end)
			cframe = CFrame.new(cframe.p)
			local clone4 = ReplicatedStorage.Chest.FruitEffect.Toy.IcePathAwake:Clone()
			clone4.IceFloor.Transparency = 0.25
			clone4.IceFloorNeon.Transparency = -1
			clone4:SetPrimaryPartCFrame(cframe * CFrame.Angles(0, 6.283185307179586 * math.random(), 0))
			clone4.Parent = workspace.Effects
			_G.PU:Dust(clone4, 4)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://8798650782",
				Volume = 1.5
			})
			_G.PU:Dust(sound, 4)
			sound.Parent = clone4.IceFloor
			sound:Play()
			TweenService:Create(clone4.IceFloor, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
				Size = createVector(113.264, 6.454, 107.626)
			}):Play()
			TweenService:Create(clone4.IceFloorNeon, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
				Size = createVector(112.947, 6.336, 107.297)
			}):Play()
			PeodizService.ForLoop({
				Step = 3
			}, function(p8)
				local v10 = math.floor(p8 * 3)
				local clone5 = ReplicatedStorage.Chest.FruitEffect.Toy.IceSpikeLow:Clone()
				clone5.Ice.Transparency = 0.25
				clone5.Neon.Transparency = -1
				clone5.Ice.Size = createVector(1.284, 1.172, 4.293)
				clone5.Neon.Size = createVector(1.254, 1.144, 4.258)
				clone5.Parent = workspace.Effects
				clone5:SetPrimaryPartCFrame(CFrame.new(cframe.p) * CFrame.Angles(0, 2.0943951023931953 * v10, 0) * CFrame.new(
					0,
					math.random(15, 20),
					math.random(10, 15)
				) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
					math.rad((math.random(-25, 25))),
					math.rad((math.random(-25, 25))),
					0
				))

				for _, emitter in pairs(clone5:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount") * 2)
					end
				end

				_G.PU:Dust(clone5, 4)
				local v11 = math.random(90, 120) / 10 * 3
				TweenService:Create(clone5.Ice, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone5.Ice.Size * v11
				}):Play()
				TweenService:Create(clone5.Neon, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone5.Neon.Size * v11
				}):Play()
				spawn(function()
					wait(1.5)

					if clone5:FindFirstChild("Ice") then
						TweenService:Create(clone5.Ice, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
							Size = clone5.Ice.Size / 1.75,
							CFrame = clone5.Ice.CFrame * CFrame.new(0, -(v10 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end

					if clone5:FindFirstChild("Neon") then
						TweenService:Create(clone5.Neon, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
							Size = clone5.Neon.Size / 1.75,
							CFrame = clone5.Neon.CFrame * CFrame.new(0, -(v10 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end
				end)
			end)
			spawn(function()
				wait(1.5)

				if clone4:FindFirstChild("IceFloor") then
					TweenService:Create(clone4.IceFloor, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
						Size = clone4.IceFloor.Size / 2,
						Transparency = 1
					}):Play()
				end

				if clone4:FindFirstChild("IceFloorNeon") then
					TweenService:Create(clone4.IceFloorNeon, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
						Size = clone4.IceFloor.Size / 2,
						Transparency = 1
					}):Play()
				end
			end)
		end

		if mode2 == "Heal" then
			local beams = {}
			PeodizService.ForLoop({
				Step = 3
			}, function(p7)
				local v8 = math.floor(p7 * 3)
				local cframe2 = CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
				local v9 = data.color_sync[v8]
				local v10 = {
					Color3.fromRGB(196, 40, 28),
					Color3.fromRGB(17, 255, 0),
					Color3.fromRGB(255, 247, 0),
					Color3.fromRGB(227, 15, 255)
				}
				local v11 = {
					Color3.fromRGB(255, 30, 30),
					Color3.fromRGB(17, 255, 0),
					Color3.fromRGB(255, 247, 0),
					Color3.fromRGB(227, 15, 255)
				}
				local clone4 = ReplicatedStorage.Chest.FruitEffect.Toy.Balloon:Clone()
				clone4.Color = v10[v9]
				clone4.CFrame = CFrame.new(cframe.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
					0,
					math.random(5, 45),
					math.random(15, 35)
				)
				_G.PU:Dust(clone4, 4)
				clone4.Size = Vector3.new()
				clone4.Parent = workspace.Effects
				clone4.AT1.CFrame = clone4.AT1.CFrame * cframe2
				clone4.AT2.CFrame = clone4.AT2.CFrame * cframe2
				beams[#beams + 1] = clone4.Beam
				clone4.Beam.CurveSize0 = 0
				clone4.Beam.CurveSize1 = 0
				TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(30.244, 39.693, 30.246) * math.random(8, 10) / 10
				}):Play()
				TweenService:Create(clone4, TweenInfo.new(3 + math.random(0, 10) / 10, Enum.EasingStyle.Linear), {
					CFrame = clone4.CFrame * CFrame.new(0, math.random(80, 120) * 0.6, 0)
				}):Play()
				task.spawn(function()
					wait(data.heal_sync[v8])
					TweenService:Create(clone4, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Vector3.new()
					}):Play()
					TweenService:Create(
						clone4.AT2,
						TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Position = createVector(0, -19.258, 0)
						}
					):Play()
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://15369721321",
						Volume = 1
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = clone4
					sound:Play()

					for _, emitter in pairs(clone4:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Color = ColorSequence.new(v11[v9])
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end

					local root = data.root

					if root then
						local clone5 = ReplicatedStorage.Chest.FruitEffect.Toy.heal_bullet:Clone()
						clone5.Parent = workspace.Effects
						clone5.CFrame = CFrame.new(clone4.CFrame.p)
						_G.PU:Dust(clone5, 0.5)
						clone5.Color = v10[v9]
						clone5.Trail.Color = ColorSequence.new(v10[v9])
						wait(0.1)
						local cFrame = root.CFrame
						local tocf2 = data.tocf
						local magnitude2 = (tocf2.p - cFrame.p).magnitude
						local cFrame2 = CFrame.new(tocf2.p, cFrame.p) * CFrame.new(
							0,
							0,
							-math.clamp(magnitude2, 0, 250)
						)
						TweenService:Create(
							clone5,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								CFrame = cFrame2
							}
						):Play()
						wait(0.2)
						local clone6 = ReplicatedStorage.Chest.FruitEffect.Toy.heal_exp:Clone()
						clone6.CFrame = cFrame2
						clone6.Parent = workspace.Effects
						_G.PU:Dust(clone6, 1)
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 1000,
							RollOffMinDistance = 10,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://15369709696",
							PlaybackSpeed = 1.25,
							Volume = 1
						})
						_G.PU:Dust(sound2, 3)
						sound2.Parent = clone6
						sound2:Play()

						for _, emitter in pairs(clone6:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter.Color = ColorSequence.new(v11[v9])
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end
				end)

				for _, emitter in pairs(clone4:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Color = ColorSequence.new(v11[v9])
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end)
			task.delay(10, function()
				table.clear(beams)
			end)
		end

		if mode2 == "Water" then
			cframe = CFrame.new(cframe.p)
			local clone4 = ReplicatedStorage.Chest.FruitEffect.Toy.whirlpool:Clone()
			_G.PU:Dust(clone4, 6)
			clone4.CFrame = cframe * CFrame.new(math.sin(tick() * 5) * 40, 0, math.cos(tick() * 5) * 40)
			clone4.Parent = workspace.Effects
			clone4.Beam.Enabled = true
			clone4.AT2.Position = createVector(0, 0, 0)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 800,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://15446831754",
				Volume = 1
			})
			_G.PU:Dust(sound, 6)
			sound.Parent = clone4
			sound:Play()
			TweenService:Create(clone4.AT2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = createVector(0, 100, 0)
			}):Play()

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.spawn(function()
				wait(4)
				TweenService:Create(
					clone4.AT2,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Position = createVector(0, 0, 0)
					}
				):Play()

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
			task.spawn(function()
				PeodizService.ForLoop({
					Step = 16,
					WaitTime = 0.25
				}, function(_)
					if (localPlayer.Character.HumanoidRootPart.Position - clone4.CFrame.Position).Magnitude < 100 then
						_G.shake({
							2.5,
							5,
							0.33,
							0.88
						})
					end
				end)
			end)
			PeodizService.new({
				Time = 5
			}, function()
				if not clone4:IsDescendantOf(workspace) then
					return true
				end

				clone4.CFrame = cframe * CFrame.new(math.sin(tick() * 3) * 35, 0, math.cos(tick() * 3) * 35)
			end)
		end
	end

	for _, child in pairs(clone3.HumanoidRootPart.Attachment:GetChildren()) do
		child.Color = ColorSequence.new(v4)
	end

	task.spawn(function()
		local ModuleScript = require(clone3.ModuleScript)
		ModuleScript()
	end)
	wait(0.15)
	explode(mode, v7)
end