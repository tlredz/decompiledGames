local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local localPlayer = game.Players.LocalPlayer
return function(list)
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

		if mode == "Wolf Z" then
			if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < 150 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			local rootPart = v2.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9597812848",
				Volume = 2
			})
			_G.PU:Dust(sound, 1)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.Etc.BallMan.slash:Clone()
			clone.CFrame = cFrame * CFrame.Angles(0, 0, 1.5707963267948966)
			clone.Parent = workspace.Effects
			clone.Mesh.Scale = createVector(30, 0.001, 20.391)
			clone.Mesh.Offset = createVector(0, 0, 18.5)
			clone.Attachment.rock.Enabled = true
			clone.Bottom.Transparency = -7
			clone.PointLight.Range = 0
			clone.PointLight.Brightness = 0
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
						EasingStyle = Enum.EasingStyle.Quad,
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
		elseif mode == "Giraffe Z" then
			if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < 150 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Explosion)
			end

			local rootPart = v2.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9585647437",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 1)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.Etc.BallMan.ParticlePart:Clone()
			clone.Attachment.Ring.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.159, 27.75),
				NumberSequenceKeypoint.new(1, 39.449999999999996, 0)
			})
			clone.Attachment.Spark.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.165, 19.650000000000002, 3.585),
				NumberSequenceKeypoint.new(0.483, 6.72, 3.585),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Attachment.Spark.Speed = NumberRange.new(187.5, 225)
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			clone.Attachment.Ring:Emit(1)
			clone.Attachment.Spark:Emit(30)
			_G.PU:Dust(clone, 1)
			local cframe = CFrame.new(rootPart.Position + createVector(0, 70, 0), rootPart.Position)
			local position = rootPart.Position
			math.floor(((rootPart.Position + createVector(0, 70, 0) - rootPart.Position).magnitude + 0.5) / 2)
			local v3 = (cframe.p - position).magnitude / 6
			local total = 0

			for _ = 1, 6 do
				local clone2 = ReplicatedStorage.Chest.FruitEffect.BossEf.Ring:Clone()
				clone2.Parent = workspace.Effects
				clone2.Material = "Neon"
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.Size = createVector(24.183, 1.49, 22.863) + Vector3.new(total, 0.5, total)
				clone2.CFrame = cframe * CFrame.new(0, 0, -total) * CFrame.Angles(1.5707963267948966, 0, 0)
				total += v3
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = Vector3.new(),
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone2, 0.3)
			end

			for i = 1, 20 do
				local cframe2 = CFrame.new(cFrame.p) * CFrame.Angles(0, 6.283185307179586 * i / 20, 0) * CFrame.new(
					0,
					0,
					-25
				)
				local p = cframe2.p
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local _, v4, _ = cframe2:ToOrientation()
				local raycastResult = workspace:Raycast(p, createVector(0, -30, 0), raycastParams)

				if raycastResult then
					local part = Instance.new("Part")
					part.Anchored = true
					part.CanCollide = false
					part.CFrame = CFrame.new(cFrame.p) * CFrame.fromOrientation(0, v4, 0)
					part.Size = Vector3.new()
					part.Material = raycastResult.Material or "SmoothPlastic"
					part.Color = raycastResult.Instance.Color
					part.Parent = workspace.Effects
					TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {
						CFrame = CFrame.new(raycastResult.Position) * CFrame.fromOrientation(0, v4, 0) * CFrame.new(
							0,
							math.random(-20, 20) / 10,
							0
						) * CFrame.Angles(math.rad((math.random(30, 60))), 0, 0),
						Size = createVector(8.75, 3.5, 3.5)
					}):Play()
					spawn(function()
						wait(2)
						TweenService:Create(part, TweenInfo.new(0.5), {
							Transparency = 1
						}):Play()
					end)
					_G.PU:Dust(part, 3)
					local v6 = part
					spawn(function()
						local lastTime = tick()
						local v7 = math.random(10, 30) / 100

						repeat
							wait()
							local cframe3 = CFrame.Angles(
								math.rad(math.random(-45, 45) / 10),
								math.rad(math.random(-45, 45) / 10),
								(math.rad(math.random(-45, 45) / 10))
							)
							v6.CFrame *= cframe3
						until v7 < tick() - lastTime
					end)
				end

				Ray.new(cframe2.p, createVector(0, -30, 0))
			end

			spawn(function()
				local p = cFrame.p
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(p, createVector(0, -30, 0), raycastParams)

				if raycastResult then
					local position2 = raycastResult.Position
					local clone2 = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
					clone2.Decal.Transparency = -0.2
					clone2.Decal.Texture = "rbxassetid://7068839334"
					clone2.CFrame = CFrame.new(position2 + raycastResult.Normal, position2) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(0, -1, 0)
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, 3)
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://262562442",
						Volume = 4
					})
					_G.PU:Dust(sound2, 3)
					sound2.Parent = clone2
					sound2:Play()
					TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), {
						Size = createVector(45, 0, 45)
					}):Play()
					spawn(function()
						wait(2)
						TweenService:Create(clone2.Decal, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end)
				end
			end)
			spawn(function()
				local clone2 = ReplicatedStorage.Chest.SwordEffect.AxeHand.ParticleAxe:Clone()
				clone2.Size = createVector(25, 0, 25)
				clone2.Attachment.Circle.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 60)
				})
				clone2.Sm.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.1, 20, 12),
					NumberSequenceKeypoint.new(0.9, 20, 12),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone2.Sm.Speed = NumberRange.new(40, 100)
				clone2.CFrame = cFrame
				clone2.Parent = workspace.Effects
				clone2.Attachment.Circle:Emit(1)
				clone2.Sm:Emit(10)
				_G.PU:Dust(clone2, 5)
			end)
		elseif mode == "Giraffe X" then
			local cframe = CFrame.new(cFrame.p)
			local clone = ReplicatedStorage.Chest.SwordEffect.TashiBlade.Ex:Clone()
			clone.CFrame = cframe
			local attachment = clone.Attachment
			attachment.Burst.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 17.5, 9.05)
			})
			attachment.Burst.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
			attachment.Burst2.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 17, 8.8)
			})
			attachment.Burst2.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
			attachment.Lines.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 4.375, 4.375),
				NumberSequenceKeypoint.new(1, 0)
			})
			attachment.Lines.Speed = NumberRange.new(50, 100)
			attachment.Lines.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
			attachment.Ring.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 22.799999999999997, 7.800000000000001)
			})
			attachment.Ring.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
			clone.Parent = workspace.Effects
			attachment.Burst:Emit(5)
			attachment.Burst2:Emit(3)
			attachment.Lines:Emit(30)
			attachment.Ring:Emit(2)
			_G.PU:Dust(clone, 1.25)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9547580894",
				Volume = 2
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
		elseif mode == "Leo Z" then
			local rootPart = v2.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://7425421402",
				Volume = 1
			})
			_G.PU:Dust(sound, 1)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.Etc.MeshStorage.Thing:Clone()
			clone.CastShadow = false
			clone.Size = Vector3.new()
			clone.Color = Color3.fromRGB(255, 102, 204)
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 0.55)
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
				Size = createVector(5, 5, 100),
				CFrame = cFrame * CFrame.new(0, 0, -50)
			}):Play()
			spawn(function()
				wait(0.15)
				TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Linear), {
					Size = createVector(0, 0, 100)
				}):Play()
			end)
			PeodizService.ForLoop({
				Step = 8
			}, function(p)
				local v3 = math.floor(p * 8)
				local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
				clone2.Size = Vector3.new()
				clone2.Transparency = -1
				clone2.CFrame = cFrame * CFrame.new(0, 0, -v3 * 12.5) * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 0.3)
				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Transparency = 1,
					Size = createVector(30, 3, 30) * math.random(400, 600) / 1000
				}):Play()
			end)
		end
	end
end