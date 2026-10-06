local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(list)
	local _, v, v2, _ = unpack(list)
	local success, result = pcall(function()
		if type(v2) == "table" and v2.LoopDistance then
			return false
		end

		if v then
			return (localPlayer.Character.HumanoidRootPart.Position - v.p).Magnitude > 1000
		end

		return false
	end)

	if success then
		if result then
			return
		end

		local mode = v2.Mode

		if mode == "Z" then
			local rootPart = v2.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9586482379",
				Volume = 4
			})
			_G.PU:Dust(sound, 1)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.Etc.DragonClaw.Shockwave:Clone()
			clone.Color = Color3.fromRGB(0, 170, 255)
			clone.CFrame = v * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Size = createVector(96.26, 96.26, 7.8250003)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1.5)
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(41.87, 41.87, 115.05),
				CFrame = clone.CFrame * CFrame.new(0, 0, 100) * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local clone2 = ReplicatedStorage.Chest.Etc.DragonClaw.Sphere:Clone()
			clone2.Transparency = -1
			clone2.Color = Color3.fromRGB(0, 170, 255)
			clone2.CFrame = v * CFrame.new(0, 0, -5)
			clone2.Size = createVector(40, 40, 25)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 145),
				CFrame = v * CFrame.new(0, 0, -70),
				Transparency = 1
			}):Play()
			spawn(function()
				for i = 1, 2 do
					local v3 = v * CFrame.new(0, 0, i * -10)
					local v4 = i == 2 and 3.5 or 5
					local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
					clone3.Transparency = -1
					clone3.Color = Color3.fromRGB(0, 170, 255)
					clone3.CFrame = v3 * CFrame.new(0, 0, -10) * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone3.Size = createVector(8.897, 0.658, 8.897)
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 1)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(21.166, 1.565, 21.166) * v4,
							CFrame = v3 * CFrame.new(0, 0, 1) * CFrame.Angles(-1.5707963267948966, 0, 0),
							Transparency = 1
						}
					):Play()
					wait()
				end
			end)

			for i = 1, 6 do
				local clone3 = ReplicatedStorage.Chest.Etc.CombatFishman.ParticlePart:Clone()
				clone3.Attachment.ParticleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255))
				clone3.Attachment.ParticleEmitter.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 15, 15),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone3.Attachment.ParticleEmitter.Speed = NumberRange.new(100, 200)
				clone3.CFrame = v * CFrame.new(0, 0, i * -3 * 5) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3.Parent = workspace.Effects
				clone3.Attachment.ParticleEmitter:Emit(10)
				TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(60, 8, 60)
				}):Play()
				_G.PU:Dust(clone3, 1)
				wait()
			end
		elseif mode == "X" then
			local tableCF = v2.TableCF

			for i = 1, 10 do
				local v3 = tableCF[i]
				local v4 = v3 * CFrame.new(0, 0, -150)
				local magnitude = (v3.p - v4.p).magnitude
				local clone = ReplicatedStorage.Chest.Etc.DragonClaw.Shockwave:Clone()
				clone.Color = Color3.fromRGB(0, 170, 255)
				clone.CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, 0) * CFrame.Angles(0, 3.141592653589793, 0)
				clone.Size = createVector(38.504, 38.504, 3.13)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1.5)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(16.748, 16.748, 46.02),
					CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, -magnitude / 1.15) * CFrame.Angles(
						0,
						3.141592653589793,
						3.839724354387525
					)
				}):Play()
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				local clone2 = ReplicatedStorage.Chest.Etc.DragonClaw.Sphere:Clone()
				clone2.Color = Color3.fromRGB(0, 170, 255)
				clone2.CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, -5)
				clone2.Size = createVector(16, 16, 10)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 1)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(0, 0, magnitude - 5),
						CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, -magnitude / 2 + 5)
					}
				):Play()
				TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				local clone3 = ReplicatedStorage.Chest.Etc.DragonClaw.WindRing:Clone()
				clone3.Color = Color3.fromRGB(0, 170, 255)
				clone3.CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, -10) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3.Size = createVector(17.794, 1.316, 17.794)
				clone3.Parent = workspace.Effects
				_G.PU:Dust(clone3, 1)
				TweenService:Create(
					clone3,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(42.332, 3.13, 42.332),
						CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, 1) * CFrame.Angles(1.5707963267948966, 0, 0)
					}
				):Play()
				TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				wait(0.05)
			end
		elseif mode == "C" then
			local tableCF = v2.TableCF

			for i = 1, 10 do
				local v3 = tableCF[i]
				local v4 = v3 * CFrame.new(0, 0, -75)
				local magnitude = (v3.p - v4.p).magnitude
				local clone = ReplicatedStorage.Chest.Etc.DragonClaw.Shockwave:Clone()
				clone.Color = Color3.fromRGB(0, 170, 255)
				clone.CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, 0) * CFrame.Angles(0, 3.141592653589793, 0)
				clone.Size = createVector(19.252, 19.252, 1.565)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1.5)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 100,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://9586482379",
					PlaybackSpeed = 1.5,
					Volume = 0.5
				})
				_G.PU:Dust(sound, 1.5)
				sound.Parent = clone
				sound:Play()
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(16.748, 16.748, 46.02),
					CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, -magnitude / 1.15) * CFrame.Angles(
						0,
						3.141592653589793,
						3.839724354387525
					)
				}):Play()
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				local clone2 = ReplicatedStorage.Chest.Etc.DragonClaw.Sphere:Clone()
				clone2.Color = Color3.fromRGB(0, 170, 255)
				clone2.CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, -5)
				clone2.Size = createVector(8, 8, 5)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 1)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(0, 0, magnitude - 5),
						CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, -magnitude / 2 + 5)
					}
				):Play()
				TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				local clone3 = ReplicatedStorage.Chest.Etc.DragonClaw.WindRing:Clone()
				clone3.Color = Color3.fromRGB(0, 170, 255)
				clone3.CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, -10) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3.Size = createVector(8.897, 0.658, 8.897)
				clone3.Parent = workspace.Effects
				_G.PU:Dust(clone3, 1)
				TweenService:Create(
					clone3,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(21.166, 1.565, 21.166),
						CFrame = CFrame.new(v3.p, v4.p) * CFrame.new(0, 0, 1) * CFrame.Angles(1.5707963267948966, 0, 0)
					}
				):Play()
				TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				wait(0.05)
			end
		elseif mode == "Fishman Z" then
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
			local clone = ReplicatedStorage.Chest.Etc.DragonClaw.Shockwave:Clone()
			clone.Color = Color3.fromRGB(255, 255, 255)
			clone.CFrame = v * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Size = createVector(48.13, 48.13, 3.9125001)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1.5)
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(20.935, 20.935, 57.525),
				CFrame = clone.CFrame * CFrame.new(0, 0, 50) * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local clone2 = ReplicatedStorage.Chest.Etc.DragonClaw.Sphere:Clone()
			clone2.Transparency = -1
			clone2.Color = Color3.fromRGB(255, 255, 255)
			clone2.CFrame = v * CFrame.new(0, 0, -5)
			clone2.Size = createVector(20, 20, 12.5)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 70),
				CFrame = v * CFrame.new(0, 0, -32.5),
				Transparency = 1
			}):Play()
			spawn(function()
				for i = 1, 2 do
					local v3 = v * CFrame.new(0, 0, i / 2 * -10)
					local v4 = i == 2 and 1.75 or 2.5
					local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
					clone3.Transparency = -1
					clone3.Color = Color3.fromRGB(255, 255, 255)
					clone3.CFrame = v3 * CFrame.new(0, 0, -10) * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone3.Size = createVector(8.897, 0.658, 8.897)
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 1)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(21.166, 1.565, 21.166) * v4,
							CFrame = v3 * CFrame.new(0, 0, 1) * CFrame.Angles(-1.5707963267948966, 0, 0),
							Transparency = 1
						}
					):Play()
					wait()
				end
			end)
		elseif mode == "Fishman Upgrade Z" then
			local rootPart = v2.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9585647437",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 1)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.Etc.DragonClaw.Shockwave:Clone()
			clone.Color = Color3.fromRGB(255, 255, 255)
			clone.CFrame = v * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Size = createVector(96.26, 96.26, 7.8250003)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1.5)
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(41.87, 41.87, 115.05),
				CFrame = clone.CFrame * CFrame.new(0, 0, 100) * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local clone2 = ReplicatedStorage.Chest.Etc.DragonClaw.Sphere:Clone()
			clone2.Transparency = -1
			clone2.Color = Color3.fromRGB(255, 255, 255)
			clone2.CFrame = v * CFrame.new(0, 0, -5)
			clone2.Size = createVector(40, 40, 25)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 145),
				CFrame = v * CFrame.new(0, 0, -70),
				Transparency = 1
			}):Play()
			spawn(function()
				for i = 1, 2 do
					local v3 = v * CFrame.new(0, 0, i * -10)
					local v4 = i == 2 and 3.5 or 5
					local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
					clone3.Transparency = -1
					clone3.Color = Color3.fromRGB(255, 255, 255)
					clone3.CFrame = v3 * CFrame.new(0, 0, -10) * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone3.Size = createVector(8.897, 0.658, 8.897)
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 1)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(21.166, 1.565, 21.166) * v4,
							CFrame = v3 * CFrame.new(0, 0, 1) * CFrame.Angles(-1.5707963267948966, 0, 0),
							Transparency = 1
						}
					):Play()
					wait()
				end
			end)
		elseif mode == "Rear Admiral Z" then
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
			local clone = ReplicatedStorage.Chest.Etc.DragonClaw.Shockwave:Clone()
			clone.Color = Color3.fromRGB(255, 255, 255)
			clone.CFrame = v * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Size = createVector(48.13, 48.13, 3.9125001)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1.5)
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(20.935, 20.935, 57.525),
				CFrame = clone.CFrame * CFrame.new(0, 0, 50) * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local clone2 = ReplicatedStorage.Chest.Etc.DragonClaw.Sphere:Clone()
			clone2.Transparency = -1
			clone2.Color = Color3.fromRGB(255, 255, 255)
			clone2.CFrame = v * CFrame.new(0, 0, -5)
			clone2.Size = createVector(20, 20, 12.5)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 70),
				CFrame = v * CFrame.new(0, 0, -32.5),
				Transparency = 1
			}):Play()
			spawn(function()
				for i = 1, 2 do
					local v3 = v * CFrame.new(0, 0, i / 2 * -10)
					local v4 = i == 2 and 1.75 or 2.5
					local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
					clone3.Transparency = -1
					clone3.Color = Color3.fromRGB(255, 255, 255)
					clone3.CFrame = v3 * CFrame.new(0, 0, -10) * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone3.Size = createVector(8.897, 0.658, 8.897)
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 1)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(21.166, 1.565, 21.166) * v4,
							CFrame = v3 * CFrame.new(0, 0, 1) * CFrame.Angles(-1.5707963267948966, 0, 0),
							Transparency = 1
						}
					):Play()
					wait()
				end
			end)

			for i = 1, 6 do
				local clone3 = ReplicatedStorage.Chest.Etc.CombatFishman.ParticlePart:Clone()
				clone3.Attachment.ParticleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
				clone3.Attachment.ParticleEmitter.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 7.5, 7.5),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone3.Attachment.ParticleEmitter.Speed = NumberRange.new(50, 100)
				clone3.CFrame = v * CFrame.new(0, 0, i * -3 * 2.5) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3.Parent = workspace.Effects
				clone3.Attachment.ParticleEmitter:Emit(10)
				TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(30, 4, 30)
				}):Play()
				_G.PU:Dust(clone3, 1)
				wait()
			end
		end
	end
end