local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local localPlayer = game.Players.LocalPlayer
return function(list)
	local DISTANCE_THRESHOLD = 150
	local _, cFrame, v2, _ = unpack(list)
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

		if mode == "Leader Z" then
			local rootPart = v2.RootPart

			if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < DISTANCE_THRESHOLD then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9597812848",
				Volume = 1
			})
			_G.PU:Dust(sound, 1)
			sound.Parent = rootPart
			sound:Play()

			for i = 1, 2 do
				local cFrame2 = cFrame * CFrame.Angles(0, 0, -0.7853981633974483)

				if i == 2 then
					cFrame2 = cFrame * CFrame.Angles(0, 0, 0.7853981633974483)
				end

				local clone = ReplicatedStorage.Chest.Etc.BallMan.SlashMesh:Clone()
				clone.Color = Color3.fromRGB(0, 0, 0)
				clone.Size = createVector(0.51, 78.049995, 46.11)
				clone.CFrame = cFrame2
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 0.5)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					CFrame = clone.CFrame * CFrame.new(0, 0, -175)
				}):Play()
				spawn(function()
					wait(0.1)
					TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
						Transparency = 1
					}):Play()
				end)
			end

			local clone = ReplicatedStorage.Chest.Etc.DragonClaw.Sphere:Clone()
			clone.Color = Color3.fromRGB(85, 0, 255)
			clone.CFrame = cFrame * CFrame.new(0, 0, -5)
			clone.Size = createVector(24, 24, 15)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1)
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 175),
				CFrame = cFrame * CFrame.new(0, 0, -85)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local clone2 = ReplicatedStorage.Chest.Etc.DragonClaw.WindRing:Clone()
			clone2.Color = Color3.fromRGB(255, 255, 255)
			clone2.CFrame = cFrame * CFrame.new(0, 0, -10) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Size = createVector(35.588, 2.632, 35.588)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(84.664, 6.26, 84.664),
				CFrame = cFrame * CFrame.new(0, 0, 1) * CFrame.Angles(1.5707963267948966, 0, 0)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			PeodizService.ForLoop({
				Step = 10
			}, function(p)
				local v3 = math.floor(p * 10)
				local v4 = math.random(300, 500) / 15
				local clone3 = ReplicatedStorage.Chest.Etc.BallMan.Slash:Clone()
				clone3.Decal1.Color3 = math.random(1, 2) == 1 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(
					170,
					0,
					2555
				)
				clone3.Mesh.Scale = Vector3.new()
				clone3.CFrame = cFrame * CFrame.new(0, 0, -v3 * 15) * CFrame.Angles(
					1.5707963267948966,
					6.283185307179586 * math.random(),
					0
				)
				clone3.Attachment.Specs.LockedToPart = false
				clone3.Attachment.Specs.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.5, 4.800000000000001, 1.956),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone3.Attachment.Specs.Speed = NumberRange.new(30, 90)
				clone3.Attachment.Specs.Color = ColorSequence.new(Color3.fromRGB(85, 0, 255))
				clone3.Parent = workspace.Effects
				_G.PU:Dust(clone3, 1.1)
				clone3.Attachment.Specs:Emit(5)
				spawn(function()
					local v5 = math.random(-40, 40)

					repeat
						wait()
						TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
							CFrame = clone3.CFrame * CFrame.Angles(0, math.rad(v5), 0)
						}):Play()
					until not clone3:IsDescendantOf(workspace.Effects)
				end)
				TweenService:Create(clone3.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Scale = Vector3.new(v4, v4 / math.random(5, 20), v4)
				}):Play()
				TweenService:Create(clone3.Decal1, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
			end)
		elseif mode == "Pasta Z" then
			local startCF = v2.StartCF
			local rootPart = v2.RootPart

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < DISTANCE_THRESHOLD then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://142691026",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.Etc.DragonClaw.WindRing:Clone()
			clone.Color = Color3.fromRGB(255, 255, 255)
			clone.CFrame = startCF * CFrame.new(0, 0, -10) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Size = createVector(35.588, 2.632, 35.588)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1)
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(84.664, 6.26, 84.664),
				CFrame = startCF * CFrame.new(0, 0, 1) * CFrame.Angles(1.5707963267948966, 0, 0)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone2.CastShadow = false
			clone2.Transparency = -1
			clone2.Size = createVector(2, 2, 2)
			clone2.Color = Color3.fromRGB(255, 255, 0)
			clone2.CFrame = startCF
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Transparency = 1,
				CFrame = cFrame
			}):Play()
			_G.PU:Dust(clone2, 0.25)
			spawn(function()
				local v3 = (rootPart.Position - cFrame.p).Magnitude / 3

				for i = 1, 3 do
					local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
					clone3.CFrame = startCF * CFrame.new(0, 0, -v3 * (i / 1.25)) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					)
					clone3.Parent = workspace.Effects
					TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
						Size = createVector(25, 2, 25),
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone3, 0.25)
				end
			end)
			wait(0.1)

			if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < DISTANCE_THRESHOLD then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			local clone3 = ReplicatedStorage.Chest.Etc.PartSound:Clone()
			clone3.CFrame = cFrame
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 5)
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://165970126",
				Volume = 1
			})
			_G.PU:Dust(sound2, 5)
			sound2.Parent = clone3
			sound2:Play()
			local part = Instance.new("Part")
			part.Shape = Enum.PartType.Ball
			part.Transparency = -1
			part.Anchored = true
			part.CanCollide = false
			part.Size = Vector3.new()
			part.Material = Enum.Material.ForceField
			part.Color = Color3.fromRGB(255, 255, 0)
			part.CastShadow = false
			part.CFrame = cFrame
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 1)
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(75, 75, 75),
				Transparency = 1
			}):Play()
			local pointLight = Instance.new("PointLight")
			pointLight.Brightness = 2.5
			pointLight.Color = Color3.fromRGB(255, 255, 0)
			pointLight.Range = 8
			pointLight.Parent = part
			_G.PU:Dust(pointLight, 1)
			TweenService:Create(
				pointLight,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Brightness = 0
				}
			):Play()
			TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Range = 50
			}):Play()
			spawn(function()
				for i = 1, 3 do
					local v4 = i
					local cFrame2 = cFrame * CFrame.new(math.random(-0, 0), math.random(-0, 0), math.random(-0, 0))
					spawn(function()
						local clone4 = ReplicatedStorage.Chest.FruitEffect.Bomb.M:Clone()
						clone4.Color = Color3.fromRGB(255, 255, 0)

						if v4 == 3 then
							clone4.Color = Color3.fromRGB(255, 255, 127)
						elseif v4 == 2 then
							clone4.Color = Color3.fromRGB(255, 255, 127)
						end

						clone4.CFrame = cFrame2
						clone4.Parent = workspace.Effects
						_G.PU:Dust(clone4, 2)
						TweenService:Create(
							clone4,
							TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{
								Size = createVector(50, 50, 50)
							}
						):Play()
						TweenService:Create(clone4, TweenInfo.new(2, Enum.EasingStyle.Quad), {
							CFrame = clone4.CFrame * CFrame.Angles(
								3.141592653589793 * math.random(),
								3.141592653589793 * math.random(),
								3.141592653589793 * math.random()
							)
						}):Play()
						wait(0.25)
						TweenService:Create(
							clone4,
							TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
							{
								Size = Vector3.new()
							}
						)
						TweenService:Create(
							clone4,
							TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
							{
								Size = Vector3.new()
							}
						):Play()
					end)
				end
			end)
			spawn(function()
				local v3 = cFrame.p + createVector(0, 5, 0)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(v3, createVector(0, -15, 0), raycastParams)

				if raycastResult then
					local position = raycastResult.Position
					local clone4 = ReplicatedStorage.Chest.Etc.PartPar:Clone()
					clone4.Attachment.Smoke.Color = ColorSequence.new(Color3.fromRGB(159, 159, 159))
					clone4.CFrame = CFrame.new(position + raycastResult.Normal, position) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone4.Parent = workspace.Effects
					_G.PU:Dust(clone4, 5)

					for _ = 1, 3 do
						clone4.Attachment.Smoke:Emit(10)
						wait()
					end
				else
					local clone4 = ReplicatedStorage.Chest.Etc.PartPar:Clone()
					clone4.Attachment.Smoke.Color = ColorSequence.new(Color3.fromRGB(159, 159, 159))
					clone4.CFrame = CFrame.new(cFrame.p)
					clone4.Parent = workspace.Effects
					_G.PU:Dust(clone4, 5)

					for _ = 1, 3 do
						clone4.Attachment.Smoke:Emit(10)
						wait()
					end
				end
			end)
		elseif mode == "New World Pirate" then
			if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < DISTANCE_THRESHOLD then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			local rootPart = v2.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9597812848",
				Volume = 1
			})
			_G.PU:Dust(sound, 1)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.Etc.BallMan.slash2:Clone()
			clone.Mesh.Scale = createVector(30, 0.001, 20.391)
			clone.Mesh.Offset = createVector(0, 0, 18.5)
			clone.Attachment.rock.Enabled = true
			clone.Bottom.Transparency = -7
			clone.PointLight.Range = 0
			clone.PointLight.Brightness = 0
			clone.CFrame = cFrame * CFrame.Angles(0, 0, 1.5707963267948966)
			clone.Parent = workspace.Effects
			TweenService:Create(
				clone.PointLight,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Range = 20,
					Brightness = 1
				}
			):Play()
			_G.PU:Dust(clone, 3)
			TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone.CFrame * CFrame.new(0, 0, -150)
			}):Play()
			local v3 = {}
			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 1,
					Tween = {
						EasingStyle = Enum.EasingStyle.Exponential,
						EasingDirection = Enum.EasingDirection.Out
					}
				}, function(p)
					local v4 = math.floor(p * 10)

					if v3[math.floor(v4)] or math.floor(v4) == 10 then
						return
					end

					v3[math.floor(v4)] = true
					clone.Attachment.Specs:Emit(math.random(3, 5))
					clone.Attachment.shard:Emit(2)
				end)
				task.delay(10, function()
					table.clear(v3)
				end)
			end)
			spawn(function()
				wait(0.25)
				spawn(function()
					wait(0.065)
					clone.Attachment.rock.Enabled = false
				end)
				spawn(function()
					wait(0.1)
					local Animate = require(clone.Animate)
					Animate()
				end)
				TweenService:Create(
					clone.Bottom,
					TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
				wait(0.125)
				TweenService:Create(
					clone.PointLight,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Brightness = 0,
						Range = 20
					}
				):Play()
				wait(0.2)
				task.spawn(function()
					PeodizService.HeartbeatWait({
						Time = 0.5,
						Tween = {
							EasingStyle = Enum.EasingStyle.Exponential,
							EasingDirection = Enum.EasingDirection.Out
						}
					}, function(p)
						local v4 = math.floor(p * 1)
						clone.Trail.Transparency = NumberSequence.new(v4)
					end)
				end)
			end)
		end
	end
end