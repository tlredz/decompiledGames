local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(list)
	local player, cFrame, v2, _ = unpack(list)
	local success, result = pcall(function()
		if type(v2) == "table" and v2.LoopDistance then
			return false
		end

		if cFrame then
			return (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude > 1000
		end

		return false
	end)

	if success then
		if result then
			return
		end

		local mode = v2.Mode

		if mode == "Z" then
			spawn(function()
				local cFrame2 = cFrame
				local endCF = v2.EndCF
				local _ = v2.RootPart
				local color = Color3.fromRGB(180, 180, 180)
				local magnitude = (endCF.p - cFrame2.p).magnitude
				local clone = ReplicatedStorage.Chest.FruitEffect.Op.Wind:Clone()
				_G.PU:Dust(clone, 1)
				clone.CFrame = CFrame.new(endCF.p, cFrame2.p) * CFrame.new(0, 0, -magnitude / 2)
				clone.Size = Vector3.new(4, 0.05, magnitude)
				clone.Parent = workspace.Effects
				TweenService:Create(
					clone,
					TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(6, 8.5, clone.Size.Z)
					}
				):Play()
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()

				for i = 1, 3 do
					local size = createVector(30.433, 0.965, 30.433) - createVector(30.433, 0.965, 30.433) * (i * 0.115)
					local clone2 = ReplicatedStorage.Chest.Etc.BlackLeg.Rings:Clone()
					clone2.Size = Vector3.new()
					clone2.Color = color
					clone2.CFrame = CFrame.new(cFrame2.p) * CFrame.new(0, i * 17.5 + 2 - 5, 0)
					clone2.Size = size
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, 1)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(size.X * 2, size.Y * 1.1, size.Z * 2),
							CFrame = clone2.CFrame * CFrame.new(0, 10, 0)
						}
					):Play()
					TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
				end

				for _ = 1, 3 do
					local clone2 = ReplicatedStorage.Chest.Etc.BlackLeg.Sphere:Clone()
					clone2.Color = color
					clone2.CFrame = CFrame.new(cFrame2.p) * CFrame.new(
						math.random(-7, 7),
						12.5 + math.random(-2, 5),
						math.random(-7, 7)
					)
					clone2.Size = createVector(0.3, 22.936, 0.3)
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, 1)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = clone2.CFrame * CFrame.new(0, math.random(15, 25), 0),
							Size = createVector(0.1, 33.816, 0.1)
						}
					):Play()
					TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
						Transparency = 1,
						Color = Color3.fromRGB(120, 120, 120)
					}):Play()
				end

				for _ = 1, 4 do
					local part = Instance.new("Part")
					part.Size = createVector(1, 1, 1)
					part.Anchored = true
					part.CFrame = CFrame.new(cFrame2.p + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
					part.CanCollide = false
					_G.PU:Dust(part, 2)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(part.CFrame.p, createVector(0, -10, 0), raycastParams)

					if not (raycastResult and raycastResult.Instance) then
						continue
					end

					local instance = raycastResult.Instance
					local position = raycastResult.Position
					part.CFrame = CFrame.new(position) * CFrame.Angles(
						math.random(-2, 2),
						math.random(-2, 2),
						math.random(-2, 2)
					)
					part.Material = instance.Material
					part.MaterialVariant = instance.MaterialVariant
					part.Color = instance.Color
					part.Anchored = false
					part.Massless = true
					part.CastShadow = false
					part.Size = Vector3.new(math.random(1, 3), math.random(1, 3), math.random(1, 3)) * math.random(3, 6) / 10
					part.Parent = workspace.Effects
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Parent = part
					bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
					bodyVelocity.Velocity = Vector3.new(math.random(-20, 20), math.random(80, 95), math.random(-20, 20))
					_G.PU:Dust(bodyVelocity, 0.1)
				end

				for _ = 1, 7 do
					local cFrame3 = CFrame.new(cFrame2.p) * CFrame.Angles(
						math.random(-2, 2),
						math.random(-2, 2),
						math.random(-2, 2)
					)
					local clone2 = ReplicatedStorage.Chest.Etc.BlackLeg.Sphere:Clone()
					clone2.Color = color
					clone2.CFrame = cFrame3
					clone2.Size = createVector(10, 1.5, 1.5)
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, 1)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(0, 0, math.random(15, 20)),
							CFrame = cFrame3 * CFrame.new(0, 0, -math.random(30, 35))
						}
					):Play()
					TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
				end

				for i = 1, 10 do
					local part = Instance.new("Part")
					part.Size = createVector(1, 1, 1)
					part.Anchored = true
					part.CanCollide = false
					local p = (CFrame.new(cFrame2.p + createVector(0, 2, 0)) * CFrame.Angles(
						0,
						0.6283185307179586 * i,
						0
					) * CFrame.new(0, 0, -24)).p
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = {
						workspace.Effects,
						workspace.PlayerCharacters,
						workspace.CharacterWorkshop
					}
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(p, createVector(0, -10, 0), raycastParams)

					if not (raycastResult and raycastResult.Instance) then
						continue
					end

					local instance = raycastResult.Instance
					local position = raycastResult.Position
					part.CFrame = CFrame.new(position + createVector(0, -6, 0)) * CFrame.Angles(
						0.3490658503988659,
						0.6283185307179586 * i,
						0
					)
					part.Material = instance.Material
					part.MaterialVariant = instance.MaterialVariant
					part.Color = instance.Color
					part.Size = createVector(1, 1, 1)
					part.Parent = workspace.Effects
					_G.PU:Dust(part, 2)
					local vector2 = Vector3.new(17.25, math.random(70, 80) / 10, math.random(6, 8))
					TweenService:Create(
						part,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = vector2,
							CFrame = CFrame.new(position + Vector3.new(0, -0.85 - (10 - vector2.Y) / 2, 0)) * CFrame.Angles(
								0,
								0.6283185307179586 * i,
								0
							) * CFrame.Angles(-0.6108652381980153, 0, 0)
						}
					):Play()
					local v4 = part
					local v6 = i
					spawn(function()
						wait(0.5)
						TweenService:Create(v4, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
							Transparency = 1,
							CFrame = CFrame.new(position + createVector(0, -7.5, 0)) * CFrame.Angles(
								0,
								0.6283185307179586 * v6,
								0
							) * CFrame.Angles(-0.4188790204786391, 0, 0)
						}):Play()
					end)
				end

				local clone2 = ReplicatedStorage.Chest.Etc.BlackLeg.Sphere:Clone()
				clone2.Color = color
				clone2.CFrame = CFrame.new(cFrame2.p) * CFrame.new(0, 27.5, 0)
				clone2.Size = createVector(10, 60, 10)
				clone2.Parent = workspace.Effects
				TweenService:Create(
					clone2,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(0.1, 55, 0.1),
						Color = Color3.fromRGB(100, 100, 100)
					}
				):Play()
				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone2, 2)
				local clone3 = ReplicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
				clone3.CanCollide = false
				clone3.Anchored = true
				clone3.Color = Color3.fromRGB(13, 8, 21)
				clone3.Size = createVector(28.003, 2.953, 28.003)
				clone3.Material = Enum.Material.Neon
				clone3.Transparency = 0.15
				clone3.CFrame = CFrame.new(cFrame2.p) * CFrame.new(0, 2, 0)
				clone3.Parent = workspace.Effects
				TweenService:Create(
					clone3,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(73.303, 7.728, 73.303),
						CFrame = CFrame.new(cFrame2.p) * CFrame.new(0, 2.5, 0) * CFrame.Angles(0, 0.8726646259971648, 0)
					}
				):Play()
				TweenService:Create(clone3, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone3, 1)
				local clone4 = ReplicatedStorage.Chest.Etc.BlackLeg.Stone_Shockwave:Clone()
				clone4.CFrame = CFrame.new(cFrame2.p) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone4.Color = color
				clone4.Size = createVector(52.412, 52.412, 10.332)
				clone4.Parent = workspace.Effects
				TweenService:Create(
					clone4,
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(45.573, 45.573, 45.573),
						CFrame = CFrame.new(cFrame2.p) * CFrame.new(0, 15, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
					}
				):Play()
				TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone4, 1)
				local clone5 = ReplicatedStorage.Chest.Etc.BlackLeg.FlameWind:Clone()
				clone5.Size = createVector(20, 25.794, 20)
				clone5.Transparency = 0.1
				clone5.Color = color
				clone5.CFrame = CFrame.new(cFrame2.p) * CFrame.new(0, -12.5, 0)
				clone5.Parent = workspace.Effects
				_G.PU:Dust(clone5, 1)
				spawn(function()
					TweenService:Create(
						clone5,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(35.06, 65.551, 35.06),
							CFrame = CFrame.new(cFrame2.p) * CFrame.new(0, 50, 0) * CFrame.Angles(
								0,
								3.141592653589793,
								0
							)
						}
					):Play()
					tick()
					PeodizService.HeartbeatWait({
						Time = 5,
						WaitTime = 0.05
					}, function()
						if not clone5:IsDescendantOf(workspace.Effects) then
							return true
						end

						TweenService:Create(clone5, TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Quad), {
							CFrame = clone5.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
						}):Play()
					end)
				end)
				wait(0.2)
				TweenService:Create(
					clone5,
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(1, 55, 1)
					}
				):Play()
				TweenService:Create(clone5, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
			end)
		elseif mode == "X" then
			if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < 150 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			local rootPart = v2.RootPart
			local total = 0
			tick()
			local lastTime = tick()
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://6605151904"
			sound.MaxDistance = 500
			sound.Volume = 2
			sound.TimePosition = 0.4
			sound.Looped = true
			sound.Parent = rootPart
			sound:Play()
			_G.PU:Dust(sound, 2.6)
			PeodizService.HeartbeatWait({
				Time = 2.6,
				WaitTime = 0.05
			}, function()
				local color = Color3.fromRGB(190, 190, 190)

				if math.random(1, 3) == 1 then
					color = Color3.fromRGB()
				end

				total += 45

				if tick() - lastTime > 0.5 then
					lastTime = tick()
					local clone = ReplicatedStorage.Chest.Etc.BlackLeg.Rings:Clone()
					clone.Size = Vector3.new()
					clone.Color = Color3.fromRGB(170, 170, 170)
					clone.CFrame = CFrame.new(rootPart.CFrame.p) * CFrame.new(0, 2.25, 0)
					clone.Size = createVector(7.711, 0.05, 7.711)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1)
					TweenService:Create(
						clone,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(21.27, 0.232, 21.27),
							CFrame = clone.CFrame * CFrame.new(0, 1.25, 0)
						}
					):Play()
					TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
				end

				local clone = ReplicatedStorage.Chest.Etc.BlackLeg.party:Clone()
				clone.Color = color
				clone.Size = createVector(8.758, 0.192, 9.754)
				clone.CFrame = CFrame.new(rootPart.CFrame.p) * CFrame.Angles(0, math.rad(total), 0)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1)
				TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(14.81, 0.325, 16.495),
					CFrame = clone.CFrame * CFrame.new(5, 3, 0)
				}):Play()
				TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end)
		elseif mode == "Light Z Awake 1" then
			local rootPart = v2.RootPart
			local _ = v2.RightHand
			local startCF = v2.StartCF
			local _ = v2.Character
			local cFMouse = v2.CFMouse
			task.spawn(function()
				local clone = ReplicatedStorage.Chest.FruitEffect.Light.LightEx2:Clone()
				clone.CFrame = startCF
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1.5)

				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)

			if (startCF.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 100 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			task.spawn(function()
				for i = 1, 2 do
					local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Wind:Clone()
					clone.Transparency = -1
					clone.Color = Color3.fromRGB(255, 255, 127)
					clone.CFrame = i == 1 and startCF * CFrame.new(-10, 5, 0) * CFrame.Angles(
						0,
						-0.15707963267948966,
						0
					) or startCF * CFrame.new(10, 5, 0) * CFrame.Angles(0, 0.15707963267948966, 0)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1)
					TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
						Transparency = 1,
						Size = createVector(1.904, 17.627, 54.643),
						CFrame = clone.CFrame * CFrame.new(0, 0, clone.Size.Z / 2)
					}):Play()
				end
			end)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://10142419364",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.Etc.MeshStorage.Thing:Clone()
			clone.CastShadow = false
			clone.Transparency = -1
			clone.Size = createVector(1, 1, 10)
			clone.Color = Color3.fromRGB(255, 255, 121)
			clone.CFrame = CFrame.new(rootPart.Position, cFMouse.p)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(v2.Speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Transparency = 1,
				CFrame = cFMouse
			}):Play()
			_G.PU:Dust(clone, v2.Speed)
			spawn(function()
				local v3 = (rootPart.Position - cFMouse.p).Magnitude / 3

				for i = 1, 3 do
					local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
					clone2.CFrame = CFrame.new(rootPart.Position, cFMouse.p) * CFrame.new(0, 0, -v3 * i / 1.3) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					)
					clone2.Parent = workspace.Effects
					TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
						Size = createVector(37.5, 3.75, 37.5),
						Transparency = 1,
						Color = Color3.fromRGB(255, 255, 127)
					}):Play()
					_G.PU:Dust(clone2, 0.25)
					wait(v2.Speed / 3)
				end
			end)
			wait(v2.Speed)
			task.spawn(function()
				if (cFMouse.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 300 then
					local clone2 = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
					clone2.Parent = game.Lighting
					_G.PU:Dust(clone2, 0.3)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
						{
							TintColor = Color3.fromRGB(255, 255, 0)
						}
					):Play()
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
				end

				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 300,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://165970126",
					Volume = 0.5
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = rootPart
				sound2:Play()
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Light["Light Explosion Small"]:Clone()
				clone2.CFrame = CFrame.new(cFMouse.p)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 1.25)
				TweenService:Create(
					clone2.Light,
					TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
					{
						Range = 60
					}
				):Play()

				for _, emitter in pairs(clone2.Attachment:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
		elseif mode == "Light Z Awake 2" then
			local rootPart = v2.RootPart
			local _ = v2.RightHand
			local startCF = v2.StartCF
			local _ = v2.Character
			local cFMouse = v2.CFMouse
			task.spawn(function()
				local clone = ReplicatedStorage.Chest.FruitEffect.Light.LightEx2:Clone()
				clone.CFrame = startCF
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1.5)

				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)

			if (startCF.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 100 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			task.spawn(function()
				for i = 1, 2 do
					local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Wind:Clone()
					clone.Transparency = -1
					clone.Color = Color3.fromRGB(255, 255, 127)
					clone.CFrame = i == 1 and startCF * CFrame.new(-10, 5, 0) * CFrame.Angles(
						0,
						-0.15707963267948966,
						0
					) or startCF * CFrame.new(10, 5, 0) * CFrame.Angles(0, 0.15707963267948966, 0)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1)
					TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
						Transparency = 1,
						Size = createVector(1.904, 17.627, 54.643),
						CFrame = clone.CFrame * CFrame.new(0, 0, clone.Size.Z / 2)
					}):Play()
				end
			end)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://10142419364",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://10110885336",
				Volume = 0.7
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = rootPart
			sound2:Play()
			local clone = ReplicatedStorage.Chest.Etc.MeshStorage.Thing:Clone()
			clone.CastShadow = false
			clone.Transparency = -1
			clone.Size = createVector(1, 1, 10)
			clone.Color = Color3.fromRGB(255, 255, 121)
			clone.CFrame = CFrame.new(rootPart.Position, cFMouse.p)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(v2.Speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Transparency = 1,
				CFrame = cFMouse
			}):Play()
			_G.PU:Dust(clone, v2.Speed)
			spawn(function()
				local v3 = (rootPart.Position - cFMouse.p).Magnitude / 3

				for i = 1, 3 do
					local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
					clone2.CFrame = CFrame.new(rootPart.Position, cFMouse.p) * CFrame.new(0, 0, -v3 * i / 1.3) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					)
					clone2.Parent = workspace.Effects
					TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
						Size = createVector(75, 7.5, 75),
						Transparency = 1,
						Color = Color3.fromRGB(255, 255, 127)
					}):Play()
					_G.PU:Dust(clone2, 0.25)
					wait(v2.Speed / 3)
				end
			end)
			wait(v2.Speed)
			task.spawn(function()
				if (cFMouse.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 300 then
					local clone2 = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
					clone2.Parent = game.Lighting
					_G.PU:Dust(clone2, 0.3)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
						{
							TintColor = Color3.fromRGB(255, 255, 0)
						}
					):Play()
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.Explosion)
				end

				local sound3 = PeoUtils.CreateSound({
					RollOffMaxDistance = 300,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://165970126",
					Volume = 0.5
				})
				_G.PU:Dust(sound3, 3)
				sound3.Parent = rootPart
				sound3:Play()
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Light["Light Explosion Big"]:Clone()
				clone2.CFrame = CFrame.new(cFMouse.p)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 1.6)
				TweenService:Create(
					clone2.Light,
					TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
					{
						Range = 60
					}
				):Play()

				for _, emitter in pairs(clone2.Attachment:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
		elseif mode == "Light X Awake" then
			local lightFolder = v2.LightFolder
			local character = v2.Character
			local rootPart = v2.RootPart
			local mouseValue = v2.MouseValue
			local A0 = v2.A0
			tick()
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://10145836440",
				Volume = 2
			})
			_G.PU:Dust(sound, 10)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.FruitEffect.Light.Part2:Clone()
			clone.CFrame = CFrame.new(mouseValue.Value)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 10)
			A0.Beam1.Attachment1 = clone.A1
			A0.Beam2.Attachment1 = clone.A1
			A0.Beam1.Enabled = true
			A0.Beam2.Enabled = true
			TweenService:Create(A0.Beam1, TweenInfo.new(0.25), {
				Width0 = 5,
				Width1 = 5
			}):Play()
			TweenService:Create(A0.Beam2, TweenInfo.new(0.25), {
				Width0 = 5,
				Width1 = 5
			}):Play()

			for _, emitter in pairs(clone.A1:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			PeodizService.HeartbeatWait({
				Time = 5,
				WaitTime = 0.05
			}, function()
				if not lightFolder:IsDescendantOf(character) then
					return true
				end

				local p = CFrame.new(rootPart.Position, mouseValue.Value).p
				local v3 = CFrame.new(rootPart.Position, mouseValue.Value).LookVector * 250
				local position = p + v3
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Effects, character, workspace.CharacterWorkshop }
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(p, v3, raycastParams)

				if raycastResult then
					position = raycastResult.Position
				end

				local _ = (rootPart.Position - position).Magnitude
				local v4 = math.clamp((rootPart.Position - position).Magnitude, 0, 250)
				local cFrame2 = CFrame.new(rootPart.Position, position) * CFrame.new(0, 0, -v4)
				TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					CFrame = cFrame2
				}):Play()
			end)

			if A0:FindFirstChild("Beam1") then
				TweenService:Create(A0.Beam1, TweenInfo.new(0.5), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end

			if A0:FindFirstChild("Beam2") then
				TweenService:Create(A0.Beam2, TweenInfo.new(0.5), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end

			_G.PU:Dust(clone, 1.5)
			TweenService:Create(sound, TweenInfo.new(0.5), {
				Volume = 0
			}):Play()
			_G.PU:Dust(sound, 1)

			for _, emitter in pairs(clone.A1:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		elseif mode == "Light X Awake Ex" then
			local clone = ReplicatedStorage.Chest.FruitEffect.Light["Light Explosion Tiny X"]:Clone()
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1)
			TweenService:Create(
				clone.Light,
				TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
				{
					Range = 50
				}
			):Play()

			for _, emitter in pairs(clone.Attachment:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		elseif mode == "Light C Awake" then
			local _ = v2.RootPart
			local _ = v2.RightHand
			local startCF = v2.StartCF
			local endCF = v2.EndCF
			local character = v2.Character
			local animation = v2.Animation
			task.spawn(function()
				local cframe = CFrame.new(startCF.p, endCF.p)
				local v3 = math.floor((startCF.Position - endCF.Position).Magnitude / 25)
				task.spawn(function()
					local v4 = {}
					local v5 = {}

					for i = 0, v3 do
						local v6 = i % 2 == 1 and -25 or 25

						if i == 0 or i == v3 then
							v4[#v4 + 1] = cframe * CFrame.new(0, 0, -i * 25)
						else
							local part = Instance.new("Part")
							part.CastShadow = false
							part.Color = Color3.fromRGB(255, 229, 121)
							part.Size = Vector3.new()
							part.Material = "Neon"
							part.Anchored = true
							part.CanCollide = false
							part.CFrame = cframe * CFrame.new(0, v6, -i * 25)
							part.Transparency = 1
							part.Parent = workspace.Effects
							_G.PU:Dust(part, 2)
							v5[i] = part
							v4[#v4 + 1] = cframe * CFrame.new(0, v6, -i * 25)
						end
					end

					PeodizService.ForLoop({
						Step = #v4,
						WaitTime = 0.05
					}, function(p)
						local v6 = math.floor(p * #v4)
						local v7 = v4[v6]
						local v8 = v4[v6 + 1]

						if v8 then
							if v5[v6] then
								spawn(function()
									TweenService:Create(v5[v6], TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
										Transparency = 0,
										Size = createVector(14, 0.4, 8)
									}):Play()
									wait(0.5)
									local clone = ReplicatedStorage.Chest.FruitEffect.Light.LightEx33:Clone()
									clone.CFrame = v5[v6].CFrame
									clone.Parent = workspace.Effects
									task.spawn(function()
										for _, emitter in pairs(clone.Attachment:GetChildren()) do
											if emitter:IsA("ParticleEmitter") then
												emitter:Emit(emitter:GetAttribute("EmitCount"))
											end
										end
									end)
									_G.PU:Dust(clone, 1)
									TweenService:Create(v5[v6], TweenInfo.new(0.25), {
										Size = Vector3.new(),
										Transparency = 1
									}):Play()
								end)
							end

							if v5[v6 + 1] then
								spawn(function()
									TweenService:Create(v5[v6 + 1], TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
										Transparency = 0,
										Size = createVector(14, 0.4, 8)
									}):Play()
									wait(0.5)
									TweenService:Create(v5[v6 + 1], TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
										Size = Vector3.new(),
										Transparency = 1
									}):Play()
								end)
							end

							local magnitude = (v7.p - v8.p).Magnitude
							local part = Instance.new("Part")
							part.CastShadow = false
							part.Color = Color3.fromRGB(255, 229, 121)
							part.Size = Vector3.new()
							part.Material = "Neon"
							part.Anchored = true
							part.CanCollide = false
							part.CFrame = CFrame.new(v7.p, v8.p)
							part.Transparency = -1
							part.Parent = workspace.Effects
							TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
								Size = Vector3.new(2, 2, magnitude),
								CFrame = CFrame.new(v7.p, v8.p) * CFrame.new(0, 0, -magnitude / 2)
							}):Play()
							_G.PU:Dust(part, 2)
							task.spawn(function()
								wait(0.1)
								local clone = ReplicatedStorage.Chest.FruitEffect.Light.LightEx33.Attachment.spark:Clone()
								clone.Parent = part
								clone:Emit(clone:GetAttribute("EmitCount"))
								_G.PU:Dust(clone, 1)
							end)
							coroutine.wrap(function()
								wait(0.75)
								TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
									Size = createVector(0.1, 2, 0),
									Transparency = 1,
									CFrame = CFrame.new(v7.p, v8.p) * CFrame.new(0, 0, -magnitude)
								}):Play()
							end)()
						end
					end)
					task.delay(10, function()
						table.clear(v4)
						table.clear(v5)
					end)
				end)
				local v4 = {}
				local v5 = {}

				for i = 0, v3 do
					local v6 = i % 2 == 1 and -25 or 25

					if i == 0 or i == v3 then
						v4[#v4 + 1] = cframe * CFrame.new(0, 0, -i * 25)
					else
						local part = Instance.new("Part")
						part.CastShadow = false
						part.Color = Color3.fromRGB(255, 229, 121)
						part.Size = Vector3.new()
						part.Material = "Neon"
						part.Anchored = true
						part.CanCollide = false
						part.CFrame = cframe * CFrame.new(v6, 0, -i * 25)
						part.Transparency = 1
						part.Parent = workspace.Effects
						_G.PU:Dust(part, 2)
						v5[i] = part
						v4[#v4 + 1] = cframe * CFrame.new(v6, 0, -i * 25)
					end
				end

				PeodizService.ForLoop({
					Step = #v4,
					WaitTime = 0.05
				}, function(p)
					local v6 = math.floor(p * #v4)
					local v7 = v4[v6]
					local v8 = v4[v6 + 1]

					if v8 then
						if v5[v6] then
							spawn(function()
								TweenService:Create(v5[v6], TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
									Transparency = 0,
									Size = createVector(0.4, 14, 8)
								}):Play()
								wait(0.5)
								local clone = ReplicatedStorage.Chest.FruitEffect.Light.LightEx33:Clone()
								clone.CFrame = v5[v6].CFrame
								clone.Parent = workspace.Effects
								task.spawn(function()
									for _, emitter in pairs(clone.Attachment:GetChildren()) do
										if emitter:IsA("ParticleEmitter") then
											emitter:Emit(emitter:GetAttribute("EmitCount"))
										end
									end
								end)
								_G.PU:Dust(clone, 1)
								TweenService:Create(v5[v6], TweenInfo.new(0.25), {
									Size = Vector3.new(),
									Transparency = 1
								}):Play()
							end)
						end

						if v5[v6 + 1] then
							spawn(function()
								TweenService:Create(v5[v6 + 1], TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
									Transparency = 0,
									Size = createVector(0.4, 14, 8)
								}):Play()
								wait(0.5)
								TweenService:Create(v5[v6 + 1], TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
									Size = Vector3.new(),
									Transparency = 1
								}):Play()
							end)
						end

						local magnitude = (v7.p - v8.p).Magnitude
						local part = Instance.new("Part")
						part.CastShadow = false
						part.Color = Color3.fromRGB(255, 229, 121)
						part.Size = Vector3.new()
						part.Material = "Neon"
						part.Anchored = true
						part.CanCollide = false
						part.CFrame = CFrame.new(v7.p, v8.p)
						part.Transparency = -1
						part.Parent = workspace.Effects
						TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
							Size = Vector3.new(2, 2, magnitude),
							CFrame = CFrame.new(v7.p, v8.p) * CFrame.new(0, 0, -magnitude / 2)
						}):Play()
						_G.PU:Dust(part, 2)
						task.spawn(function()
							wait(0.1)
							local clone = ReplicatedStorage.Chest.FruitEffect.Light.LightEx33.Attachment.spark:Clone()
							clone.Parent = part
							clone:Emit(clone:GetAttribute("EmitCount"))
							_G.PU:Dust(clone, 1)
						end)
						coroutine.wrap(function()
							wait(0.75)
							TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
								Size = createVector(0.1, 2, 0),
								Transparency = 1,
								CFrame = CFrame.new(v7.p, v8.p) * CFrame.new(0, 0, -magnitude)
							}):Play()
						end)()
						wait(0.05)
					end
				end)
				task.delay(10, function()
					table.clear(v4)
					table.clear(v5)
				end)

				if player:IsA("Player") and localPlayer == player then
					_G.PU.PlayOneShotAnim({
						Animator = character.Humanoid,
						Animation = animation,
						Speed = 2
					})
				end

				character.HumanoidRootPart.CFrame = endCF * CFrame.new(0, 10, 0)
				task.spawn(function()
					local v6 = endCF

					if (v6.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 300 then
						local clone = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
						clone.Parent = game.Lighting
						_G.PU:Dust(clone, 0.3)
						TweenService:Create(
							clone,
							TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
							{
								TintColor = Color3.fromRGB(255, 255, 170)
							}
						):Play()
					end

					local clone = ReplicatedStorage.Chest.FruitEffect.Light.LightExx:Clone()
					_G.PU:Dust(clone, 1.25)
					clone.CFrame = CFrame.new(v6.p)
					clone.Parent = workspace.Effects
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 300,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://142691026",
						Volume = 3
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = clone
					sound:Play()
					TweenService:Create(
						clone.Light,
						TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
						{
							Range = 60
						}
					):Play()

					for _, emitter in pairs(clone.Attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					task.delay(0.25, function()
						local cframe2 = CFrame.new(endCF.p)

						for i = 1, 6 do
							local v7 = cframe2 * CFrame.Angles(0, 6.283185307179586 * i / 6, 0) * CFrame.new(0, 0, -75)

							if (v7.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 100 then
								_G.BeckCameraShake(_G.CameraShakerModule.Presets.SmallBump)
								local clone2 = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
								clone2.Parent = game.Lighting
								_G.PU:Dust(clone2, 0.3)
								TweenService:Create(
									clone2,
									TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
									{
										TintColor = Color3.fromRGB(255, 255, 170)
									}
								):Play()
							end

							local clone2 = ReplicatedStorage.Chest.FruitEffect.Light.LightEx22:Clone()
							_G.PU:Dust(clone2, 1.25)
							clone2.CFrame = CFrame.new(v7.p)
							clone2.Parent = workspace.Effects
							local sound2 = PeoUtils.CreateSound({
								RollOffMaxDistance = 300,
								RollOffMinDistance = 10,
								RollOffMode = Enum.RollOffMode.InverseTapered,
								SoundId = "rbxassetid://142691026",
								Volume = 3
							})
							_G.PU:Dust(sound2, 3)
							sound2.Parent = clone2
							sound2:Play()

							for _, emitter in pairs(clone2.Attachment:GetChildren()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end

							wait(0.1)
						end
					end)
				end)
			end)
		elseif mode == "Light V Awake Ex" then
			local clone = ReplicatedStorage.Chest.FruitEffect.Light["Light Explosion Tiny"]:Clone()
			clone.CFrame = CFrame.new(cFrame.p)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://165970126",
				Volume = 0.4
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://10122093531",
				Volume = 3
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone
			sound2:Play()
			task.spawn(function()
				wait(0.5)

				if sound and sound.Parent then
					TweenService:Create(sound, TweenInfo.new(0.25), {
						Volume = 0
					}):Play()
				end

				if sound2 and sound2.Parent then
					TweenService:Create(sound2, TweenInfo.new(0.25), {
						Volume = 0
					}):Play()
				end
			end)
			TweenService:Create(
				clone.Light,
				TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
				{
					Range = 60
				}
			):Play()

			for _, emitter in pairs(clone.Attachment:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		elseif mode == "Light Awake Charge" then
			local target = v2.Target
			local lightFolder = v2.LightFolder
			local character

			if player:IsA("Player") then
				character = player.Character
			else
				character = player
			end

			task.spawn(function()
				local pointLight = Instance.new("PointLight")
				pointLight.Color = Color3.fromRGB(255, 255, 0)
				pointLight.Brightness = 2.5
				pointLight.Enabled = true
				pointLight.Range = 20
				pointLight.Parent = target
				_G.PU:Dust(pointLight, 30)
				PeodizService.HeartbeatWait({
					Time = 5,
					WaitTime = 0.2
				}, function()
					if not lightFolder:IsDescendantOf(character) or character.Humanoid.Health <= 0 then
						return true
					end

					TweenService:Create(
						pointLight,
						TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
						{
							Range = 30
						}
					):Play()
				end)
				TweenService:Create(pointLight, TweenInfo.new(0.5), {
					Range = 0
				}):Play()
				_G.PU:Dust(pointLight, 1)
			end)
			task.spawn(function()
				local character2 = player

				if player:IsA("Player") then
					character2 = player.Character
				end

				PeodizService.HeartbeatWait({
					Time = 5,
					WaitTime = 0.05
				}, function()
					if not lightFolder:IsDescendantOf(character2) or character2.Humanoid.Health <= 0 then
						return true
					end

					local cFrame2 = target.CFrame * CFrame.new(0, 0, -5.5) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					math.random(8, 10)
					local v4 = math.random(5, 10) / 10
					local v5 = math.random(15, 35)
					local clone = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
					clone.CastShadow = false
					clone.Transparency = -1
					clone.Size = Vector3.new(v4, v4, math.random(8, 10))
					clone.Color = Color3.fromRGB(255, 255, 127)
					clone.CFrame = cFrame2 * CFrame.new(0, 0, v5)
					clone.Parent = workspace.Effects
					TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = cFrame2
					}):Play()
					_G.PU:Dust(clone, 0.14)
				end)
			end)
		elseif mode == "Gravity Meteor Explosion" then
			task.spawn(function()
				if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < 200 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
					local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone.Enabled = true
					clone.Parent = workspace.CurrentCamera
					clone.Size = 0
					_G.PU:Dust(clone, 1.5)
					TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential), {
						Size = 10
					}):Play()
					wait(0.5)
					TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
						Size = 0
					}):Play()
				end
			end)
			local clone = ReplicatedStorage.Chest.Etc.Explosion4:Clone()
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local v3 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://6533506531",
				Volume = 1.5
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()

			for _, child in pairs(clone.Attachment:GetChildren()) do
				if child:isA("ParticleEmitter") then
					child:Emit(child:GetAttribute("EmitCount"))
				end
			end

			task.spawn(function()
				local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
				clone2.Color = Color3.fromRGB(255, 85, 0)
				clone2.CFrame = CFrame.new(cFrame.p) * CFrame.Angles(3.141592653589793, 0, 0)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 1)
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(250, 10, 250),
					Transparency = 1
				}):Play()
			end)
			task.spawn(function()
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Gravity.Fire:Clone()
				clone2.CFrame = CFrame.new(cFrame.p)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 2)
				delay(1, function()
					if clone2:FindFirstChild("par") then
						clone2.par.Enabled = false
					end
				end)
			end)
		end
	end
end