local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local localPlayer = game.Players.LocalPlayer
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(list)
	local _, cFrame2, v2, _ = unpack(list)
	local success, result = pcall(function()
		if type(v2) == "table" and v2.LoopDistance then
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

		local mode = v2.Mode

		if mode == "Shark Man Z" then
			spawn(function()
				local rootPart = v2.RootPart
				local sharkBladeFolder = v2.SharkBladeFolder
				local character = v2.Character
				tick()
				PeodizService.HeartbeatWait({
					Time = 3,
					WaitTime = 0.05
				}, function()
					if not sharkBladeFolder:IsDescendantOf(character) then
						return true
					end

					local cFrame = rootPart.CFrame
					local v3 = math.random(30, 40) / 2
					local clone = ReplicatedStorage.Chest.SwordEffect.SharkBlade.GreySlash:Clone()
					_G.PU:Dust(clone, 0.5)
					clone.Decal.Transparency = -1
					clone.Decal.Color3 = math.random(1, 2) == 1 and Color3.fromRGB(102, 102, 102) or Color3.fromRGB(
						138,
						138,
						138
					)
					clone.Mesh.Scale = Vector3.new(v3, 0.125, v3)
					clone.CFrame = cFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
						0,
						math.random(-2, 3),
						math.random(-v3 / 5, v3 / 5)
					)
					clone.Parent = workspace.Effects
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://9672260647",
						Volume = 0.5
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = clone
					sound:Play()
					TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
						CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					}):Play()
					TweenService:Create(clone.Decal, TweenInfo.new(0.25), {
						Transparency = 1
					}):Play()
				end)
			end)
		elseif mode == "Shark Man X" then
			if (localPlayer.Character.HumanoidRootPart.Position - cFrame2.p).Magnitude < 150 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
			end

			local _ = v2.RootPart
			local clone = ReplicatedStorage.Chest.SwordEffect.SharkBlade.ParticlePart:Clone()
			clone.Attachment.Spark.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.378, 3.19, 3.19),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Attachment.Ring.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 2.31),
				NumberSequenceKeypoint.new(1, 40)
			})
			clone.Par1.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.302, 10),
				NumberSequenceKeypoint.new(0.518, 10),
				NumberSequenceKeypoint.new(0.788, 4.19),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Par2.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.302, 10),
				NumberSequenceKeypoint.new(0.518, 10),
				NumberSequenceKeypoint.new(0.788, 4.19),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Rock.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.0994, 0.313, 0.313),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Size = createVector(20, 20, 20)
			clone.CFrame = cFrame2
			clone.Parent = workspace.Effects
			clone.Attachment.Ring:Emit(1)
			clone.Attachment.Spark:Emit(15)
			clone.Par1:Emit(5)
			clone.Par2:Emit(5)
			clone.Rock:Emit(30)
			task.spawn(function()
				local v3 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://9799804730",
					Volume = 2
				}
				local sound = PeoUtils.CreateSound(v3)
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
			end)
			_G.PU:Dust(clone, 2)
			local clone2 = ReplicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
			clone2.CastShadow = false
			clone2.Transparency = 0.1
			clone2.CFrame = cFrame2
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(60, 3, 60),
				Transparency = 1,
				CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			_G.PU:Dust(clone2, 0.5)
			spawn(function()
				local v3 = CFrame.new(cFrame2.p) * CFrame.new(0, 25, 0)
				local ray = Ray.new(v3.p, createVector(0, -50, 0))
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
					clone3.Decal.Color3 = Color3.fromRGB()
					clone3.Decal.Transparency = 0.2
					clone3.Decal.Texture = "rbxassetid://7068839334"
					clone3.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						6.283185307179586 * math.random(),
						0
					) * CFrame.new(0, -1, 0)
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 1.5)
					TweenService:Create(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {
						Size = createVector(25, 0, 25)
					}):Play()
					spawn(function()
						wait(1)
						TweenService:Create(clone3.Decal, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end)
				end
			end)

			for i = 1, 15 do
				local cframe = CFrame.new(cFrame2.p) * CFrame.Angles(0, 6.283185307179586 * i / 15, 0) * CFrame.new(
					0,
					0,
					-15
				)
				local ray = Ray.new(cframe.p, createVector(0, -50, 0))
				local _, v3, _ = cframe:ToOrientation()
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
				part.CFrame = CFrame.new(cFrame2.p)
				part.Size = createVector(0, 0, 0)
				part.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v3, 0) * CFrame.new(
						0,
						math.random(-10, 10) / 10,
						0
					) * CFrame.Angles(math.rad((math.random(30, 60))), 0, 0),
					Size = createVector(7.7, 2.8, 2.8)
				}):Play()
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
		elseif mode == "Bear Man Z" then
			if (localPlayer.Character.HumanoidRootPart.Position - cFrame2.p).Magnitude < 150 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			local _ = v2.RootPart
			local clone = ReplicatedStorage.Chest.SwordEffect.SharkBlade.ParticlePart:Clone()
			clone.Attachment.Spark.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.378, 3.19, 3.19),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Attachment.Ring.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 2.31),
				NumberSequenceKeypoint.new(1, 40)
			})
			clone.Par1.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.302, 10),
				NumberSequenceKeypoint.new(0.518, 10),
				NumberSequenceKeypoint.new(0.788, 4.19),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Par2.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.302, 10),
				NumberSequenceKeypoint.new(0.518, 10),
				NumberSequenceKeypoint.new(0.788, 4.19),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Rock.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.0994, 0.313, 0.313),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Size = createVector(20, 20, 20)
			clone.CFrame = cFrame2
			clone.Parent = workspace.Effects
			task.spawn(function()
				local v3 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://9799804730",
					Volume = 2
				}
				local sound = PeoUtils.CreateSound(v3)
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
			end)
			_G.PU:Dust(clone, 2)

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				_G.ParticleSize(emitter, 2)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			local clone2 = ReplicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
			clone2.CastShadow = false
			clone2.Transparency = 0.1
			clone2.CFrame = cFrame2
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(60, 3, 60),
				Transparency = 1,
				CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			_G.PU:Dust(clone2, 0.5)
			spawn(function()
				local v3 = CFrame.new(cFrame2.p) * CFrame.new(0, 25, 0)
				local ray = Ray.new(v3.p, createVector(0, -50, 0))
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
					clone3.Decal.Color3 = Color3.fromRGB()
					clone3.Decal.Transparency = 0.5
					clone3.Decal.Texture = "rbxassetid://7068839334"
					clone3.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						6.283185307179586 * math.random(),
						0
					) * CFrame.new(0, -1, 0)
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 1.5)
					TweenService:Create(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {
						Size = createVector(60, 0, 60)
					}):Play()
					spawn(function()
						wait(1)
						TweenService:Create(clone3.Decal, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end)
				end
			end)

			for i = 1, 15 do
				local cframe = CFrame.new(cFrame2.p) * CFrame.Angles(0, 6.283185307179586 * i / 15, 0) * CFrame.new(
					0,
					0,
					-30
				)
				local ray = Ray.new(cframe.p, createVector(0, -50, 0))
				local _, v3, _ = cframe:ToOrientation()
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
				part.CFrame = CFrame.new(cFrame2.p)
				part.Size = createVector(0, 0, 0)
				part.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v3, 0) * CFrame.new(
						0,
						math.random(-10, 10) / 10,
						0
					) * CFrame.Angles(math.rad((math.random(30, 60))), 0, 0),
					Size = createVector(13.3, 2.8, 2.8)
				}):Play()
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
		end
	end
end