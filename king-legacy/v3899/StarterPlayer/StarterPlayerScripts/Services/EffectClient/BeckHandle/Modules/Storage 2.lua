local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local localPlayer = game.Players.LocalPlayer
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local System = require(ReplicatedStorage.Chest.Modules.System)
local Utility = require(ReplicatedStorage.Chest.Modules.Utility)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local BoatTween = require(ReplicatedStorage.Chest.Modules.BoatTween)

function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

return function(list)
	local v, cFrame2, v3, _ = unpack(list)
	local success, result = pcall(function()
		if type(v3) == "table" and v3.LoopDistance then
			return false
		end

		if cFrame2 then
			return (localPlayer.Character.HumanoidRootPart.Position - cFrame2.p).Magnitude > 1000
		end

		return false
	end)

	if success then
		if result then
			return
		end

		local mode = v3.Mode

		if mode == "Aquatic Anchor Z" then
			local effects = workspace.Effects
			local aquaticAnchor = ReplicatedStorage.Chest.SwordEffect["Aquatic Anchor"]
			local character = v3.Character
			local chargeFolder = v3.ChargeFolder
			local startCF = v3.StartCF
			local rootPart = v3.RootPart
			local cFValue = v3.CFValue

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 200 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
			end

			task.spawn(function()
				local clone = aquaticAnchor.ParticlePart:Clone()
				_G.PU:Dust(clone, 5)
				clone.CFrame = CFrame.new(rootPart.Position)
				clone.Parent = effects
				local v4 = {
					RollOffMaxDistance = 300,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://9664693369",
					Volume = 2
				}
				local sound = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()

				for _, child in pairs(clone.Attachment2:GetChildren()) do
					if not child:isA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(child, 3)
					child:Emit(child:GetAttribute("EmitCount"))
				end
			end)
			local clone = aquaticAnchor.WaterBall:Clone()
			_G.PU:Dust(clone, 15)
			clone.CFrame = rootPart.CFrame * CFrame.new(0, 0, 0)
			clone.Parent = effects
			TweenService:Create(clone, TweenInfo.new(0.5), {
				Size = createVector(50, 50, 50)
			}):Play()
			task.spawn(function()
				Utility.EmitParticles(clone)

				for _, child in pairs(clone.Enable:GetChildren()) do
					if child.Name == "Stay" then
						continue
					end

					if child.Name == "StayGlow" then
						child.Enabled = true
					else
						child.Parent = clone
					end
				end

				tick()
				task.spawn(function()
					if clone then
						PeodizService.HeartbeatWait({
							Time = 5,
							WaitTime = 0.05
						}, function()
							if not clone:IsDescendantOf(workspace.Effects) then
								return true
							end

							clone.Size = (createVector(50, 50, 50)):Lerp(
								createVector(40, 40, 40),
								(math.abs((math.sin(tick() * 15))))
							)
						end)
					end
				end)
			end)
			TweenService:Create(clone, TweenInfo.new(0.5), {
				CFrame = rootPart.CFrame * CFrame.new(0, 35, 0)
			}):Play()
			PeodizService.HeartbeatWait({
				Time = 10
			}, function(_)
				if chargeFolder:IsDescendantOf(character) or not cFValue:GetAttribute("CFMouse") then
					return
				else
					return true
				end
			end)
			local cFrame = cFValue.Value

			if clone and clone.Parent then
				for _, child in pairs(clone.Enable:GetChildren()) do
					if child.Name == "Stay" then
						child.Enabled = true
					elseif child.Name == "StayGlow" then
						child.Enabled = true
					else
						child.Parent = clone
					end
				end

				TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = cFrame
				}):Play()
				_G.PU:Dust(clone, 3)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://10889050908",
					Volume = 3
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
			end

			task.spawn(function()
				task.wait(1)
				Utility.ParticleHandler(clone, false)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				local cFrame3 = cFrame
				task.spawn(function()
					local clone2 = aquaticAnchor.AnchorSmash2:Clone()
					_G.PU:Dust(clone2, 2)
					clone2.CFrame = CFrame.new(cFrame3.p)
					clone2.Position += createVector(0, 1, 0)
					clone2.Parent = effects
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.Linear,
						SoundId = "rbxassetid://10895391181",
						Volume = 1.5
					})
					_G.PU:Dust(sound, 2)
					sound.Parent = clone2
					sound:Play()
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 300,
						RollOffMinDistance = 0,
						RollOffMode = Enum.RollOffMode.Linear,
						SoundId = "rbxassetid://2648563122",
						Volume = 0.3
					})
					_G.PU:Dust(sound2, 2)
					sound2.Parent = clone2
					sound2:Play()

					for _, emitter in pairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						_G.ParticleSize(emitter, 3)
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end

					if (localPlayer.Character.HumanoidRootPart.Position - cFrame3.p).Magnitude < 200 then
						_G.CameraShake:ShakeOnce(5, 9, 0, 0.5, createVector(0, -5, 0))
						Utility.AddColorDepth(0.6, 0.3)
						Utility.BloomBlur()
					end
				end)
				task.spawn(function()
					local v5 = CFrame.new(cFrame3.p) * CFrame.new(0, 25, 0)
					local ray = Ray.new(v5.p, createVector(0, -50, 0))
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
					local normal

					if raycastResult then
						normal = raycastResult.Normal or nil
					end

					local _ = raycastResult and raycastResult.Material

					if instance then
						local clone2 = aquaticAnchor.Floor:Clone()
						_G.PU:Dust(clone2, 2)
						clone2.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
						clone2.Parent = effects
						Utility.EmitParticles(clone2)
					end
				end)
			end)
		elseif mode == "Gravity X Explosion" then
			local startCF = v3.StartCF

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 200 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			task.spawn(function()
				local clone = ReplicatedStorage.Chest.FruitEffect.Gravity["Gravity Explosion - WIP"]:Clone()
				_G.PU:Dust(clone, 1.2)
				clone.CFrame = startCF
				clone.Parent = workspace.Effects
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://11770086141",
					Volume = 1
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				PeodizService.ForLoop({
					Step = 20
				}, function(p)
					local v4 = math.floor(p * 20)
					local cframe = CFrame.new(startCF.p) * CFrame.Angles(0, 6.283185307179586 * v4 / 20, 0) * CFrame.new(
						0,
						0,
						-25
					)
					local ray = Ray.new(cframe.p, createVector(0, -25, 0))
					local _, v5, _ = cframe:ToOrientation()
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
					local _ = raycastResult and raycastResult.Normal
					local material = raycastResult and raycastResult.Material or nil

					if instance then
						local part = Instance.new("Part")
						part.Anchored = true
						part.CanCollide = false
						part.CFrame = CFrame.new(startCF.p) * CFrame.fromOrientation(0, v5, 0)
						part.Size = createVector(0, 0, 0)
						part.Parent = workspace.Effects
						TweenService:Create(
							part,
							TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v5, 0) * CFrame.new(
									0,
									math.random(-20, 1) / 10,
									0
								) * CFrame.Angles(math.rad((math.random(30, 90))), 0, 0),
								Size = createVector(8.625, 5, 5)
							}
						):Play()
						TweenService:Create(
							part,
							TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 2),
							{
								Transparency = 1
							}
						):Play()
						part.Material = material or "SmoothPlastic"
						part.BrickColor = instance.BrickColor
						_G.PU:Dust(part, 3)
					end
				end)
			end)
		elseif mode == "Gravity X Explosion Dino" then
			local startCF = v3.StartCF

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 20000 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Explosion)
			end

			task.spawn(function()
				PeodizService.ForLoop({
					Step = 9
				}, function(p)
					local v4 = math.floor(p * 9)
					local v5 = math.random(50, 100)
					local v6 = cFrame2 * CFrame.Angles(0, 0.6981317007977318 * v4, 0) * CFrame.new(0, 0, -10)
					local clone = ReplicatedStorage.Chest.FruitEffect.OpNew.bigsmoke:Clone()
					clone.Anchored = true
					clone.Color = Color3.fromRGB(v5, v5, v5)
					clone.CanCollide = false
					clone.Size = Vector3.new()
					clone.CFrame = v6 * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 2.5)
					TweenService:Create(
						clone,
						TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true, 0),
						{
							Size = createVector(2043.6001, 1986.2, 2125.4)
						}
					):Play()
					TweenService:Create(clone, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = cFrame2 * CFrame.Angles(0, 0.6981317007977318 * v4, 0) * CFrame.new(
							0,
							0,
							-math.random(25, 2500)
						) * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
					}):Play()
				end)
			end)
			task.spawn(function()
				PeodizService.ForLoop({
					Step = 12
				}, function(_)
					local v4 = math.random(50, 100)
					local clone = ReplicatedStorage.Chest.FruitEffect.OpNew.bigsmoke:Clone()
					clone.Anchored = true
					clone.Color = Color3.fromRGB(v4, v4, v4)
					clone.CanCollide = false
					clone.Size = createVector(2043.6001, 1986.2, 2125.4)
					clone.CFrame = cFrame2 * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1.5)
					TweenService:Create(
						clone,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = Vector3.new()
						}
					):Play()
					TweenService:Create(clone, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = cFrame2 * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						) * CFrame.new(0, 0, -math.random(60, 6000))
					}):Play()
				end)
			end)
			local clone = ReplicatedStorage.Chest.FruitEffect.OpNew.spike:Clone()
			clone.CFrame = cFrame2 * CFrame.new(0, 19, 0)
			clone.Anchored = true
			clone.CanCollide = false
			clone.Size = createVector(0, 6500, 0)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11770086141",
				Volume = 1
			})
			_G.PU:Dust(sound, 2)
			sound.Parent = clone
			sound:Play()
			TweenService:Create(
				clone,
				TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true, 0),
				{
					CFrame = cFrame2 * CFrame.new(0, 35, 0) * CFrame.Angles(0, 3.141592653589793, 0),
					Size = createVector(3211.9, 7027.3003, 3168.9)
				}
			):Play()
			TweenService:Create(clone, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = cFrame2 * CFrame.new(0, 30, 0) * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			spawn(function()
				wait(1.6)
				TweenService:Create(
					clone,
					TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
		elseif mode == "Gravity X Explosion Blessing" then
			local startCF = v3.StartCF

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude < 250 then
				_G.CameraShake:ShakeOnce(7, 12, 0, 1, createVector(0, -2, 0))
				Utility.BloomBlur()
			end

			local X = ReplicatedStorage.Chest.SwordEffect.XmasBlade.X
			local effects = workspace.Effects
			local clone = X.Impact:Clone()
			_G.PU:Dust(clone, 4)
			clone.CFrame = startCF
			clone.Parent = effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://15805564649",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			Utility.EmitParticles(clone)
		elseif mode == "Gravity Ring Loop" then
			task.spawn(function()
				for _ = 1, v3.Num or 5 do
					wait(0.2)
					local clone = ReplicatedStorage.Chest.FruitEffect.Gravity.hitbox:Clone()
					_G.PU:Dust(clone, 1)
					clone.CFrame = cFrame2
					clone.Parent = workspace.Effects
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 300,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://4887370202",
						Volume = 0.5
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = clone
					sound:Play()
					TweenService:Create(clone, TweenInfo.new(0.7), {
						Size = createVector(150, 1.5, 150)
					}):Play()
					TweenService:Create(clone.Decal, TweenInfo.new(0.5), {
						Transparency = 1
					}):Play()
				end
			end)
			task.spawn(function()
				local meteor = v3.Meteor
				PeodizService.HeartbeatWait({
					Time = 10,
					WaitTime = 0.15
				}, function()
					if not meteor:IsDescendantOf(workspace.Effects) then
						return true
					end

					local clone = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
					clone.Transparency = -1
					clone.Color = Color3.fromRGB(255, 255, 255)

					if meteor:FindFirstChild("Inner") then
						clone.CFrame = meteor.Inner.CFrame * CFrame.Angles(0, 0, -3.141592653589793)
					end

					clone.Parent = workspace.Effects
					TweenService:Create(clone, TweenInfo.new(0.45, Enum.EasingStyle.Exponential), {
						Size = createVector(30, 2.5, 30) * math.random(10, 20) / 8,
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone, 0.5)
				end)
			end)
		elseif mode == "Aquatic Anchor X" then
			local effects = workspace.Effects
			local aquaticAnchor = ReplicatedStorage.Chest.SwordEffect["Aquatic Anchor"]
			local startCF = v3.StartCF

			for i = 1, 5 do
				local v4 = startCF * CFrame.new(0, 0, i * -25)
				local v7 = i * 1
				task.spawn(function()
					local clone = aquaticAnchor.AnchorSmash2:Clone()
					_G.PU:Dust(clone, 2)
					clone.CFrame = CFrame.new(v4.p)
					clone.Parent = effects
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.Linear,
						SoundId = "rbxassetid://10895391181",
						Volume = 1.5
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = clone
					sound:Play()
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 300,
						RollOffMinDistance = 0,
						RollOffMode = Enum.RollOffMode.Linear,
						SoundId = "rbxassetid://2648563122",
						Volume = 0.3
					})
					_G.PU:Dust(sound2, 3)
					sound2.Parent = clone
					sound2:Play()

					for i2, emitter in pairs(clone:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						_G.ParticleSize(emitter, v7)
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end

					if (localPlayer.Character.HumanoidRootPart.Position - v4.Position).Magnitude < 250 then
						_G.CameraShake:ShakeOnce(2, 5, 0, 0.2)
					end
				end)
				local v8 = v4
				task.spawn(function()
					local v9 = CFrame.new(v8.p) * CFrame.new(0, 25, 0)
					local ray = Ray.new(v9.p, createVector(0, -50, 0))
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
					local normal

					if raycastResult then
						normal = raycastResult.Normal or nil
					end

					local material = raycastResult and raycastResult.Material

					if instance then
						local clone = aquaticAnchor.Floor:Clone()
						_G.PU:Dust(clone, 2)
						clone.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
							0,
							6.283185307179586 * math.random(),
							0
						)
						clone.Parent = effects
						Utility.EmitParticles(clone)
					end
				end)
				wait(0.25)
			end
		elseif mode == "Aquatic Anchor Ball" then
			local ball = v3.Ball
			tick()
			task.spawn(function()
				if ball then
					PeodizService.HeartbeatWait({
						Time = 5,
						WaitTime = 0.05
					}, function()
						if not ball:IsDescendantOf(workspace.Effects) then
							return true
						end

						ball.Size = (createVector(50, 50, 50)):Lerp(
							createVector(40, 40, 40),
							(math.abs((math.sin(tick() * 5))))
						)
					end)
				end
			end)
		elseif mode == "Pondere Blade X" then
			local startCF = v3.StartCF

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 150 then
				local clone = ReplicatedStorage.Chest.SwordEffect.Etc.Pondere3:Clone()
				clone.Enabled = true
				clone.Parent = game.Lighting
				_G.PU:Dust(clone, 0.01)
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.SmallExplosion)
			end

			tick()
			local clone = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone.Color = Color3.fromRGB(170, 170, 255)
			clone.CastShadow = false
			clone.Transparency = -1
			clone.Anchored = true
			clone.CanCollide = false
			clone.Size = createVector(50, 50, 50)
			clone.CFrame = CFrame.new(startCF.p)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 0.15)
			TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Size = createVector(0, 75, 0),
				CFrame = clone.CFrame * CFrame.new(0, 37.5, 0)
			}):Play()
			task.spawn(function()
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Gravity.Pondere2:Clone()
				clone2.CFrame = startCF * CFrame.new(0, 10, 0) * CFrame.Angles(0, 0, -1.5707963267948966)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 2)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://10891083054",
					Volume = 3
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone2
				sound:Play()
				clone2.Attachment.SpreadSlashes:Emit(10)
				task.spawn(function()
					local ray = Ray.new(startCF.p, createVector(0, -30, 0))
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = {
						workspace.Effects,
						workspace.PlayerCharacters,
						workspace.CharacterWorkshop
					}
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
					local normal

					if raycastResult then
						normal = raycastResult.Normal or nil
					end

					local _ = raycastResult and raycastResult.Material

					if instance then
						local clone3 = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
						clone3.Decal.Transparency = -0.2
						clone3.Decal.Texture = "rbxassetid://7068839334"
						clone3.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(0, -1, 0)
						clone3.Parent = workspace.Effects
						_G.PU:Dust(clone3, 1)
						TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), {
							Size = createVector(45, 0, 45)
						}):Play()
						task.spawn(function()
							wait(0.25)
							TweenService:Create(clone3.Decal, TweenInfo.new(0.25), {
								Transparency = 1
							}):Play()
						end)
					end
				end)
				PeodizService.HeartbeatWait({
					Time = 0.5
				}, function()
					task.spawn(function()
						for _, emitter in pairs(clone2:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end
					end)
					local v4 = math.random(5, 10) / 15
					local clone3 = ReplicatedStorage.Chest.FruitEffect.Gravity.Thing:Clone()
					clone3.Transparency = -1
					clone3.Size = Vector3.new(v4, math.random(5, 25), v4)
					clone3.Color = math.random(1, 2) == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(
						170,
						85,
						255
					)
					clone3.CFrame = startCF * CFrame.new(math.random(-22, 22), math.random(1, 15), math.random(-22, 22))
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 0.01)
				end)
			end)

			for i = 1, 20 do
				local cframe = CFrame.new(startCF.p) * CFrame.new(0, 5, 0) * CFrame.Angles(
					0,
					6.283185307179586 * i / 20,
					0
				) * CFrame.new(0, 0, -25)
				local ray = Ray.new(cframe.p, createVector(0, -25, 0))
				local _, v4, _ = cframe:ToOrientation()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
				local _ = raycastResult and raycastResult.Normal
				local material = raycastResult and raycastResult.Material or nil

				if not instance then
					continue
				end

				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.CFrame = CFrame.new(startCF.p)
				part.Size = createVector(0, 0, 0)
				part.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v4, 0) * CFrame.new(
						0,
						math.random(-20, 20) / 10,
						0
					) * CFrame.Angles(math.rad((math.random(30, 60))), 0, 0),
					Size = createVector(12.5, 5, 5)
				}):Play()
				delay(0.5, function()
					TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
						CFrame = part.CFrame * CFrame.new(0, -5, 0),
						Transparency = 1
					}):Play()
				end)
				part.Material = material or "SmoothPlastic"
				part.BrickColor = instance.BrickColor
				_G.PU:Dust(part, 1)
			end
		elseif mode == "Gamma Knife Fix" then
			local rootPart = v3.RootPart
			local chargeFolder = v3.ChargeFolder
			PeodizService.HeartbeatWait({
				Time = 10,
				WaitTime = 0.25
			}, function()
				if not chargeFolder:IsDescendantOf(v.Character) or v.Character.Humanoid.Health <= 0 then
					return true
				end

				local v4 = {}

				for _ = 1, 8 do
					local v5 = math.random(55, 70) / 10
					v4[#v4 + 1] = (rootPart.CFrame * CFrame.new(
						math.random(-v5, v5),
						math.random(-5, v5),
						math.random(-v5, v5)
					)).p
				end

				task.spawn(function()
					PeodizService.ForLoop({
						Step = #v4
					}, function(p)
						local v5 = math.floor(p * #v4)

						if v4[v5 - 1] then
							local v6 = math.random(50, 120) / 300
							local color = Color3.fromRGB(51, 85, 23)

							if math.random(1, 2) == 1 then
								color = Color3.fromRGB(202, 255, 151)
							end

							local part = Instance.new("Part")
							part.Material = "Neon"
							part.CastShadow = false
							part.Size = Vector3.new(0, 0, (v4[v5 - 1] - v4[v5]).magnitude)
							part.Color = Color3.fromRGB(120, 191, 132)
							part.Anchored = true
							part.Transparency = 0
							part.CanCollide = false
							part.CFrame = CFrame.new((v4[v5 - 1] + v4[v5]) / 2, v4[v5 - 1])
							part.Parent = workspace.Effects
							TweenService:Create(
								part,
								TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									Size = Vector3.new(v6, v6, (v4[v5 - 1] - v4[v5]).magnitude)
								}
							):Play()
							spawn(function()
								wait(0.05)
								TweenService:Create(
									part,
									TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
									{
										Color = color,
										Size = Vector3.new(0, 0, (v4[v5 - 1] - v4[v5]).magnitude)
									}
								):Play()
								wait()
								TweenService:Create(
									part,
									TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end)
							_G.PU:Dust(part, 1)
						end
					end)
					task.delay(10, function()
						table.clear(v4)
					end)
				end)
			end)
		elseif mode == "OpOp Shock Fix" then
			local rootPart = v3.RootPart
			local chargeFolder = v3.ChargeFolder
			PeodizService.HeartbeatWait({
				Time = 10,
				WaitTime = 0.25
			}, function()
				if not chargeFolder:IsDescendantOf(v.Character) or v.Character.Humanoid.Health <= 0 then
					return true
				end

				local v4 = {}

				for _ = 1, 8 do
					local v5 = math.random(55, 70) / 10
					v4[#v4 + 1] = (rootPart.CFrame * CFrame.new(
						math.random(-v5, v5),
						math.random(-5, v5),
						math.random(-v5, v5)
					)).p
				end

				local color = Color3.fromRGB(255, 232, 116)

				if math.random(1, 2) == 1 then
					color = Color3.fromRGB(134, 217, 255)
				end

				spawn(function()
					PeodizService.ForLoop({
						Step = #v4
					}, function(p)
						local v5 = math.floor(p * #v4)

						if v4[v5 - 1] then
							local v6 = math.random(50, 120) / 300
							local color2

							if color == Color3.fromRGB(255, 232, 116) then
								color2 = Color3.fromRGB(85, 68, 28)

								if math.random(1, 2) == 1 then
									color2 = Color3.fromRGB(255, 240, 184)
								end
							else
								color2 = Color3.fromRGB(25, 52, 85)

								if math.random(1, 2) == 1 then
									color2 = Color3.fromRGB(194, 234, 255)
								end
							end

							local part = Instance.new("Part")
							part.Material = "Neon"
							part.CastShadow = false
							part.Size = Vector3.new(0, 0, (v4[v5 - 1] - v4[v5]).magnitude)
							part.Color = color
							part.Anchored = true
							part.Transparency = 0
							part.CanCollide = false
							part.CFrame = CFrame.new((v4[v5 - 1] + v4[v5]) / 2, v4[v5 - 1])
							part.Parent = workspace.Effects
							TweenService:Create(
								part,
								TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									Size = Vector3.new(v6, v6, (v4[v5 - 1] - v4[v5]).magnitude)
								}
							):Play()
							spawn(function()
								wait(0.05)
								TweenService:Create(
									part,
									TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
									{
										Color = color2,
										Size = Vector3.new(0, 0, (v4[v5 - 1] - v4[v5]).magnitude)
									}
								):Play()
								wait()
								TweenService:Create(
									part,
									TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end)
							_G.PU:Dust(part, 1)
						end
					end)
					task.delay(10, function()
						table.clear(v4)
					end)
				end)
			end)
		elseif mode == "Daybreak Cleaver Z Re" then
			local effects = workspace.Effects
			local daybreakCleaver = ReplicatedStorage.Chest.SwordEffect["Daybreak Cleaver"]
			local startCF = v3.StartCF
			local clone = daybreakCleaver.Impact:Clone()
			_G.PU:Dust(clone, 2)
			clone.Size = createVector(50, 1, 50)
			clone.CFrame = startCF
			clone.Parent = effects
			Utility.EmitParticles(clone)
			local v4 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11042638602",
				Volume = 0.5
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 5)
			sound.Parent = clone
			sound:Play()
			task.spawn(function()
				local v5 = CFrame.new(startCF.p) * CFrame.new(0, 25, 0)
				local ray = Ray.new(v5.p, createVector(0, -50, 0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
				local normal

				if raycastResult then
					normal = raycastResult.Normal or nil
				end

				local _ = raycastResult and raycastResult.Material

				if instance then
					local clone2 = daybreakCleaver.Floor:Clone()
					_G.PU:Dust(clone2, 2)
					clone2.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						6.283185307179586 * math.random(),
						0
					)
					clone2.Parent = effects
					Utility.EmitParticles(clone2)
				end
			end)
			local _ = CFrame.new(startCF.p) * CFrame.new(0, 25, 9.5)

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 150 then
				_G.CameraShake:ShakeOnce(4, 8, 0, 0.3)
			end

			wait(0.35)

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 250 then
				_G.CameraShake:ShakeOnce(8, 12, 0, 0.6)
				Utility.AddColorDepth(0.6, 0.3)
			end

			local clone2 = daybreakCleaver.Impact:Clone()
			_G.PU:Dust(clone2, 2)
			clone2.Size = createVector(50, 1, 50)
			clone2.CFrame = startCF
			clone2.Parent = effects

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				_G.ParticleSize(emitter, 2)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			local v5 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11045655712",
				Volume = 0.75
			}
			local sound2 = PeoUtils.CreateSound(v5)
			_G.PU:Dust(sound2, 5)
			sound2.Parent = clone2
			sound2:Play()
			local v6 = CFrame.new(startCF.p) * CFrame.new(0, 25, 0)
			local ray = Ray.new(v6.p, createVector(0, -50, 0))
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
			local instance

			if raycastResult then
				instance = raycastResult.Instance or nil
			end

			local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
			local normal

			if raycastResult then
				normal = raycastResult.Normal or nil
			end

			local _ = raycastResult and raycastResult.Material

			if instance then
				local clone3 = daybreakCleaver.Floor:Clone()
				_G.PU:Dust(clone3, 2)
				clone3.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				)
				clone3.Parent = effects
				Utility.EmitParticles(clone3)
			end
		elseif mode == "Daybreak Cleaver X Re" then
			local effects = workspace.Effects
			local daybreakCleaver = ReplicatedStorage.Chest.SwordEffect["Daybreak Cleaver"]
			local rootPart = v3.RootPart
			local startCF = v3.StartCF
			local cFMouse = v3.CFMouse

			local function Lightning(data)
				local beginCF = data.BeginCF
				local endCF = data.EndCF
				local ex = data.Ex or false
				local unit = (endCF.p - beginCF.p).Unit
				local v4 = (endCF.p - beginCF.p).Magnitude / 5
				local _ = math.random(1, 3) * 3
				local v5 = {}

				for i = 0, 5 do
					local vector2 = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))

					if i == 0 or i == 5 then
						vector2 = Vector3.new()
					end

					v5[#v5 + 1] = beginCF.p + unit * v4 * i + vector2
				end

				task.spawn(function()
					local clone = daybreakCleaver.Trail:Clone()
					_G.PU:Dust(clone, 1)
					clone.CFrame = rootPart.CFrame
					Utility.ParticleHandler(clone, false)
					clone.Parent = effects
					local v6 = false
					PeodizService.ForLoop({
						Step = #v5,
						WaitTime = wait()
					}, function(p)
						local v7 = math.floor(p * #v5)
						local v8 = v5[v7]
						local v9 = v5[v7 + 1]

						if v9 then
							if v6 == false then
								v6 = true
								Utility.ParticleHandler(clone, true)
							end

							if v7 == 5 and ex then
								task.spawn(function()
									if (localPlayer.Character.HumanoidRootPart.Position - endCF.p).Magnitude < 250 then
										_G.CameraShake:ShakeOnce(8, 12, 0, 0.6)
									end

									local clone2 = daybreakCleaver.Impact:Clone()
									_G.PU:Dust(clone2, 2)
									clone2.CFrame = endCF
									clone2.Parent = effects
									Utility.EmitParticles(clone2)
									local v10 = {
										RollOffMaxDistance = 500,
										RollOffMinDistance = 10,
										RollOffMode = Enum.RollOffMode.Linear,
										SoundId = "rbxassetid://11042638602",
										Volume = 0.5
									}
									local sound = PeoUtils.CreateSound(v10)
									_G.PU:Dust(sound, 5)
									sound.Parent = clone2
									sound:Play()
									task.spawn(function()
										local v11 = CFrame.new(endCF.p) * CFrame.new(0, 25, 0)
										local ray = Ray.new(v11.p, createVector(0, -50, 0))
										local raycastParams = RaycastParams.new()
										raycastParams.FilterDescendantsInstances = { workspace.Island }
										raycastParams.FilterType = Enum.RaycastFilterType.Include
										local raycastResult = workspace:Raycast(
											ray.Origin,
											ray.Direction,
											raycastParams
										)
										local instance

										if raycastResult then
											instance = raycastResult.Instance or nil
										end

										local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
										local normal

										if raycastResult then
											normal = raycastResult.Normal or nil
										end

										local _ = raycastResult and raycastResult.Material

										if instance then
											local clone3 = daybreakCleaver.Floor:Clone()
											_G.PU:Dust(clone3, 2)
											clone3.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(
												1.5707963267948966,
												0,
												0
											) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
											clone3.Parent = effects
											Utility.EmitParticles(clone3)
										end
									end)
									local v11 = CFrame.new(endCF.p) * CFrame.new(0, 25, 9.5)
									PeodizService.ForLoop({
										Step = 12
									}, function(p2)
										local v12 = math.floor(p2 * 12)
										task.spawn(function()
											local v13 = v11 * CFrame.new(math.random(-20, 20), 0, math.random(-10, 10))
											PeodizService.ForLoop({
												Step = 3
											}, function(p3)
												local v14 = math.floor(p3 * 3)
												local part = Instance.new("Part")
												_G.PU:Dust(part, 0.02)
												part.CastShadow = false
												part.Color = Color3.fromRGB(141, 112, 255)
												part.Anchored = true
												part.CanCollide = false
												part.Material = Enum.Material.Neon
												part.Size = Vector3.new(
													v12 / 8 + 1 - v14 / 2.2,
													v12 / 8 + 1 - v14 / 2.2,
													v12 * 1.5 + 16
												)
												part.CFrame = v13 * CFrame.Angles(
													math.random() * 7,
													math.random() * 3.141592653589793 * 2,
													math.random() * 7
												) * CFrame.new(0, 0, -part.Size.z / 2)
												part.Parent = workspace.Effects
												v13 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
											end)
										end)
									end)
								end)
							end

							if (localPlayer.Character.HumanoidRootPart.Position - endCF.p).Magnitude < 250 then
								_G.CameraShake:ShakeOnce(1, 2, 0, 0.1)
							end

							local cFrame = CFrame.new(v8, v9) * CFrame.new(0, 0, -(v8 - v9).Magnitude / 2)
							TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
								CFrame = cFrame
							}):Play()
						end
					end)
					task.delay(10, function()
						table.clear(v5)
					end)
				end)
			end

			local v4 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11105535859",
				Volume = 2
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 2)
			sound.Parent = rootPart
			sound:Play()

			for i = 1, 3 do
				if i == 3 then
					Lightning({
						BeginCF = startCF,
						EndCF = cFMouse,
						Ex = true
					})
				else
					Lightning({
						BeginCF = startCF,
						EndCF = cFMouse
					})
				end
			end
		elseif mode == "Daybreak Cleaver Z" then
			local startCF = v3.StartCF
			task.spawn(function()
				if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 200 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
					local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone.Enabled = true
					clone.Parent = workspace.CurrentCamera
					clone.Size = 0
					_G.PU:Dust(clone, 1.5)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = 7
					}):Play()
					wait(0.35)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = 0
					}):Play()
				end
			end)
			local clone = ReplicatedStorage.Chest.SwordEffect["Daybreak Cleaver"].LightningEx:Clone()
			clone.Size = createVector(50, 1, 50)
			clone.CFrame = startCF
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local v4 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11042638602",
				Volume = 0.5
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 5)
			sound.Parent = clone
			sound:Play()

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			task.spawn(function()
				local v5 = CFrame.new(startCF.p) * CFrame.new(0, 25, 0)
				local ray = Ray.new(v5.p, createVector(0, -50, 0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
				local normal

				if raycastResult then
					normal = raycastResult.Normal or nil
				end

				local _ = raycastResult and raycastResult.Material

				if instance then
					local clone2 = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
					clone2.Decal.Transparency = -2
					clone2.Decal.Texture = "rbxassetid://9652024052"
					clone2.Decal.Color3 = Color3.fromRGB(180, 170, 1000)
					clone2.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						6.283185307179586 * math.random(),
						0
					)
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, 1)
					TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
						Size = createVector(75, 0, 75)
					}):Play()
					task.spawn(function()
						wait()
						TweenService:Create(clone2.Decal, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end)
				end
			end)
			local v5 = CFrame.new(startCF.p) * CFrame.new(0, 25, 9.5)
			task.spawn(function()
				PeodizService.ForLoop({
					Step = 12
				}, function(p)
					local v6 = math.floor(p * 12)
					task.spawn(function()
						local v7 = v5 * CFrame.new(math.random(-20, 20), 0, math.random(-10, 10))

						for i = 1, 3 do
							local part = Instance.new("Part")
							part.CastShadow = false
							part.Color = Color3.fromRGB(180, 128, 255)
							part.Anchored = true
							part.CanCollide = false
							part.Material = Enum.Material.Neon
							part.Size = Vector3.new(v6 / 8 + 1 - i / 2.2, v6 / 8 + 1 - i / 2.2, v6 * 1.5 + 16)
							part.CFrame = v7 * CFrame.Angles(
								math.random() * 7,
								math.random() * 3.141592653589793 * 2,
								math.random() * 7
							) * CFrame.new(0, 0, -part.Size.z / 2)
							part.Parent = workspace.Effects
							v7 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
							_G.PU:Dust(part, 0.02)
							wait()
						end
					end)
				end)
			end)
			wait(0.35)
			task.spawn(function()
				if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 300 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.Explosion)
					local clone2 = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
					clone2.Parent = game.Lighting
					_G.PU:Dust(clone2, 0.3)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
						{
							TintColor = Color3.fromRGB(255, 170, 255)
						}
					):Play()
				end
			end)
			local clone2 = ReplicatedStorage.Chest.SwordEffect["Daybreak Cleaver"].LightningEx:Clone()
			clone2.Size = createVector(50, 1, 50)
			clone2.CFrame = startCF
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 2)
			local v6 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11045655712",
				Volume = 0.75
			}
			local sound2 = PeoUtils.CreateSound(v6)
			_G.PU:Dust(sound2, 5)
			sound2.Parent = clone2
			sound2:Play()

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				_G.ParticleSize(emitter, 2)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			local v7 = CFrame.new(startCF.p) * CFrame.new(0, 25, 0)
			local ray = Ray.new(v7.p, createVector(0, -50, 0))
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
			local instance

			if raycastResult then
				instance = raycastResult.Instance or nil
			end

			local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
			local normal

			if raycastResult then
				normal = raycastResult.Normal or nil
			end

			local _ = raycastResult and raycastResult.Material

			if instance then
				local clone3 = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
				clone3.Decal.Transparency = -2
				clone3.Decal.Texture = "rbxassetid://9652024052"
				clone3.Decal.Color3 = Color3.fromRGB(180, 170, 1000)
				clone3.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				)
				clone3.Parent = workspace.Effects
				_G.PU:Dust(clone3, 1)
				TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = createVector(150, 0, 150)
				}):Play()
				task.spawn(function()
					wait()
					TweenService:Create(clone3.Decal, TweenInfo.new(0.25), {
						Transparency = 1
					}):Play()
				end)
			end

			wait(0.1)
			local v8 = CFrame.new(v7.p) * CFrame.new(0, 25, 9.5)
			PeodizService.ForLoop({
				Step = 5
			}, function(p)
				math.floor(p * 5)
				task.spawn(function()
					local v9 = v8 * CFrame.new(math.random(-20, 20), 0, math.random(-10, 10))

					for i = 1, 6 do
						local part = Instance.new("Part")
						part.CastShadow = false
						part.Color = Color3.fromRGB(180, 128, 255)
						part.Anchored = true
						part.CanCollide = false
						part.Material = Enum.Material.Neon
						part.Size = Vector3.new(2 - i / 6, 2 - i / 6, 35 - i / 6)
						part.CFrame = v9 * CFrame.Angles(
							math.random() * 7,
							math.random() * 3.141592653589793 * 2,
							math.random() * 7
						) * CFrame.new(0, 0, -part.Size.z / 2)
						part.Parent = workspace.Effects
						v9 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
						_G.PU:Dust(part, 0.02)
						wait()
					end
				end)
			end)
		elseif mode == "Daybreak Cleaver X" then
			local beginCF = v3.BeginCF
			local endCF = v3.EndCF
			local rootPart = v3.RootPart

			local function Lightning(data)
				local beginCF2 = data.BeginCF
				local endCF2 = data.EndCF
				local ex = data.Ex or false
				local unit = (endCF2.p - beginCF2.p).Unit
				local v4 = (endCF2.p - beginCF2.p).Magnitude / 5
				local v5 = math.random(1, 3) * 3
				local v6 = {}

				for i = 0, 5 do
					local vector2 = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))

					if i == 0 or i == 5 then
						vector2 = Vector3.new()
					end

					v6[#v6 + 1] = beginCF2.p + unit * v4 * i + vector2
				end

				task.spawn(function()
					PeodizService.ForLoop({
						Step = #v6,
						WaitTime = wait()
					}, function(p)
						local v7 = math.floor(p * #v6)
						local v8 = v6[v7]
						local v9 = v6[v7 + 1]

						if v9 then
							if v7 == 5 and ex then
								task.spawn(function()
									task.spawn(function()
										if (localPlayer.Character.HumanoidRootPart.Position - endCF2.p).Magnitude < 200 then
											_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump2)
											local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
											clone.Enabled = true
											clone.Parent = workspace.CurrentCamera
											clone.Size = 0
											_G.PU:Dust(clone, 1.5)
											TweenService:Create(
												clone,
												TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
												{
													Size = 7
												}
											):Play()
											wait(0.35)
											TweenService:Create(
												clone,
												TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
												{
													Size = 0
												}
											):Play()
										end
									end)
									local clone = ReplicatedStorage.Chest.SwordEffect["Daybreak Cleaver"].LightningEx:Clone()
									clone.CFrame = endCF2
									clone.Parent = workspace.Effects
									_G.PU:Dust(clone, 2)
									local v10 = {
										RollOffMaxDistance = 500,
										RollOffMinDistance = 10,
										RollOffMode = Enum.RollOffMode.Linear,
										SoundId = "rbxassetid://11042638602",
										Volume = 0.5
									}
									local sound = PeoUtils.CreateSound(v10)
									_G.PU:Dust(sound, 5)
									sound.Parent = clone
									sound:Play()

									for _, emitter in pairs(clone:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter:Emit(emitter:GetAttribute("EmitCount"))
										end
									end

									task.spawn(function()
										local v11 = CFrame.new(endCF2.p) * CFrame.new(0, 25, 0)
										local ray = Ray.new(v11.p, createVector(0, -50, 0))
										local raycastParams = RaycastParams.new()
										raycastParams.FilterDescendantsInstances = { workspace.Island }
										raycastParams.FilterType = Enum.RaycastFilterType.Include
										local raycastResult = workspace:Raycast(
											ray.Origin,
											ray.Direction,
											raycastParams
										)
										local instance

										if raycastResult then
											instance = raycastResult.Instance or nil
										end

										local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
										local normal

										if raycastResult then
											normal = raycastResult.Normal or nil
										end

										local _ = raycastResult and raycastResult.Material

										if instance then
											local clone2 = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
											clone2.Decal.Transparency = -2
											clone2.Decal.Texture = "rbxassetid://9652024052"
											clone2.Decal.Color3 = Color3.fromRGB(180, 170, 1000)
											clone2.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(
												1.5707963267948966,
												0,
												0
											) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
											clone2.Parent = workspace.Effects
											_G.PU:Dust(clone2, 1)
											TweenService:Create(
												clone2,
												TweenInfo.new(0.25, Enum.EasingStyle.Exponential),
												{
													Size = createVector(75, 0, 75)
												}
											):Play()
											task.spawn(function()
												wait()
												TweenService:Create(clone2.Decal, TweenInfo.new(0.25), {
													Transparency = 1
												}):Play()
											end)
										end
									end)
									local v11 = CFrame.new(endCF2.p) * CFrame.new(0, 25, 9.5)
									PeodizService.ForLoop({
										Step = 12
									}, function(p2)
										local v12 = math.floor(p2 * 12)
										task.spawn(function()
											local v13 = v11 * CFrame.new(math.random(-20, 20), 0, math.random(-10, 10))

											for i = 1, 3 do
												local part = Instance.new("Part")
												part.CastShadow = false
												part.Color = Color3.fromRGB(180, 128, 255)
												part.Anchored = true
												part.CanCollide = false
												part.Material = Enum.Material.Neon
												part.Size = Vector3.new(
													v12 / 8 + 1 - i / 2.2,
													v12 / 8 + 1 - i / 2.2,
													v12 * 1.5 + 16
												)
												part.CFrame = v13 * CFrame.Angles(
													math.random() * 7,
													math.random() * 3.141592653589793 * 2,
													math.random() * 7
												) * CFrame.new(0, 0, -part.Size.z / 2)
												part.Parent = workspace.Effects
												v13 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
												_G.PU:Dust(part, 0.02)
											end
										end)
									end)
								end)
							end

							local part = Instance.new("Part")
							part.CastShadow = false
							part.CanCollide = false
							part.Anchored = true
							part.Color = Color3.fromRGB(180, 128, 255)
							part.Material = "Neon"
							part.Size = Vector3.new(v5, v5, (v8 - v9).Magnitude)
							part.CFrame = CFrame.new(v8, v9) * CFrame.new(0, 0, -(v8 - v9).Magnitude / 2)
							part.Parent = workspace.Effects
							TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
								Size = Vector3.new(0, 0, part.Size.Z)
							}):Play()
							_G.PU:Dust(part, 0.2)
						end
					end)
					task.delay(10, function()
						table.clear(v6)
					end)
				end)
			end

			local v4 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11105535859",
				Volume = 2
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 2)
			sound.Parent = rootPart
			sound:Play()

			for i = 1, 3 do
				if i == 3 then
					Lightning({
						BeginCF = beginCF,
						EndCF = endCF,
						Ex = true
					})
				else
					Lightning({
						BeginCF = beginCF,
						EndCF = endCF
					})
				end
			end
		elseif mode == "Scepters of Flame Z" then
			local effects = workspace.Effects
			local sceptersofFlame = ReplicatedStorage.Chest.SwordEffect["Scepters of Flame"]
			local startCF = v3.StartCF
			local clone = sceptersofFlame["Heal Explosion"]:Clone()
			_G.PU:Dust(clone, 2)
			clone.CFrame = startCF * CFrame.new(0, -2.8, 0)
			clone.Parent = effects
			Utility.EmitParticles(clone)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://139109008929251",
				Volume = 1.35
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
		elseif mode == "Scepters of Flame X" then
			local effects = workspace.Effects
			local sceptersofFlame = ReplicatedStorage.Chest.SwordEffect["Scepters of Flame"]
			local rootPart = v3.RootPart
			local chargeFolder = v3.ChargeFolder
			local character = v3.Character
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11319106723",
				Volume = 3
			})
			_G.PU:Dust(sound, 15)
			sound.Parent = rootPart
			sound:Play()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11319193600",
				Volume = 1
			})
			_G.PU:Dust(sound2, 15)
			sound2.Parent = rootPart
			sound2:Play()
			local cframe = CFrame.new(0, -6, -22)
			local cframe2 = CFrame.new(0, 15, -4.5)
			local v4 = rootPart.CFrame * cframe2
			local clone = sceptersofFlame.HydraHead:Clone()
			_G.PU:Dust(clone, 10)
			clone.EyesTongueWaterFire.Transparency = 1
			clone:PivotTo(v4)
			clone.Parent = effects
			local v5 = nil
			local clone2 = nil

			for _, descendant in pairs(clone.EyesTongueWaterFire["Neck.007.R"]:GetDescendants()) do
				if descendant.Name == "Tongue.003.R" then
					v5 = descendant
				end
			end

			TweenService:Create(clone.EyesTongueWaterFire, TweenInfo.new(0.5), {
				Transparency = 0
			}):Play()
			clone.AnimationController:LoadAnimation(clone.Animation):Play()

			if v5 then
				clone2 = sceptersofFlame.Flame:Clone()
				_G.PU:Dust(clone2, 10)
				clone2.CFrame = clone.PrimaryPart.CFrame * cframe
				clone2.Parent = effects

				for _, effect in pairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = true
					end
				end
			end

			tick()
			task.spawn(function()
				local clone3 = sceptersofFlame.Aura:Clone()
				_G.PU:Dust(clone3, 12)
				clone3.CFrame = rootPart.CFrame
				Utility.ParticleHandler(clone3, false, 0)
				local weld = Instance.new("Weld")
				weld.Part0 = clone3
				weld.Part1 = rootPart
				weld.Parent = clone3
				clone3.Parent = effects
				Utility.ParticleHandler(clone3, true, 3)
				PeodizService.new({
					Time = 10
				}, function()
					if not chargeFolder:IsDescendantOf(character) then
						return true
					end

					if clone then
						clone:PivotTo(rootPart.CFrame * cframe2)
					end

					if clone2 then
						clone2.CFrame = clone.PrimaryPart.CFrame * cframe
					end
				end)
				Utility.ParticleHandler(clone3, false, 0)
			end)
			PeodizService.HeartbeatWait({
				Time = 10
			}, function(_)
				if chargeFolder:IsDescendantOf(character) then
					return
				else
					return true
				end
			end)

			if sound and sound.Parent then
				TweenService:Create(sound, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(sound, 1)
			end

			if sound2 and sound2.Parent then
				TweenService:Create(sound2, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(sound2, 1)
			end

			if clone2 then
				for _, effect in pairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			end

			if clone and clone:FindFirstChild("EyesTongueWaterFire") then
				TweenService:Create(clone.EyesTongueWaterFire, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone, 1)
			end
		elseif mode == "Hydra Lightning Ex" then
			local startCF = v3.StartCF
			task.spawn(function()
				if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 250 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
					local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone.Enabled = true
					clone.Parent = workspace.CurrentCamera
					clone.Size = 0
					_G.PU:Dust(clone, 1.5)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = 7
					}):Play()
					wait(0.35)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = 0
					}):Play()
				end
			end)
			local clone = ReplicatedStorage.Chest.SwordEffect["Daybreak Cleaver"].LightningEx:Clone()
			clone.Size = createVector(50, 1, 50)
			clone.CFrame = startCF
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local v4 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11042638602",
				Volume = 0.5
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 5)
			sound.Parent = clone
			sound:Play()

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			task.spawn(function()
				local v5 = CFrame.new(startCF.p) * CFrame.new(0, 25, 0)
				local ray = Ray.new(v5.p, createVector(0, -50, 0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
				local normal

				if raycastResult then
					normal = raycastResult.Normal or nil
				end

				local _ = raycastResult and raycastResult.Material

				if instance then
					local clone2 = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
					clone2.Decal.Transparency = -2
					clone2.Decal.Texture = "rbxassetid://9652024052"
					clone2.Decal.Color3 = Color3.fromRGB(180, 170, 1000)
					clone2.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						6.283185307179586 * math.random(),
						0
					)
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, 1)
					TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
						Size = createVector(75, 0, 75)
					}):Play()
					task.spawn(function()
						wait()
						TweenService:Create(clone2.Decal, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end)
				end
			end)
			local v5 = CFrame.new(startCF.p) * CFrame.new(0, 25, 9.5)

			for i = 1, 12 do
				local v6 = i
				task.spawn(function()
					local v7 = v5 * CFrame.new(math.random(-20, 20), 0, math.random(-10, 10))

					for i2 = 1, 3 do
						local part = Instance.new("Part")
						part.CastShadow = false
						part.Color = Color3.fromRGB(180, 128, 255)
						part.Anchored = true
						part.CanCollide = false
						part.Material = Enum.Material.Neon
						part.Size = Vector3.new(v6 / 8 + 1 - i2 / 2.2, v6 / 8 + 1 - i2 / 2.2, v6 * 1.5 + 16)
						part.CFrame = v7 * CFrame.Angles(
							math.random() * 7,
							math.random() * 3.141592653589793 * 2,
							math.random() * 7
						) * CFrame.new(0, 0, -part.Size.z / 2)
						part.Parent = workspace.Effects
						v7 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
						_G.PU:Dust(part, 0.02)
						wait()
					end
				end)
			end
		elseif mode == "Hydra Fire Ex" then
			local startCF = v3.StartCF
			task.spawn(function()
				if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 250 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
					local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone.Enabled = true
					clone.Parent = workspace.CurrentCamera
					clone.Size = 0
					_G.PU:Dust(clone, 1.5)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = 7
					}):Play()
					wait(0.35)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = 0
					}):Play()
				end
			end)
			local clone = ReplicatedStorage.Chest.Etc.HydraSB["Fire Impact"]:Clone()
			clone.Size = Vector3.new()
			clone.CFrame = startCF
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local v4 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11158049684",
				Volume = 3
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 2)
			sound.Parent = clone
			sound:Play()

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		elseif mode == "Hydra Water Ex" then
			local startCF = v3.StartCF
			task.spawn(function()
				if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 250 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
					local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone.Enabled = true
					clone.Parent = workspace.CurrentCamera
					clone.Size = 0
					_G.PU:Dust(clone, 1.5)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = 7
					}):Play()
					wait(0.35)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = 0
					}):Play()
				end
			end)
			local clone = ReplicatedStorage.Chest.Etc.HydraSB["Water Impact"]:Clone()
			clone.Size = Vector3.new()
			clone.CFrame = startCF
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local v4 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11219759584",
				Volume = 8
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 2)
			sound.Parent = clone
			sound:Play()

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		elseif mode == "Hydra Ball Rings" then
			task.spawn(function()
				local color = v3.Color
				local ball = v3.Ball
				local mouseHit = v3.MouseHit
				local character = v3.Character
				local chargeFolder = v3.ChargeFolder
				tick()
				PeodizService.HeartbeatWait({
					Time = 5,
					WaitTime = 0.25
				}, function()
					if not chargeFolder:IsDescendantOf(character) then
						return true
					end

					local clone = ReplicatedStorage.Chest.Etc.AllMeshes.WindRings:Clone()
					clone.Color = color
					clone.CFrame = CFrame.new(ball.Position, mouseHit) * CFrame.Angles(1.5707963267948966, 0, 0)
					clone.Parent = workspace.Effects
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Size = createVector(60, 6, 60),
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone, 0.5)
				end)
			end)
		elseif mode == "Hydra Roar" then
			local head = v3.Head
			local bone = v3.Bone
			local transformedWorldCFrame = bone.TransformedWorldCFrame
			task.spawn(function()
				if (localPlayer.Character.HumanoidRootPart.Position - transformedWorldCFrame.p).Magnitude < 750 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.HydraRoar)
					local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
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

			if head == "Fire" then
				tick()
				local clone = ReplicatedStorage.Chest.Etc.HydraSB["Fire Roar"]:Clone()
				clone.CFrame = transformedWorldCFrame
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 3)
				clone.Attachment.base.Rate = 7
				clone.Attachment.fluid.Rate = 12
				clone.Attachment.slashes.Rate = 50
				clone.Attachment.yea.Rate = 15
				local v4 = {
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://11241337432",
					Volume = 2
				}
				local sound = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.spawn(function()
					PeodizService.HeartbeatWait({
						Time = 2,
						WaitTime = 0.05
					}, function()
						if not bone then
							return true
						end

						clone.CFrame = bone.TransformedWorldCFrame
					end)
				end)
				task.spawn(function()
					wait(1.25)

					if clone then
						for _, emitter in pairs(clone:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end

					wait(0.5)

					if sound and sound.Parent then
						TweenService:Create(sound, TweenInfo.new(0.5), {
							Volume = 0
						}):Play()
					end
				end)
			elseif head == "Water" then
				tick()
				local clone = ReplicatedStorage.Chest.Etc.HydraSB["Water Roar"]:Clone()
				clone.CFrame = transformedWorldCFrame
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 3)
				clone.Attachment.base.Rate = 7
				clone.Attachment.fluid.Rate = 12
				clone.Attachment.slashes.Rate = 50
				clone.Attachment.yea.Rate = 15
				local v4 = {
					RollOffMaxDistance = 10000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://11241357851",
					Volume = 2
				}
				local sound = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.spawn(function()
					PeodizService.HeartbeatWait({
						Time = 2,
						WaitTime = 0.05
					}, function()
						if not bone then
							return true
						end

						clone.CFrame = bone.TransformedWorldCFrame
					end)
				end)
				task.spawn(function()
					wait(1.25)

					if clone then
						for _, emitter in pairs(clone:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end

					wait(0.5)

					if sound and sound.Parent then
						TweenService:Create(sound, TweenInfo.new(0.5), {
							Volume = 0
						}):Play()
					end
				end)
			elseif head == "Lightning" then
				tick()
				local clone = ReplicatedStorage.Chest.Etc.HydraSB["Lightning Roar"]:Clone()
				clone.CFrame = transformedWorldCFrame
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 3)
				local v4 = {
					RollOffMaxDistance = 10000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://11241407521",
					Volume = 2
				}
				local sound = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
				clone.Attachment.base.Rate = 7
				clone.Attachment.fluid.Rate = 12
				clone.Attachment.slashes.Rate = 50
				clone.Attachment.yea.Rate = 15

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.spawn(function()
					PeodizService.HeartbeatWait({
						Time = 10,
						WaitTime = 0.05
					}, function()
						if not bone then
							return true
						end

						clone.CFrame = bone.TransformedWorldCFrame
					end)
				end)
				task.spawn(function()
					wait(1.25)

					if clone then
						for _, emitter in pairs(clone:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end

					wait(0.5)

					if sound and sound.Parent then
						TweenService:Create(sound, TweenInfo.new(0.5), {
							Volume = 0
						}):Play()
					end
				end)
			end
		elseif mode == "Hydra Water Beam Charge" then
			local rootPart = v3.RootPart
			local bone = v3.Bone
			local color = v3.Color
			tick()
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 10000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11257713747",
				Volume = 2
			})
			_G.PU:Dust(sound, 4)
			sound.Parent = rootPart
			sound:Play()
			PeodizService.HeartbeatWait({
				Time = 1.4,
				WaitTime = 0.05
			}, function()
				local part = Instance.new("Part")
				part.Anchored = true
				part.CastShadow = false
				part.CanCollide = false
				part.Color = color or Color3.fromRGB(0, 170, 255)
				part.Transparency = 1
				part.Shape = Enum.PartType.Ball
				part.Size = createVector(25, 25, 25)
				part.Material = "Neon"
				part.CFrame = bone.TransformedWorldCFrame
				part.Parent = workspace.Effects
				_G.PU:Dust(part, 1)
				TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
					Size = Vector3.new(),
					Transparency = 0
				}):Play()
			end)
		elseif mode == "Hydra Water Beam Cast" then
			local startCF = v3.StartCF

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 500 then
				local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
				clone.Enabled = true
				clone.Parent = workspace.CurrentCamera
				clone.Size = 0
				_G.PU:Dust(clone, 1.5)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = 7
				}):Play()
				wait(0.35)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = 0
				}):Play()
			end

			local clone = ReplicatedStorage.Chest.Etc.HydraSB.Thing:Clone()
			clone.Size = Vector3.new()
			clone.CFrame = startCF
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 3000,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11251586778",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = createVector(25, 25, 350),
				CFrame = startCF * CFrame.new(0, 0, -175)
			}):Play()
			task.spawn(function()
				wait(0.35)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(0, 0, 350)
				}):Play()
				_G.PU:Dust(clone, 0.35)
			end)

			for i = 1, 3 do
				local clone2 = ReplicatedStorage.Chest.Etc.HydraSB.WindRing:Clone()
				clone2.Size = Vector3.new()
				clone2.CFrame = startCF * CFrame.new(0, 0, -90 * i) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 3)
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(65, 5, 65),
					Transparency = 1
				}):Play()
				wait(0.07)
			end
		elseif mode == "Hydra Lightning Head Attack" then
			local tableCF = v3.TableCF
			local startCF = v3.StartCF
			local bone = v3.Bone
			task.spawn(function()
				tick()
				local clone = ReplicatedStorage.Chest.Etc.HydraSB["Lightning Roar"]:Clone()
				clone.CFrame = startCF
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 3)
				clone.Attachment.base.Rate = 7
				clone.Attachment.fluid.Rate = 12
				clone.Attachment.slashes.Rate = 50
				clone.Attachment.yea.Rate = 15
				local v4 = {
					RollOffMaxDistance = 10000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://11241407521",
					Volume = 2
				}
				local sound = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.spawn(function()
					PeodizService.HeartbeatWait({
						Time = 2,
						WaitTime = 0.05
					}, function()
						if not bone then
							return true
						end

						clone.CFrame = bone.TransformedWorldCFrame
					end)
				end)
				task.spawn(function()
					wait(1.25)

					if clone then
						for _, emitter in pairs(clone:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end

					wait(0.5)

					if sound and sound.Parent then
						TweenService:Create(sound, TweenInfo.new(0.5), {
							Volume = 0
						}):Play()
					end
				end)
			end)

			local function Lightning(p)
				local v4 = p * CFrame.new(0, 500, 0)
				local cFrame = v4 * CFrame.new(0, -500, 0)
				local unit = (cFrame.p - v4.p).Unit
				local v6 = (cFrame.p - v4.p).Magnitude / 5
				local v7 = math.random(1, 3) * 3
				local v8 = {}

				for i = 0, 5 do
					local vector2 = Vector3.new(math.random(-45, 45), math.random(-45, 45), math.random(-45, 45))

					if i == 0 or i == 5 then
						vector2 = Vector3.new()
					end

					local v9 = i
					task.spawn(function()
						if v9 == 5 then
							local cFrame3 = cFrame
							local clone = ReplicatedStorage.Chest.Etc.HydraSB.LightningEx2:Clone()
							clone.Size = createVector(1, 1, 1)
							clone.CFrame = cFrame3
							clone.Parent = workspace.Effects
							_G.PU:Dust(clone, 1.5)
							local v11 = {
								RollOffMaxDistance = 3000,
								RollOffMinDistance = 10,
								RollOffMode = Enum.RollOffMode.Linear,
								SoundId = "rbxassetid://11042638602",
								Volume = 0.25
							}
							local sound = PeoUtils.CreateSound(v11)
							_G.PU:Dust(sound, 2)
							sound.Parent = clone
							sound:Play()
							local v12 = {
								RollOffMaxDistance = 3000,
								RollOffMinDistance = 10,
								RollOffMode = Enum.RollOffMode.Linear,
								SoundId = "rbxassetid://11258574619",
								Volume = 0.75
							}
							local sound2 = PeoUtils.CreateSound(v12)
							_G.PU:Dust(sound2, 2)
							sound2.Parent = clone
							sound2:Play()

							for i2, emitter in pairs(clone:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								_G.ParticleSize(emitter, 2)
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end

							task.spawn(function()
								local v13 = CFrame.new(cFrame3.p) * CFrame.new(0, 5, 0)
								local ray = Ray.new(v13.p, createVector(0, -50, 0))
								local raycastParams = RaycastParams.new()
								raycastParams.FilterDescendantsInstances = { workspace.Island }
								raycastParams.FilterType = Enum.RaycastFilterType.Include
								local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
								local instance

								if raycastResult then
									instance = raycastResult.Instance or nil
								end

								local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
								local normal

								if raycastResult then
									normal = raycastResult.Normal or nil
								end

								local material = raycastResult and raycastResult.Material

								if instance then
									local clone2 = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
									clone2.Decal.Transparency = -2
									clone2.Decal.Texture = "rbxassetid://9652024052"
									clone2.Decal.Color3 = Color3.fromRGB(180, 170, 1000)
									clone2.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(
										1.5707963267948966,
										0,
										0
									) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
									clone2.Parent = workspace.Effects
									_G.PU:Dust(clone2, 1)
									TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
										Size = createVector(150, 0, 150)
									}):Play()
									task.spawn(function()
										wait()
										TweenService:Create(clone2.Decal, TweenInfo.new(0.25), {
											Transparency = 1
										}):Play()
									end)
								end
							end)
						end
					end)
					v8[#v8 + 1] = v4.p + unit * v6 * i + vector2
				end

				task.spawn(function()
					PeodizService.ForLoop({
						Step = #v8
					}, function(p2)
						local v9 = math.floor(p2 * #v8)
						local v10 = v8[v9]
						local v11 = v8[v9 + 1]

						if v11 then
							local part = Instance.new("Part")
							part.CastShadow = false
							part.CanCollide = false
							part.Anchored = true
							part.Color = Color3.fromRGB(180, 128, 255)
							part.Material = "Neon"
							part.Size = Vector3.new(v7, v7, (v10 - v11).Magnitude)
							part.CFrame = CFrame.new(v10, v11) * CFrame.new(0, 0, -(v10 - v11).Magnitude / 2)
							part.Parent = workspace.Effects
							TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
								Size = Vector3.new(0, 0, part.Size.Z)
							}):Play()
							_G.PU:Dust(part, 0.35)
						end
					end)
					task.delay(10, function()
						table.clear(v8)
					end)
				end)
			end

			task.spawn(function()
				for i = 1, #tableCF do
					Lightning(tableCF[i])

					if (localPlayer.Character.HumanoidRootPart.Position - tableCF[i].p).Magnitude < 250 then
						_G.BeckCameraShake(_G.CameraShakerModule.Presets.Explosion)
						local clone = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
						clone.Parent = game.Lighting
						_G.PU:Dust(clone, 0.3)
						TweenService:Create(
							clone,
							TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
							{
								TintColor = Color3.fromRGB(255, 170, 255)
							}
						):Play()
					end

					wait(0.1)
				end

				task.delay(10, function()
					table.clear(tableCF)
				end)
			end)
		elseif mode == "Hydra Fire Head Attack" then
			local _ = v3.End
			local mag = v3.Mag
			local lookAt = v3.LookAt
			local rootPart = v3.RootPart
			local num = v3.Num
			local bone = v3.Bone
			task.spawn(function()
				tick()
				local clone = ReplicatedStorage.Chest.Etc.HydraSB["Fire Roar"]:Clone()
				clone.CFrame = bone.TransformedWorldCFrame
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 3)
				clone.Attachment.base.Rate = 7
				clone.Attachment.fluid.Rate = 12
				clone.Attachment.slashes.Rate = 50
				clone.Attachment.yea.Rate = 15
				local v4 = {
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://11241337432",
					Volume = 2
				}
				local sound = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.spawn(function()
					PeodizService.HeartbeatWait({
						Time = 2,
						WaitTime = 0.05
					}, function()
						if not bone then
							return true
						end

						clone.CFrame = bone.TransformedWorldCFrame
					end)
				end)
				task.spawn(function()
					wait(1.25)

					if clone then
						for _, emitter in pairs(clone:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end

					wait(0.5)

					if sound and sound.Parent then
						TweenService:Create(sound, TweenInfo.new(0.5), {
							Volume = 0
						}):Play()
					end
				end)
			end)
			local clone = ReplicatedStorage.Chest.Etc.HydraSB.BallBullet:Clone()
			clone.CFrame = rootPart.CFrame * CFrame.new(0, 0, -1)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://9167832679",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			task.spawn(function()
				local v4 = clone
				PeodizService.HeartbeatWait({
					Time = 10,
					WaitTime = 0.15
				}, function()
					if not v4:IsDescendantOf(workspace.Effects) then
						return true
					end

					local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
					clone2.Transparency = -1
					clone2.Color = Color3.fromRGB(255, 255, 255)
					clone2.CFrame = v4.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone2.Parent = workspace.Effects
					TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
						Size = createVector(30, 2.5, 30) * math.random(10, 20) / 5,
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone2, 0.5)
				end)
			end)
			task.spawn(function()
				tick()
				local step = num
				PeodizService.ForLoop({
					Step = step
				}, function(p)
					local cframe = CFrame.new(0, math.sin(3.141592653589793 * p) * step, -(p * step) * mag)
					clone.CFrame = CFrame.new((lookAt * cframe).p, clone.Position) * CFrame.Angles(
						0,
						3.141592653589793,
						0
					)
				end)
				local cFrame = clone.CFrame

				if (cFrame.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 500 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
					local clone2 = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone2.Enabled = true
					clone2.Parent = workspace.CurrentCamera
					clone2.Size = 0
					_G.PU:Dust(clone2, 0.5)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true, 0),
						{
							Size = 7.5
						}
					):Play()
				end

				task.spawn(function()
					clone.Anchored = true
					clone.Transparency = 1
					_G.PU:Dust(clone, 0.5)

					for _, effect in pairs(clone:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
				task.spawn(function()
					if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < 500 then
						_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
						local clone2 = ReplicatedStorage.Chest.Etc.Blur:Clone()
						clone2.Enabled = true
						clone2.Parent = workspace.CurrentCamera
						clone2.Size = 0
						_G.PU:Dust(clone2, 1.5)
						TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							Size = 10
						}):Play()
						wait(0.35)
						TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							Size = 0
						}):Play()
					end
				end)
				local clone2 = ReplicatedStorage.Chest.Etc.HydraSB["Fire Impact"]:Clone()
				clone2.Size = Vector3.new()
				clone2.CFrame = cFrame
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 2)
				local v5 = {
					RollOffMaxDistance = 300,
					RollOffMinDistance = 0,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://11158049684",
					Volume = 3
				}
				local sound2 = PeoUtils.CreateSound(v5)
				_G.PU:Dust(sound2, 2)
				sound2.Parent = clone2
				sound2:Play()

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(emitter, 2.5)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end

				local ray = Ray.new(cFrame.p, createVector(0, -25, 0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
				local normal

				if raycastResult then
					normal = raycastResult.Normal or nil
				end

				local _ = raycastResult and raycastResult.Material

				if instance then
					local clone3 = ReplicatedStorage.Chest.SwordEffect.AuthenticMace.Burn:Clone()
					clone3.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						6.283185307179586 * math.random(),
						0
					)
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 1.5)
					TweenService:Create(clone3, TweenInfo.new(0.25), {
						Size = createVector(250, 0, 250)
					}):Play()
					spawn(function()
						wait(1)
						TweenService:Create(clone3.Decal, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end)
				end
			end)
		elseif mode == "Hydra Triple Roar" then
			local fireBone = v3.FireBone
			local waterBone = v3.WaterBone
			local lightningBone = v3.LightningBone
			local transformedWorldCFrame = fireBone.TransformedWorldCFrame
			task.spawn(function()
				if (localPlayer.Character.HumanoidRootPart.Position - transformedWorldCFrame.p).Magnitude < 750 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.HydraRoar)
					local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone.Enabled = true
					clone.Parent = workspace.CurrentCamera
					clone.Size = 0
					_G.PU:Dust(clone, 1.5)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = 12
					}):Play()
					wait(0.35)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = 0
					}):Play()
				end
			end)
			tick()
			local clone = ReplicatedStorage.Chest.Etc.HydraSB["Fire Roar"]:Clone()
			clone.CFrame = transformedWorldCFrame
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 3)
			clone.Attachment.base.Rate = 7
			clone.Attachment.fluid.Rate = 12
			clone.Attachment.slashes.Rate = 50
			clone.Attachment.yea.Rate = 15
			local v4 = {
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11241337432",
				Volume = 2
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			local clone2 = ReplicatedStorage.Chest.Etc.HydraSB["Water Roar"]:Clone()
			clone2.CFrame = transformedWorldCFrame
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 3)
			clone2.Attachment.base.Rate = 7
			clone2.Attachment.fluid.Rate = 12
			clone2.Attachment.slashes.Rate = 50
			clone2.Attachment.yea.Rate = 15
			local v5 = {
				RollOffMaxDistance = 10000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11241357851",
				Volume = 2
			}
			local sound2 = PeoUtils.CreateSound(v5)
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone2
			sound2:Play()
			local clone3 = ReplicatedStorage.Chest.Etc.HydraSB["Lightning Roar"]:Clone()
			clone3.CFrame = transformedWorldCFrame
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 3)
			clone3.Attachment.base.Rate = 7
			clone3.Attachment.fluid.Rate = 12
			clone3.Attachment.slashes.Rate = 50
			clone3.Attachment.yea.Rate = 15
			local v6 = {
				RollOffMaxDistance = 10000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://11241407521",
				Volume = 2
			}
			local sound3 = PeoUtils.CreateSound(v6)
			_G.PU:Dust(sound3, 3)
			sound3.Parent = clone3
			sound3:Play()

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 2,
					WaitTime = 0.05
				}, function()
					if not (fireBone and waterBone and lightningBone) then
						return true
					end

					clone.CFrame = fireBone.TransformedWorldCFrame
					clone2.CFrame = waterBone.TransformedWorldCFrame
					clone3.CFrame = lightningBone.TransformedWorldCFrame
				end)
			end)
			task.spawn(function()
				wait(1.25)

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

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				wait(0.5)
				TweenService:Create(clone.Sound, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				TweenService:Create(clone2.Sound, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				TweenService:Create(clone3.Sound, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
			end)
		elseif mode == "Minion Roar" then
			local bone = v3.Bone
			local transformedWorldCFrame = bone.TransformedWorldCFrame
			task.spawn(function()
				if (localPlayer.Character.HumanoidRootPart.Position - transformedWorldCFrame.p).Magnitude < 500 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
					local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone.Enabled = true
					clone.Parent = workspace.CurrentCamera
					clone.Size = 0
					_G.PU:Dust(clone, 1.5)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = 5
					}):Play()
					wait(0.35)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = 0
					}):Play()
				end
			end)
			tick()
			local clone = ReplicatedStorage.Chest.Etc.HydraSB["Minion Roar"]:Clone()
			clone.CFrame = transformedWorldCFrame
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 3)
			clone.Attachment.base.Rate = 7
			clone.Attachment.fluid.Rate = 12
			clone.Attachment.slashes.Rate = 50
			clone.Attachment.yea.Rate = 15
			local v4 = {
				RollOffMaxDistance = 10000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://7725942102",
				Volume = 1,
				PlaybackSpeed = 2.5
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				_G.ParticleSize(emitter, 2)
				emitter.Enabled = true
			end

			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 2,
					WaitTime = 0.05
				}, function()
					if not bone then
						return true
					end

					clone.CFrame = bone.TransformedWorldCFrame
				end)
			end)
			task.spawn(function()
				wait(0.5)

				if clone then
					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end

				wait(0.5)

				if sound and sound.Parent then
					TweenService:Create(sound, TweenInfo.new(0.5), {
						Volume = 0
					}):Play()
				end
			end)
		elseif mode == "Hydra Minion Bullet" then
			local type2 = v3.Type

			if type2 == "Cast" then
				local bone = v3.Bone
				task.spawn(function()
					tick()
					PeodizService.HeartbeatWait({
						Time = 0.75,
						WaitTime = 0.075
					}, function()
						local part = Instance.new("Part")
						part.Anchored = true
						part.CastShadow = false
						part.CanCollide = false
						part.Color = Color3.fromRGB(0, 170, 255)
						part.Transparency = 0.75
						part.Shape = Enum.PartType.Ball
						part.Size = Vector3.new()
						part.Material = "Neon"
						part.CFrame = bone.TransformedWorldCFrame
						part.Parent = workspace.Effects
						_G.PU:Dust(part, 1)
						TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
							Size = createVector(30, 30, 30),
							Transparency = 1
						}):Play()
					end)
				end)
			elseif type2 == "Explosion" then
				local endCF = v3.EndCF
				local clone = ReplicatedStorage.Chest.Etc.HydraSB["Water Impact"]:Clone()
				clone.CFrame = endCF
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1.8)
				local v4 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://5896883376",
					Volume = 0.25
				}
				local sound = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound, 2)
				sound.Parent = clone
				sound:Play()

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(emitter, 1)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		elseif mode == "Scepters of Flame Hydra CFrame" then
			local rootPart = v3.RootPart
			local hydraHead = v3.HydraHead
			local hydraRoarFire = v3.HydraRoarFire
			local bone = v3.Bone
			local chargeFolder = v3.ChargeFolder
			local character = v3.Character

			if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.SmallExplosion)
			end

			tick()
			task.spawn(function()
				local _ = v3.BaseSize
				local clone = v3.Object:Clone()
				clone.Position = createVector(0, -3, 0)
				clone.Parent = rootPart
				clone.Bot.Enabled = true
				clone.Top.Enabled = true
				_G.PU:Dust(clone, 10)
				PeodizService.new({
					Time = 10
				}, function()
					if not chargeFolder:IsDescendantOf(character) then
						return true
					end

					if hydraHead then
						hydraHead:SetPrimaryPartCFrame(rootPart.CFrame * CFrame.new(0, 5, -4.5))
					end

					if hydraRoarFire then
						local v4 = rootPart.CFrame * CFrame.new(0, 0, -25)
						local v5 = CFrame.new(bone.TransformedWorldCFrame.p) * CFrame.new(0, 0.5, 0)
						hydraRoarFire:SetPrimaryPartCFrame(CFrame.new(v5.p, v4.p))
					end
				end)
				clone.Bot.Enabled = false
				clone.Top.Enabled = false
			end)
			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 6,
					WaitTime = 1
				}, function()
					task.spawn(function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
							local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
							clone.Enabled = true
							clone.Parent = workspace.CurrentCamera
							clone.Size = 0
							_G.PU:Dust(clone, 1.5)
							TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
								Size = 7
							}):Play()
							wait(0.35)
							TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
								Size = 0
							}):Play()
						end
					end)
				end)
			end)
		elseif mode == "Hydra Conqueror" then
			local rootPart = v3.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 3000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://9161543459",
				Volume = 3
			})
			_G.PU:Dust(sound, 6)
			sound.Parent = rootPart
			sound:Play()
			local color = v3.Color or Color3.fromRGB(255, 255, 255)
			local clone = ReplicatedStorage.Chest.Etc.Part1.Attachment:Clone()
			clone.Wind.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 181, 181),
				NumberSequenceKeypoint.new(0.747, 106, 106),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Impact.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1000)
			})
			clone.Wave1.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 306, 188),
				NumberSequenceKeypoint.new(0.642, 200, 176),
				NumberSequenceKeypoint.new(1, 75, 75)
			})
			clone.Wave2.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 313),
				NumberSequenceKeypoint.new(0.417, 137, 137),
				NumberSequenceKeypoint.new(1, 93.8, 93.8)
			})
			clone.SmallWave1.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 30.6, 18.8),
				NumberSequenceKeypoint.new(0.642, 20, 17.6),
				NumberSequenceKeypoint.new(1, 7.5, 7.5)
			})
			clone.SmallWave2.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 31.3),
				NumberSequenceKeypoint.new(0.417, 13.7, 13.7),
				NumberSequenceKeypoint.new(1, 9.379999999999999, 9.379999999999999)
			})
			clone.BotAura.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.144, 25.2),
				NumberSequenceKeypoint.new(0.352, 176, 53.5),
				NumberSequenceKeypoint.new(0.836, 12.6),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.BotAura.Speed = NumberRange.new(2000, 5000)
			clone.BotAura.Acceleration = createVector(0, 10000, 0)
			clone.Ring.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 4.37, 4.37),
				NumberSequenceKeypoint.new(0.32, 319, 18),
				NumberSequenceKeypoint.new(1, 469.00000000000006)
			})
			clone.Par2.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 250),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Wave1.Color = ColorSequence.new(color)
			clone.Wave2.Color = ColorSequence.new(color)
			clone.SmallWave1.Color = ColorSequence.new(color)
			clone.SmallWave2.Color = ColorSequence.new(color)
			clone.Ring.Color = ColorSequence.new(color)
			clone.Wind.Color = ColorSequence.new(color)
			clone.BotAura.Color = ColorSequence.new(color)
			clone.Par2.Color = ColorSequence.new(color)
			clone.Parent = rootPart
			_G.PU:Dust(clone, 5)
			spawn(function()
				for _ = 1, 4 do
					clone.SmallWave1:Emit(1)
					clone.SmallWave2:Emit(1)
					clone.Par2:Emit(1)
					wait(0.2)
				end
			end)
			wait(1.25)

			if (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 500 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Allosaurus_X)
				local clone2 = ReplicatedStorage.Chest.Etc.Blur:Clone()
				clone2.Enabled = true
				clone2.Parent = workspace.CurrentCamera
				clone2.Size = 0
				_G.PU:Dust(clone2, 3)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 10, true, 0),
					{
						Size = 20
					}
				):Play()
			end

			for _ = 1, 20 do
				local part = Instance.new("Part")
				part.Transparency = 0.7
				part.Shape = "Ball"
				part.Material = "Neon"
				part.CastShadow = false
				part.Anchored = true
				part.CanCollide = false
				part.Color = color
				part.Size = Vector3.new()
				part.CFrame = rootPart.CFrame
				part.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
					Size = createVector(300, 300, 300),
					Transparency = 1
				}):Play()
				_G.PU:Dust(part, 0.5)
				clone.Wave1:Emit(1)
				clone.Wave2:Emit(1)
				clone.Ring:Emit(1)
				clone.Wind:Emit(1)
				clone.BotAura:Emit(10)
				wait(0.1)
			end
		elseif mode == "Hydra Chest" then
			local startCF = v3.StartCF
			local clone = ReplicatedStorage.Chest.Etc.HydraSB.RingDecal:Clone()
			clone.Size = createVector(2000, 1, 2000)
			clone.Decal.Transparency = 1
			clone.Decal2.Transparency = 1
			clone.CFrame = CFrame.new(startCF.p)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 4)
			TweenService:Create(clone.Decal, TweenInfo.new(1), {
				Transparency = 0
			}):Play()
			TweenService:Create(clone.Decal2, TweenInfo.new(1), {
				Transparency = 0
			}):Play()
			TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Linear), {
				Size = createVector(0, 1, 0)
			}):Play()
		elseif mode == "Bomb Z Revamp" then
			task.spawn(function()
				local startCF = v3.StartCF
				task.spawn(function()
					if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 200 then
						_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
						local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
						clone.Enabled = true
						clone.Parent = workspace.CurrentCamera
						clone.Size = 0
						_G.PU:Dust(clone, 1.5)
						TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							Size = 7
						}):Play()
						wait(0.35)
						TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							Size = 0
						}):Play()
					end
				end)
				local clone = ReplicatedStorage.Chest.FruitEffect.Bomb.Explosion2:Clone()
				clone.CFrame = startCF
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 2)
				local v4 = {
					RollOffMaxDistance = 300,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://11607789538",
					Volume = 1
				}
				local sound = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound, 2)
				sound.Parent = clone
				sound:Play()
				task.spawn(function()
					wait(1)

					if clone and sound then
						TweenService:Create(sound, TweenInfo.new(0.5), {
							Volume = 0
						}):Play()
					end
				end)

				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(emitter, 1.25)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end)
		elseif mode == "Bomb X Revamp" then
			-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
			local function bezier(p, p2, p3, p4)
				return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
			end

			local numberValue = Instance.new("NumberValue")
			_G.PU:Dust(numberValue, 5)
			numberValue.Value = 0
			local tween = TweenService:Create(
				numberValue,
				TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Value = 100
				}
			)
			tween:Play()

			if localPlayer.Name == v3.PlayerName then
				PeodizService.Heartbeat({
					Time = 0.5,
					WaitTime = 0.03
				}, function(_)
					local v5 = bezier(numberValue.Value / 100, v3.CF1.p, v3.Up.p, v3.CF2.p)
					v3.RootPart.CFrame = CFrame.new(v5) * (v3.RootPart.CFrame - v3.RootPart.CFrame.p)
				end)

				if numberValue then
					numberValue:Destroy()
				end
			end

			tween.Completed:Wait()

			if numberValue then
				numberValue:Destroy()
			end

			local cframe = CFrame.new(v3.CF2.p)
			task.spawn(function()
				task.spawn(function()
					if (localPlayer.Character.HumanoidRootPart.Position - cframe.p).Magnitude < 200 then
						_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
						local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
						clone.Enabled = true
						clone.Parent = workspace.CurrentCamera
						clone.Size = 0
						_G.PU:Dust(clone, 1.5)
						TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							Size = 7
						}):Play()
						wait(0.35)
						TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							Size = 0
						}):Play()
					end
				end)
				local clone = ReplicatedStorage.Chest.FruitEffect.Bomb.Explosion2:Clone()
				clone.CFrame = cframe
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 2)
				local v4 = {
					RollOffMaxDistance = 300,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://11607789538",
					Volume = 1
				}
				local sound = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound, 2)
				sound.Parent = clone
				sound:Play()
				task.spawn(function()
					wait(1)

					if clone and sound then
						TweenService:Create(sound, TweenInfo.new(0.5), {
							Volume = 0
						}):Play()
					end
				end)

				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(emitter, 1.25)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end

				local v5 = CFrame.new(cframe.p) * CFrame.new(0, 25, 0)
				local ray = Ray.new(v5.p, createVector(0, -50, 0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
				local _ = raycastResult and raycastResult.Normal
				local _ = raycastResult and raycastResult.Material

				if instance then
					task.spawn(function()
						if (localPlayer.Character.HumanoidRootPart.Position - v5.p).Magnitude < 150 then
							_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
						end

						local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
						clone2.Color = Color3.fromRGB(255, 85, 0)
						clone2.CastShadow = false
						clone2.Transparency = -1
						clone2.Anchored = true
						clone2.CanCollide = false
						clone2.Size = createVector(50, 50, 50)
						clone2.CFrame = CFrame.new(position)
						clone2.Parent = workspace.Effects
						_G.PU:Dust(clone2, 0.15)
						TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
							Size = createVector(0, 75, 0),
							CFrame = clone2.CFrame * CFrame.new(0, 37.5, 0)
						}):Play()
					end)
				end
			end)
		elseif mode == "Bomb C Revamp" then
			PeodizService.ForLoop({
				Step = 3,
				WaitTime = 0.3
			}, function()
				task.spawn(function()
					local startCF = v3.StartCF
					task.spawn(function()
						if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 200 then
							_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
							local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
							clone.Enabled = true
							clone.Parent = workspace.CurrentCamera
							clone.Size = 0
							_G.PU:Dust(clone, 1.5)
							TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
								Size = 7
							}):Play()
							wait(0.35)
							TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
								Size = 0
							}):Play()
						end
					end)
					local clone = ReplicatedStorage.Chest.FruitEffect.Bomb.Explosion2:Clone()
					clone.CFrame = startCF
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 2)
					local v4 = {
						RollOffMaxDistance = 300,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.Linear,
						SoundId = "rbxassetid://11607789538",
						Volume = 1
					}
					local sound = PeoUtils.CreateSound(v4)
					_G.PU:Dust(sound, 2)
					sound.Parent = clone
					sound:Play()
					task.spawn(function()
						wait(1)

						if clone and sound then
							TweenService:Create(sound, TweenInfo.new(0.5), {
								Volume = 0
							}):Play()
						end
					end)

					for _, emitter in pairs(clone.Attachment:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						_G.ParticleSize(emitter, 0.8)
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end)
			end)
		elseif mode == "Bomb V Revamp" then
			local input = v3.Input

			if input == "Hold" then
				local folder = v3.Folder
				local character = v3.Character
				local rootPart = v3.RootPart
				local clone = ReplicatedStorage.Chest.FruitEffect.Bomb["Charge up"]:Clone()
				clone.CFrame = rootPart.CFrame
				clone.Size = createVector(150, 150, 150)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 25)

				for _, emitter in pairs(clone:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				tick()
				PeodizService.HeartbeatWait({
					Time = 10,
					WaitTime = 0.05
				}, function()
					if not folder:IsDescendantOf(character) then
						return true
					end

					clone.CFrame = rootPart.CFrame
				end)

				for _, emitter in pairs(clone:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				_G.PU:Dust(clone, 0.5)
			elseif input == "Cast" then
				local startCF = v3.StartCF
				task.spawn(function()
					if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 300 then
						_G.BeckCameraShake(_G.CameraShakerModule.Presets.Explosion)
						local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
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
				local clone = ReplicatedStorage.Chest.FruitEffect.Bomb.Explosion2:Clone()
				clone.CFrame = startCF
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 2)
				local v4 = {
					RollOffMaxDistance = 300,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://11608824551",
					Volume = 1.25
				}
				local sound = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound, 2)
				sound.Parent = clone
				sound:Play()

				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(emitter, 2)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		elseif mode == "Gravity Z" then
			local startCF = v3.StartCF

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 200 then
				local clone = ReplicatedStorage.Chest.SwordEffect.Etc.Pondere3:Clone()
				clone.Enabled = true
				clone.Parent = game.Lighting
				_G.PU:Dust(clone, 0.01)
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.SmallExplosion)
			end

			tick()
			local clone = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone.Color = Color3.fromRGB(170, 170, 255)
			clone.CastShadow = false
			clone.Transparency = -1
			clone.Anchored = true
			clone.CanCollide = false
			clone.Size = createVector(100, 100, 100)
			clone.CFrame = CFrame.new(startCF.p)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 0.15)
			TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Size = createVector(0, 150, 0),
				CFrame = clone.CFrame * CFrame.new(0, 75, 0)
			}):Play()
			task.spawn(function()
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Gravity.Pondere2:Clone()
				clone2.CFrame = startCF * CFrame.new(0, 10, 0) * CFrame.Angles(0, 0, -1.5707963267948966)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 2)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://10891083054",
					Volume = 3
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone2
				sound:Play()
				clone2.Attachment.SpreadSlashes:Emit(10)
				task.spawn(function()
					local ray = Ray.new(startCF.p, createVector(0, -30, 0))
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = {
						workspace.Effects,
						workspace.PlayerCharacters,
						workspace.CharacterWorkshop
					}
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
					local normal

					if raycastResult then
						normal = raycastResult.Normal or nil
					end

					local _ = raycastResult and raycastResult.Material

					if instance then
						local clone3 = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
						clone3.Decal.Transparency = -0.2
						clone3.Decal.Texture = "rbxassetid://7068839334"
						clone3.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(0, -1, 0)
						clone3.Parent = workspace.Effects
						_G.PU:Dust(clone3, 1)
						TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), {
							Size = createVector(90, 0, 90)
						}):Play()
						task.spawn(function()
							wait(0.65)
							TweenService:Create(clone3.Decal, TweenInfo.new(0.25), {
								Transparency = 1
							}):Play()
						end)
					end
				end)
				PeodizService.HeartbeatWait({
					Time = 0.5
				}, function()
					task.spawn(function()
						for _, emitter in pairs(clone2:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end
					end)
					local v4 = math.random(5, 10) / 15
					local clone3 = ReplicatedStorage.Chest.FruitEffect.Gravity.Thing:Clone()
					clone3.Transparency = -1
					clone3.Size = Vector3.new(v4, math.random(5, 25), v4)
					clone3.Color = math.random(1, 2) == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(
						170,
						85,
						255
					)
					clone3.CFrame = startCF * CFrame.new(math.random(-22, 22), math.random(1, 15), math.random(-22, 22))
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 0.01)
				end)
			end)

			for i = 1, 20 do
				local cframe = CFrame.new(startCF.p) * CFrame.Angles(0, 6.283185307179586 * i / 20, 0) * CFrame.new(
					0,
					0,
					-50
				)
				local ray = Ray.new(cframe.p, createVector(0, -25, 0))
				local _, v4, _ = cframe:ToOrientation()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
				local _ = raycastResult and raycastResult.Normal
				local material = raycastResult and raycastResult.Material or nil

				if not instance then
					continue
				end

				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.CFrame = CFrame.new(startCF.p) * CFrame.fromOrientation(0, v4, 0)
				part.Size = createVector(0, 0, 0)
				part.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v4, 0) * CFrame.new(
						0,
						math.random(-20, 1) / 10,
						0
					) * CFrame.Angles(math.rad((math.random(30, 90))), 0, 0),
					Size = createVector(17.25, 10, 10)
				}):Play()
				TweenService:Create(
					part,
					TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 1),
					{
						Transparency = 1
					}
				):Play()
				part.Material = material or "SmoothPlastic"
				part.BrickColor = instance.BrickColor
				_G.PU:Dust(part, 2)
			end
		elseif mode == "Gravity Z Awake" then
			local startCF = v3.StartCF

			for i = 1, 3 do
				local halfI = i / 2
				tick()
				local clone = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
				clone.Color = Color3.fromRGB(170, 170, 255)
				clone.CastShadow = false
				clone.Transparency = -1
				clone.Anchored = true
				clone.CanCollide = false
				clone.Size = createVector(100, 100, 100) * halfI
				clone.CFrame = CFrame.new(startCF.p)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 0.15)
				TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Size = Vector3.new(0, 150 * halfI, 0),
					CFrame = clone.CFrame * CFrame.new(0, 150 * halfI / 2, 0)
				}):Play()
				local v6 = i
				task.spawn(function()
					local clone2 = ReplicatedStorage.Chest.FruitEffect.Gravity.Pondere2:Clone()
					_G.PU:Dust(clone2, 2)
					clone2.Size *= halfI
					clone2.CFrame = startCF * CFrame.new(0, 10, 0) * CFrame.Angles(0, 0, -1.5707963267948966)
					clone2.Parent = workspace.Effects
					task.spawn(function()
						for i2, emitter in pairs(clone2:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								_G.ParticleSize(emitter, halfI)
							end
						end
					end)
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://10891083054",
						Volume = 3
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = clone2
					sound:Play()
					clone2.Attachment.SpreadSlashes:Emit(10)
					task.spawn(function()
						local ray = Ray.new(startCF.p, createVector(0, -30, 0))
						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = {
							workspace.Effects,
							workspace.PlayerCharacters,
							workspace.CharacterWorkshop
						}
						raycastParams.FilterType = Enum.RaycastFilterType.Exclude
						local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
						local instance

						if raycastResult then
							instance = raycastResult.Instance or nil
						end

						local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
						local normal

						if raycastResult then
							normal = raycastResult.Normal or nil
						end

						local material = raycastResult and raycastResult.Material

						if instance then
							local clone3 = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
							clone3.Decal.Transparency = -0.2
							clone3.Decal.Texture = "rbxassetid://7068839334"
							clone3.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(
								1.5707963267948966,
								0,
								0
							) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(0, -1, 0)
							clone3.Parent = workspace.Effects
							_G.PU:Dust(clone3, 3)
							TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), {
								Size = createVector(90, 0.2, 90) * halfI
							}):Play()
							task.spawn(function()
								wait(v6 / 2)
								TweenService:Create(clone3.Decal, TweenInfo.new(0.25), {
									Transparency = 1
								}):Play()
							end)
						end
					end)
					PeodizService.HeartbeatWait({
						Time = 0.5
					}, function()
						task.spawn(function()
							for i2, emitter in pairs(clone2:GetChildren()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end
						end)
						local v7 = math.random(5, 10) / 15
						local clone3 = ReplicatedStorage.Chest.FruitEffect.Gravity.Thing:Clone()
						clone3.Transparency = -1
						clone3.Size = Vector3.new(v7, math.random(5, 25), v7) * halfI
						clone3.Color = math.random(1, 2) == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(
							170,
							85,
							255
						)
						clone3.CFrame = startCF * CFrame.new(
							math.random(-22, 22),
							math.random(1, 15),
							math.random(-22, 22)
						)
						clone3.Parent = workspace.Effects
						_G.PU:Dust(clone3, 0.01)
					end)
				end)

				for i2 = 1, 20 do
					local cframe = CFrame.new(startCF.p) * CFrame.Angles(0, 6.283185307179586 * i2 / 20, 0) * CFrame.new(
						0,
						0,
						-50 * halfI
					)
					local ray = Ray.new(cframe.p, createVector(0, -25, 0))
					local _, v7, _ = cframe:ToOrientation()
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
					local _ = raycastResult and raycastResult.Normal
					local material = raycastResult and raycastResult.Material or nil

					if not instance then
						continue
					end

					local part = Instance.new("Part")
					part.CastShadow = false
					part.Anchored = true
					part.CanCollide = false
					part.CFrame = CFrame.new(startCF.p) * CFrame.fromOrientation(0, v7, 0)
					part.Size = createVector(0, 0, 0)
					part.Parent = workspace.Effects
					TweenService:Create(
						part,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v7, 0) * CFrame.new(
								0,
								math.random(-20, 1) / 10,
								0
							) * CFrame.Angles(math.rad((math.random(30, 90))), 0, 0),
							Size = createVector(17.25, 10, 10) * halfI
						}
					):Play()
					TweenService:Create(
						part,
						TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 1),
						{
							Transparency = 1
						}
					):Play()
					part.Material = material or "SmoothPlastic"
					part.BrickColor = instance.BrickColor
					_G.PU:Dust(part, 2)
				end

				wait(0.25)
			end
		elseif mode == "Electro Z" then
			local startCF = v3.StartCF

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 150 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Saber_X)
			end

			local clone = v3.ElectroShocker:Clone()
			clone.CFrame = startCF
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11793153232",
				Volume = 2
			})
			_G.PU:Dust(sound, 5)
			sound.Parent = clone
			sound:Play()
			local clone2 = v3.ElectroParticle:Clone()
			clone2.CFrame = startCF * CFrame.new(0, 0, -25)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 2)
			task.spawn(function()
				for _, emitter in pairs(clone2:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				wait(1.5)

				for _, emitter in pairs(clone2:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
			task.spawn(function()
				for _, beam in pairs(clone:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					if beam.Name == "Beam1" then
						TweenService:Create(beam, TweenInfo.new(0.25), {
							Width0 = 6,
							Width1 = 3
						}):Play()
					elseif beam.Name == "Beam2" then
						TweenService:Create(beam, TweenInfo.new(0.25), {
							Width0 = 6,
							Width1 = 1
						}):Play()
					elseif beam.Name == "Beam3" then
						TweenService:Create(beam, TweenInfo.new(0.25), {
							Width0 = 5,
							Width1 = 1
						}):Play()
					elseif beam.Name == "Beam4" then
						TweenService:Create(beam, TweenInfo.new(0.25), {
							Width0 = 2,
							Width1 = 1
						}):Play()
					end
				end

				wait(1.25)

				for _, beam in pairs(clone:GetDescendants()) do
					if beam:IsA("Beam") then
						TweenService:Create(beam, TweenInfo.new(0.25), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end
				end
			end)
			task.spawn(function()
				local function Thunder()
					local v4 = startCF

					for i = 1, 10 do
						local v5 = i
						coroutine.wrap(function()
							local v6 = v4

							for i2 = 1, 5 do
								local part = Instance.new("Part")
								part.Color = Color3.fromRGB(0, 170, 255)
								part.Anchored = true
								part.CanCollide = false
								part.Material = Enum.Material.Neon
								part.Size = Vector3.new(v5 / 8 + 0.5 - i2 / 2.2, v5 / 8 + 0.5 - i2 / 2.2, v5 * 1.5 + 2)
								part.CFrame = v6 * CFrame.Angles(
									math.rad((math.random(1, 10))),
									math.rad((math.random(-45, 45))),
									0
								) * CFrame.new(0, 0, -part.Size.z / 2)
								part.Parent = workspace.Effects
								v6 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
								_G.PU:Dust(part, 0.025)
								wait(0.025)
							end
						end)()
					end
				end

				for _ = 1, 5 do
					wait(0.2)
					Thunder()
				end
			end)
		elseif mode == "Water Style Z" then
			local startCF = v3.StartCF
			local rootPart = v3.RootPart

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 200 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11833357892",
				Volume = 2.25
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.Etc.DragonClaw.Shockwave:Clone()
			clone.Color = Color3.fromRGB(0, 170, 255)
			clone.CFrame = startCF * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Size = createVector(96.26, 96.26, 7.8250003)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1.5)
			TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(41.87, 41.87, 115.05),
				CFrame = clone.CFrame * CFrame.new(0, 0, 100) * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local clone2 = ReplicatedStorage.Chest.Etc.DragonClaw.Sphere:Clone()
			clone2.Transparency = -1
			clone2.Color = Color3.fromRGB(0, 170, 255)
			clone2.CFrame = startCF * CFrame.new(0, 0, -5)
			clone2.Size = createVector(80, 80, 50)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 145),
				CFrame = startCF * CFrame.new(0, 0, -70),
				Transparency = 1
			}):Play()
			task.spawn(function()
				PeodizService.ForLoop({
					Step = 2,
					WaitTime = 0.05
				}, function(p)
					local v4 = math.floor(p * 2)
					local v5 = startCF * CFrame.new(0, 0, v4 * -10)
					local v6 = v4 == 2 and 3.5 or 5
					local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
					clone3.Transparency = -1
					clone3.Color = Color3.fromRGB(255, 255, 255)
					clone3.CFrame = v5 * CFrame.new(0, 0, -10) * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone3.Size = createVector(8.897, 0.658, 8.897)
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 1)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(21.166, 1.565, 21.166) * v6,
							CFrame = v5 * CFrame.new(0, 0, 1) * CFrame.Angles(-1.5707963267948966, 0, 0),
							Transparency = 1
						}
					):Play()
				end)
			end)
			PeodizService.ForLoop({
				Step = 6,
				WaitTime = 0.05
			}, function(p)
				local v4 = math.floor(p * 6)
				local clone3 = ReplicatedStorage.Chest.Etc.CombatFishman.ParticlePart:Clone()
				clone3.Attachment.ParticleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255))
				clone3.Attachment.ParticleEmitter.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 15, 15),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone3.Attachment.ParticleEmitter.Speed = NumberRange.new(100, 200)
				clone3.CFrame = startCF * CFrame.new(0, 0, v4 * -3 * 5) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3.Parent = workspace.Effects
				clone3.Attachment.ParticleEmitter:Emit(10)
				TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(60, 8, 60)
				}):Play()
				_G.PU:Dust(clone3, 1)
			end)
		elseif mode == "Water Style X" then
			local start = v3.Start
			local _ = v3.End
			local mag = v3.Mag
			local lookAt = v3.LookAt
			local _ = v3.RootPart
			local howLong = v3.HowLong
			local clone = ReplicatedStorage.Chest.FruitEffect.Flame.SharkBullet:Clone()
			clone.CFrame = start.CFrame * CFrame.new(0, 0, -3)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11794815114",
				Volume = 1.25
			})
			_G.PU:Dust(sound, 2)
			sound.Parent = clone
			sound:Play()
			spawn(function()
				local v4 = clone
				spawn(function()
					PeodizService.HeartbeatWait({
						Time = 10,
						WaitTime = 0.35
					}, function()
						if not v4:IsDescendantOf(workspace.Effects) then
							return true
						end

						local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
						clone2.Transparency = -1
						clone2.Color = Color3.fromRGB(255, 255, 255)
						clone2.CFrame = v4.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
						clone2.Parent = workspace.Effects
						TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
							Size = createVector(30, 2.5, 30) * math.random(10, 20) / 20,
							Transparency = 1
						}):Play()
						_G.PU:Dust(clone2, 0.5)
					end)
				end)
			end)
			spawn(function()
				local v4 = howLong
				PeodizService.ForLoop({
					Step = howLong
				}, function(p)
					local cframe = CFrame.new(0, math.sin(3.141592653589793 * p) * v4, -(p * v4) * mag)
					clone.CFrame = CFrame.new((lookAt * cframe).p, clone.Position) * CFrame.Angles(
						0,
						3.141592653589793,
						0
					)
				end)
				local cFrame = clone.CFrame
				clone:Destroy()
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Flame.SharkBulletEx:Clone()
				clone2.CFrame = cFrame
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 1)
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://11794820196",
					Volume = 2.5
				})
				_G.PU:Dust(sound2, 1)
				sound2.Parent = clone2
				sound2:Play()
				task.spawn(function()
					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end
				end)
			end)
		elseif mode == "Water Style C" then
			local startCF = v3.StartCF
			local rootPart = v3.RootPart
			local followFolder = v3.FollowFolder
			local character = v3.Character
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
				local clone = ReplicatedStorage.Chest.MeleeEffect.WaterStyle.AnchorSmash2:Clone()
				clone.CFrame = CFrame.new(rootPart.Position)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 5)

				for _, child in pairs(clone.Attachment:GetChildren()) do
					if not child:isA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(child, 0.75)
					child:Emit(child:GetAttribute("EmitCount"))
				end
			end)
			tick()
			local clone = v3.WindParticle:Clone()
			clone.CFrame = startCF * CFrame.new(-15, 5, 0) * CFrame.Angles(0, 0, 0.7853981633974483)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 3)
			local clone2 = v3.WindParticle:Clone()
			clone2.CFrame = startCF * CFrame.new(15, 5, 0) * CFrame.Angles(0, 0, -0.7853981633974483)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 3)
			local clone3 = v3.WindParticle:Clone()
			clone3.CFrame = startCF * CFrame.new(-7.5, 2.5, 0) * CFrame.Angles(0, 0, 0.7853981633974483)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 10)
			local clone4 = v3.WindParticle:Clone()
			clone4.CFrame = startCF * CFrame.new(-7.5, 2.5, 0) * CFrame.Angles(0, 0, -0.7853981633974483)
			clone4.Parent = workspace.Effects
			_G.PU:Dust(clone4, 10)
			_G.ParticleSize(clone3.ParticleEmitter, 0.5)
			_G.ParticleSize(clone4.ParticleEmitter, 0.5)
			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 1,
					WaitTime = 0.1
				}, function()
					local clone5 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
					clone5.Transparency = -1
					clone5.Color = Color3.fromRGB(255, 255, 255)
					clone5.CFrame = rootPart.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone5.Parent = workspace.Effects
					TweenService:Create(clone5, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
						Size = createVector(30, 2.5, 30) * math.random(10, 20) / 15,
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone5, 0.5)
				end)
			end)
			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 1,
					WaitTime = 0.05
				}, function()
					if not followFolder:IsDescendantOf(character) or character.Humanoid.Health <= 0 then
						return true
					end

					clone.CFrame = rootPart.CFrame * CFrame.new(-15, 5, 0) * CFrame.Angles(0, 0, 0.7853981633974483)
					clone2.CFrame = rootPart.CFrame * CFrame.new(15, 5, 0) * CFrame.Angles(0, 0, -0.7853981633974483)
					clone3.CFrame = rootPart.CFrame * CFrame.new(-7.5, 2.5, 0) * CFrame.Angles(0, 0, 0.7853981633974483)
					clone4.CFrame = rootPart.CFrame * CFrame.new(7.5, 2.5, 0) * CFrame.Angles(0, 0, -0.7853981633974483)
					clone.ParticleEmitter:Emit(1)
					clone2.ParticleEmitter:Emit(1)
					clone3.ParticleEmitter:Emit(1)
					clone4.ParticleEmitter:Emit(1)
				end)
			end)
		elseif mode == "Water Style V Hold" then
			tick()
			local ball = v3.Ball
			local chargeFolder = v3.ChargeFolder
			local character = v3.Character
			local _ = character.LeftHand
			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 10,
					WaitTime = 0.05
				}, function()
					if not ball:IsDescendantOf(workspace.Effects) or not chargeFolder:IsDescendantOf(character) or character.Humanoid.Health <= 0 then
						return true
					end

					local cFrame = ball.CFrame
					local clone = v3.Slash:Clone()
					clone.Mesh.Scale = createVector(18.75, 0.5, 18.75)
					clone.Decal.Color3 = math.random(1, 2) == 1 and Color3.fromRGB(555, 555, 555) or Color3.fromRGB(
						0,
						255,
						555
					)
					clone.Decal.Transparency = -1
					clone.CFrame = cFrame * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					clone.Parent = workspace.Effects
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					}):Play()
					TweenService:Create(clone.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Scale = createVector(0, 0.125, 0)
					}):Play()
					_G.PU:Dust(clone, 0.5)
				end)
				ball.Transparency = 1
			end)
			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 10,
					WaitTime = 0.1
				}, function()
					if not ball:IsDescendantOf(workspace.Effects) or not chargeFolder:IsDescendantOf(character) or character.Humanoid.Health <= 0 then
						return true
					end

					ball.Transparency = 0
					ball.Size = createVector(1.5, 1.5, 1.5)
					TweenService:Create(
						ball,
						TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
						{
							Transparency = 0.5,
							Size = createVector(2.5, 2.5, 2.5)
						}
					):Play()
				end)
				ball.Transparency = 1
			end)
		elseif mode == "Water Style V Cast" then
			local startCF = v3.StartCF
			task.spawn(function()
				if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 150 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.WaterStyleV)
					local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
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
			task.spawn(function()
				local v4 = startCF * CFrame.new(0, 0, 50)

				for i = 1, 2 do
					local clone = v3.Ring:Clone()
					clone.Transparency = -1
					clone.Size = Vector3.new()
					clone.CFrame = v4 * CFrame.new(0, 0, i * -15)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Transparency = 1,
						Size = createVector(50, 50, 5) * i,
						CFrame = v4 * CFrame.new(0, 0, i * -15) * CFrame.Angles(0, 0, 6.283185307179586 * math.random())
					}):Play()
				end

				local clone = v3.AnchorSmash2:Clone()
				clone.CFrame = CFrame.new(startCF.p)
				clone.Parent = workspace.Effects
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

				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(emitter, 2)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end)
			task.spawn(function()
				for i = 1, 15 do
					local cframe = CFrame.new(startCF.p) * CFrame.Angles(0, 6.283185307179586 * i / 15, 0) * CFrame.new(
						0,
						0,
						-37.5
					)
					Ray.new(cframe.p, createVector(0, -10, 0))
					local _, v4, _ = cframe:ToOrientation()
					local ray = Ray.new(cframe.p, createVector(0, -10, 0))
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
					local _ = raycastResult and raycastResult.Normal
					local material = raycastResult and raycastResult.Material or nil

					if not instance then
						continue
					end

					local part = Instance.new("Part")
					part.Anchored = true
					part.CanCollide = false
					part.CFrame = CFrame.new(startCF.p) * CFrame.fromOrientation(0, v4, 0)
					part.Size = createVector(0, 0, 0)
					part.Parent = workspace.Effects
					TweenService:Create(
						part,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v4, 0) * CFrame.new(
								0,
								math.random(-20, 1) / 20,
								0
							) * CFrame.Angles(math.rad((math.random(30, 90))), 0, 0),
							Size = createVector(16.8, 7, 7)
						}
					):Play()
					TweenService:Create(
						part,
						TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 1),
						{
							Transparency = 1
						}
					):Play()
					part.Material = material or "SmoothPlastic"
					part.BrickColor = instance.BrickColor
					_G.PU:Dust(part, 2)
				end
			end)
		elseif mode == "Water Style Ball Loop" then
			local ball = v3.Ball
			local chargeFolder = v3.ChargeFolder
			local character = v3.Character
			task.spawn(function()
				tick()
				PeodizService.HeartbeatWait({
					Time = 15,
					WaitTime = 0.1
				}, function()
					if not ball:IsDescendantOf(workspace.Effects) or not chargeFolder:IsDescendantOf(character) or character.Humanoid.Health <= 0 then
						return true
					end

					ball.Transparency = 0
					ball.Size = createVector(1.5, 1.5, 1.5)
					TweenService:Create(
						ball,
						TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
						{
							Transparency = 0.5,
							Size = createVector(2.5, 2.5, 2.5)
						}
					):Play()
				end)
				ball.Transparency = 1
			end)
		elseif mode == "Aquatic Anchor M4" then
			local startCF = v3.StartCF
			local clone = ReplicatedStorage.Chest.SwordEffect["Aquatic Anchor"]["M4 Aquatic Anchor"]:Clone()
			clone.CFrame = CFrame.new(startCF.p)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local v4 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://11843140426",
				Volume = 1.5
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 2)
			sound.Parent = clone
			sound:Play()
			task.spawn(function()
				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
			task.spawn(function()
				for i = 1, 14 do
					local cframe = CFrame.new(startCF.p) * CFrame.Angles(0, 6.283185307179586 * i / 14, 0) * CFrame.new(
						0,
						0,
						-10
					)
					local ray = Ray.new(cframe.p, createVector(0, -5, 0))
					local _, v5, _ = cframe:ToOrientation()
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
					local _ = raycastResult and raycastResult.Normal
					local material = raycastResult and raycastResult.Material or nil

					if not instance then
						continue
					end

					local part = Instance.new("Part")
					part.Anchored = true
					part.CanCollide = false
					part.CFrame = CFrame.new(startCF.p) * CFrame.fromOrientation(0, v5, 0)
					part.Size = createVector(0, 0, 0)
					part.Parent = workspace.Effects
					TweenService:Create(
						part,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v5, 0) * CFrame.new(
								0,
								math.random(-10, 1) / 20,
								0
							) * CFrame.Angles(math.rad((math.random(30, 90))), 0, 0),
							Size = createVector(4.8, 2, 2)
						}
					):Play()
					TweenService:Create(
						part,
						TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 1),
						{
							Transparency = 1
						}
					):Play()
					part.Material = material or "SmoothPlastic"
					part.BrickColor = instance.BrickColor
					_G.PU:Dust(part, 2)
				end
			end)
			task.spawn(function()
				if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 150 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
				end

				local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
				clone2.Color = Color3.fromRGB(0, 170, 255)
				clone2.CastShadow = false
				clone2.Transparency = -1
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.Size = createVector(50, 50, 50)
				clone2.CFrame = CFrame.new(startCF.p)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 0.15)
				TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Size = createVector(0, 75, 0),
					CFrame = clone2.CFrame * CFrame.new(0, 37.5, 0)
				}):Play()
			end)
		elseif mode == "Normal M4" then
			local startCF = v3.StartCF
			local clone = ReplicatedStorage.Chest.SwordEffect.Etc.M4Ex:Clone()
			clone.CFrame = CFrame.new(startCF.p)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local v4 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://11843140426",
				Volume = 1.5
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 2)
			sound.Parent = clone
			sound:Play()
			task.spawn(function()
				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
			task.spawn(function()
				for i = 1, 14 do
					local cframe = CFrame.new(startCF.p) * CFrame.Angles(0, 6.283185307179586 * i / 14, 0) * CFrame.new(
						0,
						0,
						-10
					)
					local ray = Ray.new(cframe.p, createVector(0, -5, 0))
					local _, v5, _ = cframe:ToOrientation()
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
					local _ = raycastResult and raycastResult.Normal
					local material = raycastResult and raycastResult.Material or nil

					if not instance then
						continue
					end

					local part = Instance.new("Part")
					part.Anchored = true
					part.CanCollide = false
					part.CFrame = CFrame.new(startCF.p) * CFrame.fromOrientation(0, v5, 0)
					part.Size = createVector(0, 0, 0)
					part.Parent = workspace.Effects
					TweenService:Create(
						part,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v5, 0) * CFrame.new(
								0,
								math.random(-10, 1) / 20,
								0
							) * CFrame.Angles(math.rad((math.random(30, 90))), 0, 0),
							Size = createVector(4.8, 2, 2)
						}
					):Play()
					TweenService:Create(
						part,
						TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 1),
						{
							Transparency = 1
						}
					):Play()
					part.Material = material or "SmoothPlastic"
					part.BrickColor = instance.BrickColor
					_G.PU:Dust(part, 2)
				end
			end)
			task.spawn(function()
				local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
				clone2.Color = Color3.fromRGB(255, 255, 255)
				clone2.CastShadow = false
				clone2.Transparency = -1
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.Size = createVector(50, 50, 50)
				clone2.CFrame = CFrame.new(startCF.p)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 0.15)
				TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Size = createVector(0, 75, 0),
					CFrame = clone2.CFrame * CFrame.new(0, 37.5, 0)
				}):Play()
			end)
		elseif mode == "None Z" then
			local startCF = v3.StartCF
			local clone = ReplicatedStorage.Chest.SwordEffect.Etc.M4Ex:Clone()
			clone.CFrame = CFrame.new(startCF.p)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local v4 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://11843140426",
				Volume = 1.5
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 2)
			sound.Parent = clone
			sound:Play()
			task.spawn(function()
				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(emitter, 2)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end)
			task.spawn(function()
				for i = 1, 14 do
					local cframe = CFrame.new(startCF.p) * CFrame.Angles(0, 6.283185307179586 * i / 14, 0) * CFrame.new(
						0,
						0,
						-20
					)
					local ray = Ray.new(cframe.p, createVector(0, -10, 0))
					local _, v5, _ = cframe:ToOrientation()
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
					local _ = raycastResult and raycastResult.Normal
					local material = raycastResult and raycastResult.Material or nil

					if not instance then
						continue
					end

					local part = Instance.new("Part")
					part.Anchored = true
					part.CanCollide = false
					part.CFrame = CFrame.new(startCF.p) * CFrame.fromOrientation(0, v5, 0)
					part.Size = createVector(0, 0, 0)
					part.Parent = workspace.Effects
					TweenService:Create(
						part,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v5, 0) * CFrame.new(
								0,
								math.random(-10, 1) / 20,
								0
							) * CFrame.Angles(math.rad((math.random(30, 90))), 0, 0),
							Size = createVector(9.6, 4, 4)
						}
					):Play()
					TweenService:Create(
						part,
						TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 1),
						{
							Transparency = 1
						}
					):Play()
					part.Material = material or "SmoothPlastic"
					part.BrickColor = instance.BrickColor
					_G.PU:Dust(part, 2)
				end
			end)
			task.spawn(function()
				if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 150 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
				end

				local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
				clone2.Color = Color3.fromRGB(255, 255, 255)
				clone2.CastShadow = false
				clone2.Transparency = -1
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.Size = createVector(100, 100, 100)
				clone2.CFrame = CFrame.new(startCF.p)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 0.15)
				TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Size = createVector(0, 150, 0),
					CFrame = clone2.CFrame * CFrame.new(0, 37.5, 0)
				}):Play()
			end)
		elseif mode == "Update Awake Fruit Count" then
			task.spawn(function()
				if v.Name ~= localPlayer.Name then
					return
				end

				local fruitName = v3.FruitName
				local FruitList = require(ReplicatedStorage.Chest.Modules.FruitList)

				if v3.Type == "Completed" then
					local awakeFruitCount = workspace.Island:FindFirstChild("AwakeFruitCount")

					if awakeFruitCount then
						local surfaceGui = awakeFruitCount.Part.SurfaceGui
						local fruitImage = surfaceGui.FruitImage
						local num = surfaceGui.Num
						surfaceGui.Enabled = true
						awakeFruitCount.Neon.Color = v3.Color
						fruitImage.Image = FruitList[fruitName]
						TweenService:Create(
							awakeFruitCount.Neon,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true, 0),
							{
								Size = createVector(5, 5, 0.14),
								Color = Color3.fromRGB(85, 255, 0)
							}
						):Play()
						task.spawn(function()
							if v3.Color == Color3.fromRGB(85, 255, 0) then
								wait(1)
								TweenService:Create(num, TweenInfo.new(1, Enum.EasingStyle.Linear), {
									TextTransparency = 1,
									TextStrokeTransparency = 1
								}):Play()
								TweenService:Create(fruitImage, TweenInfo.new(1, Enum.EasingStyle.Linear), {
									ImageTransparency = 0
								}):Play()
							end
						end)
					end
				else
					local awakeFruitCount = workspace.Island:FindFirstChild("AwakeFruitCount")

					if awakeFruitCount then
						local surfaceGui = awakeFruitCount.Part.SurfaceGui
						local fruitImage = surfaceGui.FruitImage
						local num = surfaceGui.Num
						surfaceGui.Enabled = true
						awakeFruitCount.Neon.Color = v3.Color
						fruitImage.Image = FruitList[fruitName]
						num.Text = v3.ProgressNum

						if fruitImage.ImageTransparency == 1 then
							TweenService:Create(fruitImage, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
								ImageTransparency = 0.75
							}):Play()
						end

						if num.TextTransparency == 1 then
							TweenService:Create(num, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
								TextTransparency = 0,
								TextStrokeTransparency = 0
							}):Play()
						end

						TweenService:Create(
							awakeFruitCount.Neon,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true, 0),
							{
								Size = createVector(5, 5, 0.14),
								Color = Color3.fromRGB(85, 255, 0)
							}
						):Play()
						task.spawn(function()
							if v3.Color == Color3.fromRGB(85, 255, 0) then
								wait(1)
								TweenService:Create(num, TweenInfo.new(1, Enum.EasingStyle.Linear), {
									TextTransparency = 1,
									TextStrokeTransparency = 1
								}):Play()
								TweenService:Create(fruitImage, TweenInfo.new(1, Enum.EasingStyle.Linear), {
									ImageTransparency = 0
								}):Play()
							end
						end)
					end
				end
			end)
		elseif mode == "Rumble Z Re" then
			local startCF = v3.StartCF
			local endCF = v3.EndCF
			game:GetService("Debris")
			local assets = ReplicatedStorage.Chest.FruitEffect.Rumble.Assets
			local clone = assets.ElectricExplosionUnleash:Clone()
			_G.PU:Dust(clone, 2)
			clone.CFrame = startCF
			clone.Parent = workspace.Effects
			System.EmitDescendants(clone)
			System.FadeOutDescendantLights(clone, 0.4)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 700,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://15060313730",
				Volume = 2
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			local _ = (startCF.p - endCF.p).Magnitude

			local function Lightning(data)
				local beginCF = data.BeginCF
				local endCF2 = data.EndCF
				local ex = data.Ex or false
				local unit = (endCF2.p - beginCF.p).Unit
				local v4 = (endCF2.p - beginCF.p).Magnitude / 5
				local v5 = math.random(1, 3) * 3
				local v6 = {}

				for i = 0, 5 do
					local vector2 = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))

					if i == 0 or i == 5 then
						vector2 = Vector3.new()
					end

					v6[#v6 + 1] = beginCF.p + unit * v4 * i + vector2
				end

				task.spawn(function()
					PeodizService.ForceForLoop({
						Step = #v6,
						WaitTime = wait()
					}, function(p)
						local v7 = math.floor(p * #v6)
						local v8 = v6[v7]
						local v9 = v6[v7 + 1]

						if v9 then
							if v7 == 5 and ex then
								task.spawn(function()
									if (localPlayer.Character.HumanoidRootPart.Position - endCF2.p).Magnitude < 150 then
										_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
									end

									local clone2 = assets.ElectricExplosion:Clone()
									_G.PU:Dust(clone2, 2)
									clone2.CFrame = endCF
									clone2.Parent = workspace.Effects
									System.EmitDescendants(clone2)
									System.FadeOutDescendantLights(clone2, 0.4)
									local sound2 = PeoUtils.CreateSound({
										RollOffMaxDistance = 700,
										RollOffMinDistance = 0,
										RollOffMode = Enum.RollOffMode.Linear,
										SoundId = "rbxassetid://15060311782",
										Volume = 2
									})
									_G.PU:Dust(sound2, 3)
									sound2.Parent = clone2
									sound2:Play()

									for _ = 1, 5 do
										local _ = {
											endCF.Position,
											(endCF * CFrame.new(
												System.Random(-20, 20),
												System.Random(10, 20),
												System.Random(-20, 20)
											)).Position,
											(endCF * CFrame.new(
												System.Random(-30, 30),
												System.Random(0, 30),
												System.Random(-30, 30)
											)).Position
										}
									end

									System.Rocks({
										OriginCFrame = endCF,
										RockSize = createVector(8, 6, 6),
										Duration = 2,
										Amount = 20,
										Radius = 24,
										Chance = 70
									})
								end)
							end

							local part = Instance.new("Part")
							part.CastShadow = false
							part.CanCollide = false
							part.Anchored = true
							part.Color = Color3.fromRGB(0, 255, 255)
							part.Material = "Neon"
							part.Size = Vector3.new(v5, v5, (v8 - v9).Magnitude)
							part.CFrame = CFrame.new(v8, v9) * CFrame.new(0, 0, -(v8 - v9).Magnitude / 2)
							part.Parent = workspace.Effects
							TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
								Size = Vector3.new(0, 0, part.Size.Z)
							}):Play()
							_G.PU:Dust(part, 0.2)
						end
					end)
					task.delay(10, function()
						table.clear(v6)
					end)
				end)
			end

			for i = 1, 3 do
				if i == 3 then
					Lightning({
						BeginCF = startCF,
						EndCF = endCF,
						Ex = true
					})
				else
					Lightning({
						BeginCF = startCF,
						EndCF = endCF
					})
				end
			end
		elseif mode == "Rumble X Re" then
			game:GetService("Debris")
			local assets = ReplicatedStorage.Chest.FruitEffect.Rumble.Assets
			local startCF = v3.StartCF

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 150 then
				local clone = ReplicatedStorage.Chest.SwordEffect.Etc.Pondere3:Clone()
				clone.TintColor = Color3.fromRGB(0, 255, 255)
				clone.Enabled = true
				clone.Parent = game.Lighting
				_G.PU:Dust(clone, 0.01)
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
			end

			local clone = assets.ThunderBeam:Clone()
			System.DisableDescendantParticles(clone)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 700,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://15060310362",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 8)
			sound.Parent = clone.Start
			sound:Play()
			local v4 = {}

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("BasePart") then
					v4[#v4 + 1] = { descendant, descendant.Size, descendant.Transparency }
					descendant.Transparency = 1

					if descendant.Name == "Beam" then
						descendant.Size = Vector3.new(0, 0, descendant.Size.Z)
					else
						descendant.Size = createVector(0, 0, 0)
					end
				elseif descendant:IsA("Beam") then
					v4[#v4 + 1] = {
						descendant,
						descendant.Width0,
						descendant.Width1,
						descendant.CurveSize0,
						descendant.CurveSize1
					}
					descendant.Enabled = false
					descendant.Width0 = 0
					descendant.Width1 = 0
					descendant.CurveSize0 = 0
					descendant.CurveSize1 = 0
				end
			end

			clone.Parent = workspace.Effects
			clone.PrimaryPart.CFrame = startCF * CFrame.new(0, 0, -15) * CFrame.Angles(0, 3.141592653589793, 0)
			System.EnableDescendantParticles(clone.Start)
			System.EnableDescendantParticles(clone)
			TweenService:Create(
				clone.End.PointLight,
				TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Brightness = 1
				}
			):Play()
			task.spawn(function()
				for _ = 1, 10 do
					local _ = {
						clone.Start.Position,
						(clone.Start.CFrame * CFrame.new(
							System.Random(-100, 100),
							System.Random(-100, 100),
							(clone.Start.Position - clone.End.Position).Magnitude / 2 * System.Random(0.1, 1.8)
						)).Position,
						clone.End.Position
					}
					task.wait(0.1)
				end
			end)
			task.delay(1.2, function()
				System.DisableDescendantParticles(clone)
			end)
			_G.PU:Dust(clone, 3)

			for _, v5 in pairs(v4) do
				if v5[1]:IsA("BasePart") then
					v5[1].Transparency = v5[3]
					TweenService:Create(v5[1], TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Size = v5[2]
					}):Play()
					local v6 = v5
					task.delay(1, function()
						TweenService:Create(
							clone.End.PointLight,
							TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
							{
								Brightness = 0
							}
						):Play()

						if v6[1].Name == "Beam" then
							TweenService:Create(
								v6[1],
								TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
								{
									Size = Vector3.new(0, 0, v6[1].Size.Z / 2)
								}
							):Play()
						else
							TweenService:Create(
								v6[1],
								TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
								{
									Size = createVector(0, 0, 0)
								}
							):Play()
						end

						task.delay(0.4, function()
							v6[1].Transparency = 1
						end)
					end)
				elseif v5[1]:IsA("Beam") then
					v5[1].Enabled = true
					TweenService:Create(v5[1], TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Width0 = v5[2],
						Width1 = v5[3],
						CurveSize0 = v5[4],
						CurveSize1 = v5[5]
					}):Play()
					local v6 = v5
					task.delay(1, function()
						TweenService:Create(
							v6[1],
							TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
							{
								Width0 = 0,
								Width1 = 0,
								CurveSize0 = 0,
								CurveSize1 = 0
							}
						):Play()
					end)
				end
			end

			task.delay(10, function()
				table.clear(v4)
			end)
			task.wait(0.4, function()
				clone.Highlight.Enabled = false
			end)
		elseif mode == "Rumble C Re" then
			local p = v3.StartCF.p
			game:GetService("Debris")
			local assets = ReplicatedStorage.Chest.FruitEffect.Rumble.Assets
			local clone = ReplicatedStorage.Chest.FruitEffect.Rumble.Cloud:Clone()
			_G.PU:Dust(clone, 6)
			clone.Color = Color3.fromRGB(91, 93, 105)
			clone.CFrame = CFrame.new(p) * CFrame.new(0, 275, 0)
			clone.Size = createVector(50, 30, 50)
			clone.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1200,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://15061388263",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			TweenService:Create(clone, TweenInfo.new(0.25), {
				Size = createVector(400, 100, 400)
			}):Play()
			spawn(function()
				wait(2.5)
				TweenService:Create(clone, TweenInfo.new(0.25), {
					Size = createVector(200, 50, 200),
					Transparency = 1
				}):Play()
			end)
			local clone2 = assets.PowerBeam:Clone()
			System.DisableDescendantParticles(clone2)
			local v4 = {}

			for _, descendant in pairs(clone2:GetDescendants()) do
				if descendant:IsA("BasePart") then
					v4[#v4 + 1] = { descendant, descendant.Size, descendant.Transparency }
					descendant.Transparency = 1

					if descendant.Name == "Beam" then
						descendant.Size = Vector3.new(0, 0, descendant.Size.Z)
					else
						descendant.Size = createVector(0, 0, 0)
					end
				elseif descendant:IsA("Beam") then
					v4[#v4 + 1] = {
						descendant,
						descendant.Width0,
						descendant.Width1,
						descendant.CurveSize0,
						descendant.CurveSize1
					}
					descendant.Enabled = false
					descendant.Width0 = 0
					descendant.Width1 = 0
					descendant.CurveSize0 = 0
					descendant.CurveSize1 = 0
				end
			end

			clone2.Parent = workspace.Effects
			clone2.PrimaryPart.CFrame = CFrame.new(p)
			System.EnableDescendantParticles(clone2.Start)
			task.wait(0.5)

			if (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < 150 then
				local clone3 = ReplicatedStorage.Chest.SwordEffect.Etc.Pondere3:Clone()
				clone3.TintColor = Color3.fromRGB(0, 255, 255)
				clone3.Enabled = true
				clone3.Parent = game.Lighting
				_G.PU:Dust(clone3, 0.01)
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
			end

			System.EnableDescendantParticles(clone2)
			System.Rocks({
				OriginCFrame = clone2.End.CFrame,
				RockSize = createVector(18, 15, 15),
				Duration = 6,
				Amount = 18,
				Radius = 60,
				Chance = 210
			})
			TweenService:Create(
				clone2.End.PointLight,
				TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Brightness = 1
				}
			):Play()
			task.spawn(function()
				for _ = 1, 10 do
					local _ = {
						clone2.Start.Position,
						(clone2.Start.CFrame * CFrame.new(
							System.Random(-150, 150),
							-((clone2.Start.Position - clone2.End.Position).Magnitude / 2 * System.Random(0.1, 1.8)),
							System.Random(-150, 150)
						)).Position,
						clone2.End.Position
					}
					task.wait(0.1)
				end
			end)
			task.delay(1.2, function()
				System.DisableDescendantParticles(clone2)
				local clone3 = assets.Cracks:Clone()
				clone3.Parent = workspace.Effects
				clone3.CFrame = clone2.End.CFrame
				System.EmitDescendants(clone3)
				_G.PU:Dust(clone3, 3)
			end)
			_G.PU:Dust(clone2, 3)

			for _, v5 in pairs(v4) do
				if v5[1]:IsA("BasePart") then
					v5[1].Transparency = v5[3]
					TweenService:Create(v5[1], TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Size = v5[2]
					}):Play()
					local v6 = v5
					task.delay(1, function()
						TweenService:Create(
							clone2.End.PointLight,
							TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
							{
								Brightness = 0
							}
						):Play()

						if v6[1].Name == "Beam" then
							TweenService:Create(
								v6[1],
								TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
								{
									Size = Vector3.new(0, 0, v6[1].Size.Z)
								}
							):Play()
						else
							TweenService:Create(
								v6[1],
								TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
								{
									Size = createVector(0, 0, 0)
								}
							):Play()
						end

						task.delay(0.4, function()
							v6[1].Transparency = 1
						end)
					end)
				elseif v5[1]:IsA("Beam") then
					v5[1].Enabled = true
					TweenService:Create(v5[1], TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Width0 = v5[2],
						Width1 = v5[3],
						CurveSize0 = v5[4],
						CurveSize1 = v5[5]
					}):Play()
					local v6 = v5
					task.delay(1, function()
						TweenService:Create(
							v6[1],
							TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
							{
								Width0 = 0,
								Width1 = 0,
								CurveSize0 = 0,
								CurveSize1 = 0
							}
						):Play()
					end)
				end
			end

			task.delay(10, function()
				table.clear(v4)
			end)
			task.wait(0.4, function()
				clone2.Highlight.Enabled = false
			end)
		elseif mode == "Rumble V Re" then
			game:GetService("Debris")
			local assets = ReplicatedStorage.Chest.FruitEffect.Rumble.Assets
			task.spawn(function()
				local chargeFolder = v3.ChargeFolder
				local position = v3.RootPart.Position
				local endCFValue = v3.EndCFValue
				local character = v3.Character

				for _ = 1, 10 do
					local clone = ReplicatedStorage.Chest.FruitEffect.Rumble["El Thor"].Cloud:Clone()
					_G.PU:Dust(clone, 5)
					clone.CFrame = CFrame.new(position) * CFrame.new(
						math.random(-100, 100),
						250,
						math.random(-100, 100)
					)
					clone.Parent = workspace.Effects
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://539649706",
						Volume = 3
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = clone
					sound:Play()
					TweenService:Create(clone, TweenInfo.new(1), {
						Size = Vector3.new(math.random(150, 250), math.random(50, 75), math.random(150, 250)) * 2
					}):Play()
					delay(3, function()
						TweenService:Create(clone, TweenInfo.new(0.5), {
							Transparency = 1
						}):Play()
					end)
				end

				local clone = assets.ChargeBeams:Clone()
				clone.CFrame = CFrame.new(position) * CFrame.new(0, 150, 0)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 20)

				for _, beam in pairs(clone:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local width0 = beam.Width0
					local width1 = beam.Width1
					beam.Width0 = 0
					beam.Width1 = 0
					TweenService:Create(beam, TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
						Width0 = width0,
						Width1 = width1
					}):Play()
					local v4 = beam
					task.delay(1.6, function()
						TweenService:Create(v4, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						task.wait(1)
						v4.Enabled = false
					end)
				end

				local clone2 = assets.BlackBall:Clone()
				clone2.CFrame = clone.CFrame
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 20)
				System.EnableDescendantParticles(clone2)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 700,
					RollOffMinDistance = 0,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://15060308174",
					Volume = 2
				})
				sound.Parent = clone2
				sound:Play()
				task.spawn(function()
					local DELAY_DURATION = 3
					tick()
					PeodizService.HeartbeatWait({
						Time = 10,
						WaitTime = 0.05
					}, function()
						if not chargeFolder:IsDescendantOf(character) or character.Humanoid.Health <= 0 then
							return true
						end

						local _ = {
							clone2.Position,
							(clone2.CFrame * CFrame.new(
								System.Random(-200, 200),
								System.Random(-200, 200),
								System.Random(-200, 200)
							)).Position,
							(clone2.CFrame * CFrame.new(
								System.Random(-200, 200),
								System.Random(-200, 200),
								System.Random(-200, 200)
							)).Position,
							clone2.Position
						}
					end)
					TweenService:Create(clone2, TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
						Position = endCFValue.Value,
						Color = Color3.fromRGB(4, 175, 236)
					}):Play()
					task.spawn(function()
						wait(2)

						if clone2 then
							clone2:Destroy()
						end
					end)
					task.wait(1.8)

					if (localPlayer.Character.HumanoidRootPart.Position - endCFValue.Value).Magnitude < 300 then
						local clone3 = ReplicatedStorage.Chest.SwordEffect.Etc.Pondere3:Clone()
						clone3.TintColor = Color3.fromRGB(0, 255, 255)
						clone3.Enabled = true
						clone3.Parent = game.Lighting
						_G.PU:Dust(clone3, 0.01)
						_G.BeckCameraShake(_G.CameraShakerModule.Presets.Explosion)
					end

					System.Rocks({
						OriginCFrame = CFrame.new(endCFValue.Value),
						RockSize = createVector(16, 16, 24),
						Duration = 3,
						Amount = 35.2,
						Radius = 40,
						Chance = 70
					})
					task.wait(0.05)

					if clone2 then
						System.DisableDescendantParticles(clone2)
					end

					local clone3 = assets.Ball:Clone()
					clone3.Position = endCFValue.Value
					clone3.Size = createVector(0, 0, 0)
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 20)
					TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Size = createVector(160, 160, 160)
					}):Play()
					task.delay(0.1, function()
						System.Rocks({
							OriginCFrame = CFrame.new(endCFValue.Value),
							RockSize = createVector(30.6, 25.5, 34),
							Duration = 6,
							Amount = 38,
							Radius = 85,
							Chance = 70
						})
					end)
					local v4 = true

					if sound then
						TweenService:Create(sound, TweenInfo.new(1, Enum.EasingStyle.Linear), {
							Volume = 0
						}):Play()
					end

					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 700,
						RollOffMinDistance = 0,
						RollOffMode = Enum.RollOffMode.Linear,
						SoundId = "rbxassetid://15060307019",
						Volume = 1
					})
					_G.PU:Dust(sound2, 3)
					sound2.Parent = clone3
					sound2:Play()

					for _, descendant in pairs(clone3:GetDescendants()) do
						if descendant:IsA("Beam") then
							local v5 = {
								descendant.Width0,
								descendant.Width1,
								descendant.CurveSize0,
								descendant.CurveSize1
							}
							descendant.Width0 = 0
							descendant.Width1 = 0
							descendant.CurveSize0 = 0
							descendant.CurveSize1 = 0
							TweenService:Create(
								descendant,
								TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
								{
									Width0 = v5[1],
									Width1 = v5[2],
									CurveSize0 = v5[3],
									CurveSize1 = v5[4]
								}
							):Play()
							local v6 = descendant
							task.delay(DELAY_DURATION, function()
								TweenService:Create(
									v6,
									TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
									{
										Width0 = 0,
										Width1 = 0,
										CurveSize0 = 0,
										CurveSize1 = 0
									}
								):Play()
							end)
						elseif descendant:IsA("Attachment") then
							local position2 = descendant.Position
							descendant.Position = createVector(0, 0, 0)
							TweenService:Create(
								descendant,
								TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
								{
									Position = position2
								}
							):Play()
							local v5 = descendant
							task.delay(DELAY_DURATION, function()
								TweenService:Create(
									v5,
									TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
									{
										Position = createVector(0, 0, 0)
									}
								):Play()
							end)
						end
					end

					task.delay(DELAY_DURATION, function()
						v4 = false

						if clone3 then
							System.FadeOutDescendantLights(clone3, 1)
							TweenService:Create(
								clone3,
								TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
								{
									Size = createVector(0, 0, 0)
								}
							):Play()
						end
					end)
				end)
				task.wait(0.5)

				if clone2 then
					TweenService:Create(clone2, TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
						Size = createVector(150, 150, 150)
					}):Play()
				end
			end)
		elseif mode == "Rumble E Re" then
			game:GetService("Debris")
			local assets = ReplicatedStorage.Chest.FruitEffect.Rumble.Assets
			local endCF = v3.EndCF
			local startCF = v3.StartCF

			local function Lightning(data)
				local beginCF = data.BeginCF
				local endCF2 = data.EndCF
				local _ = data.Ex or false
				local unit = (endCF2.p - beginCF.p).Unit
				local v4 = (endCF2.p - beginCF.p).Magnitude / 5
				local v5 = math.random(1, 3) * 3
				local v6 = {}

				for i = 0, 5 do
					local vector2 = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))

					if i == 0 or i == 5 then
						vector2 = Vector3.new()
					end

					v6[#v6 + 1] = beginCF.p + unit * v4 * i + vector2
				end

				task.spawn(function()
					PeodizService.ForceForLoop({
						Step = #v6
					}, function(p)
						local v7 = math.floor(p * #v6)
						local v8 = v6[v7]
						local v9 = v6[v7 + 1]

						if v9 then
							local part = Instance.new("Part")
							part.CastShadow = false
							part.CanCollide = false
							part.Anchored = true
							part.Color = Color3.fromRGB(0, 255, 255)
							part.Material = "Neon"
							part.Size = Vector3.new(v5, v5, (v8 - v9).Magnitude)
							part.CFrame = CFrame.new(v8, v9) * CFrame.new(0, 0, -(v8 - v9).Magnitude / 2)
							part.Parent = workspace.Effects
							TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
								Size = Vector3.new(0, 0, part.Size.Z)
							}):Play()
							_G.PU:Dust(part, 0.2)
						end
					end)
					task.delay(10, function()
						table.clear(v6)
					end)
				end)
			end

			local clone = assets.ElectricDash:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = startCF
			System.EmitDescendants(clone)
			_G.PU:Dust(clone, 3)
			task.spawn(function()
				PeodizService.ForLoop({
					Step = 2
				}, function(_)
					Lightning({
						BeginCF = startCF,
						EndCF = endCF
					})
				end)
			end)
			task.wait(0.05)
			local clone2 = assets.ElectricDashEnd:Clone()
			clone2.Parent = workspace.Effects
			clone2.CFrame = endCF
			System.EmitDescendants(clone2)
			_G.PU:Dust(clone2, 3)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 700,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://15060305597",
				Volume = 0.5,
				PlaybackSpeed = 2
			})
			_G.PU:Dust(sound, 5)
			sound.Parent = clone2
			sound:Play()
		elseif mode == "Pumpkin Smasher Z" then
			local character = v3.Character
			local rootPart = v3.RootPart
			local clone = ReplicatedStorage.Chest.SwordEffect.PumpkinSmasher.Spin:Clone()
			clone.CFrame = rootPart.CFrame
			clone.Parent = character
			_G.PU:Dust(clone, 3)
			local v4 = {
				RollOffMaxDistance = 250,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://15157429990",
				Volume = 6
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			local weld = Instance.new("Weld")
			weld.Part0 = rootPart
			weld.Part1 = clone
			weld.Parent = clone
			_G.PU:Dust(weld, 3)
			task.spawn(function()
				for _ = 1, 5 do
					for _, emitter in pairs(clone.Attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					wait(0.1)
				end
			end)
			task.spawn(function()
				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				wait(0.6)

				if clone and clone:FindFirstChild("Attachment") then
					_G.PU:Dust(clone, 1)

					for _, emitter in pairs(clone.Attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end
			end)
		elseif mode == "Chaos Crab Z" then
			local effects = workspace.Effects
			local chaosCrab = ReplicatedStorage.Chest.Etc["Chaos Crab"]
			local character = v3.Character
			local startCF = v3.StartCF
			local rootPart = v3.RootPart
			local combo = v3.Combo or 1
			local cFTbl = v3.CFTbl
			local teleportCF = v3.TeleportCF
			local clone = chaosCrab.hand:Clone()
			_G.PU:Dust(clone, 1)
			clone.Anchored = false
			clone.Parent = effects
			Utility.EmitParticles(clone)
			Utility.ParticleHandler(clone, true)
			local rigidConstraint = Instance.new("RigidConstraint")
			rigidConstraint.Attachment0 = character:FindFirstChild("LeftHandAT", true)
			rigidConstraint.Attachment1 = clone.Circular
			rigidConstraint.Parent = clone
			local trail = character:FindFirstChild("Trail", true)

			if combo == 1 then
				task.wait(0.45)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://82242554993250",
					Volume = 1
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = rootPart
				sound:Play()
				local clone2 = chaosCrab.CrabS1:Clone()
				_G.PU:Dust(clone2, 3)
				clone2.CFrame = teleportCF * CFrame.new(0, 10, -30)
				clone2.Parent = effects
				Utility.EmitParticles(clone2)
				Utility.ParticleHandler(clone, false)

				if trail and trail.Parent then
					trail.Enabled = true
				end

				if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude < 200 then
					_G.CameraShake:ShakeOnce(6, 12, 0, 0.3)
				end
			elseif combo == 2 then
				task.wait(0.45)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://97655807176888",
					Volume = 1
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = rootPart
				sound:Play()
				local clone2 = chaosCrab.Circ:Clone()
				_G.PU:Dust(clone2, 3)
				clone2:PivotTo(teleportCF)
				clone2.Parent = effects

				if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude < 200 then
					_G.CameraShake:ShakeOnce(7, 12, 0, 0.5)
				end

				Utility.EmitParticles(clone2.RootPart)
				PeodizService.ForceForLoop({
					Step = 5,
					WaitTime = 0.05
				}, function(p)
					local v4 = math.floor(p * 5)
					local v5 = clone2[tostring(v4)]
					v5.CFrame = teleportCF * CFrame.new(0, 0, -10) * CFrame.Angles(
						0,
						-1.5707963267948966 + 0.6283185307179586 * v4,
						0
					) * CFrame.new(0, 10, -40)
					task.delay(wait(), function()
						Utility.EmitParticles(v5)
					end)
				end)
			elseif combo == 3 then
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 100,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://99411117432720",
					Volume = 0.75
				})
				_G.PU:Dust(sound, 2)
				sound.Parent = rootPart
				sound:Play()

				local function BeforeS3()
					local function flicker(duration, clone2)
						local decal = clone2.Decal
						clone2.progress.CFrame = clone2.CFrame
						decal.Transparency = 1
						clone2.Size = Vector3.new()
						clone2.progress.Size = Vector3.new()
						TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
							Size = createVector(300, 0.001, 300)
						}):Play()
						TweenService:Create(clone2.progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
							Size = createVector(300, 0.001, 300)
						}):Play()
						local tween = TweenService:Create(
							decal,
							TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 1e999, true),
							{
								Transparency = 0
							}
						)
						tween:Play()
						task.delay(duration, function()
							tween:Cancel()
							decal.Transparency = 0
							TweenService:Create(
								clone2,
								TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Size = createVector(0, 0, 0)
								}
							):Play()
							TweenService:Create(
								decal,
								TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
							TweenService:Create(
								clone2.progress.Decal,
								TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
						end)
					end

					local _ = rootPart.CFrame * CFrame.new(0, 1, 0)
					local count = 0

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 500 then
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.Inverse,
							SoundId = "rbxassetid://134934245741559",
							Volume = 1
						})
						_G.PU:Dust(sound2, 5)
						sound2.Parent = SoundService
						sound2:Play()
					end

					PeodizService.ForceForLoop({
						Step = 6
					}, function(p)
						local v4 = math.floor(p * 6)
						local spawnCF = cFTbl[v4].spawnCF
						local ranAngle = cFTbl[v4].ranAngle
						local cframe = CFrame.new(spawnCF.p)
						local clone2 = chaosCrab.warning:Clone()
						_G.PU:Dust(clone2, 5)
						clone2.CFrame = cframe * ranAngle
						clone2.Parent = effects
						Utility.ParticleHandler(clone2, true)
						flicker(1.8, clone2)
						count += 1

						if count % 2 == 0 then
							wait()
						end

						task.spawn(function()
							wait(1.9)
							Utility.ParticleHandler(clone2, false)
							local clone3 = chaosCrab.pillar_exp:Clone()
							_G.PU:Dust(clone3, 2)
							clone3.CFrame = cframe * ranAngle
							clone3.Parent = effects
							Utility.EmitParticles(clone3)
							local sound2 = PeoUtils.CreateSound({
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://101802966725308",
								Volume = 0.75
							})
							_G.PU:Dust(sound2, 2)
							sound2.Parent = clone3
							sound2:Play()
							PeodizService.ForLoop({
								Step = 6
							}, function(_)
								local v5 = CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
									0,
									0,
									math.random(15, 35)
								)
								local v6 = CFrame.new(cframe.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * v5
								local _ = v6 * CFrame.new(0, 100, 0)
								local raycastParams = RaycastParams.new()
								raycastParams.FilterType = Enum.RaycastFilterType.Exclude
								raycastParams.FilterDescendantsInstances = { effects }
								local raycastResult = workspace:Raycast(
									v6.Position,
									createVector(0, -45, 0),
									raycastParams
								)

								if raycastResult and raycastResult.Instance and raycastResult.Position then
									local part = Instance.new("Part")
									_G.PU:Dust(part, 2)
									part.Name = "Rock"
									part.Anchored = true
									part.CanCollide = false
									part.Massless = true
									local v7 = math.random(2, 12)
									part.Size = Vector3.new(
										v7,
										v7 / (math.random(15, 20) / 10),
										v7 / (math.random(15, 20) / 10)
									) * 1.1
									part.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random()
									)
									part.Material = raycastResult.Material
									part.Color = raycastResult.Instance.Color
									part.CollisionGroup = "Effect"
									part.Parent = effects
									TweenService:Create(
										part,
										TweenInfo.new(
											math.random(40, 50) / 100,
											Enum.EasingStyle.Exponential,
											Enum.EasingDirection.Out
										),
										{
											CFrame = CFrame.new(raycastResult.Position + Vector3.new(
												0,
												math.random(30, 70),
												0
											)) * CFrame.Angles(
												6.283185307179586 * math.random(),
												6.283185307179586 * math.random(),
												6.283185307179586 * math.random()
											)
										}
									):Play()
									task.spawn(function()
										wait(0.15)

										if part and part.Parent then
											TweenService:Create(
												part,
												TweenInfo.new(
													math.random(35, 45) / 100,
													Enum.EasingStyle.Cubic,
													Enum.EasingDirection.Out
												),
												{
													Size = Vector3.new()
												}
											):Play()
										end
									end)
								end
							end)
						end)
					end)
				end

				task.spawn(function()
					BeforeS3()
				end)
				task.delay(0.317, function()
					local clone2 = chaosCrab.hand2:Clone()
					_G.PU:Dust(clone2, 2)
					clone2.Anchored = true
					clone2.CFrame = character:FindFirstChild("LeftHandAT", true).WorldCFrame
					clone2.Parent = effects
					Utility.EmitParticles(clone2)
				end)
				task.delay(0.583, function()
					if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude < 200 then
						_G.CameraShake:ShakeOnce(8, 16, 0, 0.3)
					end

					trail.Enabled = false
					local clone2 = chaosCrab.Explode:Clone()
					_G.PU:Dust(clone2, 3)
					clone2.CFrame = rootPart.CFrame * CFrame.new(0, 1, -20)
					clone2.Parent = effects
					Utility.EmitParticles(clone2)
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.Inverse,
						SoundId = "rbxassetid://77153530742629",
						Volume = 2
					})
					_G.PU:Dust(sound2, 2)
					sound2.Parent = clone2
					sound2:Play()
				end)
			elseif combo == 4 then
				local _ = v3.TargetRootPart
				local targetVect3s = v3.TargetVect3s
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 100,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://83104575420059",
					Volume = 0.75
				})
				_G.PU:Dust(sound, 2)
				sound.Parent = rootPart
				sound:Play()
				local clones = {}

				local function BeforeS3()
					local function flicker(duration, clone2)
						local decal = clone2.Decal
						clone2.progress.CFrame = clone2.CFrame
						decal.Transparency = 1
						clone2.Size = Vector3.new()
						clone2.progress.Size = Vector3.new()
						TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
							Size = createVector(300, 0.001, 300)
						}):Play()
						TweenService:Create(clone2.progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
							Size = createVector(300, 0.001, 300)
						}):Play()
						local tween = TweenService:Create(
							decal,
							TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 1e999, true),
							{
								Transparency = 0
							}
						)
						tween:Play()
						task.delay(duration, function()
							tween:Cancel()
							decal.Transparency = 0
							TweenService:Create(
								clone2,
								TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Size = createVector(0, 0, 0)
								}
							):Play()
							TweenService:Create(
								decal,
								TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
							TweenService:Create(
								clone2.progress.Decal,
								TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
						end)
					end

					local _ = rootPart.CFrame * CFrame.new(0, 1, 0)
					local count = 0
					task.spawn(function()
						wait(0.75)
						local lastTime = tick()
						PeodizService.HeartbeatWait({
							Time = 2
						}, function(_)
							if tick() - lastTime > 0.1 then
								lastTime = tick()

								if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude < 200 then
									_G.CameraShake:ShakeOnce(2.25, 13, 0, 0.2)
								end
							end
						end)
					end)

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 500 then
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.Inverse,
							SoundId = "rbxassetid://134934245741559",
							Volume = 1
						})
						_G.PU:Dust(sound2, 5)
						sound2.Parent = SoundService
						sound2:Play()
					end

					local explodeCFs = v3.ExplodeCFs
					PeodizService.ForceForLoop({
						Step = 8
					}, function(p)
						local v4 = math.floor(p * 8)
						local explodeCF = explodeCFs[v4]

						if not explodeCF then
							return
						end

						local v5 = explodeCF * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
							0,
							0,
							math.random(25, 200)
						)
						local cframe = CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
						local cframe2 = CFrame.new(explodeCF.p)
						local cframe3 = CFrame.new(v5.p)
						local clone2 = chaosCrab.warning:Clone()
						_G.PU:Dust(clone2, 5)
						clone2.CFrame = cframe3 * cframe
						clone2.Parent = effects
						Utility.ParticleHandler(clone2, true)
						flicker(1.8, clone2)
						count += 1

						if count % 2 == 0 then
							wait()
						end

						TweenService:Create(clone2, TweenInfo.new(2, Enum.EasingStyle.Sine), {
							CFrame = cframe2 * cframe
						}):Play()
						task.spawn(function()
							wait(1.9)
							Utility.ParticleHandler(clone2, false)
							local clone3 = chaosCrab.pillar_exp:Clone()
							_G.PU:Dust(clone3, 3)
							clone3.CFrame = cframe2 * cframe
							clone3.Parent = effects
							local sound2 = PeoUtils.CreateSound({
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://103511063907229",
								Volume = 0.75
							})
							_G.PU:Dust(sound2, 5)
							sound2.Parent = clone3
							sound2:Play()
							task.spawn(function()
								TweenService:Create(clone3, TweenInfo.new(2, Enum.EasingStyle.Linear), {
									CFrame = cframe2 * cframe * CFrame.new(0, 0, -25)
								}):Play()
								Utility.ParticleHandler(clone3, true)
								wait(0.65)
								Utility.ParticleHandler(clone3, false)
							end)
							task.delay(0.5, function()
								if v4 == 1 then
									local cFrame = clone3.CFrame
									local clone4 = chaosCrab.WaterBall:Clone()
									_G.PU:Dust(clone4, 3)
									clone4.CFrame = cFrame
									clone4.Parent = effects
									clone4:SetAttribute("Timer", tick())
									clone4:SetAttribute("StartPos", cFrame.Position)
									clone4:SetAttribute("Height", math.random(25, 60))
									clone4:SetAttribute("Curve", math.random(-50, 50))
									clones[v4] = clone4
								end
							end)
						end)
					end)

					-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
					local function quadBezier(p, startPos, p2, value)
						return (1 - p) ^ 2 * startPos + 2 * (1 - p) * p * p2 + p ^ 2 * value
					end

					local lastTime = tick()
					local flag = nil

					while tick() - lastTime < 5 do
						RunService.Heartbeat:Wait()

						if flag then
							local _ = #clones <= 0
						end

						for i = #clones, 1, -1 do
							local v4 = clones[i]

							if not v4 then
								continue
							end

							local value = targetVect3s[i].Value

							if not value then
								continue
							end

							local timer = v4:GetAttribute("Timer")
							local startPos = v4:GetAttribute("StartPos")
							local curve = v4:GetAttribute("Curve")
							local height = v4:GetAttribute("Height")
							local v5 = math.min(tick() - timer, 1)
							local position = quadBezier(
								v5,
								startPos,
								startPos:Lerp(value, 0.5) + (value - startPos).Unit:Cross(createVector(0, 1, 0)).Unit * curve + Vector3.new(
									0,
									height,
									0
								),
								value
							)
							flag = true
							v4.Position = position

							if not (v5 >= 1) then
								continue
							end

							table.remove(targetVect3s, i)
							table.remove(clones, i)

							if not (v4 and v4.Parent) then
								continue
							end

							local clone2 = chaosCrab.crab_exp:Clone()
							_G.PU:Dust(clone2, 2)
							clone2.CFrame = CFrame.new(position)
							clone2.Parent = effects
							Utility.EmitParticles(clone2)
							local sound2 = PeoUtils.CreateSound({
								RollOffMaxDistance = 500,
								RollOffMinDistance = 75,
								RollOffMode = Enum.RollOffMode.InverseTapered,
								SoundId = "rbxassetid://87149359703416",
								Volume = 1
							})
							_G.PU:Dust(sound2, 3)
							sound2.Parent = clone2
							sound2:Play()
							v4:Destroy()
						end
					end
				end

				local function S3()
					if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude < 200 then
						_G.CameraShake:ShakeOnce(8, 16, 0, 0.3)
					end

					trail.Enabled = false
					local clone2 = chaosCrab.Explode:Clone()
					_G.PU:Dust(clone2, 3)
					clone2.CFrame = rootPart.CFrame * CFrame.new(0, 1, -20)
					clone2.Parent = effects
					Utility.EmitParticles(clone2)
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.Inverse,
						SoundId = "rbxassetid://77153530742629",
						Volume = 2
					})
					_G.PU:Dust(sound2, 2)
					sound2.Parent = clone2
					sound2:Play()
				end

				task.spawn(function()
					BeforeS3()
				end)
				task.delay(0.83, function()
					S3()
				end)
			end

			if trail and trail.Parent then
				trail.Enabled = false
			end
		elseif mode == "Craberno Z" then
			local effects = workspace.Effects
			local chaosCrab = ReplicatedStorage.Chest.Etc["Chaos Crab"]
			local rootPart = v3.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 100,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://83104575420059",
				Volume = 1.25
			})
			_G.PU:Dust(sound, 5)
			sound.Parent = rootPart
			sound:Play()
			local clone = chaosCrab.Roar:Clone()
			_G.PU:Dust(clone, 5)
			clone.CFrame = rootPart.CFrame
			clone.Parent = effects
			Utility.ParticleHandler(clone.Sphere, true)
			wait(1)
			Utility.ParticleHandler(clone.Sphere, false)
			Utility.EmitParticles(clone.Charge)
			wait()
			Utility.ParticleHandler(clone, true)
			Utility.ParticleHandler(clone.Sphere, false)

			if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 300 then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				_G.PU:Dust(colorCorrectionEffect, 5)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						TintColor = Color3.fromRGB(255, 215, 203),
						Contrast = 0.1
					}
				):Play()
				task.spawn(function()
					wait(4)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							TintColor = Color3.fromRGB(255, 255, 255),
							Brightness = 0,
							Contrast = 0
						}
					):Play()
				end)
			end

			task.spawn(function()
				wait(4)
				Utility.ParticleHandler(clone, false)
			end)

			local function flicker(duration, clone2)
				local decal = clone2.Decal
				clone2.progress.CFrame = clone2.CFrame
				decal.Transparency = 1
				clone2.Size = Vector3.new()
				clone2.progress.Size = Vector3.new()
				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
					Size = createVector(300, 0.001, 300)
				}):Play()
				TweenService:Create(clone2.progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
					Size = createVector(300, 0.001, 300)
				}):Play()
				local tween = TweenService:Create(
					decal,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 1e999, true),
					{
						Transparency = 0
					}
				)
				tween:Play()
				task.delay(duration, function()
					tween:Cancel()
					decal.Transparency = 0
					TweenService:Create(
						clone2,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
					TweenService:Create(
						decal,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						clone2.progress.Decal,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
			end

			local function meteor(p)
				local position = (p * CFrame.new(math.random(-50, 50), 150, math.random(-50, 50))).Position
				local position2 = p.Position
				local cframe = CFrame.lookAt(position, position2)
				local v4 = math.rad((math.random(0, 360)))
				local v5 = cframe * CFrame.Angles(0, 0, v4)
				local clone2 = chaosCrab.Meteor:Clone()
				_G.PU:Dust(clone2, 2)
				local main = clone2:FindFirstChild("Main")
				main.Anchored = true
				main.CanCollide = false
				clone2:PivotTo(v5)
				clone2.Parent = effects
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://133298211262165",
					Volume = 1.5
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone2.Main
				sound2:Play()
				task.spawn(function()
					clone2.Main.rock:Emit(30)
					Utility.EmitParticles(clone2.Main.EXp)
					Utility.ParticleHandler(clone2, true)
					clone2.Neon.Size = createVector(0, 25, 0)
					clone2.Main.Size = createVector(0, 25, 0)
					wait()
					TweenService:Create(
						clone2.Main,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = createVector(10, 10, 10)
						}
					):Play()
					TweenService:Create(
						clone2.Neon,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = createVector(11, 11, 11)
						}
					):Play()
				end)
				local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
				local cframe2 = CFrame.lookAt(position2, position2 + (position2 - position).Unit)
				local tween = TweenService:Create(main, tweenInfo, {
					CFrame = cframe2
				})
				TweenService:Create(clone2.Neon, tweenInfo, {
					CFrame = cframe2
				}):Play()
				tween:Play()
				local completedConnection = nil
				completedConnection = tween.Completed:Connect(function()
					Utility.EmitParticles(main)
					Utility.ParticleHandler(main, false)
					TweenService:Create(
						clone2.Neon,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = Vector3.new()
						}
					):Play()
					TweenService:Create(
						clone2.Main,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = Vector3.new()
						}
					):Play()
					local clone3 = chaosCrab.exp:Clone()
					_G.PU:Dust(clone3, 2)
					clone3.CFrame = CFrame.new(p.p) * CFrame.Angles(1.5707963267948966, 0, 0)
					clone3.Parent = effects
					Utility.EmitParticles(clone3)
					local soundId = math.random(1, 2) == 1 and "rbxassetid://104927381357449" or "rbxassetid://95316420983233"
					local sound3 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.Inverse,
						SoundId = soundId,
						Volume = 0.7
					})
					_G.PU:Dust(sound3, 3)
					sound3.Parent = clone3
					sound3:Play()
					completedConnection:Disconnect()
				end)
			end

			task.spawn(function()
				local explodeData = v3.ExplodeData

				if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 500 then
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.Inverse,
						SoundId = "rbxassetid://134934245741559",
						Volume = 1
					})
					_G.PU:Dust(sound2, 5)
					sound2.Parent = SoundService
					sound2:Play()
				end

				PeodizService.ForceForLoop({
					Step = 7,
					WaitTime = 0.5
				}, function(p)
					local v5 = explodeData[math.floor(p * 7)]

					if v5 then
						for i = 1, 2 do
							local cFrame = v5[i]

							if not cFrame then
								continue
							end

							local clone2 = chaosCrab.warning:Clone()
							_G.PU:Dust(clone2, 5)
							clone2.CFrame = cFrame
							clone2.Parent = effects
							Utility.ParticleHandler(clone2, true)
							flicker(2, clone2)
							local cFrame3 = cFrame
							task.delay(1.25, function()
								meteor(cFrame3)
							end)
						end
					end
				end)
			end)
			local lastTime = tick()
			local lastTime2 = tick()
			PeodizService.HeartbeatWait({
				Time = 4
			}, function(_)
				local v4 = tick() - lastTime
				task.wait()
				local v5 = math.pow(1 - v4 / 5, 2) * 8
				clone.CFrame *= CFrame.Angles(0, math.rad(v5), 0)

				if tick() - lastTime2 > 0.1 then
					lastTime2 = tick()

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
						_G.CameraShake:ShakeOnce(2.25, 13, 0, 0.2)
					end
				end
			end)
		elseif mode == "Craberno X" then
			local effects = workspace.Effects
			local chaosCrab = ReplicatedStorage.Chest.Etc["Chaos Crab"]
			local shieldHP = v3.ShieldHP
			local maxShieldHP = v3.MaxShieldHP
			local rootPart = v3.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 100,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://99411117432720",
				Volume = 1.25
			})
			_G.PU:Dust(sound, 5)
			sound.Parent = rootPart
			sound:Play()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 100,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://129156822828630",
				Volume = 1.25
			})
			_G.PU:Dust(sound2, 35)
			sound2.Parent = rootPart
			sound2:Play()
			local _ = {
				Inner = 0,
				Middle = 0,
				Outer = 0
			}
			local v4 = {}
			local v5 = {}
			local v6 = {}
			local v7 = {}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function randomSineHeight(p, p2)
				return (math.sin(p + p2) + 1) / 2 * 10 + 10
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function insertOrb(clones, step, _, _)
				PeodizService.ForceForLoop({
					Step = step
				}, function(_)
					local clone = chaosCrab.Orb:Clone()
					_G.PU:Dust(clone, 35)
					clone.Parent = effects
					Utility.EmitParticles(clone.EXp)
					Utility.ParticleHandler(clone, true)
					table.insert(clones, clone)
					table.insert(v7, math.random() * 3.141592653589793 * 2)
					local pointLight = clone.PointLight
					pointLight.Range = 0
					clone.Size = Vector3.new()
					clone.Inner.Size = Vector3.new()
					clone.Outer.Size = Vector3.new()
					TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = createVector(6.434, 6.434, 6.434)
					}):Play()
					TweenService:Create(
						clone.Inner,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = createVector(8.84, 8.84, 8.84)
						}
					):Play()
					TweenService:Create(
						clone.Outer,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = createVector(10.608, 10.608, 10.608)
						}
					):Play()
					TweenService:Create(
						pointLight,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Range = 30
						}
					):Play()
				end)
			end

			task.spawn(function()
				insertOrb(v4, 3) -- equivalent call inferred; original call site unknown
				wait()
				insertOrb(v5, 4) -- equivalent call inferred; original call site unknown
				wait()
				insertOrb(v6, 5) -- equivalent call inferred; original call site unknown
			end)

			local function shootProjectile(instance, instance2)
				local clone = chaosCrab.bullet:Clone()
				_G.PU:Dust(clone, 5)
				clone.CFrame = CFrame.new(instance.CFrame.p, instance2.CFrame.p)
				clone.Anchored = false
				clone.Parent = effects
				Utility.ParticleHandler(clone, true)
				local unit = (instance2.Position - instance.Position).Unit
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = unit * 250
				bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
				bodyVelocity.P = 2000
				bodyVelocity.Parent = clone
			end

			local v8 = maxShieldHP / 12

			local function checkOrbHP(p)
				if shieldHP.Value <= maxShieldHP - v8 * p then
					return true
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function deadOrb(instance)
				local pointLight = instance.PointLight
				task.spawn(function()
					TweenService:Create(
						instance,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = Vector3.new()
						}
					):Play()
					TweenService:Create(
						instance.Inner,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = Vector3.new()
						}
					):Play()
					TweenService:Create(
						instance.Outer,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = Vector3.new()
						}
					):Play()
					TweenService:Create(
						pointLight,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Range = 0
						}
					):Play()
					Utility.ParticleHandler(instance, false)
					task.wait(1)
					instance:Destroy()
				end)
			end

			local function orbGone(data)
				local sound3 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 100,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://98955021968030",
					Volume = 0.5
				})
				_G.PU:Dust(sound3, 5)
				sound3.Parent = rootPart
				sound3:Play()
				local pointLight = data.PointLight
				task.spawn(function()
					TweenService:Create(
						data,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Color = Color3.fromRGB(59, 43, 43)
						}
					):Play()
					TweenService:Create(
						data.Inner,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Color = Color3.fromRGB(49, 11, 0)
						}
					):Play()
					TweenService:Create(
						data.Outer,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Color = Color3.fromRGB(49, 11, 0)
						}
					):Play()
					TweenService:Create(
						pointLight,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Range = 0
						}
					):Play()
					Utility.ParticleHandler(data, false)
				end)
			end

			local lastTime = tick()

			while shieldHP.Parent do
				RunService.Heartbeat:Wait()
				local v9 = tick() - lastTime
				local v10 = 40 + math.sin((math.rad(v9 * 180))) * 15
				local v11 = 80 + math.sin((math.rad((1 + v9) * 180 * 1.5))) * 10
				local v12 = 110 + math.sin((math.rad((2 + v9) * 180))) * 10
				local count = 0

				for i, v13 in ipairs(v4) do
					count += 1
					local v14 = 2.0943951023931953 * i + v9 * 1.2566370614359172
					local v15 = randomSineHeight(v9, v7[i]) -- equivalent call inferred; original call site unknown
					local v16 = CFrame.Angles(0, v14, 0) * CFrame.new(0, v15, -v10)
					v13.CFrame = rootPart.CFrame * v16

					if not (shieldHP.Value <= maxShieldHP - v8 * count) or v13:GetAttribute("Gone") then
						continue
					end

					v13:SetAttribute("Gone", true)
					orbGone(v13)
				end

				for i, v13 in ipairs(v5) do
					count += 1
					local v14 = 1.5707963267948966 * i + v9 * 1.5707963267948966
					local v15 = randomSineHeight(v9, v7[#v4 + i]) -- equivalent call inferred; original call site unknown
					local v16 = CFrame.Angles(0, v14, 0) * CFrame.new(0, v15, -v11)
					v13.CFrame = rootPart.CFrame * v16

					if not (shieldHP.Value <= maxShieldHP - v8 * count) or v13:GetAttribute("Gone") then
						continue
					end

					v13:SetAttribute("Gone", true)
					orbGone(v13)
				end

				for i, v13 in ipairs(v6) do
					count += 1
					local v14 = 1.2566370614359172 * i + v9 * 2.0943951023931953
					local v15 = randomSineHeight(v9, v7[#v4 + #v5 + i]) -- equivalent call inferred; original call site unknown
					local v16 = CFrame.Angles(0, v14, 0) * CFrame.new(0, v15, -v12)
					v13.CFrame = rootPart.CFrame * v16

					if not (shieldHP.Value <= maxShieldHP - v8 * count) or v13:GetAttribute("Gone") then
						continue
					end

					v13:SetAttribute("Gone", true)
					orbGone(v13)
				end
			end

			for _, v9 in ipairs(v4) do
				deadOrb(v9) -- equivalent call inferred; original call site unknown
			end

			for _, v9 in ipairs(v5) do
				deadOrb(v9) -- equivalent call inferred; original call site unknown
			end

			for _, v9 in ipairs(v6) do
				deadOrb(v9) -- equivalent call inferred; original call site unknown
			end

			if sound2 and sound2.Parent then
				TweenService:Create(sound2, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(sound2, 1)
			end
		elseif mode == "Craberno C" then
			local effects = workspace.Effects
			local chaosCrab = ReplicatedStorage.Chest.Etc["Chaos Crab"]
			local wallCFs = v3.WallCFs
			local rootPart = v3.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 100,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://106857875094253",
				Volume = 1.25
			})
			_G.PU:Dust(sound, 5)
			sound.Parent = rootPart
			sound:Play()

			if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 500 then
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 100,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://98138557595492",
					Volume = 1.25
				})
				_G.PU:Dust(sound2, 5)
				sound2.Parent = SoundService
				sound2:Play()
			end

			local v4 = {}
			task.delay(20, function()
				table.clear(v4)
			end)
			table.insert(v4, 1)
			table.insert(v4, 2)
			table.insert(v4, 3)
			table.insert(v4, 4)
			table.insert(v4, 5)
			table.insert(v4, 6)
			table.insert(v4, 7)
			table.insert(v4, 8)
			table.insert(v4, 9)
			table.insert(v4, 10)
			table.insert(v4, 11)
			table.insert(v4, 12)
			table.insert(v4, 13)
			table.insert(v4, 14)
			table.insert(v4, 15)
			table.insert(v4, 16)

			for i = #v4, 2, -1 do
				local v5 = math.random(i)
				local v6 = v4[v5]
				local v7 = v4[i]
				v4[i] = v6
				v4[v5] = v7
			end

			local function flicker(duration, clone)
				local decal = clone.Decal
				clone.progress.CFrame = clone.CFrame
				decal.Transparency = 1
				clone.Size = Vector3.new()
				clone.progress.Size = Vector3.new()
				TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
					Size = createVector(800, 0.001, 800)
				}):Play()
				TweenService:Create(clone.progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
					Size = createVector(800, 0.001, 800)
				}):Play()
				local tween = TweenService:Create(
					decal,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 1e999, true),
					{
						Transparency = 0
					}
				)
				tween:Play()
				task.delay(duration, function()
					tween:Cancel()
					decal.Transparency = 0
					TweenService:Create(
						clone,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
					TweenService:Create(
						decal,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						clone.progress.Decal,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
			end

			local clone = chaosCrab.warning:Clone()
			clone.CFrame = rootPart.CFrame * CFrame.new(0, 0.25, 0)
			clone.Parent = effects
			_G.PU:Dust(clone, 5)
			Utility.ParticleHandler(clone, true)
			flicker(2, clone)
			local wallCFsByClone = {}
			local v5 = {}
			task.delay(20, function()
				table.clear(wallCFsByClone)
				table.clear(v5)
			end)

			for i = 1, 4 do
				local wallCF = wallCFs[i]

				if not wallCF then
					continue
				end

				local clone2 = chaosCrab.pillar:Clone()
				_G.PU:Dust(clone2, 5)
				clone2.CFrame = wallCF * CFrame.new(0, -30, 0)
				clone2.Size = createVector(20.255, 0, 15.939)
				clone2.Parent = effects
				local clone3 = chaosCrab.Wind:Clone()
				_G.PU:Dust(clone3, 5)
				clone3.CFrame = wallCF * CFrame.new(0, 0, -7) * CFrame.Angles(0, 3.141592653589793, 0)
				clone3.Parent = effects
				wallCFsByClone[clone2] = wallCF
				v5[clone3] = wallCF * CFrame.new(0, 0, -7) * CFrame.Angles(0, 3.141592653589793, 0)

				for _, beam in pairs(clone3:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Width0 = 0
					beam.Width1 = 0
				end

				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = wallCF,
					Size = createVector(20.255, 32.378, 15.939)
				}):Play()
				task.wait()
				TweenService:Create(clone2.Beam, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Width0 = 15,
					Width1 = 105
				}):Play()
				Utility.EmitParticles(clone2)
				task.spawn(function()
					wait(1)
					BoatTween:Create(clone2.Beam, {
						Time = 3,
						EasingStyle = "Quad",
						EasingDirection = "Out",
						StepType = "Heartbeat",
						Goal = {
							Color = ColorSequence.new(Color3.fromRGB(255, 132, 70))
						}
					}):Play()
				end)
				local v7 = clone2
				local cFrame = wallCF
				task.spawn(function()
					wait(4.2)
					TweenService:Create(v7, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = createVector(20.255, 0, 15.939),
						CFrame = cFrame * CFrame.new(0, -30, 0),
						Transparency = 1
					}):Play()
				end)
			end

			wait(2)

			if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 300 then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				_G.PU:Dust(colorCorrectionEffect, 4)
				colorCorrectionEffect.Parent = game.Lighting
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						TintColor = Color3.fromRGB(255, 190, 160),
						Contrast = 0.1,
						Brightness = -0.1
					}
				):Play()
				task.spawn(function()
					wait(3)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							TintColor = Color3.fromRGB(255, 255, 255),
							Brightness = 0,
							Contrast = 0
						}
					):Play()
				end)
			end

			task.spawn(function()
				for folder, _ in pairs(v5) do
					Utility.ParticleHandler(folder, true)

					for _, beam in pairs(folder:GetDescendants()) do
						if beam:IsA("Beam") then
							TweenService:Create(beam, TweenInfo.new(0.2), {
								Width0 = 9.828,
								Width1 = 29.4
							}):Play()
						end
					end
				end

				local lastTime = tick()
				PeodizService.HeartbeatWait({
					Time = 3,
					WaitTime = 0.05
				}, function(_)
					local _ = tick() - lastTime

					for k, v6 in pairs(wallCFsByClone) do
						local cframe = CFrame.new(
							math.random(-25, 25) / 10,
							math.random(0, 1),
							math.random(-25, 25) / 10
						)
						TweenService:Create(k, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							CFrame = v6 * cframe
						}):Play()
					end

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 300 then
						_G.CameraShake:ShakeOnce(2.25, 13, 0, 0.2)
					end
				end)

				for folder, _ in pairs(v5) do
					Utility.ParticleHandler(folder, false)

					for _, beam in pairs(folder:GetDescendants()) do
						if beam:IsA("Beam") then
							TweenService:Create(beam, TweenInfo.new(0.5), {
								Width0 = 0,
								Width1 = 0
							}):Play()
						end
					end
				end
			end)

			if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 500 then
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 100,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://114611651515037",
					Volume = 1.5
				})
				_G.PU:Dust(sound2, 6)
				sound2.Parent = SoundService
				sound2:Play()
			end

			local clone2 = chaosCrab.CrabPull:Clone()
			_G.PU:Dust(clone2, 4)
			clone2.Parent = effects
			clone2:SetPrimaryPartCFrame(rootPart.CFrame * CFrame.new(0, 0.15, 0))
			Utility.ParticleHandler(clone2, true)
			wait(3)
			Utility.ParticleHandler(clone2, false)
		elseif mode == "Craberno V" then
			local effects = workspace.Effects
			local chaosCrab = ReplicatedStorage.Chest.Etc["Chaos Crab"]
			local rootPart = v3.RootPart
			local clone = chaosCrab.Roar:Clone()
			_G.PU:Dust(clone, 5)
			clone.CFrame = rootPart.CFrame
			clone.Parent = effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 100,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://106857875094253",
				Volume = 1.25
			})
			_G.PU:Dust(sound, 5)
			sound.Parent = rootPart
			sound:Play()
			Utility.ParticleHandler(clone.Sphere, true)
			wait(1)
			Utility.ParticleHandler(clone.Sphere, false)
			Utility.EmitParticles(clone.Charge)
			wait()
			Utility.ParticleHandler(clone, true)
			Utility.ParticleHandler(clone.Sphere, false)

			if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 300 then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				_G.PU:Dust(colorCorrectionEffect, 5)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						TintColor = Color3.fromRGB(255, 215, 203),
						Contrast = 0.1
					}
				):Play()
				task.spawn(function()
					wait(4)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							TintColor = Color3.fromRGB(255, 255, 255),
							Brightness = 0,
							Contrast = 0
						}
					):Play()
				end)
			end

			task.delay(4, function()
				Utility.ParticleHandler(clone, false)
			end)

			local function flicker(duration, clone2)
				local decal = clone2.Decal
				clone2.progress.CFrame = clone2.CFrame
				decal.Transparency = 1
				clone2.Size = Vector3.new()
				clone2.progress.Size = Vector3.new()
				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
					Size = createVector(300, 0.001, 300)
				}):Play()
				TweenService:Create(clone2.progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
					Size = createVector(300, 0.001, 300)
				}):Play()
				local tween = TweenService:Create(
					decal,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 1e999, true),
					{
						Transparency = 0
					}
				)
				tween:Play()
				task.delay(duration, function()
					tween:Cancel()
					decal.Transparency = 0
					TweenService:Create(
						clone2,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
					TweenService:Create(
						decal,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						clone2.progress.Decal,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
			end

			local function blitz(cFrame)
				local part = Instance.new("Part")
				_G.PU:Dust(part, 2)
				part.Color = Color3.fromRGB(255, 93, 128)
				part.Material = "Neon"
				part.CanCollide = nil
				part.Anchored = true
				part.CFrame = cFrame
				part.CastShadow = false
				part.Size = createVector(50, 0.1, 500)
				part.Transparency = 0.75
				part.Parent = effects
				local part2 = Instance.new("Part")
				_G.PU:Dust(part2, 2)
				part2.Color = Color3.fromRGB(255, 93, 128)
				part2.Material = "Neon"
				part2.CanCollide = nil
				part2.Anchored = true
				part2.CFrame = part.CFrame * CFrame.new(0, 0, 250)
				part2.Size = createVector(50, 0.1, 0)
				part2.Transparency = 0
				part2.Parent = effects
				TweenService:Create(part2, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
					Size = createVector(50, 0.1, 500),
					CFrame = part.CFrame
				}):Play()
				wait(0.5)
				local clone2 = chaosCrab.blitz:Clone()
				_G.PU:Dust(clone2, 2)
				clone2.CFrame = cFrame * CFrame.new(0, 0, 250)
				clone2.Parent = effects
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 100,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://98433303530038",
					Volume = 1.5
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone2
				sound2:Play()
				Utility.EmitParticles(clone2)
				Utility.ParticleHandler(clone2, true)
				wait()
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = cFrame * CFrame.new(0, 0, -250)
				}):Play()
				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = createVector(0, 0.1, 500),
					Transparency = 1
				}):Play()
				TweenService:Create(part2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = createVector(0, 0.1, 500),
					Transparency = 1
				}):Play()
				wait(0.3)
				Utility.ParticleHandler(clone2, false)
			end

			local function meteor(p)
				local position = (p * CFrame.new(math.random(-50, 50), 150, math.random(-50, 50))).Position
				local position2 = p.Position
				local cframe = CFrame.lookAt(position, position2)
				local v4 = math.rad((math.random(0, 360)))
				local v5 = cframe * CFrame.Angles(0, 0, v4)
				local clone2 = chaosCrab.Meteor:Clone()
				_G.PU:Dust(clone2, 2)
				local main = clone2:FindFirstChild("Main")
				main.Anchored = true
				main.CanCollide = false
				clone2:PivotTo(v5)
				clone2.Parent = effects
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://133298211262165",
					Volume = 1.5
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone2.Main
				sound2:Play()
				task.spawn(function()
					clone2.Main.rock:Emit(30)
					Utility.EmitParticles(clone2.Main.EXp)
					Utility.ParticleHandler(clone2, true)
					clone2.Neon.Size = createVector(0, 25, 0)
					clone2.Main.Size = createVector(0, 25, 0)
					wait()
					TweenService:Create(
						clone2.Main,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = createVector(10, 10, 10)
						}
					):Play()
					TweenService:Create(
						clone2.Neon,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = createVector(11, 11, 11)
						}
					):Play()
				end)
				local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
				local cframe2 = CFrame.lookAt(position2, position2 + (position2 - position).Unit)
				local tween = TweenService:Create(main, tweenInfo, {
					CFrame = cframe2
				})
				TweenService:Create(clone2.Neon, tweenInfo, {
					CFrame = cframe2
				}):Play()
				tween:Play()
				local completedConnection = nil
				completedConnection = tween.Completed:Connect(function()
					Utility.EmitParticles(main)
					Utility.ParticleHandler(main, false)
					TweenService:Create(
						clone2.Neon,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = Vector3.new()
						}
					):Play()
					TweenService:Create(
						clone2.Main,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = Vector3.new()
						}
					):Play()
					local clone3 = chaosCrab.exp:Clone()
					_G.PU:Dust(clone3, 2)
					clone3.CFrame = CFrame.new(p.p) * CFrame.Angles(1.5707963267948966, 0, 0)
					clone3.Parent = effects
					Utility.EmitParticles(clone3)
					local soundId = math.random(1, 2) == 1 and "rbxassetid://104927381357449" or "rbxassetid://95316420983233"
					local sound3 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.Inverse,
						SoundId = soundId,
						Volume = 0.7
					})
					_G.PU:Dust(sound3, 3)
					sound3.Parent = clone3
					sound3:Play()
					completedConnection:Disconnect()
				end)
			end

			task.spawn(function()
				local explodeData = v3.ExplodeData

				if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 500 then
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.Inverse,
						SoundId = "rbxassetid://134934245741559",
						Volume = 1.25
					})
					_G.PU:Dust(sound2, 5)
					sound2.Parent = SoundService
					sound2:Play()
				end

				PeodizService.ForceForLoop({
					Step = 7,
					WaitTime = 0.5
				}, function(p)
					local v5 = explodeData[math.floor(p * 7)]

					if v5 then
						for i = 1, 3 do
							local cFrame = v5[i]

							if not cFrame then
								continue
							end

							if i > 2 then
								blitz(cFrame)
							else
								local v7 = cFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
									0,
									0,
									math.random(50, 150)
								)
								local cframe = CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
								local cframe2 = CFrame.new(cFrame.p)
								local cframe3 = CFrame.new(v7.p)
								local clone2 = chaosCrab.warning:Clone()
								_G.PU:Dust(clone2, 5)
								clone2.CFrame = cframe3 * cframe
								clone2.Parent = effects
								TweenService:Create(clone2, TweenInfo.new(0.55, Enum.EasingStyle.Sine), {
									CFrame = cframe2 * cframe
								}):Play()
								Utility.ParticleHandler(clone2, true)
								flicker(2, clone2)
								task.delay(1.25, function()
									meteor(cframe2 * cframe)
								end)
							end
						end
					end
				end)
			end)
			local lastTime = tick()
			local lastTime2 = tick()
			PeodizService.HeartbeatWait({
				Time = 4
			}, function(_)
				local v4 = tick() - lastTime2
				task.wait()
				local v5 = math.pow(1 - v4 / 5, 2) * 8
				clone.CFrame *= CFrame.Angles(0, math.rad(v5), 0)

				if tick() - lastTime > 0.1 then
					lastTime = tick()

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 300 then
						_G.CameraShake:ShakeOnce(2.25, 13, 0, 0.2)
					end
				end
			end)
		elseif mode == "Gas Z Hold" then
			local re = ReplicatedStorage.Chest.FruitEffect.Gas.Re
			local effects = workspace.Effects
			local character = v3.Character
			local chargeFolder = v3.ChargeFolder

			if (v3.GasType or "Land") ~= "Land" then
				return
			end

			local clone = re.Lightsaber:Clone()
			_G.PU:Dust(clone, 15)
			clone.Parent = effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12276918496",
				Volume = 2
			})
			_G.PU:Dust(sound, 15)
			sound.Parent = clone
			sound:Play()
			local weld = Instance.new("Weld")
			_G.PU:Dust(weld, 15)
			weld.Part0 = character.RightHand
			weld.Part1 = clone
			weld.Name = "LightsaberWeld"
			weld.C0 = CFrame.new(0, -0.3, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
			weld.Parent = clone
			PeodizService.HeartbeatWait({
				Time = 15
			}, function()
				if chargeFolder:IsDescendantOf(character) then
					return
				else
					return true
				end
			end)

			if sound and sound.Parent then
				TweenService:Create(sound, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(sound, 1)
			end

			if clone and clone.Parent then
				TweenService:Create(clone, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
				local part = clone:FindFirstChild("Part")

				if part and part.Parent then
					TweenService:Create(part, TweenInfo.new(0.5), {
						Transparency = 1
					}):Play()
				end

				Utility.ParticleHandler(clone, false)
				_G.PU:Dust(clone, 0.5)
			end

			if weld and weld.Parent then
				_G.PU:Dust(weld, 0.5)
			end
		elseif mode == "Gas Z" then
			local re = ReplicatedStorage.Chest.FruitEffect.Gas.Re
			local effects = workspace.Effects
			local gasType = v3.GasType or "Land"
			local rootPart = v3.RootPart
			local cFrames = v3.CFrames
			local _ = v3.Character

			if gasType == "Land" then
				PeodizService.ForceForLoop({
					Step = 3,
					WaitTime = 0.25
				}, function(p)
					local v4 = math.floor(p * 3)
					local cFrame = cFrames[v4]
					task.spawn(function()
						if localPlayer == v then
							PeoUtils.LerpCF(
								rootPart,
								TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								cFrame
							)
						end
					end)
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://87844958905735",
						Volume = 1.5
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = rootPart
					sound:Play()
					spawn(function()
						local v5 = v4 == 1 and -45 or v4 == 3 and 0 or 45
						local v6 = cFrame * CFrame.Angles(0, 0, (math.rad(v5)))
						local clone = re.Move:Clone()
						_G.PU:Dust(clone, 3)
						clone.CFrame = v6 * CFrame.Angles(0, -0.9250245035569946, 0) * CFrame.new(0, 0, -20)
						clone.Parent = effects
						local clone2 = re.SlashEmit:Clone()
						_G.PU:Dust(clone2, 1)
						clone2.CFrame = v6 * CFrame.Angles(0, 0.3141592653589793, 0) * CFrame.Angles(
							0,
							-1.0471975511965976,
							0
						) * CFrame.Angles(0, -0.7853981633974483, 0)

						if v4 > 1 then
							clone2.CFrame *= CFrame.Angles(3.141592653589793, 0, 0)
						end

						clone2.Parent = effects
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 1000,
							RollOffMinDistance = 10,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://6780412894",
							Volume = 1.5
						})
						_G.PU:Dust(sound2, 3)
						sound2.Parent = clone2
						sound2:Play()
						Utility.EmitParticles(clone2)
						local v7 = {}
						PeodizService.ForLoop({
							Step = 100,
							WaitTime = 0.0025
						}, function(p2)
							if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
								_G.CameraShake:ShakeOnce(2, 4, 0, 0.01)
							end

							local v8 = math.floor(p2 * 10)
							local v9 = v6 * CFrame.Angles(0, v8 * 3.455751918948773 / 10 - 1.5707963267948966, 0) * CFrame.new(
								0,
								0,
								v8 / 10 * -5
							)
							local _ = CFrame.new(v9.p) * (v6 - v6.p)
							TweenService:Create(
								clone,
								TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = v9 * CFrame.new(0, 0, -20)
								}
							):Play()
							v7[#v7 + 1] = (v9 * CFrame.new(0, 0, -21)).p
						end)
						task.delay(10, function()
							table.clear(v7)
						end)
						Utility.ParticleHandler(clone, false)
						_G.PU:Dust(clone, 2)
					end)
				end)
			elseif gasType == "Air" then
				local clone = re.Middle:Clone()
				_G.PU:Dust(clone, 5)
				clone.PrimaryPart.CFrame = rootPart.CFrame
				clone.Parent = effects
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://113218508217303",
					Volume = 0.75
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
				local total = 0
				local total2 = 1
				PeodizService.HeartbeatWait({
					Time = 1,
					WaitTime = 0.05
				}, function()
					clone.PrimaryPart.CFrame = rootPart.CFrame
					clone:ScaleTo(total2)
					total += 5
					total2 += 0.075
				end)
				Utility.ParticleHandler(clone, false)
				task.wait(0.5)
				local clone2 = re.Explode_Flat:Clone()
				_G.PU:Dust(clone2, 4)
				clone2.CFrame = rootPart.CFrame
				clone2.Parent = effects
				Utility.EmitParticles(clone2)
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://122893058789347",
					Volume = 0.75
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone2
				sound2:Play()

				if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
					_G.CameraShake:ShakeOnce(9, 12, 0, 0.5)
				end
			end
		elseif mode == "Gas X Hold" then
			local re = ReplicatedStorage.Chest.FruitEffect.Gas.Re
			local effects = workspace.Effects
			local chargeFolder = v3.ChargeFolder
			local character = v3.Character
			local _ = v3.GasType
			local rootPart = v3.RootPart
			local clone = re.HoldingX:Clone()
			_G.PU:Dust(clone, 15)
			clone.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3)
			clone.Parent = effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://100580940365256",
				Volume = 1.25,
				Looped = true
			})
			_G.PU:Dust(sound, 15)
			sound.Parent = clone
			sound:Play()
			PeodizService.HeartbeatWait({
				Time = 10
			}, function()
				if not chargeFolder:IsDescendantOf(character) then
					return true
				end

				if clone and clone.Parent then
					clone.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3)
				end
			end)
			Utility.ParticleHandler(clone, false)
			_G.PU:Dust(clone, 2)

			if sound and sound.Parent then
				TweenService:Create(sound, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(sound, 1)
			end
		elseif mode == "Gas X" then
			local re = ReplicatedStorage.Chest.FruitEffect.Gas.Re
			local effects = workspace.Effects
			local gasType = v3.GasType or "Land"
			local rootPart = v3.RootPart
			local startCF = v3.StartCF
			local cFMouse = v3.CFMouse
			local cFMouse2 = v3.CFMouse2
			local cFMouse3 = v3.CFMouse3
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://90293481047533",
				Volume = 0.75
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local v4 = nil

			local function doExp(p)
				local startCF2 = p.StartCF
				local endCF = p.EndCF
				task.spawn(function()
					local DISTANCE_THRESHOLD = 200
					local magnitude = (startCF.Position - endCF.Position).Magnitude
					local clone = re.Still:Clone()
					_G.PU:Dust(clone, 4)
					clone.CFrame = startCF2
					clone.Parent = effects
					local clone2 = re.Rotate:Clone()
					_G.PU:Dust(clone2, 4)
					clone2.CFrame = startCF2
					clone2.Parent = effects
					local tween = TweenService:Create(
						clone2,
						TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
						{
							CFrame = clone2.CFrame * CFrame.new(0, 0, -1.5707963267948966)
						}
					)
					tween:Play()
					tween:Destroy()
					local clone3 = re.Explode:Clone()
					_G.PU:Dust(clone3, 4)
					clone3.CFrame = endCF
					clone3.Parent = effects

					if not v4 then
						v4 = true
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.Inverse,
							SoundId = "rbxassetid://89351795297195",
							Volume = 1.5
						})
						_G.PU:Dust(sound2, 3)
						sound2.Parent = clone3
						sound2:Play()
					end

					Utility.ParticleHandler(clone, false, 0)
					Utility.ParticleHandler(clone2, false, 0)
					Utility.ParticleHandler(clone, true, 4)
					Utility.ParticleHandler(clone2, true, 3)

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(4, 8, 0, 0.3, createVector(0, 0, -5))
					end

					for i = 0, 8 do
						local clone4 = re.Shoot:Clone()
						_G.PU:Dust(clone4, 2)
						clone4.CFrame = startCF2 * CFrame.new(0, 0, -i * (magnitude / 10))
						clone4.Parent = effects
						Utility.EmitParticles(clone4)
					end

					task.wait(0.2)
					Utility.ParticleHandler(clone, false, 0)
					Utility.ParticleHandler(clone2, false, 0)

					if (localPlayer.Character.HumanoidRootPart.Position - endCF.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(8, 12, 0, 0.5)
					end

					clone3.Start:Destroy()
					Utility.EmitParticles(clone3)

					if (localPlayer.Character.HumanoidRootPart.Position - endCF.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(4, 6, 0, 0.3)
					end
				end)
			end

			if gasType == "Land" then
				local v5 = {
					StartCF = startCF,
					EndCF = cFMouse
				}
				local startCF2 = v5.StartCF
				local endCF = v5.EndCF
				task.spawn(function()
					local DISTANCE_THRESHOLD = 200
					local magnitude = (startCF.Position - endCF.Position).Magnitude
					local clone = re.Still:Clone()
					_G.PU:Dust(clone, 4)
					clone.CFrame = startCF2
					clone.Parent = effects
					local clone2 = re.Rotate:Clone()
					_G.PU:Dust(clone2, 4)
					clone2.CFrame = startCF2
					clone2.Parent = effects
					local tween = TweenService:Create(
						clone2,
						TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
						{
							CFrame = clone2.CFrame * CFrame.new(0, 0, -1.5707963267948966)
						}
					)
					tween:Play()
					tween:Destroy()
					local clone3 = re.Explode:Clone()
					_G.PU:Dust(clone3, 4)
					clone3.CFrame = endCF
					clone3.Parent = effects

					if not v4 then
						v4 = true
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.Inverse,
							SoundId = "rbxassetid://89351795297195",
							Volume = 1.5
						})
						_G.PU:Dust(sound2, 3)
						sound2.Parent = clone3
						sound2:Play()
					end

					Utility.ParticleHandler(clone, false, 0)
					Utility.ParticleHandler(clone2, false, 0)
					Utility.ParticleHandler(clone, true, 4)
					Utility.ParticleHandler(clone2, true, 3)

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(4, 8, 0, 0.3, createVector(0, 0, -5))
					end

					for i = 0, 8 do
						local clone4 = re.Shoot:Clone()
						_G.PU:Dust(clone4, 2)
						clone4.CFrame = startCF2 * CFrame.new(0, 0, -i * (magnitude / 10))
						clone4.Parent = effects
						Utility.EmitParticles(clone4)
					end

					task.wait(0.2)
					Utility.ParticleHandler(clone, false, 0)
					Utility.ParticleHandler(clone2, false, 0)

					if (localPlayer.Character.HumanoidRootPart.Position - endCF.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(8, 12, 0, 0.5)
					end

					clone3.Start:Destroy()
					Utility.EmitParticles(clone3)

					if (localPlayer.Character.HumanoidRootPart.Position - endCF.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(4, 6, 0, 0.3)
					end
				end)
			end

			if gasType == "Air" then
				local v5 = {
					StartCF = startCF,
					EndCF = cFMouse
				}
				local startCF2 = v5.StartCF
				local endCF = v5.EndCF
				task.spawn(function()
					local DISTANCE_THRESHOLD = 200
					local magnitude = (startCF.Position - endCF.Position).Magnitude
					local clone = re.Still:Clone()
					_G.PU:Dust(clone, 4)
					clone.CFrame = startCF2
					clone.Parent = effects
					local clone2 = re.Rotate:Clone()
					_G.PU:Dust(clone2, 4)
					clone2.CFrame = startCF2
					clone2.Parent = effects
					local tween = TweenService:Create(
						clone2,
						TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
						{
							CFrame = clone2.CFrame * CFrame.new(0, 0, -1.5707963267948966)
						}
					)
					tween:Play()
					tween:Destroy()
					local clone3 = re.Explode:Clone()
					_G.PU:Dust(clone3, 4)
					clone3.CFrame = endCF
					clone3.Parent = effects

					if not v4 then
						v4 = true
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.Inverse,
							SoundId = "rbxassetid://89351795297195",
							Volume = 1.5
						})
						_G.PU:Dust(sound2, 3)
						sound2.Parent = clone3
						sound2:Play()
					end

					Utility.ParticleHandler(clone, false, 0)
					Utility.ParticleHandler(clone2, false, 0)
					Utility.ParticleHandler(clone, true, 4)
					Utility.ParticleHandler(clone2, true, 3)

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(4, 8, 0, 0.3, createVector(0, 0, -5))
					end

					for i = 0, 8 do
						local clone4 = re.Shoot:Clone()
						_G.PU:Dust(clone4, 2)
						clone4.CFrame = startCF2 * CFrame.new(0, 0, -i * (magnitude / 10))
						clone4.Parent = effects
						Utility.EmitParticles(clone4)
					end

					task.wait(0.2)
					Utility.ParticleHandler(clone, false, 0)
					Utility.ParticleHandler(clone2, false, 0)

					if (localPlayer.Character.HumanoidRootPart.Position - endCF.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(8, 12, 0, 0.5)
					end

					clone3.Start:Destroy()
					Utility.EmitParticles(clone3)

					if (localPlayer.Character.HumanoidRootPart.Position - endCF.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(4, 6, 0, 0.3)
					end
				end)
				local v6 = {
					StartCF = startCF * CFrame.Angles(0, -0.5235987755982988, 0),
					EndCF = cFMouse2
				}
				local startCF3 = v6.StartCF
				local endCF2 = v6.EndCF
				task.spawn(function()
					local DISTANCE_THRESHOLD = 200
					local magnitude = (startCF.Position - endCF2.Position).Magnitude
					local clone = re.Still:Clone()
					_G.PU:Dust(clone, 4)
					clone.CFrame = startCF3
					clone.Parent = effects
					local clone2 = re.Rotate:Clone()
					_G.PU:Dust(clone2, 4)
					clone2.CFrame = startCF3
					clone2.Parent = effects
					local tween = TweenService:Create(
						clone2,
						TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
						{
							CFrame = clone2.CFrame * CFrame.new(0, 0, -1.5707963267948966)
						}
					)
					tween:Play()
					tween:Destroy()
					local clone3 = re.Explode:Clone()
					_G.PU:Dust(clone3, 4)
					clone3.CFrame = endCF2
					clone3.Parent = effects

					if not v4 then
						v4 = true
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.Inverse,
							SoundId = "rbxassetid://89351795297195",
							Volume = 1.5
						})
						_G.PU:Dust(sound2, 3)
						sound2.Parent = clone3
						sound2:Play()
					end

					Utility.ParticleHandler(clone, false, 0)
					Utility.ParticleHandler(clone2, false, 0)
					Utility.ParticleHandler(clone, true, 4)
					Utility.ParticleHandler(clone2, true, 3)

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(4, 8, 0, 0.3, createVector(0, 0, -5))
					end

					for i = 0, 8 do
						local clone4 = re.Shoot:Clone()
						_G.PU:Dust(clone4, 2)
						clone4.CFrame = startCF3 * CFrame.new(0, 0, -i * (magnitude / 10))
						clone4.Parent = effects
						Utility.EmitParticles(clone4)
					end

					task.wait(0.2)
					Utility.ParticleHandler(clone, false, 0)
					Utility.ParticleHandler(clone2, false, 0)

					if (localPlayer.Character.HumanoidRootPart.Position - endCF2.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(8, 12, 0, 0.5)
					end

					clone3.Start:Destroy()
					Utility.EmitParticles(clone3)

					if (localPlayer.Character.HumanoidRootPart.Position - endCF2.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(4, 6, 0, 0.3)
					end
				end)
				local v7 = {
					StartCF = startCF * CFrame.Angles(0, 0.5235987755982988, 0),
					EndCF = cFMouse3
				}
				local startCF4 = v7.StartCF
				local endCF3 = v7.EndCF
				task.spawn(function()
					local DISTANCE_THRESHOLD = 200
					local magnitude = (startCF.Position - endCF3.Position).Magnitude
					local clone = re.Still:Clone()
					_G.PU:Dust(clone, 4)
					clone.CFrame = startCF4
					clone.Parent = effects
					local clone2 = re.Rotate:Clone()
					_G.PU:Dust(clone2, 4)
					clone2.CFrame = startCF4
					clone2.Parent = effects
					local tween = TweenService:Create(
						clone2,
						TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
						{
							CFrame = clone2.CFrame * CFrame.new(0, 0, -1.5707963267948966)
						}
					)
					tween:Play()
					tween:Destroy()
					local clone3 = re.Explode:Clone()
					_G.PU:Dust(clone3, 4)
					clone3.CFrame = endCF3
					clone3.Parent = effects

					if not v4 then
						v4 = true
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.Inverse,
							SoundId = "rbxassetid://89351795297195",
							Volume = 1.5
						})
						_G.PU:Dust(sound2, 3)
						sound2.Parent = clone3
						sound2:Play()
					end

					Utility.ParticleHandler(clone, false, 0)
					Utility.ParticleHandler(clone2, false, 0)
					Utility.ParticleHandler(clone, true, 4)
					Utility.ParticleHandler(clone2, true, 3)

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(4, 8, 0, 0.3, createVector(0, 0, -5))
					end

					for i = 0, 8 do
						local clone4 = re.Shoot:Clone()
						_G.PU:Dust(clone4, 2)
						clone4.CFrame = startCF4 * CFrame.new(0, 0, -i * (magnitude / 10))
						clone4.Parent = effects
						Utility.EmitParticles(clone4)
					end

					task.wait(0.2)
					Utility.ParticleHandler(clone, false, 0)
					Utility.ParticleHandler(clone2, false, 0)

					if (localPlayer.Character.HumanoidRootPart.Position - endCF3.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(8, 12, 0, 0.5)
					end

					clone3.Start:Destroy()
					Utility.EmitParticles(clone3)

					if (localPlayer.Character.HumanoidRootPart.Position - endCF3.Position).Magnitude < DISTANCE_THRESHOLD then
						_G.CameraShake:ShakeOnce(4, 6, 0, 0.3)
					end
				end)
			end
		elseif mode == "Gas C Hold" then
			local re = ReplicatedStorage.Chest.FruitEffect.Gas.Re
			local effects = workspace.Effects
			local chargeFolder = v3.ChargeFolder
			local character = v3.Character
			local humanoidType = v3.HumanoidType or "Floor"
			local _ = v3.GasType
			local rootPart = v3.RootPart
			local cframe = CFrame.new(0, 4.5, 0)

			if humanoidType == "Float" then
				cframe = CFrame.new(0, 0, -3)
			end

			local clone = re.Hold:Clone()
			_G.PU:Dust(clone, 15)
			clone.CFrame = rootPart.CFrame * cframe
			clone.Parent = effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://87607086972972",
				Volume = 1.25,
				Looped = true
			})
			_G.PU:Dust(sound, 15)
			sound.Parent = clone
			sound:Play()
			PeodizService.HeartbeatWait({
				Time = 10
			}, function()
				if not chargeFolder:IsDescendantOf(character) then
					return true
				end

				if clone and clone.Parent then
					if humanoidType == "Float" then
						clone.CFrame = rootPart.CFrame * cframe
					elseif humanoidType == "Floor" then
						clone.CFrame = CFrame.new(rootPart.Position) * cframe
					end
				end
			end)
			Utility.ParticleHandler(clone, false)
			_G.PU:Dust(clone, 2)

			if sound and sound.Parent then
				TweenService:Create(sound, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(sound, 1)
			end
		elseif mode == "Gas C" then
			local re = ReplicatedStorage.Chest.FruitEffect.Gas.Re
			local effects = workspace.Effects
			local startCF = v3.StartCF
			local humanoidType = v3.HumanoidType or "Floor"
			local gasType = v3.GasType or "Land"
			local rootPart = v3.RootPart
			local tableCF = v3.TableCF
			local v4 = nil

			local function Explosion(p)
				local startCF2 = p.StartCF
				task.spawn(function()
					if not v4 then
						v4 = true
						local sound = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.Inverse,
							SoundId = "rbxassetid://101455888795308",
							Volume = 1
						})
						_G.PU:Dust(sound, 3)
						sound.Parent = rootPart
						sound:Play()
					end

					PeodizService.ForceForLoop({
						Step = 4,
						WaitTime = 0.05
					}, function(p2)
						local v5 = math.floor(p2 * 4)
						local clone = re.Explode:Clone()
						_G.PU:Dust(clone, 4)
						clone.CFrame = startCF2 * CFrame.new(0, 0, -v5 * 50 + 25)
						clone.Parent = effects
						Utility.EmitParticles(clone)

						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
							_G.CameraShake:ShakeOnce(4, 6, 0, 0.3)
						end
					end)
				end)
			end

			local function aoeExplosion()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://77461813073546",
					Volume = 1.25
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = rootPart
				sound:Play()
				PeodizService.ForceForLoop({
					Step = 12,
					WaitTime = 0.0125
				}, function(p)
					local v5 = math.floor(p * 12)
					task.spawn(function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
							_G.CameraShake:ShakeOnce(2, 4, 0, 0.2)
						end

						local cFrame = startCF
						local v7 = tableCF[v5]
						local position = cFrame.Position
						local position2 = v7.Position
						local v8 = (position + position2) / 2 + Vector3.new(
							math.random(-75, 75),
							math.random(-37.5, 37.5),
							math.random(-75, 75)
						)
						local clone = re.Projectile:Clone()
						_G.PU:Dust(clone, 3)
						clone.CFrame = cFrame
						Utility.ParticleHandler(clone, false)
						clone.Parent = effects
						Utility.ParticleHandler(clone, true)
						PeodizService.ForLoop({
							Step = 24,
							WaitTime = 0.025
						}, function(p2)
							local v9 = math.floor(p2 * 24)
							local v10 = v9 / 24
							local v11 = (v9 + 1) / 24
							local lerped = lerp(position, v8, v10)
							local lerped2 = lerp(v8, position2, v10)
							local lerped3 = lerp(position, v8, v11)
							local lerped4 = lerp(v8, position2, v11)
							local lerped5 = lerp(lerped, lerped2, v10)
							local lerped6 = lerp(lerped3, lerped4, v11)
							clone.Position = lerped5
							clone.CFrame = CFrame.lookAt(clone.Position, lerped6)
						end)
						Utility.ParticleHandler(clone, false)
						local clone2 = re.Explode:Clone()
						_G.PU:Dust(clone2, 4)
						clone2.CFrame = clone.CFrame
						clone2.Parent = effects
						Utility.EmitParticles(clone2)

						if v5 % 4 == 1 then
							local sound2 = PeoUtils.CreateSound({
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://76410861803714",
								Volume = 1
							})
							_G.PU:Dust(sound2, 3)
							sound2.Parent = rootPart
							sound2:Play()
						end

						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
							_G.CameraShake:ShakeOnce(4, 6, 0, 0.3)
						end
					end)
				end)
			end

			if humanoidType == "Floor" then
				aoeExplosion()
			elseif humanoidType == "Float" then
				if gasType == "Land" then
					local startCF2 = ({
						StartCF = startCF
					}).StartCF
					task.spawn(function()
						if not v4 then
							v4 = true
							local sound = PeoUtils.CreateSound({
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://101455888795308",
								Volume = 1
							})
							_G.PU:Dust(sound, 3)
							sound.Parent = rootPart
							sound:Play()
						end

						PeodizService.ForceForLoop({
							Step = 4,
							WaitTime = 0.05
						}, function(p)
							local v5 = math.floor(p * 4)
							local clone = re.Explode:Clone()
							_G.PU:Dust(clone, 4)
							clone.CFrame = startCF2 * CFrame.new(0, 0, -v5 * 50 + 25)
							clone.Parent = effects
							Utility.EmitParticles(clone)

							if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
								_G.CameraShake:ShakeOnce(4, 6, 0, 0.3)
							end
						end)
					end)
				else
					for i = 1, 3 do
						local v6 = ({
							StartCF = startCF * CFrame.Angles(0, math.rad(-30 + 15 * i), 0)
						}).StartCF
						task.spawn(function()
							if not v4 then
								v4 = true
								local sound = PeoUtils.CreateSound({
									RollOffMaxDistance = 500,
									RollOffMinDistance = 50,
									RollOffMode = Enum.RollOffMode.Inverse,
									SoundId = "rbxassetid://101455888795308",
									Volume = 1
								})
								_G.PU:Dust(sound, 3)
								sound.Parent = rootPart
								sound:Play()
							end

							PeodizService.ForceForLoop({
								Step = 4,
								WaitTime = 0.05
							}, function(p)
								local v7 = math.floor(p * 4)
								local clone = re.Explode:Clone()
								_G.PU:Dust(clone, 4)
								clone.CFrame = v6 * CFrame.new(0, 0, -v7 * 50 + 25)
								clone.Parent = effects
								Utility.EmitParticles(clone)

								if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
									_G.CameraShake:ShakeOnce(4, 6, 0, 0.3)
								end
							end)
						end)
					end
				end
			end
		elseif mode == "Gas V" then
			local re = ReplicatedStorage.Chest.FruitEffect.Gas.Re
			local effects = workspace.Effects
			local stats_Type = v3.Stats_Type
			local rootPart = v3.RootPart
			local v4 = math.clamp(math.clamp(stats_Type, 0, 10000), 0, 5000) / 5000 * 0.5 + 0.5
			local clone = re.GasDomain:Clone()
			_G.PU:Dust(clone, 10)
			clone:PivotTo(rootPart.CFrame * CFrame.new(0, -2.8, 0))
			clone:ScaleTo(v4)
			clone.Parent = effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://107917053633078",
				Volume = 2
			})
			_G.PU:Dust(sound, 10)
			sound.Parent = rootPart
			sound:Play()
			local colorCorrectionEffect

			if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
				local colorCorrectionEffect2 = Instance.new("ColorCorrectionEffect")
				_G.PU:Dust(colorCorrectionEffect2, 1)
				colorCorrectionEffect2.Parent = game.Lighting
				local tween = TweenService:Create(
					colorCorrectionEffect2,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
					{
						Contrast = 0.5,
						Saturation = -0.5,
						TintColor = Color3.fromRGB(121, 44, 255)
					}
				)
				tween:Play()
				tween:Destroy()
				colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				_G.PU:Dust(colorCorrectionEffect, 6)
				colorCorrectionEffect.Parent = game.Lighting
				local tween2 = TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Contrast = 0.1,
						Saturation = -0.1,
						TintColor = Color3.fromRGB(170, 144, 255)
					}
				)
				tween2:Play()
				tween2:Destroy()
			end

			PeodizService.HeartbeatWait({
				Time = 3,
				WaitTime = 0.05
			}, function()
				if not rootPart or rootPart and not rootPart.Parent then
					return true
				end

				clone:PivotTo(rootPart.CFrame * CFrame.new(0, -2.8, 0))
			end)

			if sound and sound.Parent then
				TweenService:Create(sound, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(sound, 1)
			end

			if clone and clone.Parent then
				Utility.ParticleHandler(clone, false, 0)
			end

			if colorCorrectionEffect and colorCorrectionEffect.Parent then
				local tween = TweenService:Create(colorCorrectionEffect, TweenInfo.new(1), {
					Contrast = 0,
					Saturation = 0,
					TintColor = Color3.new(1, 1, 1)
				})
				tween:Play()
				tween:Destroy()
			end
		end
	end
end