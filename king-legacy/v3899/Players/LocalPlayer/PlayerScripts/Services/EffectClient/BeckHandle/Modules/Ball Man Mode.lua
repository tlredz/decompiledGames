local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
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

		if mode == "Z" then
			local part = Instance.new("Part")
			part.Material = Enum.Material.Glass
			part.Shape = "Ball"
			part.Anchored = true
			part.CastShadow = false
			part.CanCollide = false
			part.Color = Color3.fromRGB(255, 255, 255)
			part.Size = Vector3.new()
			part.CFrame = cFrame
			part.Parent = workspace.Effects
			TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
				Size = createVector(45, 45, 45)
			}):Play()
			_G.PU:Dust(part, 2)
			local clone = ReplicatedStorage.Chest.Etc.BallMan.ParticlePart:Clone()
			_G.PU:Dust(clone, 1)
			clone.Attachment.Ring.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.159, 37),
				NumberSequenceKeypoint.new(1, 52.599999999999994, 0)
			})
			clone.Attachment.Spark.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.165, 26.200000000000003, 4.779999999999999),
				NumberSequenceKeypoint.new(0.483, 8.96, 4.779999999999999),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Attachment.Spark.Speed = NumberRange.new(250, 300)
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			local v3 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://9569992804",
				Volume = 5
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 1)
			sound.Parent = clone
			sound:Play()
			clone.Attachment.Ring:Emit(1)
			clone.Attachment.Spark:Emit(30)
			spawn(function()
				wait(1)
				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Transparency = 1
				}):Play()
			end)
			spawn(function()
				wait(0.5)

				if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < 150 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.Explosion)
				end

				local clone2 = ReplicatedStorage.Chest.Etc.BallMan.ParticlePart:Clone()
				clone2.Attachment.Blast.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.223, 7.26, 7.26),
					NumberSequenceKeypoint.new(1, 20)
				})
				clone2.Attachment.Blast.Speed = NumberRange.new(350, 400)
				clone2.CFrame = cFrame
				clone2.Parent = workspace.Effects
				clone2.Attachment.Blast:Emit(15)
				_G.PU:Dust(clone2, 1)
				local clone3 = ReplicatedStorage.Chest.Etc.PartSound:Clone()
				clone3.CFrame = cFrame
				clone3.Parent = workspace.Effects
				_G.PU:Dust(clone3, 5)
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://6986308351",
					Volume = 1.5
				})
				_G.PU:Dust(sound2, 5)
				sound2.Parent = clone3
				sound2:Play()
				local part2 = Instance.new("Part")
				part2.Shape = Enum.PartType.Ball
				part2.Transparency = -1
				part2.Anchored = true
				part2.CanCollide = false
				part2.Size = createVector(50, 50, 50)
				part2.Material = Enum.Material.ForceField
				part2.Color = Color3.fromRGB(213, 115, 0)
				part2.CastShadow = false
				part2.CFrame = cFrame
				part2.Parent = workspace.Effects
				_G.PU:Dust(part2, 1)
				TweenService:Create(
					part2,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(75, 75, 75),
						Transparency = 1
					}
				):Play()
				spawn(function()
					for i = 1, 3 do
						local v5 = i
						local cFrame2 = cFrame * CFrame.new(math.random(-0, 0), math.random(-0, 0), math.random(-0, 0))
						spawn(function()
							local clone4 = ReplicatedStorage.Chest.FruitEffect.Bomb.M:Clone()
							clone4.Color = Color3.fromRGB(170, 85, 0)
							clone4.Size = createVector(40, 40, 40)

							if v5 == 3 then
								clone4.Color = Color3.fromRGB(255, 85, 0)
							elseif v5 == 2 then
								clone4.Color = Color3.fromRGB(255, 110, 0)
							end

							clone4.CFrame = cFrame2
							clone4.Parent = workspace.Effects
							_G.PU:Dust(clone4, 2)
							TweenService:Create(
								clone4,
								TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
								{
									Size = createVector(65, 65, 65)
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
									Size = Vector3.new(),
									Color = Color3.fromRGB()
								}
							):Play()
						end)
					end
				end)
				spawn(function()
					local v4 = cFrame.p + createVector(0, 5, 0)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(v4, createVector(0, -15, 0), raycastParams)

					if raycastResult then
						local position = raycastResult.Position
						local clone4 = ReplicatedStorage.Chest.Etc.PartPar:Clone()
						clone4.Attachment.Smoke.Color = ColorSequence.new(Color3.fromRGB(49, 49, 49))
						clone4.Attachment.Smoke.Speed = NumberRange.new(156.25)
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
						clone4.Attachment.Smoke.Color = ColorSequence.new(Color3.fromRGB(49, 49, 49))
						clone4.Attachment.Smoke.Speed = NumberRange.new(156.25)
						clone4.CFrame = CFrame.new(cFrame.p)
						clone4.Parent = workspace.Effects
						_G.PU:Dust(clone4, 5)

						for _ = 1, 3 do
							clone4.Attachment.Smoke:Emit(10)
							wait()
						end
					end
				end)
			end)
		elseif mode == "X" then
			for i = 1, 6 do
				local cFrame2 = v2.TableCF[i]
				local v4 = v2.TableSize[i]
				local v5 = v4 * 20
				local part = Instance.new("Part")
				part.Material = Enum.Material.Glass
				part.Shape = "Ball"
				part.Anchored = true
				part.CastShadow = false
				part.CanCollide = false
				part.Color = Color3.fromRGB(255, 255, 255)
				part.Size = Vector3.new()
				part.CFrame = cFrame2
				part.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
					Size = createVector(45, 45, 45) * v4
				}):Play()
				_G.PU:Dust(part, 2)
				local clone = ReplicatedStorage.Chest.Etc.BallMan.ParticlePart:Clone()
				clone.Attachment.Ring.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.159, 1.85 * v5),
					NumberSequenceKeypoint.new(1, 2.63 * v5, 0)
				})
				clone.Attachment.Spark.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.165, 1.31 * v5, 0.239 * v5),
					NumberSequenceKeypoint.new(0.483, 0.448 * v5, 0.239 * v5),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Attachment.Spark.Speed = NumberRange.new(25 * v5 / 2, 30 * v5 / 2)
				clone.CFrame = cFrame2
				clone.Parent = workspace.Effects
				local v6 = {
					RollOffMaxDistance = 300,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://9569992804",
					Volume = 5
				}
				local sound = PeoUtils.CreateSound(v6)
				_G.PU:Dust(sound, 1)
				sound.Parent = clone
				sound:Play()
				clone.Attachment.Ring:Emit(1)
				clone.Attachment.Spark:Emit(30)
				_G.PU:Dust(clone, 3)
				spawn(function()
					wait(1)
					TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
						Transparency = 1
					}):Play()
				end)
				spawn(function()
					wait(0.5)

					if (localPlayer.Character.HumanoidRootPart.Position - cFrame2.p).Magnitude < 150 then
						_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
					end

					local clone2 = ReplicatedStorage.Chest.Etc.BallMan.ParticlePart:Clone()
					clone2.Attachment.Blast.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.223, 3.63 * v5 / 10, 3.63 * v5 / 10),
						NumberSequenceKeypoint.new(1, 10 * v5 / 10)
					})
					clone2.Attachment.Blast.Speed = NumberRange.new(175 * v5 / 10, 200 * v5 / 10)
					clone2.CFrame = cFrame2
					clone2.Parent = workspace.Effects
					clone2.Attachment.Blast:Emit(15)
					_G.PU:Dust(clone2, 3)
					local clone3 = ReplicatedStorage.Chest.Etc.PartSound:Clone()
					clone3.CFrame = cFrame2
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 5)
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://165970126",
						Volume = 1.5
					})
					_G.PU:Dust(sound2, 5)
					sound2.Parent = clone3
					sound2:Play()
					local part2 = Instance.new("Part")
					part2.Shape = Enum.PartType.Ball
					part2.Transparency = -1
					part2.Anchored = true
					part2.CanCollide = false
					part2.Size = createVector(50, 50, 50) * v4
					part2.Material = Enum.Material.ForceField
					part2.Color = Color3.fromRGB(213, 115, 0)
					part2.CastShadow = false
					part2.CFrame = cFrame2
					part2.Parent = workspace.Effects
					_G.PU:Dust(part2, 1)
					TweenService:Create(
						part2,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(75, 75, 75) * v4,
							Transparency = 1
						}
					):Play()
					spawn(function()
						for i2 = 1, 3 do
							local v12 = i2
							local cFrame3 = cFrame2 * CFrame.new(
								math.random(-0, 0),
								math.random(-0, 0),
								math.random(-0, 0)
							)
							spawn(function()
								local clone4 = ReplicatedStorage.Chest.FruitEffect.Bomb.M:Clone()
								clone4.Color = Color3.fromRGB(170, 85, 0)
								clone4.Size = createVector(40, 40, 40) * v4

								if v12 == 3 then
									clone4.Color = Color3.fromRGB(255, 85, 0)
								elseif v12 == 2 then
									clone4.Color = Color3.fromRGB(255, 110, 0)
								end

								clone4.CFrame = cFrame3
								clone4.Parent = workspace.Effects
								_G.PU:Dust(clone4, 2)
								TweenService:Create(
									clone4,
									TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
									{
										Size = createVector(65, 65, 65) * v4
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
										Size = Vector3.new(),
										Color = Color3.fromRGB()
									}
								):Play()
							end)
						end
					end)
					spawn(function()
						local v11 = cFrame2.p + createVector(0, 5, 0)
						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = { workspace.Island }
						raycastParams.FilterType = Enum.RaycastFilterType.Include
						local raycastResult = workspace:Raycast(v11, createVector(0, -15, 0), raycastParams)

						if raycastResult then
							local position = raycastResult.Position
							local clone4 = ReplicatedStorage.Chest.Etc.PartPar:Clone()
							clone4.Attachment.Smoke.Color = ColorSequence.new(Color3.fromRGB(49, 49, 49))
							clone4.Attachment.Smoke.Speed = NumberRange.new(125 * v4 * 1.25)
							clone4.CFrame = CFrame.new(position + raycastResult.Normal, position) * CFrame.Angles(
								1.5707963267948966,
								0,
								0
							)
							clone4.Parent = workspace.Effects
							_G.PU:Dust(clone4, 5)

							for i2 = 1, 3 do
								clone4.Attachment.Smoke:Emit(10)
								wait()
							end
						else
							local clone4 = ReplicatedStorage.Chest.Etc.PartPar:Clone()
							clone4.Attachment.Smoke.Color = ColorSequence.new(Color3.fromRGB(49, 49, 49))
							clone4.Attachment.Smoke.Speed = NumberRange.new(125 * v4 * 1.25)
							clone4.CFrame = CFrame.new(cFrame2.p)
							clone4.Parent = workspace.Effects
							_G.PU:Dust(clone4, 5)

							for i2 = 1, 3 do
								clone4.Attachment.Smoke:Emit(10)
								wait()
							end
						end
					end)
				end)
				wait(0.1)
			end
		end
	end
end